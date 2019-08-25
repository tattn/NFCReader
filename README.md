<h1 align="center">NFCReader</h1>

<h5 align="center">Scan and decode NFC tags on iOS</h5>

<div align="center">
  <a href="https://app.bitrise.io/app/31a1944381e3f58b">
    <img src="https://app.bitrise.io/app/31a1944381e3f58b/status.svg?token=ZpaTRx-41YV9CJBb4lQgGQ" alt="Build Status" />
  </a>
  <img src="https://img.shields.io/badge/platform-iOS-yellow.svg" alt="Platform" />
  <a href="https://developer.apple.com/swift">
    <img src="https://img.shields.io/badge/Swift-5.1+-F16D39.svg" alt="Swift Version" />
  </a>
  <a href="./LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-green.svg?style=flat-square" alt="license:MIT" />
  </a>
</div>

<br />

## Features

- [x] Scan NFC Tag (see below about supported tags)
- [x] Scan custom NFC tags

### Supported Tags

- IC cards for transit in Japan
  - Suica, Pasmo, Kitaca, ICOCA, TOICA、manaca、PiTaPa、nimoca、SUGOCA、はやかけん
- IC cards for shopping in Japan
  - nanaco
  - Edy
  - WAON

# Requirements

- Xcode 11.x
- Swift 5.1+
- iOS 13.0+

# Installation

You can install this framework with Swift Package Manager in Xcode 11.

# Usage

## Read histories

```swift
import NFCReader

let reader = Reader<Suica>() // `Nanaco`, `Edy` or `Waon`
reader.read(didBecomeActive: { _ in
	print("didBecomeActive")
}, didDetect: { reader, result in
	switch result {
	case .success(let suica):
		let balance = suica.boardingHistory.first?.balance ?? 0
		reader.setMessage("Your balance is ¥\(balance) .")
	case .failure(let error):
		reader.setMessage("something wrong")
	}
})
```

You can see more details at  `Sources/NFCReader/Tags`:

### Scan multiple tags 

```swift
private let reader = Reader<FeliCa>
self.reader.read(didDetect: { reader, result in
    switch result {
    case .success(let tag):
        let balance: UInt
        switch tag {
        case .edy(let edy):
            print(edy)
        case .nanaco(let nanaco):
            print(nanaco)
        case .waon(let waon):
            print(waon)
        case .suica(let suica):
            print(suica)
        }
    case .failure(let error):
        print(error)
    }
})
```

The reader can also read just specific tags. Please see `Sources/NFCReader/Tags/FeliCa/FeliCa.swift`.

### Scan repeatedly

```swift
reader.read(didDetect: { reader, result in
	switch result {
	case .success(let suica):
		let balance = suica.boardingHistory.first?.balance ?? 0
		reader.setMessage("Your balance is ¥\(balance) .")
		reader.restartReading() // continue to scan
	case .failure(let error):
		reader.setMessage("something wrong")
		reader.restartReading()
	}
})
```

### Custom message

```swift
var configuration = ReaderConfiguration()
configuration.message.alert = "Hold your iPhone near the Suica."

let reader = Reader<Suica>(configuration: configuration)
```

### Read custom tag

Please see `./Sources/NFCReader/Tags/FeliCa/nanaco/Nanaco.swift`.

# ToDo
- [ ] Decode entrance and exit histories of Suica. (service code: 108F)
- [ ] Decode SF entrance histories of Suica. (service code: 10CB)
- [ ] Support more NFC tags.

# Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## Support this project

Donating to help me continue working on this project.

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/tattn/)

# License

Suica is released under the MIT license. See LICENSE for details.

# Author
Tatsuya Tanaka

<a href="https://twitter.com/tanakasan2525" target="_blank"><img alt="Twitter" src="https://img.shields.io/twitter/follow/tanakasan2525.svg?style=social&label=Follow"></a>
<a href="https://github.com/tattn" target="_blank"><img alt="GitHub" src="https://img.shields.io/github/followers/tattn.svg?style=social"></a>

