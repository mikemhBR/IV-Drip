//
//  DBBrain.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 16/08/23.
//

import CoreData
import SwiftUI

enum DatabaseError: Error {
    case fetchError, saveCustomSolutionError, saveNewListError, deleteError
}


class DBBrain: ObservableObject {

    static let shared = DBBrain()
    
    private init() {}
    
    let context = PersistenceController.shared.container.viewContext
    
    func saveNewMedication(medName: String, medWeight: Double, medWeightUnit: Int, medVolume: Double, medObs: String, minimum: Double?, maximum: Double?, doseReference: Int = 9) {
        let newMed = MedicationEntity(context: context)
        newMed.med_uuid = UUID().uuidString
        newMed.med_name = medName
        newMed.med_weight = medWeight
        newMed.med_weight_unit = Int16(medWeightUnit)
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
    
    func deleteCustomSolution(toDelete: CustomSolutionEntity) {
        context.delete(toDelete)
        saveDataToContext()
    }
    
    func saveCustomSolution(solutionName: String, savedMed: MedicationEntity?, mainActiveComponent: String, drugWeightPerAmp: Double, drugWeightUnit: Int, drugVolumePerAmp: Double, numberAmps: Double, dilutionVolume: Double, solutionType: Int, minimumDose: Double?, maximumDose: Double?, minMaxFactor: Int, solutionObservation: String) throws {
        
        let newSolution = CustomSolutionEntity(context: context)
        newSolution.solution_uuid = UUID().uuidString
        newSolution.solution_name = solutionName
        
        if let safeSavedMed = savedMed {
            newSolution.med_uuid = safeSavedMed.med_uuid
            newSolution.solutionToMed = safeSavedMed
        } else {
            newSolution.med_uuid = nil
            newSolution.solutionToMed = nil
        }
        
        newSolution.main_active = mainActiveComponent
        newSolution.drug_weight_amp = drugWeightPerAmp
        newSolution.drug_weight_unit = Int16(drugWeightUnit)
        newSolution.drug_volume_amp = drugVolumePerAmp
        newSolution.amp_number = numberAmps
        newSolution.dilution_volume = dilutionVolume
        newSolution.solution_type = Int16(solutionType)
        
        if let safeMin = minimumDose {
            newSolution.solution_min = safeMin
            newSolution.min_max_factor = Int16(minMaxFactor)
        }
        
        if let safeMax = maximumDose {
            newSolution.solution_max = safeMax
            newSolution.min_max_factor = Int16(minMaxFactor)
        }
        
        newSolution.solution_obs = solutionObservation
        
        do {
            try context.save()
        } catch {
            throw DatabaseError.saveCustomSolutionError
        }
        
    }
    
    
    
    
    
    //MARK: My List Functions
    
    func createNewList(listName: String, listUUID: String) throws -> SolutionListEntity {
        let newList = SolutionListEntity(context: context)
        newList.list_name = listName
        newList.list_uuid = listUUID
        
        do {
            try context.save()
        } catch {
            throw DatabaseError.saveNewListError
        }
                
        return newList
    }
    
    func saveSolutionToList(list: SolutionListEntity, solution: CustomSolutionEntity) throws {
        let listItem = SolutionListFact(context: context)
        listItem.list_uuid = list.list_uuid
        listItem.solution_uuid = solution.solution_uuid
        listItem.factToList = list
        listItem.factToSolution = solution
        
        do {
            try context.save()
        } catch {
            throw DatabaseError.saveNewListError
        }
        
    }
    
    func getAllLists() throws -> [SolutionListEntity] {
        var allLists = [SolutionListEntity]()
        
        let request: NSFetchRequest<SolutionListEntity> = SolutionListEntity.fetchRequest()
        
        do {
            allLists = try context.fetch(request)
        } catch {
            throw DatabaseError.fetchError
        }
        
        
        return allLists
    }
    
    func getSolutionsFromList(listUUID: String) throws -> [CustomSolutionEntity] {
        var solutionFactList = [SolutionListFact]()
        
        let request: NSFetchRequest<SolutionListFact> = SolutionListFact.fetchRequest()
        request.predicate = NSPredicate(format: "list_uuid = %@", listUUID)
        
        do {
            solutionFactList = try context.fetch(request)
        } catch {
            throw DatabaseError.fetchError
        }
        
        var solutionList = [CustomSolutionEntity]()
        
        let solutionRequest: NSFetchRequest<CustomSolutionEntity> = CustomSolutionEntity.fetchRequest()
        
        for solutionUUID in solutionFactList {
            solutionRequest.predicate = NSPredicate(format: "solution_uuid = %@", solutionUUID.solution_uuid!)
            
            do {
                let singleSolution = try context.fetch(solutionRequest)
                if let safeSolution = singleSolution.first {
                    solutionList.append(safeSolution)
                }
                
            } catch {
                continue
            }
        }
                
        return solutionList
    }
    
    func deleteList(listUUID: String) {
        var foundLists = [SolutionListEntity]()
        
        let request: NSFetchRequest<SolutionListEntity> = SolutionListEntity.fetchRequest()
        request.predicate = NSPredicate(format: "list_uuid = %@", listUUID)
        
        do {
            foundLists = try context.fetch(request)
            
            for list in foundLists {
                context.delete(list)
            }
        } catch {
            //TODO: Error handling
        }
        
        var foundFact = [SolutionListFact]()
        let factRequest: NSFetchRequest<SolutionListFact> = SolutionListFact.fetchRequest()
        factRequest.predicate = NSPredicate(format: "list_uuid = %@", listUUID)
        
        do {
            foundFact = try context.fetch(factRequest)
            
            for fact in foundFact {
                context.delete(fact)
            }
        } catch {
            //TODO: error handling
        }
        
        saveDataToContext()
    }
    
    func saveDataToContext() {
        do {
            try context.save()
        } catch let error {
            fatalError("DBBrain saveData error: \(error.localizedDescription)")
        }
    }
}
