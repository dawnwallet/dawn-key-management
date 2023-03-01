import Foundation

struct Platform {

    static var isRealDevice: Bool {
        return TARGET_OS_SIMULATOR == 0
    }
}
