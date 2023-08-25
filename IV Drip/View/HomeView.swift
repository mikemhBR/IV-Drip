//
//  HomeView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var navigationModel: NavigationModel
    
    var body: some View {
        VStack (spacing: 32) {
            Button {
                navigationModel.navigateTo(to: .calculatorView)
            } label: {
                Text("Quick Calculator")
            }
            
            Button {
                withAnimation {
                    navigationModel.navigateTo(to: .mySolutions)
                }
            } label: {
                Text("My Solutions")
            }


        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(NavigationModel.shared)
    }
}
