//
//  RunnerEvent.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 8/15/21.
//

import Foundation

//class RunnerAdvanceEvent: GameEventBase {
//
//    init(pitcher: RosterMember,
//         hitter: RosterMember,
//         atBatNum: Int,
//         baseAt: Base,
//         baseGoingTo: Base,
//         player: RosterMember,
//         isError: Bool) {
//        super.init(pitcher: pitcher,
//                   hitter: hitter,
//                   atBatNum: atBatNum,
//                   eventType: .RunnerAdvance,
//                   player: player,
//                   isError: isError)
//    }
//
//    override func getEventName() -> String {
//        return "Runner Advance"
//    }
//
//    override func getSpecialAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) -> GameAction? {
//        if let player = player, let baseAt = baseAt, let baseGoingTo = baseGoingTo, let isError = isError {
//            return RunnerAdvanceAction(actionID: .RunnerAdvance, player: player, atBase: baseAt,
//                                   baseAdvancingTo: baseGoingTo, error: isError)
//        }
//        return nil
//    }
//
//}
//
//class RunnerStealEvent: GameEventBase {
//
//    init(pitcher: RosterMember,
//         hitter: RosterMember,
//         atBatNum: Int,
//         baseAt: Base,
//         baseGoingTo: Base,
//         player: RosterMember,
//         isError: Bool) {
//        super.init(pitcher: pitcher,
//                   hitter: hitter,
//                   atBatNum: atBatNum,
//                   eventType: .RunnerAdvance,
//                   player: player,
//                   baseAt: baseAt,
//                   baseGoingTo: baseGoingTo,
//                   isError: isError)
//    }
//
//    override func getEventName() -> String {
//        return "Stolen Base"
//    }
//
//    override func getSpecialAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) -> GameAction? {
//        if let player = player, let baseAt = baseAt, let baseGoingTo = baseGoingTo, let isError = isError {
//            return RunnerStealAction(actionID: .RunnerSteal, player: player, atBase: baseAt, baseAdvancingTo: baseGoingTo, error: isError)
//        }
//        return nil
//    }
//
//}
//
//class RunnerStealOutEvent: GameEventBase {
//
//    init(pitcher: RosterMember,
//         hitter: RosterMember,
//         atBatNum: Int,
//         baseAt: Base,
//         player: RosterMember) {
//        super.init(pitcher: pitcher,
//                   hitter: hitter,
//                   atBatNum: atBatNum,
//                   eventType: .RunnerAdvance,
//                   player: player,
//                   baseAt: baseAt)
//    }
//
//    override func getEventName() -> String {
//        return "Stolen Base Out"
//    }
//
//    override func getSpecialAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) -> GameAction? {
//        if let player = player, let baseAt = baseAt  {
//            return RunnerStealOutAction(actionID: .RunnerStealOut, player: player, atBase: baseAt)
//        }
//        return nil
//    }
//
//}
