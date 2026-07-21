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
    /// A type that names one media type.
    ///
    /// ``HTTP/Body/Coder/Protocol`` states its media type at the type level, so
    /// a codec's media type travels with the codec's *type* and cannot be
    /// varied per value. The closure-backed ``HTTP/Body/Coder/Witness`` erases
    /// the codec's implementation but must still answer that type-level
    /// question, so it takes the answer as a parameter: `Media` is where the
    /// witness gets its `contentType` from.
    ///
    /// Conformers are empty — this carries no values, only a name:
    ///
    /// ```swift
    /// enum ApplicationJSON: HTTP.Body.Coder.Media {
    ///     static var contentType: HTTP.MediaType { .json }
    /// }
    /// ```
    public protocol Media {
        /// The media type this type names.
        static var contentType: HTTP.MediaType { get }
    }
}
