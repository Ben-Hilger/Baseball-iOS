//
//  Game.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/6/21.
//

import Foundation
import Firebase

struct Game: Hashable, Equatable {

    var gameID: String
    var gameDate: Date
    var gameStartHour: Int
    var gameStartMinute: Int
    var seasonID: String
    var seasonName: String
    var seasonYear: Int
    var homeTeamID: String
    var awayTeamID: String
    var homeTeamName: String
    var awayTeamName: String
    var homeTeamLineupID: String
    var awayTeamLineupID: String
    var gameState: Int
    var gameLocation: String? = nil
    
    func package() -> [String: Any] {
        var package: [String: Any] = [:]
        package["game_date"] = gameDate
        package["game_start_hour"] = gameStartHour
        package["game_start_minute"] = gameStartMinute
        package["season_id"] = seasonID
        package["season_name"] = seasonName
        package["season_year"] = seasonYear
        package["home_team_id"] = homeTeamID
        package["away_team_id"] = awayTeamID
        package["home_team_name"] = homeTeamName
        package["away_team_name"] = awayTeamName
        package["home_lineup_id"] = homeTeamLineupID
        package["away_lineup_id"] = awayTeamLineupID
        package["game_state"] = gameState
        package["game_location"] = gameLocation
        return package
    }
    
    static func loadFromDictionary(dict: [String: Any], id: String) -> Game? {
        if let gameDate = dict["game_date"] as? Timestamp,
           let gameStartHour = dict["game_start_hour"] as? Int,
           let gameStartMinute = dict["game_start_minute"] as? Int,
           let seasonID = dict["season_id"] as? String,
           let seasonName = dict["season_name"] as? String,
           let seasonYear = dict["season_year"] as? Int,
           let homeTeamID = dict["home_team_id"] as? String,
           let awayTeamID = dict["away_team_id"] as? String,
           let homeTeamName = dict["home_team_name"] as? String,
           let awayTeamName = dict["away_team_name"] as? String,
           let homeTeamLineupID = dict["home_lineup_id"] as? String,
           let awayTeamLineupID = dict["away_lineup_id"] as? String {
            return Game(gameID: id,
                        gameDate: gameDate.dateValue(),
                        gameStartHour: gameStartHour,
                        gameStartMinute: gameStartMinute,
                        seasonID: seasonID,
                        seasonName: seasonName,
                        seasonYear: seasonYear,
                        homeTeamID: homeTeamID,
                        awayTeamID: awayTeamID,
                        homeTeamName: homeTeamName,
                        awayTeamName: awayTeamName,
                        homeTeamLineupID: homeTeamLineupID,
                        awayTeamLineupID: awayTeamLineupID,
                        gameState: 0)
        }
        return nil
    }
    
    static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.gameID == rhs.gameID
    }
    
}
