//
//  GameState.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 7/30/21.
//

import Foundation
import SwiftUI

class GameStateViewModel: ObservableObject {
    
    @Published var mainViewState: GameMainViewState = .Field
 
    @Published var baseSelected: Base = .None
    @Published var runnerState: RunnerState = .None
        
    @Published var event: GameEventBase = GameEventBase()
    
    @Published var teamEditing: Team = .Home
    
    @Published var homeLineup: [LineupPerson] = []
    @Published var awayLineup: [LineupPerson] = []
    
    @Published var selectedPitch: PitchThrown? = nil
    @Published var selectedOutcome: PitchOutcome? = nil
    @Published var extraInfo1: PitchOutcomeSpecific? = nil
    @Published var extraInfo2: PitchOutcomeSpecific? = nil
    @Published var extraInfo3: PitchOutcomeSpecific? = nil
    
    @Published var strikeZoneX: CGFloat? = nil
    @Published var strikeZoneY: CGFloat? = nil
    
    @Published var ballFieldX: CGFloat? = nil
    @Published var ballFieldY: CGFloat? = nil
    
    @Published var pitchVelocity: String = ""
    @Published var hittingExitVelocity: String = ""
    
    func resetRunnerState() {
        runnerState = .None
        baseSelected = .None
    }
    
    func getCurrentPitchAction() -> PitchGameAction? {
//        for action in (event.actionsPerformed).reversed() {
//            if action.getActionType() == .PitchAction {
//                return action as? PitchGameAction
//            }
//        }
        return nil
    }
}

enum RunnerState {
    case Selected
    case Pickoff
    case Steal
    case Advance
    case None
}
