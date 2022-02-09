//
//  GameRunnerBIPView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 8/6/21.
//

import Foundation
import SwiftUI

struct GameRunnerBIPView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    var body: some View {
        GeometryReader { geometry in
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ZStack {
                        GameFieldImage()
                        if let player = getCurrentRunner() {
                            GameRunnerDetail(name: player.lastName)
                                .frame(width: geometry.size.width * 0.12, height: geometry.size.height * 0.12, alignment: .center)
                                .position(x: geometry.size.width * getRunnerDisplayPositionX(), y: geometry.size.height * getRunnerDisplayPositionY())
                        }
                    }.frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
    }
    
    func getCurrentRunner() -> RosterMember? {
        if let player = gameViewModel.basesToUpdate[.First] {
            return player
        } else if let player = gameViewModel.basesToUpdate[.Second] {
            return player
        } else if let player = gameViewModel.basesToUpdate[.Third] {
            return player
        }
        return nil
    }
    
    func getRunnerDisplayPositionX() -> CGFloat {
        if gameViewModel.basesToUpdate.keys.contains(.First) {
            return 0.675
        } else if gameViewModel.basesToUpdate.keys.contains(.Second) {
            return 0.5
        } else if gameViewModel.basesToUpdate.keys.contains(.Third) {
            return 0.32
        }
        return 0
    }
    
    func getRunnerDisplayPositionY() -> CGFloat {
        if gameViewModel.basesToUpdate.keys.contains(.First) {
            return 0.67
        } else if gameViewModel.basesToUpdate.keys.contains(.Second) {
            return 0.455
        } else if gameViewModel.basesToUpdate.keys.contains(.Third) {
            return 0.67
        }
        return 0
    }
}

enum RunnerBIPState {
    case Advanced
    case Normal
}

struct GameRunnerBIPOptions: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    @State var runnerBIPState: RunnerBIPState = .Normal
    @State var isError: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            if let player = getCurrentRunner() {
                Text(player.lastName)
                    .font(.system(size: 45))
                    .frame(maxWidth: .infinity)
                    .padding([.top])
                Text("Runner on \(getCurrentBase().getStringShortRep())")
                    .frame(maxWidth: .infinity)
                    .padding()
                Text("Please select what happened to the player on \(getCurrentBase().getStringShortRep())")
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding([.bottom, .leading, .trailing])
                if runnerBIPState == .Normal {
                    GameRunnerMainBIPOptions(isError: $isError,
                                             runnerBIPState: $runnerBIPState)
                } else if runnerBIPState == .Advanced {
                    GameRunnerAdvancedBIPOptions(isError: $isError,
                                             runnerBIPState: $runnerBIPState)
                }
            }
        }
    }
    
    func getCurrentBase() -> Base {
        return gameViewModel.basesToUpdate.keys.contains(.First) ? .First :
        gameViewModel.basesToUpdate.keys.contains(.Second) ? .Second :
        gameViewModel.basesToUpdate.keys.contains(.Third) ? .Third :
            gameViewModel.basesToUpdate.keys.contains(.Home) ? .Home : .None
    }
    
    func getCurrentRunner() -> RosterMember? {
        if let player = gameViewModel.basesToUpdate[.First] {
            return player
        } else if let player = gameViewModel.basesToUpdate[.Second] {
            return player
        } else if let player = gameViewModel.basesToUpdate[.Third] {
            return player
        }
        return nil
    }
}

struct GameRunnerMainBIPOptions: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    @Binding var isError: Bool
    @Binding var runnerBIPState: RunnerBIPState
    
    var body: some View {
        VStack(alignment: .center) {
            if let player = getCurrentRunner() {
                Button(action: {
                    isError = false
                    runnerBIPState = .Advanced
                }, label: {
                    Text("Advanced")
                        .foregroundColor(Color.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 5)
                                )
                })
                Button(action: {
                    isError = true
                    runnerBIPState = .Advanced
                }, label: {
                    Text("Advanced on Error")
                        .foregroundColor(Color.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 5)
                                )
                })
                if let event = gameStateViewModel.getCurrentPitchAction(),
                   event.extraInfo2?.isFC ?? false {
                    Button(action: {
                        addGameAction(action: BIPOutFielderChoiceAction(eventType: .BIPOutFielderChoice,
                                    player: player))
                    }, label: {
                        Text("Out on Fielder's Choice")
                            .foregroundColor(Color.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    })
                }
                if let event = gameStateViewModel.getCurrentPitchAction(),
                   event.extraInfo2?.isDoublePlay ?? false {
                    Button(action: {
                        addGameAction(action: BIPOutDoublePlayAction(eventType: .BIPDoublePlayOut,
                                         player: player,
                                         baseAt: getCurrentBase()))
                    }, label: {
                        Text("Out in Double Play")
                            .foregroundColor(Color.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    })
                }
                Button(action: {
                    addGameAction(action: BIPOutOnBasepathAction(eventType: .BIPOutBasepath,
                                     player: player,
                                     baseAt: getCurrentBase()))
                }, label: {
                    Text("Out")
                        .foregroundColor(Color.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 5)
                                )
                })
                Button(action: {
                    removeBase()
                    runnerBIPState = .Normal
                    checkIfDone()
                }, label: {
                    Text("Nothing Occurred")
                        .foregroundColor(Color.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red, lineWidth: 5)
                                )
                })
                Button(action: {
                    gameStateViewModel.mainViewState = .AddPitch
                }, label: {
                    Text("Back")
                        .foregroundColor(Color.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red, lineWidth: 5)
                                )
                })
            }
        }
    }
    func checkIfDone() {
        if gameViewModel.basesToUpdate.count == 0 {
            GameEngine.processEvent(gameViewModel: gameViewModel,
                                    gameState: gameStateViewModel)
            gameStateViewModel.mainViewState = .Field
        }
    }
    func getCurrentRunner() -> RosterMember? {
        if let player = gameViewModel.basesToUpdate[.First] {
            return player
        } else if let player = gameViewModel.basesToUpdate[.Second] {
            return player
        } else if let player = gameViewModel.basesToUpdate[.Third] {
            return player
        }
        return nil
    }
    
    func getCurrentBase() -> Base {
        return gameViewModel.basesToUpdate.keys.contains(.First) ? .First :
            gameViewModel.basesToUpdate.keys.contains(.Second) ? .Second :
            gameViewModel.basesToUpdate.keys.contains(.Third) ? .Third :
            gameViewModel.basesToUpdate.keys.contains(.Home) ? .Home : .None
    }
    
    func removeBase() {
        gameViewModel.basesToUpdate.removeValue(forKey: getCurrentBase())
    }
    
    func addGameAction(action: GameAction) {
        gameStateViewModel.event.actionsPerformed.append(action)
        removeBase()
        runnerBIPState = .Normal
        checkIfDone()
    }
}

struct GameRunnerAdvancedBIPOptions: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    @Binding var isError: Bool
    @Binding var runnerBIPState: RunnerBIPState
    
    var body: some View {
        VStack(alignment: .center) {
            List {
                if let player = getCurrentRunner() {
                    Button(action: {
                        addGameAction(withPlayer: player, withBase: .Second)
                    }, label: {
                        Text("Advanced to 2nd")
                            .foregroundColor(Color.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    })
                    Button(action: {
                        addGameAction(withPlayer: player, withBase: .Third)
                    }, label: {
                        Text("Advanced to 3rd")
                            .foregroundColor(Color.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    })
                    Button(action: {
                        addGameAction(withPlayer: player, withBase: .Home)
                    }, label: {
                        Text("Advanced to Home")
                            .foregroundColor(Color.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    })
                    Button(action: {
                        runnerBIPState = .Normal
                    }, label: {
                        Text("Back")
                            .foregroundColor(Color.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.red, lineWidth: 5)
                                    )
                    })
                }
            }
        }
    }
    
    func addGameAction(withPlayer player: RosterMember, withBase base: Base) {
        gameStateViewModel.event.actionsPerformed.append(BIPAdvanceAction(eventType: .BIPAdvance,
                                           player: getCurrentRunner(),
                                           baseAt: getCurrentBase(),
                                           baseGoingTo: base))
    
        removeBase()
        runnerBIPState = .Normal
        checkIfDone()
    }
    
    func checkIfDone() {
        if gameViewModel.basesToUpdate.count == 0 {
            GameEngine.processEvent(gameViewModel: gameViewModel, gameState: gameStateViewModel)
            gameStateViewModel.mainViewState = .Field
        }
    }
    func getCurrentRunner() -> RosterMember? {
        if let player = gameViewModel.basesToUpdate[.First] {
            return player
        } else if let player = gameViewModel.basesToUpdate[.Second] {
            return player
        } else if let player = gameViewModel.basesToUpdate[.Third] {
            return player
        }
        return nil
    }
    
    func getCurrentBase() -> Base {
        return gameViewModel.basesToUpdate.keys.contains(.First) ? .First :
        gameViewModel.basesToUpdate.keys.contains(.Second) ? .Second :
        gameViewModel.basesToUpdate.keys.contains(.Third) ? .Third :
            gameViewModel.basesToUpdate.keys.contains(.Home) ? .Home : .None
    }
    
    func removeBase() {
        gameViewModel.basesToUpdate.removeValue(forKey: getCurrentBase())
    }
}
