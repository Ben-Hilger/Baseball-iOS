//
//  FirebaseManager.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/14/21.
//

import Foundation
import Firebase

class FirebaseManager {
    
    private static let GAME_COL = "Game"
    private static let TEAM_COL = "Team"
    private static let LINEUP_COL = "Lineup"
    private static let PERSON_COL = "Person"
    private static let CONFIG_COL = "Config"
    
    private static let dB = Firestore.firestore()
    
    static func saveGame(game: Game) {
        var ref: DocumentReference! = nil
        ref = dB.collection(GAME_COL).document(game.gameID)
        ref.setData(game.package(), merge: true)
    }
    
    static func getGamesForTeam(teamID: String,
                                        completion: @escaping (([Game]) -> Void)) {
        dB.collection(GAME_COL)
            .whereField("home_team_id", isEqualTo: teamID)
            .whereField("away_team_id", isEqualTo: teamID)
                .getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    completion([])
                } else if let snapshot = snapshot {
                    var games: [Game] = []
                    let docs = snapshot.documents
                    for doc in docs {
                        if let game = Game.loadFromDictionary(dict: doc.data(),
                                                              id: doc.documentID) {
                            games.append(game)
                        }
                    }
                    completion(games)
                }
            }
    }
 
    static func loadGameLineup(gameUID: String,
                                        teamUID: String,
                                        lineupUID: String,
                                        completion: @escaping
                                            ([LineupPerson]) -> Void) {
        dB.collection(GAME_COL)
            .document(gameUID).collection(TEAM_COL)
            .document(teamUID).collection(LINEUP_COL)
            .document(lineupUID).collection(PERSON_COL)
            .order(by: "number_in_lineup", descending: false).getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    completion([])
                } else if let snapshot = snapshot {
                    var persons: [LineupPerson] = []
                    let docs = snapshot.documents
                    for doc in docs {
                        if let member = LineupPerson.loadFromDictionary(dict:
                                                doc.data(), id: doc.documentID) {
                            persons.append(member)
                        }
                    }
                    completion(persons)
                }
            }
    }
    
    static func clearLineup(gameUID: String,
                            teamUID: String,
                            line: String,
                            completion: @escaping () -> Void)  {
        dB.collection(GAME_COL).document(gameUID)
        dB.collection(GAME_COL).document(gameUID)
            .collection(TEAM_COL).document(teamUID).collection(LINEUP_COL)
            .document(line).collection(PERSON_COL)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    completion()
                } else if let snapshot = snapshot {
                    print("Deleting Lineup Document")
                    for doc in snapshot.documents {
                        dB.collection(GAME_COL).document(gameUID)
                            .collection(TEAM_COL).document(teamUID).collection(LINEUP_COL)
                            .document(line).collection(PERSON_COL).document(doc.documentID).delete()
                    }
                    completion()
                }
            }
    }
     
    static func saveLineup(gameUID: String,
                                   teamUID: String,
                                   line: String?,
                                   lineup: inout [LineupPerson]) -> String {
        var lineupId: String! = nil
        if let id = line {
            lineupId = id
        } else {
            lineupId = dB.collection(GAME_COL).document(gameUID)
                .collection(TEAM_COL).document(teamUID).collection(LINEUP_COL)
                .document().documentID
        }
        
        for index in 0..<lineup.count {
            saveLineupPerson(gameUID: gameUID, teamUID: teamUID,
                            lineupID: lineupId, member: &lineup[index])
        }
        return lineupId
    }
    
    static func saveLineupPerson(gameUID: String,
                                        teamUID: String,
                                        lineupID: String,
                                        member: inout LineupPerson) {
        var doc: DocumentReference! = nil
        if let id = member.lineupID {
            doc = dB.collection(GAME_COL).document(gameUID)
                .collection(TEAM_COL).document(teamUID).collection(LINEUP_COL)
                .document(lineupID).collection(PERSON_COL).document(id)
        } else {
            doc =  dB.collection(GAME_COL).document(gameUID)
                .collection(TEAM_COL).document(teamUID).collection(LINEUP_COL)
                .document(lineupID).collection(PERSON_COL).document()
            member.setID(id: doc.documentID)
        }
        print(member.numberInLineup)
        doc.setData(member.package(), merge: true)
    }
    
    static func getTeamRoster(teamID: String,
                       seasonID: String,
                       completion: @escaping ([RosterMember]) -> Void) {
        print("Getting roster for team \(teamID) in season \(seasonID)")
        dB.collection("Season").document(seasonID).collection(TEAM_COL)
            .document(teamID).collection("Roster").getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    completion([])
                } else if let snapshot = snapshot {
                    var persons: [RosterMember] = []
                    let docs = snapshot.documents
                    for doc in docs {
                        if let person = RosterMember.loadFromDictionary(dict: doc.data(),
                                                            id: doc.documentID) {
                            persons.append(person)
                        }
                    }
                    completion(persons)
                }
            }
    }
    
    
    static func getPitches(completion:
                                    @escaping (([PitchThrown]) -> Void)) {
        dB.collection("Config").document(GAME_COL).collection("Pitches")
            .order(by: "weight", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    completion([])
                } else if let snapshot = snapshot {
                    var pitches: [PitchThrown] = []
                    let docs = snapshot.documents
                    for doc in docs {
                        if let pitch =
                            PitchThrown.loadFromDictionary(dict: doc.data(),
                                                           id: doc.documentID) {
                            pitches.append(pitch)
                        }
                    }
                    completion(pitches)
                }
            }
    }
    
    static func getPositions(completion: @escaping (([Position]) -> Void)) {
        dB.collection("Config").document("System").collection("Position")
            .order(by: "position_num", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    completion([])
                } else if let snapshot = snapshot {
                    var positions: [Position] = []
                    let docs = snapshot.documents
                    for doc in docs {
                        if let position = Position.loadFromDictionary(dict: doc.data(),
                                                                      id: doc.documentID) {
                            positions.append(position)
                        }
                    }
                    completion(positions)
                }
            }
    }
    
    static func getPitchOutcomes(completion: @escaping (([PitchOutcome]) -> Void)) {
        dB.collection(CONFIG_COL).document(GAME_COL).collection("PitchOutcome")
            .order(by: "weight", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    completion([])
                } else if let snapshot = snapshot {
                    var outcomes: [PitchOutcome] = []
                    let docs = snapshot.documents
                    for doc in docs {
                        if let outcome =
                            PitchOutcome.loadFromDictionary(dict: doc.data(),
                                                            id: doc.documentID) {
                            outcomes.append(outcome)
                        }
                    }
                    completion(outcomes)
                }
            }
    }
    
    static func getPitchOutcomeSection1(outcomeID: String,
                                        completion:
                                            @escaping (([PitchOutcomeSpecific]) -> Void)) {
        dB.collection(CONFIG_COL).document(GAME_COL).collection("PitchExtraInfo")
            .document("Section1").collection(outcomeID)
            .order(by: "weight", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    completion([])
                } else if let snapshot = snapshot {
                    var specificInfo: [PitchOutcomeSpecific] = []
                    let docs = snapshot.documents
                    for doc in docs {
                        if let outcome =
                            PitchOutcomeSpecific.loadFromDictionary(
                                dict: doc.data(), id: doc.documentID) {
                            specificInfo.append(outcome)
                        }
                    }
                    completion(specificInfo)
                }
            }
    }

    static func getPitchOutcomeSection2(outcomeID: String,
                                          completion:
                                              @escaping (([PitchOutcomeSpecific]) -> Void)) {
          dB.collection(CONFIG_COL).document(GAME_COL).collection("PitchExtraInfo")
            .document("Section2").collection(outcomeID)
            .order(by: "weight", descending: false)
              .getDocuments { snapshot, error in
                  if let error = error {
                      print(error)
                      completion([])
                  } else if let snapshot = snapshot {
                      var specificInfo: [PitchOutcomeSpecific] = []
                      let docs = snapshot.documents
                      for doc in docs {
                          if let outcome =
                                PitchOutcomeSpecific.loadFromDictionary(dict: doc.data(),
                                                                        id: doc.documentID) {
                              specificInfo.append(outcome)
                          }
                      }
                      completion(specificInfo)
                  }
              }
    }
    
    static func savePAOrder(gameID: String, paOrder: [Int]) {
        dB.collection("Game")
            .document("\(gameID)")
            .collection("Data")
            .document("Order").setData(["pa_order": paOrder], merge: true)
    }
    
    static func loadPAOrder(gameID: String, completion: @escaping ([Int]) -> Void) {
        print("Loading the PA Order...")
        dB.collection("Game")
            .document("\(gameID)")
            .collection("Data")
            .document("Order").getDocument { snapshot, error in
                if let error = error {
                    print(error)
                    completion([])
                } else if let snapshot = snapshot {
                    let data = snapshot.data() ?? [:]
                    completion(data["pa_order"] as? [Int] ?? [])
                }
            }
    }
    
    static func savePlateAppearance(gameID: String,
                                    pa: PlateAppearance) {
        var data = pa.package()
        data["game_id"] = gameID
        dB.collection("Game")
            .document("\(gameID)")
            .collection("Data")
            .document("PA")
            .collection("Data")
            .document("\(pa.paNumber)").setData(data, merge: false)
    }
    
    static func loadPlateAppearanceInfo(gameID: String,
                                        completion: @escaping ([Int: PlateAppearance] ) -> Void) {
        print("Loading plate appearance information...")
        dB.collection("Game")
            .document("\(gameID)")
            .collection("Data")
            .document("PA")
            .collection("Data")
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    completion([:])
                } else if let snapshot = snapshot {
                    var compiledPA: [Int: PlateAppearance] = [:]
                    for doc in snapshot.documents {
                        let data = doc.data()
                        if let pa = PlateAppearance.initFromDictionary(dict: data) {
                            compiledPA.updateValue(pa, forKey: pa.paNumber)
                        }
                    }
                    completion(compiledPA)
                }
            }
        
    }
    
    static func saveGameEvent(gameID: String,
                              event: GameEventBase) {
        let data = event.package()
        dB.collection("Game")
            .document("\(gameID)")
            .collection("Data")
            .document("Event")
            .collection("GameData")
            .document("\(event.eventNum!)").setData(data, merge: false)
    }
    
    static func loadGameEvents(gameID: String, completion: @escaping ([Int: GameEventBase]) -> Void) {
        print("Loading game event information...")
        dB.collection("Game")
            .document("\(gameID)")
            .collection("Data")
            .document("Event")
            .collection("GameData")
            .order(by: "event_num")
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    completion([:])
                } else if let snapshot = snapshot {
                    var compiledEvents: [Int: GameEventBase] = [:]
                    for doc in snapshot.documents {
                        let data = doc.data()
                        if let event = GameEventBase.initFromDictionary(dict: data) {
                            print(event.eventNum)
                            compiledEvents.updateValue(event, forKey: event.eventNum)
                        }
                    }
                    completion(compiledEvents)
                }
            }
    }
  
    static func setGameState(gameID: String, snapshot: GameSnapshot) {
        dB.collection("Game").document(gameID).collection("State").document("Current")
            .setData(snapshot.package(), merge: false)
    }
    
    static func getCurrentGameState(gameID: String,
                                completion: @escaping ((GameSnapshot?) -> Void)) {
        dB.collection("Game").document(gameID).collection("State").document("Current")
            .getDocument { snapshot, error in
                if let error = error {
                    print(error)
                    completion(nil)
                } else if let snapshot = snapshot {
                    let data = snapshot.data() ?? [:]
                    completion(GameSnapshot.loadFromDictionary(dict: data))
                }
            }
    }
    
    static func setupUpdateStats(gameID: String,
                                 dataFunc: @escaping ([String: Any]) -> Void) {
        dB.collection("Game").document(gameID).collection("State")
            .document("Exchange").addSnapshotListener { snapshot, error in
                if let error = error {
                    print(error)
                } else if let snapshot = snapshot {
                    guard let data = snapshot.data() else {
                        dataFunc([:])
                        return
                    }
                    dataFunc(data)
                }
            }
    }
}
