//
//  InfusionCalculator.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 23/08/23.
//

import Foundation

class InfusionCalculator {
    
    var miligrams = 0.0
    
    var micrograms: Double {
        return miligrams*1_000
    }
    
    var grams: Double {
        return miligrams/1_000
    }
    
    static func getAdjustedWeight(inputWeight: Double, inputWeightFactor: WeightOptions) -> Double {
        switch inputWeightFactor {
        case .grams:
            return inputWeight*1000
        case .miligrams:
            return inputWeight
        case .micrograms:
            return inputWeight/1000
        case .units:
            return inputWeight
        }
    }
    
    //    static func getPushDose(desiredPushDose: Double, desiredPushMethod: PushDoseOptions, solutionConcentrationMgMl: Double, patientWeight: Double?) -> Double {
    //
    //        switch desiredPushMethod {
    //        case .mg:
    //            return desiredPushDose/solutionConcentrationMgMl
    //        case .mcg:
    //            return (desiredPushDose/1000)/solutionConcentrationMgMl
    //        case .mgKg:
    //            guard let safeWeight = patientWeight else {return 999}
    //            return (desiredPushDose*safeWeight)/solutionConcentrationMgMl
    //        case .mcgKg:
    //            guard let safeWeight = patientWeight else {return 999}
    //            return ((desiredPushDose/1000)*safeWeight)/solutionConcentrationMgMl
    //        case .unitsKg:
    //            guard let safeWeight = patientWeight else {return 999}
    //            return (desiredPushDose*safeWeight)/solutionConcentrationMgMl
    //        case .units:
    //            return desiredPushDose/solutionConcentrationMgMl
    //        }
    //    }
    
    static func getPushDose(desiredPushDose: Double, inputDoseOption: DoseOptions, solutionConcentrationMgMl: Double, patientWeight: Double?) -> Double {
        
        switch inputDoseOption {
        case .pushDose(let pushDoseOptions):
            switch pushDoseOptions {
            case .mg:
                return desiredPushDose/solutionConcentrationMgMl
            case .mcg:
                return (desiredPushDose/1000)/solutionConcentrationMgMl
            case .mgKg:
                guard let safeWeight = patientWeight else {return 999}
                return (desiredPushDose*safeWeight)/solutionConcentrationMgMl
            case .mcgKg:
                guard let safeWeight = patientWeight else {return 999}
                return ((desiredPushDose/1000)*safeWeight)/solutionConcentrationMgMl
            case .unitsKg:
                guard let safeWeight = patientWeight else {return 999}
                return (desiredPushDose*safeWeight)/solutionConcentrationMgMl
            case .units:
                return desiredPushDose/solutionConcentrationMgMl
            }
        case .concentrationDose(let concentrationOptions):
            return 7777
        }
        
    }
    
    
    //    static func getInfusionRate(desiredInfusionRate: Double, inputRateMethod: ConcentrationOptions, solutionConcentrationMgMl: Double, patientWeight: Double?, outputRateMethod: InfusionRateOptions) -> Double {
    //
    //        //Solution Concentration must be in mg/ml
    //
    //        if outputRateMethod == .mlHour {
    //            switch inputRateMethod {
    //            case .mcgKgMin:
    //                guard let safeWeight = patientWeight else { return 999 }
    //                return (desiredInfusionRate*60*safeWeight)/(solutionConcentrationMgMl*1000)
    //            case .mcgKgHour:
    //                guard let safeWeight = patientWeight else { return 999 }
    //                return (desiredInfusionRate*safeWeight)/(solutionConcentrationMgMl*1000)
    //            case .mcgMin:
    //                return (desiredInfusionRate*60)/(solutionConcentrationMgMl*1000)
    //            case .mcgHour:
    //                return (desiredInfusionRate/(solutionConcentrationMgMl*1000))
    //            case .mgKgMin:
    //                guard let safeWeight = patientWeight else { return 999 }
    //                return (desiredInfusionRate*safeWeight*60)/(solutionConcentrationMgMl)
    //            case .mgKgHour:
    //                guard let safeWeight = patientWeight else { return 999 }
    //                return (desiredInfusionRate*safeWeight)/(solutionConcentrationMgMl)
    //            case .mgMin:
    //                return (desiredInfusionRate*60)/(solutionConcentrationMgMl)
    //            case .mgHour:
    //                return (desiredInfusionRate/(solutionConcentrationMgMl))
    //            case .unitsMin:
    //                return (desiredInfusionRate*60)/solutionConcentrationMgMl
    //            }
    //        } else {
    //            //TODO: Unverified calculations, probably all wrong
    //            switch inputRateMethod {
    //            case .mcgKgMin:
    //                guard let safeWeight = patientWeight else { return 999 }
    //                return (desiredInfusionRate/(solutionConcentrationMgMl*1000))*safeWeight
    //            case .mcgKgHour:
    //                guard let safeWeight = patientWeight else { return 999 }
    //                return ((desiredInfusionRate/(solutionConcentrationMgMl*1000))*safeWeight)/60
    //            case .mcgMin:
    //                return (desiredInfusionRate/(solutionConcentrationMgMl*1000))
    //            case .mcgHour:
    //                return (desiredInfusionRate/(solutionConcentrationMgMl*1000))/60
    //            case .mgKgMin:
    //                guard let safeWeight = patientWeight else { return 999 }
    //                return (desiredInfusionRate/(solutionConcentrationMgMl))*safeWeight
    //            case .mgKgHour:
    //                guard let safeWeight = patientWeight else { return 999 }
    //                return ((desiredInfusionRate/(solutionConcentrationMgMl))*safeWeight)/60
    //            case .mgMin:
    //                return (desiredInfusionRate/(solutionConcentrationMgMl))
    //            case .mgHour:
    //                return (desiredInfusionRate/(solutionConcentrationMgMl))/60
    //            case .unitsMin:
    //                return desiredInfusionRate/solutionConcentrationMgMl
    //            }
    //        }
    //
    //    }
    
    static func getInfusionRate(desiredInfusionRate: Double, inputRateMethod: DoseOptions, solutionConcentrationMgMl: Double, patientWeight: Double?, outputRateMethod: InfusionRateOptions) -> Double {
        
        //Solution Concentration must be in mg/ml
        print(outputRateMethod)
        //TODO: correct placeholders
        switch inputRateMethod {
        case .pushDose(let pushDoseOptions):
            switch pushDoseOptions {
            case .mg:
                return 988888
            case .mcg:
                return 988888
            case .mgKg:
                return 988888
            case .mcgKg:
                return 988888
            case .unitsKg:
                return 988888
            case .units:
                return 988888
            }
        case .concentrationDose(let concentrationOptions):
            if outputRateMethod == .mlHour {
                switch concentrationOptions {
                case .mcgKgMin:
                    guard let safeWeight = patientWeight else { return 999 }
                    return (desiredInfusionRate*60*safeWeight)/(solutionConcentrationMgMl*1000)
                case .mcgKgHour:
                    guard let safeWeight = patientWeight else { return 999 }
                    return (desiredInfusionRate*safeWeight)/(solutionConcentrationMgMl*1000)
                case .mcgMin:
                    return (desiredInfusionRate*60)/(solutionConcentrationMgMl*1000)
                case .mcgHour:
                    return (desiredInfusionRate/(solutionConcentrationMgMl*1000))
                case .mgKgMin:
                    guard let safeWeight = patientWeight else { return 999 }
                    return (desiredInfusionRate*safeWeight*60)/(solutionConcentrationMgMl)
                case .mgKgHour:
                    guard let safeWeight = patientWeight else { return 999 }
                    return (desiredInfusionRate*safeWeight)/(solutionConcentrationMgMl)
                case .mgMin:
                    return (desiredInfusionRate*60)/(solutionConcentrationMgMl)
                case .mgHour:
                    return (desiredInfusionRate/(solutionConcentrationMgMl))
                case .unitsMin:
                    return (desiredInfusionRate*60)/solutionConcentrationMgMl
                }
            } else {
                switch concentrationOptions {
                case .mcgKgMin:
                    guard let safeWeight = patientWeight else { return 999 }
                    return (desiredInfusionRate*safeWeight)/(solutionConcentrationMgMl*1000)
                case .mcgKgHour:
                    guard let safeWeight = patientWeight else { return 999 }
                    return ((desiredInfusionRate/(solutionConcentrationMgMl*1000))*safeWeight)/60
                case .mcgMin:
                    return (desiredInfusionRate/(solutionConcentrationMgMl*1000))
                case .mcgHour:
                    return (desiredInfusionRate/(solutionConcentrationMgMl*1000))/60
                case .mgKgMin:
                    guard let safeWeight = patientWeight else { return 999 }
                    return (desiredInfusionRate/(solutionConcentrationMgMl))*safeWeight
                case .mgKgHour:
                    guard let safeWeight = patientWeight else { return 999 }
                    return ((desiredInfusionRate/(solutionConcentrationMgMl))*safeWeight)/60
                case .mgMin:
                    return (desiredInfusionRate/(solutionConcentrationMgMl))
                case .mgHour:
                    return (desiredInfusionRate/(solutionConcentrationMgMl))/60
                case .unitsMin:
                    return desiredInfusionRate/solutionConcentrationMgMl
                }
            }
            
        }
        
    }
    
    static func getRateFromInfusion(currentInfusionRate: Double, infusionRateFactor: InfusionRateOptions, solutionConcentrationMgMl: Double, patientWeight: Double?, outputRateFactor: ConcentrationOptions) -> Double {
        
        //Solution Concentration must be in mg/ml
        
        if infusionRateFactor == .mlHour {
            switch outputRateFactor {
            case .mcgKgMin:
                guard let safeWeight = patientWeight else { return 999 }
                return (currentInfusionRate*solutionConcentrationMgMl*1000)/(safeWeight*60)
            case .mcgKgHour:
                guard let safeWeight = patientWeight else { return 999 }
                return (currentInfusionRate*solutionConcentrationMgMl*1000)/(safeWeight)
            case .mcgMin:
                return (currentInfusionRate*solutionConcentrationMgMl*1000)/(60)
            case .mcgHour:
                return (currentInfusionRate*solutionConcentrationMgMl*1000)
            case .mgKgMin:
                guard let safeWeight = patientWeight else { return 999 }
                return (currentInfusionRate*solutionConcentrationMgMl)/(safeWeight*60)
            case .mgKgHour:
                guard let safeWeight = patientWeight else { return 999 }
                return (currentInfusionRate*solutionConcentrationMgMl)/safeWeight
            case .mgMin:
                return (currentInfusionRate*solutionConcentrationMgMl)/(60)
            case .mgHour:
                return (currentInfusionRate*solutionConcentrationMgMl)
            case .unitsMin:
                return (currentInfusionRate*solutionConcentrationMgMl)/60
            }
        } else {
            switch outputRateFactor {
            case .mcgKgMin:
                guard let safeWeight = patientWeight else { return 999 }
                return (currentInfusionRate*solutionConcentrationMgMl)/(safeWeight)
            case .mcgKgHour:
                guard let safeWeight = patientWeight else { return 999 }
                return (currentInfusionRate*solutionConcentrationMgMl*60)/(safeWeight)
            case .mcgMin:
                return (currentInfusionRate*solutionConcentrationMgMl*1000)
            case .mcgHour:
                return (currentInfusionRate*solutionConcentrationMgMl*1000*60)
            case .mgKgMin:
                guard let safeWeight = patientWeight else { return 999 }
                return (currentInfusionRate*solutionConcentrationMgMl)/(safeWeight)
            case .mgKgHour:
                guard let safeWeight = patientWeight else { return 999 }
                return (currentInfusionRate*solutionConcentrationMgMl*60)/safeWeight
            case .mgMin:
                return (currentInfusionRate*solutionConcentrationMgMl)
            case .mgHour:
                return (currentInfusionRate*solutionConcentrationMgMl*60)
            case .unitsMin:
                return currentInfusionRate*solutionConcentrationMgMl
            }
        }
        
    }
    
    static func normalizePushDose(inputFactor: PushDoseOptions, value: Double) -> Double {
        // Adjusts any push dose value to mg/kg
        
        switch inputFactor {
        case .mg:
            return value
        case .mcg:
            return value/1000
        case .mgKg:
            return value
        case .mcgKg:
            return value/1000
        case .units:
            return value
        case .unitsKg:
            return value
        }
    }
    
    static func normalizeInfusionDose(inputFactor: ConcentrationOptions, value: Double) -> Double {
        switch inputFactor {
        case .mcgKgMin:
            return value
        case .mcgKgHour:
            return value/60
        case .mcgMin:
            return value
        case .mcgHour:
            return value/60
        case .mgKgMin:
            return value*1000
        case .mgKgHour:
            return (value*1000)/60
        case .mgMin:
            return value*1000
        case .mgHour:
            return (value*1000)/60
        case .unitsMin:
            return value
        }
    }
    
    static func normalizeDatabaseInfusionDose(rateValue: Double, databaseRateFactor: Int, desiredOutputFactor: ConcentrationOptions) -> Double? {
        switch desiredOutputFactor {
        case .mcgKgMin:
            if databaseRateFactor == 3 {
                return rateValue
            } else {
                return nil
            }
        case .mcgKgHour:
            if databaseRateFactor == 3 {
                return rateValue*60
            } else {
                return nil
            }
        case .mcgMin:
            if databaseRateFactor == 2 {
                return rateValue
            } else {
                return nil
            }
        case .mcgHour:
            if databaseRateFactor == 2 {
                return rateValue*60
            } else {
                return nil
            }
        case .mgKgMin:
            if databaseRateFactor == 3 {
                return rateValue/1000
            } else {
                return nil
            }
        case .mgKgHour:
            if databaseRateFactor == 3 {
                return (rateValue/1000)*60
            } else {
                return nil
            }
        case .mgMin:
            if databaseRateFactor == 2 {
                return rateValue/1000
            } else {
                return nil
            }
        case .mgHour:
            if databaseRateFactor == 2 {
                return (rateValue/1000)*60
            } else {
                return nil
            }
        case .unitsMin:
            if databaseRateFactor == 4 {
                return rateValue
            } else {
                return nil
            }
        }
    }
    
    static func normalizeDatabasePushDose(rateValue: Double, databaseRateCategory: Int, databaseRateFactor: Int, desiredOutputFactor: PushDoseOptions) -> Double? {
        
        switch desiredOutputFactor {
        case .mg:
            if databaseRateFactor == 120 {
                return rateValue
            } else {
                return nil
            }
        case .mcg:
            if databaseRateFactor == 0 {
                return rateValue*1000
            } else {
                return nil
            }
        case .mgKg:
            if databaseRateFactor == 1 {
                return rateValue
            } else {
                return nil
            }
        case .mcgKg:
            if databaseRateFactor == 1 {
                return rateValue*1000
            } else {
                return nil
            }
        case .unitsKg:
            if databaseRateFactor == 5 {
                return rateValue
            } else {
                return nil
            }
        case .units:
            return rateValue
        }
    }
    
    static func getPushDoseEnum(databaseFactor: Int) -> PushDoseOptions {
        if databaseFactor == 110 {
            return .mcg
        } else if databaseFactor == 120 {
            return .mg
        } else if databaseFactor == 210 {
            return .mcgKg
        } else if databaseFactor == 220 {
            return .mgKg
        } else if databaseFactor == 300 {
            return .units
        } else if databaseFactor == 410 {
            return .unitsKg
        } else {
            return .units
        }
    }
    
    static func getDatabaseRateFactor(databaseFactor: Int) -> DoseOptions {
        if databaseFactor == 110 {
            
            return .pushDose(.mcg)
        } else if databaseFactor == 120 {
            
            return .pushDose(.mg)
        } else if databaseFactor == 210 {
            
            return .pushDose(.mcgKg)
        } else if databaseFactor == 220 {
            
            return .pushDose(.mgKg)
        } else if databaseFactor == 300 {
            return .pushDose(.units)
            
        } else if databaseFactor == 410 {
            return .pushDose(.unitsKg)
            
        } else if databaseFactor == 511 {
            return .concentrationDose(.mcgMin)
        } else if databaseFactor == 512 {
            return .concentrationDose(.mcgHour)
        } else if databaseFactor == 521 {
            return .concentrationDose(.mgMin)
        } else if databaseFactor == 522 {
            return .concentrationDose(.mgHour)
        } else if databaseFactor == 611 {
            return .concentrationDose(.mcgKgMin)
        } else if databaseFactor == 612 {
            return .concentrationDose(.mcgKgHour)
        } else if databaseFactor == 621 {
            return .concentrationDose(.mgKgMin)
        } else if databaseFactor == 622 {
            return .concentrationDose(.mgKgHour)
        } else if databaseFactor == 710 {
            return .concentrationDose(.unitsMin)
        } else {
            return .pushDose(.units)
        }
    }
}


