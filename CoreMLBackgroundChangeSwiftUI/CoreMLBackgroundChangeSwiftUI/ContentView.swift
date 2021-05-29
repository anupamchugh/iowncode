//
//  ContentView.swift
//  CoreMLBackgroundChangeSwiftUI
//
//  Created by Anupam Chugh on 27/05/21.
//

import SwiftUI
import CoreML
import CoreMedia
import Vision

struct ContentView: View {

    @State var outputImage : UIImage = UIImage(named: "unsplash")!
    @State var inputImage : UIImage = UIImage(named: "unsplash")!

    var body: some View {
        
            
            ScrollView{
                
                VStack{
                    
                    HStack{
                        
                        Image(uiImage: inputImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            
                        Spacer()
                        Image(uiImage: outputImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)

                    }

                    Button(action: {runVisionRequest()}, label: {
                        Text("Run Image Segmentation")
                    })
                    .padding()
                    
                }.ignoresSafeArea()
            //}
        }
    }

    func runVisionRequest() {
        
        guard let model = try? VNCoreMLModel(for: DeepLabV3(configuration: .init()).model)
        else { return }
        
        let request = VNCoreMLRequest(model: model, completionHandler: visionRequestDidComplete)
        request.imageCropAndScaleOption = .scaleFill
        DispatchQueue.global().async {

            let handler = VNImageRequestHandler(cgImage: inputImage.cgImage!, options: [:])
            
            do {
                try handler.perform([request])
            }catch {
                print(error)
            }
        }
    }
    
    func maskInputImage(){
        
//        let points = [GradientPoint(location: 0, color: #colorLiteral(red: 0.6486759186, green: 0.2260715365, blue: 0.2819285393, alpha: 1)), GradientPoint(location: 0.2, color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 0.5028884243)), GradientPoint(location: 0.4, color: #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 0.3388534331)),
//                  GradientPoint(location: 0.6, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 0.3458681778)), GradientPoint(location: 0.8, color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.3388534331))]
//
//        let bgImage = UIImage(size: self.inputImage.size, gradientPoints: points, scale: self.inputImage.scale)!
        
        let bgImage = UIImage.imageFromColor(color: .orange, size: self.inputImage.size, scale: self.inputImage.scale)!

        let beginImage = CIImage(cgImage: inputImage.cgImage!)
        let background = CIImage(cgImage: bgImage.cgImage!)
        let mask = CIImage(cgImage: self.outputImage.cgImage!)
        
        if let compositeImage = CIFilter(name: "CIBlendWithMask", parameters: [
                                        kCIInputImageKey: beginImage,
                                        kCIInputBackgroundImageKey:background,
                                        kCIInputMaskImageKey:mask])?.outputImage
        {
            
            
            let ciContext = CIContext(options: nil)

            let filteredImageRef = ciContext.createCGImage(compositeImage, from: compositeImage.extent)
            
            self.inputImage = UIImage(cgImage: filteredImageRef!)
            
        }
    }

    func visionRequestDidComplete(request: VNRequest, error: Error?) {
            DispatchQueue.main.async {
                if let observations = request.results as? [VNCoreMLFeatureValueObservation],
                    let segmentationmap = observations.first?.featureValue.multiArrayValue {
                    
                    let segmentationMask = segmentationmap.image(min: 0, max: 1)

                    self.outputImage = segmentationMask!.resizedImage(for: self.inputImage.size)!

                    maskInputImage()

                }
            }
    }
}

struct GradientPoint {
   var location: CGFloat
   var color: UIColor
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
