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

// `HTTP.Body.Coder` names `HTTP.MediaType`, `HTTP.Request`, and `HTTP.Headers`
// in its public surface, and `Byte` in its `Input`/`Buffer` pinning — both
// re-exported so consumers get the vocabulary with one import ([PKG-DEP-003]).
@_exported public import Byte_Primitive
@_exported public import HTTP_Standard
