# swift-http-body

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

HTTP message body handling for Swift.

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-foundations/swift-http-body.git", branch: "main")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "HTTP Body", package: "swift-http-body")
    ]
)
```

JSON body coding lives in a separate product, so a target that never encodes
JSON does not link it:

```swift
.product(name: "HTTP Body JSON", package: "swift-http-body")
```

## Error Handling

Body coding failures surface as `HTTP.Body.Coder.Error`, declared by this
package. Coding entry points use typed throws, so the failure cases are visible
in the signature and callers can switch over them exhaustively.

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
