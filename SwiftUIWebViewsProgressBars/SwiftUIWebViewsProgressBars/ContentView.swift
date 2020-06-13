//
//  ContentView.swift
//  SwiftUIWebViewsProgressBars
//
//  Created by Anupam Chugh on 12/06/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import SwiftUI
import WebKit


class WebViewModel: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var didFinishLoading: Bool = false
    @Published var link : String

    init (progress: Double, link : String) {
        self.progress = progress
        self.link = link
    }
}

struct SwiftUIProgressBar: View {
    
    @Binding var progress: Double
    @State var isShowing = false
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.gray)
                    .opacity(0.3)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                Rectangle()
                    .foregroundColor(Color.blue)
                    .frame(width: self.isShowing ? geometry.size.width * CGFloat((self.progress)) : 0.0,
                           height: geometry.size.height)
                    .animation(.linear(duration: 0.5))
            }
            .onAppear {
                self.isShowing = true
            }
            
        }
    }
}

struct SwiftUIWebView : UIViewRepresentable {

    @ObservedObject var viewModel: WebViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }

    let webView = WKWebView()

    func makeUIView(context: Context) -> WKWebView {
        if let url = URL(string: viewModel.link) {
            self.webView.load(URLRequest(url: url))
        }
        return self.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        //add your code here...
    }
}

class Coordinator: NSObject {

    private var viewModel: WebViewModel
    
    var parent: SwiftUIWebView
    private var estimatedProgressObserver: NSKeyValueObservation?

    init(_ parent: SwiftUIWebView, viewModel: WebViewModel) {
        self.parent = parent
        self.viewModel = viewModel
        super.init()
        
        estimatedProgressObserver = self.parent.webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            print(Float(webView.estimatedProgress))
            guard let weakSelf = self else{return}

            if webView.estimatedProgress == 1.0{
                weakSelf.viewModel.didFinishLoading = true
            }
            else{
            weakSelf.viewModel.progress = webView.estimatedProgress
            }
            
        }
    }

    deinit {
        estimatedProgressObserver = nil
    }
}


struct ContentView : View {
    @ObservedObject var model = WebViewModel(progress: 0.0, link: "https://www.medium.com")
    

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {

                VStack {
                    SwiftUIWebView(viewModel: model)
                }

                if !model.didFinishLoading {
                SwiftUIProgressBar(progress: .constant(model.progress))
                    .frame(height: 15.0)
                    .foregroundColor(.accentColor)
                    
                }
                
            }
            .navigationBarTitle("SwiftUIWebViewProgressBar", displayMode: .inline)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
