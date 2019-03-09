<p align="center"><img src="https://raw.githubusercontent.com/vergecurrency/vIOS/master/readme-header.png" alt="Verge iOS Wallet"></p>
<p align="center">
  <a href="https://travis-ci.org/vergecurrency/vIOS" target="_blank"><img src="https://travis-ci.org/vergecurrency/vIOS.svg?branch=master"></a>
  <img src="https://img.shields.io/badge/status-beta-yellow.svg">
  <img src="https://img.shields.io/badge/latest build-0.17.1-lightgrey.svg">
  <img src="https://img.shields.io/badge/iOS-^11.4-green.svg">
  <img src="https://img.shields.io/badge/watchOS-^4.0-brightgreen.svg">
  <img src="https://img.shields.io/badge/license-MIT-blue.svg">
</p>

#  VERGE iOS Wallet

This iOS wallet provides an easy and secure wallet on your iOS device. With **Tor** integrated you can be sure your http communication is private. Sending and receiving XVG in a secure and easy to use wallet will actually change the way you use Verge Currency. 💪

## Features:

* Sending and receiving XVG
* Store addresses in an address book
* Tor integrated
* Price statistics in different fiat currencies
* Share your receive card
* Private keys are yours
* Possibility to choose your own wallet service
* Touch ID & Face ID support
* Apple Watch support
* Siri integrated

## Local Development

If you want to help us out on the development use this guide:

1. Fork the project, and clone it to your local machine.

2. Install the following tools via [brew](https://brew.sh) 
```sh
brew install carthage
```

3. In your cloned project folder run carthage update (this could take a while):
```sh
carthage update --platform iOS
```

4. Open the project:
```sh
open VergeiOS.xcodeproj
```

## Build With

* [Swift](https://github.com/apple/swift) - Language used writing the application
* [Tor](https://www.torproject.org) - The intergration of Tor makes sure your transactions are private
* [iCepa/Tor.framework](https://github.com/iCepa/Tor.framework) - Provides a solid framework for using Tor
* [hackiftekhar/IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager) - Makes working with keyboards and inputs painless
* [aschuch/QRCode](https://github.com/aschuch/QRCode) - Generates beautiful QR codes for receiving XVG
* [SwiftyJSON/SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) - Helps working with JSON responses
* [evgenyneu/keychain-swift](https://github.com/evgenyneu/keychain-swift) - Takes away the worries of saving sensitive user data on your device
* [HamzaGhazouani/HGPlaceholders](https://github.com/HamzaGhazouani/HGPlaceholders) - Library to show placeholders and Empty States for any UITableView
* [danielgindi/Charts](https://github.com/danielgindi/Charts) - This library is used for making beautiful charts
* [JohnEstropia/CoreStore](https://github.com/JohnEstropia/CoreStore) - Handy core data library
* [xmartlabs/Eureka](https://github.com/xmartlabs/Eureka) - Library for easily creating forms
* [yenom/BitcoinKit](https://github.com/yenom/BitcoinKit) - The BitcoinKit library is a Swift implementation of the Bitcoin protocol
* [krzyzanowskim/CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift) - Crypto related functions and helpers for Swift implemented in Swift.

### Community

* [Telegram](https://t.me/VERGExvg)
* [Discord](https://discord.gg/vergecurrency)
* [Twitter](https://www.twitter.com/vergecurrency)
* [Facebook](https://www.facebook.com/VERGEcurrency/)
* [Reddit](https://www.reddit.com/r/vergecurrency/)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.
