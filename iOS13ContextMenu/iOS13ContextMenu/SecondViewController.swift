//
//  SecondViewController.swift
//  iOS13ContextMenu
//
//  Created by Anupam Chugh on 08/10/19.
//  Copyright © 2019 Anupam Chugh. All rights reserved.
//

import UIKit

class SecondViewController : UIViewController{
    
    var imageView : UIImageView!
    var index : Int?
    
    override func loadView() {
        super.loadView()

        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        imageView.contentMode = .scaleToFill
        
        self.imageView = imageView
    }
    
    override func viewDidLoad() {
        
        if ((index ?? 0)%2 == 0)
        {
            self.imageView.image = UIImage(named: "car")?.addFilter(filter: "CIPhotoEffectProcess")
            self.view.backgroundColor = .black
        }else{
            self.imageView.image = UIImage(named: "bike")?.addFilter(filter: "CIPhotoEffectNoir")
            self.view.backgroundColor = .white
        }
        
    }
    
    init(index: Int?) {
        super.init(nibName: nil, bundle: nil)
        self.index = index
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIImage {
func addFilter(filter : String) -> UIImage {
let filter = CIFilter(name: filter)
// convert UIImage to CIImage and set as input
let ciInput = CIImage(image: self)
filter?.setValue(ciInput, forKey: "inputImage")
let ciOutput = filter?.outputImage
let ciContext = CIContext()
let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
return UIImage(cgImage: cgImage!)
}
}
