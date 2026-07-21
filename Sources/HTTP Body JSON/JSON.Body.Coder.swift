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

public import JSON

extension JSON {
    /// The JSON document as an HTTP message body.
    public enum Body {}
}

extension JSON.Body {
    /// Reads and writes an HTTP message body as JSON, owning the
    /// `application/json` media type.
    ///
    /// Homed in the JSON namespace rather than under `HTTP.Body.Coder`
    /// because JSON is the *subject* and body-coding is the *role*
    /// ([API-NAME-001b]); the subject owns its specialisations.
    ///
    /// This type is the adapter that reconciles two honest but different byte
    /// surfaces: swift-json parses a borrowed `Span<Byte>` and emits into a
    /// `[UInt8]` buffer, while an HTTP body is a `[Byte]` in both directions.
    /// The conversion lives here, at the boundary, rather than widening either
    /// contract to accommodate the other.
    ///
    /// ```swift
    /// var request = HTTP.Request(method: .post, target: ...)
    /// try request.body(set: value, using: JSON.Body.Coder())
    /// // → body bytes installed AND `Content-Type: application/json`
    /// ```
    public struct Coder {
        /// The underlying JSON codec — depth limit and encoding options.
        public var json: JSON.Coder

        @inlinable
        public init(json: JSON.Coder = JSON.Coder()) {
            self.json = json
        }
    }
}
