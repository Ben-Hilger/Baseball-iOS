//
//  InterferenceEvent.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 8/2/21.
//

import Foundation

class RunnerInterferenceAction: GameAction {
    override func performAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) {
        if let base = baseAt {
            print("Marking player out...")
            _ = gameViewModel.markPlayerOnBaseOut(base: base)
        }
    }
    
    override func getActionType() -> ActionType {
        return .RunnerIntereference
    }
}
