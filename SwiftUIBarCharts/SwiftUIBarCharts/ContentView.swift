//
//  ContentView.swift
//  SwiftUIBarCharts
//
//  Created by Anupam Chugh on 03/11/19.
//  Copyright © 2019 iowncode. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @State var pickerSelection = 0
    @State var barValues : [[CGFloat]] =
        [
        [5,150,50,100,200,110,30,170,50],
        [200,110,30,170,50, 100,100,100,200],
        [10,20,50,100,120,90,180,200,40]
        ]
    var body: some View {
        ZStack{
            Color(.black).edgesIgnoringSafeArea(.all)

            VStack{
                Text("Bar Charts").foregroundColor(.white)
                    .font(.largeTitle)

                Picker(selection: $pickerSelection, label: Text("Stats"))
                    {
                    Text("Views").tag(0)
                    Text("Reads").tag(1)
                    Text("Fans").tag(2)
                }.pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 10)

                HStack(alignment: .center, spacing: 10)
                {

                    ForEach(barValues[pickerSelection], id: \.self){
                        data in
                        
                        BarView(value: data, cornerRadius: CGFloat(integerLiteral: 10*self.pickerSelection))
                    }
                }.padding(.top, 24).animation(.default)
            }
        }
    }


    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .darkGray
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    }
}


struct BarView: View{

    var value: CGFloat
    var cornerRadius: CGFloat
    
    var body: some View {
        VStack {
            ZStack (alignment: .bottom) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: 30, height: 200).foregroundColor(.black)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: 30, height: value).foregroundColor(.green)
                
            }.padding(.bottom, 8)
        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


