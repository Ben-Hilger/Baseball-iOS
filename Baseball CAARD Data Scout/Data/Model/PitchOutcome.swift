//
//  Pitchoutcome.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 7/26/21.
//

import Foundation

struct PitchOutcome: Hashable, Equatable {
    
    var outcomeID: String
    var shortName: String
    var longName: String
    
    var specificOptions: [PitchOutcomeSpecific] = []
    var extraInfoOption: [PitchOutcomeSpecific] = []
    
    var defaultExtraInfo1: PitchOutcomeSpecific? = nil
    
    var strikesToAdd: Int = 0
    var ballsToAdd: Int = 0
    var outsToAdd: Int = 0
    
    var isDropThird: Bool = false
    
    var isFB: Bool = false
    var isBIP: Bool = false
    var isHBP: Bool = false
    
    static func == (lhs: PitchOutcome, rhs: PitchOutcome) -> Bool {
        return lhs.shortName == rhs.shortName &&
            lhs.longName == rhs.longName
    }
    
    func package(includeID: Bool = false) -> [String: Any] {
        var package: [String: Any] = [:]
        package["short_name"] = shortName
        package["long_name"] = longName
        package["strikes_to_add"] = strikesToAdd
        package["balls_to_add"] = ballsToAdd
        package["outs_to_add"] = outsToAdd
        package["is_fb"] = isFB
        package["is_bip"] = isBIP
        package["show_as_drop_third"] = isDropThird
        package["is_hbp"] = isHBP
        return package
    }
    
    static func loadFromDictionary(dict: [String: Any], id: String) -> PitchOutcome? {
        if let shortName = dict["short_name"] as? String,
           let longName = dict["long_name"] as? String,
           let strikesToAdd = dict["strikes_to_add"] as? Int,
           let ballsToAdd = dict["balls_to_add"] as? Int,
           let outsToAdd = dict["outs_to_add"] as? Int {
            return PitchOutcome(outcomeID: id, shortName: shortName,
                                longName: longName, defaultExtraInfo1: PitchOutcomeSpecific.loadFromDictionary(dict: dict["default_pitch_outcome_specific"] as? [String: Any] ?? [:], id: dict["default_pitch_outcome_specific_id"] as? String ?? ""), strikesToAdd: strikesToAdd,
                            ballsToAdd: ballsToAdd,
                            outsToAdd: outsToAdd,
                            isDropThird: dict["show_as_drop_third"] as? Bool ?? false,
                            isFB: dict["is_fb"] as? Bool ?? false,
                            isBIP: dict["is_bip"] as? Bool ?? false,
                            isHBP: dict["is_hbp"] as? Bool ?? false)
        }
        return nil
    }
}

struct PitchOutcomeSpecific: Hashable, Equatable {
    
    var specificID: String
    var shortName: String
    var longName: String
    
    var markHitterAsOut: Bool = false
    var sendHitterToBase: Base = .None
    var canRunnerAdvance: Bool = false
    var isDoublePlay: Bool = false
    var isTriplePlay: Bool = false
    var isFC: Bool = false
    var hitterSwing: Bool = false
    static func == (lhs: PitchOutcomeSpecific, rhs: PitchOutcomeSpecific) -> Bool {
        return lhs.specificID == rhs.specificID
    }
    
    func package(includeID: Bool = false) -> [String: Any] {
        var package: [String: Any] = [:]
        package["specific_id"] = specificID
        package["short_name"] = shortName
        package["long_name"] = longName
        package["mark_hitter_as_out"] = markHitterAsOut
        package["send_hitter_to_base_id"] = sendHitterToBase.rawValue
        package["can_runner_advance"] = canRunnerAdvance
        package["is_double_play"] = isDoublePlay
        package["is_triple_play"] = isDoublePlay
        package["is_fc"] = isDoublePlay
        package["hitter_swing"] = hitterSwing
        return package
    }
    
    static func loadFromDictionary(dict: [String: Any],
                                   id: String) -> PitchOutcomeSpecific? {
        if let shortName = dict["short_name"] as? String,
           let longName = dict["long_name"] as? String,
           let markHitterAsOut = dict["mark_hitter_as_out"] as? Bool {
            return PitchOutcomeSpecific(specificID: id, shortName: shortName,
                    longName: longName,
                    markHitterAsOut: markHitterAsOut,
                    sendHitterToBase: Base(rawValue: dict["send_hitter_to_base_id"] as? Int ?? -1) ?? .None,
                    canRunnerAdvance: dict["can_runner_advance"] as? Bool ?? false,
                    isDoublePlay: dict["is_double_play"] as? Bool ?? false,
                    isTriplePlay: dict["is_triple_play"] as? Bool ?? false,
                    isFC: dict["is_fc"] as? Bool ?? false,
                    hitterSwing: dict["hitter_swing"] as? Bool ?? false)
        }
        return nil
    }
}

enum PitchOutcomeSpecificType {
    case Standard
    case BIPType
    case BIPOutcome
    case None
}
//
//var swinging: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "SW", longName: "Swinging")
//var looking: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "LK", longName: "Looking")
//
//var passedBall: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "PB", longName: "Passed Ball")
//var wildPitch: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "WP", longName: "Wild Pitch")
//
//var pitchout: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "PO", longName: "Pitch Out")
//
//var single: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "1B", longName: "Single", sendHitterToBase: .First)
//var double: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "2B", longName: "Double", sendHitterToBase: .Second)
//var triple: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "3B", longName: "Triple", sendHitterToBase: .Third)
//var homerun: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "HR", longName: "Home Run", sendHitterToBase: .Home)
//var homeRunPark: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "HRInP", longName: "Home Run (In Park)", sendHitterToBase: .Home)
//var fieldersChoice: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "FC", longName: "Fielder's Choice", sendHitterToBase: .First)
//
//var hitterOut: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "HO", longName: "Hitter Out")
//var doublePlay: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "DP", longName: "Double Play")
//var triplePlay: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "TP", longName: "Triple Day")
//
//var safe: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "S", longName: "Safe", extra: [
//    single,
//    double,
//    triple,
//    homerun,
//    homeRunPark,
//    fieldersChoice
//])
//
//var out: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "O", longName: "Out", extra: [
//    hitterOut,
//    doublePlay,
//    triplePlay
//])
//
//var groundBall: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "GB", longName: "Ground Ball")
//
//var hardGroundBall: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "HGB", longName: "Hard Ground Ball")
//var flyBall: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "FB", longName: "Fly Ball")
//var lineDrive: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "LD", longName: "Line Drive")
//var popFly: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "PF", longName: "Pop Fly")
//var bunt: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "BT", longName: "Bunt")
//var flare: PitchOutcomeSpecific = PitchOutcomeSpecific(shortName: "FL", longName: "Flare")
//
//
//let bip = PitchOutcome(shortName: "BIP", longName: "Ball In Play", specificOptions: [
//    groundBall,
//    hardGroundBall,
//    flyBall,
//    lineDrive,
//    popFly,
//    bunt,
//    flare
//], extraInfoOption: [
//    safe,
//    out
//])
//
//
//let strike = PitchOutcome(shortName: "SK", longName: "Strike", specificOptions: [
//    swinging,
//    looking
//], extraInfoOption: [
//    passedBall,
//    wildPitch,
//    pitchout
//], strikesToAdd: 1)
//
//let ball = PitchOutcome(shortName: "BL", longName: "Ball", specificOptions: [
//                            passedBall,
//                            wildPitch,
//pitchout], extraInfoOption: [], ballsToAdd: 1)
//
//let foulball = PitchOutcome(shortName: "F", longName: "Foul Ball", specificOptions: [
//                                passedBall,
//                                wildPitch], extraInfoOption: [], strikesToAdd: 1, stopAfter2Strikes: true)
//
//let batterInterference = PitchOutcomeSpecific(shortName: "BINF", longName: "Batter Interference", markHitterAsOut: true)
//let catcherInterference = PitchOutcomeSpecific(shortName: "CINF", longName: "Catcher Interference", sendHitterToBase: .First)
//
//let interference = PitchOutcome(shortName: "INF", longName: "Interference", specificOptions: [
//    batterInterference,
//    catcherInterference
//], extraInfoOption: [])
//
