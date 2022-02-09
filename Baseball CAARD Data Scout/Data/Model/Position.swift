//
//  Position.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/16/21.
//

import Foundation

struct Position: Equatable, Hashable {
    
    var positionID: String
    var shortName: String
    var longName: String
    var positionNum: Int
    
    var isDH: Bool = false
    var removeFromOptionsOnceSelected: Bool = true
    static func loadFromDictionary(dict: [String: Any], id: String) -> Position? {
        if let shortName = dict["short_name"] as? String,
           let longName = dict["long_name"] as? String,
           let num = dict["position_num"] as? Int {
            return Position(positionID: id, shortName: shortName, longName: longName,
                        positionNum: num, isDH: dict["is_dh"] as? Bool ?? false,
                        removeFromOptionsOnceSelected: dict["remove_once_selected"] as? Bool ?? true)
        }
        return nil
    }
    
    func package(includeID: Bool = false) -> [String: Any] {
        var package: [String: Any] = [:]
        package["short_name"] = shortName
        package["long_name"] = longName
        package["position_num"] = positionNum
        if includeID {
            package["position_id"] = positionID
        }
        package["is_dh"] = isDH
        package["remove_once_selected"] = removeFromOptionsOnceSelected
        return package
    }
    
    static func == (lhs: Position, rhs: Position) -> Bool {
        return lhs.positionID == rhs.positionID
    }
    
}
