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

extension RFC_9110.Body {
    /// The body-coder namespace: bidirectional codecs that own their
    /// `Content-Type`.
    ///
    /// - Important: inside this namespace the unqualified name `Coder`
    ///   resolves *here*, shadowing the `Coder` namespace of
    ///   `swift-coder-primitives`. Every reference to the primitive must be
    ///   spelled `Coder_Primitives.Coder` ([API-IMPL-019]); the unqualified
    ///   spelling produces a `circular reference` diagnostic that names
    ///   neither type.
    public enum Coder {}

    /// The active capability an HTTP body codec conforms to
    /// ([PKG-NAME-002] gerund alias of ``HTTP/Body/Coder/Protocol``).
    public typealias Coding = RFC_9110.Body.Coder.`Protocol`
}
