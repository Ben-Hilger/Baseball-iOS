//
//  GameRunnerView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 8/1/21.
//

import Foundation
import SwiftUI

struct GameRunnerView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    var body: some View {
        GeometryReader { geometry in
            if let player = gameViewModel.playerOnFirst {
                GameRunnerDetail(name: player.lastName)
                    .frame(width: geometry.size.width * 0.12, height: geometry.size.height * 0.12, alignment: .center)
                    .position(x: geometry.size.width * 0.675, y: geometry.size.height * 0.67)
                    .onTapGesture {
                        gameStateViewModel.baseSelected = .First
                        gameStateViewModel.runnerState = .Selected
                    }
            }
            if let player = gameViewModel.playerOnSecond {
                GameRunnerDetail(name: player.lastName)
                    .frame(width: geometry.size.width * 0.12, height: geometry.size.height * 0.12, alignment: .center)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.455)
                    .onTapGesture {
                        gameStateViewModel.baseSelected = .Second
                        gameStateViewModel.runnerState = .Selected
                    }
            }
            if let player = gameViewModel.playerOnThird {
                GameRunnerDetail(name: player.lastName)
                    .frame(width: geometry.size.width * 0.12, height: geometry.size.height * 0.12, alignment: .center)
                    .position(x: geometry.size.width * 0.32, y: geometry.size.height * 0.67)
                    .onTapGesture {
                        gameStateViewModel.baseSelected = .Third
                        gameStateViewModel.runnerState = .Selected
                    }
            }
        }
    }
}

struct GameRunnerDetail: View {
    
    var name: String
    var number: Int = 23
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(name)
                    .font(.system(size: 25))
                Text("#\(number)")
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .cornerRadius(15).background(Color.red).border(Color.black, width: 2)
        }
        
    }
}

struct GameRunnerOptions: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateModel: GameStateViewModel

    var body: some View {
        VStack {
            if let player = gameViewModel.getPlayerAtBase(base: gameStateModel.baseSelected) {
                Text(player.lastName)
                    .font(.system(size: 45))
                    .frame(maxWidth: .infinity)
                    .padding([.top])
                Text("Runner on \(gameStateModel.baseSelected.getStringShortRep())")
                    .frame(maxWidth: .infinity)
                    .padding([.bottom])
            }
            if gameStateModel.runnerState == .Selected {
                GameRunnerSelectedView()
            } else if gameStateModel.runnerState == .Pickoff {
                GameRunnerPickoffView()
            } else if gameStateModel.runnerState == .Steal {
                GameRunnerStealView()
            } else if gameStateModel.runnerState == .Advance {
                GameRunnerAdvanceView()
            }
        }
    }
}

struct GameRunnerPickoffView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            List {
                Button(action: {
                    gameStateViewModel.event.actionsPerformed.append(PickoffThrowAction(eventType: .PickoffThrow))
                    GameEngine.processEvent(gameViewModel: gameViewModel, gameState: gameStateViewModel)
                    gameStateViewModel.resetRunnerState()
                }, label: {
                    Text("Still at \(gameStateViewModel.baseSelected.getStringShortRep())")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 5)
                            )
                })
                Button(action: {
                    if let player = gameViewModel.getPlayerAtBase(base: gameStateViewModel.baseSelected) {
                        gameStateViewModel.event.actionsPerformed.append(PickoffAdvanceAction(
                                                                            eventType: .PickoffAdvance,
                                                                            player: player,
                                                                            baseAt: gameStateViewModel.baseSelected,
                                                                            baseGoingTo: getNextBase()))
                        GameEngine.processEvent(gameViewModel: gameViewModel, gameState: gameStateViewModel)
                        gameStateViewModel.resetRunnerState()
                    }
                }, label: {
                    Text("Advanced to \(getNextBaseShortName())")
                        .foregroundColor(.green)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.green, lineWidth: 5)
                                )
                })
                Button(action: {
                    if let player = gameViewModel.getPlayerAtBase(base: gameStateViewModel.baseSelected) {
                        gameStateViewModel.event.actionsPerformed.append(PickoffAdvanceAction(
                                                                            eventType: .PickoffAdvance,
                                                                            player: player,
                                                                            baseAt: gameStateViewModel.baseSelected,
                                                                            baseGoingTo: getNextBase(),
                                                                            isError: true))
                        GameEngine.processEvent(gameViewModel: gameViewModel, gameState: gameStateViewModel)
                    }
                    gameStateViewModel.resetRunnerState()
                }, label: {
                    Text("Advanced to \(getNextBaseShortName()) Error")
                        .foregroundColor(.yellow)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.yellow, lineWidth: 5)
                                )
                })
                if canAdvanceTwoBases() {
                    Button(action: {
                        if let player = gameViewModel.getPlayerAtBase(base: gameStateViewModel.baseSelected) {
                            gameStateViewModel.event.actionsPerformed.append(PickoffAdvanceAction(
                                                                                eventType: .PickoffAdvance,
                                                                                player: player,
                                                                                baseAt: gameStateViewModel.baseSelected,
                                                                                baseGoingTo: getTwoBase()))
                            GameEngine.processEvent(gameViewModel: gameViewModel, gameState: gameStateViewModel)
                        }
                        gameStateViewModel.resetRunnerState()
                    }, label: {
                        Text("Advanced to \(getTwoBasesAhead())")
                            .foregroundColor(.green)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.green, lineWidth: 5)
                                    )
                    })
                    Button(action: {
                        if let player = gameViewModel.getPlayerAtBase(base: gameStateViewModel.baseSelected) {
                            gameStateViewModel.event.actionsPerformed.append(PickoffAdvanceAction(
                                                                                eventType: .PickoffAdvance,
                                                                                player: player,
                                                                                baseAt: gameStateViewModel.baseSelected,
                                                                                baseGoingTo: getTwoBase(),
                                                                                isError: true))
                            GameEngine.processEvent(gameViewModel: gameViewModel, gameState: gameStateViewModel)
                        }
                        gameStateViewModel.resetRunnerState()
                    }, label: {
                        Text("Advanced to \(getTwoBasesAhead()) Error")
                            .foregroundColor(.yellow)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.yellow, lineWidth: 5)
                                    )
                    })
                }
                if canAdvanceThreeBases() {
                    Button(action: {
                        if let player = gameViewModel.getPlayerAtBase(base: gameStateViewModel.baseSelected) {
                            gameStateViewModel.event.actionsPerformed.append(PickoffAdvanceAction(
                                                                                eventType: .PickoffAdvance,
                                                                                player: player,
                                                                                baseAt: gameStateViewModel.baseSelected,
                                                                                baseGoingTo: .Home))
                            GameEngine.processEvent(gameViewModel: gameViewModel, gameState: gameStateViewModel)
                        }
                        gameStateViewModel.resetRunnerState()
                    }, label: {
                        Text("Advanced Home")
                            .foregroundColor(.green)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.green, lineWidth: 5)
                                    )
                    })
                    Button(action: {
                        if let player = gameViewModel.getPlayerAtBase(base: gameStateViewModel.baseSelected) {
                            gameStateViewModel.event.actionsPerformed.append(PickoffAdvanceAction(
                                                                                eventType: .PickoffAdvance,
                                                                                player: player,
                                                                                baseAt: gameStateViewModel.baseSelected,
                                                                                baseGoingTo: .Home,
                                                                                isError: true))
                            GameEngine.processEvent(gameViewModel: gameViewModel, gameState: gameStateViewModel)
                        }
                        gameStateViewModel.resetRunnerState()
                    }, label: {
                        Text("Advanced Home Error")
                            .foregroundColor(.yellow)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.yellow, lineWidth: 5)
                                    )
                    })
                }
                Button(action: {
                    if let player = gameViewModel.getPlayerAtBase(base: gameStateViewModel.baseSelected) {
                        gameStateViewModel.event.actionsPerformed.append(PickoffOutAction(
                                                                                  eventType: .PickoffOut,
                                                                                  player: player,
                                                                                  baseAt: gameStateViewModel.baseSelected))
                        GameEngine.processEvent(gameViewModel: gameViewModel, gameState: gameStateViewModel)
                        gameStateViewModel.resetRunnerState()
                    }
                    
                }, label: {
                    Text("Out")
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
                    gameStateViewModel.runnerState = .Selected
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
        }.padding()
    }
    
    func getNextBase() -> Base {
        return Base(rawValue:
                        gameStateViewModel.baseSelected.rawValue + 1) ?? .None
    }
    
    func getNextBaseShortName() -> String {
        return getNextBase().getStringShortRep()
    }
    
    func canAdvanceTwoBases() -> Bool {
        return gameStateViewModel.baseSelected == .First ||
            gameStateViewModel.baseSelected == .Second
    }
    
    func canAdvanceThreeBases() -> Bool {
        return gameStateViewModel.baseSelected == .First
    }
    
    func getTwoBasesAhead() -> String {
        return (Base(rawValue:
                        gameStateViewModel.baseSelected.rawValue + 2) ?? .None).getStringShortRep()
    }
    
    func getTwoBase() -> Base {
        return (Base(rawValue:
                        gameStateViewModel.baseSelected.rawValue + 2) ?? .None)
    }
    
}

struct GameRunnerStealView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel

    var body: some View {
        VStack(alignment: .center) {
            List {
                Button(action: {
                    processEvent(goingToBase: getNextBase(), isError: false)
                }, label: {
                    Text("Safe at \(getNextBaseShortName())")
                        .foregroundColor(Color.green)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.green, lineWidth: 5)
                                )
                })
                Button(action: {
                    processEvent(goingToBase: getNextBase(), isError: true)
                }, label: {
                    Text("Safe at \(getNextBaseShortName()) Error")
                        .foregroundColor(Color.yellow)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.yellow, lineWidth: 5)
                                )
                })
                if canAdvanceTwoBases() {
                    Button(action: {
                        processEvent(goingToBase: getTwoBase(), isError: false)
                    }, label: {
                        Text("Advanced to \(getTwoBasesAhead())")
                            .foregroundColor(Color.green)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.green, lineWidth: 5)
                                    )
                    })
                    Button(action: {
                        processEvent(goingToBase: getTwoBase(), isError: true)
                    }, label: {
                        Text("Advanced to \(getTwoBasesAhead()) Error")
                            .foregroundColor(Color.yellow)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.yellow, lineWidth: 5)
                                    )
                    })
                }
                if canAdvanceThreeBases() {
                    Button(action: {
                        processEvent(goingToBase: .Home, isError: false)
                    }, label: {
                        Text("Advanced Home")
                            .foregroundColor(Color.green)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.green, lineWidth: 5)
                                    )
                    })
                    Button(action: {
                        processEvent(goingToBase: .Home, isError: true)
                    }, label: {
                        Text("Advanced Home Error")
                            .foregroundColor(Color.yellow)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.yellow, lineWidth: 5)
                                    )
                    })
                }
                Button(action: {
                    processOutEvent()
                }, label: {
                    Text("Out")
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
                    gameStateViewModel.runnerState = .Selected
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
    
    func processEvent(goingToBase base: Base, isError: Bool) {
        if let player = gameViewModel.getPlayerAtBase(base: gameStateViewModel.baseSelected) {
            gameStateViewModel.event.actionsPerformed.append(RunnerStealAction(
                                                                               eventType: .RunnerSteal,
                                                                               player: player,
                                                                               baseAt: gameStateViewModel.baseSelected,
                                                                               baseGoingTo: base,
                                                                               isError: isError))
            GameEngine.processEvent(gameViewModel: gameViewModel, gameState: gameStateViewModel)
            gameStateViewModel.resetRunnerState()
        }
    }
    
    func processOutEvent() {
        if let player = gameViewModel.getPlayerAtBase(base: gameStateViewModel.baseSelected) {
            gameStateViewModel.event.actionsPerformed.append(RunnerStealOutAction(eventType: .RunnerStealOut, player: player, baseAt: gameStateViewModel.baseSelected))
            GameEngine.processEvent(gameViewModel: gameViewModel, gameState: gameStateViewModel)
            gameStateViewModel.resetRunnerState()
        }
    }
    
    func getNextBaseShortName() -> String {
        return (Base(rawValue:
                        gameStateViewModel.baseSelected.rawValue + 1) ?? .None).getStringShortRep()
    }
    
    func getNextBase() -> Base {
        return (Base(rawValue:
                        gameStateViewModel.baseSelected.rawValue + 1) ?? .None)
    }
    
    func canAdvanceTwoBases() -> Bool {
        return gameStateViewModel.baseSelected == .First ||
            gameStateViewModel.baseSelected == .Second
    }
    
    func canAdvanceThreeBases() -> Bool {
        return gameStateViewModel.baseSelected == .First
    }
    
    func getTwoBasesAhead() -> String {
        return (Base(rawValue:
                        gameStateViewModel.baseSelected.rawValue + 2) ?? .None).getStringShortRep()
    }
    
    func getTwoBase() -> Base {
        return (Base(rawValue:
                        gameStateViewModel.baseSelected.rawValue + 2) ?? .None)
    }
}

struct GameRunnerSelectedView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            List {
                Button(action: {
                    gameStateViewModel.runnerState = .Pickoff
                }, label: {
                    Text("Pickoff Attempt")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 5)
                                )
                })
                Button(action: {
                    gameStateViewModel.runnerState = .Steal
                }, label: {
                    Text(getStoleBaseVerbage())
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 5)
                                )
                })
                
//                if isAdvanceablePitch() {
                    Button(action: {
                        gameStateViewModel.runnerState = .Advance
                    }, label: {
                        Text("Advanced")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    })
//                }
                Button(action: {
                    if let player = gameViewModel.getPlayerAtBase(base: gameStateViewModel.baseSelected) {
                        gameStateViewModel.event.actionsPerformed.append(RunnerInterferenceAction(
                                                                            eventType: .RunnerIntereference,
                                                                            player: player,
                                                                            baseAt: gameStateViewModel.baseSelected))
                        GameEngine.processEvent(gameViewModel: gameViewModel, gameState: gameStateViewModel)
                    }
                }, label: {
                    Text("Runner Interference")
                        .padding()
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red, lineWidth: 5)
                                )
                })
                Button(action: {
                    gameStateViewModel.baseSelected = .None
                    gameStateViewModel.runnerState = .None
                }, label: {
                    Text("Pinch Runner")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 5)
                                )
                })
                Button(action: {
                    gameStateViewModel.baseSelected = .None
                    gameStateViewModel.runnerState = .None
                }, label: {
                    Text("Cancel")
                        .padding()
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red, lineWidth: 5)
                                )
                })
            }
        }.padding()
    }
    
    func getNextBaseShortName() -> String {
        return (Base(rawValue:
                        gameStateViewModel.baseSelected.rawValue + 1) ?? .None).getStringShortRep()
    }
    
    func getStoleBaseVerbage() -> String {
        return "Attempted to Steal \((Base(rawValue: gameStateViewModel.baseSelected.rawValue + 1) ?? .None).getStringShortRep())"
    }
    
    func getCaughtStealingVerbage() -> String {
        return "Caught Stealing \(getNextBaseShortName())"
    }
    
    func isAdvanceablePitch() -> Bool {
        if let pitch = gameViewModel.getLastPitchAction() {
            return pitch.extraInfo1?.canRunnerAdvance ?? false ||
                pitch.extraInfo2?.canRunnerAdvance ?? false
        }
        return false
    }
    
    func getPreviousAdvanceablePitch() -> String {
        if let pitch = gameViewModel.getLastPitchAction(),
           let option = pitch.extraInfo2  {
            return option.longName
        }
        return ""
    }
}

struct GameRunnerAdvanceView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel

    var body: some View {
        VStack(alignment: .center) {
            List {
                Button(action: {
                    processEvent(goingToBase: getNextBase(), isError: false)
                }, label: {
                    Text("Advanced to \(getNextBaseShortName())")
                        .foregroundColor(Color.green)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.green, lineWidth: 5)
                                )
                })
                Button(action: {
                    processEvent(goingToBase: getNextBase(), isError: true)
                }, label: {
                    Text("Advanced to \(getNextBaseShortName()) Error")
                        .foregroundColor(Color.yellow)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.yellow, lineWidth: 5)
                                )
                })
                if canAdvanceTwoBases() {
                    Button(action: {
                        processEvent(goingToBase: getTwoBasesAway(), isError: false)
                    }, label: {
                        Text("Advanced to \(getTwoBasesAhead())")
                            .foregroundColor(Color.green)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.green, lineWidth: 5)
                                    )
                    })
                    Button(action: {
                        processEvent(goingToBase: getTwoBasesAway(), isError: true)
                    }, label: {
                        Text("Advanced to \(getTwoBasesAhead()) Error")
                            .foregroundColor(Color.yellow)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.yellow, lineWidth: 5)
                                    )
                    })
                }
                if canAdvanceThreeBases() {
                    Button(action: {
                        processEvent(goingToBase: .Home, isError: false)
                    }, label: {
                        Text("Advanced Home")
                            .foregroundColor(Color.green)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.green, lineWidth: 5)
                                    )
                    })
                    Button(action: {
                        processEvent(goingToBase: .Home, isError: true)
                    }, label: {
                        Text("Advanced Home Error")
                            .foregroundColor(Color.yellow)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.yellow, lineWidth: 5)
                                    )
                    })
                }
                Button(action: {
                    processOutEvent()
                }, label: {
                    Text("Out")
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
                    gameStateViewModel.runnerState = .Selected
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
    
    func processEvent(goingToBase base: Base, isError: Bool) {
        if let player = gameViewModel.getPlayerAtBase(base: gameStateViewModel.baseSelected) {
            gameStateViewModel.event.actionsPerformed.append(RunnerAdvanceAction(eventType: .RunnerSteal,
                                                                               player: player,
                                                                               baseAt: gameStateViewModel.baseSelected,
                                                                               baseGoingTo: base,
                                                                               isError: isError))
            GameEngine.processEvent(gameViewModel: gameViewModel, gameState: gameStateViewModel)
            gameStateViewModel.resetRunnerState()
        }
    }
    
    func processOutEvent() {
        if let player = gameViewModel.getPlayerAtBase(base: gameStateViewModel.baseSelected) {
            gameStateViewModel.event.actionsPerformed.append(RunnerAdvanceOutAction(eventType: .RunnerStealOut,
                                                                                    player: player,
                                                                                    baseAt: gameStateViewModel.baseSelected))
            GameEngine.processEvent(gameViewModel: gameViewModel, gameState: gameStateViewModel)
            gameStateViewModel.resetRunnerState()
        }
    }
    
    func getNextBaseShortName() -> String {
        return (Base(rawValue:
                        gameStateViewModel.baseSelected.rawValue + 1) ?? .None).getStringShortRep()
    }
    
    func getNextBase() -> Base {
        return (Base(rawValue:
                        gameStateViewModel.baseSelected.rawValue + 1) ?? .None)
    }
    
    func canAdvanceTwoBases() -> Bool {
        return gameStateViewModel.baseSelected == .First ||
            gameStateViewModel.baseSelected == .Second
    }
    
    func getTwoBasesAway() -> Base {
        return (Base(rawValue:
                        gameStateViewModel.baseSelected.rawValue + 2) ?? .None)
    }
    
    func canAdvanceThreeBases() -> Bool {
        return gameStateViewModel.baseSelected == .First
    }
    
    func getTwoBasesAhead() -> String {
        return (Base(rawValue:
                        gameStateViewModel.baseSelected.rawValue + 2) ?? .None).getStringShortRep()
    }
}
