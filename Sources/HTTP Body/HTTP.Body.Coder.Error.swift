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

public import HTTP_Standard

extension RFC_9110.Body.Coder {
    /// Why a body could not be decoded through a ``HTTP/Body/Coder/Protocol``.
    ///
    /// Every case names a failure of the message, not a remedy
    /// ([API-ERR-003]). `Failure` is the codec's own error domain, kept
    /// separate rather than flattened in, so a caller can tell "this was not
    /// the media type I asked for" from "it was, and it was malformed".
    public enum Error<Failure: Swift.Error>: Swift.Error {
        /// The request carried no body at all.
        case bodyMissing

        /// The request carried a body but no `Content-Type` field, so the
        /// bytes are unlabelled.
        case contentTypeMissing(expected: HTTP.MediaType)

        /// The `Content-Type` field is present but is not a well-formed
        /// media type per RFC 9110 §8.3.
        case contentTypeMalformed(expected: HTTP.MediaType, actual: String)

        /// The body is labelled with a media type this codec does not accept.
        case contentTypeUnacceptable(expected: HTTP.MediaType, actual: HTTP.MediaType)

        /// The media type matched; the bytes did not decode.
        case decodeFailed(Failure)
    }
}

extension RFC_9110.Body.Coder.Error: Equatable where Failure: Equatable {}

extension RFC_9110.Body.Coder.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .bodyMissing:
            "request has no body"
        case .contentTypeMissing(let expected):
            "request body has no Content-Type; expected \(expected)"
        case .contentTypeMalformed(let expected, let actual):
            "Content-Type '\(actual)' is not a well-formed media type; expected \(expected)"
        case .contentTypeUnacceptable(let expected, let actual):
            "Content-Type \(actual) is not accepted; expected \(expected)"
        case .decodeFailed(let failure):
            "body did not decode: \(failure)"
        }
    }
}
