//
//  GameLineupView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 8/4/21.
//

import Foundation
import SwiftUI

struct GameEditorLineupViewAuxOptions: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel

//    @Binding var teamEditing: Team
//
//    @Binding var homeLineup: [LineupPerson]
//    @Binding var homeRoster: [RosterMember]
//
//    @Binding var awayLineup: [LineupPerson]
//    @Binding var awayRoster: [RosterMember]
    
    var body: some View {
        HStack {
            Button(action: {
                resetLineupInformation()
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
                resetLineupInformation()
            }, label: {
                Text("Reset")
                    .foregroundColor(Color.red)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red, lineWidth: 5)
                            )
            })
            Spacer()
            Button(action: {
                gameStateViewModel.teamEditing = getOtherTeam()
            }, label: {
                Text("Switch to \(getOtherTeam().toString()) Team")
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 5)
                            )
            })
            Spacer()
            Button(action: {
                setLineupInformation()
                gameViewModel.setHitter()
                gameViewModel.setPitcher()
                gameStateViewModel.mainViewState = .Field
                gameViewModel.saveLineups()
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
    
    func resetLineupInformation() {
        gameStateViewModel.homeLineup = gameViewModel.homeLineup
        // homeRoster = gameStaticViewModel.homeRoster
        gameStateViewModel.awayLineup = gameViewModel.awayLineup
        // awayRoster = gameStaticViewModel.awayRoster
    }
    
    func setLineupInformation() {
        gameViewModel.homeLineup = gameStateViewModel.homeLineup
        gameStaticViewModel.homeRoster = gameStaticViewModel.homeRoster
        gameViewModel.awayLineup = gameStateViewModel.awayLineup
        gameStaticViewModel.awayRoster = gameStaticViewModel.awayRoster
    }
    
    func getOtherTeam() -> Team {
        return gameStateViewModel.teamEditing == .Away ? .Home : .Away
    }
}

struct GameLineupView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
//
//    @Binding var teamEditing: Team
//
//    @Binding var homeLineup: [LineupPerson]
//    @Binding var homeRoster: [RosterMember]
//
//    @Binding var awayLineup: [LineupPerson]
//    @Binding var awayRoster: [RosterMember]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Lineup")
                    .frame(width: geometry.size.width,
                           height: geometry.size.height * 0.05)
                    .border(Color.black)
                List {
                    ForEach(0..<getHittingTeamLineup().count, id: \.self) { index in
                        LineupCellView(pos: index + 1, person: getHittingTeamLineup()[index])
                            .padding()
                            .if(gameViewModel.hitter == getHittingTeamLineup()[index].person ||
                                    gameViewModel.hitter == getHittingTeamLineup()[index].dh) { view in
                                view.border(Color.black, width: 2)
                            }
                    }
                }
                Button(action: {
                    gameStateViewModel.teamEditing = gameViewModel.getHittingTeam()
                    setInitialLineups()
                    gameStateViewModel.mainViewState = .Lineup
                }, label: {
                    Text("Edit Lineup")
                        .frame(maxWidth: .infinity)
                        .padding([.top, .bottom])
                        .border(Color.blue)
                })
            }
        }
    }
    
    func setInitialLineups() {
        gameStateViewModel.homeLineup = gameViewModel.homeLineup
        // homeRoster = gameStaticViewModel.homeRoster
        gameStateViewModel.awayLineup = gameViewModel.awayLineup
        // awayRoster = gameStaticViewModel.awayRoster
    }
    
    func getHittingTeamLineup() -> [LineupPerson] {
        return gameViewModel.getHittingTeam() == .Away ?
            gameViewModel.awayLineup :
            gameViewModel.homeLineup
    }
}

struct LineupCellView: View {
    
    var pos: Int
    var person: LineupPerson
    
    var body: some View {
        HStack {
            Text("#" + String(pos))
            Spacer()
            VStack {
                Text(person.dh?.getFullName() ?? person.person.getFullName())
                if person.dh?.firstName != nil {
                Text("DH for \(person.person.getFullName())")
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 15))
                }
            }
            Spacer()
            Text(person.dh == nil ? person.position.shortName : "DH")
        }
    }
}

struct RosterCellView: View {
    
    var pos: Int
    var person: RosterMember
    
    var body: some View {
        HStack {
            Text("#" + String(pos))
            Spacer()
            VStack {
                Text(person.getFullName())
            }
            Spacer()
            Text("B")
        }
    }
}


struct GameEditorLineupView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
    
    @State var selectedLineupMember: LineupPerson? = nil
    @State var selectedRosterMember: RosterMember? = nil
    
    @State var lineupState: LineupState = .Normal
    
    var body: some View {
        if lineupState == .DH {
            GameLineupDHSelectionView(lineupState: $lineupState,
                                      selectedLineupMember: $selectedLineupMember,
                                      selectedRosterMember: $selectedRosterMember)
        } else {
            HStack {
                VStack {
                    Text("Current Lineup")
                        .frame(maxWidth: .infinity)
                        .padding([.top, .bottom])
                        .border(Color.black)
                    List {
                        ForEach(0..<getCurrentLineup().count, id: \.self) { index in
                                LineupCellView(pos: index + 1, person: getCurrentLineup()[index])
                                    .padding()
                                    .if(getCurrentLineup()[index] == self.selectedLineupMember, transform: { view in
                                        view.border(Color.black, width: 2)
                                    })
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        self.selectedLineupMember = getCurrentLineup()[index]
                                    }
                        }
                    }
                }.border(Color.black, width: 2)
                VStack {
                    Text("\(gameStateViewModel.teamEditing.toString()) Team")
                        .frame(maxWidth: .infinity)
                        .padding([.top, .bottom])
                        .border(Color.black, width: 5)
                    if lineupState == .Normal {
                        LineupEditButtonView(selectedLineupMember: $selectedLineupMember,
                                             selectedRosterMember: $selectedRosterMember,
                                             lineupState: $lineupState)
                    } else if lineupState == .AddPlayer {
                        GameLineupPositionSelector(lineupState: $lineupState,
                                                   selectedLineupMember: $selectedLineupMember,
                                                   selectedRosterMember: $selectedRosterMember)
                    }
                }
                
                VStack {
                    Text("Team Roster")
                        .frame(maxWidth: .infinity)
                        .padding([.top, .bottom])
                        .border(Color.black)
                    List {
                        ForEach(0..<getCurrentRoster().count, id: \.self) { index in
                            RosterCellView(pos: index + 1, person: getCurrentRoster()[index])
                                .padding()
                                .if(getCurrentRoster()[index] == self.selectedRosterMember, transform: { view in
                                    view.border(Color.black, width: 2)
                                })
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard lineupState == .Normal else {
                                        return
                                    }
                                    self.selectedRosterMember = getCurrentRoster()[index]
                                }
                        }
                    }
                }.border(Color.black, width: 2)
            }
        }
    }
    
    func getCurrentLineup() -> [LineupPerson] {
        return gameStateViewModel.teamEditing == .Away ? gameStateViewModel.awayLineup : gameStateViewModel.homeLineup
    }
    
    func getCurrentRoster() -> [RosterMember] {
        return gameStateViewModel.teamEditing == .Away ? gameStaticViewModel.awayRoster : gameStaticViewModel.homeRoster
    }
}

struct LineupEditButtonView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
    
    @Binding var selectedLineupMember: LineupPerson?
    @Binding var selectedRosterMember: RosterMember?
    
    @Binding var lineupState: LineupState
    
    var body: some View {
        VStack {
            Button(action: {
                addRosterMemberToLineup()
            }, label: {
                Image(systemName: "plus.circle")
                    .frame(maxWidth: .infinity)
                    .padding([.top, .bottom])
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue, lineWidth: 5)
                            )
            })
            Button(action: {
                removeLineupMemberFromLineup()
            }, label: {
                Image(systemName: "minus.circle")
                    .frame(maxWidth: .infinity)
                    .padding([.top, .bottom])
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue, lineWidth: 5)
                            )
            })
            Button(action: {
                replace()
            }, label: {
                Text("Replace")
                    .frame(maxWidth: .infinity)
                    .padding([.top, .bottom])
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue, lineWidth: 5)
                            )
            })
            Button(action: {
                moveLineupMemberUp()
            }, label: {
                Image(systemName: "arrow.up")
                    .frame(maxWidth: .infinity)
                    .padding([.top, .bottom])
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue, lineWidth: 5)
                            )
            })
            Button(action: {
                moveLineupMemberDown()
            }, label: {
                Image(systemName: "arrow.down")
                    .frame(maxWidth: .infinity)
                    .padding([.top, .bottom])
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue, lineWidth: 5)
                            )
            })
            if gameViewModel.game.homeTeamID == gameViewModel.game.awayTeamID {
                Button(action: {
                    swapLineups()
                }, label: {
                    Text("Swap Lineup with \(gameStateViewModel.teamEditing == .Away ? (Team.Home.toString()) : Team.Away.toString()) Team")
                        .frame(maxWidth: .infinity)
                        .padding([.top, .bottom])
                        .foregroundColor(.red)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red , lineWidth: 5)
                                )
                })
            }
        }
    }
    
    func swapLineups() {
        let temp = gameStateViewModel.awayLineup
        gameStateViewModel.awayLineup = gameStateViewModel.homeLineup
        gameStateViewModel.homeLineup = temp
    }
    
    func addSelectedLineupMemberToRoster() {
        if gameStateViewModel.teamEditing == .Home,
           let person = selectedLineupMember {
            gameStaticViewModel.homeRoster.append(person.person)
        } else if gameStateViewModel.teamEditing == .Away,
                  let person = selectedLineupMember {
            gameStaticViewModel.awayRoster.append(person.person)
        }
        selectedRosterMember = selectedLineupMember?.person
    }
    
    func removeSelectedRosterMemberFromRoster() {
        if gameStateViewModel.teamEditing == .Home,
           let person = selectedRosterMember,
           let index = gameStaticViewModel.homeRoster.firstIndex(of: person) {
            gameStaticViewModel.homeRoster.remove(at: index)
        } else if gameStateViewModel.teamEditing == .Away,
                  let person = selectedRosterMember,
                  let index = gameStaticViewModel.awayRoster.firstIndex(of: person) {
            gameStaticViewModel.awayRoster.remove(at: index)
        }
    }
    
    func addSelectedRosterMemberToLineup(withPos pos: Position, atIndex index: Int = -1, withDH dh: RosterMember? = nil) {
        if gameStateViewModel.teamEditing == .Home,
           let person = selectedRosterMember {
            var newMember = LineupPerson(numberInLineup: index,
                                         position: pos, dh: dh, person: person)
            if index == -1 {
                newMember.numberInLineup = gameStateViewModel.homeLineup.count
                gameStateViewModel.homeLineup.append(newMember)
            } else {
                gameStateViewModel.homeLineup.insert(newMember, at: index)
            }
        } else if gameStateViewModel.teamEditing == .Away,
                  let person = selectedRosterMember {
            var newMember = LineupPerson(numberInLineup: index,
                                         position: pos, dh: dh, person: person)
            if index == -1 {
                newMember.numberInLineup = gameStateViewModel.awayLineup.count
                gameStateViewModel.awayLineup.append(newMember)
            } else {
                gameStateViewModel.awayLineup.insert(newMember, at: index)
            }
        }
    }
    
    func removeSelectedLineupMemberFromLineup() {
        if gameStateViewModel.teamEditing == .Home,
           let person = selectedLineupMember,
           let index = gameStateViewModel.homeLineup.firstIndex(of: person) {
            gameStateViewModel.homeLineup.remove(at: index)
        } else if gameStateViewModel.teamEditing == .Away,
                  let person = selectedLineupMember,
                  let index = gameStateViewModel.awayLineup.firstIndex(of: person) {
            gameStateViewModel.awayLineup.remove(at: index)
        }
    }
    
    func addRosterMemberToLineup() {
        guard selectedRosterMember != nil else {
            return
        }
        lineupState = .AddPlayer
    }
    
    func removeLineupMemberFromLineup() {
        removeSelectedLineupMemberFromLineup()
        addSelectedLineupMemberToRoster()
        selectedLineupMember = nil
    }
    
    func getCurrentLineup() -> [LineupPerson] {
        return gameStateViewModel.teamEditing == .Away ?
            gameStateViewModel.awayLineup : gameStateViewModel.homeLineup
    }
    
    func replace() {
        guard let _ = selectedRosterMember, let lineup = selectedLineupMember,
              let lineupIndex = getCurrentLineup().firstIndex(of: lineup) else {
            return
        }
        removeSelectedRosterMemberFromRoster()
        addSelectedRosterMemberToLineup(withPos: lineup.position, atIndex: lineupIndex, withDH: lineup.dh)
        removeSelectedLineupMemberFromLineup()
        addSelectedLineupMemberToRoster()
        // Swap them here as well
//        let temp = selectedLineupMember
//        selectedRosterMember = temp?.person
    }
    
    func moveLineupMemberUp() {
        guard let person = selectedLineupMember else {
            return
        }
        if gameStateViewModel.teamEditing == .Home,
           let index = gameStateViewModel.homeLineup.firstIndex(of: person),
           index != 0 {

            gameStateViewModel.homeLineup[index] = gameStateViewModel.homeLineup[index - 1]
            gameStateViewModel.homeLineup[index - 1] = person
            gameStateViewModel.homeLineup[index - 1].numberInLineup = index - 1
            gameStateViewModel.homeLineup[index].numberInLineup = index
        } else if gameStateViewModel.teamEditing == .Away,
                  let index = gameStateViewModel.awayLineup.firstIndex(of: person),
                  index != 0 {
            gameStateViewModel.awayLineup[index] = gameStateViewModel.awayLineup[index - 1]
            gameStateViewModel.awayLineup[index - 1] = person
            gameStateViewModel.awayLineup[index].numberInLineup = index
            gameStateViewModel.awayLineup[index - 1].numberInLineup = index - 1
        }
    }
    
    func moveLineupMemberDown() {
        guard let person = selectedLineupMember else {
            return
        }
        if gameStateViewModel.teamEditing == .Home,
           let index = gameStateViewModel.homeLineup.firstIndex(of: person),
           index != gameStateViewModel.homeLineup.count - 1 {
            gameStateViewModel.homeLineup[index] = gameStateViewModel.homeLineup[index + 1]
            gameStateViewModel.homeLineup[index + 1] = person
            gameStateViewModel.homeLineup[index].numberInLineup = index
            gameStateViewModel.homeLineup[index + 1].numberInLineup = index + 1
        } else if gameStateViewModel.teamEditing == .Away,
                  let index = gameStateViewModel.awayLineup.firstIndex(of: person),
                  index != gameStateViewModel.awayLineup.count - 1 {
            gameStateViewModel.awayLineup[index] = gameStateViewModel.awayLineup[index + 1]
            gameStateViewModel.awayLineup[index + 1] = person
            gameStateViewModel.awayLineup[index].numberInLineup = index
            gameStateViewModel.awayLineup[index + 1].numberInLineup = index + 1
        }
    }
}

struct GameLineupPositionSelector: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
    
    @Binding var lineupState: LineupState
    
    @Binding var selectedLineupMember: LineupPerson?
    @Binding var selectedRosterMember: RosterMember?
    
    var body: some View {
        List {
            Text("Available Positions")
                .frame(maxWidth: .infinity)
                .padding([.top, .bottom])
            if let position = getAvailablePosition()  {
                ForEach(0..<position.count, id: \.self) { index in
                    Button(action: {
                        if position[index].isDH {
                            lineupState = .DH
                        } else {
                            addRosterMemberToLineup(withPosition: position[index])
                        }
                    }, label: {
                        Text("\(position[index].shortName) (\(position[index].positionNum))")
                            .frame(maxWidth: .infinity)
                            .padding([.top, .bottom])
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.blue, lineWidth: 5)
                                    )
                    })
                }
            }
            Button(action: {
                lineupState = .Normal
            }, label: {
                Text("Back")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding([.top, .bottom])
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.red, lineWidth: 5)
                            )
            })
        }
    }
    func getAvailablePosition() -> [Position]? {
        var positions = gameStaticViewModel.positions
        let lineup = gameStateViewModel.teamEditing == .Away ? gameStateViewModel.awayLineup : gameStateViewModel.homeLineup
        for player in lineup {
            if let position = positions.firstIndex(of: player.position),
                player.position.removeFromOptionsOnceSelected {
                positions.remove(at: position)
            }
        }
         
        var array = Array(positions)
        array.sort { pos1, pos2 in
            pos1.positionNum < pos2.positionNum
        }
        return array
    }
    
    func addRosterMemberToLineup(withPosition pos: Position) {
        print("Adding member with position \(pos.shortName)")
        removeSelectedRosterMemberFromRoster()
        addSelectedRosterMemberToLineup(withPos: pos)
        selectedRosterMember = nil
        lineupState = .Normal
    }
    
    func addSelectedRosterMemberToLineup(withPos pos: Position, atIndex index: Int = -1) {
        if gameStateViewModel.teamEditing == .Home,
           let person = selectedRosterMember {
            var newMember = LineupPerson(numberInLineup: index, position: pos,
                                         person: person)
            if index == -1 {
                newMember.numberInLineup = gameStateViewModel.homeLineup.count
                gameStateViewModel.homeLineup.append(newMember)
            } else {
                gameStateViewModel.homeLineup.insert(newMember, at: index)
            }
        } else if gameStateViewModel.teamEditing == .Away,
                  let person = selectedRosterMember {
            var newMember = LineupPerson(numberInLineup: index, position: pos,
                                         person: person)
            if index == -1 {
                newMember.numberInLineup = gameStateViewModel.awayLineup.count
                gameStateViewModel.awayLineup.append(newMember)
            } else {
                gameStateViewModel.awayLineup.insert(newMember, at: index)
            }
        }
    }
    
    func removeSelectedLineupMemberFromLineup() {
        if gameStateViewModel.teamEditing == .Home,
           let person = selectedLineupMember,
           let index = gameStateViewModel.homeLineup.firstIndex(of: person) {
            gameStateViewModel.homeLineup.remove(at: index)
        } else if gameStateViewModel.teamEditing == .Away,
                  let person = selectedLineupMember,
                  let index = gameStateViewModel.awayLineup.firstIndex(of: person) {
            gameStateViewModel.awayLineup.remove(at: index)
        }
    }
    
    func addRosterMemberToLineup() {
        removeSelectedRosterMemberFromRoster()
        addSelectedRosterMemberToLineup(withPos: gameStaticViewModel.positions[0])
//        selectedLineupMember = selectedRosterMember
        selectedRosterMember = nil
    }
    
    func removeLineupMemberFromLineup() {
        removeSelectedLineupMemberFromLineup()
        addSelectedLineupMemberToRoster()
        selectedLineupMember = nil
    }
    
    func addSelectedLineupMemberToRoster() {
        if gameStateViewModel.teamEditing == .Home,
           let person = selectedLineupMember {
            gameStaticViewModel.homeRoster.append(person.person)
        } else if gameStateViewModel.teamEditing == .Away,
                  let person = selectedLineupMember {
            gameStaticViewModel.awayRoster.append(person.person)
        }
//        selectedRosterMember = selectedLineupMember
    }
    
    
    func removeSelectedRosterMemberFromRoster() {
        if gameStateViewModel.teamEditing == .Home,
           let person = selectedRosterMember,
           let index = gameStaticViewModel.homeRoster.firstIndex(of: person) {
            gameStaticViewModel.homeRoster.remove(at: index)
        } else if gameStateViewModel.teamEditing == .Away,
                  let person = selectedRosterMember,
                  let index = gameStaticViewModel.awayRoster.firstIndex(of: person) {
            gameStaticViewModel.awayRoster.remove(at: index)
        }
    }
}

struct GameLineupDHSelectionView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
    @EnvironmentObject var gameStateViewModel: GameStateViewModel

    @Binding var lineupState: LineupState
    
//    @Binding var teamEditing: Team
//
//    @Binding var homeLineup: [LineupPerson]
//    @Binding var homeRoster: [RosterMember]
//
//    @Binding var awayLineup: [LineupPerson]
//    @Binding var awayRoster: [RosterMember]
    
    @Binding var selectedLineupMember: LineupPerson?
    @Binding var selectedRosterMember: RosterMember?
    
    @State var rosterMemberToSet: RosterMember? = nil
    
    var body: some View {
        VStack {
            Text("Available Positions")
                .frame(maxWidth: .infinity)
                .padding([.top, .bottom])
            if let dhPlayer = selectedRosterMember {
                Text("Please select the position and the player \(dhPlayer.getFullName()) will be the DH for")
                    .frame(maxWidth: .infinity)
                    .padding([.top, .bottom])
            }
            HStack {
                List {
                   
                    if let position = getAvailablePosition()  {
                        ForEach(0..<position.count, id: \.self) { index in
                            Button(action: {
                                addRosterMemberToLineup(withPosition: position[index])
                            }, label: {
                                Text("\(position[index].shortName) (\(position[index].positionNum))")
                                    .frame(maxWidth: .infinity)
                                    .padding([.top, .bottom])
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.blue, lineWidth: 5)
                                            )
                            })
                        }
                    }
                    Button(action: {
                        lineupState = .AddPlayer
                    }, label: {
                        Text("Back")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding([.top, .bottom])
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.red, lineWidth: 5)
                                    )
                    })
                }
                VStack {
                    Text("Team Roster")
                        .frame(maxWidth: .infinity)
                        .padding([.top, .bottom])
                        .border(Color.black)
                    List {
                        ForEach(0..<getCurrentRoster().count, id: \.self) { index in
                            RosterCellView(pos: index + 1, person: getCurrentRoster()[index])
                                .padding()
                                .if(getCurrentRoster()[index] == self.rosterMemberToSet, transform: { view in
                                    view.border(Color.black, width: 2)
                                })
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.rosterMemberToSet = getCurrentRoster()[index]
                                }
                        }
                    }
                }.border(Color.black, width: 2)
            }
        }
        
    }
    func getAvailablePosition() -> [Position]? {
        var positions = gameStaticViewModel.positions
        let lineup = gameStateViewModel.teamEditing == .Away ? gameStateViewModel.awayLineup : gameStateViewModel.homeLineup
        for player in lineup {
            if let position = positions.firstIndex(of: player.position),
                player.position.removeFromOptionsOnceSelected {
                positions.remove(at: position)
            }
        }
         
        var array = Array(positions)
        array.sort { pos1, pos2 in
            pos1.positionNum < pos2.positionNum
        }
        return array
    }
    
    func addRosterMemberToLineup(withPosition pos: Position) {
        guard rosterMemberToSet != nil else {
            return
        }
        removeSelectedRosterMemberFromRoster()
        addSelectedRosterMemberToLineup(withPos: pos)
//        selectedLineupMember = rosterMemberToSet
        selectedRosterMember = nil
        lineupState = .Normal
    }
    
    func addSelectedRosterMemberToLineup(withPos pos: Position, atIndex index: Int = -1) {
        if gameStateViewModel.teamEditing == .Home,
           let person = rosterMemberToSet ,
           let dh = selectedRosterMember {
            var newMember = LineupPerson(numberInLineup: index, position: pos, person: person)
            newMember.dh = dh
            if index == -1 {
                newMember.numberInLineup = gameStateViewModel.homeLineup.count
                gameStateViewModel.homeLineup.append(newMember)
            } else {
                gameStateViewModel.homeLineup.insert(newMember, at: index)
            }
        } else if gameStateViewModel.teamEditing == .Away,
                  let person = rosterMemberToSet,
                  let dh = selectedRosterMember {
            var newMember = LineupPerson(numberInLineup: index, position: pos, person: person)
            newMember.dh = dh
            if index == -1 {
                newMember.numberInLineup = gameStateViewModel.awayLineup.count
                gameStateViewModel.awayLineup.append(newMember)
            } else {
                gameStateViewModel.awayLineup.insert(newMember, at: index)
            }
        }
    }
    
    func removeSelectedLineupMemberFromLineup() {
        if gameStateViewModel.teamEditing == .Home,
           let person = selectedLineupMember,
           let index = gameStateViewModel.homeLineup.firstIndex(of: person) {
            gameStateViewModel.homeLineup.remove(at: index)
        } else if gameStateViewModel.teamEditing == .Away,
                  let person = selectedLineupMember,
                  let index = gameStateViewModel.awayLineup.firstIndex(of: person) {
            gameStateViewModel.awayLineup.remove(at: index)
        }
    }
    
    func addRosterMemberToLineup() {
        removeSelectedRosterMemberFromRoster()
        addSelectedRosterMemberToLineup(withPos: gameStaticViewModel.positions[0])
//        selectedLineupMember = selectedRosterMember
        selectedRosterMember = nil
    }
    
    func removeLineupMemberFromLineup() {
        removeSelectedLineupMemberFromLineup()
        addSelectedLineupMemberToRoster()
        selectedLineupMember = nil
    }
    
    func addSelectedLineupMemberToRoster() {
        if gameStateViewModel.teamEditing == .Home,
           let person = selectedLineupMember {
            gameStaticViewModel.homeRoster.append(person.person)
        } else if gameStateViewModel.teamEditing == .Away,
                  let person = selectedLineupMember {
            gameStaticViewModel.awayRoster.append(person.person)
        }
//        selectedRosterMember = selectedLineupMember
    }
    
    
    func removeSelectedRosterMemberFromRoster() {
        if gameStateViewModel.teamEditing == .Home,
           let person = selectedRosterMember,
           let rosterMember = rosterMemberToSet,
           let index = gameStaticViewModel.homeRoster.firstIndex(of: person) {
            gameStaticViewModel.homeRoster.remove(at: index)
            if let rosterIndex = gameStaticViewModel.homeRoster.firstIndex(of: rosterMember) {
                gameStaticViewModel.homeRoster.remove(at: rosterIndex)
            }
        } else if gameStateViewModel.teamEditing == .Away,
                  let person = selectedRosterMember,
                  let rosterMember = rosterMemberToSet,
                  let index = gameStaticViewModel.awayRoster.firstIndex(of: person) {
            gameStaticViewModel.awayRoster.remove(at: index)
            if let rosterIndex = gameStaticViewModel.awayRoster.firstIndex(of: rosterMember) {
                gameStaticViewModel.awayRoster.remove(at: rosterIndex)
            }
        }
    }
    
    func getCurrentRoster() -> [RosterMember] {
        return gameStateViewModel.teamEditing == .Away ? gameStaticViewModel.awayRoster : gameStaticViewModel.homeRoster
    }
}


enum LineupState {
    case AddPlayer
    case Normal
    case DH
}
