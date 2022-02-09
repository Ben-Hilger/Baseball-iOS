//
//  PitchThrown.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 7/26/21.
//

import Foundation

struct PitchThrown: Hashable, Equatable {

    var pitchID: String
    var shortName: String
    var longName: String
    var numberRep: String? = nil
    
    static func == (lhs: PitchThrown, rhs: PitchThrown) -> Bool {
        return lhs.pitchID == rhs.pitchID
    }
    
    func package(includeID: Bool = false) -> [String: Any] {
        var package: [String: Any] = [:]
        package["pitch_id"] = pitchID
        package["short_name"] = shortName
        package["long_name"] = longName
        package["number_rep"] = numberRep
        return package
    }
    
    static func loadFromDictionary(dict: [String: Any], id: String) -> PitchThrown? {
        if let shortName = dict["short_name"] as? String,
           let longName = dict["long_name"] as? String {
            return PitchThrown(pitchID: id,
                           shortName: shortName, longName: longName,
                           numberRep: dict["number_rep"] as? String)
        }
        return nil
    }
}
