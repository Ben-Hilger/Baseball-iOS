//
//  PitchingSStyle.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/18/21.
//

import Foundation

//struct PitchingStyle {
//
//    var pitchingID: String
//    var shortName: String
//    var longName: String
//
//    static func initFromDictionary(dict: [String: Any], id: String) -> PitchingStyle? {
//        if let shortName = dict["short_name"] as? String,
//           let longName = dict["long_name"] as? String {
//            return PitchingStyle(pitchingID: id,
//                                 shortName: shortName, longName: longName)
//        }
//        return nil
//    }
//
//    func package() -> [String: Any] {
//        var package: [String: Any] = [:]
//        package["short_name"] = shortName
//        package["long_name"] = longName
//        return package
//    }
//}

enum PitchingStyle: Int {
    case Stretch = 1
    case Windup = 2
    
    func getShortName() -> String {
        switch self {
        case .Stretch:
            return "STR"
        case .Windup:
            return "WND"
        }
    }
    
    func getLongName() -> String {
        switch self {
        case .Stretch:
            return "Stretch"
        case .Windup:
            return "Windup"
        }
    }
}


