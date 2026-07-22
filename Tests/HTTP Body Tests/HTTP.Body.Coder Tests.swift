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
import Parser_Primitive
import Serializer_Primitive
import Testing

extension RFC_9110.Body.Coder {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

// MARK: - Fixtures

extension RFC_9110.Body.Coder.Test {
    /// A codec that passes bytes through unchanged, labelled `text/plain`.
    struct Passthrough: RFC_9110.Body.Coder.`Protocol` {
        typealias Input = [Byte]
        typealias Buffer = [Byte]
        typealias Output = [Byte]
        typealias Failure = Never
        typealias Body = Never

        static var contentType: HTTP.MediaType { .plain }

        var body: Never { borrowing get { return fatalError("leaf") } }

        func parse(_ input: inout [Byte]) -> [Byte] {
            defer { input = [] }
            return input
        }

        func serialize(_ output: [Byte], into buffer: inout [Byte]) {
            buffer.append(contentsOf: output)
        }
    }

    /// A codec that always refuses to decode — exercises `decode`.
    struct Rejecting: RFC_9110.Body.Coder.`Protocol` {
        enum Fault: Swift.Error, Equatable { case always }

        typealias Input = [Byte]
        typealias Buffer = [Byte]
        typealias Output = [Byte]
        typealias Failure = Fault
        typealias Body = Never

        static var contentType: HTTP.MediaType { .plain }

        var body: Never { borrowing get { return fatalError("leaf") } }

        func parse(_ input: inout [Byte]) throws(Fault) -> [Byte] {
            throw .always
        }

        func serialize(_ output: [Byte], into buffer: inout [Byte]) throws(Fault) {
            buffer.append(contentsOf: output)
        }
    }

    static let hello: [Byte] = Array("hello".utf8).map(Byte.init)

    /// Media names for the witness fixtures — the witness takes its media type
    /// at the type level, so each one needs a name to point at.
    enum OctetStream: RFC_9110.Body.Coder.Media {
        static var contentType: HTTP.MediaType { .octetStream }
    }

    enum ApplicationJSON: RFC_9110.Body.Coder.Media {
        static var contentType: HTTP.MediaType { .json }
    }
}

// MARK: - Unit

extension RFC_9110.Body.Coder.Test.Unit {
    @Test
    func `accepts its own media type`() {
        #expect(RFC_9110.Body.Coder.Test.Passthrough().accepts(.plain))
    }

    @Test
    func `accepts its media type carrying parameters`() {
        let labelled = HTTP.MediaType("text", "plain", parameters: ["charset": "utf-8"])
        #expect(RFC_9110.Body.Coder.Test.Passthrough().accepts(labelled))
    }

    @Test
    func `refuses a different media type`() {
        #expect(!RFC_9110.Body.Coder.Test.Passthrough().accepts(.json))
    }

    @Test
    func `witness round-trips through its stored closures`() throws {
        let witness = RFC_9110.Body.Coder.Witness<RFC_9110.Body.Coder.Test.OctetStream, [Byte], Never>(
            parse: { bytes in
                defer { bytes = [] }
                return bytes
            },
            serialize: { value, buffer in buffer.append(contentsOf: value) }
        )

        var buffer: [Byte] = []
        witness.serialize(RFC_9110.Body.Coder.Test.hello, into: &buffer)
        #expect(buffer == RFC_9110.Body.Coder.Test.hello)

        var input = buffer
        #expect(witness.parse(&input) == RFC_9110.Body.Coder.Test.hello)
        #expect(input.isEmpty)
    }

    @Test
    func `witness takes its media type from its Media parameter`() {
        typealias JSONWitness = RFC_9110.Body.Coder.Witness<
            RFC_9110.Body.Coder.Test.ApplicationJSON, [Byte], Never
        >
        let json = JSONWitness(parse: { _ in [] }, serialize: { _, _ in })

        #expect(JSONWitness.contentType == .json)
        #expect(json.accepts(.json))
        #expect(!json.accepts(.plain))
    }

    @Test
    func `default body coding delegates to parse and serialize`() {
        let coder = RFC_9110.Body.Coder.Test.Passthrough()
        var buffer: [Byte] = []

        let mediaType = coder.encode(RFC_9110.Body.Coder.Test.hello, into: &buffer)
        #expect(mediaType == .plain)
        #expect(buffer == RFC_9110.Body.Coder.Test.hello)

        var input = buffer
        #expect(coder.decode(&input, as: .plain) == RFC_9110.Body.Coder.Test.hello)
        #expect(input.isEmpty)
    }
}

// MARK: - Edge Case

extension RFC_9110.Body.Coder.Test.`Edge Case` {
    @Test
    func `decoding a request with no body reports the missing body`() {
        let request = HTTP.Request(method: .post)
        #expect(throws: RFC_9110.Body.Coder.Error<Never>.body(.missing)) {
            try request.body(decode: [Byte].self, using: RFC_9110.Body.Coder.Test.Passthrough())
        }
    }

    @Test
    func `decoding an unlabelled body reports the missing Content-Type`() {
        var request = HTTP.Request(method: .post)
        request.body = RFC_9110.Body.Coder.Test.hello

        #expect(throws: RFC_9110.Body.Coder.Error<Never>.header(.missing(expected: .plain))) {
            try request.body(decode: [Byte].self, using: RFC_9110.Body.Coder.Test.Passthrough())
        }
    }

    @Test
    func `decoding a body labelled with another media type is refused`() {
        var request = HTTP.Request(method: .post)
        request.body = RFC_9110.Body.Coder.Test.hello
        request.headers.append(
            HTTP.Header.Field(name: .contentType, value: HTTP.Header.Field.Value(unchecked: "application/json"))
        )

        #expect(
            throws: RFC_9110.Body.Coder.Error<Never>.header(.unacceptable(expected: .plain, actual: .json))
        ) {
            try request.body(decode: [Byte].self, using: RFC_9110.Body.Coder.Test.Passthrough())
        }
    }

    @Test
    func `a codec failure surfaces as decode, not as a media-type problem`() {
        var request = HTTP.Request(method: .post)
        request.body = RFC_9110.Body.Coder.Test.hello
        request.headers.append(
            HTTP.Header.Field(name: .contentType, value: HTTP.Header.Field.Value(unchecked: "text/plain"))
        )

        let expected = RFC_9110.Body.Coder.Error<RFC_9110.Body.Coder.Test.Rejecting.Fault>.decode(.always)
        #expect(throws: expected) {
            try request.body(decode: [Byte].self, using: RFC_9110.Body.Coder.Test.Rejecting())
        }
    }
}

// MARK: - Integration

extension RFC_9110.Body.Coder.Test.Integration {
    @Test
    func `setting a body installs the bytes and the Content-Type together`() {
        var request = HTTP.Request(method: .post)
        request.body(set: RFC_9110.Body.Coder.Test.hello, using: RFC_9110.Body.Coder.Test.Passthrough())

        #expect(request.body == RFC_9110.Body.Coder.Test.hello)
        #expect(request.headers.first("Content-Type")?.rawValue == "text/plain")
    }

    @Test
    func `setting a body replaces any Content-Type already present`() {
        var request = HTTP.Request(method: .post)
        request.headers.append(
            HTTP.Header.Field(name: .contentType, value: HTTP.Header.Field.Value(unchecked: "application/json"))
        )

        request.body(set: RFC_9110.Body.Coder.Test.hello, using: RFC_9110.Body.Coder.Test.Passthrough())

        // One media type per message — the stale label must be gone, not
        // merely outnumbered.
        #expect(request.headers.values("Content-Type").count == 1)
        #expect(request.headers.first("Content-Type")?.rawValue == "text/plain")
    }

    @Test
    func `a body set through a codec decodes back through the same codec`() throws {
        let coder = RFC_9110.Body.Coder.Test.Passthrough()
        var request = HTTP.Request(method: .post)
        request.body(set: RFC_9110.Body.Coder.Test.hello, using: coder)

        #expect(try request.body(decode: [Byte].self, using: coder) == RFC_9110.Body.Coder.Test.hello)
    }

    @Test
    func `witness preserves the realized media type in both directions`() throws {
        let realized = HTTP.MediaType(
            "multipart",
            "form-data",
            parameters: ["boundary": "Queue20Boundary"]
        )
        let coder = RFC_9110.Body.Coder.Witness<
            RFC_9110.Body.Coder.Test.MultipartFormData,
            [Byte],
            Never
        >(
            parse: { input in
                defer { input = [] }
                return input
            },
            serialize: { output, buffer in
                buffer.append(contentsOf: output)
            },
            decode: { input, mediaType in
                #expect(mediaType.parameters["boundary"] == "Queue20Boundary")
                defer { input = [] }
                return input
            },
            encode: { output, buffer in
                buffer.append(contentsOf: output)
                return realized
            }
        )
        var request = HTTP.Request(method: .post)

        request.body(set: RFC_9110.Body.Coder.Test.hello, using: coder)

        #expect(
            request.headers.first("Content-Type")?.rawValue
                == "multipart/form-data; boundary=Queue20Boundary"
        )
        #expect(
            try request.body(decode: [Byte].self, using: coder)
                == RFC_9110.Body.Coder.Test.hello
        )
    }
}
