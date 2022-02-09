//
//  ReportMainView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/18/21.
//

import SwiftUI

struct ReportMainView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel

    
    @Binding var detailState: GameDetailState
    @State var reportState: ReportState = .Main
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if reportState == .PitchingChart {
                    NewPitchingChartView()
                        .frame(width: geometry.size.width,
                               height: geometry.size.height * 0.9, alignment: .center)
                }
                ReportSelectionAuxView(detailState: $detailState, reportState: $reportState)
                    .frame(width: geometry.size.width,
                               height: geometry.size.height * 0.1, alignment: .center)
            }
        }
        
    }
}

struct ReportSelectionAuxView: View {
    
    @Binding var detailState: GameDetailState
    @Binding var reportState: ReportState
    
    var body: some View {
        HStack {
            Button {
                detailState = .Detail
            } label: {
                Text("Back")
                    .foregroundColor(Color.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue, lineWidth: 5)
                            )
            }
            Spacer()
            Button {
                reportState = .PitchingChart
            } label: {
                Text("View Pitching Report")
                    .foregroundColor(Color.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue, lineWidth: 5)
                            )
            }
            Spacer()
            Button {
                reportState = .PitchingChart
            } label: {
                Text("View Accuracy Report")
                    .foregroundColor(Color.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue, lineWidth: 5)
                            )
            }
            Spacer()
        }
       
    }
}

struct ReportSelectionView: View {
        
    @EnvironmentObject var gameViewModel: GameViewModel

    @Binding var detailState: GameDetailState
    @Binding var reportState: ReportState

    var body: some View {
        Button {
            reportState = .PitchingChart
        } label: {
            Text("View Pitching Report")
                .foregroundColor(Color.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue, lineWidth: 5)
                        )
        }
        Button {
            detailState = .Detail
        } label: {
            Text("Back")
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

enum ReportState {
    case PitchingChart
    case Main
}
