//
//  GameView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 7/26/21.
//

import SwiftUI

// BEGIN Game View

struct GameView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
        
    @State var firstLoad: Bool = true

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                GameScoreCardView()
                    .padding(.top)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.15, alignment: .center)
                    .border(Color.black)
                    .environmentObject(gameViewModel)
                GameSituationView()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.07, alignment: .center)
                    .border(Color.black)
                    .environmentObject(gameViewModel)
                    .environmentObject(gameStateViewModel)
                HStack(spacing: 0) {
                    GameMainView()
                        .frame(width: geometry.size.width *
                                (gameStateViewModel.mainViewState == .Lineup ?  1 : 0.7), height: geometry.size.height * 0.78)
                        .border(Color.black)
                        .environmentObject(gameViewModel)
                        .environmentObject(gameStateViewModel)
                        .environmentObject(gameStaticViewModel)
                    if gameStateViewModel.mainViewState == .Lineup {
                      EmptyView()
                    } else if gameStateViewModel.mainViewState == .BIP {
                        GameRunnerBIPOptions()
                            .frame(width: geometry.size.width * 0.3
                                   , height: geometry.size.height * 0.78)
                            .border(Color.black)
                            .environmentObject(gameStateViewModel)
                            .environmentObject(gameViewModel)
                    } else if gameStateViewModel.baseSelected == .None {
                        GameEditorView()
                            .frame(width: geometry.size.width * 0.3
                                   , height: geometry.size.height * 0.78)
                            .border(Color.black)
                            .environmentObject(gameStateViewModel)
                            .environmentObject(gameViewModel)
                    } else {
                        GameRunnerOptions()
                            .frame(width: geometry.size.width * 0.3
                                   , height: geometry.size.height * 0.78)
                            .border(Color.black)
                            .environmentObject(gameStateViewModel)
                            .environmentObject(gameViewModel)
                    }
                }.frame(width: geometry.size.width, height: geometry.size.height * 0.78, alignment: .center)
            }
        }.navigationBarHidden(true)
        .onAppear {
            if firstLoad {
                gameViewModel.startGame()
                gameStateViewModel.homeLineup = gameViewModel.homeLineup
                gameStateViewModel.awayLineup = gameViewModel.awayLineup
                firstLoad = false
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .previewLayout(.fixed(width: 1024, height: 768))
    }
}

// BEGIN Game Information View

struct GameSituationView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    @State var showingPitchingOptions: Bool = false
    @State var showingHittingOptions: Bool = false

    
    var body: some View {
        GeometryReader { geomtery in
            HStack(spacing: 0) {
                if let pitcher = gameViewModel.pitcher {
                    GamePlayerInformationView(name: gameViewModel.pitcher?.getFullName() ?? "Pitcher Name", number: 23, position: "P", numberPitches: gameViewModel.getNumberOfPitches(forPitcher: pitcher), pitchingHand: gameViewModel.pitchingHand ?? .Right, pitchingStyle: gameViewModel.style ?? .Stretch)
                        .frame(width: geomtery.size.width * 0.45,
                               height: geomtery.size.height)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingPitchingOptions = true
                        }
                        .actionSheet(isPresented: $showingPitchingOptions, content: {
                            ActionSheet(title: Text("Pitcher Options"), message: nil, buttons: getPitcherOptionButtons())
                        })
                }
                Text("vs")
                    .font(.system(size: 20))
                    .padding()
                    .frame(width: geomtery.size.width * 0.1,
                           height: geomtery.size.height)
                GamePlayerInformationHitterView(name: gameViewModel.hitter?.getFullName() ?? "Hitter Name", position: "H", number: 23, hittingHand: gameViewModel.hitterHand ?? .Right)
                    .frame(width: geomtery.size.width * 0.45,
                           height: geomtery.size.height)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingHittingOptions = true
                    }
                    .actionSheet(isPresented: $showingHittingOptions, content: {
                        ActionSheet(title: Text("Hitter Options"), message: nil, buttons: getHitterOptionButtons())
                    })
            }
        }
    }
    
    func getPitcherOptionButtons() -> [ActionSheet.Button] {
        var options: [ActionSheet.Button] = []
        
        options.append(.default(Text("Change Pitcher")) {
            
        })
        
        return options
    }
    
    func getHitterOptionButtons() -> [ActionSheet.Button] {
        var options: [ActionSheet.Button] = []
        
        options.append(.default(Text("Pinch Hitter")) {
            
        })
        
        return options
    }
}

struct GamePlayerInformationView: View {
    
    var name: String
    var number: Int
    var position: String
    
    var numberPitches: Int
    var pitchingHand: Hand
    var pitchingStyle: PitchingStyle
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("\(name) #\(number)")
                    Text("(\(pitchingStyle.getLongName()))")
                        .padding()
                    Spacer()
                    Text("\(numberPitches) Pitch\(numberPitches == 1 ? "" : "es")")
                    Text("\(pitchingHand.getShortName())P")
                        .padding()
                }.padding()
                    .frame(width: geometry.size.width,
                        height: geometry.size.height,
                        alignment: .center)
                .border(Color.black)
//                Text(position)
//                    .frame(width: geometry.size.width * 0.2,
//                           height: geometry.size.height,
//                           alignment: .center)
//                    .border(Color.black)
            }.frame(width: geometry.size.width, height: geometry.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
        
    }
}


struct GamePlayerInformationHitterView: View {
    
    var name: String
    var position: String
    var number: Int
    var hittingHand: Hand
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Text("\(name) #\(number)")
                    .frame(maxWidth: .infinity)
                Spacer()
                Text("\(hittingHand.getShortName())H")
                    .frame(maxWidth: .infinity)
//                Text(position)
//                    .frame(width: geometry.size.width * 0.2,
//                           height: geometry.size.height,
//                           alignment: .center)
//                    .border(Color.black)
            }.frame(width: geometry.size.width, height: geometry.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .border(Color.black)
        }
        
    }
}

// BEGIN Game Scorecard View

struct GameScoreCardView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 0) {
                CountView()
                    .frame(width: geometry.size.width * 0.2, height: geometry.size.height, alignment: .center)
                    .environmentObject(gameViewModel)
                GameScoreBreakdownView()
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height, alignment: .center)
            }
        }
    }
}

struct CountView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("Balls")
                Image(systemName:
                        gameViewModel.numberBalls >= 1 ? "circle.fill" : "circle")
                Image(systemName:
                        gameViewModel.numberBalls >= 2 ? "circle.fill" : "circle")
                Image(systemName:
                        gameViewModel.numberBalls >= 3 ? "circle.fill" : "circle")
            }
            HStack {
                Text("Strikes")
                Image(systemName:
                        gameViewModel.numberStrikes >= 1 ? "circle.fill" : "circle")
                Image(systemName:
                        gameViewModel.numberStrikes >= 2 ? "circle.fill" : "circle")
            }
            HStack {
                Text("Out")
                Image(systemName:
                        gameViewModel.numberOuts >= 1 ? "circle.fill" : "circle")
                Image(systemName:
                        gameViewModel.numberOuts >= 2 ? "circle.fill" : "circle")
            }
        }
    }
}

// BEGIN Game Settings View

struct GameSettingsView: View {
    var body: some View  {
        Image(systemName: "gear")
    }
}

// BEGIN ScoreBreakdown View

struct GameScoreBreakdownView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var inningScoreWidth: CGFloat = 0.08
    var inningScoreHeight: CGFloat = 0.3
   @State var numInnings: Int = 9
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: nil) {
                HStack(spacing: nil) {
                    GameScoreBreakdownTeamName(teamName: "Team")
                        .frame(width: geometry.size.width * inningScoreWidth * 3, height: geometry.size.height * inningScoreHeight)
                        .border(Color.black)
                        .background(Color.gray)
                    ForEach(1...numInnings, id: \.self) { value in
                        GameScoreBreakdownInningScore(score: value)
                            .frame(width: geometry.size.width * inningScoreWidth, height: geometry.size.height * inningScoreHeight)
                            .border(Color.black)
                            .background(isInInning(inning: value) ? Color.red : Color.gray)
                    }
                }
                HStack(spacing: nil) {
                    GameScoreBreakdownTeamName(teamName: "Miami Redhawks")
                        .frame(width: geometry.size.width * inningScoreWidth * 3, height: geometry.size.height * inningScoreHeight)
                        .border(Color.black)
                        .background(Color.gray)
                    ForEach(1...numInnings, id: \.self) { value in
                        GameScoreBreakdownInningScore(score: gameViewModel.inningTotals["\(value + (value - 1))"] ?? 0)
                            .frame(width: geometry.size.width * inningScoreWidth, height: geometry.size.height * inningScoreHeight)
                            .border(Color.black)
                    }
                }
                HStack(spacing: nil) {
                    GameScoreBreakdownTeamName(teamName: "Miami Redhawks")
                        .frame(width: geometry.size.width * inningScoreWidth * 3, height: geometry.size.height * inningScoreHeight)
                        .border(Color.black)
                        .background(Color.gray)
                    ForEach(1...numInnings, id: \.self) { value in
                        GameScoreBreakdownInningScore(score: gameViewModel.inningTotals["\(value*2)    "] ?? 0)
                            .frame(width: geometry.size.width * inningScoreWidth, height: geometry.size.height * inningScoreHeight)
                            .border(Color.black)
                    }
                }
            }
        }
    }
    
    func isInInning(inning: Int) -> Bool {
        return inning + (inning - 1) == gameViewModel.halfInning
            || inning * 2 == gameViewModel.halfInning
    }
}

struct GameScoreBreakdownTeamName:  View {
    
    var teamName: String
    
    var body: some View {
        Text(teamName)
    }
}

struct GameScoreBreakdownInningScore: View {
    
    var score: Int
    
    var body: some View {
        Text(String(score))
    }
}

// BEGIN Game Editor View

struct GameEditorView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    var body: some View {
        TabView {
            GameLineupView()
                .tabItem { Text("Lineup") }
            GameSettingsEditorView()
                .tabItem { Text("Settings") }
            HistoryListView()
                .tabItem { Text("Events") }
        }
    }
}

struct GameSettingsEditorView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    var body: some View {
        List {
            Text("Emergency Functions")
                .frame(maxWidth: .infinity)
                .padding()
                .border(Color.black, width: 3)
            Group {
                Button {
                    gameStateViewModel.mainViewState = .PAEditor
                } label: {
                    Text("PA Editor")
                        .foregroundColor(Color.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red, lineWidth: 5)
                                )
                }
                Button {
                    gameViewModel.undo()
                } label: {
                    Text("Undo")
                        .foregroundColor(Color.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red, lineWidth: 5)
                                )
                }
                Button {
                    gameViewModel.undo()
                } label: {
                    Text("Undo")
                        .foregroundColor(Color.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red, lineWidth: 5)
                                )
                }
                Button {
                    gameViewModel.resetCount()
                } label: {
                    Text("Reset Count")
                        .foregroundColor(Color.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red, lineWidth: 5)
                                )
                }
                Button {
                    gameViewModel.clearBases()
                } label: {
                    Text("Clear Bases")
                        .foregroundColor(Color.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red, lineWidth: 5)
                                )
                }
                Text("Edit Strike Count")
                    .frame(maxWidth: .infinity)
                    .padding()
                    Button {
                        gameViewModel.numberStrikes += 1
                    } label: {
                        Text("+")
                            .foregroundColor(Color.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    }
                    Button {
                        gameViewModel.numberStrikes -= 1
                    } label: {
                        Text("-")
                            .foregroundColor(Color.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    }
            }
           
            Group {
                Text("Edit Ball Count")
                    .frame(maxWidth: .infinity)
                    .padding()
                    Button {
                        gameViewModel.numberBalls += 1
                    } label: {
                        Text("+")
                            .foregroundColor(Color.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    }
                    Button {
                        gameViewModel.numberBalls -= 1
                    } label: {
                        Text("-")
                            .foregroundColor(Color.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    }
            }
            Group {
                Text("Edit Out Count")
                    .frame(maxWidth: .infinity)
                    .padding()
                    Button {
                        gameViewModel.numberOuts += 1
                    } label: {
                        Text("+")
                            .foregroundColor(Color.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    }
                    Button {
                        gameViewModel.numberOuts -= 1
                    } label: {
                        Text("-")
                            .foregroundColor(Color.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    }
            }
            Text("Edit Current Hitter")
                .frame(maxWidth: .infinity)
                .padding()
                Button {
                    gameViewModel.goToNextHitter()
                } label: {
                    Text("+")
                        .foregroundColor(Color.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 5)
                                )
                }
                Button {
                    gameViewModel.revertOneHitter()
                } label: {
                    Text("-")
                        .foregroundColor(Color.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 5)
                                )
                }
            Group {
                GameStyleOptions()
                Text("Pitching Hand")
                    .frame(maxWidth: .infinity)
                    .padding()
                GameHandOptions(handToTrack: $gameViewModel.pitchingHand)
                Text("Hitting Hand")
                    .frame(maxWidth: .infinity)
                    .padding()
                GameHandOptions(handToTrack: $gameViewModel.hitterHand)
                Text("Inning")
                    .frame(maxWidth: .infinity)
                    .padding()
                    Button {
                        gameViewModel.halfInning += 1
                        gameViewModel.switchSides()
                    } label: {
                        Text("+")
                            .foregroundColor(Color.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    }
                    Button {
                        gameViewModel.halfInning -= 1
                        gameViewModel.switchSides()
                    } label: {
                        Text("-")
                            .foregroundColor(Color.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    }
                }
            }
            
            
    }
}

// BEGIN Mobile Phone Aux View

struct AuxView: View {
    
    @State var pitchVelo: String = ""
    
    @State var xPos: CGFloat? = nil
    @State var yPos: CGFloat? = nil
    
    var body: some View {
        GeometryReader { geometry in
                VStack {
                    Text("Auxiliary View")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 30))
                    Text("Pitch #1")
                    Text("Pitch Information")
                    TextField("Enter Pitch Velo", text: $pitchVelo)
                        // .padding()
                        .border(Color.black)
                    TextField("Enter Hitting Velo", text: $pitchVelo)
                        // .padding()
                        .border(Color.black)
                    Text("Strike Zone Information")
                    ZStack {
                        // StrikeZoneView()
                    }
                    Button(action: {}, label: {
                        Text("Add Pitch").frame(maxWidth: .infinity)
                            .padding([.top, .bottom])
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    })
                    Button(action: {}, label: {
                        Text("Skip Pitch").frame(maxWidth: .infinity)
                            .padding([.top, .bottom])
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    })
                }.padding()
            }
        }
    }
