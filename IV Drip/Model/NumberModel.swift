//
//  NumberModel.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 01/09/23.
//

import Foundation

enum NumberType {
    case mass, volume, concentration, dose, infusionRate
}

struct NumberModel: CustomStringConvertible {
    var value: Double
    var numberType: NumberType
    
    private static var massFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 3
        return formatter
    }()
    
    private static var volumeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    private static var concentrationFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 3
        return formatter
    }()
    
    private static var doseFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 3
        return formatter
    }()
    
    private static var infusionFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    var description: String {
        let number = NSNumber(value: value)
        
        switch numberType {
        case .mass:
            return Self.massFormatter.string(from: number)!
        case .volume:
            return Self.volumeFormatter.string(from: number)!
        case .concentration:
            return Self.concentrationFormatter.string(from: number)!
        case .dose:
            return Self.doseFormatter.string(from: number)!
        case .infusionRate:
            return Self.infusionFormatter.string(from: number)!
        }
        
    }

}


