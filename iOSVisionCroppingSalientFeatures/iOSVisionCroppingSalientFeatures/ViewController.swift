//
//  ViewController.swift
//  iOSVisionCroppingSalientFeatures
//
//  Created by Anupam Chugh on 19/11/19.
//  Copyright © 2019 iowncode. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    

    var saliencyRequest = VNGenerateObjectnessBasedSaliencyImageRequest(completionHandler: nil)
    private let workQueue = DispatchQueue(label: "VisionRequest", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    var imageView: UIImageView?
    
    let button:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        view.setImage(UIImage(systemName: "photo.fill", withConfiguration: config), for: .normal)
        
        return view
    }()
    
    let marginConstant : CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupImageView()
        setupButton()
    }
    
    func setupButton()
    {
        self.view.addSubview(button)
        
        button.addTarget(self, action: #selector(onButtonClick(sender:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 150),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -marginConstant/2),
            button.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        button.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
    }
    
    @objc func onButtonClick(sender: UIButton){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func setupImageView()
    {
        imageView = UIImageView(frame: .zero)
        imageView?.contentMode = .scaleAspectFit
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView!)
        
        
        NSLayoutConstraint.activate([
            imageView!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: marginConstant),
            imageView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -marginConstant),
            imageView!.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: marginConstant),
            imageView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -marginConstant),
        ])
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.imageView?.image = image
                self.processImage(image)
                
            }
        }
    }

    private func processImage(_ image: UIImage) {
        
        guard let originalImage = image.cgImage else { return }
        
        workQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: originalImage, options: [:])
            do {
                try requestHandler.perform([self.saliencyRequest])
                guard let results = self.saliencyRequest.results?.first
                    else{return}
                
                if let observation = results as? VNSaliencyImageObservation
                {
                    var unionOfSalientRegions = CGRect(x: 0, y: 0, width: 0, height: 0)
                    let salientObjects = observation.salientObjects
                    
                    let showAlert = (salientObjects?.isEmpty ?? false)
                    
                    for salientObject in salientObjects ?? [] {
                        unionOfSalientRegions = unionOfSalientRegions.union(salientObject.boundingBox)
                    }
                    
                    if let ciimage = CIImage(image: image)
                    {
                        let salientRect = VNImageRectForNormalizedRect(unionOfSalientRegions,
                                                                       Int(ciimage.extent.size.width),
                                                                       Int(ciimage.extent.size.height))
                        let croppedImage = ciimage.cropped(to: salientRect)
                        let thumbnail =  UIImage(ciImage:croppedImage)
                        DispatchQueue.main.async {
                            
                            if showAlert{
                                let alertController = UIAlertController(title: "Oops!", message: "No highlights were found", preferredStyle: .alert)
                                
                                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { _ in
                                }))
                                self.present(alertController, animated: false, completion: nil)
                            }
                            
                            self.imageView?.image = thumbnail
                        }
                    }
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    
}

