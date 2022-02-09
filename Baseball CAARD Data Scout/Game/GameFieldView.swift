//
//  GameFieldView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 7/30/21.
//

import Foundation
import SwiftUI

// BEGIN Game Field View
struct GameFieldView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack {
                    GameFieldImage()
                    GameRunnerView()
                    GamePitchButton()
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.6)
                        .environmentObject(gameStateViewModel)
                }.frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
       
    }
}

struct GameStyleOptions: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
    
    var body: some View {
            ForEach(0..<gameStaticViewModel.style.count, id: \.self) { index in
                Button {
                    gameViewModel.style = gameStaticViewModel.style[index]
                } label: {
                    Text("\(gameStaticViewModel.style[index].getLongName())")
                        .foregroundColor(getColor(index: index))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(getColor(index: index), lineWidth: 5)
                                )
                }
            }
        
    }
    
    func getColor(index: Int) -> Color {
        return gameViewModel.style == gameStaticViewModel.style[index] ? Color.red :
            Color.blue
    }
}

struct GameHandOptions: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
    
    @Binding var handToTrack: Hand?
    
    var body: some View {
            ForEach(0..<gameStaticViewModel.hands.count, id: \.self) { index in
                Button {
                    handToTrack = gameStaticViewModel.hands[index]
                } label: {
                    Text("\(gameStaticViewModel.hands[index].getShortName())")
                        .foregroundColor(getColor(index: index))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(getColor(index: index), lineWidth: 5)
                                )
                }
        }
    }
    
    func getColor(index: Int) -> Color {
        return handToTrack == gameStaticViewModel.hands[index] ? Color.red :
            Color.blue
    }
}

struct GameFieldImage: View {
    var body: some View {
        Image("baseball-field")
            .resizable()
    }
}

struct GamePitchButton: View {
        
    @EnvironmentObject var gameStateViewModel: GameStateViewModel

    @State var viewOptions: Bool = false
    
    var body: some View {
        Button(action: {
            self.viewOptions = true
            gameStateViewModel.mainViewState = .StrikeZone
        }, label: {
            Text("Add Pitch")
        })
        .padding()
        .background(Color.white)
        .border(Color.black)
    }
}

struct GameOptionsView: View {
        
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    GeometryReader { inneerGeo in
                        VStack(spacing: 0) {
                            Section(header: Text("Pitch Thrown")
                                        .frame(width: inneerGeo.size.width,
                                               height: inneerGeo.size.height * 0.05).border(Color.black)) {
                                List {
                                    ForEach(gameViewModel.pitcher?.pitches ??
                                                gameStaticViewModel.pitches, id: \.self) { pitch in
                                        HStack {
                                            GameOption(text: pitch.longName, width: inneerGeo.size.width * 0.9, height: inneerGeo.size.height * 0.1, isSelected: pitch == gameStateViewModel.selectedPitch)
                                        }.contentShape(Rectangle()).onTapGesture {
                                            gameStateViewModel.selectedPitch = pitch
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                    GeometryReader { inneerGeo in
                        VStack(spacing: 0) {
                            
                            Section(header: Text("Pitch Outcome")
                                        .frame(width: inneerGeo.size.width,
                                               height: inneerGeo.size.height * 0.05)
                                        .border(Color.black)) {
                                List {
                                    ForEach(gameStaticViewModel.outcomes, id: \.self) { outcome in
                                        if !outcome.isDropThird || (gameViewModel.numberStrikes == 2 &&
                                                                        gameViewModel.numberOuts < 2 &&
                                                                        gameViewModel.playerOnFirst == nil) {
                                            HStack {
                                                GameOption(text: outcome.longName,
                                                           width: inneerGeo.size.width * 0.9,
                                                           height: inneerGeo.size.height * 0.1,
                                                           isSelected: outcome == gameStateViewModel.selectedOutcome)
                                            }.contentShape(Rectangle()).onTapGesture {
                                                gameStateViewModel.selectedOutcome = outcome
                                                gameStateViewModel.extraInfo1 = outcome.defaultExtraInfo1
                                                gameStateViewModel.extraInfo2 = nil
                                                gameStateViewModel.extraInfo3 = nil
                                            
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    GeometryReader { inneerGeo in
                        VStack(spacing: 0) {
                            Section(header: Text("Extra Info")
                                        .frame(width: inneerGeo.size.width,
                                               height: inneerGeo.size.height * 0.05)
                                        .border(Color.black)) {
                                if gameStateViewModel.selectedOutcome != nil,
                                   let options = gameStateViewModel.selectedOutcome?.specificOptions {
                                    List {
                                        ForEach(options, id: \.self) { option in
                                            HStack {
                                                GameOption(text: option.longName, width: inneerGeo.size.width * 0.9, height: inneerGeo.size.height * 0.1, isSelected: gameStateViewModel.extraInfo1 == option)
                                            }.contentShape(Rectangle()).onTapGesture {
                                                gameStateViewModel.extraInfo1 = option
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if gameStateViewModel.selectedOutcome != nil, let specialExtras = gameStateViewModel.selectedOutcome?.extraInfoOption {
                        GeometryReader { inneerGeo in
                            VStack(spacing: 0) {
                                Section(header: Text("Extra Info")
                                            .frame(width: inneerGeo.size.width,
                                                   height: inneerGeo.size.height * 0.05)
                                            .border(Color.black)) {
                                    List {
                                        ForEach(specialExtras, id: \.self) { option in
                                            HStack {
                                                GameOption(text: option.longName, width: inneerGeo.size.width * 0.9, height: inneerGeo.size.height * 0.1, isSelected: gameStateViewModel.extraInfo2 == option)
                                            }.contentShape(Rectangle()).onTapGesture {
                                                gameStateViewModel.extraInfo2 = option
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .background(Color.white)
        }
    }
}

struct GameOption: View {
    
    var text: String
    var width: CGFloat
    var height: CGFloat
    
    var isSelected: Bool
    
    var body: some View {
        HStack {
            Button(action: {}, label: {
                Text(text)
                    .foregroundColor(getDiplayColor())
                    .multilineTextAlignment(.center)
                    .frame(width: width, height: height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(getDiplayColor(), lineWidth: 5)
                            )
            })
            
        }
    }
    
    func getDiplayColor() -> Color {
        return isSelected ? Color.red : Color.blue
    }
}
