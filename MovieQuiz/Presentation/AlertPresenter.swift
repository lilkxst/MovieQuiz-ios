//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Артём Костянко on 15.03.23.
//

import Foundation
import UIKit

class AlertPresenter {
    let alertModel: AlertModel
    
    init(title: String, message: String, buttonText: String, completion: @escaping () -> Void) {
        self.alertModel = AlertModel (title: title, message: message, buttonText: buttonText, completion: completion)
    }
    func showAlert(viewController: UIViewController) {
            let alert = UIAlertController(
                title: self.alertModel.title,
                message: self.alertModel.message,
                preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Game results"
            
            let action = UIAlertAction(title: self.alertModel.buttonText, style: .default) { _ in
                self.alertModel.completion()
            }
            alert.addAction(action)
            
        viewController.present(alert, animated: true, completion: nil)
        }
}

