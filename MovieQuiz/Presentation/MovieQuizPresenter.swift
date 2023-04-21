//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Артём Костянко on 19.04.23.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var viewController: MovieQuizViewControllerProtocol?
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticService!
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
        viewController.hideLoadingIndicator()
    }
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromService() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoad(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNewQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonlicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
       didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer == true {
            correctAnswers += 1
        }
    }
    
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            let bestGame = statisticService.bestGame
            let text =
            "Ваш результат: \(correctAnswers)/10\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(bestGame.correct)/10 (\(bestGame.date.dateTimeString))\nCредняя точность: \(String(format: "%.2f%%", statisticService!.totalAccuracy * 100))"
            
            viewController?.show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!", text: text, buttonText: "Сыграть ещё раз!"))
        }
        else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
         }
     }
    func reloadData() {
        questionFactory?.loadData()
    }
}
