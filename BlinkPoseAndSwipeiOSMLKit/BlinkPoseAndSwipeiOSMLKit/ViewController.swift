//
//  ViewController.swift
//  BlinkPoseAndSwipeiOSMLKit
//
//  Created by Anupam Chugh on 25/01/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import UIKit


protocol BlinkSwiperDelegate {
    func leftBlink()
    func rightBlink()
}

class ViewController: UIViewController , BlinkSwiperDelegate{
    
    func leftBlink() {
        if let firstView = stackContainer.subviews.last as? TinderCardView{
                firstView.leftSwipeClicked(stackContainerView: stackContainer)
        }
    }
    
    func rightBlink() {
        if let firstView = stackContainer.subviews.last as? TinderCardView{
                firstView.rightSwipeClicked(stackContainerView: stackContainer)
        }
    }
    
    
    //MARK: - Properties
    var modelData = [DataModel(bgColor: .systemYellow),
                         DataModel(bgColor: .systemBlue),
                         DataModel(bgColor: .systemRed),
                         DataModel(bgColor: .systemTeal),
                         DataModel(bgColor: .systemOrange),
                         DataModel(bgColor: .brown)]
    var stackContainer : StackContainerView!
    
    
    var buttonStackView: UIStackView!
    var leftButton : UIButton!, rightButton : UIButton!
    
    
    var cameraView : CameraView!
    
    //MARK: - Init
    
    override func loadView() {
        view = UIView()
        
        //view.backgroundColor = .white
        
        stackContainer = StackContainerView()
        view.addSubview(stackContainer)
        configureStackContainer()
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
        
        addButtons()
        configureNavigationBarButtonItem()
        addCameraView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BlinkPoseSwipe"
        stackContainer.dataSource = self
    }
    
    
    func addCameraView()
    {
        
        cameraView = CameraView()
        cameraView.blinkDelegate = self
        view.addSubview(cameraView)
        
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        cameraView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cameraView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        cameraView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    //MARK: - Configurations
    func configureStackContainer() {
        stackContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60).isActive = true
        stackContainer.widthAnchor.constraint(equalToConstant: 300).isActive = true
        stackContainer.heightAnchor.constraint(equalToConstant: 400).isActive = true
    }
    
    func addButtons()
    {
        leftButton = UIButton(type: .custom)
        leftButton.setImage(UIImage(named: "Nope"), for: .normal)
        
        leftButton.addTarget(self, action: #selector(onButtonPress(sender:)), for: .touchUpInside)
        leftButton.tag = 0
        
        rightButton = UIButton(type: .custom)
        rightButton.setImage(UIImage(named: "Like"), for: .normal)
        
        rightButton.addTarget(self, action: #selector(onButtonPress(sender:)), for: .touchUpInside)
        rightButton.tag = 1
        
        buttonStackView = UIStackView(arrangedSubviews: [leftButton, rightButton])
        buttonStackView.distribution = .fillEqually
        self.view.addSubview(buttonStackView)
        
        buttonStackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        buttonStackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        buttonStackView.topAnchor.constraint(equalTo: stackContainer.bottomAnchor, constant: 30).isActive = true
        buttonStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
    }

    @objc func onButtonPress(sender: UIButton){
        
        
        UIView.animate(withDuration: 2.0,
                                   delay: 0,
                                   usingSpringWithDamping: CGFloat(0.20),
                                   initialSpringVelocity: CGFloat(6.0),
                                   options: UIView.AnimationOptions.allowUserInteraction,
                                   animations: {
                                    sender.transform = CGAffineTransform.identity
            },
                                   completion: { Void in()  }
        )
        
        if let firstView = stackContainer.subviews.last as? TinderCardView{
            if sender.tag == 0{
                firstView.leftSwipeClicked(stackContainerView: stackContainer)
            }
            else{
                firstView.rightSwipeClicked(stackContainerView: stackContainer)
            }
        }
    }
    
    func configureNavigationBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetTapped))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Blink Start", style: .plain, target: self, action: #selector(startBlink))
    }
    
    //MARK: - Handlers
    @objc func resetTapped() {
        stackContainer.reloadData()
    }
    
    @objc func startBlink() {
        cameraView.beginSession()
    }
    
}

extension ViewController : SwipeCardsDataSource {
    
    func numberOfCardsToShow() -> Int {
        return modelData.count
    }
    
    func card(at index: Int) -> TinderCardView {
        let card = TinderCardView()
        card.dataSource = modelData[index]
        return card
    }
    
    func emptyView() -> UIView? {
        return nil
    }
}



