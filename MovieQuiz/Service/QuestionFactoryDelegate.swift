//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Артём Костянко on 15.03.23.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNewQuestion(question: QuizQuestion?)
    func didLoadDataFromService()
    func didFailToLoad(with error: Error)
}
