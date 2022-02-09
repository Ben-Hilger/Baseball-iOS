//
//  APIManager.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/6/21.
//

import Foundation

class APIManager {
        
//    private static let baseURL = "https://api.grandslamanalytics.com/api/v2"
//    
//    static func createGame(homeTeamID: String, awayTeamID: String,
//                    gameDate: Date, gameStartHour: Int,
//                    gameStartMinute: Int, seasonID: Int,
//                    gameLocation: String,
//                    completion: @escaping (Int, Int, Int) -> Void) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "YYYY-MM-DD"
//        let url = URL(string: baseURL +  "/game?" +
//                        "homeTeamID=" + homeTeamID +
//                        "&awayTeamID=" + awayTeamID +
//                        "&gameDate=" + dateFormatter.string(from: gameDate) +
//                        "&gameStartHour=" + String(gameStartHour) +
//                        "&gameStartMinute=" + String(gameStartMinute) +
//                        "&seasonID=" + String(seasonID) +
//                        "&gameLoc=" + gameLocation)!
//        processRequest(url: url, method: "POST") { response in
//            if let gameId = response["game_id"] as? Int,
//               let homeLineupID = response["home_lineup_id"] as? Int,
//               let awayLineupID = response["away_lineup_id"] as? Int {
//                completion(gameId, homeLineupID, awayLineupID)
//            } else {
//                completion(-1, -1, -1)
//            }
//        }
//    }
//    
//    static func updateGameInfo(gameID: Int, homeTeamID: String, awayTeamID: String,
//                               gameDate: Date, gameStartHour: Int,
//                               gameStartMinute: Int, seasonID: Int,
//                               gameLocation: String, homeLineupID: Int,
//                               awayLineupID: Int) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "YYYY-MM-DD"
//        let url = URL(string: baseURL + "/game?" +
//                        "gameDate=\(dateFormatter.string(from: gameDate))&" +
//                        "gameID=\(gameID)&" +
//                        "gameStartHour=\(gameStartHour)&" +
//                        "gameStartMinute=\(gameStartMinute)&" +
//                        "homeLineupID=\(homeLineupID)&" +
//                        "awayLineupID=\(awayLineupID)&" +
//                        "homeTeamID=\(homeTeamID)&" +
//                        "awayTeamID=\(awayTeamID)&" +
//                        "seasonID=\(seasonID)")!
//        processRequest(url: url, method: "PATCH") { _ in }
//    }
//    
//    static func createLineup(gameID: Int, teamID: String,
//                             completion: @escaping (Int) -> Void) {
//        let url = URL(string: baseURL + "/game/lineup?" +
//                        "gameID=\(gameID)&" +
//                        "teamID=\(teamID)")!
//        processRequest(url: url, method: "POST") { response in
//            if let lineupID = response["lineup_id"] as? Int {
//                completion(lineupID)
//            } else {
//                completion(-1)
//            }
//        }
//    }
//    
//    static func updateLineup(lineupID: Int, gameID: Int, teamID: String,
//                             newLineup: [LineupMember]) {
//        let url = URL(string: baseURL + "/game/lineup?" +
//                        "lineupID=\(lineupID)&" +
//                        "gameID=\(gameID)&" +
//                        "teamID=\(teamID)")!
//        processRequest(url: url, method: "DELETE") { _ in
//            for member in newLineup {
//                let url2 = URL(string: baseURL + "/game/lineup?" +
//                                "lineupID=\(lineupID)&" +
//                                "gameID=\(gameID)&" +
//                                "teamID=\(teamID)&" +
//                                "personID=\(member.person.personID)&" +
//                                "numInLineup=\(newLineup.firstIndex(of: member)!)&" +
//                                "positionID=\(member.position)" +
//                                (member.dh != nil ? "&dhPersonID=\(member.dh!.person.personID)" : ""))!
//                processRequest(url: url2, method: "PUT") { _ in }
//            }
//        }
//    }
//    
//    static func createGameInning(gameID: Int,
//                          halfInning: Int,
//                          completion: @escaping (Int) -> Void) {
//        let url = URL(string: baseURL + "/game/inning?" +
//                        "gameID=" + String(gameID) +
//                        "&halfInning=" + String(halfInning))!
//        processRequest(url: url, method: "POST") { response in
//            if let inning_id = response["inning_id"] as? Int {
//                completion(inning_id)
//            } else {
//                completion(-1)
//            }
//        }
//    }
//    
//    static func updateGameInning(gameID: Int,
//                          inningID: Int,
//                          halfInning: Int,
//                          homeTotalEarned: Int,
//                          homeTotalUnearned: Int,
//                          awayTotalEarned: Int,
//                          awayTotalUnearned: Int,
//                          completion: @escaping (Bool) -> Void) {
//        let url = URL(string: baseURL + "/game/inning?" +
//                        "gameID=" + String(gameID) +
//                        "&inningID=" + String(inningID) +
//                        "&halfInning=" + String(halfInning) +
//                        "&homeTotalEarned=" + String(homeTotalEarned) +
//                        "&homeTotalUnearned=" + String(homeTotalUnearned) +
//                        "&awayTotalEarned=" + String(awayTotalEarned) +
//                        "&awayTotalUnearned=" + String(awayTotalUnearned))!
//        processRequest(url: url, method: "PATCH") { response in
//            completion(true)
//        }
//    }
//    
//    static func getTeamRoster(teamID: String,
//                       seasonID: Int,
//                       completion: @escaping ([LineupMember]) -> Void) {
//        let url = URL(string: baseURL + "/team/roster?" +
//                        "teamID=" + teamID +
//                        "&seasonID=" + String(seasonID))!
//        print("Getting team roster with URL: \(url.absoluteString)")
//        processRequest(url: url, method: "GET") { response in
//            print("Got team roster response: \(response)")
//            var members: [LineupMember] = []
//            if let data = response["data"] as? [[String: Any]] {
//                print("Converted to data properly")
//                // Load in all of the people from the response
//                for person in data {
//                    // Get the required information
//                    if let rosterMember = RosterMember.loadFromDictionary(dict: person) {
//                        // Add to the member list
//                        members.append(LineupMember(person: rosterMember, position: .Bench))
//                    }
//                }
//            }
//            // Return the list
//            completion(members)
//        }
//    }
//    
//    static func getTeamGames(teamID: String, completion: @escaping (([Game]) -> Void)) {
//        let url = URL(string: baseURL + "/team/games?" +
//            "teamID=" + teamID)!
//        processRequest(url: url, method: "GET") { response in
//            if let data = response["data"] as? [[String: Any]] {
//                var games: [Game] = []
//                for val in data {
//                    if let game = Game.loadFromDictionary(dict: val) {
//                        games.append(game)
//                    }
//                }
//                completion(games)
//            }
//        }
//    }
//    
//    static func getPitches(completion: @escaping (([PitchThrown]) -> Void)) {
//        let url = URL(string: baseURL + "/pitches")!
//        processRequest(url: url, method: "GET") { response in
//            var pitches: [PitchThrown] = []
//            if let data = response["data"] as? [[String: Any]] {
//                for val in data {
//                    if let pitch = PitchThrown.loadFromDictionary(dict: val) {
//                        pitches.append(pitch)
//                    }
//                }
//            }
//            completion(pitches)
//        }
//    }
//    
//    static func getPitchOutcomes(completion: @escaping (([PitchOutcome]) -> Void)) {
//        let url = URL(string: baseURL + "/outcomes")!
//        processRequest(url: url, method: "GET") { response in
//            var outcomes: [PitchOutcome] = []
//            if let data = response["data"] as? [[String: Any]] {
//                for val in data {
//                    if let outcome = PitchOutcome.loadFromDictionary(dict: val) {
//                        outcomes.append(outcome)
//                    }
//                }
//            }
//            completion(outcomes)
//        }
//    }
//
//    static func getPitchOutcomeSection1(outcomeID: Int, completion: @escaping (([PitchOutcomeSpecific]) -> Void)) {
//        let url = URL(string: baseURL + "/outcomes/section1?"
//                    + "outcomeID=\(outcomeID)")!
//        processRequest(url: url, method: "GET") { response in
//            var specificInfo: [PitchOutcomeSpecific] = []
//            if let data = response["data"] as? [[String: Any]] {
//                for val in data {
//                    if let outcome = PitchOutcomeSpecific.loadFromDictionary(dict: val) {
//                        specificInfo.append(outcome)
//                    }
//                }
//            }
//            completion(specificInfo)
//        }
//    }
//    
//    static func getPitchOutcomeSection2(outcomeID: Int, completion: @escaping (([PitchOutcomeSpecific]) -> Void)) {
//        let url = URL(string: baseURL + "/outcomes/section2?"
//                    + "outcomeID=\(outcomeID)")!
//        processRequest(url: url, method: "GET") { response in
//            var specificInfo: [PitchOutcomeSpecific] = []
//            if let data = response["data"] as? [[String: Any]] {
//                for val in data {
//                    if let outcome = PitchOutcomeSpecific.loadFromDictionary(dict: val) {
//                        specificInfo.append(outcome)
//                    }
//                }
//            }
//            completion(specificInfo)
//        }
//    }
//    
//    private static func processRequest(url: URL, method: String, completion: @escaping ([String: Any]) -> Void) {
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data,
//                  let response = response as? HTTPURLResponse,
//                  error == nil else {
//                print("error", error ?? "Unknown error")
//                completion([:])
//                return
//            }
//            guard (200 ... 299) ~= response.statusCode else {
//                print("statusCode should be 2xx, but is \(response.statusCode)")
//                print("response = \(response)")
//                completion([:])
//                return
//            }
//            
//            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
//            if let responseJSON = responseJSON as? [String: Any] {
//                completion(responseJSON)
//            } else {
//                completion([:])
//            }
//        }.resume()
//    }
}
