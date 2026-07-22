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
    /// A failure of the request body itself.
    public enum Body: Equatable, Sendable {
        /// The request carried no body at all.
        case missing
    }
}
