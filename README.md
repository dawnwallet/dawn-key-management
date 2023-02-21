# KeyManagement

Dawn Key Management provides a new sort of APIs that allows you to manage, create, encrypt wallets and sign transactions in ETH. This package leverages the Secure Enclave to keep your keys protected.

## Installation

### Swift Package Manager

To integrate this package into your Xcode project using Swift Package Manager, add it to the dependencies value of your Package.swift: 

```Swift
dependencies: [
    .package(url: "https://github.com/dawnwallet/dawn-key-management", branch: "main")
]
```

## Usage

### Wallet
`EthereumWallet` object is used to describe a standard wallet. 

#### Representation
Create a new instance by injecting the `EthereumPrivateKey`.
```Swift
  let privateKey = EthereumPrivateKey(rawBytes: [])
  let standardWallet = EthereumWallet(privateKey: privateKey)
```

#### Encryption
The following method encrypts the wallet using a secret generated in the secure enclave, the resolved ciphertext is stored in the Keychain. It returns the wallet in case no error is thrown.
```Swift
  standardWallet.encryptWallet()
```

### Account
`EthereumAccount` object is used to perform crypto operations over the encrypted wallet. In order to have fully access of its capabilities, the address injected should have been encrypted before.

#### Representation
Create a new instance by injecting the `EthereumAddress`.
```Swift
  let address = EthereumAddress(hex: "0x7851b240aCE79FA6961AE36c865802D1416611e7")
  let account = EthereumAccount(address: address)
```

#### Signature
  It resolves a signature given the digest. You may only sign digests if the address injected has been encrypted before. If not, an `notImported` error will be thrown.
```Swift
  account.signDigest([])
```
#### Decryption
  It decrypts the privateKey, and returns the closure containing its reference.
```Swift
  account.accessPrivateKey { privateKey in }
```
### HD Wallet
`HDEthereumWallet` object is used to describe a Hierarchical deterministic Wallet. 

#### Representation
#### From mnemonic
Return the HD Wallet with the given mnemonic string.
```Swift
  let hdWallet = HDEthereumWallet(mnemonicString: "test test test")
```

#### Generate
Generate a new HD Wallet with the desired length.
```Swift
  let hdWallet = HDEthereumWallet(length: .word12)
```

#### Encryption
Encrypt the mnemonic, and return the Id used as reference.
```Swift
  let id = hdwallet.encryptSeedPhrase()
```

#### Derivation
It decrypts the seed phrase, generates an account at the indicated index, and returns the generated private key.
```Swift
  HDEthereumWallet.generateExternalPrivateKey(id: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F", index: UInt32(0)) { privateKey in }
```

#### Decryption
It decrypts the seed phrase, and returns the closure containing its reference.
```Swift
  HDEthereumWallet.accessSeedPhrase(id: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F") { seedPhrase in }
```

### License
GPLv3, inspired by the key manager written at Light by Isaac Rodriguez.
