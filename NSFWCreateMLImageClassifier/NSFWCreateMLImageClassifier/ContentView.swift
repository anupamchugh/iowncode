//
//  ContentView.swift
//  NSFWCreateMLImageClassifier
//
//  Created by Anupam Chugh on 03/12/19.
//  Copyright © 2019 iowncode. All rights reserved.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    
    @State var imagesData = [
        ImageData(imageName: "image1"),
        ImageData(imageName: "image2"),
        ImageData(imageName: "image3"),
        ImageData(imageName: "image4"),
        ImageData(imageName: "image5")]
    
    var body: some View {
        NavigationView{
            List{
                ForEach(imagesData, id: \.id){
                    data in
                    HStack{
                        
                        Image(data.imageName)
                            .resizable()
                            .frame(width: 100.0, height: 100.0)
                            .scaledToFit()
                            .blur(radius: (data.label == "SFW" ? 0 : 20))
                        
                        Spacer()
                        Text(data.label)
                            .padding(10)
                    }
                }
            }.navigationBarTitle(Text("NSFW Detector"))
            
        }.onAppear(perform: runNSFWDetector)
    }
    
    func runNSFWDetector()
    {
        guard let model = try? VNCoreMLModel(for: NSFWDetector().model) else {
            return
        }

        for i in 0..<imagesData.count{

            guard let image = UIImage(named: imagesData[i].imageName)
                else{continue}

            guard let ciImage = CIImage(image: image)
                else{continue}

            let request = VNCoreMLRequest(model: model) { request, error in
                let results = request.results?.first as? VNClassificationObservation
                self.imagesData[i].label = results?.identifier ?? "Error"
            }

            let handler = VNImageRequestHandler(ciImage: ciImage)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print(error)
                }
            }
        }
    }
}



struct ImageData : Identifiable{
    public let id = UUID()
    public var imageName : String
    public var label : String = "Processing..."
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
