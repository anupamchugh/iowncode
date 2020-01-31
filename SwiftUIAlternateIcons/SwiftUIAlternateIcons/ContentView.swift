//
//  ContentView.swift
//  SwiftUIAlternateIcons
//
//  Created by Anupam Chugh on 30/01/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var iconSettings : IconNames

    var body: some View {
        NavigationView {
            Form {
                Section{
                    
                    Picker(selection: $iconSettings.currentIndex, label: Text("Icons"))
                    {
                        ForEach(0..<iconSettings.iconNames.count) { index in
                            HStack{
                                Text(self.iconSettings.iconNames[index] ?? "Default")
                                    .frame(minWidth : 100, alignment: .leading)

                                Image(uiImage: UIImage(named: self.iconSettings.iconNames[index] ?? "Default") ?? UIImage())
                                    .renderingMode(.original) //important
                                    .frame(height: 50)
                            }
                        }
                    }.onReceive([self.iconSettings.currentIndex].publisher.first()) { (value) in

                        let index = self.iconSettings.iconNames.firstIndex(of: UIApplication.shared.alternateIconName) ?? 0

                        if index != value{
 
                            UIApplication.shared.setAlternateIconName(self.iconSettings.iconNames[value]){ error in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    print("Success!")
                                }
                            }
                        }
                    }
                }

            } .navigationBarTitle("AlternateIcons", displayMode: .inline)

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


