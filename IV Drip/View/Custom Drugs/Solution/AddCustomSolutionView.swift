//
//  AddCustomSolutionView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI

class AddCustomSolutionViewController: ObservableObject {
    
    func saveCustomSolution() {
        
    }
    
}

struct AddCustomSolutionView: View {
    
    @EnvironmentObject var navigationModel: NavigationModel
    @EnvironmentObject var dbBrain: DBBrain
    
    @StateObject var viewModel = AddCustomSolutionViewController()
    
    @State private var solutionNameField = ""
    
    @State private var mainComponentName = ""
    
    @State private var showMainComponentWheelPicker = false
    @State private var mainComponentWeight = 0.0
    @State private var showAmpouleNumberWheelPicker = false
    
    @State private var mainComponentAmpVolume = 0.0
    @State private var showMainComponentAmpouleVolumePicker = false
    
    @State private var showSelectedMedWeightPicker = false
    @State private var showMyMeds = false
    @State var selectedMyMed: MedicationEntity?
    @State private var selectedMedQuantity = 1.0
    @State private var selectedMedQuantityString = "1"
    
    @State private var selectedWeightOption = WeightOptions.miligrams
    
    @State private var selectedDilutions = [false, false, false, false, false]
    
    @State private var showDilutionWheelPicker = false
    @State private var showDilutionOptions = false
    @State private var dilutionVolume = 0.0
    
    @State private var currentlySelectedRow: RowType?
    
    @State private var isContinuousInfusion: Int?
    
    @State private var showDetailForm = false
    
    @State private var showMinimumDosePickerWheel = false
    @State private var selectedConcentrationOption = ConcentrationOptions.mcgKgMin
    @State private var selectedOptionalWeightOption = WeightOptions.miligrams
    @State private var minimumDose = 0.0
    
    @State private var showMaximumDosePickerWheel = false
    @State private var maximumDose = 0.0
    
    @State private var observationsField = ""
    
    @FocusState private var focusState: RowType?
        
    var body: some View {
        ScrollView {
            SectionHeaderView(sectionTitle: "Custom Solution") {
                withAnimation {
                    navigationModel.navigateTo(to: .mySolutions)
                }
            }
            
            VStack (alignment: .center, spacing: Constants.Layout.kPadding*2) {
                
                VStack (spacing: 0) {
                    Text("Solution Name")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .sectionHeaderStyle()
                    
                    TextField("Solution Name", text: $solutionNameField)
                        .font(.system(size: 20))
                        .focused($focusState, equals: .textInput)
                        .foregroundColor(Color("Text"))
                        .frame(height: 44)
                        .padding(.horizontal, Constants.Layout.kPadding/2)
                        .background(Color.white)
                        .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
                }
                .onTapGesture {
                    focusState = nil
                }
                
                  
                Group {
                    
                    mainComponentForm
                        .onTapGesture {
                            focusState = nil
                        }
                    
                    dilutionComponentForm
                        .onTapGesture {
                            focusState = nil
                        }
                    
                    typeOfSolutionPicker
                    
                    detailsForm
                        .onTapGesture {
                            focusState = nil
                        }
                    
                    if dilutionVolume != 0.0 && (mainComponentWeight != 0.0 || selectedMyMed != nil) {
                        finalResultView
                    }
                    
                }
                
                Button {
                    saveSolution()
                } label: {
                    Text("Save")
                        .frame(width: Constants.Layout.buttonWidth.large.rawValue)
                        .modifier(PrimaryButtonConfig())
                        
                }
                
                
            }
            
        }
        .padding(Constants.Layout.kPadding/2)
        .fullScreenCover(isPresented: $showMyMeds) {
            CustomSolutionMyMedsView(selectedMed: $selectedMyMed)
        }
        .onChange(of: selectedMedQuantity) { newValue in
            selectedMedQuantityString = String(format: "%.1f", selectedMedQuantity)
        }
        .onChange(of: focusState, perform: { newValue in
            currentlySelectedRow = focusState
        })
        .background(Color("Background 200"))
        
        
    }

    
    var mainComponentForm: some View {
        VStack (alignment: .leading, spacing: 4) {
            HStack {
                Text("Main Component")
                    .sectionHeaderStyle()
                
                Spacer()
                
                Button {
                    selectedMedQuantity = 1
                    withAnimation {
                        showMyMeds = true
                    }
                    
                } label: {
                    Text("My Meds")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("Accent Blue"))
                }

            }
            
            if let safeMyMed = selectedMyMed {
                let weightString = String(format: "%.2f", safeMyMed.med_weight*selectedMedQuantity)
                let volumeString = String(format: "%.1f", safeMyMed.med_volume*selectedMedQuantity)
                
                HStack {
                    if selectedMedQuantity < 1 {
                        Button {
                            withAnimation {
                                selectedMyMed = nil
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                    
                    VStack {
                        Text(safeMyMed.med_name ?? "")
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            showSelectedMedWeightPicker.toggle()
                        }
                    } label: {
                        Image(systemName: "plusminus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 28)
                    }
                    
                    TextField("Infusion Velocity", text: $selectedMedQuantityString)
                        .modifier(InputRowTextFieldModifier())
                        .disabled(showSelectedMedWeightPicker)
                        
                        .onTapGesture {
                            withAnimation {
                                showSelectedMedWeightPicker = false
                            }
                            
                        }
                        .onChange(of: selectedMedQuantityString) { newValue in
                            selectedMedQuantity = Double(newValue) ?? 0.0
                        }
                    
                    
                    Stepper("") {
                        selectedMedQuantity += 1
                    } onDecrement: {
                        if selectedMedQuantity > 0 {
                            selectedMedQuantity -= 1
                        }
                    }
                    .frame(width: 96)

                }
                
                if showSelectedMedWeightPicker {
                    DecimalWheelPicker(intCases: 2, decimalCases: 1, selection: $selectedMedQuantity, initialValue: selectedMedQuantity)
                        
                        
                    Button("OK") {
                        selectedMedQuantityString = String(format: "%.1f", selectedMedQuantity)
                        withAnimation {
                            showSelectedMedWeightPicker = false
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Spacer()
                    .frame(height: 1)
                
                Text("Main Component: \(weightString)mg / \(volumeString)ml")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Text"))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
            } else {
                TextField("Main Component Name", text: $mainComponentName)
                    .font(.system(size: 20))
                    .frame(height: 44)
                    .focused($focusState, equals: .textInput)
                    .padding(.horizontal, Constants.Layout.kPadding/2)
                    .background(Color.white)
                    .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
                
                
                DrugWeightRowView(itemTitle: "Weight/Ampoule", pickerIntCases: 4,
                    pickerDecimalCases: 1,
                    showPickerWheel: $showMainComponentWheelPicker,
                    userValue: $mainComponentWeight,
                    selectedWeightOption: $selectedWeightOption,
                    currentlySelectedRow: $currentlySelectedRow,
                    rowTag: .drugInBag
                ) {
                    withAnimation {
                        currentlySelectedRow = .ampouleVolume
                        showMainComponentAmpouleVolumePicker = true
                    }
                }
                .focused($focusState, equals: .drugInBag)
                
                VolumeRowView(rowTitle: "Volume/Ampoule", showPickerWheel: $showMainComponentAmpouleVolumePicker, userInput: $mainComponentAmpVolume, currentlySelectedRow: $currentlySelectedRow, rowTag: .ampouleVolume) {
                    withAnimation {
                        currentlySelectedRow = .ampouleNumber
                        showAmpouleNumberWheelPicker = true
                    }
                }
                .focused($focusState, equals: .ampouleVolume)
                
                AmpouleNumberRowView(
                    showPickerWheel: $showAmpouleNumberWheelPicker, userInput: $selectedMedQuantity, currentlySelectedRow: $currentlySelectedRow) {
                        currentlySelectedRow = nil
                        focusState = nil
                    }
                    .focused($focusState, equals: .ampouleNumber)
            }
            
            
        }
    }

    var dilutionComponentForm: some View {
        VStack (alignment: .leading, spacing: 4) {
            Text("Dilution")
                .sectionHeaderStyle()
            
            VolumeRowView(
                showPickerWheel: $showDilutionWheelPicker,
                userInput: $dilutionVolume,
                currentlySelectedRow: $currentlySelectedRow,
                rowTag: .volume
            ) {
                withAnimation {
                    currentlySelectedRow = nil
                    focusState = nil
                }
                }
                .focused($focusState, equals: .volume)
            

                
                Button {
                    withAnimation {
                        showDilutionOptions.toggle()
                    }
                    
                } label: {
                    HStack (spacing: 8) {
                        Image(systemName: "chevron.right.circle.fill")
                            .rotationEffect(Angle(degrees: showDilutionOptions ? 90 : 0))
                        
                        
                        Text("Select Dilution Fluid (optional)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("Accent Blue"))
                    }
                   
                }
                .padding(.leading, Constants.Layout.kPadding/2)
            
            
            
            if showDilutionOptions {
                HStack {
                    ForEach(0..<DilutionOptions.allCases.count, id: \.self) { index in
                        let text = DilutionOptions.allCases[index].rawValue
                        Toggle(isOn: $selectedDilutions[index]) {
                            Text(text)
                        }
                        .toggleStyle(.button)
                    }
                }
                .padding(.leading, Constants.Layout.kPadding/2)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
        }
    }
    
    var typeOfSolutionPicker: some View {
        VStack (alignment: .leading, spacing: 4) {
            Text("Type of Solution")
                .sectionHeaderStyle()
            
            Picker("Type of Infusion", selection: $isContinuousInfusion) {
                Text("Push").tag(0 as Int?)
                Text("Continuous Infusion").tag(1 as Int?)
            }
            .pickerStyle(.segmented)
            
            
        }
    }
    
    var detailsForm: some View {
        VStack (alignment: .leading, spacing: 4) {
            
            Button {
                withAnimation {
                    showDetailForm.toggle()
                }
            } label: {
                Label {
                    Text("Add Details (optional)")
                        
                        
                } icon: {
                    Image(systemName: "plus")
                        .rotationEffect(Angle(degrees: showDetailForm ? 45 : 0))
                        
                }
                
                .foregroundColor(isContinuousInfusion == nil ? Color.secondary : Color("Accent Blue"))
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            if showDetailForm && isContinuousInfusion != nil {
                
                Text("Details")
                    .headlineTitle()
                
                
                if isContinuousInfusion != nil && isContinuousInfusion == 1 {
                    ConcentrationRowView(itemTitle: "MIN Dose", pickerIntCases: 3, pickerDecimalCases: 1, showPickerWheel: $showMinimumDosePickerWheel, userValue: $minimumDose, selectedConcentrationOption: $selectedConcentrationOption, currentlySelectedRow: $currentlySelectedRow, rowTag: .minimumDose) {
                        withAnimation {
                            currentlySelectedRow = .maximumDose
                            showMaximumDosePickerWheel = true
                        }
                    }
                    .focused($focusState, equals: .minimumDose)
                    
                    
                    ConcentrationRowView(itemTitle: "MAX Dose", pickerIntCases: 3, pickerDecimalCases: 1, showPickerWheel: $showMaximumDosePickerWheel, userValue: $maximumDose, selectedConcentrationOption: $selectedConcentrationOption, currentlySelectedRow: $currentlySelectedRow, rowTag: .maximumDose) {
                        withAnimation {
                            currentlySelectedRow = nil
                        }
                    }
                    .focused($focusState, equals: .maximumDose)
                    
                } else if isContinuousInfusion != nil && isContinuousInfusion == 0 {
                    DrugWeightRowView(itemTitle: "MIN Dose", pickerIntCases: 3, pickerDecimalCases: 1, showPickerWheel: $showMinimumDosePickerWheel, userValue: $minimumDose, selectedWeightOption: $selectedOptionalWeightOption, currentlySelectedRow: $currentlySelectedRow, rowTag: .minimumDose) {
                        withAnimation {
                            currentlySelectedRow = .maximumDose
                            showMaximumDosePickerWheel = true
                        }
                    }
                    .focused($focusState, equals: .minimumDose)
                    
                    
                    DrugWeightRowView(itemTitle: "MAX Dose", pickerIntCases: 3, pickerDecimalCases: 1, showPickerWheel: $showMaximumDosePickerWheel, userValue: $maximumDose, selectedWeightOption: $selectedOptionalWeightOption, currentlySelectedRow: $currentlySelectedRow, rowTag: .maximumDose) {
                        withAnimation {
                            currentlySelectedRow = nil
                        }
                    }
                    .focused($focusState, equals: .maximumDose)
                }
                
                Text("Observations")
                    .caption3Title()
                
                TextField("Observations", text: $observationsField)
                    .font(.system(size: 20))
                    .frame(height: 88)
                    .padding(Constants.Layout.kPadding/2)
                    .background(Color.white)
                    .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
            }
            
        }
        
    }
    
    @ViewBuilder
    var finalResultView: some View {
        if let safeSelectedMed = selectedMyMed {
            let finalWeight = safeSelectedMed.med_weight*Double(selectedMedQuantity)
            let weightString = String(format: "%.2f", finalWeight)
            let volume = String(format: "%.1f", dilutionVolume)
            
            let totalVolume = dilutionVolume + safeSelectedMed.med_volume
            let totalVolumeString = String(format: "%.1f", totalVolume)
            
            let concentration = totalVolume == 0 ? " - " : String(format: "%.3f", (finalWeight/totalVolume))
            
            VStack (alignment: .leading, spacing: 4) {
                Text("Resulting Solution")
                    .foregroundColor(Color("Text"))
                    .font(.system(size: 28, weight: .thin))
                
                VStack (alignment: .leading, spacing: 4) {
                    Text("Composition")
                        .font(.system(size: 16, weight: .bold))
                    
                    HStack (spacing: 8) {
                        Text(safeSelectedMed.med_name ?? "")
                            .font(.system(size: 14, weight: .light))
                        
                        Rectangle()
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("Text").opacity(0.2))
                        
                        Text("\(weightString)mg / \(volume)ml")
                            .font(.system(size: 14, weight: .light))
                        
                    }
                    
                    HStack (spacing: 8) {
                        Text("Fluid")
                            .font(.system(size: 14, weight: .light))
                        
                        Rectangle()
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("Text").opacity(0.2))
                        
                        Text("\(volume) ml")
                            .font(.system(size: 14, weight: .light))
                        
                    }
                    
                    Text("Final Volume: \(totalVolumeString)")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    Text("Concentration")
                        .font(.system(size: 16, weight: .bold))
                    
                    HStack {
                        Text("\(weightString)\(selectedWeightOption.rawValue) / \(volume)ml")
                            .font(.system(size: 14, weight: .semibold))
                            .fixedSize()
                        
                        Image(systemName: "arrow.left.and.right")
                            .frame(maxWidth: .infinity)
                        
                        Text(concentration + "\(selectedWeightOption.rawValue) / ml")
                            .font(.system(size: 14, weight: .semibold))
                            .fixedSize()
                    }
                    
                }
                .padding(Constants.Layout.kPadding)
                .background(Color("Row Background"))
                .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
            }
            
        } else {
            let weight = mainComponentWeight*selectedMedQuantity
            let weightString = String(format: "%.2f", mainComponentWeight*Double(selectedMedQuantity))
            let mainComponentVolume = mainComponentAmpVolume*selectedMedQuantity
            let mainComponentVolumeString = String(format: "%.1f", mainComponentVolume)
            let volume = String(format: "%.1f", dilutionVolume)
            
            let totalVolume = dilutionVolume + selectedMedQuantity*mainComponentAmpVolume
            let totalVolumeString = String(format: "%.1f", totalVolume)
            let concentration = totalVolume == 0 ? " - " : String(format: "%.3f", (weight/totalVolume))
            
            VStack (alignment: .leading, spacing: 4) {
                Text("Resulting Solution")
                    .foregroundColor(Color("Text"))
                    .font(.system(size: 28, weight: .thin))
                
                VStack (alignment: .leading, spacing: 4) {
                    Text("Composition")
                        .font(.system(size: 16, weight: .bold))
                    
                    HStack (spacing: 8) {
                        Text(mainComponentName.isEmpty ? "Drug" : mainComponentName)
                            .font(.system(size: 14, weight: .light))
                        
                        Rectangle()
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("Text").opacity(0.2))
                        
                        Text("\(weightString)\(selectedWeightOption.rawValue) / \(mainComponentVolumeString)ml")
                            .font(.system(size: 14, weight: .light))
                            .fixedSize()
                        
                    }
                    
                    HStack (spacing: 8) {
                        Text("Fluid")
                            .font(.system(size: 14, weight: .light))
                        
                        Rectangle()
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("Text").opacity(0.2))
                        
                        Text("\(volume) ml")
                            .font(.system(size: 14, weight: .light))
                        
                    }
                    
                    Text("Solution: \(weightString) \(selectedWeightOption.rawValue) / \(totalVolumeString) ml")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    Text("Concentration")
                        .font(.system(size: 16, weight: .bold))
                    
                    Text(concentration + "\(selectedWeightOption.rawValue) / ml")
                        .font(.system(size: 14, weight: .semibold))
                        .fixedSize()
                    
                    if minimumDose != 0 || maximumDose != 0 {
                        Spacer()
                            .frame(height: 8)
                        
                        Text("Dose Range")
                            .font(.system(size: 16, weight: .bold))
                        
                        HStack {
                            Text(String(format: "%.2f", minimumDose) + " " + selectedConcentrationOption.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .fixedSize()
                            
                            Image(systemName: "arrow.left.and.right")
                                .frame(maxWidth: .infinity)
                            
                            Text(String(format: "%.2f", maximumDose) + " " + selectedConcentrationOption.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .fixedSize()
                        }
                    }
                }
                .padding(Constants.Layout.kPadding)
                .background(Color("Row Background"))
                .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
                
                
                
            }
           
        }
        
    }
    
    func saveSolution() {
        guard let solutionType = isContinuousInfusion else {
            return
        }
        
        do {
            try dbBrain.saveCustomSolution(
                solutionName: solutionNameField,
                mainActiveComponent: mainComponentName,
                drugWeightPerAmp: mainComponentWeight,
                drugVolumePerAmp: mainComponentAmpVolume,
                numberAmps: selectedMedQuantity,
                dilutionVolume: dilutionVolume,
                solutionType: solutionType,
                minimumDose: minimumDose == 0.0 ? nil : minimumDose,
                maximumDose: maximumDose == 0.0 ? nil : maximumDose,
                solutionObservation: observationsField
            )
            
            withAnimation {
                navigationModel.navigateTo(to: .mySolutions)
            }
        } catch {
            return
        }
        
    }
    
}

struct AddCustomSolutionView_Previews: PreviewProvider {
    static var previews: some View {
        AddCustomSolutionView()
            .environmentObject(NavigationModel.shared)
    }
}
