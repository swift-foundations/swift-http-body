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
public import Parser_Primitive
public import Serializer_Primitive

extension RFC_9110.Request {
    /// Installs `value` as this request's body, encoded by `coder`, and states
    /// the media type in the same operation.
    ///
    /// The coupling is the point: the body bytes and the `Content-Type` field
    /// are written together or not at all, so a request cannot leave here
    /// carrying content it has not labelled. Any `Content-Type` already on the
    /// request is replaced — a message has one media type, and appending a
    /// second field would make the request ambiguous rather than updated.
    ///
    /// - Parameters:
    ///   - value: The value to encode into the body.
    ///   - coder: The codec that both encodes `value` and names its media type.
    @inlinable
    public mutating func body<C: RFC_9110.Body.Coder.`Protocol`>(
        set value: C.Output,
        using coder: C
    ) throws(C.Failure) {
        // Forward-append into an EMPTY scratch buffer: the serialize world is
        // append-oriented and must never be entered over a non-empty buffer
        // owned by the prepend world (ratification-queue item 14).
        var bytes: [Byte] = []
        try coder.serialize(value, into: &bytes)

        self.body = bytes
        self.headers.removeAll(named: RFC_9110.Header.Field.Name.contentType.rawValue)
        self.headers.append(
            RFC_9110.Header.Field(
                name: .contentType,
                // The media type's own description is field-value-legal by
                // construction (RFC 9110 §8.3 token/parameter grammar).
                value: RFC_9110.Header.Field.Value(unchecked: C.contentType.description)
            )
        )
    }

    /// Decodes this request's body through `coder`, refusing to read bytes
    /// whose stated media type `coder` does not accept.
    ///
    /// Validation precedes decoding deliberately. Handing `application/xml`
    /// bytes to a JSON codec produces a parse error that describes the wrong
    /// problem; checking the label first produces one that names it.
    ///
    /// - Parameters:
    ///   - outputType: The value type to decode — redundant with `coder`, and
    ///     present so the call site reads as what it yields.
    ///   - coder: The codec that both decodes the body and names the media
    ///     type it accepts.
    @inlinable
    public func body<C: RFC_9110.Body.Coder.`Protocol`>(
        decode outputType: C.Output.Type,
        using coder: C
    ) throws(RFC_9110.Body.Coder.Error<C.Failure>) -> C.Output {
        _ = outputType

        guard var bytes = self.body else {
            throw .bodyMissing
        }

        guard let field = self.headers.first(RFC_9110.Header.Field.Name.contentType.rawValue) else {
            throw .contentTypeMissing(expected: C.contentType)
        }

        guard let mediaType = HTTP.MediaType.parse(field.rawValue) else {
            throw .contentTypeMalformed(expected: C.contentType, actual: field.rawValue)
        }

        guard coder.accepts(mediaType) else {
            throw .contentTypeUnacceptable(expected: C.contentType, actual: mediaType)
        }

        do throws(C.Failure) {
            return try coder.parse(&bytes)
        } catch {
            throw .decodeFailed(error)
        }
    }
}
