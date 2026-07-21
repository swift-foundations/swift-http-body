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
    /// The media type is supplied by the `Media` parameter rather than stored,
    /// because ``HTTP/Body/Coder/Protocol`` asks the question of the *type*:
    /// the codec's implementation is erased into closures, its media type is
    /// not.
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

        @inlinable
        public init(
            parse: @escaping (inout [Byte]) throws(Failure) -> Output,
            serialize: @escaping (Output, inout [Byte]) throws(Failure) -> Void
        ) {
            self._parse = parse
            self._serialize = serialize
        }
    }
}
