//
//  NavigationModel.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI

class NavigationModel: ObservableObject {
    
    static let shared = NavigationModel()
        
    @Published private(set) var selectedModal: Modals = .homeView
    @Published private(set) var previousModal: Modals = .homeView
    
    @Published private(set) var showCustomSolutionMyMeds = false
    
    private init() {
       
    }
   
    func navigateTo(to modal: Modals) {
        previousModal = selectedModal
        selectedModal = modal
    }
    
    func showCustomSolutionMyMedsModal(isShown: Bool) {
        showCustomSolutionMyMeds = isShown
    }
}

enum Modals {
    case homeView
    case calculatorView
    case mySolutions
    case addCustomSolution
    case addMedication
}
