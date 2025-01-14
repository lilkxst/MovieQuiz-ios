//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Артём Костянко on 22.03.23.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
}

extension GameRecord: Comparable {
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
    static func <= (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct <= rhs.correct
    }
}
