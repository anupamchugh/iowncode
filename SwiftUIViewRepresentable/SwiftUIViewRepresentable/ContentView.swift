//
//  ContentView.swift
//  SwiftUIViewRepresentable
//
//  Created by Anupam Chugh on 06/05/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import SwiftUI
import UIKit

import PieCharts

struct ContentView: View {
    
    @State private var shouldAnimate = false
    
    var body: some View {
        VStack{

            
            Anything(UISearchBar(frame: .zero)){
                $0.autocapitalizationType = .none
                $0.placeholder = "placeholder"
            }
            
            Anything(PieChart(frame: CGRect(x: 0, y: 0, width: 350, height: 200))){
                $0.models = [
                    PieSliceModel(value: 2.1, color: UIColor.systemYellow),
                    PieSliceModel(value: 3, color: UIColor.systemPurple),
                    PieSliceModel(value: 1, color: UIColor.systemGreen)
                ]
            
            }
            
            Anything(UITextView())
            {
                $0.font = UIFont.preferredFont(forTextStyle: .body)
                
                $0.isScrollEnabled = true
                $0.isEditable = true
                $0.isUserInteractionEnabled = true
            }
            
            Anything(UIPageControl())
            {
                $0.numberOfPages = 5
                $0.currentPageIndicatorTintColor = UIColor.systemPink
                $0.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.8)
            }

            
            Anything(UIActivityIndicatorView(style: .large)) {
                if self.shouldAnimate {
                    $0.startAnimating()
                } else {
                    $0.stopAnimating()
                }
            }


            Button(action: {
                self.shouldAnimate = !self.shouldAnimate
            }, label: {
                Text("Show/Hide")
                    .foregroundColor(Color.white)
                    .padding()
            })
                .background(Color.red)
                .cornerRadius(8)
                .padding()
            
            
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct Anything<Wrapper : UIView>: UIViewRepresentable {
    typealias Updater = (Wrapper, Context) -> Void

    var makeView: () -> Wrapper
    var update: (Wrapper, Context) -> Void

    init(_ makeView: @escaping @autoclosure () -> Wrapper,
         updater update: @escaping (Wrapper) -> Void) {
        self.makeView = makeView
        self.update = { view, _ in update(view) }
    }

    func makeUIView(context: Context) -> Wrapper {
        makeView()
    }

    func updateUIView(_ view: Wrapper, context: Context) {
        update(view, context)
    }
}
