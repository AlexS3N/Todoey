import UIKit

extension UIAlertController {
    func setupYesAlertAction(alertAction: UIAlertAction, textField: UITextField) {
        alertAction.isEnabled = false
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using: {_ in
            let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
            let textIsNotEmpty = textCount > 0
            alertAction.isEnabled = textIsNotEmpty
        })
    }
}
