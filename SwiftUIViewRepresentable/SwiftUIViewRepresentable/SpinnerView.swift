//
//  SpinnerView.swift
//  SwiftUIViewRepresentable
//
//  Created by Anupam Chugh on 07/05/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import SwiftUI


struct SpinnerView: View {

    @State private var shouldAnimate = false

    var body: some View {
        VStack {
            ActivityIndicator(startAnimating: self.$shouldAnimate)

            Button(action: {
                self.shouldAnimate = !self.shouldAnimate
            }, label: {
                Text("Show/Hide")
                    .foregroundColor(Color.white)
                    .padding()
            })
                .background(Color.red)
                .cornerRadius(8)
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var startAnimating: Bool

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: .medium)

    }

    func updateUIView(_ uiView: UIActivityIndicatorView,
                      context: Context) {
        if self.startAnimating {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}



struct SpinnerView_Previews: PreviewProvider {
    static var previews: some View {
        SpinnerView()
    }
}
