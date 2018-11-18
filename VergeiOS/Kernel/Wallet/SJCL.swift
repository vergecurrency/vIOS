import JavaScriptCore

public class SJCL {
    let encrypt: JSValue?
    let decrypt: JSValue?
    let base64ToBits: JSValue?
    let sha256Hash: JSValue?
    let hexFromBits: JSValue?

    public init() {
        let jsPath = Bundle.main.path(forResource: "sjcl", ofType: "js")!
        let text = try! String(contentsOfFile: jsPath)

        let js = JSContext()
        js?.evaluateScript(text)

        js?.evaluateScript("var encrypt = function(password, plaintext, params) { return sjcl.encrypt(password, plaintext, params); }")
        js?.evaluateScript("var decrypt = function(password, ciphertext, params) { return sjcl.decrypt(password, ciphertext, params); }")
        js?.evaluateScript("var base64ToBits = function(encryptingKey) { return sjcl.codec.base64.toBits(encryptingKey); }")
        js?.evaluateScript("var sha256Hash = function(data) { return sjcl.hash.sha256.hash(data); }")
        js?.evaluateScript("var hexFromBits = function(hash) { return sjcl.codec.hex.fromBits(hash); }")

        encrypt = js?.objectForKeyedSubscript("encrypt")
        decrypt = js?.objectForKeyedSubscript("decrypt")
        base64ToBits = js?.objectForKeyedSubscript("base64ToBits")
        sha256Hash = js?.objectForKeyedSubscript("sha256Hash")
        hexFromBits = js?.objectForKeyedSubscript("hexFromBits")
    }

    public func encrypt(password: Array<Any>, plaintext: String, params: Any) -> String {
        return self.encrypt?.call(withArguments: [password, plaintext, params]).toString() ?? ""
    }

    public func decrypt(password: Array<Any>, ciphertext: String, params: Any) -> String {
        return self.decrypt?.call(withArguments: [password, ciphertext, params]).toString() ?? ""
    }

    public func base64ToBits(encryptingKey: String) -> [Int] {
        return self.base64ToBits?.call(withArguments: [encryptingKey])?.toArray() as! [Int]
    }

    public func sha256Hash(data: String) -> [Int] {
        return self.sha256Hash?.call(withArguments: [data]).toArray() as! [Int]
    }

    public func hexFromBits(hash: [Int]) -> String {
        return self.hexFromBits?.call(withArguments: [hash]).toString() ?? ""
    }
}
