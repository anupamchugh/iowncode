//
//  ContentView.swift
//  iOSImageSimilarityUsingVision
//
//  Created by Anupam Chugh on 01/12/19.
//  Copyright © 2019 iowncode. All rights reserved.
//

import SwiftUI
import Vision

struct ContentView: View {
    
    
    var sourceImage = "source_car"
    
    @State var modelData = [
                            ModelData(id: 0, imageName: "scene"),
                            ModelData(id: 1, imageName: "bike_1"),
                            ModelData(id: 2, imageName: "car_2"),
                            ModelData(id: 3, imageName: "bike_2"),
                            ModelData(id: 4, imageName: "car_1")]
    
    
    
    var body: some View {

        NavigationView{
            VStack{
            
            Image(sourceImage)
                .resizable()
                .frame(width: 200.0, height: 200.0)
                .scaledToFit()
                Divider()
                
            List{
                ForEach(modelData, id: \.id){
                    model in
                    HStack{
                        Text(model.distance)
                            .padding(10)
                        Spacer()
                        Image(model.imageName)
                            .resizable()
                            .frame(width: 100.0, height: 100.0)
                            .scaledToFit()
                    }
                }
            }
                
            }.navigationBarItems(
            trailing: Button(action: processImages, label: { Text("Process") }))
                .navigationBarTitle(Text("Vision Image Similarity"), displayMode: .inline)
        }
    }
    
    func processImages()
    {
        
        guard self.modelData.count > 0 else{
            return
        }
        
        var observation : VNFeaturePrintObservation?
        var sourceObservation : VNFeaturePrintObservation?
    
        sourceObservation = featureprintObservationForImage(image: UIImage(named: sourceImage)!)
        
        var tempData = modelData
        
        tempData = modelData.enumerated().map { (i,m) in
            var model = m
            if let uiimage = UIImage(named: model.imageName){
                observation = featureprintObservationForImage(image: uiimage)
                
                do{
                    var distance = Float(0)
                    if let sourceObservation = sourceObservation{
                        try observation?.computeDistance(&distance, to: sourceObservation)
                        model.distance = "\(distance)"
                    }
                }catch{
                    print("errror occurred..")
                }
                
            }
            
            return model
        }
        
        modelData = tempData.sorted(by: {Float($0.distance)! < Float($1.distance)!})
    }
    
    func featureprintObservationForImage(image: UIImage) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        do {
            try requestHandler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            print("Vision error: \(error)")
            return nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}


struct ModelData : Identifiable{
    public let id: Int
    public var imageName : String
    public var distance : String = "NA"
}
