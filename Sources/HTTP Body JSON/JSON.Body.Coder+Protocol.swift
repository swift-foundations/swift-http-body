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
public import Either_Primitives
public import HTTP_Body
public import JSON

extension JSON.Body.Coder: RFC_9110.Body.Coder.`Protocol` {
    public typealias Input = [Byte]
    public typealias Buffer = [Byte]
    public typealias Output = RFC_8259.Value
    public typealias Failure = Either<RFC_8259.Error, JSON.Encode.Error>

    /// Leaf codec: both directions are implemented directly, so there is no
    /// composed body. Load-bearing for witness-table emission
    /// ([API-IMPL-020]).
    public typealias Body = Never

    /// Explicit leaf body. `Parser.Protocol` and `Serializer.Protocol` each
    /// supply a `Body == Never` default getter, and this concrete conformance
    /// otherwise has two equally-good candidates.
    @inlinable
    public var body: Never {
        borrowing get { return fatalError("leaf codec — parse(_:) and serialize(_:into:) are implemented directly") }
    }

    public static var contentType: HTTP.MediaType { .json }

    /// Decodes the whole body. swift-json's wholesale parser consumes its
    /// entire input (RFC 8259 §2 trailing-content check), so on success the
    /// HTTP body is fully consumed and `input` is emptied to match the
    /// inout-advance contract.
    @inlinable
    public func parse(_ input: inout [Byte]) throws(Failure) -> RFC_8259.Value {
        let bytes = input
        var span = bytes.span
        let value = try json.parse(&span)
        input = []
        return value
    }

    /// Encodes into an EMPTY scratch buffer, then appends — the serialize
    /// world is forward-append and must not be entered over a buffer it does
    /// not own (ratification-queue item 14).
    @inlinable
    public func serialize(_ output: RFC_8259.Value, into buffer: inout [Byte]) throws(Failure) {
        var scratch: [UInt8] = []
        try json.serialize(output, into: &scratch)
        buffer.append(contentsOf: scratch.map(Byte.init))
    }
}
