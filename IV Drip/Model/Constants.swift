//
//  Constants.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import Foundation


enum ConcentrationOptions: String, CaseIterable {
    
    case mcgKgMin = "mcg/kg/min"
    case mcgKgHour = "mcg/kg/H"
    case mcgMin = "mcg/min"
    case mcgHour = "mcg/hour"
    
    case mgKgMin = "mg/kg/min"
    case mgKgHour = "mg/kg/hour"
    case mgMin = "mg/min"
    case mgHour = "mg/hour"
    
}

enum PushDoseOptions: String, CaseIterable {
    case mg = "mg"
    case mcg = "mcg"
    case mgKg = "mg/kg"
    case mcgKg = "mcg/kg"
    case unitsKg = "U/kg"
}

enum WeightOptions: String, CaseIterable {
    case grams = "g"
    case miligrams = "mg"
    case micrograms = "mcg"
}

enum InfusionRateOptions: String, CaseIterable {
    case mlHour = "ml/h"
    case mlMin = "ml/min"
}

enum MedDoseOptions: String, CaseIterable {
    case mg, mcg, mgKg, mgMin, mcgMin, mgKgHour, mgKgMin, mcgKgMin, unitsMin
}

struct Constants {
    
    struct AppStorage {
        static let patientWeight = "patientWeight"
    }
    
    struct Layout {
        
        enum buttonRadius: CGFloat {
            case small = 4
            case medium = 8
            case large = 16
        }
        
        enum cornerRadius: CGFloat {
            case small = 8
            case textbox = 10
            case medium = 16
            case large = 24
            case vLarge = 32
        }
        
        static let kPadding: CGFloat = 16
        static let textFieldHeight: CGFloat = 40
        
        enum buttonHeight: CGFloat {
            case small = 36
            case medium = 44
            case large = 52
        }
        
        enum buttonWidth: CGFloat {
            case small = 88
            case large = 120
        }
        
        enum fontSize: CGFloat {
            case inputRow = 12
        }
    }
    
}

enum RowType {
    case weight, drugInBag, volume, desiredRate, infusionVelocity, minimumDose, maximumDose, ampouleNumber, ampouleVolume, textInput
}

enum DilutionOptions: String, CaseIterable{
    case ns = "NS"
    case dw = "DW"
    case dextroseFive = "D5%"
    case dextroseTen = "D10%"
    case ringer = "RL"
}




