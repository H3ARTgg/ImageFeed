import Foundation
import UIKit

public protocol AlertPresenterDelegate: AnyObject {
    func didRecieveAlertController(alert: UIAlertController?)
}

public protocol AlertPresenterProtocol {
    var delegate: AlertPresenterDelegate? { get set }
    func showBasic(model: AlertModel)
    func showAdvanced(model: AlertModel)
}

struct AlertPresenter: AlertPresenterProtocol {
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func showBasic(model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.firstButtonText, style: .default, handler: model.firstCompletion)
        alert.addAction(action)
        delegate?.didRecieveAlertController(alert: alert)
    }
    
    func showAdvanced(model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let firstAction = UIAlertAction(title: model.firstButtonText, style: .default, handler: model.firstCompletion)
        let secondAction = UIAlertAction(title: model.secondButtonText, style: .default, handler: model.secondCompletion)
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        delegate?.didRecieveAlertController(alert: alert)
    }
}
