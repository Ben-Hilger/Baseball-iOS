//
//  GameSelectionViewModel.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/6/21.
//

import Foundation

class GameSelectionViewModel: ObservableObject {
    
    @Published var games: [Game] = []
    
    func loadGames(forTeam teamID: String) {
        FirebaseManager.getGamesForTeam(teamID: teamID) { games in
            DispatchQueue.main.async {
                self.games = games
            }
        }
    }
    
}
