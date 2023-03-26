import UIKit

public struct AlertModel {
    let title: String
    let message: String
    let firstButtonText: String
    let secondButtonText: String?
    let firstCompletion: ((UIAlertAction) -> Void)?
    let secondCompletion: ((UIAlertAction) -> Void)?
}
