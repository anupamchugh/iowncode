//
//  SwiftUIView.swift
//  SwiftUIWebViewsProgressBars
//
//  Created by Anupam Chugh on 13/06/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import SwiftUI
import WebKit


//This code would keep re-rendering the views on Modifying the progress state.
//For correct example, check out the ContentView.swift file.
struct SwiftUIView : View {
    @State var progress : Double = 0.0

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {

                VStack {
                    Webview(req: URLRequest(url: URL(string: "https://medium.com")!), progress: $progress)
                }

                SwiftUIProgressBar(progress: $progress)
                .frame(height: 15.0)
                .foregroundColor(.accentColor)

            }
            .navigationBarTitle("ProgressBar", displayMode: .inline)
        }
    }
}


struct Webview : UIViewRepresentable {
    let request: URLRequest
    var webview: WKWebView?

    @Binding var progress: Double

    init(web: WKWebView? = nil, req: URLRequest, progress: Binding<Double>) {
        self.webview = WKWebView()
        self.request = req
        _progress = progress
    }

    func makeCoordinator() -> MyCoordinator {
        MyCoordinator(self, progress: $progress)
    }

    func makeUIView(context: Context) -> WKWebView  {
        return webview!
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
}

class MyCoordinator: NSObject {

    @Binding var progress: Double
    var parent: Webview
    private var estimatedProgressObserver: NSKeyValueObservation?

    init(_ parent: Webview, progress: Binding<Double>) {
        self.parent = parent
        _progress = progress
        super.init()

        estimatedProgressObserver = self.parent.webview?.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            print(Float(webView.estimatedProgress))
            guard let weakSelf = self else{return}
            
            //glaring issue
            weakSelf.progress = webView.estimatedProgress

        }
    }

    deinit {
        estimatedProgressObserver = nil
    }
}


struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
