////
////  DataEditorView.swift
////  Baseball CAARD Data Scout
////
////  Created by Benjamin Hilger on 10/2/21.
////
//
import SwiftUI

struct PAEditorMainView: View {
    
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        List {
            ForEach(gameViewModel.paOrder, id: \.self) { index in
                PAInfoRow(paNum: gameViewModel.pa[index]!.paNumber)
                ForEach(gameViewModel.pa[index]?.events ?? [], id: \.self) { event in
                    if let curEvent = gameViewModel.events[event] {
                        PAEventHeaderInfoRow(eventNum: curEvent.eventNum)
                        VStack(spacing: 0) {
                            PAEventPlayerInfoRow(event: curEvent)
                            PAEventInfoRow(event: curEvent)
                        }.padding().border(Color.blue, width: 3)
                        
                        VStack(spacing: 0) {
                            ForEach(0..<curEvent.actionsPerformed.count, id: \.self) { action in
                                if curEvent.actionsPerformed[guarded: action]!.getActionType() == .PitchAction {
                                    PAPitchActionInfoRow(action: curEvent.actionsPerformed[guarded: action]!)
                                }
                            }
                        }.border(Color.black)
                    }
                }
            }
        }
    }
}

struct PAPitchActionInfoRow: View {
    
    var action: GameAction
    
    var body: some View {
        HStack {
            if let pitchNum = action.pitchNumber {
                Text("#\(pitchNum)")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if let pitch = action.pitchThrown {
                Text("\(pitch.longName)")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if let pitchOutcome = action.pitchOutcome {
                Text("\(pitchOutcome.longName)")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if let velo = action.pitchVelocity {
                Text("\(Int(velo)) MPH")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct PAEventPlayerInfoRow: View {
    
    var event: GameEventBase
    
    var body: some View {
        HStack {
            HStack {
                Text("Hitter: \(event.hitter.lastName)")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text("\(event.hitterThrowingHand.getShortName())H")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            HStack {
                Text("Pitcher: \(event.pitcher.lastName)")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                Text("\(event.hitterThrowingHand.getShortName())P")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text("\(event.pitcherStyle.getLongName())")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct PAEventInfoRow: View {
    
    var event: GameEventBase
    
    var body: some View {
        HStack {
            Text("Count: \(event.stateOfGameBefore.numberBalls)-\(event.stateOfGameBefore.numberStrikes)")
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text("\(event.stateOfGameBefore.numberOuts) Out\(event.stateOfGameBefore.numberOuts == 1 ? "" : "s")")
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct PAEventHeaderInfoRow: View {
    
    var eventNum: Int
    
    var body: some View {
        HStack {
            Text("Event #\(eventNum)")
                .padding()
                .frame(maxWidth: .infinity)
                .border(Color.blue, width: 3)
                .foregroundColor(.blue)
        }
    }
}

struct PAInfoRow: View {
    
    var paNum: Int
    
    var body: some View {
        HStack {
            Text("PA #\(paNum)")
                .padding()
                .frame(maxWidth: .infinity)
                .border(Color.red, width: 3)
                .foregroundColor(.red)
        }
    }
}

struct PAAuxOptionsView: View {
    
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                gameStateViewModel.mainViewState = .Field
            }, label: {
                Text("Back")
                    .foregroundColor(Color.red)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red, lineWidth: 5)
                            )
            })
            Spacer()
        }
    }
}

//
//struct DataEditorView: View {
//
//    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
//    @EnvironmentObject var gameViewModel: GameViewModel
//
//    var body: some View {
//        List {
//            ForEach(gameViewModel.paOrder, id: \.self) { paIndex in
//                if gameViewModel.pa.keys.contains(paIndex) {
//                    PlateAppearanceDetail(paIndex: paIndex)
//                        .frame(maxWidth: .infinity)
//                    if let count = gameViewModel.pa[paIndex]?.events.count {
//                        ForEach(0..<count, id: \.self) { event in
//                            PlateAppearanceEventDetail(paIndex: paIndex,
//                                                       event: event)
//                                .frame(maxWidth: .infinity)
//                            ForEach(0..<(gameViewModel.pa[paIndex]?.events[event].actionsPerformed.count)!,
//                                    id: \.self) { action in
//                                if gameViewModel.pa[paIndex]?.events[event].actionsPerformed[action].eventType == .PitchAction {
//                                    PlateAppearanceActionDetail(paIndex: paIndex,
//                                        event: event,
//                                        action: action)
//                                        .frame(maxWidth: .infinity)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct PlateAppearanceDetail: View {
//
//    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
//    @EnvironmentObject var gameViewModel: GameViewModel
//
//    var paIndex: Int
//
//    var body: some View {
//        PlateAppearanceHeader(paNumber: paIndex,
//              pitchingHand: Binding(get: {
//                return gameViewModel.pa[paIndex]!.pitchingHand
//              }, set: { val in
//                if let val = val  {
//                    gameViewModel.pa[paIndex]!.pitchingHand = val
//                }
//              }),
//              hittingHand: Binding(get: {
//                return gameViewModel.pa[paIndex]!.hittingHand
//              }, set: { val in
//                if let val = val {
//                    gameViewModel.pa[paIndex]!.hittingHand = val
//                }
//              }))
//            .padding()
//            .frame(maxWidth: .infinity)
//            .border(Color.black)
//    }
//}
//
////struct PlateAppearanceEventDetail: View {
////
////    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
////    @EnvironmentObject var gameViewModel: GameViewModel
////
////    var paIndex: Int
////    var event: Int
////
////    var body: some View {
////        PlateAppearanceEventInfo(numberStrikes: Binding(get: {
////            return gameViewModel.pa[paIndex]!.events[guarded: event]!.stateOfGameBefore.numberStrikes
////        }, set: { val in
////            gameViewModel.pa[paIndex]!.events[event].stateOfGameBefore.numberStrikes = val
////        }), numberBalls: Binding(get: {
////            return gameViewModel.pa[paIndex]!.events[guarded: event]!.stateOfGameBefore.numberBalls
////        }, set: { val in
////            gameViewModel.pa[paIndex]!.events[event].stateOfGameBefore.numberBalls = val
////        }), numberOuts: Binding(get: {
////            return gameViewModel.pa[paIndex]!.events[guarded: event]!.stateOfGameBefore.numberOuts
////        }, set: { val in
////            gameViewModel.pa[paIndex]!.events[event].stateOfGameBefore.numberOuts = val
////        }))
////        .padding()
////        .frame(maxWidth: .infinity)
////        .border(Color.black)
////    }
////}
//
//struct PlateAppearanceActionDetail: View {
//
//    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
//    @EnvironmentObject var gameViewModel: GameViewModel
//
//    var paIndex: Int
//    var event: Int
//    var action: Int
//
//    var body: some View {
//        PlateAppearancePitchInfo(pitchOutcome: Binding(get: {
//            return gameViewModel.pa[paIndex]!.events[guarded: event]!.actionsPerformed[guarded: action]!.pitchOutcome!
//        }, set: { val in
//            gameViewModel.pa[paIndex]!.events[guarded: event]!.actionsPerformed[guarded: action]!.pitchOutcome = val
//        }), strikeZoneX: Binding(get: {
//            return gameViewModel.pa[paIndex]!.events[guarded: event]!.actionsPerformed[guarded: action]!.strikeZoneXRelative!
//        }, set: { val in
//            gameViewModel.pa[paIndex]!.events[guarded: event]!.actionsPerformed[guarded: action]!.strikeZoneXRelative = val
//        }), stikeZoneY: Binding(get: {
//            return gameViewModel.pa[paIndex]!.events[guarded: event]!.actionsPerformed[guarded: action]!.strikeZoneYRelative!
//        }, set: { val in
//            gameViewModel.pa[paIndex]!.events[guarded: event]!.actionsPerformed[guarded: action]!.strikeZoneYRelative = val
//        }))
//        .padding()
//        .frame(maxWidth: .infinity)
//        .border(Color.black)
//    }
//}
//
//struct PlateAppearanceEventInfo: View {
//
//    @Binding var numberStrikes: Int
//    @Binding var numberBalls: Int
//    @Binding var numberOuts: Int
//
//
//    var body: some View {
//        HStack {
//            Text("\(numberBalls)-\(numberStrikes)")
//                .padding()
//                .border(Color.black)
//            Spacer()
//            Text("Outs: \(numberOuts)")
//                .padding()
//                .border(Color.black)
//        }
//    }
//}
//
//struct PlateAppearancePitchInfo: View {
//
//    @EnvironmentObject var gameInfo: GameStaticViewModel
//
//    @Binding var pitchOutcome: PitchOutcome
//    @State var showOutcomeChange: Bool = false
//
//    @Binding var strikeZoneX: CGFloat?
//    @Binding var stikeZoneY: CGFloat?
//
//    var body: some View {
//        HStack {
//            Text("\(pitchOutcome.longName)")
//                .padding()
//                .border(Color.black)
//            Spacer()
//            VStack(spacing: 0) {
//                Button {
//
//                } label: {
//                    Text("Edit Strike Zone")
//                        .padding()
//                        .border(Color.black)
//                }
//                Button {
//
//                } label: {
//                    Text("Edit Ball Field Info")
//                        .padding()
//                        .border(Color.black)
//                }
//            }
//        }
//    }
//
//    func getOutcomeChangeButtons() -> [ActionSheet.Button] {
//        var buttons: [ActionSheet.Button] = []
//        for outcome in gameInfo.outcomes {
//            buttons.append(ActionSheet.Button.default(Text("\(outcome.longName)"),
//                                                      action: {
//                self.pitchOutcome = outcome
//            }))
//        }
//        return buttons
//    }
//}
//
//struct PlateAppearanceHeader: View {
//
//    @State var paNumber: Int
//
//    @Binding var pitchingHand: Hand?
//    @Binding var hittingHand: Hand?
//
//    @State var showPitchingOptions: Bool = false
//    @State var showHittingOptions: Bool = false
//
//    var body: some View {
//        HStack {
//            Text("\(paNumber)")
//                .padding()
//                .border(Color.black)
//            Spacer()
//            Button {
//                showPitchingOptions = true
//            } label: {
//                Text("\(pitchingHand!.getShortName())P")
//                    .padding()
//                    .border(Color.black)
//                    .actionSheet(isPresented: $showPitchingOptions) {
//                        ActionSheet(title: Text("Change Pitching Hand"),
//                                message: Text("Select the new pitching hand for the plate appearance"),
//                                buttons: getPitchingButtons())
//                    }
//            }
//            Button {
//                showHittingOptions = true
//            } label: {
//                Text("\(hittingHand!.getShortName())H")
//                    .padding()
//                    .border(Color.black)
//                    .actionSheet(isPresented: $showHittingOptions) {
//                        ActionSheet(title: Text("Change Hitting Hand"),
//                                message: Text("Select the new hitting hand for the plate appearance"),
//                                buttons: getPitchingButtons())
//                    }
//            }
//        }
//    }
//
//    func getPitchingButtons() -> [ActionSheet.Button] {
//        var buttons: [ActionSheet.Button] = []
//        buttons.append(ActionSheet.Button.default(Text("LHP"), action: {
//            self.pitchingHand = .Left
//        }))
//        buttons.append(ActionSheet.Button.default(Text("RHP"), action: {
//            self.pitchingHand = .Right
//        }))
//        return buttons
//    }
//
//    func getHittingButtons() -> [ActionSheet.Button] {
//        var buttons: [ActionSheet.Button] = []
//        buttons.append(ActionSheet.Button.default(Text("LHH"), action: {
//            self.hittingHand = .Left
//        }))
//        buttons.append(ActionSheet.Button.default(Text("RHH"), action: {
//            self.hittingHand = .Right
//        }))
//        return buttons
//    }
//}
//
//struct DataEditorView_Previews: PreviewProvider {
//    static var previews: some View {
//        DataEditorView()
//    }
//}
