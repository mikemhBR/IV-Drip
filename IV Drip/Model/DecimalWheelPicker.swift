//
//  DecimalWheelPicker.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.

import SwiftUI

struct DecimalWheelPicker: UIViewRepresentable {
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    let intCases: Int
    let decimalCases: Int
    let selection: Binding<Double>
    let initialValue: Double
    
    func makeUIView(context: Context) -> some UIPickerView {
        let pickerView = UIPickerView(frame: .zero)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = context.coordinator
        pickerView.dataSource = context.coordinator
        
        
        let initialValueString = "\(initialValue)"
        
        
        var digits = [Int]()
                
        for iPlace in 1..<intCases {
            if initialValue < pow(10, Double(intCases) - Double(iPlace)) {
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
        
        pickerView.selectRow(0, inComponent: intCases, animated: false)
        
        if initialValue.truncatingRemainder(dividingBy: 1) == 0 {
            return pickerView
        }
        
        
        var decimalString = String(format: "%.\(decimalCases)f", initialValue.truncatingRemainder(dividingBy: 1))
        decimalString = String(decimalString.suffix(decimalString.count - 2))
        
        
        var i = 0
        
        for decimal in decimalString {
            if (intCases + i) >= (intCases + decimalCases) {
                break
            }
            if decimal.isNumber {
                let valueInt = decimal.wholeNumberValue
                pickerView.selectRow(valueInt ?? 7, inComponent: intCases + i + 1, animated: false)
                i += 1
            }
        }
        return pickerView
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(selection: selection, intCases: intCases, decimalCases: decimalCases)
      }
        
    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        
        
        let selection: Binding<Double>
        let intCases: Int
        let decimalCases: Int
        var pickerComponentsValues = [[Int]]()
          

        init(selection: Binding<Double>, intCases: Int, decimalCases: Int) {
            self.intCases = intCases
            self.decimalCases = decimalCases
            self.selection = selection
            
            for _ in 0..<intCases {
                pickerComponentsValues.append([Int](0...9))
            }
            
            pickerComponentsValues.append([9999])
            
            for _ in 0..<decimalCases {
                pickerComponentsValues.append([Int](0...9))
            }
            
        }
        
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return intCases+decimalCases+1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return pickerComponentsValues[component].count
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = UILabel()
            
            if pickerComponentsValues[component][row] == 9999 {
                label.text = ","
            } else {
                label.text = String(pickerComponentsValues[component][row])
            }
            
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
            
            for i in (intCases+1)...(intCases + decimalCases) {
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
            selection.wrappedValue = result
        }
      }
    
    
}
