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

extension RFC_9110.Body.Coder.Error {
    /// A failure of the request's `Content-Type` field.
    public enum Header: Equatable, Sendable {
        /// The body is present but unlabelled.
        case missing(expected: HTTP.MediaType)

        /// The field is not a well-formed media type per RFC 9110 §8.3.
        case malformed(expected: HTTP.MediaType, actual: String)

        /// The body is labelled with a media type the codec does not accept.
        case unacceptable(expected: HTTP.MediaType, actual: HTTP.MediaType)
    }
}
