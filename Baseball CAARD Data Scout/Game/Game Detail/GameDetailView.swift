//
//  GameDetailView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/5/21.
//

import SwiftUI

struct GameDetailMainView: View {
    
    @StateObject var gameViewModel: GameViewModel = GameViewModel()
    @StateObject var gameStateViewModel: GameStateViewModel = GameStateViewModel()
    @StateObject var gameStaticViewModel: GameStaticViewModel = GameStaticViewModel()
    
    @State var detailState: GameDetailState = .Detail
    var game: Game
    
    @State var firstLoad: Bool = true
    var body: some View {
        if detailState == .Detail {
            GameDetailView(game: game, gameState: $detailState)
                .onAppear {
                    if firstLoad {
                        gameViewModel.loadInitialGameInformation(game: game) { homeLineup in
                            self.gameStateViewModel.homeLineup = homeLineup
                        } awayLineupComp: { awayLineup in
                            self.gameStateViewModel.awayLineup = awayLineup
                        }
                        firstLoad = false
                    }
                    
                }.navigationBarHidden(true)
        } else if detailState == .Game {
            GameView()
                .environmentObject(gameViewModel)
                .environmentObject(gameStateViewModel)
                .environmentObject(gameStaticViewModel)
                .onAppear {
                    if firstLoad {
                        gameViewModel.loadInitialGameInformation(game: game) { homeLineup in
                            self.gameStateViewModel.homeLineup = homeLineup
                        } awayLineupComp: { awayLineup in
                            self.gameStateViewModel.awayLineup = awayLineup
                        }
                        firstLoad = false
                    }
                    
                }.navigationBarHidden(true)
        } else if detailState == .Lineup {
            GameEditorLineupView()
            .environmentObject(gameViewModel)
            .environmentObject(gameStateViewModel)
            .environmentObject(gameStaticViewModel)
            .navigationBarItems(trailing: HStack {
                Button(action: {
                    self.detailState = .Detail
                }, label: {
                    Text("Back")
                        .padding()
                })
                Button(action: {
                    self.gameViewModel.homeLineup = self.gameStateViewModel.homeLineup
                    self.gameViewModel.awayLineup = self.gameStateViewModel.awayLineup
                    self.gameViewModel.saveLineups()
                }, label: {
                    Text("Save")
                        .padding()
                })
                Button(action: {
                    gameStateViewModel.teamEditing = getOtherTeam()
                }, label: {
                    Text("Switch to \(getOtherTeam().toString()) Team")
                        .padding()
                })
            }).onAppear {
                if firstLoad {
                    gameViewModel.loadInitialGameInformation(game: game) { homeLineup in
                        self.gameStateViewModel.homeLineup = homeLineup
                    } awayLineupComp: { awayLineup in
                        self.gameStateViewModel.awayLineup = awayLineup
                    }
                    firstLoad = false
                }
                
            }
        } else if detailState == .Report {
            ReportMainView(detailState: $detailState)
                .environmentObject(gameViewModel)
                .environmentObject(gameStateViewModel)
                .environmentObject(gameStaticViewModel)
        }
    }
    
    
    func getOtherTeam() -> Team {
        return gameStateViewModel.teamEditing == .Away ? .Home : .Away
    }
}

struct GameDetailView: View {
    
    @StateObject var gameViewModel: GameViewModel = GameViewModel()
    @StateObject var gameStateViewModel: GameStateViewModel = GameStateViewModel()
    @StateObject var gameStaticViewModel: GameStaticViewModel = GameStaticViewModel()
        
    var game: Game
    @Binding var gameState: GameDetailState
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Text("\(game.awayTeamName) vs\n\(game.homeTeamName)")
                    .font(.system(size: 50))
                    .padding()
                Text("\(game.gameStartHour):\(game.gameStartMinute) PM 9/4/2021")
                    .font(.system(size: 20))
                    .padding()
                Spacer()
//                NavigationLink(destination:
//                                GameEditorLineupView()
//                                .environmentObject(gameViewModel)
//                                .environmentObject(gameStateViewModel)
//                                .environmentObject(gameStaticViewModel)
//                                .navigationBarItems(trailing: HStack {
//                                    Button(action: {
//                                        self.gameViewModel.homeLineup = self.gameStateViewModel.homeLineup
//                                        self.gameViewModel.awayLineup = self.gameStateViewModel.awayLineup
//                                        self.gameViewModel.saveLineups()
//                                    }, label: {
//                                        Text("Save")
//                                            .padding()
//                                    })
//                                    Button(action: {
//                                        gameStateViewModel.teamEditing = getOtherTeam()
//                                    }, label: {
//                                        Text("Switch to \(getOtherTeam().toString()) Team")
//                                            .padding()
//                                    })
//                                })
//
//                ) {
//                    Text("Edit Lineups")
//                        .foregroundColor(.red)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .border(Color.red, width: 5)
//                        .padding()
//                }
                Button {
                    self.gameState = .Lineup
                } label: {
                    Text("Edit Lineups")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .border(Color.red, width: 5)
                        .padding()
                }
                Button {
                    self.gameState = .Report
                } label: {
                    Text("View Game Reports")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .border(Color.red, width: 5)
                        .padding()
                }
                Button {
                    self.gameState = .Game
                } label: {
                    Text("Start Recording")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .border(Color.red, width: 5)
                        .padding()
                }

//                NavigationLink(destination: GameView()
//                                .environmentObject(gameViewModel)
//                                .environmentObject(gameStateViewModel)
//                                .environmentObject(gameStaticViewModel)) {
//                    Text("Start Recording")
//                        .foregroundColor(.red)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .border(Color.red, width: 5)
//                        .padding()
//                }
            }
        }
    }
}

enum GameDetailState {
    case Detail
    case Game
    case Lineup
    case Report
}
