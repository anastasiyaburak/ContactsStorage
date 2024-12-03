import Foundation

extension String {
    func checkEmailRegularExpression() -> Bool {
        let stringTest = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,32}")
        return stringTest.evaluate(with: self)
    }

}
