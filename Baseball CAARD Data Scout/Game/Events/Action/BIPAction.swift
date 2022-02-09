//
//  BIPAction.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 8/6/21.
//

import Foundation

class BIPAdvanceAction: GameAction {
    override func performAction(gameViewModel: GameViewModel,
                       gameState: GameStateViewModel) {
        if let player = player,
           let baseAdvancingTo = baseGoingTo,
           let baseStartingAt = baseAt {
            gameViewModel.movePlayer(fromBase: baseStartingAt,
                                     toBase: baseAdvancingTo,
                                     playerToMove: player)

        }
    }
    
    override func getActionType() -> ActionType {
        return .BIPAdvance
    }
}

class BIPOutOnBasepathAction: GameAction {
    override func performAction(gameViewModel: GameViewModel,
                       gameState: GameStateViewModel) {
        if let player = player, let baseAt = baseAt {
            if gameViewModel.getPlayerAtBase(base: baseAt) == player {
                gameViewModel.clearBase(base: baseAt)
            }
            gameViewModel.addOuts()
        }
    }
    
    override func getActionType() -> ActionType {
        return .BIPOutBasepath
    }
}

class BIPOutFielderChoiceAction: GameAction {
    override func performAction(gameViewModel: GameViewModel,
                       gameState: GameStateViewModel) {
        if let baseAt = baseAt, let player = player {
            if gameViewModel.getPlayerAtBase(base: baseAt) == player {
                gameViewModel.clearBase(base: baseAt)
            }
            gameViewModel.addOuts()
        }
    }
    
    override func getActionType() -> ActionType {
        return .BIPOutFielderChoice
    }
}

class BIPOutDoublePlayAction: GameAction {
    override func performAction(gameViewModel: GameViewModel,
                       gameState: GameStateViewModel) {
        if let baseAt = baseAt, let player = player {
            if gameViewModel.getPlayerAtBase(base: baseAt) == player {
                gameViewModel.clearBase(base: baseAt)
            }
            gameViewModel.addOuts()
        }
    }
    
    override func getActionType() -> ActionType {
        return .BIPDoublePlayOut
    }
}
