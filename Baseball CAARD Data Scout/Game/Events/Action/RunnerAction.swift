//
//  RunnerAction.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 8/15/21.
//

import Foundation

class RunnerStealAction: GameAction {
    override func performAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) {
        if let baseAt = baseAt, let baseGoingTo = baseGoingTo,
           let runner = player {
            gameViewModel.movePlayer(fromBase: baseAt,
                                     toBase: baseGoingTo,
                                     playerToMove: runner)
        }
    }
    
    override func getActionType() -> ActionType {
        return .RunnerSteal
    }
}

class RunnerStealOutAction: GameAction {
    override func performAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) {
        if let baseAt = baseAt, let runner = player {
            gameViewModel.clearBase(base: baseAt)
            gameViewModel.markPlayerOut(player: runner)
        }
    }
    
    override func getActionType() -> ActionType {
        return .RunnerStealOut
    }
}

class RunnerAdvanceAction: GameAction {
    override func performAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) {
        if let baseAt = baseAt, let baseGoingTo = baseGoingTo,
           let runner = player {
            gameViewModel.movePlayer(fromBase: baseAt,
                                     toBase: baseGoingTo,
                                     playerToMove: runner)
        }
    }
    
    override func getActionType() -> ActionType {
        return .RunnerAdvance
    }
}

class RunnerAdvanceOutAction: GameAction {
    override func performAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) {
        if let baseAt = baseAt, let runner = player {
            gameViewModel.clearBase(base: baseAt)
            gameViewModel.markPlayerOut(player: runner)
        }
    }
    
    override func getActionType() -> ActionType {
        return .RunnerAdvance
    }
}
