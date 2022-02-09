//
//  GameAuxInformationView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 7/30/21.
//

import Foundation
import SwiftUI

struct BallFieldAuxView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
//
//    @Binding var ballFieldX: CGFloat?
//    @Binding var ballFieldY: CGFloat?
//
    var body: some View {
        HStack {
            Button(action: {
                resetBallFieldInfo()
                gameStateViewModel.mainViewState = .Field
            }, label: {
                Text("Cancel")
                    .foregroundColor(Color.red)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red, lineWidth: 5)
                            )
            })
            Button(action: {
                gameStateViewModel.mainViewState = .Field
            }, label: {
                Text("Done")
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 5)
                            )
            })
        }
    }
    
    func resetBallFieldInfo() {
        gameStateViewModel.ballFieldX = nil
        gameStateViewModel.ballFieldY = nil
    }
}

struct StrikeZoneAuxView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
//
//    @Binding var strikeZoneX: CGFloat?
//    @Binding var strikeZoneY: CGFloat?
//
    var body: some View {
        HStack {
            Button(action: {
                gameStateViewModel.strikeZoneX = nil
                gameStateViewModel.strikeZoneY = nil
                gameStateViewModel.mainViewState = .Field
            }, label: {
                Text("Cancel")
                    .foregroundColor(Color.red)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red, lineWidth: 5)
                            )
            })
            Button(action: {
//                if let x = strikeZoneX, let y = strikeZoneY {
////                    gameViewModel.addStrikeZoneInformationToPitchEvent(strikeZoneX: x,
////                                                                       strikeZoneY: y)
                gameStateViewModel.mainViewState = .Field
//                }
                
            }, label: {
                Text("Done")
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 5)
                            )
            })
        }
    }
}

struct AddPitchAuxView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    var body: some View {
        HStack {

            Button(action: {
                resetPitchingInfo()
                gameStateViewModel.mainViewState = .Field
            }, label: {
                Text("Cancel")
                    .foregroundColor(Color.red)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red, lineWidth: 5)
                            )
            })
            Spacer()
            Button(action: {
                if gameStateViewModel.mainViewState == .AddPitch {
                    resetPitchingInfo()
                } else if gameStateViewModel.mainViewState == .StrikeZone {
                    gameStateViewModel.strikeZoneY = nil
                    gameStateViewModel.strikeZoneX = nil
                } else if gameStateViewModel.mainViewState == .BallField {
                    gameStateViewModel.ballFieldX = nil
                    gameStateViewModel.ballFieldY = nil
                } else if gameStateViewModel.mainViewState == .BallVelo {
                    gameStateViewModel.pitchVelocity = ""
                    gameStateViewModel.hittingExitVelocity = ""
                }
            }, label: {
                Text("Clear")
                    .foregroundColor(Color.red)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red, lineWidth: 5)
                            )
            })
            Button(action: {
                gameStateViewModel.mainViewState = .StrikeZone
            }, label: {
                Text("Strike Zone")
                    .foregroundColor(getStrikeZoneBorderColor())
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(getStrikeZoneBorderColor(), lineWidth: 5)
                            )
            })
            Button(action: {
                gameStateViewModel.mainViewState = .BallVelo
            }, label: {
                Text("Velocity")
                    .foregroundColor(getVelocityBorderColor())
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(getVelocityBorderColor(), lineWidth: 5)
                            )
            })
            Button(action: {
                gameStateViewModel.mainViewState = .AddPitch
            }, label: {
                Text("Outcome")
                    .foregroundColor(getOutcomeBorderColor())
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(getOutcomeBorderColor(), lineWidth: 5)
                            )
            })
            if gameStateViewModel.selectedOutcome?.isBIP ?? false {
                Button(action: {
                    gameStateViewModel.mainViewState = .BallField
                }, label: {
                    Text("Ball Field Location")
                        .foregroundColor(getBallFieldBorderColor())
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(getBallFieldBorderColor(), lineWidth: 5)
                                )
                })
            }
            Spacer()
            Button(action: {
                // Force at least one option to be selected to move foreåward
                if let pitch = gameStateViewModel.selectedPitch, let outcome = gameStateViewModel.selectedOutcome,
                   let option1 = gameStateViewModel.extraInfo1 {
                    let action = PitchGameAction(eventType: .PitchAction,
                                                 pitchThrown: pitch,
                                                 pitchOutcome: outcome,
                                                 extraInfo1: option1,
                                                 extraInfo2: gameStateViewModel.extraInfo2,
                                                 extraInfo3: gameStateViewModel.extraInfo3)
                    gameStateViewModel.event.actionsPerformed.append(action)
                    action.ballFieldXRelative = gameStateViewModel.ballFieldX
                    action.ballFieldYRelative = gameStateViewModel.ballFieldY
                    action.strikeZoneXRelative = gameStateViewModel.strikeZoneX
                    action.strikeZoneYRelative = gameStateViewModel.strikeZoneY
                    action.bipOrder = gameViewModel.bipOrder
                    if let velo = Float(gameStateViewModel.pitchVelocity) {
                        action.pitchVelocity = velo
                    }
                    if let velo = Float(gameStateViewModel.hittingExitVelocity) {
                        action.ballExitVelocity = velo
                    }

                    if outcome.isBIP {
                        gameViewModel.markBasesToUpdate()
                        if (gameViewModel.basesToUpdate.count >  0)  {
                            gameStateViewModel.mainViewState = .BIP
                        } else {
                            GameEngine.processEvent(gameViewModel: gameViewModel,
                                                    gameState: gameStateViewModel)
                            gameStateViewModel.mainViewState = .Field

                        }
                    } else {
                        GameEngine.processEvent(gameViewModel: gameViewModel,
                                                gameState: gameStateViewModel)
                        gameStateViewModel.mainViewState = .Field
                    }
                    resetPitchingInfo()
                }
            }, label: {
                Text("Add Pitch")
                    .foregroundColor(getAddPitchButtonColor())
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(getAddPitchButtonColor(), lineWidth: 5)
                            )
            }).disabled(!canAddPitch())
        }
    }
    
    func resetPitchingInfo() {
        gameStateViewModel.selectedPitch = nil
        gameStateViewModel.selectedOutcome = nil
        gameStateViewModel.extraInfo1 = nil
        gameStateViewModel.extraInfo2 = nil
        gameStateViewModel.extraInfo3 = nil
        gameStateViewModel.strikeZoneY = nil
        gameStateViewModel.strikeZoneX = nil
        gameStateViewModel.ballFieldX = nil
        gameStateViewModel.ballFieldY = nil
        gameStateViewModel.pitchVelocity = ""
        gameStateViewModel.hittingExitVelocity = ""
    }
    
    func getStrikeZoneBorderColor() -> Color {
        return gameStateViewModel.strikeZoneX == nil ||
            gameStateViewModel.strikeZoneY == nil ?
            Color.red : Color.green
    }
    
    func getBallFieldBorderColor() -> Color {
        return gameStateViewModel.ballFieldX == nil ||
            gameStateViewModel.ballFieldY == nil ?
            Color.red : Color.green
    }
    
    func getOutcomeBorderColor() -> Color {
        return gameStateViewModel.selectedPitch == nil ||
            gameStateViewModel.selectedOutcome == nil ||
            gameStateViewModel.extraInfo1 == nil ? Color.red : Color.green
    }
    
    func getVelocityBorderColor() -> Color {
        if gameStateViewModel.pitchVelocity == "" {
            return .red
        }
        return .green
    }
    
    func canAddPitch() -> Bool {
        return !(gameStateViewModel.selectedPitch == nil ||
                    gameStateViewModel.selectedOutcome == nil ||
                    gameStateViewModel.extraInfo1 == nil)
    }
    
    func getAddPitchButtonColor() -> Color {
        return canAddPitch() ? .blue : .gray
    }
}

//struct PitchAuxView: View {
//
//    @EnvironmentObject var gameViewModel: GameViewModel
//    @EnvironmentObject var gameStateViewModel: GameStateViewModel
//
//    @Binding var strikeZoneX: CGFloat?
//    @Binding var strikeZoneY: CGFloat?
//
//    @Binding var ballFieldX: CGFloat?
//    @Binding var ballFieldY: CGFloat?
//    var body: some View {
//        HStack {
//            Button(action: {
//                gameStateViewModel.mainViewState = .StrikeZone
//            }, label: {
//                Text("Add Strike Zone Information")
//                    .foregroundColor(getStrikeZoneBorderColor())
//                    .padding()
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 20)
//                            .stroke(getStrikeZoneBorderColor(), lineWidth: 5)
//                            )
//            })
//            Button(action: {
//                gameStateViewModel.mainViewState = .BallField
//            }, label: {
//                Text("Add Ball Field Location")
//                    .foregroundColor(getBallFieldBorderColor())
//                    .padding()
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 20)
//                            .stroke(getBallFieldBorderColor(), lineWidth: 5)
//                            )
//            })
//            Button(action: {
//                gameViewModel.reset()
//                gameStateViewModel.mainViewState = .Field
//            }, label: {
//                Text("Reset to Last Pitch")
//                    .padding()
//                    .foregroundColor(.red)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 20)
//                            .stroke(Color.red, lineWidth: 5)
//                            )
//            })
//        }
//    }
//
//    func getStrikeZoneBorderColor() -> Color {
//        return strikeZoneX == nil ||
//            strikeZoneY == nil ?
//            Color.red : Color.green
//    }
//
//    func getBallFieldBorderColor() -> Color {
//        return ballFieldX == nil ||
//            ballFieldY == nil ?
//            Color.red : Color.green
//    }
//}

// BEGIN StrikeZone View

struct StrikeZoneSelectionView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
//
//    @Binding var xRel: CGFloat?
//    @Binding var yRel: CGFloat?
//
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Strike Zone")
                    .font(.title)
                StrikeZoneView(xRelative: $gameStateViewModel.strikeZoneX, yRelative: $gameStateViewModel.strikeZoneY)
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.75)
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct StrikeZoneView: View {

    @Binding var xRelative: CGFloat?
    @Binding var yRelative: CGFloat?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                    }
                    HStack(spacing: 0) {
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2, showBorders: true)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2, showBorders: true)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2, showBorders: true)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                    }
                    HStack(spacing: 0) {
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2, showBorders: true)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2, showBorders: true)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2, showBorders: true)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                    }
                    HStack(spacing: 0) {
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2, showBorders: true)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2, showBorders: true)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2, showBorders: true)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                    }
                    HStack(spacing: 0) {
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                        Zone(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                    }
                }.frame(width: geometry.size.width, height: geometry.size.height).border(Color.black, width: 4)
                .coordinateSpace(name: "strikezone")
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("strikezone")).onChanged({ value in
                    xRelative = min(max((value.location.x) / geometry.size.width, 0), 1)
                    yRelative = min(max(value.location.y / (geometry.size.height), 0), 1)
                }).onEnded({ _ in
                    
                }))
                if let x = xRelative, let y = yRelative {
                    Circle()
                        .size(CGSize(width: 15, height: 15))
                        .fill(Color.red)
                        .offset(x: x * geometry.size.width,
                                y: y * geometry.size.height)
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
            
        }
    }
}

struct Zone: View {
    
    var width: CGFloat
    var height: CGFloat
    
    var showBorders: Bool = false
    
    var body: some View {
        Rectangle()
            .size(CGSize(width: width, height: height))
            .fill(Color.gray)
            .opacity(0.8)
            .if(showBorders, transform: { view in
                view.border(Color.black, width: 2)
            })
            .frame(width: width, height: height)

    }
}

// BEGIN Ball Field Selection View

struct BallFieldSelectionView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
//
//    @Binding var ballFieldX: CGFloat?
//    @Binding var ballFieldY: CGFloat?
//
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Ball Field Location")
                    .font(.title)
                BallFieldView(xRel: $gameStateViewModel.ballFieldX, yRel: $gameStateViewModel.ballFieldY, bipOrder: $gameViewModel.bipOrder)
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.9)
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct BIPOrderView: View {
    
    @Binding var valueToTrack: String
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack(spacing: 0) {
                    Button {
                        valueToTrack += "\(addSuffix())1"
                    } label: {
                        Text("1")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                    Button {
                        valueToTrack += "\(addSuffix())2"
                    } label: {
                        Text("2")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                        
                    }
                    Button {
                        valueToTrack += "\(addSuffix())3"
                    } label: {
                        Text("3")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                }
                HStack(spacing: 0) {
                    Button {
                        valueToTrack += "\(addSuffix())4"
                    } label: {
                        Text("4")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                        
                    }
                    Button {
                        valueToTrack += "\(addSuffix())5"
                    } label: {
                        Text("5")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                    Button {
                        valueToTrack += "\(addSuffix())6"
                    } label: {
                        Text("6")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                }
                HStack(spacing: 0) {
                    Button {
                        valueToTrack += "\(addSuffix())7"
                    } label: {
                        Text("7")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                    Button {
                        valueToTrack += "\(addSuffix())8"
                    } label: {
                        Text("8")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                    Button {
                        valueToTrack += "\(addSuffix())9"
                    } label: {
                        Text("9")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                }
                HStack(spacing: 0) {
                    Button {
                    } label: {
                        Text(" ")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                    Button {
                    } label: {
                        Text(" ")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                    Button {
                        if valueToTrack != "" {
                            // Drop twice
                            valueToTrack = String(valueToTrack.dropLast())
                            valueToTrack = String(valueToTrack.dropLast())
                        }
                    } label: {
                        Text("Del")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                }
            }
        }
    }
    
    func addSuffix() -> String {
        return valueToTrack == "" ? "" : "-"
    }
}


struct BallFieldView: View {
    
    @Binding var xRel: CGFloat?
    @Binding var yRel: CGFloat?
    
    @Binding var bipOrder: String
    
    var body: some View {
        GeometryReader { outerGeo in
            HStack {
                VStack {
                    Text("BIP Player Order")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .border(Color.black)
                    Text("\(bipOrder)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .border(Color.black)
                    BIPOrderView(valueToTrack: $bipOrder)
                }.frame(width: outerGeo.size.width * 0.4, height: outerGeo.size.height * 0.9)
                GeometryReader { geometry in
                    
                    ZStack {
                        GameFieldImage()
                        if let x = xRel, let y = yRel {
                            Circle()
                                .size(CGSize(width: 15, height: 15))
                                .fill(Color.red)
                                .offset(x: x * geometry.size.width,
                                        y: y * geometry.size.height)
                        }
                    }.frame(width: geometry.size.width, height: geometry.size.height).border(Color.black, width: 4)
                    .coordinateSpace(name: "ballfield")
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("ballfield")).onChanged({ value in
                        xRel = min(max((value.location.x) / geometry.size.width, 0), 1)
                        yRel = min(max(value.location.y / (geometry.size.height), 0), 1)
                    }).onEnded({ _ in
                        
                    }))
                }.frame(width: outerGeo.size.width * 0.6, height: outerGeo.size.height * 0.9)
            }
        }
        
    }
}

// BEGIN EXTRA PITCH INFO VIEW

struct PitchInfoView: View {
    
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
//    @Binding var pitchVelocity: String
//    @Binding var hittingExitVelocity: String
//
//    @Binding var pitchOutcome: PitchOutcome?
//
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center) {
                VStack {
                    Text("Velocity Information")
                        .font(.title)
                    Text("\(gameStateViewModel.pitchVelocity) mph")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .padding([.leading, .trailing])
                        .border(Color.black, width: 2)
                        .keyboardType(.numberPad)
                    CalculatorView(valueToTrack: $gameStateViewModel.pitchVelocity)
                }.frame(width: geometry.size.width * 0.4, height: geometry.size.height)
                .padding()
                if gameStateViewModel.selectedOutcome?.isBIP ?? false {
                        VStack(alignment: .center) {
                            Text("Ball Field Information")
                                .font(.title)
                            Text("\(gameStateViewModel.hittingExitVelocity) mph")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .padding([.leading, .trailing])
                                .border(Color.black, width: 2)
                                .keyboardType(.numberPad)
                            CalculatorView(valueToTrack: $gameStateViewModel.hittingExitVelocity)
                        }.frame(width: geometry.size.width * 0.4, height: geometry.size.height)
                        .padding()
                }
            }.frame(maxWidth: .infinity)
        }
    }
}

struct CalculatorView: View {
    
    @Binding var valueToTrack: String
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack(spacing: 0) {
                    Button {
                        valueToTrack += "1"
                    } label: {
                        Text("1")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                    Button {
                        valueToTrack += "2"
                    } label: {
                        Text("2")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                        
                    }
                    Button {
                        valueToTrack += "3"
                    } label: {
                        Text("3")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                }
                HStack(spacing: 0) {
                    Button {
                        valueToTrack += "4"
                    } label: {
                        Text("4")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                        
                    }
                    Button {
                        valueToTrack += "5"
                    } label: {
                        Text("5")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                    Button {
                        valueToTrack += "6"
                    } label: {
                        Text("6")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                }
                HStack(spacing: 0) {
                    Button {
                        valueToTrack += "7"
                    } label: {
                        Text("7")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                    Button {
                        valueToTrack += "8"
                    } label: {
                        Text("8")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                    Button {
                        valueToTrack += "9"
                    } label: {
                        Text("9")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                }
                HStack(spacing: 0) {
                    Button {
                    } label: {
                        Text("-")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                    Button {
                        valueToTrack += "0"
                    } label: {
                        Text("0")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                    Button {
                        valueToTrack = String(valueToTrack.dropLast())
                    } label: {
                        Text("Del")
                            .frame(width: geometry.size.width * 1/3,
                                   height: geometry.size.height * 0.2)
                             .border(Color.blue, width: 3)
                    }
                }
            }
        }
    }
}
