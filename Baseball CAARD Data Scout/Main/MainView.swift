//
//  MainView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/3/21.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    Text("Baseball CAARD")
                        .font(.system(size: 50))
                        .foregroundColor(.black)
                    HStack {
                        NavigationLink(destination: GameSelectionView(teamID: "9ACmrOkyhAWPozuPzFmE")) {
                            Text("Game")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            .frame(width: geometry.size.width * 0.4,
                                   height: geometry.size.height * 0.8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.red, lineWidth: 5)
                                    )
                        }
                        Spacer()
                        NavigationLink(destination: GameView()) {
                            Text("Reports")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                                .frame(width: geometry.size.width * 0.4,
                                       height: geometry.size.height * 0.8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.red, lineWidth: 5)
                                        )
                        }
                    }
                }
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
