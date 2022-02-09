//
//  PitchingChartSelectionView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/18/21.
//

import SwiftUI
import MessageUI

struct NewPitchingChartView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
    
    @State var selectedPitcher: RosterMember? = nil

    @State var pitchers: [RosterMember] = []
    @State var pitches: [GameAction] = []
    @State var events: [GameEventBase] = []
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    @State var pdfFile: URL! = nil
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Text("Pitchers")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .border(Color.black, width: 1)
                        List {
                            ForEach(pitchers, id: \.self) { pitcher in
                                PitchingChartPitcherCell(pitcher: pitcher,
                                             selectedPitcher: $selectedPitcher)
                            }
                        }
                    }.frame(width: geometry.size.width * 0.3,
                            height: geometry.size.height * 0.5, alignment: .center)
                    .border(Color.black, width: 5)
                    VStack(spacing: 0) {
                        Text("Totals")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .border(Color.black, width: 1)
                        TabView {
                            PitchingChartTotals(hand: [.Left],
                                                pa: Array(gameViewModel.pa.values),
                                                events: gameViewModel.events)
                                .tabItem {
                                    Text("LHH")
                                }
                            PitchingChartTotals(hand: [.Right],
                                                pa: Array(gameViewModel.pa.values),
                                                events: gameViewModel.events)
                                .tabItem {
                                    Text("RHH")
                                }
                            PitchingChartTotals(hand: [.Left, .Right],
                                                pa: Array(gameViewModel.pa.values),
                                                events: gameViewModel.events)
                                .tabItem {
                                    Text("Total")
                                }
                        }
                    }.frame(width: geometry.size.width * 0.3,
                               height: geometry.size.height * 0.5, alignment: .center)
                    .border(Color.black, width: 5)
                }.frame(width: geometry.size.width * 0.3,
                        height: geometry.size.height, alignment: .center)
                VStack(alignment: .leading) {
                    HStack {
                        Text("Pitching Chart")
                            .font(.system(size: 35))
                            .padding()
                        Spacer()
                        Button {
                            exportToPDF()
                        } label: {
                            Text("Export to PDF")
                                .padding()
                        }
                    }
                    .border(Color.black, width: 3)
                    PitchingChartHeader(font: 15)
                        .frame(width: geometry.size.width * 0.65,
                               height: geometry.size.height * 0.1, alignment: .center)
                    List {
                        ForEach(0..<events.count, id: \.self) { index in
                            ForEach(0..<events[index].actionsPerformed.count, id: \.self) { action in
                                if events[index].actionsPerformed[action].getActionType() == .PitchAction {
                                    PitchingChartRowCell(action: $events[index].actionsPerformed[action],
                                                         event: $events[index],
                                                         showHitterText: true,
                                                         font: 15)
                                        .frame(width: geometry.size.width * 0.65,
                                               height: geometry.size.height * 0.15, alignment: .center)
                                }
                                
                            }
                            
//                            if let outcome = pitches[index].pitchOutcome,
//                               let state = pitches[index].stateOfGameBeforeEvent,
//                               outcome.outsToAdd+state.numberOuts >= 3 ||
//                                (state.numberOuts == 2 &&
//                                    (pitches[index].extraInfo1?.markHitterAsOut ?? false ||
//                                    pitches[index].extraInfo2?.markHitterAsOut ?? false)) {
//                                Text("End of Half Inning")
//                                    .font(.system(size: 20))
//                                    .frame(width: geometry.size.width * 0.7,
//                                           height: geometry.size.height * 0.15, alignment: .center)
//                                    .padding()
////                                    .padding()
//                                    .border(Color.black)
//                            }
                        }
                    }
                }.frame(width: geometry.size.width * 0.7,
                        height: geometry.size.height, alignment: .center)
                
                
            }
            
        }.onAppear {
            pitchers = getAllPitchers()
        }.onChange(of: selectedPitcher) { pitcher in
            if let pitcher = pitcher {
                // pitches = getAllPitchersForPitcher(pitcher: pitcher)
                events = getAllEventsForPitcher(pitcher: pitcher)
                print(pitches.count)
            }
        }.sheet(isPresented: $isShowingMailView) {
            PDFViewUI(url: $pdfFile)
        }
    }
    
    func getAllPitchers() -> [RosterMember] {
        var pitchers: Set<RosterMember> = Set()
        for event in gameViewModel.events.values {
            pitchers.insert(event.pitcher)
        }
        return Array(pitchers)
    }
    
    func getAllEventsForPitcher(pitcher: RosterMember) -> [GameEventBase] {
        var events: [GameEventBase] = []
        for event in gameViewModel.events.values {
            if event.pitcher == pitcher {
                for action in event.actionsPerformed {
                    if action.getActionType() == .PitchAction {
                        events.append(event)
                    }
                }
            }
        }
        events.sort { base1, base2 in
            base1.eventNum < base2.eventNum
        }
        return events
    }
    
    func getAllPitchersForPitcher(pitcher: RosterMember) -> [GameAction] {
        var pitches: [GameAction] = []
        for event in gameViewModel.events.values {
            if event.pitcher == pitcher {
                for action in event.actionsPerformed {
                    if action.getActionType() == .PitchAction {
                        pitches.append(action)
                    }
                }
            }
        }
        return pitches.reversed()
    }
    
    
    func exportToPDF() {
        let outputFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PitchingChart.pdf")
        guard let selectedPitcher = selectedPitcher else {
            return
        }
        
        //Normal with
        let width: CGFloat = 8.5 * 72.0
        //Estimate the height of your view
        let height: CGFloat = 1000
            
        let arraySplt = Int(ceil(Double(pitches.count)/11.0))
        let totalArraySplit = Int(ceil(Double(pitches.count)/3.0))
        
        //Render the PDF
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 8.5 * 72.0, height: height))

        do {
            try pdfRenderer.writePDF(to: outputFileURL, withActions: { (context) in
                
                for arrayIndex in 0..<(arraySplt) {
                    context.beginPage()
                    let charts = PitchingChartPDFView(pitcherViewing: selectedPitcher,
                                                isLimitingBy: 11,
                                                isStartingAt: arrayIndex * 11,
                                                pitches: pitches,
                                                event: GameEventBase())
                        .frame(maxWidth: .infinity)
                    let pdfVC = UIHostingController(rootView: charts)
                    pdfVC.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
                    //Render the view behind all other views
                    let rootVC = UIApplication.shared.windows.first?.rootViewController
                    rootVC?.addChild(pdfVC)
                    rootVC?.view.insertSubview(pdfVC.view, at: 0)
                    pdfVC.view.layer.render(in: context.cgContext)
                    pdfVC.removeFromParent()
                    pdfVC.view.removeFromSuperview()
                }
                context.beginPage()
                let charts = PitchingChartPDFTotals(pa: Array(gameViewModel.pa.values),
                                                    events: gameViewModel.events)
                    .frame(maxWidth: .infinity)
                let pdfVC = UIHostingController(rootView: charts)
                pdfVC.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
                //Render the view behind all other views
                let rootVC = UIApplication.shared.windows.first?.rootViewController
                rootVC?.addChild(pdfVC)
                rootVC?.view.insertSubview(pdfVC.view, at: 0)
                pdfVC.view.layer.render(in: context.cgContext)
                pdfVC.removeFromParent()
                pdfVC.view.removeFromSuperview()
            })
            
            print(outputFileURL)
            self.pdfFile = outputFileURL
            self.isShowingMailView = true
        }catch {
            // self.showError = true
            print("Could not create PDF file: \(error)")
        }
        
    }
}

struct PitchingChartHeader: View {
    
    var font: CGFloat! = nil
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Text("Batter +\nRHH/LHH")
                    .if(font != nil, transform: { text in
                        text.font(.system(size: font))
                    })
                    .frame(width: geometry.size.width/7, height: geometry.size.height * 0.6)
//                    .padding()
                    .border(Color.black)
                Text("Count")
                    .if(font != nil, transform: { text in
                        text.font(.system(size: font))
                    })
                    .frame(width: geometry.size.width/7, height: geometry.size.height * 0.6)
//                    .padding()
                    .border(Color.black)
                Text("STR?")
                    .if(font != nil, transform: { text in
                        text.font(.system(size: font))
                    })
                    .frame(width: geometry.size.width/7, height: geometry.size.height * 0.6)
//                    .padding()
                    .border(Color.black)
                Text("Pitch +\nLocation")
                    .if(font != nil, transform: { text in
                        text.font(.system(size: font))
                    })
                    .frame(width: geometry.size.width/7, height: geometry.size.height * 0.6)
//                    .padding()
                    .border(Color.black)
                Text("Strike?")
                    .if(font != nil, transform: { text in
                        text.font(.system(size: font))
                    })
                    .frame(width: geometry.size.width/7, height: geometry.size.height * 0.6)
//                    .padding()
                    .border(Color.black)
                Text("Velocity")
                    .if(font != nil, transform: { text in
                        text.font(.system(size: font))
                    })
                    .frame(width: geometry.size.width/7, height: geometry.size.height * 0.6)
//                    .padding()
                    .border(Color.black)
                Text("Outcome")
                    .if(font != nil, transform: { text in
                        text.font(.system(size: font))
                    })
                    .frame(width: geometry.size.width/7, height: geometry.size.height * 0.6)
//                    .padding()
                    .border(Color.black)
            }//.padding()
        }
        
    }
}

struct PitchingChartTotals: View {
    
    var hand: [Hand]
    var pa: [PlateAppearance]
    var events: [Int: GameEventBase]
    
    var body: some View {
        GeometryReader { geometry in
            List {
                HStack {
                    VStack(alignment: .leading) {
                        Text("FB K=\(calculateTotalStrikes(ofPitches: ["FA","FT"]))")
                        Text("S+M=\(calculateTotalSwingMiss(ofPitches: ["FA","FT"]))")
                    }
                    .frame(maxWidth: .infinity)
                    VStack {
                        Text("Total FB")
                        Text("\(calculateTotal(ofPitches: ["FA","FT"]))")
                    }.frame(maxWidth: .infinity)
                }
                .frame(width: geometry.size.width)
                HStack {
                    VStack(alignment: .leading) {
                        Text("BB K=\(calculateTotalStrikes(ofPitches: ["CU"]))")
                        Text("S+M=\(calculateTotalSwingMiss(ofPitches: ["CU"]))")
                    }
                    .frame(maxWidth: .infinity)
                    VStack {
                        Text("Total BB")
                        Text("\(calculateTotal(ofPitches: ["CU"]))")
                    }.frame(maxWidth: .infinity)
                }
                .frame(width: geometry.size.width)
                HStack {
                    VStack(alignment: .leading) {
                        Text("SL K=\(calculateTotalStrikes(ofPitches: ["SL"]))")
                        Text("S+M=\(calculateTotalSwingMiss(ofPitches: ["SL"]))")
                    }
                    .frame(maxWidth: .infinity)
                    VStack {
                        Text("Total SL")
                        Text("\(calculateTotal(ofPitches: ["SL"]))")
                    }.frame(maxWidth: .infinity)
                }
                .frame(width: geometry.size.width)
                HStack {
                    VStack(alignment: .leading) {
                        Text("CHUP K=\(calculateTotalStrikes(ofPitches: ["CH"]))")
                        Text("S+M=\(calculateTotalSwingMiss(ofPitches: ["CH"]))")
                    }
                    .frame(maxWidth: .infinity)
                    VStack{
                        Text("Total CHUP")
                        Text("\(calculateTotal(ofPitches: ["CH"]))")
                    }.frame(maxWidth: .infinity)
                }
                .frame(width: geometry.size.width)
                HStack {
                    Text("FP K=")
                        .frame(maxWidth: .infinity)
                    Text("\(getFirstPitchStrikes()) / \(getTotalFirstPitch())")
                        .frame(maxWidth: .infinity)
                }
                .frame(width: geometry.size.width)
                HStack {
                    Text("1-1 K=")
                        .frame(maxWidth: .infinity)
                    Text("\(get11StrikePercentage()) / \(getTotal11Pitches())")
                        .frame(maxWidth: .infinity)
                    
                }
                .frame(width: geometry.size.width)
            }
        }
    }
    
    func getFirstPitchStrikes() -> Int {
        var sum = 0
        for pa in pa {
            for event in pa.events {
                var foundPitch: Bool = false
                if let currentEvent = events[event] {
                    for action in currentEvent.actionsPerformed {
                        if action.getActionType() == .PitchAction {
                            if let outcome = action.pitchOutcome,
                               outcome.strikesToAdd > 0,
                               hand.contains(currentEvent.hitterThrowingHand) {
                                sum += 1
                            }
                            foundPitch = true
                            break
                        }
                    }
                }
                if foundPitch {
                    break
                }
            }
        }
        return sum
    }
    
    func getTotalFirstPitch() -> Int {
        var sum = 0
        for pa in pa {
            for event in pa.events {
                var foundPitch: Bool = false
                if let currentEvent = events[event] {
                    for action in currentEvent.actionsPerformed {
                        if action.getActionType() == .PitchAction,
                           hand.contains(currentEvent.hitterThrowingHand) {
                            sum += 1
                            foundPitch = true
                            break
                        }
                    }
                }
                if foundPitch {
                    break
                }
            }
        }
        return sum
    }
    
    func get11StrikePercentage() -> Int {
        var sum = 0
        for pa in pa {
            for event in pa.events {
                if let currentEvent = events[event] {
                    if currentEvent.stateOfGameBefore.numberBalls == 1,
                       currentEvent.stateOfGameBefore.numberStrikes == 1 {
                        for action in currentEvent.actionsPerformed {
                            if action.getActionType() == .PitchAction,
                               hand.contains(currentEvent.hitterThrowingHand),
                               let outcome = action.pitchOutcome,
                               outcome.strikesToAdd > 0 {
                                sum += 1
                            }
                        }
                    }
                }
            }
        }
        return sum
    }
    
    func getTotal11Pitches() -> Int {
        var sum = 0
        for pa in pa {
            for event in pa.events {
                if let currentEvent = events[event] {
                    if currentEvent.stateOfGameBefore.numberBalls == 1,
                       currentEvent.stateOfGameBefore.numberStrikes == 1 {
                        for action in currentEvent.actionsPerformed {
                            if action.getActionType() == .PitchAction,
                               hand.contains(currentEvent.hitterThrowingHand) {
                                sum += 1
                            }
                        }
                    }
                }
            }
        }
        return sum
    }
    
    func calculateTotalStrikes(ofPitches names: [String]) -> Int {
        var sum = 0
        for pa in pa {
            for event in pa.events {
                if let currentEvent = events[event] {
                    for action in currentEvent.actionsPerformed {
                        if action.getActionType() == .PitchAction,
                           hand.contains(currentEvent.hitterThrowingHand),
                           let outcome = action.pitchOutcome,
                           outcome.strikesToAdd > 0 {
                            sum += 1
                        }
                    }
                }
            }
        }
        return sum
    }
    
    func calculateTotalSwingMiss(ofPitches names: [String]) -> Int {
        var sum = 0
        for pa in pa {
            for event in pa.events {
                if let currentEvent = events[event] {
                    for action in currentEvent.actionsPerformed {
                        if action.getActionType() == .PitchAction,
                           hand.contains(currentEvent.hitterThrowingHand),
                           let outcome = action.pitchOutcome,
                           let extra1 = action.extraInfo1,
                           outcome.strikesToAdd > 0,
                           extra1.shortName == "SW",
                           outcome.shortName == "STR" {
                            sum += 1
                        }
                    }
                }
            }
        }
        return sum
    }
    
    func calculateTotal(ofPitches names: [String]) -> Int {
        var sum = 0
        for pa in pa {
            for event in pa.events {
                if let currentEvent = events[event] {
                    for action in currentEvent.actionsPerformed {
                        if action.getActionType() == .PitchAction,
                           hand.contains(currentEvent.hitterThrowingHand) {
                            sum += 1
                        }
                    }
                }
            }
        }
        return sum

    }
    
}

enum EditState {
    case Pitch
    case Count
    case Velo
    case None
}
struct PitchingChartRowCell: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel

    @Binding var action: GameAction
    @Binding var event: GameEventBase
    var showHitterText: Bool
    
    var font: CGFloat
    
    var pdfMode: Bool = false
    
    @State var changeHitter: Bool = false
    @State var changeCount: Bool = false
    @State var changeStretch: Bool = false
    @State var changePitchLoc: Bool = false
    @State var changePitchOutcome: Bool = false
    @State var changePitchVelo: Bool = false

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Text("\(getHitterText()) - \(event.eventNum)")
                    .font(.system(size: showHitterText ? font * 0.75 : font))
                     .frame(width: geometry.size.width/7, height: geometry.size.height * 0.6)
                    .border(Color.black)
                    .onTapGesture {
                        self.changeHitter = true
                    }
                    .actionSheet(isPresented: $changeHitter) {
                        ActionSheet(title: Text("Change Hitter"), message: Text("Select the new hitter below"), buttons: getHitters())
                    }
                Text(getCount())
                    .font(.system(size: font))
                    .frame(width: geometry.size.width/7, height: geometry.size.height * 0.6)
                    .border(Color.black)
                    .onTapGesture {
                        self.changePitchVelo = true
                    }.actionSheet(isPresented: $changePitchVelo) {
                        ActionSheet(title: Text("Change Hand"), message: Text("Select the new hand below"), buttons: getHand())
                    }
                Image(systemName: getIsSTRText())
                    .font(.system(size: font))
                    .frame(width: geometry.size.width/7, height: geometry.size.height * 0.6)
                    .border(Color.black)
                    .onTapGesture {
                        self.changeStretch = true
                    }
                    .actionSheet(isPresented: $changeStretch) {
                        ActionSheet(title: Text("Change Style"), message: Text("Select the new style below"), buttons: getStyle())
                    }
                Text("\(getPitchNumber())-\(getLocationNumber())")
                    .font(.system(size: font))
                    .frame(width: geometry.size.width/7, height: geometry.size.height * 0.6)
                    .border(Color.black)
                    .onTapGesture {
                        self.changePitchLoc = true
                    }
                ZStack {
                    GeometryReader { innerGeo in
                        Image(systemName: "circle")
                            .font(.system(size: font * 1.75))
                            .position(x: innerGeo.size.width * (isInZone() ? 0.65 : 0.9),
                                      y: innerGeo.size.height * 0.8)
                        Text("Z")
                            .font(.system(size: font))
                            .position(x: innerGeo.size.width * 0.65, y: innerGeo.size.height * 0.8)
                        Text("O")
                            .font(.system(size: font))
                            .position(x: innerGeo.size.width * 0.9, y: innerGeo.size.height * 0.8)
                        if let outcome = action.pitchOutcome,
                           let extraInfo1 = action.extraInfo1 {
                            if extraInfo1.shortName == "LK",
                               outcome.strikesToAdd > 0 {
                                Image(systemName: "multiply")
                                    .font(.system(size: font * 2))
                                    .position(x: innerGeo.size.width * 0.5, y: innerGeo.size.height * 0.5)
                            } else if extraInfo1.shortName == "SW",
                                      outcome.strikesToAdd > 0,
                                      !outcome.isFB {
                                Image(systemName: "multiply.circle")
                                    .font(.system(size: font * 2.5))
                                    .position(x: innerGeo.size.width * 0.5, y: innerGeo.size.height * 0.5)
                            } else if outcome.shortName == "FB",
                                      outcome.strikesToAdd > 0 {
                                Text("xf")
                                    .font(.system(size: font * 2))
                                    .position(x: innerGeo.size.width * 0.5, y: innerGeo.size.height * 0.5)
                            } else if outcome.isBIP {
                                Image(systemName: "checkmark")
                                    .font(.system(size: font * 2.5))
                                    .position(x: innerGeo.size.width * 0.5, y: innerGeo.size.height * 0.5)
                            } else {
                                Text(" ")
                                    .font(.system(size: font))
                                    .position(x: innerGeo.size.width * 0.5, y: innerGeo.size.height * 0.5)
                            }
                        }
                    }
                   
                }.frame(width: geometry.size.width/7, height: geometry.size.height * 0.6)
                .border(Color.black)
                .onTapGesture {
                    self.changePitchOutcome = true
                }
                .actionSheet(isPresented: $changePitchOutcome) {
                    ActionSheet(title: Text("Change Outcome"), message: Text("Select the new outcome below"), buttons: getOutcomes())
                }
                Text("\(action.pitchVelocity == nil ? " " : String(Int(action.pitchVelocity!)))")
                    .font(.system(size: font))
                    .frame(width: geometry.size.width/7, height: geometry.size.height * 0.6)
                    .border(Color.black)
                ZStack {
                    GeometryReader { innerGeometry in
                        Text(getResultText())
                            .font(.system(size: font))
                            .position(x: innerGeometry.size.width * 0.3,
                                      y: innerGeometry.size.height * 0.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .multilineTextAlignment(.center)
                            .lineLimit(5)
                        if let result = getBIPInfoText() {
                            Image(systemName: "circle")
                                .font(.system(size: font * 2))
                                .position(x: innerGeometry.size.width * 0.85,
                                          y: innerGeometry.size.height * 0.5)

                            Text("\(result)")
                                .font(.system(size: font))
                                .position(x: innerGeometry.size.width * 0.85, y: innerGeometry.size.height * 0.5)
                            
//                            Text("LD")
//                                .font(.system(size: font))
//                                .position(x: innerGeometry.size.width * 0.99, y: innerGeometry.size.height * 0.5)
//                            Text("GB")
//                                .font(.system(size: font))
//                                .position(x: innerGeometry.size.width * 0.99, y: innerGeometry.size.height * (pdfMode ? -2 : -0.4))
                        }
                        
                    }
                }.frame(width: geometry.size.width/7, height: geometry.size.height * 0.6)
//                .padding()
                .if(isOut(), transform: { view in
                    view.border(Color.black, width: 5)
                })
                .if(!isOut(), transform: { view in
                    view.border(Color.black)
                })
            }
//            }.popover(isPresented: Binding(get: {
//                return changeCount || changePitchLoc || changePitchVelo
//            }, set: { val in
//                changeCount = false
//                changePitchLoc = false
//                changePitchVelo = false
//            })) {
//                if changeCount {
//                    PitchingChartCountChangeView(event: $event)
//                } else if changePitchVelo {
//                    PitchingChartVelocityView(event: Binding(get: {
//                        if let velo = action.pitchVelocity {
//                            return String(velo)
//                        }
//                        return String("")
//                    }, set: { val in
//                        if let value = Float(val) {
//                            action.pitchVelocity = value
//                        }
//                    }) )
//                } else if changePitchLoc {
//                    PitchingChartChangeLocation(action: $action)
//                        .frame(width: geometry.size.width/2, height: geometry.size.height/2)
//                }
//            }
        }
    }
    
    func getHitters() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        for hitter in gameStaticViewModel.homeRoster {
            buttons.append(ActionSheet.Button.default(Text("\(hitter.getFullName())"), action: {
                event.hitter = hitter
                FirebaseManager.saveGameEvent(gameID: gameViewModel.game.gameID, event: event)
            }))
        }
        return buttons
    }
    
    func getStyle() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        buttons.append(ActionSheet.Button.default(Text("Stretch"), action: {
            event.pitcherStyle = .Stretch
            FirebaseManager.saveGameEvent(gameID: gameViewModel.game.gameID, event: event)
        }))
        buttons.append(ActionSheet.Button.default(Text("Windup"), action: {
            event.pitcherStyle = .Windup
            FirebaseManager.saveGameEvent(gameID: gameViewModel.game.gameID, event: event)
        }))
        return buttons
    }
    
    func getHand() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        buttons.append(ActionSheet.Button.default(Text("LHH"), action: {
            event.hitterThrowingHand = .Left
            FirebaseManager.saveGameEvent(gameID: gameViewModel.game.gameID, event: event)
        }))
        buttons.append(ActionSheet.Button.default(Text("RHH"), action: {
            event.hitterThrowingHand = .Right
            FirebaseManager.saveGameEvent(gameID: gameViewModel.game.gameID, event: event)
        }))
        return buttons
    }
    
    func getOutcomes() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        for outcome in gameStaticViewModel.outcomes {
            buttons.append(ActionSheet.Button.default(Text("\(outcome.longName)"), action: {
                for action in 0..<event.actionsPerformed.count {
                    if event.actionsPerformed[action].actionNum == self.action.actionNum {
                        event.actionsPerformed[action].pitchOutcome = outcome
                    }
                }
                FirebaseManager.saveGameEvent(gameID: gameViewModel.game.gameID, event: event)
            }))
        }
        return buttons
    }
    
    func getResultY() -> CGFloat? {
        if let outcome = action.pitchOutcome,
           outcome.isBIP,
           let extra1 = action.extraInfo1 {
            if extra1.shortName == "GB" {
                return pdfMode ? 2 : 1.4
            } else if extra1.shortName == "LD" {
                return 0.5
            } else if extra1.shortName == "FB" {
                return pdfMode ? -2 : -0.4
            }
        }
        return nil
    }
    
    func getBIPInfoText() -> String? {
        if let outcome = action.pitchOutcome,
           outcome.isBIP,
           let extra1 = action.extraInfo1 {
            return extra1.shortName
        }
        return nil
    }
    
    func getHitterText() -> String {
        if showHitterText {
            return "\(event.hitter.getFullName())\n\((event.hitterThrowingHand ?? .Right).getShortName())H"
        } else {
            return " "
        }
    }
    
    func getCount() -> String {
        if let state = event.stateOfGameBefore {
            return "\(state.numberBalls)-\(state.numberStrikes)"
        }
        return "0-0"
    }
    
    func getIsSTRText() -> String {
        if let style = event.pitcherStyle,
           style.getShortName() == "STR" {
            return "checkmark"
        }
        return "multiply"
    }
    
    func isInZone() -> Bool {
        let locationX = getLocationNumberX()
        if let strikeY = action.strikeZoneYRelative {
            return (locationX == 2 || locationX == 3 || locationX == 4) &&
                (strikeY > 0.2 && strikeY <= 0.8)
        }
        return false
    }
    
    func isOut() -> Bool {
        if let outcome = action.pitchOutcome,
           let state = event.stateOfGameBefore {
            if state.numberStrikes + outcome.strikesToAdd >= 3,
               !outcome.isFB {
                return true
            }
        }
        if let extra1 = action.extraInfo1,
           extra1.markHitterAsOut {
            return true
        }
        if let extra2 = action.extraInfo2,
           extra2.markHitterAsOut {
            return true
        }
        return false
    }
    
    func getResultText() -> String {
        if let state = event.stateOfGameBefore,
           let outcome = action.pitchOutcome,
           let extra1 = action.extraInfo1 {
            if state.numberBalls + outcome.ballsToAdd >= 4 {
                return "BB"
            } else if state.numberStrikes + outcome.strikesToAdd  >= 3,
                      !outcome.isFB {
                if extra1.shortName == "SW" {
                    return "K"
                } else if extra1.shortName == "LK" {
                    return "ꓘ"
                }
            }
        }
        if let outcome = action.pitchOutcome,
           outcome.isBIP,
           let info = action.extraInfo1 {
            var val = info.shortName
            if let info2 = action.extraInfo2 {
                if info2.markHitterAsOut {
                    val = String(val.dropLast())
                } else {
                    val = "\(info2.shortName)-"
                }
            }
            if let order = action.bipOrder, order != "" {
                val += order
            }
            return val
        } else if action.pitchOutcome?.isHBP ?? false {
            return "HBP"
        }
        return " "
    }
    
    func getPitchNumber() -> String {
        return action.pitchThrown?.numberRep ?? action.pitchThrown?.shortName ?? ""
    }
    
    func getLocationNumber() -> String {
        guard let y = action.strikeZoneYRelative, let x = action.strikeZoneXRelative else {
            return " "
        }
        return y <= 0.2 ? "7" : y >= 0.8 ? "6" : "\(getLocationNumberX())/\(getLocationY())"
    }
    
    func getLocationNumberX() -> Int {
        if let strikeX = action.strikeZoneXRelative {
            if strikeX <= 0.2 {
                return 1
            } else if strikeX <= 0.4 {
                return 2
            } else if strikeX <= 0.6 {
                return 3
            } else if strikeX <= 0.8 {
                return 4
            } else {
                return 5
            }
        }
        return 0
    }
    
    func getLocationY() -> String {
        if let strikeY = action.strikeZoneYRelative {
            if strikeY <= 0.2 {
                return "7"
            } else if strikeY >= 0.8 {
                return "6"
            } else if strikeY > 0.2 && strikeY <= 0.4 {
                return "u"
            } else if strikeY > 0.6 && strikeY < 0.8 {
                return "L"
            }
        }
        return ""
    }
}

struct PitchingChartChangeLocation: View {
    
    @EnvironmentObject var gameStaticViewModel: GameStaticViewModel
    
    @Binding var action: GameAction
    
    var body: some View {
        HStack {
            VStack {
                ForEach(gameStaticViewModel.pitches, id: \.self) { pitch in
                    Text("\(pitch.longName)")
                        .padding()
                        .border(Color.black)
                        .onTapGesture {
                            action.pitchThrown = pitch
                        }
                }
            }
            StrikeZoneView(xRelative: $action.strikeZoneXRelative, yRelative: $action.strikeZoneYRelative)
        }
    }
}

struct PitchingChartVelocityView: View {
    
    @Binding var event: String
    
    var body: some View {
        VStack {
            Text("\(event)")
            CalculatorView(valueToTrack: $event)
        }
    }
}

struct PitchingChartCountChangeView: View {
    
    @Binding var event: GameEventBase
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    event.stateOfGameBefore.numberStrikes -= 1
                } label: {
                    Text("-")
                        .padding()
                }
                Text("Strikes: \(event.stateOfGameBefore.numberStrikes)")
                Button {
                    event.stateOfGameBefore.numberStrikes += 1
                } label: {
                    Text("+")
                        .padding()
                }
            }
            HStack {
                Button {
                    event.stateOfGameBefore.numberBalls -= 1
                } label: {
                    Text("-")
                        .padding()
                }
                Text("Balls: \(event.stateOfGameBefore.numberBalls)")
                Button {
                    event.stateOfGameBefore.numberBalls += 1
                } label: {
                    Text("+")
                        .padding()
                }
            }
        }
    }
}

struct PitchingChartPitcherCell: View {
    
    var pitcher: RosterMember
    
    @Binding var selectedPitcher: RosterMember?
    
    var body: some View {
        Button {
            selectedPitcher = pitcher
        } label: {
            Text("\(pitcher.getFullName())")
                .padding()
                .if(selectedPitcher == pitcher) { view in
                    view.border(Color.black, width: 3)
                }
        }

    }
}

