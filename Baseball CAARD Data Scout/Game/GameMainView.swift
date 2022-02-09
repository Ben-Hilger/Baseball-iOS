//
//  GameMainView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 7/30/21.
//

import Foundation
import SwiftUI

struct GameMainView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel

    var body: some View {
        if gameStateViewModel.mainViewState == .Field {
            GameFieldViewMain()
                .environmentObject(gameViewModel)
                .environmentObject(gameStateViewModel)
        } else if gameStateViewModel.mainViewState == .AddPitch ||
                    gameStateViewModel.mainViewState == .StrikeZone ||
                    gameStateViewModel.mainViewState == .BallField ||
                    gameStateViewModel.mainViewState == .BallVelo {
            GameFieldAddPitchViewMain()
                .environmentObject(gameViewModel)
                .environmentObject(gameStateViewModel)
        } else if gameStateViewModel.mainViewState == .StrikeZone {
            StrikeZoneViewMain()
                .environmentObject(gameViewModel)
                .environmentObject(gameStateViewModel)
        } else if gameStateViewModel.mainViewState == .BallField {
            BallFieldViewMain()
                .environmentObject(gameViewModel)
                .environmentObject(gameStateViewModel)
        } else if gameStateViewModel.mainViewState == .Lineup {
            GameEditorLineupViewMain()
                  .environmentObject(gameViewModel)
                  .environmentObject(gameStateViewModel)
        } else if gameStateViewModel.mainViewState == .BIP {
            GameRunnerBIPMainView()
                .environmentObject(gameViewModel)
                .environmentObject(gameStateViewModel)
        } else if gameStateViewModel.mainViewState == .PAEditor {
            GamePAEditorMainView()
                .environmentObject(gameViewModel)
                .environmentObject(gameStateViewModel)
                .environmentObject(gameStaticViewModel)
        }
    }
}

struct GameFieldViewMain: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    GameFieldView()
                        .frame(width:
                                geometry.size.width * (gameStateViewModel.baseSelected == .None ? 1 : 1),//0.7),
                               height: geometry.size.height * (gameStateViewModel.mainViewState == .Field &&
                                                                gameStateViewModel.extraInfo1 == nil ? 1 : 0.9))
                        .environmentObject(gameViewModel)
                        .environmentObject(gameStateViewModel)
                }
            }
        }
    }
}

struct GameFieldAddPitchViewMain: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if gameStateViewModel.mainViewState == .AddPitch {
                    GameOptionsView()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
                } else if gameStateViewModel.mainViewState == .StrikeZone {
                    StrikeZoneSelectionView()
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
                } else if gameStateViewModel.mainViewState == .BallField {
                    BallFieldSelectionView()
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
                } else if gameStateViewModel.mainViewState == .BallVelo {
                    PitchInfoView()
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.9)

                }
                AddPitchAuxView()
                    .environmentObject(gameViewModel)
                    .environmentObject(gameStateViewModel)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.1)
                    .border(Color.black)
            }
        }
    }
}

struct StrikeZoneViewMain: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                StrikeZoneSelectionView()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
                StrikeZoneAuxView()
                    .environmentObject(gameViewModel)
                    .environmentObject(gameStateViewModel)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.1)
                    .border(Color.black)
            }
        }

    }
}

struct BallFieldViewMain: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                BallFieldSelectionView()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
                BallFieldAuxView()
                    .environmentObject(gameViewModel)
                    .environmentObject(gameStateViewModel)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.1)
                    .border(Color.black)
            }
        }
    }
}

struct GameEditorLineupViewMain: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
//    @Binding var teamEditing: Team
//
//    @Binding var homeLineup: [LineupPerson]
//    @Binding var homeRoster: [RosterMember]
//
//    @Binding var awayLineup: [LineupPerson]
//    @Binding var awayRoster: [RosterMember]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                GameEditorLineupView()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
                GameEditorLineupViewAuxOptions()
                    .environmentObject(gameViewModel)
                    .environmentObject(gameStateViewModel)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.1)
                    .border(Color.black)
            }
        }
    }
}

struct GameRunnerBIPMainView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                GameRunnerBIPView()
                    .frame(width: geometry.size.width,
                           height: geometry.size.height * 0.9)
             
            }
        }
    }
}

struct GamePAEditorMainView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                PAEditorMainView()
                    .frame(width: geometry.size.width,
                           height: geometry.size.height * 0.9)
                PAAuxOptionsView()
                    .frame(width: geometry.size.width,
                           height: geometry.size.height * 0.1)
                    .border(Color.black)
            }
        }
    }
}

enum GameMainViewState: Int {
    case Field = 0
    case StrikeZone = 1
    case AddPitch = 2
    case BallField = 3
    case Lineup = 4
    case BIP = 5
    case BallVelo = 6
    case PAEditor = 7
}
