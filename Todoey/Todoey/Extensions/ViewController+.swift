import UIKit
import ChameleonFramework

extension UIViewController {
    
    func setupBarButton(selector: Selector?) {
        let randomButton = UIBarButtonItem(systemItem: .add)
        randomButton.target = self
        randomButton.action = selector
        self.navigationItem.rightBarButtonItem = randomButton
    }
    
    func setupColor(color: UIColor) {
        navigationController?.navigationBar.backgroundColor = color
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(color, returnFlat: true)]
        navigationController?.navigationBar.tintColor = ContrastColorOf(color, returnFlat: true)
        view.backgroundColor = color
    }
}


