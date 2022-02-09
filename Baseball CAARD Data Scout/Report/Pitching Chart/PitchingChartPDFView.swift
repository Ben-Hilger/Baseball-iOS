//
//  PitchingChartPDFView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/21/21.
//

import SwiftUI

struct PitchingChartPDFTotals: View {
    
    var pa: [PlateAppearance]
    var events: [Int: GameEventBase]
    var body: some View {
        VStack {
            PitchingChartPDFTotalsCell(pa: pa, events: events, hand: [.Left], title: "LHH")
                .padding()
                .border(Color.black)
            PitchingChartPDFTotalsCell(pa: pa, events: events, hand: [.Right], title: "RHH")
                .padding()
                .border(Color.black)
        }
    }
}

struct PitchingChartPDFTotalsCell: View {
    
    var pa: [PlateAppearance] = []
    var events: [Int: GameEventBase] = [:]
    var hand: [Hand]
    var title: String

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Text("\(title)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .border(Color.black, width: 1)
                HStack {
                    VStack(alignment: .leading) {
                        Text("FB K=\(calculateTotalStrikes(ofPitches: ["FA","FT"]))")
                        Text("S+M=\(calculateTotalSwingMiss(ofPitches: ["FA","FT"]))")
                    }
                    .frame(maxWidth: .infinity)
                    VStack {
                        Text("Total FB")
                        Text("\(calculateTotal(ofPitches: ["FA","FT"]))")
                    }.frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .border(Color.black, width: 1)
                .frame(width: geometry.size.width)
                HStack {
                    VStack(alignment: .leading) {
                        Text("BB K=\(calculateTotalStrikes(ofPitches: ["CU"]))")
                        Text("S+M=\(calculateTotalSwingMiss(ofPitches: ["CU"]))")
                    }
                    .frame(maxWidth: .infinity)
                    VStack {
                        Text("Total BB")
                        Text("\(calculateTotal(ofPitches: ["CU"]))")
                    }.frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .border(Color.black, width: 1)
                HStack {
                    VStack(alignment: .leading) {
                        Text("SL K=\(calculateTotalStrikes(ofPitches: ["SL"]))")
                        Text("S+M=\(calculateTotalSwingMiss(ofPitches: ["SL"]))")
                    }
                    .frame(maxWidth: .infinity)
                    VStack {
                        Text("Total SL")
                        Text("\(calculateTotal(ofPitches: ["SL"]))")
                    }.frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .border(Color.black, width: 1)
                HStack {
                    VStack(alignment: .leading) {
                        Text("CHUP K=\(calculateTotalStrikes(ofPitches: ["CH"]))")
                        Text("S+M=\(calculateTotalSwingMiss(ofPitches: ["CH"]))")
                    }
                    .frame(maxWidth: .infinity)
                    VStack{
                        Text("Total CHUP")
                        Text("\(calculateTotal(ofPitches: ["CH"]))")
                    }.frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .border(Color.black, width: 1)
                HStack {
                    Text("FP K=")
                        .frame(maxWidth: .infinity)
                    Text("\(getFirstPitchStrikes()) / \(getTotalFirstPitch())")
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .border(Color.black, width: 1)
                HStack {
                    Text("1-1 K=")
                        .frame(maxWidth: .infinity)
                    Text("\(get11StrikePercentage()) / \(getTotal11Pitches())")
                        .frame(maxWidth: .infinity)
                    
                }.frame(maxWidth: .infinity)
                .padding()
                .border(Color.black, width: 1)
                
            }
            
        }
    }
    
    func getFirstPitchStrikes() -> Int {
        var sum = 0
        for pa in pa {
            for event in pa.events {
                var foundPitch: Bool = false
                if let currentEvent = events[event] {
                    for action in currentEvent.actionsPerformed {
                        if action.getActionType() == .PitchAction {
                            if let outcome = action.pitchOutcome,
                               outcome.strikesToAdd > 0,
                               hand.contains(currentEvent.hitterThrowingHand) {
                                sum += 1
                            }
                            foundPitch = true
                            break
                        }
                    }
                }
                if foundPitch {
                    break
                }
            }
        }
        return sum
    }
    
    func getTotalFirstPitch() -> Int {
        var sum = 0
        for pa in pa {
            for event in pa.events {
                var foundPitch: Bool = false
                if let currentEvent = events[event] {
                    for action in currentEvent.actionsPerformed {
                        if action.getActionType() == .PitchAction,
                           hand.contains(currentEvent.hitterThrowingHand) {
                            sum += 1
                            foundPitch = true
                            break
                        }
                    }
                }
                if foundPitch {
                    break
                }
            }
        }
        return sum
    }
    
    func get11StrikePercentage() -> Int {
        var sum = 0
        for pa in pa {
            for event in pa.events {
                if let currentEvent = events[event] {
                    if currentEvent.stateOfGameBefore.numberBalls == 1,
                       currentEvent.stateOfGameBefore.numberStrikes == 1 {
                        for action in currentEvent.actionsPerformed {
                            if action.getActionType() == .PitchAction,
                               hand.contains(currentEvent.hitterThrowingHand),
                               let outcome = action.pitchOutcome,
                               outcome.strikesToAdd > 0 {
                                sum += 1
                            }
                        }
                    }
                }
            }
        }
        return sum
    }
    
    func getTotal11Pitches() -> Int {
        var sum = 0
        for pa in pa {
            for event in pa.events {
                if let currentEvent = events[event] {
                    if currentEvent.stateOfGameBefore.numberBalls == 1,
                       currentEvent.stateOfGameBefore.numberStrikes == 1 {
                        for action in currentEvent.actionsPerformed {
                            if action.getActionType() == .PitchAction,
                               hand.contains(currentEvent.hitterThrowingHand) {
                                sum += 1
                            }
                        }
                    }
                }
            }
        }
        return sum
    }
    
    func calculateTotalStrikes(ofPitches names: [String]) -> Int {
        var sum = 0
        for pa in pa {
            for event in pa.events {
                if let currentEvent = events[event] {
                    for action in currentEvent.actionsPerformed {
                        if action.getActionType() == .PitchAction,
                           hand.contains(currentEvent.hitterThrowingHand),
                           let outcome = action.pitchOutcome,
                           outcome.strikesToAdd > 0 {
                            sum += 1
                        }
                    }
                }
            }
        }
        return sum
    }
    
    func calculateTotalSwingMiss(ofPitches names: [String]) -> Int {
        var sum = 0
        for pa in pa {
            for event in pa.events {
                if let currentEvent = events[event] {
                    for action in currentEvent.actionsPerformed {
                        if action.getActionType() == .PitchAction,
                           hand.contains(currentEvent.hitterThrowingHand),
                           let outcome = action.pitchOutcome,
                           let extra1 = action.extraInfo1,
                           outcome.strikesToAdd > 0,
                           extra1.shortName == "SW",
                           outcome.shortName == "STR" {
                            sum += 1
                        }
                    }
                }
            }
        }
        return sum
    }
    
    func calculateTotal(ofPitches names: [String]) -> Int {
        var sum = 0
        for pa in pa {
            for event in pa.events {
                if let currentEvent = events[event] {
                    for action in currentEvent.actionsPerformed {
                        if action.getActionType() == .PitchAction,
                           hand.contains(currentEvent.hitterThrowingHand) {
                            sum += 1
                        }
                    }
                }
            }
        }
        return sum

    }
    
}

struct PitchingChartPDFView: View {
    
    var pitcherViewing: RosterMember
    var isLimitingBy: Int
    var isStartingAt: Int
    
    var pitches: [GameAction] = []
    var event: GameEventBase
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 0)  {
                    Text("\(pitcherViewing.getFullName())")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .border(Color.black, width: 1)
                    VStack(alignment: .leading, spacing: 0) {
                        PitchingChartHeader(font: 10)
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height * 0.1)
                        ForEach(isStartingAt..<min(pitches.count, isStartingAt+isLimitingBy), id: \.self) { index in
//                            PitchingChartRowCell(action: pitches[index],
//                                                 event: event,
//                                                 showHitterText: true,
//                                                 font: 10)
//                                .frame(width: geometry.size.width,
//                                   height: geometry.size.height * 0.07)
//                            if let outcome = pitches[index].pitchOutcome,
//                               let state = pitches[index].stateOfGameBeforeEvent,
//                               outcome.outsToAdd+state.numberOuts >= 3 ||
//                                (state.numberOuts == 2 &&
//                                    (pitches[index].extraInfo1?.markHitterAsOut ?? false ||
//                                    pitches[index].extraInfo2?.markHitterAsOut ?? false)) {
//                                Text("End of Half Inning")
//                                    .font(.system(size: 10))
//                                    .frame(width: geometry.size.width,
//                                           height: geometry.size.height * 0.03, alignment: .center)
//                                    .border(Color.black)
//                                    .padding([.top,. bottom])
//                            }
                        }
                    }
                }
            }
        }.padding()
    }
}

