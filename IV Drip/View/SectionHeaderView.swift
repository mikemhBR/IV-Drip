//
//  SectionHeaderView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 22/08/23.
//

import SwiftUI

struct SectionHeaderView: View {
    
    let sectionTitle: String
    let onBackButtonPress: ()->()
    
    var body: some View {
        ZStack {
            Button {
                onBackButtonPress()
            } label: {
                
                Image(systemName: "arrow.backward.circle.fill")
                    .font(.system(size: 28))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("Text"))
                
                
            }
            
            Text(sectionTitle)
                .font(.system(size: 24, weight: .light))
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(Color("Text"))
        }
        
    }
}

struct SectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeaderView(sectionTitle: "Test Title") {
            
        }
        .environmentObject(NavigationModel.shared)
    }
}
