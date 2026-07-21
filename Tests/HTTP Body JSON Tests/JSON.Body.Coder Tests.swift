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

import Byte_Primitive
import Coder_Primitives
import HTTP_Body
import HTTP_Body_JSON
import Parser_Primitive
import Serializer_Primitive
import Testing

extension JSON.Body.Coder {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension JSON.Body.Coder.Test {
    static let document = #"{"a":1}"#

    static var bytes: [Byte] { Array(document.utf8).map(Byte.init) }

    static func text(_ bytes: [Byte]) -> String {
        String(decoding: bytes.map(\.underlying), as: UTF8.self)
    }
}

// MARK: - Unit

extension JSON.Body.Coder.Test.Unit {
    @Test
    func `owns the application-json media type`() {
        #expect(JSON.Body.Coder.contentType == .json)
    }

    @Test
    func `accepts a JSON body carrying a charset parameter`() {
        let labelled = HTTP.MediaType("application", "json", parameters: ["charset": "utf-8"])
        #expect(JSON.Body.Coder().accepts(labelled))
    }

    @Test
    func `refuses a body labelled as something else`() {
        #expect(!JSON.Body.Coder().accepts(.plain))
    }

    @Test
    func `round-trips a document through the byte-surface adapter`() throws {
        let coder = JSON.Body.Coder()

        var input = JSON.Body.Coder.Test.bytes
        let value = try coder.parse(&input)
        #expect(input.isEmpty, "the wholesale parser consumes the entire body")

        var output: [Byte] = []
        try coder.serialize(value, into: &output)
        #expect(JSON.Body.Coder.Test.text(output) == JSON.Body.Coder.Test.document)
    }
}

// MARK: - Edge Case

extension JSON.Body.Coder.Test.`Edge Case` {
    @Test
    func `serializing appends rather than replacing the buffer`() throws {
        let coder = JSON.Body.Coder()
        var input = JSON.Body.Coder.Test.bytes
        let value = try coder.parse(&input)

        var buffer: [Byte] = Array("prefix".utf8).map(Byte.init)
        try coder.serialize(value, into: &buffer)

        #expect(JSON.Body.Coder.Test.text(buffer) == "prefix" + JSON.Body.Coder.Test.document)
    }

    @Test
    func `malformed JSON surfaces as a decode failure, not a media-type problem`() throws {
        var request = HTTP.Request(method: .post)
        request.body = Array("{".utf8).map(Byte.init)
        request.headers.append(
            HTTP.Header.Field(name: .contentType, value: HTTP.Header.Field.Value(unchecked: "application/json"))
        )

        #expect(throws: RFC_9110.Body.Coder.Error<JSON.Body.Coder.Failure>.self) {
            try request.body(decode: RFC_8259.Value.self, using: JSON.Body.Coder())
        }
    }
}

// MARK: - Integration

extension JSON.Body.Coder.Test.Integration {
    @Test
    func `setting a JSON body labels the request application-json`() throws {
        let coder = JSON.Body.Coder()
        var input = JSON.Body.Coder.Test.bytes
        let value = try coder.parse(&input)

        var request = HTTP.Request(method: .post)
        try request.body(set: value, using: coder)

        #expect(request.headers.first("Content-Type")?.rawValue == "application/json")
        #expect(JSON.Body.Coder.Test.text(request.body ?? []) == JSON.Body.Coder.Test.document)
    }

    @Test
    func `a JSON body set through the codec decodes back through it`() throws {
        let coder = JSON.Body.Coder()
        var input = JSON.Body.Coder.Test.bytes
        let value = try coder.parse(&input)

        var request = HTTP.Request(method: .post)
        try request.body(set: value, using: coder)

        let decoded = try request.body(decode: RFC_8259.Value.self, using: coder)
        var output: [Byte] = []
        try coder.serialize(decoded, into: &output)
        #expect(JSON.Body.Coder.Test.text(output) == JSON.Body.Coder.Test.document)
    }
}
