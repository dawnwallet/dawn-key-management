# KeyManagement

Dawn Key management provides news sort of APIs that allows you to manage, create and update wallets and sign transactions in ETH. This package leverages the Secure Enclave to keep your keys protected.

## Installation

### Swift Package Manager

To integrate this package into your Xcode project using Swift Package Manager, add it to the dependencies valye of your Package.swift: 

```
dependencies: [
    .package(url: "https://github.com/dawnwallet/dawn-key-management", branch: "main")
]
```

## Usage

### EOA Wallet
An EOA is represented by `EthereumWallet` object. 

#### Representation
```Swift
  let privateKey = EthereumPrivateKey(rawBytes: [])
  let eoaWallet = EthereumWallet(privateKey: privateKey)
```

#### Encryption
`EthereumWallet` encrypts the wallet using the following method. It not error is thrown, it returns the wallet back.
```Swift
  eoaWallet.encryptWallet()
```

### Account
An Account is represented by an `EthereumAccount` object. You are required to inject an `EthereumAddress` to have fully access of its capabilities

```Swift
  let address = EthereumAddress(hex: "")
  let account = EthereumAccount(address: address)
```

#### Signature
  In case the wallet is been imported before, account has the capability to sign digests.
```Swift
  account.signDigest([])
```
#### Decryption
  Account has the capability to reveal its private key
```Swift
  account.revealPrivateKey()
```
### HD Wallet Examples
### Encryption
```Swift
  let hdwallet = HDEthereumWallet() || let hdwallet = HDEthereumWallet(mnemonic: "") || let hdwallet = HDEthereumWallet(seed: [])
  hdwallet.encryptSeedPhrase()
```

### License
