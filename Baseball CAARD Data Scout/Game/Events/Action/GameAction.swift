//
//  GameActioon.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 8/2/21.
//

import Foundation
import SwiftUI

class GameEmptyAction: GameAction {
    func performAction(gameViewModel: GameViewModel,
                       gameState: GameStateViewModel, event: GameEventBase) {}
    
    override func getActionType() -> ActionType {
        return .None
    }
}

enum ActionType: Int {
    case None = 1
    case GameOut = 2
    case GameAdvance = 3
    case PitchAction = 4
     case RunnerIntereference = 5
    case RunnerAdvance = 6
    case RunnerAdvanceOut = 7
    case RunnerSteal = 8
    case RunnerStealOut = 9
    case PickoffOut = 10
    case PickoffThrow = 11
    case PickoffAdvance = 12
    case BIPAdvance = 13
    case BIPOutFielderChoice = 14
    case BIPDoublePlayOut = 15
    case BIPOutBasepath = 16
}

class GameAction {
                
    var actionNum: Int? = nil

    var eventType: ActionType
    
    var player: RosterMember? = nil
    var baseAt: Base? = nil
    var baseGoingTo: Base? = nil
    
    var pitchThrown: PitchThrown? = nil
    var pitchOutcome: PitchOutcome? = nil
    var extraInfo1: PitchOutcomeSpecific? = nil
    var extraInfo2: PitchOutcomeSpecific? = nil
    var extraInfo3: PitchOutcomeSpecific? = nil
    var pitchNumber: Int? = nil
    
    var strikeZoneXRelative: CGFloat? = nil
    var strikeZoneYRelative: CGFloat? = nil
    var ballFieldXRelative: CGFloat? = nil
    var ballFieldYRelative: CGFloat? = nil
   
    var pitchVelocity: Float? = nil
    var ballExitVelocity: Float? = nil
    
    var isError: Bool? = nil
    
    var bipOrder: String? = nil
    
    init(eventType: ActionType,
         player: RosterMember? = nil,
         baseAt: Base? = nil,
         baseGoingTo: Base? = nil,
        pitchThrown: PitchThrown? = nil,
        pitchOutcome: PitchOutcome? = nil,
        extraInfo1: PitchOutcomeSpecific? = nil,
        extraInfo2: PitchOutcomeSpecific? = nil,
        extraInfo3: PitchOutcomeSpecific? = nil,
        isError: Bool? = nil) {
        self.eventType = eventType
        self.player = player
        self.baseAt = baseAt
        self.baseGoingTo = baseGoingTo
        self.pitchThrown = pitchThrown
        self.pitchOutcome = pitchOutcome
        self.extraInfo1 = extraInfo1
        self.extraInfo2 =  extraInfo2
        self.extraInfo3 = extraInfo3
        self.isError = isError
    }
    
    func performAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) {}
    func getActionType() -> ActionType {
        return eventType
    }
    
    static func loadFromDictionary(dict: [String: Any]) -> GameAction? {
        if let eventNum = dict["action_type"] as? Int,
           let eventType = ActionType(rawValue: eventNum) ?? .none {
            let base = GameAction(eventType: eventType)
            base.actionNum = dict["action_num"] as? Int
            if let playerID = dict["player_id"] as? String,
               let playerData = dict["player"] as? [String: Any],
               let player = RosterMember.loadFromDictionary(dict: playerData, id: playerID){
                base.player = player
            }
            if let baseAtNum = dict["base_at"] as? Int,
               let baseAt = Base(rawValue: baseAtNum) {
                base.baseAt = baseAt
            }
            if let baseNum = dict["base_going_to"] as? Int,
               let baseGoingTo = Base(rawValue: baseNum) {
                base.baseGoingTo = baseGoingTo
            }
            if let pitchID = dict["pitch_thrown_id"] as? String,
               let pitchData = dict["pitch_thrown"] as? [String: Any],
               let pitch = PitchThrown.loadFromDictionary(dict: pitchData,
                                                          id: pitchID) {
                base.pitchThrown = pitch
            }
            if let outcomeID = dict["pitch_outcome_id"] as? String,
               let outcomeData = dict["pitch_outcome"] as? [String: Any],
               let outcome = PitchOutcome.loadFromDictionary(dict: outcomeData,
                                                             id: outcomeID) {
                base.pitchOutcome = outcome
            }
            if let info1 = dict["extra_info_1_id"] as? String,
               let infoData = dict["extra_info_1"] as? [String: Any],
               let info = PitchOutcomeSpecific.loadFromDictionary(dict: infoData,
                                                                  id: info1) {
                base.extraInfo1 = info
            }
            if let info2 = dict["extra_info_2_id"] as? String,
               let infoData = dict["extra_info_2"] as? [String: Any],
               let info = PitchOutcomeSpecific.loadFromDictionary(dict: infoData,
                                                                  id: info2) {
                base.extraInfo2 = info
            }
            if let info3 = dict["extra_info_3_id"] as? String,
               let infoData = dict["extra_info_3"] as? [String: Any],
               let info = PitchOutcomeSpecific.loadFromDictionary(dict: infoData,
                                                                  id: info3) {
                base.extraInfo3 = info
            }
            if let pitchNumber = dict["pitch_number"] as? Int {
                base.pitchNumber = pitchNumber
            }
            if let strikeX = dict["strike_X_rel"] as? CGFloat {
                base.strikeZoneXRelative = strikeX
            }
            if let strikeY = dict["strike_Y_rel"] as? CGFloat {
                base.strikeZoneYRelative = strikeY
            }
            if let ballX = dict["ball_X_rel"] as? CGFloat {
                base.ballFieldXRelative = ballX
            }
            if let ballY = dict["ball_Y_rel"] as? CGFloat {
                base.ballFieldYRelative = ballY
            }
            if let pitchVelo = dict["pitch_velocity"] as? Float {
                base.pitchVelocity = pitchVelo
            }
            if let ballExitVelocity = dict["ball_exit_velocity"] as? Float {
                base.ballExitVelocity = ballExitVelocity
            }
            if let error = dict["is_error"] as? Bool {
                base.isError = error
            }
            if let order = dict["bip_order"] as? String {
                base.bipOrder = order
            }
            return base
        }
        return nil
    }
    
    func package() -> [String: Any] {
        var package: [String: Any] = [:]
        package["action_type"] = eventType.rawValue
        
        if let actionNum = actionNum {
            package["action_num"] = actionNum
        }
        if let player = player {
            package["player_id"] = player.personID
            package["player"] = player.package()
        }
        if let base = baseAt {
            package["base_at"] = base.rawValue
        }
        if let base = baseGoingTo {
            package["base_going_to"] = base.rawValue
        }
        if let pitch = pitchThrown {
            package["pitch_thrown_id"] = pitch.pitchID
            package["pitch_thrown"] = pitch.package(includeID: true)
        }
        if let outcome = pitchOutcome {
            package["pitch_outcome_id"] = outcome.outcomeID
            package["pitch_outcome"] = outcome.package(includeID: true)
        }
        if let extraInfo1 = extraInfo1 {
            package["extra_info_1_id"] = extraInfo1.specificID
            package["extra_info_1"] = extraInfo1.package(includeID: true)
        }
        if let extraInfo2 = extraInfo2 {
            package["extra_info_2_id"] = extraInfo2.specificID
            package["extra_info_2"] = extraInfo2.package(includeID: true)
        }
        if let extraInfo3 = extraInfo3 {
            package["extra_info_3_id"] = extraInfo3.specificID
            package["extra_info_3"] = extraInfo3.package(includeID: true)
        }
        if let pitchNumber = pitchNumber {
            package["pitch_number"] = pitchNumber
        }
        if let strikeX = strikeZoneXRelative {
            package["strike_X_rel"] = strikeX
        }
        if let strikeY = strikeZoneYRelative {
            package["strike_Y_rel"] = strikeY
        }
        if let ballX = ballFieldXRelative {
            package["ball_X_rel"] = ballX
        }
        if let ballY = ballFieldYRelative {
            package["ball_Y_rel"] = ballY
        }
        if let pitchVelo = pitchVelocity {
            package["pitch_velocity"] = pitchVelo
        }
        if let ballExitVelocity = ballExitVelocity {
            package["ball_exit_velocity"] = ballExitVelocity
        }
        if let error = isError {
            package["is_error"] = error
        }
        if let bipOrder = bipOrder {
            package["bip_order"] = bipOrder
        }
        return package
    }
}

//class GameAction {
//
//    var actionID: ActionType
//    var player: RosterMember?
//    var atBase: Base?
//    var baseAdvancingTo: Base?
//    var error: Bool?
//
//    var pitchThrown: PitchThrown?
//    var pitchOutcome: PitchOutcome?
//    var extraInfo1: PitchOutcomeSpecific?
//    var extraInfo2: PitchOutcomeSpecific?
//    var extraInfo3: PitchOutcomeSpecific?
//
//    init(actionID: ActionType,
//         player: RosterMember? = nil,
//         atBase: Base? = nil,
//         baseAdvancingTo: Base? = nil,
//         error: Bool? = nil,
//         pitchThrown: PitchThrown? = nil,
//         pitchOutcome: PitchOutcome? = nil,
//         extraInfo1: PitchOutcomeSpecific? = nil,
//         extraInfo2: PitchOutcomeSpecific? = nil,
//         extraInfo3: PitchOutcomeSpecific? = nil) {
//        self.actionID = actionID
//        self.player = player
//        self.atBase = atBase
//        self.baseAdvancingTo = baseAdvancingTo
//        self.error = error
//        self.pitchThrown = pitchThrown
//        self.pitchOutcome = pitchOutcome
//        self.extraInfo1 = extraInfo1
//        self.extraInfo2 = extraInfo2
//        self.extraInfo3 = extraInfo3
//    }
//
//    func performAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) {}
//
//}

class GameOutAction: GameAction {
    
    override func performAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) {
        if let base = baseAt {
            _ = gameViewModel.markPlayerOnBaseOut(base: base)
        } else if let playerOut = player {
            gameViewModel.markPlayerOut(player: playerOut)
        }
    }
    
    override func getActionType() -> ActionType {
        return .GameOut
    }
}

class GameAdvanceAction: GameAction {
    override func performAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) {
        if let base = baseAt, let baseAdvancingTo = baseGoingTo,
           let playerToAdvance = player {
            gameViewModel.movePlayer(fromBase: base,
                                     toBase: baseAdvancingTo,
                                     playerToMove: playerToAdvance)
        } else if let baseAdvancingTo = baseGoingTo,
                  let playerToAdvance = player {
            gameViewModel.movePlayer(toBase: baseAdvancingTo,
                                     playerToMove: playerToAdvance)
        }
    }
    
    override func getActionType() -> ActionType {
        return .GameAdvance
    }
}
