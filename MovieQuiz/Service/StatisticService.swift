//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Артём Костянко on 21.03.23.
//

import Foundation



final class StatisticServiceImplementation: StatisticService {
    func store(correct count: Int, total amount: Int) {
        let savedGame = bestGame
        let simpleGame = GameRecord(correct: savedGame.correct, total: savedGame.total, date: Date())
        var recordGame = GameRecord(correct: count, total: amount, date: Date())
        let oldCount = self.gamesCount
        if recordGame.correct <= simpleGame.correct {
            let newGamesCount = self.gamesCount+1
            let newTotalAccuracy = (Double(oldCount*amount)*self.totalAccuracy+Double(count))/Double(amount*(oldCount+1))

            userDefaults.set(newGamesCount, forKey: Keys.gamesCount.rawValue)
            userDefaults.set(newTotalAccuracy, forKey: Keys.totalAccuracy.rawValue)
        } else {
            let newGamesCount = self.gamesCount+1
            let newTotalAccuracy = (Double(oldCount*amount)*self.totalAccuracy+Double(count))/Double(amount*(oldCount+1))
            recordGame = GameRecord(correct: count, total: amount, date: Date())
            
            userDefaults.set(newGamesCount, forKey: Keys.gamesCount.rawValue)
            userDefaults.set(newTotalAccuracy, forKey: Keys.totalAccuracy.rawValue)
            userDefaults.set(try? JSONEncoder().encode(recordGame), forKey: Keys.bestGame.rawValue)
            
        }
    }
    
    
    private enum Keys: String, CodingKey {
        case correct, total, bestGame, gamesCount, totalAccuracy
    }
    
    private let userDefaults = UserDefaults.standard
    
    var totalAccuracy: Double {
        get {
            let data = userDefaults.double(forKey: Keys.totalAccuracy.rawValue)
            return data
        }
    }
    
    var gamesCount: Int {
        get {
            let data = userDefaults.integer(forKey: Keys.gamesCount.rawValue)
            return data
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
            
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
}
