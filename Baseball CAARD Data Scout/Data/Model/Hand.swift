//
//  Hand.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/18/21.
//

import Foundation

//struct Hand {
//    
//    var handID: String
//    var shortName: String
//    var longName: String
//    
//    func package() -> [String: Any] {
//        var package: [String: Any] = [:]
//        package["short_name"] = shortName
//        package["long_name"] = longName
//        return package
//    }
//    
//    static func initFromDictionary(dict: [String: Any], id: String) -> Hand? {
//        if let shortName = dict["short_name"] as? String,
//           let longName = dict["long_name"] as? String {
//            return Hand(handID: id, shortName: shortName,
//                        longName: longName)
//        }
//        return nil
//    }
//}

enum Hand: Int {
    case Left = 1
    case Right = 2
    case Switch = 3
    
    func getShortName() -> String {
        switch self {
        case .Left:
            return "LH"
        case .Right:
            return "RH"
        case .Switch:
            return "SW"
        }
    }
}
