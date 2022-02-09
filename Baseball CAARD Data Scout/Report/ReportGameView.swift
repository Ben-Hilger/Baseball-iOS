//
//  GameSelectionView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/4/21.
//

import SwiftUI

struct ReportGameSelectionView: View {
    
    @StateObject var viewModel: GameSelectionViewModel = GameSelectionViewModel()
       
    @State var teamID: String
    
    var body: some View {
        List {
            ForEach(viewModel.games, id: \.self) { game in
                ReportGameSelectionCellView(game: game)
            }
        }.navigationTitle(Text("Games"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: Button {
            
        } label: {
            Image(systemName: "plus.rectangle")
        }).onAppear {
            viewModel.loadGames(forTeam: teamID)
        }
    }
}

struct ReportGameSelectionCellView: View {
    
    var game: Game
    
    var body: some View {
        NavigationLink(destination: GameDetailMainView(game: game)) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(game.awayTeamName) vs \(game.homeTeamName)")
                        .font(.system(size: 20))
                        .padding([.top, .leading, .trailing])
                    Text("\(game.gameLocation ?? "No Location Given")")
                        .padding([.leading])
                }
                Spacer()
                Text("\(getGameTime()) @ \(game.gameStartHour):\(game.gameStartMinute)")
                    .padding()
            }
        }
    }
    
    func getGameTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/DD/YYYY"
        return formatter.string(from: game.gameDate)
    }
}
