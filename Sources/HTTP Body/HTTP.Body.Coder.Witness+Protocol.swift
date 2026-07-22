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

extension RFC_9110.Body.Coder.Witness: RFC_9110.Body.Coder.`Protocol` {
    public typealias Input = [Byte]
    public typealias Buffer = [Byte]

    /// Leaf witness: ``parse(_:)`` and ``serialize(_:into:)`` are implemented
    /// directly from the stored closures, so there is no composed body. The
    /// explicit typealias is load-bearing for witness-table emission on a
    /// generic conformer ([API-IMPL-020]).
    public typealias Body = Never

    /// Forwarded from the `Media` parameter — the witness erases the codec's
    /// implementation, not its media type.
    @inlinable
    public static var contentType: HTTP.MediaType { Media.contentType }

    @inlinable
    public func parse(_ input: inout [Byte]) throws(Failure) -> Output {
        try _parse(&input)
    }

    @inlinable
    public func serialize(_ output: Output, into buffer: inout [Byte]) throws(Failure) {
        try _serialize(output, &buffer)
    }
}
