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
        }
    }
    static func getPushDose(desiredPushDose: Double, desiredPushMethod: PushDoseOptions, solutionConcentrationMgMl: Double, patientWeight: Double?) -> Double {
        
        switch desiredPushMethod {
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
        }
    }
    
    
    static func getInfusionRate(desiredInfusionRate: Double, desiredRateMethod: ConcentrationOptions, solutionConcentrationMgMl: Double, patientWeight: Double?, outputRateMethod: InfusionRateOptions) -> Double {
        
        //Solution Concentration must be in mg/ml
        
        if outputRateMethod == .mlHour {
            switch desiredRateMethod {
            case .mcgKgMin:
                guard let safeWeight = patientWeight else { return 999 }
                return (desiredInfusionRate/(solutionConcentrationMgMl*1000))*safeWeight*60
            case .mcgKgHour:
                guard let safeWeight = patientWeight else { return 999 }
                return (desiredInfusionRate/(solutionConcentrationMgMl*1000))*safeWeight
            case .mcgMin:
                return (desiredInfusionRate/(solutionConcentrationMgMl*1000))*60
            case .mcgHour:
                return (desiredInfusionRate/(solutionConcentrationMgMl*1000))
            case .mgKgMin:
                guard let safeWeight = patientWeight else { return 999 }
                return (desiredInfusionRate/(solutionConcentrationMgMl))*safeWeight*60
            case .mgKgHour:
                guard let safeWeight = patientWeight else { return 999 }
                return (desiredInfusionRate/(solutionConcentrationMgMl))*safeWeight
            case .mgMin:
                return (desiredInfusionRate/(solutionConcentrationMgMl))*60
            case .mgHour:
                return (desiredInfusionRate/(solutionConcentrationMgMl))
            }
        } else {
            switch desiredRateMethod {
            case .mcgKgMin:
                guard let safeWeight = patientWeight else { return 999 }
                return (desiredInfusionRate/(solutionConcentrationMgMl*1000))*safeWeight
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
            }
        }
        
    }
}
