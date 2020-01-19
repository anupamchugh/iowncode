//
//  ContentView.swift
//  SwiftUIPullToRefresh
//
//  Created by Anupam Chugh on 18/01/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import SwiftUI

struct Model: Identifiable {
    var id = UUID()
    var title: String
}

struct ContentView: View {
    
    var body: some View {
        GeometryReader{
        geometry in
        NavigationView{
            
                CustomScrollView(width: geometry.size.width, height: geometry.size.height)
                    .navigationBarTitle(Text("SwiftUI Pull To Refresh"), displayMode: .inline)
            
            }
        }
    }
    
}

struct SwiftUIList: View {
        
    @ObservedObject var model: DataModel

    var body: some View {
        List(model.modelData){
            model in
            Text(model.title)
        }
    }
}


class DataModel: ObservableObject {
    @Published var modelData: [Model]
    
    init(modelData: [Model]) {
        self.modelData = modelData
    }
    
    func addElement(){
        modelData.append(Model(title: "Item \(modelData.count + 1)"))
    }
}


struct CustomScrollView : UIViewRepresentable {
    
    var width : CGFloat, height : CGFloat
    let modelData = DataModel(modelData: [Model(title: "Item 1"), Model(title: "Item 2"), Model(title: "Item 3")])
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, model: modelData)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let control = UIScrollView()
        control.refreshControl = UIRefreshControl()
        control.refreshControl?.addTarget(context.coordinator, action:
            #selector(Coordinator.handleRefreshControl),
                                          for: .valueChanged)

        let childView = UIHostingController(rootView: SwiftUIList(model: modelData))
        childView.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        control.addSubview(childView.view)
        return control
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}

    class Coordinator: NSObject {
        var control: CustomScrollView
        var model : DataModel

        init(_ control: CustomScrollView, model: DataModel) {
            self.control = control
            self.model = model
        }

        @objc func handleRefreshControl(sender: UIRefreshControl) {

            sender.endRefreshing()
            model.addElement()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
