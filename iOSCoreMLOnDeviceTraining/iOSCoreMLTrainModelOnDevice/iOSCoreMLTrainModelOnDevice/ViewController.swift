//
//  ViewController.swift
//  iOSCoreMLTrainModelOnDevice
//
//  Created by Anupam Chugh on 01/10/19.
//  Copyright © 2019 Anupam Chugh. All rights reserved.
//

import UIKit
import CoreML
import Vision

enum Animal {
    case cat
    case dog
}


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var btnTrainImages: UIButton!
    @IBOutlet weak var trainingImagesCount: UILabel!
    @IBOutlet weak var predicatedClassLabel: UILabel!
    @IBOutlet weak var btnToggleClassLabel: UIButton!
    private var updatableModel : MLModel?
    
    @IBOutlet weak var imageView: UIImageView!
    var imageLabelDictionary : [UIImage:String] = [:]
    
    var retrainImageCount = 0{
        didSet{
            if retrainImageCount == 0{
                trainingImagesCount.text = ""
                btnTrainImages.alpha = 0
            }
        }
    }
    
    var imageConstraint: MLImageConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
        
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
            let fileURL = documentDirectory.appendingPathComponent("CatDog.mlmodelc")
            if let model = loadModel(url: fileURL){
                updatableModel = model
            }
            else{
                if let modelURL = Bundle.main.url(forResource: "CatDogUpdatable", withExtension: "mlmodelc"){
                    if let model = loadModel(url: modelURL){
                        updatableModel = model
                    }
                }
            }

            if let updatableModel = updatableModel{
                imageConstraint = self.getImageConstraint(model: updatableModel)
            }
    
        }catch(let error){
            print("initial error is \(error.localizedDescription)")
        }
        
        btnToggleClassLabel.alpha = 0
    }
    
    //MARK:- Get MLImageConstraints

    func getImageConstraint(model: MLModel) -> MLImageConstraint {
      return model.modelDescription.inputDescriptionsByName["image"]!.imageConstraint!
    }
    
    //MARK:- Load Model From URL
    
    private func loadModel(url: URL) -> MLModel? {
      do {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        return try MLModel(contentsOf: url, configuration: config)
      } catch {
        print("Error loading model: \(error)")
        return nil
      }
    }

    
    @IBAction func takePhotoClicked(_ sender: Any) {
    
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.imageView.image = image
                let animal = self.predict(image: image)

                if let animal = animal{
                    if animal == .dog{
                        self.predicatedClassLabel.text = "Dog"
                        self.btnToggleClassLabel.alpha = 1
                        self.btnToggleClassLabel.tag = 0
                        self.btnToggleClassLabel.setTitle("Click here if it's a Cat!", for: .normal)
                    }
                    else if animal == .cat{
                        self.btnToggleClassLabel.alpha = 1
                        self.predicatedClassLabel.text = "Cat"
                        
                        self.btnToggleClassLabel.tag = 1
                        self.btnToggleClassLabel.setTitle("Click here if it's a Dog!", for: .normal)
                    }
                }
                else{
                    self.predicatedClassLabel.text = "Neither dog nor cat."
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Run Prediction
    
    func predict(image: UIImage) -> Animal? {
        
        do{
        
            let imageOptions: [MLFeatureValue.ImageOption: Any] = [
                .cropAndScale: VNImageCropAndScaleOption.scaleFill.rawValue
            ]
            let featureValue = try MLFeatureValue(cgImage: image.cgImage!, constraint: imageConstraint, options: imageOptions)
            let featureProviderDict = try MLDictionaryFeatureProvider(dictionary: ["image" : featureValue])
            let prediction = try updatableModel?.prediction(from: featureProviderDict)
            let value = prediction?.featureValue(for: "classLabel")?.stringValue
            if value == "Dog"{
                return .dog
            }
            else{
                return .cat
            }
        }catch(let error){
            print("error is \(error.localizedDescription)")
        }
        return nil
    }
    
    //MARK:- Image Label Dictionary for training
    
    @IBAction func btnAddToTraining(_ sender: UIButton) {
        btnToggleClassLabel.alpha = 0
        
        if btnTrainImages.alpha == 0{
            btnTrainImages.alpha = 1
        }
        retrainImageCount = retrainImageCount + 1
        trainingImagesCount.text = "\(retrainImageCount)"
        
        if let image = imageView.image{
            var label = "Dog"
            if sender.tag == 0{
                label = "Cat"
            }
            imageLabelDictionary[image] = label
        }
    }
    
    //MARK:- MLArrayBatchProvider
    
    private func batchProvider() -> MLArrayBatchProvider
    {

        var batchInputs: [MLFeatureProvider] = []
        let imageOptions: [MLFeatureValue.ImageOption: Any] = [
          .cropAndScale: VNImageCropAndScaleOption.scaleFill.rawValue
        ]
        for (image,label) in imageLabelDictionary {
            
            do{
                let featureValue = try MLFeatureValue(cgImage: image.cgImage!, constraint: imageConstraint, options: imageOptions)
              
                if let pixelBuffer = featureValue.imageBufferValue{
                    let x = CatDogUpdatableTrainingInput(image: pixelBuffer, classLabel: label)
                    batchInputs.append(x)
                }
            }
            catch(let error){
                print("error description is \(error.localizedDescription)")
            }
        }
     return MLArrayBatchProvider(array: batchInputs)
    }

    
    //MARK:- Training the Model Using MLUpdateTask
    
    @IBAction func startTraining(_ sender: Any) {
            
        let modelConfig = MLModelConfiguration()
        modelConfig.computeUnits = .cpuAndGPU
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
            
            var modelURL = CatDogUpdatable.urlOfModelInThisBundle
            let pathOfFile = documentDirectory.appendingPathComponent("CatDog.mlmodelc")
            
            if fileManager.fileExists(atPath: pathOfFile.path){
                modelURL = pathOfFile
            }
                        
            let updateTask = try MLUpdateTask(forModelAt: modelURL, trainingData: batchProvider(), configuration: modelConfig,
                             progressHandlers: MLUpdateProgressHandlers(forEvents: [.trainingBegin,.epochEnd],
                              progressHandler: { (contextProgress) in
                                print(contextProgress.event)
                                // you can check the progress here, after each epoch
                                
                             }) { (finalContext) in
                                
                                if finalContext.task.error?.localizedDescription == nil{
                                    let fileManager = FileManager.default
                                    do {

                                        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
                                        let fileURL = documentDirectory.appendingPathComponent("CatDog.mlmodelc")
                                        try finalContext.model.write(to: fileURL)
                                        
                                        self.updatableModel = self.loadModel(url: fileURL)
                                        
                                        DispatchQueue.main.async {
                                            self.btnTrainImages.alpha = 0
                                            self.imageLabelDictionary = [:]
                                            self.retrainImageCount = 0
                                        }

                                    } catch(let error) {
                                        print("error is \(error.localizedDescription)")
                                    }
                                }
                                
                                
            })
            updateTask.resume()
            
        } catch {
            print("Error while upgrading \(error.localizedDescription)")
        }
    }
}


