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
public import Coder_Primitives
public import HTTP_Standard
// `Input` and `Buffer` are declared by `Parser.Protocol` / `Serializer.Protocol`
// in these modules; the `where` clause below names them, so under
// MemberImportVisibility the DEFINING modules must be imported — and publicly,
// since they appear in a public protocol's requirements.
public import Parser_Primitive
public import Serializer_Primitive

extension RFC_9110.Body.Coder {
    /// A bidirectional codec for an HTTP message body that **owns its media
    /// type**.
    ///
    /// This is the contract that closes the RT-030 class. A codec that can
    /// only turn a value into bytes leaves the `Content-Type` field to the
    /// caller, and a field that every caller must remember is a field some
    /// caller will forget — silently, because a body with no media type still
    /// serialises, still transmits, and only fails at the far end. Binding the
    /// two together makes the omission unrepresentable: there is no way to
    /// install a body through this contract without also stating how to read
    /// it.
    ///
    /// ## Shape
    ///
    /// Refines `Coder.Protocol` with `Input` and `Buffer` both pinned to
    /// `[Byte]` — an HTTP body *is* a byte sequence in both directions, so the
    /// codec is a `Parser.Bidirectional` in the `Buffer == Input` sense.
    /// Codecs whose native surface is narrower (a `Span<Byte>` parser, a
    /// `[UInt8]` buffer) adapt at their own boundary; see the `HTTP Body JSON`
    /// target for the worked example.
    ///
    /// ## Conforming
    ///
    /// ```swift
    /// struct PlainText: HTTP.Body.Coding {
    ///     typealias Output = String
    ///     typealias Failure = Never
    ///     typealias Body = Never          // [API-IMPL-020]
    ///
    ///     static var contentType: HTTP.MediaType { .plain }
    ///
    ///     func parse(_ input: inout [Byte]) -> String { ... }
    ///     func serialize(_ output: String, into buffer: inout [Byte]) { ... }
    /// }
    /// ```
    public protocol `Protocol`<Output, Failure>: Coder_Primitives.Coder.`Protocol`
    where Input == [Byte], Buffer == [Byte] {
        /// The media type this codec writes, and the one it reads.
        ///
        /// Type-level: a codec's media type is a property of the codec itself,
        /// not of a particular value of it. The type-erased
        /// ``HTTP/Body/Coder/Witness`` carries it through a
        /// ``HTTP/Body/Coder/Media`` parameter rather than as stored data.
        static var contentType: HTTP.MediaType { get }

        /// Whether this codec is willing to decode a body labelled
        /// `mediaType`.
        ///
        /// Defaults to RFC 9110 §8.3 type/subtype matching against
        /// ``contentType``, ignoring parameters — a body labelled
        /// `application/json;charset=utf-8` is JSON.
        func accepts(_ mediaType: HTTP.MediaType) -> Bool
    }
}

extension RFC_9110.Body.Coder.`Protocol` {
    @inlinable
    public func accepts(_ mediaType: HTTP.MediaType) -> Bool {
        mediaType.matches(Self.contentType)
    }
}
