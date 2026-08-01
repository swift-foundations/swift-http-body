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

import HTTP_Body

extension RFC_9110.Body.Coder.Test {
    enum MultipartFormData: RFC_9110.Body.Coder.Media {}
}

extension RFC_9110.Body.Coder.Test.MultipartFormData {
    static var contentType: HTTP.MediaType {
        HTTP.MediaType("multipart", "form-data")
    }
}
