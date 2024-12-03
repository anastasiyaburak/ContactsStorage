import Foundation
import Logging

final class DebugLogger {

    static let shared = DebugLogger()

    private lazy var logger: Logger = {
        var logger = Logger(label: Bundle.main.bundleIdentifier!)
        logger.logLevel = .debug
        return logger
    }()

    func debug(_ message: String) {
#if DEBUG
        logger.debug(Logger.Message(stringLiteral: message))
#endif
    }

    func warning(_ message: String) {
#if DEBUG
        logger.warning(Logger.Message(stringLiteral: message))
#endif
    }

    func error(_ message: String) {
#if DEBUG
        logger.error(Logger.Message(stringLiteral: message))
#endif
    }

    func critical(_ message: String) {
#if DEBUG
        logger.critical(Logger.Message(stringLiteral: message))
#endif
    }
}
