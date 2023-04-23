import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
    }
    
    // MARK: - Actions
       @IBAction private func yesButtonlicked(_ sender: Any) {
            presenter.yesButtonlicked()
            yesButton.isEnabled = false
            noButton.isEnabled = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.yesButton.isEnabled = true
                self.noButton.isEnabled = true
            }
        }
        
        @IBAction private func noButtonClicked(_ sender: Any) {
            presenter.noButtonClicked()
            yesButton.isEnabled = false
            noButton.isEnabled = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.yesButton.isEnabled = true
                self.noButton.isEnabled = true
        }
    }
    
    // MARK: - Private functions
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let action = {
            self.presenter.restartGame()
        }
        
        let alertPresenter: AlertPresenter = AlertPresenter(title: result.title, message: result.text, buttonText: result.buttonText, completion: action)
        alertPresenter.showAlert(viewController: self)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderWidth = 0
        }
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
    
        let model = AlertModel(title: "Что-то пошло не так(",
                               message: message,
                               buttonText: "Попробовать ещё раз") { [weak self] in guard let self = self else { return }
            self.presenter.restartGame()
            
            self.presenter.reloadData()
        }
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            self.showLoadingIndicator()
            self.presenter.reloadData()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
