//
//  ViewController+Vision.swift
//  iOSFindMyText
//
//  Created by Anupam Chugh on 14/08/19.
//  Copyright © 2019 Anupam Chugh. All rights reserved.
//

import UIKit
import Vision


extension ViewController
{
    func createVisionRequest(image: UIImage)
    {
        
        currentImage = image
        guard let cgImage = image.cgImage else {
            return
        }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImageOrientation, options: [:])
        let vnRequests = [vnTextDetectionRequest]
        
        DispatchQueue.global(qos: .background).async {
            do{
                try requestHandler.perform(vnRequests)
            }catch let error as NSError {
                print("Error in performing Image request: \(error)")
            }
        }
        
    }
    
    var vnTextDetectionRequest : VNDetectTextRectanglesRequest{
        let request = VNDetectTextRectanglesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                guard let observations = request.results as? [VNTextObservation]
                    else {
                        return
                }
                
                var numberOfWords = 0
                for textObservation in observations {
                    var numberOfCharacters = 0
                    for rectangleObservation in textObservation.characterBoxes! {
                        let croppedImage = crop(image: self.currentImage, rectangle: rectangleObservation)
                        if let croppedImage = croppedImage {
                            let processedImage = preProcess(image: croppedImage)
                            self.imageClassifier(image: processedImage,
                                               wordNumber: numberOfWords,
                                               characterNumber: numberOfCharacters, currentObservation: textObservation)
                            numberOfCharacters += 1
                        }
                    }
                    numberOfWords += 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    self.drawRectanglesOnObservations(observations: observations)
                })
                
            }
        }
        
        request.reportCharacterBoxes = true
        
        return request
    }
    
    
    
    //COREML
    func imageClassifier(image: UIImage, wordNumber: Int, characterNumber: Int, currentObservation : VNTextObservation){
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("Unexpected result type from VNCoreMLRequest")
            }
            let result = topResult.identifier
            let classificationInfo: [String: Any] = ["wordNumber" : wordNumber,
                                                     "characterNumber" : characterNumber,
                                                     "class" : result]
            self?.handleResult(classificationInfo, currentObservation: currentObservation)
        }
        guard let ciImage = CIImage(image: image) else {
            fatalError("Could not convert UIImage to CIImage :(")
        }
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            }
            catch {
                print(error)
            }
        }
    }
    
    func handleResult(_ result: [String: Any], currentObservation : VNTextObservation) {
        objc_sync_enter(self)
        guard let wordNumber = result["wordNumber"] as? Int else {
            return
        }
        guard let characterNumber = result["characterNumber"] as? Int else {
            return
        }
        guard let characterClass = result["class"] as? String else {
            return
        }
        if (textMetadata[wordNumber] == nil) {
            let tmp: [Int: String] = [characterNumber: characterClass]
            textMetadata[wordNumber] = tmp
        } else {
            var tmp = textMetadata[wordNumber]!
            tmp[characterNumber] = characterClass
            textMetadata[wordNumber] = tmp
        }
        objc_sync_exit(self)
        DispatchQueue.main.async {
            self.doTextDetection(currentObservation: currentObservation)
        }
    }
    
    func doTextDetection(currentObservation : VNTextObservation) {
        var result: String = ""
        if (textMetadata.isEmpty) {
            print("The image does not contain any text.")
            return
        }
        let sortedKeys = textMetadata.keys.sorted()
        for sortedKey in sortedKeys {
            result +=  word(fromDictionary: textMetadata[sortedKey]!) + " "
            
        }
        
        observationStringLookup[currentObservation] = result
        
    }
    
    func word(fromDictionary dictionary: [Int : String]) -> String {
        let sortedKeys = dictionary.keys.sorted()
        var word: String = ""
        for sortedKey in sortedKeys {
            let char: String = dictionary[sortedKey]!
            word += char
        }
        return word
    }
    
    
    //Draw recognised texts.
    func drawRectanglesOnObservations(observations : [VNDetectedObjectObservation]){
        DispatchQueue.main.async {
            guard let image = self.imageView.image
                else{
                    print("Failure in retriving image")
                    return
            }
            let imageSize = image.size
            var imageTransform = CGAffineTransform.identity.scaledBy(x: 1, y: -1).translatedBy(x: 0, y: -imageSize.height)
            imageTransform = imageTransform.scaledBy(x: imageSize.width, y: imageSize.height)
            UIGraphicsBeginImageContextWithOptions(imageSize, true, 0)
            let graphicsContext = UIGraphicsGetCurrentContext()
            image.draw(in: CGRect(origin: .zero, size: imageSize))
            
            graphicsContext?.saveGState()
            graphicsContext?.setLineJoin(.round)
            graphicsContext?.setLineWidth(8.0)
            
            graphicsContext?.setFillColor(red: 0, green: 1, blue: 0, alpha: 0.3)
            graphicsContext?.setStrokeColor(UIColor.green.cgColor)
            
            
            
            var previousString = ""
            let elements = ["VISION","COREML"]
            
            observations.forEach { (observation) in
                
                var string = observationStringLookup[observation as! VNTextObservation] ?? ""
                let tempString = string
                string = string.replacingOccurrences(of: previousString, with: "")
                string = string.trim()
                previousString = tempString
                
                if elements.contains(where: string.contains){
                    
                    let observationBounds = observation.boundingBox.applying(imageTransform)
                    graphicsContext?.addRect(observationBounds)
                }
                
                
            }
            graphicsContext?.drawPath(using: CGPathDrawingMode.fillStroke)
            graphicsContext?.restoreGState()
            
            let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.imageView.image = drawnImage
            
        }
    }

}

