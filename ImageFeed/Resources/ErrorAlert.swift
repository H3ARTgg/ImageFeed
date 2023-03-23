import UIKit

struct ErrorAlert {
    let viewController: UIViewController
    
    func show() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(okAction)
        viewController.present(alert, animated: true)
    }
}
