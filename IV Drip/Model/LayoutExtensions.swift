//
//  LayoutExtensions.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI


struct PrimaryButtonConfig: ViewModifier {
    
    var cornerRadius: CGFloat = Constants.Layout.buttonRadius.large.rawValue
    var buttonHeight: CGFloat = Constants.Layout.buttonHeight.medium.rawValue
    var backgroundColor: Color = Color("Accent Blue")
    var fontColor: Color = Color("Text ButtonP")
    var fontSize: CGFloat = 14
    var borderColors = [Color("Button Border Top"), Color("Button Border Bottom")]
    var active = true
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundColor(active ? fontColor : Color("Inactive Button Font"))
            .frame(height: buttonHeight)
            .background(active ? backgroundColor : Color("Button 2 Top"), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.linearGradient(colors: borderColors, startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 1, y: 1)), lineWidth: 1)
                    
            )
            .cornerRadius(cornerRadius)
    }
}




struct Caption3Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(Color("Text"))
    }
}

struct SubHeadlineTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(Color("Text"))
    }
}
struct HeadlineTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(Color("Text"))
    }
}

struct SectionHeader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color("Text").opacity(0.8))
    }
}

struct InputRowTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16))
            .foregroundColor(Color("Text"))
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .frame(width: 88, height: Constants.Layout.textFieldHeight)
            .background(Color.white)
            .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
    }
}

struct InputRowButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: true, vertical: false)
            .padding(Constants.Layout.kPadding/2)
            .frame(width: 80, height: Constants.Layout.textFieldHeight)
            .background(Color("Accent Blue").opacity(0.2))
            .font(.system(size: 12))
            .cornerRadius(Constants.Layout.kPadding/2)
    }
}
extension View {
    func caption3Title() -> some View {
        modifier(Caption3Title())
    }
    
    func subHeadlineTitle() -> some View {
        modifier(HeadlineTitle())
    }
    
    func headlineTitle() -> some View {
        modifier(HeadlineTitle())
    }
    
    func sectionHeaderStyle() -> some View {
        modifier(SectionHeader())
    }
}
