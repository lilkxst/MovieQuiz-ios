import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswer: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNewQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let action = {
            self.currentQuestionIndex = 0
            self.correctAnswer = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        let alertPresenter: AlertPresenter = AlertPresenter(title: result.title, message: result.text, buttonText: result.buttonText, completion: action)
        alertPresenter.showAlert(viewController: self)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderWidth = 0
        }
        
        if isCorrect == true {
            correctAnswer += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService!.store(correct: correctAnswer, total: questionsAmount)
            let text =
            "Ваш результат: \(correctAnswer)/10\nКоличество сыгранных квизов: \(statisticService!.gamesCount)\nРекорд: \(statisticService!.bestGame.correct)/10 (\(statisticService!.bestGame.date.dateTimeString))\nCредняя точность: \(String(format: "%.2f%%", statisticService!.totalAccuracy * 100))"
            
            self.show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!", text: text, buttonText: "Сыграть ещё раз!"))
        }
        else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
    
        let model = AlertModel(title: "Что-то пошло не так(",
                               message: message,
                               buttonText: "Попробовать ещё раз") { [weak self] in guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswer = 0
            
            self.questionFactory?.loadData()
        }
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func didLoadDataFromService() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
       
    func didFailToLoad(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
        @IBAction private func yesButtonlicked(_ sender: Any) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            var givenAnswer = true
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
            yesButton.isEnabled = false
            noButton.isEnabled = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.yesButton.isEnabled = true
                self.noButton.isEnabled = true
            }
        }
        
        @IBAction private func noButtonClicked(_ sender: Any) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            var givenAnswer = false
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer )
            yesButton.isEnabled = false
            noButton.isEnabled = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.yesButton.isEnabled = true
                self.noButton.isEnabled = true
        }
    }
}
