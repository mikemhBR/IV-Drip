//
//  MyMedsView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 15/08/23.
//

import SwiftUI


struct AddMedView: View {
    @EnvironmentObject var navigationModel: NavigationModel
    @EnvironmentObject var dbBrain: DBBrain
    
    
    @State private var medName = ""
    @State private var medWeight = 0.0
    @State private var medVolume = 0.0
    
    @State private var isFavorite = false
    
    @State private var showDrugWeightPickerWheel = false
    @State private var selectedWeightOption = WeightOptions.miligrams
    
    @State private var currentlySelectedRow: RowType? = RowType.weight
    
    @State private var showVolumePickerWheel = false
    
    @State private var showDetailForm = false
    
    @State private var showMinimumDoseWheelPicker = false
    @State private var minimumDose = 0.0
    
    @State private var selectedMedDoseOption = MedDoseOptions.mcgKgMin
    @State private var showMaximumDoseWheelPicker = false
    @State private var maximumDose = 0.0
    
    @State private var observationsField = ""
    
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 0) {
            
            ZStack {
                Button {
                    navigationModel.navigateTo(to: .mySolutions)
                } label: {
                    
                    Image(systemName: "chevron.left")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                }
                
                Text("Add New Medication")
                    .font(.system(size: 24, weight: .light))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.bottom, Constants.Layout.kPadding)
            
            ScrollView {
                VStack (alignment: .leading, spacing: 0) {
                    Label {
                        Text("Favorite")
                    } icon: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundStyle(Color("Accent Blue"))
                    }
                    .onTapGesture {
                        withAnimation {
                            isFavorite.toggle()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.bottom, Constants.Layout.kPadding)
                    
                    
                    
                    medicationNameView
                        .padding(.bottom, Constants.Layout.kPadding)
                    
                    
                    drugWeightView
                        .padding(.bottom, Constants.Layout.kPadding)
                    
                    
                    
                    Text("Ampoule Volume")
                    VolumeRowView(showPickerWheel: $showVolumePickerWheel, userInput: $medVolume, currentlySelectedRow: $currentlySelectedRow, rowTag: .volume) {
                        withAnimation {
                            showVolumePickerWheel = false
                            currentlySelectedRow = nil
                        }
                    }
                    .padding(.bottom, Constants.Layout.kPadding)
                    
                    resultView
                        .padding(.bottom, Constants.Layout.kPadding)
                    
                    detailsForm
                        .padding(.bottom, Constants.Layout.kPadding)
                    
                    
                    Spacer()
                    
                    Button {
                        saveMedication()
                        withAnimation {
                            navigationModel.navigateTo(to: .mySolutions)
                        }
                    } label: {
                        Text("Save")
                            .frame(width: Constants.Layout.buttonWidth.large.rawValue)
                            .modifier(PrimaryButtonConfig())
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            
            
            
            
        }
        .padding(Constants.Layout.kPadding)
        
    }
    
    var medicationNameView: some View {
        VStack (spacing: 0) {
            Text("Medication Name")
                .caption3Title()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Medication Name", text: $medName)
                
        }
    }
    
    var drugWeightView: some View {
        VStack (spacing: 0) {
            Text("Weight")
                .caption3Title()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            DrugWeightRowView(itemTitle: "Drug Weight/Amp", pickerIntCases: 4, pickerDecimalCases: 1, showPickerWheel: $showDrugWeightPickerWheel, userValue: $medWeight, selectedWeightOption: $selectedWeightOption, currentlySelectedRow: $currentlySelectedRow, rowTag: .weight) {
                withAnimation {
                    showVolumePickerWheel = true
                    currentlySelectedRow = .volume
                }
            }
            
        }
    }
    
    var detailsForm: some View {
        VStack (alignment: .leading, spacing: 0) {
            
            Button {
                withAnimation {
                    showDetailForm.toggle()
                }
            } label: {
                Label {
                    Text("Add Details (optional)")
                    
                    
                } icon: {
                    Image(systemName: "plus")
                    
                }
                
                .foregroundColor(Color("Accent Blue"))
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            if showDetailForm {
                Spacer()
                    .frame(height: Constants.Layout.kPadding)
                
                Text("Details")
                    .headlineTitle()
                
                MyMedDoseRowView(itemTitle: "Minimum Dose", pickerIntCases: 4, pickerDecimalCases: 1, showPickerWheel: $showMinimumDoseWheelPicker, userValue: $minimumDose, selectedMedDoseOption: $selectedMedDoseOption, currentlySelectedRow: $currentlySelectedRow, rowTag: .minimumDose) {
                    withAnimation {
                        currentlySelectedRow = .maximumDose
                        showMaximumDoseWheelPicker = true
                    }
                    
                }
                
                
                Spacer()
                    .frame(height: Constants.Layout.kPadding)
                
                MyMedDoseRowView(itemTitle: "Maximum Dose", pickerIntCases: 4, pickerDecimalCases: 1, showPickerWheel: $showMaximumDoseWheelPicker, userValue: $maximumDose, selectedMedDoseOption: $selectedMedDoseOption, currentlySelectedRow: $currentlySelectedRow, rowTag: .maximumDose) {
                    
                }
                
                Text("Details")
                    .caption3Title()
                
                TextField("Observations", text: $observationsField)
                    .font(.system(size: 20))
                    .frame(height: 88)
                    .background(Color.white)
                    .padding(Constants.Layout.kPadding/2)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
            }
            
        }
        
    }
    
    var resultView: some View {
        let weight = String(format: "%.2f", medWeight)
        let volume = String(format: "%.1f", medVolume)
        
        return VStack {
            Text("\(weight) \(selectedWeightOption.rawValue) / \(volume) ml")
            
            Spacer()
                .frame(height: Constants.Layout.kPadding)
            
            Text(getconcentrationString() + " \(selectedWeightOption.rawValue) / ml")
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    func getconcentrationString() -> String {
        if medVolume != 0 {
            return String(format: "%.1f", (medWeight/Double(medVolume)))
        } else {
            return "-"
        }
    }
    
    func saveMedication() {
        if minimumDose == 0.0 && maximumDose == 0.0 {
            dbBrain.saveNewMedication(
                medName: medName,
                medWeight: medWeight,
                medVolume: medVolume,
                medObs: observationsField,
                minimum: nil,
                maximum: nil
            )
            
        } else {
            var doseReference = 9
            switch selectedMedDoseOption {
            case .mg, .mcg:
                doseReference = 0
            case .mgKg:
                doseReference = 1
            case .mgMin, .mcgMin:
                doseReference = 2
            case .mgKgHour, .mgKgMin, .mcgKgMin:
                doseReference = 3
            case .unitsMin:
                doseReference = 4
            }
            dbBrain.saveNewMedication(
                medName: medName,
                medWeight: medWeight,
                medVolume: medVolume,
                medObs: observationsField,
                minimum: getDose(inputValue: minimumDose),
                maximum: getDose(inputValue: maximumDose),
                doseReference: doseReference
            )
        }
    }
    
    func getDose(inputValue: Double) -> Double {
        /*
         0: drug weight only
         1: drug weight and patient weight
         2: drug weight and time
         3: drug weight, patient weight and time
         4: units/minute
         */
        
        switch selectedMedDoseOption {
            //0
        case .mg:
            return inputValue
        case .mcg:
            return inputValue/1000
            
            //1
        case .mgKg:
            return inputValue
            
            // 2
        case .mgMin:
            return inputValue*1000
        case .mcgMin:
            return inputValue
            
            // 3
        case .mgKgHour:
            return (inputValue*1000)/60
        case .mgKgMin:
            return inputValue*1000
        case .mcgKgMin:
            return inputValue
        
        case .unitsMin:
            return inputValue
        }
    }
}

struct MyMedsView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedView()
            .environmentObject(NavigationModel.shared)
            .environmentObject(DBBrain.shared)
    }
}
