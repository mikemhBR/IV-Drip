//
//  HorizontalWheelPicker.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 15/08/23.
//

import SwiftUI

struct ScrollPreferenceKey: PreferenceKey {
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
    
    static var defaultValue: CGFloat = 0
}

struct HorizontalWheelPicker: View {
    let viewPadding: CGFloat
    var initialWeight = 0
    
    @State private var scrollString = "0"
    @State private var previousValue: CGFloat = 0.0
    @State private var scaleMultiplier = 0.0
    @Binding var patientWeight: Double
    
    @State private var scrollIndex = 0
    @State private var scrollProxy: ScrollViewProxy?
    
    var body: some View {
        
        VStack (spacing: 0) {
            
            Text("\(scrollString) kg")
                .font(.system(size: 16))
                .foregroundColor(Color("Text"))
                .frame(width: 52, height: 18)
                .padding(4)
                .background(Color("Row Background"))
                .cornerRadius(4)
            
            ScrollViewReader { readerValue in
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    let largeTickCount = 20
                    
                    ZStack {
                        HStack (alignment: .bottom, spacing: 0) {
                            
                            ForEach(0...largeTickCount, id: \.self) { index in
                                GeometryReader { proxy in
                                    
                                    Rectangle()
                                        .overlay(
                                            Text(String(index*10))
                                                .font(.system(size: 11, weight: .light))
                                                .foregroundColor(Color("Text"))
                                                .offset(y: 18)
                                                .fixedSize()
                                                .scaleEffect(2.0-1.0*abs(proxy.frame(in: .global).minX - midScreen)/midScreen, anchor: .bottom)
                                                .opacity(1.0-0.6*abs(proxy.frame(in: .global).minX - midScreen)/midScreen)
                                        )
                                        .opacity(1.0-0.6*abs(proxy.frame(in: .global).minX - midScreen)/midScreen)
                                }
                                .frame(width: 1, height: 20, alignment: .center)
                                .frame(width: 10, alignment: .center)
                                .id("\(index*10)")
                                
                                ForEach(1...9, id: \.self) { smallIndex in
                                    
                                    GeometryReader { smallProxy in
                                        if smallIndex % 2 == 0 {
                                            Rectangle()
                                                .fill(Color("Text"))
                                                .opacity(1.0-1.0*abs(smallProxy.frame(in: .global).minX - midScreen)/midScreen)
                                        } else {
                                            Rectangle()
                                                .fill(Color("Text"))
                                                .frame(height: 10)
                                                .opacity(0.4)
                                        }
                                        
                                    }
                                    
                                    .frame(width: 1, height: 15, alignment: .center)
                                    .frame(width: 10, alignment: .center)
                                    .id("\(index*10 + (smallIndex))")
                                }
                            }
                            
                        }
                        
                        GeometryReader { proxy in
                            
                            let offset = proxy.frame(in: .named("scroll")).minX
                            Color.clear.preference(key: ScrollPreferenceKey.self, value: offset)
                            
                            
                        }
                    }
                    .offset(x: (UIScreen.main.bounds.width - viewPadding*2)/2)
                    .padding(.trailing, UIScreen.main.bounds.width - viewPadding*2)
                    .onAppear {
                        scrollProxy = readerValue
                        readerValue.scrollTo("\(initialWeight)", anchor: .center)
                    }
                }
                .overlay(
                    Rectangle()
                        .foregroundStyle(Color.blue)
                        .frame(width: 1, height: 20)
                        .offset(x: 5, y: -24)
                    
                )
                .coordinateSpace(name: "scroll")
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .backgroundStyle(Color.gray)
                .onPreferenceChange (ScrollPreferenceKey.self ){ value in
                    let screenOffset = ((UIScreen.main.bounds.width-viewPadding*2)/2 - (value))/10
                    
                    if screenOffset > 0 {
                        scrollString = String(format: "%.0f", screenOffset)
                        previousValue = value
                        patientWeight = screenOffset
                    } else {
                        scrollString = String(format: "%.0f", 0)
                        previousValue = 0
                        patientWeight = 0
                    }
                    
                    
                }
                
            }
            
            
        }
        .coordinateSpace(name: "vstack")
        
        
    }
    
    var midScreen: CGFloat {
        return (UIScreen.main.bounds.width - viewPadding*2)/2
    }
}

struct HorizontalWheelPicker_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalWheelPicker(viewPadding: Constants.Layout.kPadding/2, patientWeight: .constant(0.0))
    }
}
