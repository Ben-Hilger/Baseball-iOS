//
//  LineupMembeer.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 7/26/21.
//

import Foundation

struct LineupPerson: Equatable, Hashable {
        
    var lineupID: String? = nil
    var numberInLineup: Int
    var position: Position
    
    var dh: RosterMember?
    var person: RosterMember

    func package() -> [String: Any] {
        var package: [String: Any] = [:]
        package["number_in_lineup"] = numberInLineup
        package["position"] = position.package(includeID:true)
        package["person_uid"] = self.person.personID
        package["person"] = self.person.package()
        if let dh = dh {
            package["dh_person_uid"] = dh.personID
            package["dh_person"] = dh.package()
        }
        
        return package
     }
    
    mutating func setID(id: String) {
        self.lineupID = id
    }
    
    static func loadFromDictionary(dict: [String: Any], id: String) -> LineupPerson? {
        if let numberInLineup = dict["number_in_lineup"] as? Int,
           let positionName = dict["position"] as? [String: Any],
           let positionID = positionName["position_id"] as? String,
           let position = Position.loadFromDictionary(dict: positionName, id: positionID),
           let personUID = dict["person_uid"] as? String,
           let personData = dict["person"] as? [String: Any],
           let member = RosterMember.loadFromDictionary(dict: personData, id: personUID) {
            var lineup = LineupPerson(lineupID: id,
                                numberInLineup: numberInLineup,
                                position: position,
                                dh: nil,
                                person: member)
            if let dhUID = dict["dh_person_uid"] as? String,
               let dhInfo = dict["dh_person"] as? [String: Any],
               let dh = RosterMember.loadFromDictionary(dict: dhInfo, id: dhUID) {
                lineup.dh = dh
            }
            return lineup
        }
        return nil
    }
    
    static func == (lhs: LineupPerson, rhs: LineupPerson) -> Bool {
        return lhs.person.personID == rhs.person.personID
    }
}

struct Person: Equatable {
    var person_id: String
    var first_name: String
    var height: Int
    var high_school: String
    var hometown_city: String
    var hometown_state: String
    var last_name: String
    var nickname: String
    var pitching_hand: String
    var hitting_hand: String
    var weight: Int
    
    func getFullName() -> String {
        return first_name + " " + last_name
    }
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.person_id == rhs.person_id
    }
}
