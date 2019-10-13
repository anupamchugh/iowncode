//
//  ViewController.swift
//  iOSPencilKitCoreMLMNIST
//
//  Created by Anupam Chugh on 14/10/19.
//  Copyright © 2019 Anupam Chugh. All rights reserved.
//

import UIKit
import PencilKit
import CoreML

class ViewController: UIViewController {
    
    let canvasView = PKCanvasView(frame: .zero)
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        
        canvasView.backgroundColor = .black
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func setNavigationBar() {
        if let navItem = navigationBar.topItem{
            
            let detectItem = UIBarButtonItem(title: "Detect", style: .done, target: self, action: #selector(detectImage))
            let clearItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clear))

            navItem.rightBarButtonItems = [clearItem,detectItem]
            navItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
            
        }
    }

    @objc func detectImage() {
        var image = canvasView.drawing.image(from: canvasView.drawing.bounds, scale: 10.0)
        if let newImage = UIImage(color: .black, size: CGSize(width: view.frame.width, height: view.frame.height)){

            if let overlayedImage = newImage.image(byDrawingImage: image, inRect: CGRect(x: view.center.x, y: view.center.y, width: view.frame.width, height: view.frame.height)){
            
                image = overlayedImage
            }
        }
        
        processImage(image: image)
        
    }
    
    private let trainedImageSize = CGSize(width: 28, height: 28)

    func processImage(image: UIImage){
        if let resizedImage = image.resize(newSize: trainedImageSize), let pixelBuffer = resizedImage.toCVPixelBuffer(){

        guard let result = try? MNIST().prediction(image: pixelBuffer) else {
            print("error in image...")
            return
        }
            
            
            navigationBar.topItem?.leftBarButtonItem?.title = "Predicted: \(result.classLabel)"
            print("result is \(result.classLabel)")

        }
    }
    
    
    @objc func clear() {
        canvasView.drawing = PKDrawing()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard
            let window = view.window,
            let toolPicker = PKToolPicker.shared(for: window) else { return }

        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
}


extension CGRect {
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}

extension UIImage {
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    
    
    func image(byDrawingImage image: UIImage, inRect rect: CGRect) -> UIImage! {
        UIGraphicsBeginImageContext(size)

        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func resize(newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    func toCVPixelBuffer() -> CVPixelBuffer? {
       var pixelBuffer: CVPixelBuffer? = nil

        
        let attr = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
        kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
       let width = Int(self.size.width)
       let height = Int(self.size.height)

       CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_OneComponent8, attr, &pixelBuffer)
       CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue:0))

       let colorspace = CGColorSpaceCreateDeviceGray()
       let bitmapContext = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer!), width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: colorspace, bitmapInfo: 0)!

       guard let cg = self.cgImage else {
           return nil
       }

       bitmapContext.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))

       return pixelBuffer
    }
    
    
}

