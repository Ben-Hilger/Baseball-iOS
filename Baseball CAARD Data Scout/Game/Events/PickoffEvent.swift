//
//  PickoffGameEvent.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 8/2/21.
//

import Foundation

//class PickoffOutEvent: GameEventBase {
//
//    init(pitcher: RosterMember,
//         hitter: RosterMember,
//         atBatNum: Int,
//         baseAt: Base,
//         player: RosterMember) {
//        super.init(pitcher: pitcher,
//                   hitter: hitter,
//                   atBatNum: atBatNum,
//                   eventType: .PickoffOut,
//                   player: player,
//                   baseAt: baseAt)
//    }
//
//    override func getEventName() -> String {
//        return "Pickoff"
//    }
//
//    override func getSpecialAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) -> GameAction? {
//        if let base = baseAt, let player = player {
//            return PickoffOutAction(actionID: .PickoffOut, player: player, atBase: base)
//        }
//        return nil
//    }
//}

class PickoffOutAction: GameAction {
    override func performAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) {
        if let base = baseAt {
            _ = gameViewModel.markPlayerOnBaseOut(base: base)
        }
    }
    
    override func getActionType() -> ActionType {
        return .PickoffOut
    }
}

//class PickoffThrowEvent: GameEventBase {
//
//    init(pitcher: RosterMember,
//         hitter: RosterMember,
//         atBatNum: Int) {
//        super.init(pitcher: pitcher,
//                   hitter: hitter,
//                   atBatNum: atBatNum,
//                   eventType: .PickoffThrow)
//    }
//
//    override func getEventName() -> String {
//        return "Pickoff (Throw)"
//    }
//
//    override func getSpecialAction(gameViewModel:  GameViewModel, gameState:  GameStateViewModel) -> GameAction {
//        return PickoffThrowAction(actionID: .PickoffThrow)
//    }
//
//
//}

class PickoffThrowAction: GameAction {
    override func performAction(gameViewModel: GameViewModel,
                       gameState: GameStateViewModel) {}
    
    override func getActionType() -> ActionType {
        return .PickoffThrow
    }
}


//class PickoffAdvanceEvent: GameEventBase {
//
//    init(pitcher: RosterMember,
//         hitter: RosterMember,
//         atBatNum: Int,
//         baseAt: Base,
//         baseGoingTo: Base,
//         player: RosterMember,
//         isError: Bool = false) {
//        super.init(pitcher: pitcher,
//                   hitter: hitter,
//                   atBatNum: atBatNum,
//                   eventType: .PickoffAdvance,
//                   player: player,
//                   baseAt: baseAt,
//                   baseGoingTo: baseGoingTo,
//                   isError: isError)
//    }
//
//    override func getEventName() -> String {
//        return "Pickoff (Advance)"
//    }
//
//    override func getSpecialAction(gameViewModel:  GameViewModel, gameState:  GameStateViewModel) -> GameAction? {
//        if let player = player, let currentBase = baseAt, let baseGoingTo = baseGoingTo, let isError = isError {
//            return PickoffAdvanceAction(actionID: .PickoffAdvance, player: player, atBase: currentBase,
//                                        baseAdvancingTo: baseGoingTo, error: isError)
//        }
//        return nil
//    }
//}

class PickoffAdvanceAction: GameAction {
    override func performAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) {
        if let player = player,
           let currentBase = baseAt,
           let baseAdvancingTo = baseGoingTo {
            gameViewModel.movePlayer(fromBase: currentBase,
                                     toBase: baseAdvancingTo,
                                     playerToMove: player)
        }
    }
    
    override func getActionType() -> ActionType {
        return .PickoffAdvance
    }
}
