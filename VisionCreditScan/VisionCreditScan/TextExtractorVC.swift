//
//  TextExtractorVC.swift
//  VisionCreditScan
//
//  Created by Anupam Chugh on 27/01/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import UIKit
import Vision

class TextExtractorVC: UIViewController {
    
    let queue = OperationQueue()
    
    let overlay = UIView()
    var lastPoint = CGPoint.zero
    
    var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
    private let textRecognitionWorkQueue = DispatchQueue(label: "MyVisionScannerQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    var scannedImage : UIImage?
    
    private var maskLayer = [CAShapeLayer]()
    
    lazy var imageView : UIImageView = {
       
        let b = UIImageView()
        b.contentMode = .scaleAspectFit
        
        view.addSubview(b)
        
        b.translatesAutoresizingMaskIntoConstraints = false
        b.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        b.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        b.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        b.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        return b
        
    }()
    
    lazy var button : UIButton = {
       
        let b = UIButton(type: .system)
        b.setTitle("Extract Digits", for: .normal)
        view.addSubview(b)
        
        b.translatesAutoresizingMaskIntoConstraints = false
        b.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        b.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        b.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        b.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return b
        
    }()
    
    lazy var digitsLabel : UILabel = {
       
        let b = UILabel(frame: .zero)
        
        view.addSubview(b)
        
        b.translatesAutoresizingMaskIntoConstraints = false
        b.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        b.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        b.bottomAnchor.constraint(equalTo: self.button.topAnchor, constant: -20).isActive = true
        b.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        return b
        
    }()

    @objc func doExtraction(sender: UIButton!){
        processImage(snapshot(in: imageView, rect: overlay.frame))
    }

    func snapshot(in imageView: UIImageView, rect: CGRect) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect).image { _ in
    
            clearOverlay()
            imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupVision()
        self.view.backgroundColor = .black
                
        imageView.image = scannedImage
    
        overlay.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        overlay.isHidden = true

        imageView.addSubview(overlay)
        imageView.bringSubviewToFront(overlay)
        
        button.addTarget(self, action: #selector(doExtraction(sender:)), for: .touchUpInside)
        
    }
    
    private func setupVision() {
        textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var detectedText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }

    
                detectedText += topCandidate.string
                detectedText += "\n"
            }

            DispatchQueue.main.async{
                self.digitsLabel.text = detectedText
            }
        }

        textRecognitionRequest.recognitionLevel = .accurate
    }

    private func processImage(_ image: UIImage) {
        recognizeTextInImage(image)
    }
    
    private func recognizeTextInImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        textRecognitionWorkQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([self.textRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
    
    func clearOverlay(){
        overlay.isHidden = false
        overlay.frame = CGRect.zero
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        clearOverlay()
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
    }

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawSelectionArea(fromPoint: lastPoint, toPoint: currentPoint)
        }
    }

    func drawSelectionArea(fromPoint: CGPoint, toPoint: CGPoint) {
        
            let rect = CGRect(x: min(fromPoint.x, toPoint.x), y: min(fromPoint.y, toPoint.y), width: abs(fromPoint.x - toPoint.x), height: abs(fromPoint.y - toPoint.y))
            overlay.frame = rect
    }
}
