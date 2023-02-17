# KeyManagement

Dawn Key Management provides a new sort of APIs that allows you to manage, create, update wallets and sign transactions in ETH. This package leverages the Secure Enclave to keep your keys protected.

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
An EOA is represented by an `EthereumWallet` object. You are required to inject an `EthereumPrivateKey`.

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
An Account is represented by an `EthereumAccount` object. You are required to inject an `EthereumAddress` to have fully access of its capabilities.

```Swift
  let address = EthereumAddress(hex: "")
  let account = EthereumAccount(address: address)
```

#### Signature
  In case the wallet has been imported, account object has the capability to sign digests.
```Swift
  account.signDigest([])
```
#### Decryption
  It reveals the private key by calling this method.
```Swift
  account.revealPrivateKey()
```
### HD Wallet
#### Encryption
```Swift
  let hdwallet = HDEthereumWallet() || let hdwallet = HDEthereumWallet(mnemonic: "") || let hdwallet = HDEthereumWallet(seed: [])
  hdwallet.encryptSeedPhrase()
```

### License
