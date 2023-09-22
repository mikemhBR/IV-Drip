//
//  Constants.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import Foundation

enum DoseOptions: Hashable {
    
    case pushDose(PushDoseOptions)
    case concentrationDose(ConcentrationOptions)
    
    var rawValue: String {
        switch self {
        case .pushDose(let chosen):
            return chosen.rawValue
        case .concentrationDose(let chosen):
            return chosen.rawValue
        }
    }
    
    enum ConcentrationOptions: String, CaseIterable {
        
        case mcgKgMin = "mcg/kg/min"
        case mcgKgHour = "mcg/kg/H"
        case mcgMin = "mcg/min"
        case mcgHour = "mcg/hour"
        
        case mgKgMin = "mg/kg/min"
        case mgKgHour = "mg/kg/hour"
        case mgMin = "mg/min"
        case mgHour = "mg/hour"
        
        case unitsMin = "units/min"
        
    }

    enum PushDoseOptions: String, CaseIterable {
        
        case mg = "mg"
        case mcg = "mcg"
        case mgKg = "mg/kg"
        case mcgKg = "mcg/kg"
        case unitsKg = "U/kg"
        case units = "units"
        
    }
    
    static var allPushOptions: [DoseOptions] {
        return [
            .pushDose(.mg), .pushDose(.mcg), .pushDose(.mgKg), .pushDose(.mcgKg), .pushDose(.unitsKg), .pushDose(.units)
        ]
    }
    
    static var allInfusionOptions: [DoseOptions] {
        return [
            .concentrationDose(.mcgKgMin), .concentrationDose(.mcgKgHour), .concentrationDose(.mcgMin), .concentrationDose(.mcgHour), .concentrationDose(.mgKgMin), .concentrationDose(.mgKgHour), .concentrationDose(.mgMin), .concentrationDose(.mgHour), .concentrationDose(.unitsMin)
        ]
    }
}

enum ConcentrationOptions: String, CaseIterable {
    typealias T = ConcentrationOptions
    
    
    case mcgKgMin = "mcg/kg/min"
    case mcgKgHour = "mcg/kg/H"
    case mcgMin = "mcg/min"
    case mcgHour = "mcg/hour"
    
    case mgKgMin = "mg/kg/min"
    case mgKgHour = "mg/kg/hour"
    case mgMin = "mg/min"
    case mgHour = "mg/hour"
    
    case unitsMin = "units/min"
    
}

enum PushDoseOptions: String, CaseIterable {
    typealias T = PushDoseOptions
    
    case mg = "mg"
    case mcg = "mcg"
    case mgKg = "mg/kg"
    case mcgKg = "mcg/kg"
    case unitsKg = "U/kg"
    case units = "units"
    
}

enum WeightOptions: String, CaseIterable {
    case grams = "g"
    case miligrams = "mg"
    case micrograms = "mcg"
    case units = "units"
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
        static let kTextFieldPadding: CGFloat = 4
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
    case weight, drugInBag, volume, desiredRate, infusionVelocity, minimumDose, maximumDose, ampouleNumber, ampouleVolume, textInput, observation
}

enum DilutionOptions: String, CaseIterable{
    case ns = "NS"
    case dw = "DW"
    case dextroseFive = "D5%"
    case dextroseTen = "D10%"
    case ringer = "RL"
}


struct PushDoseStruct {
    let drugDose: Double
    let unitOfMeasure: PushDoseType
    
    enum PushDoseType {
        case byDrugWeight, byDrugAndPatient, byUnits, byUnitsAndWeight
    }
    
    init(initialValue: Double, inputUnitOfMeasure: PushDoseOptions) {
        switch inputUnitOfMeasure {
        case .mcg:
            drugDose = initialValue/1000
            unitOfMeasure = .byDrugWeight
        case .mg:
            drugDose = initialValue
            unitOfMeasure = .byDrugWeight
        case .mgKg:
            drugDose = initialValue
            unitOfMeasure = .byDrugAndPatient
        case .mcgKg:
            drugDose = initialValue/1000
            unitOfMeasure = .byDrugAndPatient
        case .unitsKg:
            drugDose = initialValue
            unitOfMeasure = .byUnitsAndWeight
        case .units:
            drugDose = initialValue
            unitOfMeasure = .byUnits
        }
    }
    
    func getConversion(desiredOutput: PushDoseOptions) -> Double? {
        switch desiredOutput {
        case .mg:
            if unitOfMeasure == .byDrugWeight {
                return drugDose
            } else {
                return nil
            }
        case .mcg:
            if unitOfMeasure == .byDrugWeight {
                return drugDose*1000
            } else {
                return nil
            }
        case .mgKg:
            if unitOfMeasure == .byDrugAndPatient {
                return drugDose
            } else {
                return nil
            }
        case .mcgKg:
            if unitOfMeasure == .byDrugAndPatient {
                return drugDose*1000
            } else {
                return nil
            }
        case .unitsKg:
            if unitOfMeasure == .byUnitsAndWeight {
                return drugDose
            } else {
                return nil
            }
        case .units:
            if unitOfMeasure == .byUnits {
                return drugDose
            } else {
                return nil
            }
        }
    }
}

protocol DoseProtocol {
    var drugDose: Double {get set}
    var doseString: String {get set}
    var unitOfMeasure: DoseOptions {get set}
}

//struct DatabasePushDoseStruct: DoseProtocol {
//
//    var drugDose: Double
//    var doseString: String
//    var unitOfMeasure: DoseOptions
//
//    init(initialValue: Double, databaseUnitOfMeasure: Int) {
//        drugDose = initialValue
//        doseString = NumberModel(value: initialValue, numberType: .dose).description
//
//        if databaseUnitOfMeasure == 110 {
//            unitOfMeasure = DoseOptions.pushDose(.mcg)
//        } else if databaseUnitOfMeasure == 120 {
//            unitOfMeasure = .mg
//        } else if databaseUnitOfMeasure == 210 {
//            unitOfMeasure = .mcgKg
//        } else if databaseUnitOfMeasure == 220 {
//            unitOfMeasure = .mgKg
//        } else if databaseUnitOfMeasure == 300 {
//            unitOfMeasure = .units
//        } else if databaseUnitOfMeasure == 410 {
//            unitOfMeasure = .unitsKg
//        } else {
//            unitOfMeasure = .units
//        }
//    }
//
//}

//TODO: test struct. delete if needed
struct DatabaseDoseStruct: DoseProtocol {
    var drugDose: Double
    var doseString: String
    var unitOfMeasure: DoseOptions
    var doseType: Int
    
    init(initialValue: Double, databaseUnitOfMeasure: Int) {
        drugDose = initialValue
        doseString = NumberModel(value: initialValue, numberType: .dose).description
        
        if databaseUnitOfMeasure == 110 {
            unitOfMeasure = DoseOptions.pushDose(.mcg)
            doseType = 0
        } else if databaseUnitOfMeasure == 120 {
            unitOfMeasure = DoseOptions.pushDose(.mg)
            doseType = 0
        } else if databaseUnitOfMeasure == 210 {
            unitOfMeasure = DoseOptions.pushDose(.mcgKg)
            doseType = 0
        } else if databaseUnitOfMeasure == 220 {
            unitOfMeasure = DoseOptions.pushDose(.mgKg)
            doseType = 0
        } else if databaseUnitOfMeasure == 300 {
            unitOfMeasure = DoseOptions.pushDose(.units)
            doseType = 0
        } else if databaseUnitOfMeasure == 410 {
            unitOfMeasure = DoseOptions.pushDose(.unitsKg)
            doseType = 0
        } else if databaseUnitOfMeasure == 511 {
            unitOfMeasure = DoseOptions.concentrationDose(.mcgMin)
            doseType = 1
        } else if databaseUnitOfMeasure == 512 {
            unitOfMeasure = DoseOptions.concentrationDose(.mcgHour)
            doseType = 1
        } else if databaseUnitOfMeasure == 521 {
            unitOfMeasure = DoseOptions.concentrationDose(.mgMin)
            doseType = 1
        } else if databaseUnitOfMeasure == 522 {
            unitOfMeasure = DoseOptions.concentrationDose(.mgHour)
            doseType = 1
        } else if databaseUnitOfMeasure == 611 {
            unitOfMeasure = DoseOptions.concentrationDose(.mcgKgMin)
            doseType = 1
        } else if databaseUnitOfMeasure == 612 {
            unitOfMeasure = DoseOptions.concentrationDose(.mcgKgHour)
            doseType = 1
        } else if databaseUnitOfMeasure == 621 {
            unitOfMeasure = DoseOptions.concentrationDose(.mgKgMin)
            doseType = 1
        } else if databaseUnitOfMeasure == 622 {
            unitOfMeasure = DoseOptions.concentrationDose(.mgKgHour)
            doseType = 1
        } else if databaseUnitOfMeasure == 710 {
            unitOfMeasure = DoseOptions.concentrationDose(.unitsMin)
            doseType = 1
        } else {
            unitOfMeasure = DoseOptions.concentrationDose(.unitsMin)
            doseType = 1
        }
    }
}

struct DatabasePushDoseStruct: DoseProtocol {
    
    var drugDose: Double
    var doseString: String
    var unitOfMeasure: DoseOptions
    
    init(initialValue: Double, unitOfMeasure: DoseOptions) {
        self.drugDose = initialValue
        self.doseString = NumberModel(value: initialValue, numberType: .dose).description
        self.unitOfMeasure = unitOfMeasure
    }
    
    init(initialValue: Double, databaseUnitOfMeasure: Int) {
        drugDose = initialValue
        doseString = NumberModel(value: initialValue, numberType: .dose).description
        
        if databaseUnitOfMeasure == 110 {
            unitOfMeasure = DoseOptions.pushDose(.mcg)
        } else if databaseUnitOfMeasure == 120 {
            unitOfMeasure = DoseOptions.pushDose(.mg)
        } else if databaseUnitOfMeasure == 210 {
            unitOfMeasure = DoseOptions.pushDose(.mcgKg)
        } else if databaseUnitOfMeasure == 220 {
            unitOfMeasure = DoseOptions.pushDose(.mgKg)
        } else if databaseUnitOfMeasure == 300 {
            unitOfMeasure = DoseOptions.pushDose(.units)
        } else if databaseUnitOfMeasure == 410 {
            unitOfMeasure = DoseOptions.pushDose(.unitsKg)
        } else {
            unitOfMeasure = DoseOptions.pushDose(.units)
        }
    }
    
    init(initialValue: Double, databaseUnitOfMeasure: PushDoseOptions) {
        drugDose = initialValue
        doseString = NumberModel(value: initialValue, numberType: .dose).description
        
        switch databaseUnitOfMeasure {
        case .mg:
            unitOfMeasure = DoseOptions.pushDose(.mg)
        case .mcg:
            unitOfMeasure = DoseOptions.pushDose(.mcg)
        case .mgKg:
            unitOfMeasure = DoseOptions.pushDose(.mgKg)
        case .mcgKg:
            unitOfMeasure = DoseOptions.pushDose(.mcgKg)
        case .unitsKg:
            unitOfMeasure = DoseOptions.pushDose(.unitsKg)
        case .units:
            unitOfMeasure = DoseOptions.pushDose(.units)
        }
    }
    
}

struct DatabaseInfusionDoseStruct {
    let drugDose: Double
    var doseString: String
    var unitOfMeasure: DoseOptions
    
    init(initialValue: Double, unitOfMeasure: DoseOptions) {
        self.drugDose = initialValue
        self.doseString = NumberModel(value: initialValue, numberType: .dose).description
        self.unitOfMeasure = unitOfMeasure
    }
    
    init(initialValue: Double, databaseUnitOfMeasure: Int) {
        drugDose = initialValue
        doseString = NumberModel(value: initialValue, numberType: .dose).description
        
        if databaseUnitOfMeasure == 511 {
            unitOfMeasure = DoseOptions.concentrationDose(.mcgMin)
        } else if databaseUnitOfMeasure == 512 {
            unitOfMeasure = DoseOptions.concentrationDose(.mcgHour)
        } else if databaseUnitOfMeasure == 521 {
            unitOfMeasure = DoseOptions.concentrationDose(.mgMin)
        } else if databaseUnitOfMeasure == 522 {
            unitOfMeasure = DoseOptions.concentrationDose(.mgHour)
        } else if databaseUnitOfMeasure == 611 {
            unitOfMeasure = DoseOptions.concentrationDose(.mcgKgMin)
        } else if databaseUnitOfMeasure == 612 {
            unitOfMeasure = DoseOptions.concentrationDose(.mcgKgHour)
        } else if databaseUnitOfMeasure == 621 {
            unitOfMeasure = DoseOptions.concentrationDose(.mgKgMin)
        } else if databaseUnitOfMeasure == 622 {
            unitOfMeasure = DoseOptions.concentrationDose(.mgKgHour)
        } else if databaseUnitOfMeasure == 710 {
            unitOfMeasure = DoseOptions.concentrationDose(.unitsMin)
        } else {
            unitOfMeasure = DoseOptions.concentrationDose(.unitsMin)
        }
        
    }
    
    init(initialValue: Double, databaseUnitOfMeasure: ConcentrationOptions) {
        drugDose = initialValue
        doseString = NumberModel(value: initialValue, numberType: .dose).description
        
        switch databaseUnitOfMeasure {
        case .mcgKgMin:
            unitOfMeasure = DoseOptions.concentrationDose(.mcgKgMin)
        case .mcgKgHour:
            unitOfMeasure = DoseOptions.concentrationDose(.mcgKgHour)
        case .mcgMin:
            unitOfMeasure = DoseOptions.concentrationDose(.mcgMin)
        case .mcgHour:
            unitOfMeasure = DoseOptions.concentrationDose(.mcgHour)
        case .mgKgMin:
            unitOfMeasure = DoseOptions.concentrationDose(.mgKgMin)
        case .mgKgHour:
            unitOfMeasure = DoseOptions.concentrationDose(.mgKgHour)
        case .mgMin:
            unitOfMeasure = DoseOptions.concentrationDose(.mgMin)
        case .mgHour:
            unitOfMeasure = DoseOptions.concentrationDose(.mgHour)
        case .unitsMin:
            unitOfMeasure = DoseOptions.concentrationDose(.unitsMin)
        }
    }
}

//struct DatabaseInfusionDoseStruct {
//    let drugDose: Double
//    var doseString: String
//    var unitOfMeasure: ConcentrationOptions
//
//    init(initialValue: Double, databaseUnitOfMeasure: Int) {
//        drugDose = initialValue
//        doseString = NumberModel(value: initialValue, numberType: .dose).description
//
//        if databaseUnitOfMeasure == 511 {
//            unitOfMeasure = .mcgMin
//        } else if databaseUnitOfMeasure == 512 {
//            unitOfMeasure = .mcgHour
//        } else if databaseUnitOfMeasure == 521 {
//            unitOfMeasure = .mgMin
//        } else if databaseUnitOfMeasure == 522 {
//            unitOfMeasure = .mgHour
//        } else if databaseUnitOfMeasure == 611 {
//            unitOfMeasure = .mcgKgMin
//        } else if databaseUnitOfMeasure == 612 {
//            unitOfMeasure = .mcgKgHour
//        } else if databaseUnitOfMeasure == 621 {
//            unitOfMeasure = .mgKgMin
//        } else if databaseUnitOfMeasure == 622 {
//            unitOfMeasure = .mgKgHour
//        } else if databaseUnitOfMeasure == 710 {
//            unitOfMeasure = .unitsMin
//        } else {
//            unitOfMeasure = .unitsMin
//        }
//
//    }
//}

/*
 ## PUSH DOSE
 1. Drug
 110 - mcg
 120 - mg
 
 2. Drug + Weight
 210 - mcg/kg
 220 - mg/kg
 
 3. Units
 300 - units
 
 4. Units + Weight
 410 - units/kg
 
 
 ## CONTINUOUS INFUSION
 5. Drug + Time
 511 - mcg/min
 512 - mcg/hour
 521 - mg/min
 522 - mg/hour
 
 6. Drug + Weight + Time
 611 - mcg/kg/min
 612 - mcg/kg/hour
 621 - mg/kg/min
 622 - mg/kg/hour
 
 7. Units + Time
 710 - units/min
 720 - units/hour
 

 
 */


