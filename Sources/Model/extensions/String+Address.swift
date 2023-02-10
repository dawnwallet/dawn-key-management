import Foundation
import CryptoSwift

extension String {

    var withPrefix: String {
        "0x\(self)"
    }

    var withoutPrefix: String {
        self.replacingOccurrences(of: "0x", with: "")
    }

    var toCheckSumString: String {
        let lowerCaseAddress = self.withoutPrefix.lowercased()
        let arr = Array(lowerCaseAddress)
        let keccaf = SHA3.keccak256(data: Array(lowerCaseAddress.utf8)).toHexString()
        let keccafArray = Array(keccaf)
        var result = ""
        for i in 0..<lowerCaseAddress.count {
            if let val = Int(String(keccafArray[i]), radix: 16), val >= 8 {
                result.append(arr[i].uppercased())
            } else {
                result.append(arr[i])
            }
        }
        return result.withPrefix
    }
}
