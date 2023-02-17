# KeyManagement

Accounts for managing Seeds and Private Keys & Keychain for generating Secure Enclave Keys

### Wallet
Crypto methods (Generate Public Key, Generate Extended Keys, Signature)
### Keychain
Secure Enclave encryption & decryption, Keychain Storage
### Model
Ethereum Classes and Constants

## Private Key Wallet Examples
### Encryption
```Swift
  let eoaWallet = EthereumWallet(privateKey: EthereumPrivateKey(rawBytes: []))
  eoaWallet.encryptWallet()
```
### Signature
```Swift
  let account = EthereumAccount(address: EthereumAddress(hex: ""))
  account.signDigest([])
```

## HD Wallet Examples
### Encryption
```Swift
  let hdwallet = HDEthereumWallet() || let hdwallet = HDEthereumWallet(mnemonic: "") || let hdwallet = HDEthereumWallet(seed: [])
  hdwallet.encryptSeedPhrase()
```
