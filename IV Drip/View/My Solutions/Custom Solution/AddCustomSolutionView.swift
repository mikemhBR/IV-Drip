//
//  AddCustomSolutionView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI



struct AddCustomSolutionView: View {
    
    @EnvironmentObject var navigationModel: NavigationModel
    @EnvironmentObject var dbBrain: DBBrain
    
    
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
    @State private var selectedMedQuantityString = "1.0"
    
    @State private var selectedWeightOption = WeightOptions.miligrams
    
    @State private var selectedDilutions = [false, false, false, false, false]
    
    @State private var showDilutionWheelPicker = false
    @State private var showDilutionOptions = false
    @State private var dilutionVolume = 0.0
    
    @State private var currentlySelectedRow: RowType?
    
    @State private var isContinuousInfusion: Int?
    
    @State private var showDetailForm = false
    
    @State private var showMinimumDosePickerWheel = false
    @State var selectedConcentrationOption = ConcentrationOptions.mcgKgMin
    @State var selectedPushDoseFactor = PushDoseOptions.mgKg
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
            
            Spacer()
                .frame(height: Constants.Layout.kPadding)
            
            VStack (alignment: .center, spacing: Constants.Layout.kPadding*2) {
                
                VStack (spacing: 0) {
                    Text("Solution Name")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .sectionHeaderStyle()
                    
                    TextField("Solution Name", text: $solutionNameField)
                        .textFieldFont()
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
        .onChange(of: selectedPushDoseFactor) { newValue in
            selectedPushDoseFactor = newValue
        }
        
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
                
                HStack (spacing: 4) {
                    
                    HStack {
                        
                        
                        VStack (alignment: .leading) {
                            Text(safeMyMed.med_name ?? "")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color("Text"))
                            
                            Text("\(String(format: "%.1f", safeMyMed.med_weight))mg / \(String(format: "%.1f", safeMyMed.med_volume))ml")
                                .font(.system(size: 11, weight: .regular))
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
                        
                        TextField("Selected Med Number", text: $selectedMedQuantityString, onEditingChanged: { isEditing in
                            if isEditing {
                                if Double(selectedMedQuantityString) == 0.0 {
                                    DispatchQueue.main.async {
                                        selectedMedQuantityString = ""
                                    }
                                }
                            } else {
                                selectedMedQuantity = Double(selectedMedQuantityString) ?? 0.0
                            }
                        })
                        .foregroundColor(Color("Text"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 72, height: Constants.Layout.textFieldHeight)
                        .background(Color.white)
                        .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
                        .disabled(showSelectedMedWeightPicker)
                        .onTapGesture {
                            withAnimation {
                                showSelectedMedWeightPicker = false
                            }
                            
                        }
                        .onSubmit {
                            selectedMedQuantity = Double(selectedMedQuantityString) ?? 0.0
                        }
                        
                        
                        CustomStepper(inputDouble: $selectedMedQuantity) {
                            withAnimation {
                                selectedMyMed = nil
                            }
                        }
                        
                    }
                    .padding(Constants.Layout.kPadding/2)
                    .background(Color("Row Background"))
                    .cornerRadius(8)
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
                    .textFieldFont()
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
                
                VolumeRowView(rowTitle: "Volume/Ampoule", showPickerWheel: $showMainComponentAmpouleVolumePicker, inputDouble: 0.0, outputValue: $mainComponentAmpVolume, currentlySelectedRow: $currentlySelectedRow, rowTag: .ampouleVolume) {
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
                inputDouble: 0.0,
                outputValue: $dilutionVolume,
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
            Text("Details")
                .sectionHeaderStyle()
            
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
                
                if isContinuousInfusion != nil && isContinuousInfusion == 1 {
                    
                    InfusionMinMaxRowView(outputMin: $minimumDose, outputMax: $maximumDose, selectedInfusionDoseOption: $selectedConcentrationOption, currentlySelectedRow: $currentlySelectedRow) {
                        currentlySelectedRow = nil
                    }
                    .focused($focusState, equals: .minimumDose)
              
                } else if isContinuousInfusion != nil && isContinuousInfusion == 0 {
                    
                    PushMinMaxRowView(outputMin: $minimumDose, outputMax: $maximumDose, selectedPushDoseOption: $selectedPushDoseFactor, currentlySelectedRow: $currentlySelectedRow) {
                        currentlySelectedRow = nil
                    }
                    .focused($focusState, equals: .minimumDose)

                }
                
                Text("Observations")
                    .caption3Title()
                
                TextField("Observations", text: $observationsField)
                    .textFieldFont()
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.leading)
                    .textSelection(.disabled)
                    .frame(maxWidth: .infinity)
                    .frame(height: 88, alignment: .topLeading)
                    .background(Color.white)
                    .padding(Constants.Layout.kTextFieldPadding)
                    .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
                    .focused($focusState, equals: .observation)
                    
            }
            
        }
        
    }
    
    @ViewBuilder
    var finalResultView: some View {
        if let safeSelectedMed = selectedMyMed {
            let finalWeight = safeSelectedMed.med_weight*Double(selectedMedQuantity)
            let weightString = NumberModel(value: finalWeight, numberType: .mass).description
            let volume = NumberModel(value: dilutionVolume, numberType: .volume).description
            
            
            let totalVolume = dilutionVolume + safeSelectedMed.med_volume*selectedMedQuantity
            
            let totalVolumeString = NumberModel(value: totalVolume, numberType: .volume).description
            
            let concentration = totalVolume == 0 ? " - " : NumberModel(value: (finalWeight/totalVolume), numberType: .concentration).description
            
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
                            .fixedSize()
                        
                        Rectangle()
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("Text").opacity(0.2))
                        
                        Text("\(weightString)mg / \(volume)ml")
                            .font(.system(size: 14, weight: .light))
                            .fixedSize()
                        
                    }
                    
                    HStack (spacing: 8) {
                        Text("Fluid")
                            .font(.system(size: 14, weight: .light))
                            .fixedSize()
                        
                        Rectangle()
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("Text").opacity(0.2))
                        
                        Text("\(volume) ml")
                            .font(.system(size: 14, weight: .light))
                            .fixedSize()
                        
                    }
                    
                    Text("Final Volume: \(totalVolumeString)ml")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .fixedSize()
                    
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
                        
                        Text("\(concentration) \(selectedWeightOption.rawValue) / ml")
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
            let weightString = NumberModel(value: mainComponentWeight*Double(selectedMedQuantity), numberType: .mass).description
            
            let mainComponentVolume = mainComponentAmpVolume*selectedMedQuantity
            let mainComponentVolumeString = NumberModel(value: mainComponentVolume, numberType: .volume).description
            let volume = NumberModel(value: dilutionVolume, numberType: .volume).description
            
            let totalVolume = dilutionVolume + selectedMedQuantity*mainComponentAmpVolume
            let totalVolumeString = NumberModel(value:totalVolume, numberType: .volume).description
            let concentration = totalVolume == 0 ? " - " : NumberModel(value: (weight/totalVolume), numberType: .concentration).description
            
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
                            .fixedSize()
                        
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
                    
                    HStack (spacing: Constants.Layout.kPadding/4) {
                        Text("Concentration")
                            .font(.system(size: 16, weight: .bold))
                        
                        Text(concentration + " \(selectedWeightOption.rawValue) / ml")
                            .font(.system(size: 16, weight: .regular))
                            
                    }
                    .fixedSize()
                    
                    if minimumDose != 0 || maximumDose != 0 {
                        Spacer()
                            .frame(height: 8)
                        
                        Text("Dose Range")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        if isContinuousInfusion == 1 {
                            let minDose = NumberModel(value: minimumDose, numberType: .dose).description
                            let maxDose = NumberModel(value: maximumDose, numberType: .dose).description
                            
                            HStack {
                                VStack (spacing: 2) {
                                    Text("Mininum")
                                        .caption3Title()
                                        .padding(2)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(2)
                                    
                                    Text("\(minDose) \(selectedConcentrationOption.rawValue)")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .fixedSize()
                                
                                
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.theme.secondaryText)
                                
                                Rectangle()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 1)
                                    .foregroundColor(Color.theme.secondaryText)
                                
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.theme.secondaryText)
                                
                                VStack (spacing: 2) {
                                    Text("Maximum")
                                        .caption3Title()
                                        .padding(2)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(2)
                                    
                                    Text("\(maxDose) \(selectedConcentrationOption.rawValue)")
                                        .font(.system(size: 14, weight: .semibold))
                                    
                                }
                                .fixedSize()
                                
                            }
                        } else if isContinuousInfusion == 0 {
                            let minDose = NumberModel(value: minimumDose, numberType: .dose).description
                            let maxDose = NumberModel(value: maximumDose, numberType: .dose).description
                            HStack {
                                VStack (spacing: 2) {
                                    Text("Mininum")
                                        .caption3Title()
                                        .padding(2)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(2)
                                    
                                    Text("\(minDose) \(selectedPushDoseFactor.rawValue)")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .fixedSize()
                                
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.theme.secondaryText)
                                
                                Rectangle()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 1)
                                
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.theme.secondaryText)
                                
                                VStack (spacing: 2) {
                                    Text("Maximum")
                                        .caption3Title()
                                        .padding(2)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(2)
                                    
                                    Text("\(maxDose) \(selectedPushDoseFactor.rawValue)")
                                        .font(.system(size: 14, weight: .semibold))
                                    
                                }
                                .fixedSize()
                                
                            }
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
        // Check if user selected a solution type
        //TODO: Add criteria for form submission
        guard let solutionType = isContinuousInfusion else {
            return
        }
        
        var minMaxFactor = 9999
        var minMaxFactorCategory = 9999
        var adjustedMinimumValue = 9999.0
        var adjustedMaximumValue = 9999.0
        //get min_max dose factor and adjusted rate
        if solutionType == 1 {
            switch selectedConcentrationOption {
            case .mcgKgMin:
                minMaxFactorCategory = 6
                minMaxFactor = 611
            case .mcgKgHour:
                minMaxFactorCategory = 6
                minMaxFactor = 612
            case .mcgMin:
                minMaxFactorCategory = 5
                minMaxFactor = 511
            case .mcgHour:
                minMaxFactorCategory = 5
                minMaxFactor = 512
            case .mgKgMin:
                minMaxFactorCategory = 6
                minMaxFactor = 621
            case .mgKgHour:
                minMaxFactorCategory = 6
                minMaxFactor = 622
            case .mgMin:
                minMaxFactorCategory = 5
                minMaxFactor = 521
            case .mgHour:
                minMaxFactorCategory = 5
                minMaxFactor = 522
            case .unitsMin:
                minMaxFactorCategory = 7
                minMaxFactor = 710
            }
            
            adjustedMinimumValue = InfusionCalculator.normalizeInfusionDose(inputFactor: selectedConcentrationOption, value: minimumDose)
            adjustedMaximumValue = InfusionCalculator.normalizeInfusionDose(inputFactor: selectedConcentrationOption, value: maximumDose)
            
        } else if solutionType == 0 {
            switch selectedPushDoseFactor {
            case .mg:
                minMaxFactorCategory = 1
                minMaxFactor = 120
            case .mcg:
                minMaxFactorCategory = 1
                minMaxFactor = 110
            case .mgKg:
                minMaxFactorCategory = 2
                minMaxFactor = 220
            case .mcgKg:
                minMaxFactorCategory = 3
                minMaxFactor = 310
            case .unitsKg:
                minMaxFactorCategory = 7
                minMaxFactor = 710
            case .units:
                minMaxFactorCategory = 3
                minMaxFactor = 300
            }
            
            adjustedMinimumValue = InfusionCalculator.normalizePushDose(inputFactor: selectedPushDoseFactor, value: minimumDose)
            adjustedMaximumValue = InfusionCalculator.normalizePushDose(inputFactor: selectedPushDoseFactor, value: maximumDose)
            
        }
        
        if let userSelectedMed = selectedMyMed {
            do {
                try dbBrain.saveCustomSolution(
                    solutionName: solutionNameField,
                    savedMed: userSelectedMed,
                    mainActiveComponent: userSelectedMed.med_name ?? "error",
                    drugWeightPerAmp: userSelectedMed.med_weight,
                    drugWeightUnit: selectedWeightOption == .units ? 1 : 0,
                    drugVolumePerAmp: userSelectedMed.med_volume,
                    numberAmps: selectedMedQuantity,
                    dilutionVolume: dilutionVolume,
                    solutionType: solutionType,
                    minimumDose: minimumDose == 0.0 ? nil : adjustedMinimumValue,
                    maximumDose: maximumDose == 0.0 ? nil : adjustedMaximumValue,
                    minMaxFactor: minMaxFactor,
                    minMaxCatFactor: minMaxFactorCategory,
                    solutionObservation: observationsField
                )
                
                withAnimation {
                    navigationModel.navigateTo(to: .mySolutions)
                }
            } catch {
                return
            }
        } else {
            
            var adjustedWeight = 0.0
            
            switch selectedWeightOption {
            case .grams:
                adjustedWeight = mainComponentWeight*1000
            case .miligrams:
                adjustedWeight = mainComponentWeight
            case .micrograms:
                adjustedWeight = mainComponentWeight/1000
            case .units:
                adjustedWeight = mainComponentWeight
            }
            
            do {
                try dbBrain.saveCustomSolution(
                    solutionName: solutionNameField,
                    savedMed: nil,
                    mainActiveComponent: mainComponentName,
                    drugWeightPerAmp: adjustedWeight,
                    drugWeightUnit: selectedWeightOption == .units ? 1 : 0,
                    drugVolumePerAmp: mainComponentAmpVolume,
                    numberAmps: selectedMedQuantity,
                    dilutionVolume: dilutionVolume,
                    solutionType: solutionType,
                    minimumDose: minimumDose == 0.0 ? nil : adjustedMinimumValue,
                    maximumDose: maximumDose == 0.0 ? nil : adjustedMaximumValue,
                    minMaxFactor: minMaxFactor,
                    minMaxCatFactor: minMaxFactorCategory,
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
    
}

struct AddCustomSolutionView_Previews: PreviewProvider {
    static var previews: some View {
        AddCustomSolutionView()
            .environmentObject(NavigationModel.shared)
    }
}
