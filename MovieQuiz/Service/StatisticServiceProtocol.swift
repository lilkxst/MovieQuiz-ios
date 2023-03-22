//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Артём Костянко on 22.03.23.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    func store(correct count: Int, total amount: Int)
}
