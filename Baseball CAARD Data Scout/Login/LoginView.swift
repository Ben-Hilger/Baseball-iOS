//
//  LoginView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 8/7/21.
//

import Foundation
import SwiftUI

struct LoginView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Baseball CAARD")
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }.frame(width: geometry.size.width * 0.5,
                    height: geometry.size.height * 0.5,
                    alignment: .center)
            .border(Color.black, width: 2)
        }
        
    }
}
