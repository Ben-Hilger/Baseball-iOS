//
//  GameEvent.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 8/2/21.
//

import Foundation
import SwiftUI

struct GameEventBase: Equatable {

    var pitcher: RosterMember!
    var hitter: RosterMember!
    
    var actionsPerformed: [GameAction] = []
    var eventNum: Int!
    var stateOfGameBefore: GameSnapshot!

    var pitcherStyle: PitchingStyle!
    var pitcherThrowingHand: Hand!
    var hitterThrowingHand: Hand!
    
    var gameID: String!
    var paNumber: Int!
    var teamIDs: [String] = []
    
    func package() -> [String: Any] {
        var data: [String: Any] = [:]
        data["state_of_game_before"] = stateOfGameBefore.package()
        data["event_num"] = eventNum
        
        data["pitcher_id"] = pitcher.personID
        data["pitcher"] = pitcher.package()
        data["hitter_id"] = hitter.personID
        data["hitter"]  = hitter.package()
        
        data["team_ids"] = teamIDs
        
        if let gameID = gameID {
            data["game_id"] = gameID
        }
        
        if let paNumber = paNumber {
            data["pa_number"] = paNumber
        }
        
        if let hand = pitcherThrowingHand {
            data["pitcher_hand_id"] = hand.rawValue
        }
        if let hand = hitterThrowingHand {
            data["hitter_hand_id"] = hand.rawValue
        }
        if let style = pitcherStyle {
            data["pitching_style_id"] = style.rawValue
        }
        
        var actions: [[String: Any]] = []
        for action in actionsPerformed {
            actions.append(action.package())
        }
        data["actions"] = actions
        return data
    }
    
    static func initFromDictionary(dict: [String: Any]) -> GameEventBase? {
        if let pitcherID = dict["pitcher_id"] as? String,
            let pitcherData = dict["pitcher"] as? [String: Any],
            let pitcher = RosterMember.loadFromDictionary(dict: pitcherData, id: pitcherID),
            let hitterID = dict["hitter_id"] as? String,
            let hitterData = dict["hitter"] as? [String: Any],
            let hitter = RosterMember.loadFromDictionary(dict: hitterData, id: hitterID),
            let eventNum = dict["event_num"] as? Int,
           let snapshot = GameSnapshot.loadFromDictionary(dict:
                            dict["state_of_game_before"] as? [String: Any] ?? [:]),
           let actions = dict["actions"] as? [[String: Any]],
           let pitchingHandID = dict["pitcher_hand_id"] as? Int,
           let pitchingHand = Hand(rawValue: pitchingHandID),
           let hittingHandID = dict["hitter_hand_id"] as? Int,
           let hittingHand = Hand(rawValue: hittingHandID),
           let styleID = dict["pitching_style_id"] as? Int,
           let style = PitchingStyle(rawValue: styleID),
           let gameID = dict["game_id"] as? String,
           let paNumber = dict["pa_number"] as? Int {
            var compiledActions: [GameAction] = []
            for action in actions {
                if let action = GameAction.loadFromDictionary(dict: action) {
                    compiledActions.append(action)
                }
            }
            return GameEventBase(pitcher: pitcher,
                                 hitter: hitter,
                                 actionsPerformed: compiledActions,
                                 eventNum: eventNum,
                                 stateOfGameBefore: snapshot,
                                 pitcherStyle: style,
                                 pitcherThrowingHand: pitchingHand,
                                 hitterThrowingHand: hittingHand,
                                 gameID: gameID,
                                 paNumber: paNumber,
                                 teamIDs: dict["team_ids"] as? [String] ?? [])
        }
        return nil
    }
    
    static func == (lhs: GameEventBase, rhs: GameEventBase) -> Bool {
        return lhs.eventNum == rhs.eventNum
    }
}

//class GameEventBase {
//
//    var actionsPerformed: [GameAction] = []
//    var stateOfGameBeforeEvent: GameSnapshot? = nil
//
//    var pitcher: RosterMember
//    var hitter: RosterMember
//
//    var atBatNum: Int
//    var eventType: EventType
//
//    var player: RosterMember? = nil
//    var baseAt: Base? = nil
//    var baseGoingTo: Base? = nil
//
//    var pitchThrown: PitchThrown? = nil
//    var pitchOutcome: PitchOutcome? = nil
//    var extraInfo1: PitchOutcomeSpecific? = nil
//    var extraInfo2: PitchOutcomeSpecific? = nil
//    var extraInfo3: PitchOutcomeSpecific? = nil
//    var pitchNumber: Int? = nil
//
//    var strikeZoneXRelative: CGFloat? = nil
//    var strikeZoneYRelative: CGFloat? = nil
//    var ballFieldXRelative: CGFloat? = nil
//    var ballFieldYRelative: CGFloat? = nil
//
//    var pitchVelocity: Float? = nil
//    var ballExitVelocity: Float? = nil
//
//    var isError: Bool? = nil
//
//    init(pitcher: RosterMember,
//         hitter: RosterMember,
//         atBatNum: Int,
//         eventType: EventType,
//         player: RosterMember? = nil,
//         baseAt: Base? = nil,
//         baseGoingTo: Base? = nil,
//        pitchThrown: PitchThrown? = nil,
//        pitchOutcome: PitchOutcome? = nil,
//        extraInfo1: PitchOutcomeSpecific? = nil,
//        extraInfo2: PitchOutcomeSpecific? = nil,
//        extraInfo3: PitchOutcomeSpecific? = nil,
//        isError: Bool? = nil) {
//        self.pitcher = pitcher
//        self.hitter = hitter
//        self.atBatNum = atBatNum
//        self.eventType = eventType
//        self.player = player
//        self.baseAt = baseAt
//        self.baseGoingTo = baseGoingTo
//        self.pitchThrown = pitchThrown
//        self.pitchOutcome = pitchOutcome
//        self.extraInfo1 = extraInfo1
//        self.extraInfo2 =  extraInfo2
//        self.extraInfo3 = extraInfo3
//        self.isError = isError
//    }
//
//    func getEventName() -> String { return "Empty" }
//    func getSpecialAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) -> GameAction? {
//        return nil
//    }
//
//    func addActionPerformed(action: GameAction) {
//        actionsPerformed.append(action)
//    }
//
//    func setStateOfGameBeforeEvent(snapshot: GameSnapshot) {
//        self.stateOfGameBeforeEvent = snapshot
//    }
//
//    static func loadFromDictionary(dict: [String: Any]) -> GameEventBase? {
//        if let actions = dict["actions_performed"] as? [Int],
//           let snapshotDict = dict["state_of_game_before"] as? [String: Any],
//           let snapshot = GameSnapshot.loadFromDictionary(dict: snapshotDict),
//           let pitcherID = dict["pitcher_id"] as? String,
//           let pitcherData = dict["pitcher"] as? [String: Any],
//           let pitcher = RosterMember.loadFromDictionary(dict: pitcherData, id: pitcherID),
//           let hitterID = dict["hitter_id"] as? String,
//           let hitterData = dict["hitter"] as? [String: Any],
//           let hitter = RosterMember.loadFromDictionary(dict: hitterData, id: hitterID),
//           let atBatNum = dict["at_bat_num"] as? Int,
//           let eventNum = dict["event_type"] as? Int,
//           let eventType = EventType(rawValue: eventNum) ?? .none {
//            var base = GameEventBase(pitcher: pitcher,
//                     hitter: hitter, atBatNum: atBatNum, eventType: eventType)
//            if let playerID = dict["player_id"] as? String,
//               let playerData = dict["player"] as? [String: Any],
//               let player = RosterMember.loadFromDictionary(dict: playerData, id: playerID){
//                base.player = player
//            }
//            if let baseAtNum = dict["base_at"] as? Int,
//               let baseAt = Base(rawValue: baseAtNum) {
//                base.baseAt = baseAt
//            }
//            if let baseNum = dict["base_going_to"] as? Int,
//               let baseGoingTo = Base(rawValue: baseNum) {
//                base.baseGoingTo = baseGoingTo
//            }
//            if let pitchID = dict["pitch_thrown_id"] as? String,
//               let pitchData = dict["pitch_thrown"] as? [String: Any],
//               let pitch = PitchThrown.loadFromDictionary(dict: pitchData,
//                                                          id: pitchID) {
//                base.pitchThrown = pitch
//            }
//            if let outcomeID = dict["pitch_outcome_id"] as? String,
//               let outcomeData = dict["pitch_outcome"] as? [String: Any],
//               let outcome = PitchOutcome.loadFromDictionary(dict: outcomeData,
//                                                             id: outcomeID) {
//                base.pitchOutcome = outcome
//            }
//            if let info1 = dict["extra_info_1_id"] as? String,
//               let infoData = dict["extra_info_1_id"] as? [String: Any],
//               let info = PitchOutcomeSpecific.loadFromDictionary(dict: infoData,
//                                                                  id: info1) {
//                base.extraInfo1 = info
//            }
//            if let info2 = dict["extra_info_2_id"] as? String,
//               let infoData = dict["extra_info_2_id"] as? [String: Any],
//               let info = PitchOutcomeSpecific.loadFromDictionary(dict: infoData,
//                                                                  id: info2) {
//                base.extraInfo2 = info
//            }
//            if let info3 = dict["extra_info_3_id"] as? String,
//               let infoData = dict["extra_info_3_id"] as? [String: Any],
//               let info = PitchOutcomeSpecific.loadFromDictionary(dict: infoData,
//                                                                  id: info3) {
//                base.extraInfo3 = info
//            }
//            if let pitchNumber = dict["pitch_number"] as? Int {
//                base.pitchNumber = pitchNumber
//            }
//            if let strikeX = dict["strike_X_rel"] as? CGFloat {
//                base.strikeZoneXRelative = strikeX
//            }
//            if let strikeY = dict["strike_Y_rel"] as? CGFloat {
//                base.strikeZoneYRelative = strikeY
//            }
//            if let ballX = dict["ball_X_rel"] as? CGFloat {
//                base.ballFieldXRelative = ballX
//            }
//            if let ballY = dict["ball_Y_rel"] as? CGFloat {
//                base.ballFieldYRelative = ballY
//            }
//            if let pitchVelo = dict["pitch_velocity"] as? Float {
//                base.pitchVelocity = pitchVelo
//            }
//            if let ballExitVelocity = dict["ball_exit_velocity"] as? Float {
//                base.ballExitVelocity = ballExitVelocity
//            }
//            if let error = dict["is_error"] as? Bool {
//                base.isError = error
//            }
//            for action in actions {
//                if let actionType = ActionType(rawValue: action) {
//                    let act = ActionType.buildAction(forType: actionType,
//                                                     event: base)
//                    base.actionsPerformed.append(act)
//                }
//            }
//            return base
//        }
//        return nil
//    }
//
//    func package() -> [String: Any] {
//        var package: [String: Any] = [:]
//        var actions: [Int] = []
//        for action in actionsPerformed {
//            actions.append(action.getActionType().rawValue)
//        }
//        package["actions_performed"] = actions
//        if let pack = stateOfGameBeforeEvent?.package() {
//            package["state_of_game_before"] = pack
//        }
//        package["pitcher_id"] = pitcher.personID
//        package["pitcher"] = pitcher.package()
//        package["hitter_id"] = hitter.personID
//        package["hitter"] = hitter.package()
//        package["at_bat_num"] = atBatNum
//        package["event_type"] = eventType.rawValue
//
//        if let player = player {
//            package["player_id"] = player.personID
//            package["player"] = player.package()
//        }
//        if let base = baseAt {
//            package["base_at"] = base.rawValue
//        }
//        if let base = baseGoingTo {
//            package["base_going_to"] = base.rawValue
//        }
//        if let pitch = pitchThrown {
//            package["pitch_thrown_id"] = pitch.pitchID
//            package["pitch_thrown"] = pitch.package(includeID: true)
//        }
//        if let outcome = pitchOutcome {
//            package["pitch_outcome_id"] = outcome.outcomeID
//            package["pitch_outcome"] = outcome.package(includeID: true)
//        }
//        if let extraInfo1 = extraInfo1 {
//            package["extra_info_1_id"] = extraInfo1.specificID
//            package["extra_info_1"] = extraInfo1.package(includeID: true)
//        }
//        if let extraInfo2 = extraInfo2 {
//            package["extra_info_2_id"] = extraInfo2.specificID
//            package["extra_info_2"] = extraInfo2.package(includeID: true)
//        }
//        if let extraInfo3 = extraInfo3 {
//            package["extra_info_3_id"] = extraInfo3.specificID
//            package["extra_info_3"] = extraInfo3.package(includeID: true)
//        }
//        if let pitchNumber = pitchNumber {
//            package["pitch_number"] = pitchNumber
//        }
//        if let strikeX = strikeZoneXRelative {
//            package["strike_X_rel"] = strikeX
//        }
//        if let strikeY = strikeZoneYRelative {
//            package["strike_Y_rel"] = strikeY
//        }
//        if let ballX = ballFieldXRelative {
//            package["ball_X_rel"] = ballX
//        }
//        if let ballY = ballFieldYRelative {
//            package["ball_Y_rel"] = ballY
//        }
//        if let pitchVelo = pitchVelocity {
//            package["pitch_velocity"] = pitchVelo
//        }
//        if let ballExitVelocity = ballExitVelocity {
//            package["ball_exit_velocity"] = ballExitVelocity
//        }
//        if let error = isError {
//            package["is_error"] = error
//        }
//        return package
//    }
//}
//
//enum EventType: Int {
//    case Pitch = 0
//    case BIPAction = 1
//    case HitterInterference = 2
//    case RunnerInterference = 3
//    case PickoffThrow = 4
//    case PickoffOut = 5
//    case PickoffAdvance = 6
//    case RunnerSteal = 7
//    case RunnerAdvance = 8
//    case RunnerStealOut = 9
//}
//    static func convertEvent(fromBase base: GameEventBase,
//                             toType type: EventType) -> GameEventBase? {
//        switch type {
//        case .Pitch:
//            if let pitch = base.pitchThrown, let outcome = base.pitchOutcome,
//               let extra1 = base.extraInfo1 {
//                return PitchEvent(pitchThrown: pitch,
//                                  pitchOutcome: outcome,
//                                  extraInfo1: extra1,
//                                  extraInfo2: base.extraInfo2,
//                                  extraInfo3: base.extraInfo3,
//                                  hitter: base.hitter,
//                                  pitcher: base.pitcher,
//                                  atBatNum: base.atBatNum)
//            }
//            return nil
//        case .BIPAction:
//            return
//        case .HitterInterference:
//            return Inter
//        case .RunnerInterference:
//            if let player = base.player, let baseAt = base.baseAt {
//                return RunnerInterferenceEvent(player: player, base: baseAt,
//                                       atBatNum: base.atBatNum,
//                                       pitcher: base.pitcher, hitter: base.hitter)
//            }
//           return nil
//        case .PickoffThrow:
//            return PickoffThrowEvent(pitcher: base.pitcher,
//                                 hitter: base.hitter, atBatNum: base.atBatNum)
//        case .PickoffOut:
//            if let player = base.player, let baseAt = base.baseAt {
//                return PickoffOutEvent(pitcher: base.pitcher, hitter: base.hitter, atBatNum: base.atBatNum, baseAt: baseAt, player: player)
//            }
//            return nil
//        case .PickoffAdvance:
//            return PickoffA
//        case .RunnerSteal:
//            <#code#>
//        case .RunnerAdvance:
//            <#code#>
//        }
//    }
//}
