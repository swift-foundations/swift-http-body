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

extension RFC_9110 {
    /// The HTTP message-body namespace (RFC 9110 §6.4).
    ///
    /// RFC 9110 models the body as the content an HTTP message carries, and
    /// §8.3 makes `Content-Type` the field that names how those bytes are to
    /// be read. The two are one contract: bytes whose media type is unstated
    /// are bytes a recipient may not interpret. `HTTP.Body` is the home of
    /// that coupling — see ``HTTP/Body/Coder``.
    public enum Body {}
}
