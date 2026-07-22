// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

public import Byte_Primitive
public import HTTP_Standard

extension RFC_9110.Body.Coder {
    /// The closure-backed body codec — the canonical witness for
    /// ``HTTP/Body/Coder/Protocol`` ([PKG-NAME-015]).
    ///
    /// The media identity is supplied by the `Media` parameter rather than
    /// stored, because ``HTTP/Body/Coder/Protocol`` asks that question of the
    /// *type*. The realized media type still travels through the stored encode
    /// and decode closures, preserving parameters selected for particular
    /// bodies.
    ///
    /// ```swift
    /// enum ApplicationOctetStream: HTTP.Body.Coder.Media {
    ///     static var contentType: HTTP.MediaType { .octetStream }
    /// }
    ///
    /// let identity = HTTP.Body.Coder.Witness<ApplicationOctetStream, [Byte], Never>(
    ///     parse: { bytes in defer { bytes = [] }; return bytes },
    ///     serialize: { value, buffer in buffer.append(contentsOf: value) }
    /// )
    /// ```
    public struct Witness<Media: RFC_9110.Body.Coder.Media, Output, Failure: Swift.Error> {
        /// The stored decode closure. Underscore signals implementation
        /// hatch — call ``parse(_:)``.
        public var _parse: (inout [Byte]) throws(Failure) -> Output

        /// The stored encode closure. Underscore signals implementation
        /// hatch — call ``serialize(_:into:)``.
        public var _serialize: (Output, inout [Byte]) throws(Failure) -> Void

        /// The stored media-aware decode closure. Underscore signals
        /// implementation hatch — call ``decode(_:as:)``.
        public var _decode: (inout [Byte], HTTP.MediaType) throws(Failure) -> Output

        /// The stored media-aware encode closure. Underscore signals
        /// implementation hatch — call ``encode(_:into:)``.
        public var _encode: (Output, inout [Byte]) throws(Failure) -> HTTP.MediaType

        @inlinable
        public init(
            parse: @escaping (inout [Byte]) throws(Failure) -> Output,
            serialize: @escaping (Output, inout [Byte]) throws(Failure) -> Void
        ) {
            self._parse = parse
            self._serialize = serialize
            self._decode = { input, _ throws(Failure) in try parse(&input) }
            self._encode = { output, buffer throws(Failure) in
                try serialize(output, &buffer)
                return Media.contentType
            }
        }

        /// Creates a witness that preserves media-aware body coding while
        /// erasing the concrete codec implementation.
        @inlinable
        public init(
            parse: @escaping (inout [Byte]) throws(Failure) -> Output,
            serialize: @escaping (Output, inout [Byte]) throws(Failure) -> Void,
            decode: @escaping (inout [Byte], HTTP.MediaType) throws(Failure) -> Output,
            encode: @escaping (Output, inout [Byte]) throws(Failure) -> HTTP.MediaType
        ) {
            self._parse = parse
            self._serialize = serialize
            self._decode = decode
            self._encode = encode
        }
    }
}
