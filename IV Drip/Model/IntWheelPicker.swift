//
//  DecimalWheelPicker.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.

import SwiftUI

struct IntWheelPicker: UIViewRepresentable {
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    let intCases: Int
    let selection: Binding<Int>
    let initialValue: Int
    
    func makeUIView(context: Context) -> some UIPickerView {
        let pickerView = UIPickerView(frame: .zero)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = context.coordinator
        pickerView.dataSource = context.coordinator
        
        
        let initialValueString = "\(initialValue)"
        
        var digits = [Int]()
        
        let initialDouble = Double(initialValue)
        
        for iPlace in 1..<intCases {
            if initialDouble < pow(10, Double(intCases) - Double(iPlace)) {
                digits.append(0)
            }
        }
        
        for value in initialValueString {
            if value.isNumber {
                let valueInt = value.wholeNumberValue
                digits.append(valueInt ?? 7)
            }
        }
        
        for (i, iDigit) in digits.enumerated() {
            pickerView.selectRow(iDigit, inComponent: i, animated: false)
        }
        
        return pickerView
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(selection: selection, intCases: intCases)
      }
        
    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        
        
        let selection: Binding<Int>
        let intCases: Int
        var pickerComponentsValues = [[Int]]()
          

        init(selection: Binding<Int>, intCases: Int) {
            self.intCases = intCases
            self.selection = selection
            
            for _ in 0..<intCases {
                pickerComponentsValues.append([Int](0...9))
            }
            
        }
        
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return intCases
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return pickerComponentsValues[component].count
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = UILabel()
            
           
                label.text = String(pickerComponentsValues[component][row])
            
            
            label.textColor = UIColor.black
            label.font = UIFont.systemFont(ofSize: 16)
            label.textAlignment = .center
            
            return label
            
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return String(pickerComponentsValues[component][row])
        }
        
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            
            var values = [Int]()
            
            for i in 0..<(intCases) {
                let columnIndexValue = pickerView.selectedRow(inComponent: i)
                values.append(pickerComponentsValues[i][columnIndexValue])
            }

            var result = 0.0
            
            for (i, value) in values.enumerated() {
                let doubleValue = Double(value)
                let exponential: Double = Double(intCases) - 1.0 - Double(i)
                let resultValue = doubleValue*pow(10, exponential)
                result += resultValue
            }
            selection.wrappedValue = Int(result)
        }
      }
    
    
}
