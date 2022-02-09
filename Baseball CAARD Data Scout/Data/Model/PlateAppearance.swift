//
//  PlateAppearance.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 10/2/21.
//

import Foundation

struct PlateAppearance {
    
    static var numPA: Int = 0
    
    var hittingHand: Hand
    var pitchingHand: Hand
    var paNumber: Int
    
    var events: [Int] = []
    
    func package() -> [String: Any] {
        var package: [String: Any] = [:]
        package["hitting_hand"] = hittingHand.rawValue
        package["pitching_hand"] = pitchingHand.rawValue
        package["pa_number"] = paNumber
        package["event_order"] = events
        return package
    }
    
    static func initFromDictionary(dict: [String: Any]) -> PlateAppearance? {
        if let num = dict["pa_number"] as? Int,
           let hittingHand = dict["hitting_hand"] as? Int,
           let hitting = Hand(rawValue: hittingHand),
           let pitchingHand = dict["pitching_hand"] as? Int,
           let pitching = Hand(rawValue: pitchingHand),
           let eventOrder = dict["event_order"] as? [Int] {
            return PlateAppearance(hittingHand: hitting,
                                   pitchingHand: pitching,
                                   paNumber: num,
                                   events: eventOrder)
        }
        return nil
    }
    
}
