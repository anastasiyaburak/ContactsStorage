import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T? {
        guard let cell = dequeueReusableCell(withIdentifier: T.description(), for: indexPath) as? T else {
            assertionFailure("unable to dequeue cell with identifier \(T.description())")
            return nil
        }

        return cell
    }

    func register(cellClasses: UITableViewCell.Type...) {
        cellClasses.forEach({
            register($0.self, forCellReuseIdentifier: $0.description())
        })
    }
}
