//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Артём Костянко on 15.03.23.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> Void
}
