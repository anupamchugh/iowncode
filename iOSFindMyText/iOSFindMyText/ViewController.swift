//
//  ViewController.swift
//  iOSFindMyText
//
//  Created by Anupam Chugh on 14/08/19.
//  Copyright © 2019 Anupam Chugh. All rights reserved.
//

import UIKit
import Vision
import CoreML


public var observationStringLookup : [VNTextObservation : String] = [:]

class ViewController: UIViewController {

    var model: VNCoreMLModel!
    var textMetadata = [Int: [Int: String]]()
    var currentImage : UIImage!
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadModel()
    }
    
    private func loadModel() {
        model = try? VNCoreMLModel(for: Alphanum_28x28().model)
    }

    @IBAction func takeImageClicked(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Camera", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Photos Library", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
        
        
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        guard let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Error!")
        }
        observationStringLookup.removeAll()
        textMetadata.removeAll()
        imageView.image = uiImage
        createVisionRequest(image: uiImage)
    }
    
    private func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
}

