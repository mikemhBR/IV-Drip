//
//  DBBrain.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 16/08/23.
//

import CoreData
import SwiftUI

enum DatabaseError: Error {
    case fetchError
}

class DBBrain: ObservableObject {

    static let shared = DBBrain()
    
    private init() {}
    
    let context = PersistenceController.shared.container.viewContext
    
    func saveNewMedication(medName: String, medWeight: Double, medVolume: Double, medObs: String, minimum: Double?, maximum: Double?, doseReference: Int = 9) {
        let newMed = MedicationEntity(context: context)
        newMed.med_uuid = UUID().uuidString
        newMed.med_name = medName
        newMed.med_weight = medWeight
        newMed.med_volume = medVolume
        
        if minimum != nil {
            newMed.med_min = Double(minimum!)
        }
        
        if maximum != nil {
            newMed.med_max = Double(maximum!)
        }
        
        newMed.dose_reference = Int16(doseReference)
        
        newMed.med_observations = medObs
        
        saveDataToContext()
    }
    
    func getAllMedications() -> [MedicationEntity] {
        var medList = [MedicationEntity]()
        
        let request: NSFetchRequest<MedicationEntity> = MedicationEntity.fetchRequest()
        
        do {
            medList = try context.fetch(request)
        } catch {
            fatalError("Error with database")
        }
        
        return medList
    }
    
    func getAllSolutionsList() throws -> [CustomSolutionEntity] {
        var solutionList = [CustomSolutionEntity]()
        
        let request: NSFetchRequest<CustomSolutionEntity> = CustomSolutionEntity.fetchRequest()
        
        do {
            solutionList = try context.fetch(request)
        } catch {
            throw DatabaseError.fetchError
        }
        
        return solutionList
        
    }
    
    func saveCustomSolution(solutionName: String, mainActiveComponent: String, drugWeightPerAmp: Double, drugVolumePerAmp: Double, numberAmps: Double, dilutionVolume: Double, solutionType: Int, minimumDose: Double?, maximumDose: Double?, solutionObservation: String) throws {
        
        let newSolution = CustomSolutionEntity(context: context)
        newSolution.solution_uuid = UUID().uuidString
        newSolution.solution_name = solutionName
        newSolution.main_active = mainActiveComponent
        newSolution.drug_weight_amp = drugWeightPerAmp
        newSolution.drug_volume_amp = drugVolumePerAmp
        newSolution.amp_number = numberAmps
        newSolution.dilution_volume = dilutionVolume
        newSolution.solution_type = Int16(solutionType)
        
        if let safeMin = minimumDose {
            newSolution.solution_min = safeMin
        }
        
        if let safeMax = maximumDose {
            newSolution.solution_max = safeMax
        }
        
        newSolution.solution_obs = solutionObservation
        
        do {
            try context.save()
        } catch {
            throw SavingErrors.saveCustomSolutionError
        }
        
    }
    
    func saveDataToContext() {
        do {
            try context.save()
        } catch let error {
            fatalError("DBBrain saveData error: \(error.localizedDescription)")
        }
    }
}
