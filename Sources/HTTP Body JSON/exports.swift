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

// The JSON lift is an opt-in leaf over the core contract: consumers that
// import it get `HTTP.Body.Coding` and the JSON vocabulary together.
@_exported public import HTTP_Body
@_exported public import JSON
