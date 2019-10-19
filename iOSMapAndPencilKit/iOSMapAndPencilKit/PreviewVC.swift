//
//  PreviewVC.swift
//  iOSMapAndPencilKit
//
//  Created by Anupam Chugh on 19/10/19.
//  Copyright © 2019 Anupam Chugh. All rights reserved.
//

import UIKit

class PreviewVC: UIViewController {

    var imageView: UIImageView!
    var myImage : UIImage?
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.myImage = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = myImage
        self.view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]) 
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
}
