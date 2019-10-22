//
//  ViewController.swift
//  iPadOSMultiWindowExample
//
//  Created by Anupam Chugh on 22/10/19.
//  Copyright © 2019 Anupam Chugh. All rights reserved.
//

import UIKit

let VCActivityType = "VCKey"


enum Filters : String, CaseIterable {
case process = "CIPhotoEffectProcess"
case noir = "CIPhotoEffectNoir"
case chrome = "CIPhotoEffectChrome"
case transfer =  "CIPhotoEffectTransfer"
case clear =  "clear"
}


class ViewController: UIViewController {

    var photo: UIImageView?
    var currentImage: UIImage?
    var navigationBar : UINavigationBar?
    
    var stackView: UIStackView?
    
    var marginConstant : CGFloat = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setNavigationBar()
        setupStackView()
        setupImageView()
        
        photo?.image = UIImage(named: "spiderman")
        currentImage = photo?.image
        photo?.contentMode = .scaleAspectFit
        
        photo?.isUserInteractionEnabled = true
        photo?.addInteraction(UIDragInteraction(delegate: self))
        
    }
    
    func setupStackView()
    {

        stackView = UIStackView()
        stackView?.axis = .horizontal
        stackView?.distribution = .fillEqually
        stackView?.backgroundColor = .blue

        for filter in Filters.allCases{
            let button = UIButton(type: .roundedRect)
            button.setTitle(filter.rawValue.replacingOccurrences(of: "CIPhotoEffect", with: ""), for: .normal)
            stackView?.addArrangedSubview(button)
            
            button.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
            
        }

        view.addSubview(stackView!)
        stackView?.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [stackView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -marginConstant/2),
             stackView!.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             stackView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
             stackView!.heightAnchor.constraint(equalToConstant: marginConstant)
            ]
        )
    }
    
    @objc func onButtonClick(sender:UIButton){
        photo?.image = currentImage
        let value = sender.titleLabel?.text ?? ""
        
        for filter in Filters.allCases{

            if filter.rawValue.contains(value){
                if value != "clear"{
                    photo?.image = photo?.image?.addFilter(filter: filter)
                }
            }
        }
        
    }
    
    func setupImageView()
    {
        photo = UIImageView(frame: .zero)
        photo?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photo!)
        
        
        NSLayoutConstraint.activate([
            photo!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: marginConstant),
            photo!.bottomAnchor.constraint(equalTo: self.stackView!.topAnchor, constant: -marginConstant),
            photo!.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: marginConstant),
            photo!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -marginConstant),
        ])
    }
    
    
    func setNavigationBar()
    {
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addScreen))

        navigationItem.title = "Multi Window Part 1"
        navigationItem.rightBarButtonItems = [add]
        navigationItem.leftBarButtonItem = nil
        
    }
    
    @objc func addScreen() {
        let activity = NSUserActivity(activityType: VCActivityType)
       UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil, errorHandler: nil)
    }
    
    
}

extension ViewController : UIDragInteractionDelegate{
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        if let imageView = interaction.view as? UIImageView {
            guard let image = imageView.image else { return [] }
            let provider = NSItemProvider(object: image)
            
            
            let userActivity = NSUserActivity(activityType: VCActivityType)
            provider.registerObject(userActivity, visibility: .all)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        }
        
        return []
    }
}




extension UIImage {
    func addFilter(filter : Filters) -> UIImage {
        let filter = CIFilter(name: filter.rawValue)
        let ciInput = CIImage(image: self)
        filter?.setValue(ciInput, forKey: "inputImage")
        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
        return UIImage(cgImage: cgImage!)
    }
}
