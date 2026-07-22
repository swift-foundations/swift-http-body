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
        /// The media type family this codec writes and reads.
        ///
        /// Type-level: a codec's media identity is a property of the codec
        /// itself, not of a particular value of it. Parameters that are only
        /// known while encoding — notably an RFC 2046 multipart boundary — are
        /// returned by ``encode(_:into:)`` as part of the realized media type.
        /// Conformers must return a realized value whose type and subtype match
        /// this identity.
        /// The type-erased
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

        /// Decodes bytes whose realized media type has already been accepted.
        ///
        /// The media type is passed through rather than discarded so codecs
        /// whose grammar depends on a parameter — notably multipart codecs —
        /// can recover the sender's boundary. Fixed-media codecs inherit a
        /// default that delegates to ``parse(_:)``.
        func decode(
            _ input: inout [Byte],
            as mediaType: HTTP.MediaType
        ) throws(Failure) -> Output

        /// Encodes a value and returns the realized media type for those bytes.
        ///
        /// The returned value, rather than ``contentType``, is installed on the
        /// request. This lets an encoder select a parameter while producing the
        /// bytes and report the exact value that describes them. Its type and
        /// subtype must match ``contentType``; parameters may differ. Fixed-
        /// media codecs inherit a default that serializes and returns
        /// ``contentType``.
        func encode(
            _ output: Output,
            into buffer: inout [Byte]
        ) throws(Failure) -> HTTP.MediaType
    }
}

extension RFC_9110.Body.Coder.`Protocol` {
    @inlinable
    public func accepts(_ mediaType: HTTP.MediaType) -> Bool {
        mediaType.matches(Self.contentType)
    }

    @inlinable
    public func decode(
        _ input: inout [Byte],
        as mediaType: HTTP.MediaType
    ) throws(Failure) -> Output {
        _ = mediaType
        return try parse(&input)
    }

    @inlinable
    public func encode(
        _ output: Output,
        into buffer: inout [Byte]
    ) throws(Failure) -> HTTP.MediaType {
        try serialize(output, into: &buffer)
        return Self.contentType
    }
}
