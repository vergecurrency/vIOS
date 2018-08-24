<p align="center"><img src="http://staging.swenvanzanten.com/ios-icon.png" alt="Verge iOS Wallet"></p>
<p align="center">
  <a href="https://travis-ci.org/vergecurrency/vIOS" target="_blank"><img src="https://travis-ci.org/vergecurrency/vIOS.svg?branch=master"></a>
  <img src="https://img.shields.io/badge/status-development-red.svg">
  <img src="https://img.shields.io/badge/latest build-0.4-lightgrey.svg">
  <img src="https://img.shields.io/badge/iOS-^11.4-green.svg">
  <img src="https://img.shields.io/badge/license-MIT-blue.svg">
</p>

#  VERGE iOS Wallet

The iOS application will provide a solid and secure iOS wallet app on your personal iPhone, iPad or iPod Touch. Keeping **Tor** between all your outside http communications makes sure all of your transactions, wallet creations and price request remain private. Sending and receiving XVG in a secure and beautiful wallet application will actually change the way you use Verge Currency. 💪

## Features:

* Shows your XVG on your iOS device (iPhone, iPad and iPod Touch)
* Send XVG to other XVG wallets
* Receive XVG
* Store addresses of other recipients in the address book
* Keep track of your transactions
* See what you XVG is worth in your own fiat currency

## Local Development

So you want to help us out? Here's a guide on how to get started:

1. Fork the project, and clone it to your local machine.

2. Now install the following tools via [brew](https://brew.sh) 
```sh
brew install carthage automake autoconf libtool gettext
```

3. In your cloned project folder run carthage build (this could take awile):
```sh
carthage checkout && carthage build --platform iOS
```

4. After that is done, open the project and start coding.

## Build With

* [Swift](https://github.com/apple/swift) - Language used writing the application
* [Tor](https://www.torproject.org) - The intergration of Tor makes sure your transactions are private
* [iCepa/Tor.framework](https://github.com/iCepa/Tor.framework) - Provides a solid framework for using Tor
* [hackiftekhar/IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager) - Makes working with keyboards and inputs painless
* [aschuch/QRCode](https://github.com/aschuch/QRCode) - Generates beautiful QR codes for receiving XVG
* [SwiftyJSON/SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) - Helps working with JSON responses
* [evgenyneu/keychain-swift](https://github.com/evgenyneu/keychain-swift) - Takes away the worries of saving sensitive user data on your device

### Community

* [Telegram](https://t.me/VERGExvg)
* [Discord](https://discord.gg/vergecurrency)
* [Twitter](https://www.twitter.com/vergecurrency)
* [Facebook](https://www.facebook.com/VERGEcurrency/)
* [Reddit](https://www.reddit.com/r/vergecurrency/)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

* **Swen van Zanten** - *Main developer* - [SwenVanZanten](https://github.com/SwenVanZanten)
* **Marvin Piekarek** - *Main developer* - [marpme](https://github.com/marpme)
