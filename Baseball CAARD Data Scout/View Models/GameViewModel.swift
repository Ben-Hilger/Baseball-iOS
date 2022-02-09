//
//  GameViewModel.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/7/21.
//

import Foundation

class GameStaticViewModel: ObservableObject {
    
    @Published var pitches: [PitchThrown] = []
    @Published var outcomes: [PitchOutcome] = []
    @Published var positions: [Position] = []
    @Published var hands: [Hand] = [.Left, .Right]
    @Published var style: [PitchingStyle] = [.Stretch, .Windup]
    
    @Published var awayRoster: [RosterMember] = []
    @Published var homeRoster: [RosterMember] = []
    
    init() {
        // Set the pitches
        loadPitches()
        loadOutcomes()
        loadPositions()
        loadTeamInformation()
    }
    
    func loadTeamInformation() {
        loadAwayTeam(teamID: "9ACmrOkyhAWPozuPzFmE", seasonID: "rwEdAhSrSyQDWch3tgRJ")
        loadHomeTeam(teamID: "9ACmrOkyhAWPozuPzFmE", seasonID: "rwEdAhSrSyQDWch3tgRJ")
    }
    
    func loadPitches() {
        FirebaseManager.getPitches { pitches in
            DispatchQueue.main.async {
                self.pitches = pitches
            }
        }
    }
    
    func loadPositions() {
        FirebaseManager.getPositions { positions in
            DispatchQueue.main.async {
                self.positions = positions
            }
        }
    }
    
    func loadOutcomes() {
        self.outcomes = []
        FirebaseManager.getPitchOutcomes { outcomes in
            for var outcome in outcomes {
                FirebaseManager.getPitchOutcomeSection1(outcomeID: outcome.outcomeID) { specific in
                        outcome.specificOptions = specific
                        FirebaseManager.getPitchOutcomeSection2(outcomeID: outcome.outcomeID) { extra in
                                outcome.extraInfoOption = extra
                            DispatchQueue.main.async {
                                self.outcomes.append(outcome)
                            }
                        }
                    
                }
            }
        }
    }
    
    func loadAwayTeam(teamID: String, seasonID: String) {
        print("Getting team roster for team: \(teamID) in season: \(seasonID)")
        FirebaseManager.getTeamRoster(teamID: teamID, seasonID: seasonID) { members in
            DispatchQueue.main.async {
                self.awayRoster = members
            }
        }
    }
    
    func loadHomeTeam(teamID: String, seasonID: String) {
        FirebaseManager.getTeamRoster(teamID: teamID, seasonID: seasonID) { members in
            DispatchQueue.main.async {
                self.homeRoster = members
            }
        }
    }
}
