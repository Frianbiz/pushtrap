import Foundation

class Tag: NSObject {
    var key: String = ""
    var value: String = ""
    
    override init() {
        super.init()
    }
    
    init(vKey: String, vValue: String) {
        super.init()
        self.key = vKey
        self.value = vValue
    }
}
