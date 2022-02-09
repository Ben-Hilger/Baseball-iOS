//
//  RosterMember.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/6/21.
//



struct RosterMember: Equatable, Hashable {
    var personID: String
    var firstName: String
    var lastName: String
    var bio: String
    var height: Int
    var homeTown: String
    var roleNameShort: String
    var roleNameLong: String
    var throwingHand: Hand
    var hittingHand: Hand
    var number: Int
    
    var pitches: [PitchThrown]?
    
    func package() -> [String: Any] {
        var package: [String: Any] = [:]
        package["first_name"] = firstName
        package["last_name"] = lastName
        package["bio"] = bio
        package["height"] = height
        package["home_town"] = homeTown
        package["role_name_short"] = roleNameShort
        package["role_name_long"] = roleNameLong
        package["throwing_hand_id"] = throwingHand.rawValue
        package["hitting_hand_id"] = hittingHand.rawValue
        package["number"] = number
        if let pitches = pitches {
            var pitchData: [String: Any] = [:]
            for pitch in pitches {
                pitchData[pitch.pitchID] = pitch.package(includeID:true)
            }
            if pitchData.keys.count > 0 {
                package["pitches"] = pitchData
            }
        }
        
        return package
    }
    
    static func loadFromDictionary(dict: [String: Any], id: String) -> RosterMember? {
        if let firstName = dict["first_name"] as? String,
           let lastName = dict["last_name"] as? String,
           //let bio = dict["bio"] as? String,
           //let height = dict["height"] as? Int,
           let homeTown = dict["home_town"] as? String,
           let roleNameShort = dict["role_name_short"] as? String,
           let roleNameLong = dict["role_name_long"] as? String,
           let number = dict["number"] as? Int {
            var pitches: [PitchThrown] = []
            if let pitchesData = dict["pitches"] as? [String: Any] {
                for pitchD in pitchesData.keys {
                    if let data = pitchesData[pitchD] as? [String: Any] {
                        if let pitch = PitchThrown.loadFromDictionary(dict: data, id: pitchD) {
                            pitches.append(pitch)
                        }
                    }
                }
            }
            return RosterMember(
                personID: id,
                firstName: firstName,
                lastName: lastName,
                bio: "",
                height: 0,
                homeTown: homeTown,
                roleNameShort: roleNameShort,
                roleNameLong: roleNameLong,
                throwingHand: Hand(rawValue: dict["throwing_hand_id"] as? Int ?? 2) ?? .Right,
                hittingHand: Hand(rawValue: dict["hitting_hand_id"] as? Int ?? 2) ?? .Right,
                number: number,
                pitches: pitches.count == 0 ? nil : pitches)
        }
        return nil
    }
    
    static func == (lhs: RosterMember, rhs: RosterMember) -> Bool {
        return lhs.personID == rhs.personID
    }
    
    func getFullName() -> String {
        return firstName + " " + lastName
    }
}
