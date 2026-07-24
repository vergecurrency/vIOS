<p align="center"><img src="https://raw.githubusercontent.com/vergecurrency/vIOS/master/readme-header.png" alt="Verge XVR iOS Wallet"></p>
<p align="center">
  <a href="https://github.com/vergecurrency/vIOS/actions"><img src="https://github.com/vergecurrency/vIOS/actions/workflows/default.yml/badge.svg" alt="iOS Build"></a>
  <a href="https://developer.apple.com/ios/" target="_blank"><img src="https://img.shields.io/badge/iOS-15.0%2B-green.svg" alt="iOS 15.0+"></a>
  <a href="https://developer.apple.com/watchos/" target="_blank"><img src="https://img.shields.io/badge/watchOS-6.0%2B-brightgreen.svg" alt="watchOS 6.0+"></a>
  <a href="https://github.com/vergecurrency/vIOS/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
</p>

# Verge XVR iOS Wallet

Verge XVR is the Verge Currency iOS wallet for sending, receiving, restoring, and managing XVG wallets on Apple devices.

Current app version: `26.8`

## Wallet Backends

Verge XVR supports two wallet backends:

- **VWS legacy wallets**: 12-word mnemonic restores with the legacy Verge Wallet Service backend. VWS is a Verge fork of Bitcore Wallet Service.
- **ElectrumX wallets**: new 18-word mnemonics and 18-word restores using Verge ElectrumX servers and the XVG derivation path registered as coin type `77`.

Default ElectrumX servers:

- `electrumx-verge.cloud`
- `electrum-verge.cloud`

VWS server settings and ElectrumX server settings are managed from the app settings menu.

## Features

- Create new 18-word ElectrumX XVG wallets.
- Restore legacy 12-word VWS wallets with passphrase support.
- Restore 18-word ElectrumX wallets without the legacy VWS passphrase.
- Multiple wallet profiles with wallet switching and wallet naming.
- Send and receive XVG.
- ElectrumX transaction history, balance sync, and transaction broadcasting.
- VWS transaction proposal signing and publishing for legacy wallets.
- Address book/contact support.
- Unstoppable Domains/Web3 name resolution for send recipients.
- QR, clipboard, and share flows for wallet addresses.
- Tor privacy routing for wallet network traffic when enabled.
- Live Tor bootstrap/status display.
- CoinGecko XVG price/chart data.
- Retrowave app theme.
- Touch ID and Face ID support.
- Apple Watch and Siri targets are still present in the project.

## Requirements

- macOS with Xcode installed.
- CocoaPods.
- iOS 15.0+ for the main app target.
- watchOS 6.0+ for the Watch target.

Install CocoaPods if needed:

```sh
sudo gem install cocoapods
```

Install project dependencies:

```sh
pod install
```

Open the workspace, not the project file:

```sh
open VergeiOS.xcworkspace
```

## Local Build

Build the app for the simulator:

```sh
xcodebuild \
  -workspace VergeiOS.xcworkspace \
  -scheme VergeiOS \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

The GitHub Actions workflow builds the simulator target without signing to verify that the app compiles on push and pull request.

## Signing And TestFlight

The repository build workflow does not sign the app. Device installs, archives, and TestFlight uploads require an Apple Developer account and a valid signing team in Xcode.

For TestFlight/App Store Connect:

- Bundle ID: `org.verge.wallets`
- App display name: `Verge XVR`
- Version/build: `26.8`

External TestFlight testers require Apple Beta App Review before invites become usable.

## Dependencies

This app uses CocoaPods and Swift Package Manager dependencies, including:

- [Tor](https://www.torproject.org) / Tor.framework for privacy routing.
- [vergecurrency/BitcoinKit](https://github.com/vergecurrency/BitcoinKit) for transaction and key handling.
- [GigaBitcoin/secp256k1.swift](https://github.com/GigaBitcoin/secp256k1.swift) for secp256k1 support.
- [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift) for cryptographic helpers.
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) for JSON handling.
- [KeychainSwift](https://github.com/evgenyneu/keychain-swift) for keychain storage.
- [Swinject](https://github.com/Swinject/Swinject) and SwinjectStoryboard for dependency injection.
- [CoreStore](https://github.com/JohnEstropia/CoreStore) for local data persistence.
- [Eureka](https://github.com/xmartlabs/Eureka) for form screens.
- [DGCharts](https://github.com/danielgindi/Charts) for chart rendering.
- [IQKeyboardManagerSwift](https://github.com/hackiftekhar/IQKeyboardManager) for keyboard handling.

## Community

- [Telegram](https://t.me/VERGExvg)
- [Discord](https://discord.gg/vergecurrency)
- [X/Twitter](https://www.twitter.com/vergecurrency)
- [Facebook](https://www.facebook.com/VERGEcurrency/)
- [Reddit](https://www.reddit.com/r/vergecurrency/)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for the project code of conduct and pull request process.
