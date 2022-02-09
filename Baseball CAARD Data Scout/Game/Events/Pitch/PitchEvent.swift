//
//  PitchEvent.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 8/2/21.
//

import Foundation
import SwiftUI

//class PitchEvent: GameEventBase {
//
//    init(pitchThrown: PitchThrown,
//         pitchOutcome: PitchOutcome,
//         extraInfo1: PitchOutcomeSpecific,
//         extraInfo2: PitchOutcomeSpecific?,
//         extraInfo3: PitchOutcomeSpecific?,
//         hitter: RosterMember,
//         pitcher: RosterMember,
//         atBatNum: Int) {
//        super.init(pitcher: pitcher,
//                   hitter: hitter,
//                   atBatNum: atBatNum,
//                   eventType: EventType.Pitch,
//                   pitchThrown: pitchThrown,
//                   pitchOutcome: pitchOutcome,
//                   extraInfo1: extraInfo1,
//                   extraInfo2: extraInfo2,
//                   extraInfo3: extraInfo3)
//    }
//
//    override func getEventName() -> String {
//        return "Pitch"
//    }
//    override func getSpecialAction(gameViewModel: GameViewModel, gameState: GameStateViewModel) -> GameAction? {
//        if let pitchThrown = pitchThrown, let pitchOutcome = pitchOutcome, let extraInfo1 = extraInfo1 {
//            return PitchGameAction()
//        }
//        return nil
//    }
//
//    func setStrikeZoneInfo(strikeZoneX: CGFloat, strikeZoneY: CGFloat) {
//        strikeZoneXRelative = strikeZoneX
//        strikeZoneYRelative = strikeZoneY
//    }
//
//    func setBallFieldInfo(ballFieldX: CGFloat, ballFieldY: CGFloat) {
//        ballFieldXRelative = ballFieldX
//        ballFieldYRelative = ballFieldY
//    }
//
//}

class PitchGameAction: GameAction {
    override func performAction(gameViewModel: GameViewModel,
                       gameState: GameStateViewModel) {
        gameViewModel.processPitchAction(event: self)

    }
    
    override func getActionType() -> ActionType {
        return .PitchAction
    }
}
