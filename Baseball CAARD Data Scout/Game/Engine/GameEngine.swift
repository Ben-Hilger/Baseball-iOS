//
//  GameEngine.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 7/28/21.
//

import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    
    @Published var halfInning: Int = 1
    
    @Published var atBatNum: Int = 1
    
    @Published var numberStrikes: Int = 0
    @Published var numberBalls: Int = 0
    @Published var numberOuts: Int = 0
    
    @Published var eventHistory: [GameEventBase] = []
    
    @Published var pa: [Int: PlateAppearance] = [:]
    @Published var events: [Int: GameEventBase] = [:]
    @Published var paOrder: [Int] = []
    @Published var currentPA: PlateAppearance!
    
    @Published var hitter: RosterMember? = nil
    @Published var pitcher: RosterMember? = nil
    @Published var pitherPitches: [PitchThrown] = []
    
    @Published var playerOnFirst: RosterMember? = nil
    @Published var playerOnSecond: RosterMember? = nil
    @Published var playerOnThird: RosterMember? = nil

    @Published var homeLineup: [LineupPerson] = []
    var homeLineupIndex: Int = 0

    @Published var awayLineup: [LineupPerson] = []
    var awayLineupIndex: Int = 0

    @Published var basesToUpdate: [Base: RosterMember] = [:]
    
    @Published var inningTotals: [String: Int] = [:]
    
    var game: Game!
    var loaded: Bool = false

    @Published var style: PitchingStyle? = nil
    @Published var pitchingHand: Hand? = nil
    @Published var hitterHand: Hand? = nil

    @Published var bipOrder: String = ""
    
    init() {
        // startGame()
    }
    
    func loadInitialGameInformation(game: Game, homeLineupComp: @escaping ((([LineupPerson]) -> Void)),
                                    awayLineupComp: @escaping ((([LineupPerson]) -> Void))) {
        if loaded && game == self.game {
            return
        }
        FirebaseManager.loadGameLineup(gameUID: game.gameID,
               teamUID: game.homeTeamID,
               lineupUID: game.homeTeamLineupID) { lineup in
            DispatchQueue.main.async {
                self.homeLineup = lineup
                homeLineupComp(lineup)
            }
        }
        FirebaseManager.loadGameLineup(gameUID: game.gameID,
               teamUID: game.awayTeamID,
               lineupUID: game.awayTeamLineupID) { lineup in
            DispatchQueue.main.async {
                self.awayLineup = lineup
                awayLineupComp(lineup)
            }
        }
        FirebaseManager.loadPAOrder(gameID: game.gameID) { order in
            self.paOrder = order
            PlateAppearance.numPA = self.paOrder.max() ?? 0
        }
        FirebaseManager.loadPlateAppearanceInfo(gameID: game.gameID) { paInfo in
            self.pa = paInfo
        }
        FirebaseManager.loadGameEvents(gameID: game.gameID) { eventInfo in
            self.events = eventInfo
            GameEngine.eventNum = self.events.keys.max() ?? 1
            for event in eventInfo.values {
                for action in event.actionsPerformed {
                    GameEngine.actionNum = max(action.actionNum ?? 0,
                                               GameEngine.actionNum)
                }
            }
            GameEngine.eventNum += 1
            GameEngine.actionNum += 1
        }
        FirebaseManager.getCurrentGameState(gameID: game.gameID) { snapshot in
            if let snapshot = snapshot {
                DispatchQueue.main.async {
                    self.setState(snapshot: snapshot)
                }
            }
        }
        self.game = game
        loaded = true
    }
    
    func nextPlateAppearance() {
        PlateAppearance.numPA += 1
        let newPA = PlateAppearance(hittingHand: self.hitterHand ?? .Right,
                                    pitchingHand: self.pitchingHand ?? .Right,
                                    paNumber: PlateAppearance.numPA)
        if currentPA != nil {
            pa.updateValue(currentPA, forKey: currentPA.paNumber)
            paOrder.append(currentPA.paNumber)
            FirebaseManager.savePlateAppearance(gameID: game.gameID, pa: currentPA)
            FirebaseManager.savePAOrder(gameID: game.gameID, paOrder: paOrder)
        }
        currentPA = newPA
    }
    
    func getMaxPANum(events: [GameEventBase]) -> Int {
        if let max = pa.keys.max() {
            return max
        }
        return 0
    }
    
    func setState(snapshot: GameSnapshot) {
        self.numberStrikes = snapshot.numberStrikes
        self.numberBalls = snapshot.numberBalls
        self.numberOuts = snapshot.numberOuts
        self.halfInning = snapshot.halfInning
        self.homeLineupIndex = snapshot.homeLineupIndex
        self.awayLineupIndex = snapshot.awayLineupIndex
        self.inningTotals = snapshot.inningTotals
        self.playerOnFirst = snapshot.playerOnFirst
        self.playerOnSecond = snapshot.playerOnSecond
        self.playerOnThird = snapshot.playerOnThird
        PlateAppearance.numPA = snapshot.plateAppearance
    }
    
    func startGame() {
        setHitter()
        setPitcher()
        nextPlateAppearance()
        FirebaseManager.setupUpdateStats(gameID: game.gameID) { data in
            if let pitchingID = data["pitching_hand_id"] as? Int {
                self.pitchingHand = Hand(rawValue: pitchingID) ?? .Right
            }
            if let hittingID = data["hitting_hand_id"] as? Int {
                self.hitterHand = Hand(rawValue: hittingID) ?? .Right
            }
            if let styleID = data["style_id"] as? Int {
                self.style = PitchingStyle(rawValue: styleID) ?? .Stretch
            }
        }
    }
    
    func getCurrentPitcher() -> RosterMember? {
        for player in getFieldingTeamLineup() {
            if player.position.positionNum == 1 {
                return player.person
            }
        }
        return nil
    }
    
    func goToNextHalfInning() {
        halfInning += 1
    }

    func goToNextHitter(goToNextPA: Bool = true) {
        // Get the current team lineup
        let lineup = getHittingTeamLineup()
        // Get the current index
        var index = getHittingTeam() == .Away ? awayLineupIndex : homeLineupIndex
        // Check if it's the end of the lineup
        if index + 1 == getHittingTeamLineup().count {
            index = -1
        }
        // Set the new hitter
        self.hitter = lineup[index + 1].dh ?? lineup[index + 1].person
        if getHittingTeam() == .Away {
            awayLineupIndex = index + 1
        } else if getHittingTeam() == .Home {
            homeLineupIndex = index + 1
        }
        atBatNum += 1
        if goToNextPA {
            nextPlateAppearance()
        }
    }
    
    func revertOneHitter(goToNextPA: Bool = true) {
        // Get the current team lineup
        let lineup = getHittingTeamLineup()
        // Get the current index
        var index = getHittingTeam() == .Away ? awayLineupIndex : homeLineupIndex
        // Check if it's the end of the lineup
        if index - 1 < 0  {
            index = getHittingTeamLineup().count - 1
        }
        // Set the new hitter
        self.hitter = lineup[index - 1].dh ?? lineup[index - 1].person
        if getHittingTeam() == .Away {
            awayLineupIndex = index - 1
        } else if getHittingTeam() == .Home {
            homeLineupIndex = index - 1
        }
        atBatNum += 1
        if goToNextPA {
            nextPlateAppearance()
        }
    }
    
    func setPitcher() {
        self.pitcher = getCurrentPitcher()
        if self.pitcher?.throwingHand == .Switch {
            self.pitcher?.throwingHand = .Right
        } else {
            self.pitchingHand = self.pitcher?.throwingHand
        }
        if playerOnThird == nil && (playerOnFirst != nil && playerOnSecond == nil) ||
            (playerOnSecond != nil) {
            self.style = .Stretch
        } else {
            self.style = .Windup
        }
    }
    
    func setHitter() {
        // Get the current team lineup
        let lineup = getHittingTeamLineup()
        // Make sure the hitter and the position can be found
        let position = getHittingTeam() == .Away ?
            awayLineupIndex : homeLineupIndex
        self.hitter = lineup[position].dh ?? lineup[position].person
        if self.hitter?.hittingHand == .Switch {
            self.hitterHand = self.pitchingHand == .Right ? .Left : .Right
        } else {
            self.hitterHand = self.hitter?.hittingHand
        }
    }
    
    func switchSides() {
        setHitter()
        setPitcher()
        nextPlateAppearance()
    }
    
    func getHittingTeamLineup() -> [LineupPerson] {
        return getHittingTeam() == .Away ? awayLineup : homeLineup
    }
    
    func getFieldingTeamLineup() -> [LineupPerson] {
        return getFieldingTeam() == .Away ? awayLineup : homeLineup
    }
    
    func markBasesToUpdate() {
        basesToUpdate = [:]
        if let player = playerOnFirst {
            basesToUpdate.updateValue(player, forKey: .First)
        }
        if let player = playerOnSecond {
            basesToUpdate.updateValue(player, forKey: .Second)
        }
        if let player = playerOnThird {
            basesToUpdate.updateValue(player, forKey: .Third)
        }
    }
    
    func processPitchOutcome(outcome: PitchOutcome,
                             extraInfo1: PitchOutcomeSpecific,
                             extraInfo2: PitchOutcomeSpecific?,
                             extraInfo3: PitchOutcomeSpecific?) {
        numberStrikes += outcome.isFB && numberStrikes >= 2 ? 0 : outcome.strikesToAdd
        numberBalls += outcome.ballsToAdd
        numberOuts += outcome.outsToAdd
        
        if extraInfo1.markHitterAsOut || (extraInfo2?.markHitterAsOut ?? false) {
            numberOuts += 1
            resetCount()
            goToNextHitter()
        } else if extraInfo1.sendHitterToBase != .None, let hitter = hitter {
            movePlayer(toBase: extraInfo1.sendHitterToBase, playerToMove: hitter, moveOtherPlayers: true)
            resetCount()
            goToNextHitter()
        } else if let info2 = extraInfo2, info2.sendHitterToBase != .None, let hitter = hitter {
            movePlayer(toBase: info2.sendHitterToBase, playerToMove: hitter, moveOtherPlayers: true)
            resetCount()
            goToNextHitter()
        } else if let extra2 = extraInfo2,
                  extra2.markHitterAsOut {
            numberOuts += 1
            resetCount()
            goToNextHitter()
        } else if GameEngine.outOnStrikes(currentStrikes: numberStrikes) {
            numberOuts += 1
            resetCount()
            goToNextHitter()
        } else if GameEngine.walkOnBalls(currentBalls: numberBalls) {
            resetCount()
            if let hitter = hitter {
                movePlayer(toBase: .First, playerToMove: hitter, moveOtherPlayers: true)
            }
            goToNextHitter()
        } else if outcome.isBIP || outcome.isDropThird {
            resetCount()
            goToNextHitter()
        }
        
        // Check if it's an interference call
//        if outcome.shortName == "INF" {
//            goToNextHitter()
//            }
//        // Check if it's a BIP
//        } else if outcome.shortName == "BIP", let specificOutcome = extraInfo2, let movement = extraInfo3 {
//            if specificOutcome.longName == "Safe", let hitter = hitter {
//            } else if specificOutcome.longName == "Out", let hitter = hitter {
//                numberOuts += 1
//            }
//            goToNextHitter()
//        } else if GameEngine.outOnStrikes(currentStrikes: numberStrikes) {
//            numberOuts += 1
//            resetCount()
//            goToNextHitter()
//        } else if GameEngine.walkOnBalls(currentBalls: numberBalls) {
//            resetCount()
//            if let hitter = hitter {
//                movePlayer(toBase: .First, playerToMove: hitter)
//            }
//            goToNextHitter()
//        }
        
    }
    
    func addOuts(amt: Int = 1) {
        numberOuts += amt
    }
    
    func processPitchAction(event: PitchGameAction) {
        if let pitchOutcome = event.pitchOutcome,
           let extraInfo1 = event.extraInfo1 {
            processPitchOutcome(outcome: pitchOutcome,
                                extraInfo1: extraInfo1,
                                extraInfo2: event.extraInfo2,
                                extraInfo3: event.extraInfo3)
        }
    }
    
    func checkGameState() {
        if GameEngine.endOfHalfInning(currentOuts: numberOuts) {
            resetInning()
            goToNextHalfInning()
            switchSides()
        }
    }
    
    func resetCount() {
        numberStrikes = 0
        numberBalls = 0
    }
    
    func resetInning() {
        resetCount()
        clearBases()
        numberOuts = 0
    }
    
    func reset() {
    }

    func movePlayer(toBase base: Base, playerToMove player: RosterMember,
                    moveOtherPlayers: Bool = false) {
        switch base {
        case .First:
            if let player = playerOnFirst, moveOtherPlayers {
                movePlayer(toBase: .Second,
                           playerToMove: player,
                           moveOtherPlayers: moveOtherPlayers)
            }
            playerOnFirst = player
            break
        case .Second:
            if let player = playerOnSecond, moveOtherPlayers {
                movePlayer(toBase: .Third,
                           playerToMove: player,
                           moveOtherPlayers: moveOtherPlayers)
            }
            playerOnSecond = player
            break
        case .Third:
            if let player = playerOnThird, moveOtherPlayers {
                movePlayer(toBase: .Home,
                           playerToMove: player,
                           moveOtherPlayers: moveOtherPlayers)
            }
            playerOnThird = player
            break
        case .Home:
            addPointsToScore()
            break
        case .None:
            break
        }
    }
    
    func movePlayer(fromBase fbase: Base, toBase tbase: Base, playerToMove player: RosterMember) {
        switch fbase {
        case .First:
            if let currplayer = playerOnFirst, currplayer == player {
                clearBase(base: fbase)
            }
            break
        case .Second:
            if let currplayer = playerOnSecond, currplayer == player {
                clearBase(base: fbase)
            }
            break
        case .Third:
            if let currplayer = playerOnThird, currplayer == player {
                clearBase(base: fbase)
            }
            break
        case .Home:
            addPointsToScore()
            break
        default:
            break
        }
        movePlayer(toBase: tbase, playerToMove: player)
    }
    
    func addPointsToScore(amtToAdd amt: Int = 1) {
        if inningTotals.keys.contains("\(halfInning)") {
            inningTotals["\(halfInning)"]! += amt
        } else {
            inningTotals["\(halfInning)"] = amt
        }
    }
    
    func clearBases() {
        playerOnFirst = nil
        playerOnSecond = nil
        playerOnThird = nil
    }
    
    func getPlayerAtBase(base: Base) -> RosterMember? {
        switch base {
        case .First:
            return playerOnFirst
        case .Second:
            return playerOnSecond
        case .Third:
            return playerOnThird
        default:
            return nil
        }
    }
    
    func clearBase(base: Base) {
        switch base {
        case .First:
            playerOnFirst = nil
            break
        case .Second:
            playerOnSecond = nil
            break
        case .Third:
            playerOnThird = nil
            break
        default:
            break
        }
    }
    
    func markPlayerOnBaseOut(base: Base) -> RosterMember? {
        if let player = getPlayerAtBase(base: base) {
            clearBase(base: base)
            numberOuts += 1
            if GameEngine.endOfHalfInning(currentOuts: numberOuts) {
                resetInning()
            }
            return player
        }
        return nil
    }
    
    func markPlayerOut(player: RosterMember) {
        // Check if player is hitter
        numberOuts += 1
        if GameEngine.endOfHalfInning(currentOuts: numberOuts) {
            resetInning()
        }
    }
    
    func getLastPitchAction() -> PitchGameAction? {
        for event in Array(eventHistory.reversed()) {
            for action in event.actionsPerformed.reversed() {
                if action.getActionType() == .PitchAction {
                    return action as? PitchGameAction
                }
            }
        }
        return nil
    }
    
    func getHittingTeam() -> Team {
        return halfInning % 2 == 1 ? .Away : .Home
    }
    
    func getFieldingTeam() -> Team {
        return halfInning % 2 == 1 ? .Home : .Away
    }
    
    func generateGameSnapshoot() -> GameSnapshot {
        return GameSnapshot(halfInning: halfInning,
                            numberStrikes: numberStrikes,
                            numberBalls: numberBalls,
                            numberOuts: numberOuts,
                            playerOnFirst: playerOnFirst,
                            playerOnSecond: playerOnSecond,
                            playerOnThird: playerOnThird,
                            inningTotals: inningTotals,
                            homeLineupIndex: homeLineupIndex,
                            awayLineupIndex: awayLineupIndex,
                            plateAppearance: currentPA.paNumber,
                            atBatNum: atBatNum)
    }
    
    func addEvent(event: GameEventBase) {
        eventHistory.append(event)
        currentPA.events.append(event.eventNum)
    }
    
    func updateGameInfo() {
//        APIManager.updateGameInfo(gameID: game.gameID, homeTeamID: game.homeTeamID,
//          awayTeamID: game.awayTeamID, gameDate: game.gameDate,
//          gameStartHour: game.gameStartHour, gameStartMinute: game.gameStartMinute,
//          seasonID: game.seasonID, gameLocation: "",
//          homeLineupID: game.homeTeamLineupID, awayLineupID: game.awayTeamLineupID)
    }
    
    func saveLineups() {
        if game.gameState == 0 {
            FirebaseManager.clearLineup(gameUID: game.gameID, teamUID: game.homeTeamID, line: game.homeTeamLineupID) { [self] in
                game.homeTeamLineupID = FirebaseManager.saveLineup(gameUID: self.game.gameID,
                                                                   teamUID: self.game.homeTeamID,
                                                                   line: self.game.homeTeamLineupID,
                                                                   lineup: &self.homeLineup)
            }
            FirebaseManager.clearLineup(gameUID: game.gameID, teamUID: game.awayTeamID, line: game.awayTeamLineupID) { [self] in
                game.awayTeamLineupID = FirebaseManager.saveLineup(gameUID: self.game.gameID,
                                                                   teamUID: self.game.awayTeamID,
                                                                   line: self.game.awayTeamLineupID,
                                                                   lineup: &self.awayLineup)
            }
        } else {
            game.homeTeamLineupID = FirebaseManager.saveLineup(gameUID: game.gameID,
                                       teamUID: game.homeTeamID,
                                       line: nil,
                                       lineup: &homeLineup)
            game.awayTeamLineupID = FirebaseManager.saveLineup(gameUID: game.gameID,
                                       teamUID: game.awayTeamID,
                                       line: nil,
                                       lineup: &awayLineup)
        }
    }
    
    
    func getNumberOfPitches(forPitcher person: RosterMember) -> Int {
        var num: Int = 0
        for event in events {
            if event.value.pitcher == person {
                for action in event.value.actionsPerformed {
                    if action.getActionType() == .PitchAction {
                        num += 1
                    }
                }
            }
        }
        return num
    }

    func undo() {
//        if let last = eventHistory.last {
//            if let first = last.actionsPerformed.first,
//               let state = first.stateOfGameBeforeEvent {
//                setState(snapshot: state)
//                self.eventHistory = eventHistory.dropLast()
//                GameEngine.actionNum = first.actionNum!
//            }
//        }
    }
}

struct GameEngine {
    
    static var actionNum: Int = 0
    static var eventNum: Int = 1
    
    static func outOnStrikes(currentStrikes: Int) -> Bool {
        return currentStrikes >= 3
    }
    
    static func endOfHalfInning(currentOuts: Int) -> Bool {
        return currentOuts >= 3
    }
    
    static func walkOnBalls(currentBalls: Int) -> Bool {
        return currentBalls >= 4
    }
    
    static func processEvent(gameViewModel: GameViewModel,
                             gameState: GameStateViewModel) {
        print("Processing event...")
        if let pitcher = gameViewModel.pitcher,
           let hitter = gameViewModel.hitter {
            var event = gameState.event
            event.pitcher = pitcher
            event.hitter = hitter
            event.eventNum = GameEngine.eventNum
            event.stateOfGameBefore = gameViewModel.generateGameSnapshoot()
            event.pitcherThrowingHand = gameViewModel.pitchingHand
            event.hitterThrowingHand = gameViewModel.hitterHand
            event.pitcherStyle = gameViewModel.style
            event.paNumber = gameViewModel.currentPA.paNumber
            event.gameID = gameViewModel.game.gameID
            event.teamIDs = [gameViewModel.game.awayTeamID,
                             gameViewModel.game.homeTeamID]
            gameViewModel.addEvent(event: event)
            for actionIndex in 0..<event.actionsPerformed.count {
                event.actionsPerformed[actionIndex].actionNum = actionNum
                let action = event.actionsPerformed[actionIndex]
                action.performAction(gameViewModel: gameViewModel,
                                     gameState: gameState)
                actionNum += 1
            }
            eventNum += 1
            FirebaseManager.saveGameEvent(gameID: gameViewModel.game.gameID,
                                          event: event)
            gameViewModel.checkGameState()
            gameViewModel.bipOrder = ""
            gameState.resetRunnerState()
            gameState.event = GameEventBase()
            FirebaseManager.setGameState(gameID: gameViewModel.game.gameID,
                                 snapshot: gameViewModel.generateGameSnapshoot())
        }
        
    }
    
}

struct GameSnapshot {
    
    var halfInning: Int
    
    var numberStrikes: Int
    var numberBalls: Int
    var numberOuts: Int
    
    var playerOnFirst: RosterMember?
    var playerOnSecond: RosterMember?
    var playerOnThird: RosterMember?
    
    var inningTotals: [String: Int]
    
    var homeLineupIndex: Int
    var awayLineupIndex: Int
    
    var plateAppearance: Int
    
    var atBatNum: Int
    
    static func loadFromDictionary(dict: [String: Any]) -> GameSnapshot? {
        if let halfInning = dict["half_inning"] as? Int,
           let numberStrikes = dict["number_strikes"] as? Int,
           let numberBalls = dict["number_balls"] as? Int,
           let numberOuts = dict["number_outs"] as? Int,
           let inningTotals = dict["inning_totals"] as? [String: Int],
           let homeLineupIndex = dict["home_lineup_index"] as? Int,
           let awayLineupIndex = dict["away_lineup_index"] as? Int,
           let atBatNum = dict["at_bat_num"] as? Int,
           let pa = dict["plate_appearance"] as? Int {
            var snapshot = GameSnapshot(halfInning: halfInning,
                                       numberStrikes: numberStrikes,
                                       numberBalls: numberBalls,
                                       numberOuts: numberOuts,
                                       playerOnFirst: nil,
                                       playerOnSecond: nil,
                                       playerOnThird: nil,
                                       inningTotals: inningTotals,
                                       homeLineupIndex: homeLineupIndex,
                                       awayLineupIndex: awayLineupIndex,
                                       plateAppearance: pa,
                                       atBatNum: atBatNum)
            if let id = dict["player_on_first_id"] as? String,
               let data = dict["player_on_first"] as? [String: Any] {
                snapshot.playerOnFirst = RosterMember.loadFromDictionary(dict: data,
                                                                         id: id)
            }
            if let id = dict["player_on_second_id"] as? String,
               let data = dict["player_on_second"] as? [String: Any] {
                snapshot.playerOnSecond = RosterMember.loadFromDictionary(dict: data,
                                                                         id: id)
            }
            if let id = dict["player_on_third_id"] as? String,
               let data = dict["player_on_third"] as? [String: Any] {
                snapshot.playerOnThird = RosterMember.loadFromDictionary(dict: data,
                                                                         id: id)
            }
            return snapshot
        }
        return nil
    }
    
    func package() -> [String: Any] {
        var package: [String: Any] = [:]
        package["half_inning"] = halfInning
        package["number_strikes"] = numberStrikes
        package["number_balls"] = numberBalls
        package["number_outs"] = numberOuts
        package["inning_totals"] = inningTotals
        package["home_lineup_index"] = homeLineupIndex
        package["away_lineup_index"] = awayLineupIndex
        package["at_bat_num"] = atBatNum
        package["plate_appearance"] = plateAppearance
        if let id = playerOnFirst {
            package["player_on_first_id"] = id.personID
            package["player_on_first"] = id.package()
        }
        if let id = playerOnSecond{
            package["player_on_second_id"] = id.personID
            package["player_on_second"] = id.package()
        }
        if let id = playerOnThird {
            package["player_on_third_id"] = id.personID
            package["player_on_third"] = id.package()
        }
        return package
    }
}

enum Base: Int {
    case First = 1
    case Second = 2
    case Third = 3
    case Home = 4
    case None = 5
    
    func getStringShortRep() -> String {
        switch self {
        case .First:
            return "1st"
        case .Second:
            return "2nd"
        case .Third:
            return "3rd"
        case .Home:
            return "Home"
        case .None:
            return "None"
        }
    }
    
    func getStringLongRep() -> String {
        switch self {
        case .First:
            return "First"
        case .Second:
            return "Second"
        case .Third:
            return "Third"
        case .Home:
            return "Home"
        case .None:
            return "None"
        }
    }
}

enum Team {
    case Home
    case Away
    
    func toString() -> String {
        switch self {
        case .Home:
            return "Home"
        case .Away:
            return "Away"
        }
    }
}
