//
//  ViewController.swift
//  iOS13VisionPetAnimalClassifier
//
//  Created by Anupam Chugh on 28/09/19.
//  Copyright © 2019 Anupam Chugh. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!

    var animalRecognitionRequest = VNRecognizeAnimalsRequest(completionHandler: nil)
    
    private let animalRecognitionWorkQueue = DispatchQueue(label: "PetClassifierRequest", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = false
        setupVision()
    }

    @IBAction func takePicture(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func setupVision() {
        animalRecognitionRequest = VNRecognizeAnimalsRequest { (request, error) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNRecognizedObjectObservation] {
                    var detectionString = ""
                    var animalCount = 0
                    for result in results
                    {
                        let animals = result.labels

                        for animal in animals {
                            
                            animalCount = animalCount + 1
                            var animalLabel = ""
                            
                            if animal.identifier == "Cat"{
                                animalLabel = "😸"
                            }
                            else{
                                animalLabel = "🐶"
                            }
                            
                            let string = "#\(animalCount) \(animal.identifier) \(animalLabel) confidence is \(animal.confidence)\n"
                            detectionString = detectionString + string
                        }
                    }
                    
                    if detectionString.isEmpty{
                        detectionString = "Neither cat nor dog"
                    }
                    self.textView.text = detectionString
                }
            }
        }
    }
    
    private func processImage(_ image: UIImage) {
        imageView.image = image
        animalClassifier(image)
    }
    
    private func animalClassifier(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        textView.text = ""
        animalRecognitionWorkQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([self.animalRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.imageView.image = image
                self.processImage(image)
                
            }
        }
    }
    
}

