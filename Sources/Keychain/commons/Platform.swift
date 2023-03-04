import Foundation

struct Platform {

    static var isRealDevice: Bool {
        #if targetEnvironment(simulator)
            return false
        #else
            return true
        #endif
    }
}
