//
//  HistoryView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 8/8/21.
//

import Foundation
import SwiftUI

struct HistoryListView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Game History")
                    .frame(width: geometry.size.width,
                           height: geometry.size.height * 0.05)
                    .border(Color.black)
                List {
//                    ForEach(organizeByPlateAppearance().keys.sorted().reversed(), id: \.self) { historyIndex in
//                        Text("PA #\(historyIndex)")
//                            .frame(width: geometry.size.width,
//                                   height: geometry.size.height * 0.05)
//                            .border(Color.black)
//                        ForEach(0..<gameViewModel.eventHistory[index].actionsPerformed.count, id: \.self) { actionIndex in
//                            if let action = gameViewModel.eventHistory[index].actionsPerformed[actionIndex],
//                                let pitchThrown = action.pitchThrown,
//                               let pitchOutcome = action.pitchOutcome,
//                               let pitchNumber = action.pictchNumber {
//                                HistoryPitchEventViewCell(pitchThrown: pitchThrown,
//                                                          pitchOutcome: pitchOutcome,
//                                                          pitchVelocity: action.pitchVelocity,
//                                                          pitchNumber: pitchNumber)
//                                    .frame(maxWidth: .infinity)
//                                    .border(Color.black, width: 2)
//                            }
//                        }
                        
                    }
                }
            }
        }
}


struct HistoryPitchEventViewCell: View {
    
    var pitchThrown: PitchThrown
    var pitchOutcome: PitchOutcome
    var pitchVelocity: Float?
    var pitchNumber: Int
    
    var body: some View {
            HStack {
                    Text("\(pitchNumber)")
                        .padding()
                        .background(Color.red)
                        .clipShape(Circle())
                    VStack {
                        Text(pitchThrown.longName)
                            .padding()
                        if let floatVelo = pitchVelocity, let velo = Int(floatVelo) {
                            Text("\(velo) mph")
                                .padding()
                        } else {
                            Text("-- mph")
                                .padding()
                        }
                    }
                    Text(pitchOutcome.longName)
                        .padding()
                }
    }
     
    func getOutcomeColor(outcome: PitchOutcome) -> Color {
        // Check if Fastball
        if outcome.strikesToAdd > 0 {
            return Color.red
        } else if outcome.ballsToAdd > 0 {
            return Color.green
        }
        return Color.black
    }
}
