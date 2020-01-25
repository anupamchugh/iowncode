//
//  TinderCardView.swift
//  BlinkPoseAndSwipeiOSMLKit
//
//  Created by Anupam Chugh on 25/01/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import UIKit

class TinderCardView : UIView {
   
    //MARK: - Properties
    var swipeView : UIView!
    var delegate : SwipeCardsDelegate?

    var dataSource : DataModel? {
        didSet {
            swipeView.backgroundColor = dataSource?.bgColor
        }
    }
    
    //MARK: - Init
     override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureSwipeView()
        addPanGestureOnCards()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configuration
    
    func configureSwipeView() {
        swipeView = UIView()
        swipeView.layer.cornerRadius = 15
        swipeView.clipsToBounds = true
        addSubview(swipeView)
        
        swipeView.translatesAutoresizingMaskIntoConstraints = false
        swipeView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        swipeView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        swipeView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        swipeView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }

    
    
    func addPanGestureOnCards() {
        self.isUserInteractionEnabled = true
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
    }
    
    func leftSwipeClicked(stackContainerView: StackContainerView)
    {
        let finishPoint = CGPoint(x: center.x - frame.size.width * 2, y: center.y)
        UIView.animate(withDuration: 0.4, animations: {() -> Void in

            self.center = finishPoint
            self.transform = CGAffineTransform(rotationAngle: -1)

        }, completion: {(_ complete: Bool) -> Void in
            stackContainerView.swipeDidEnd(on: self)
            self.removeFromSuperview()

        })
    }

    func rightSwipeClicked(stackContainerView: StackContainerView)
    {
        let finishPoint = CGPoint(x: center.x + frame.size.width * 2, y: center.y)
        UIView.animate(withDuration: 0.4, animations: {() -> Void in

            self.center = finishPoint
            self.transform = CGAffineTransform(rotationAngle: 1)

        }, completion: {(_ complete: Bool) -> Void in
            stackContainerView.swipeDidEnd(on: self)
            self.removeFromSuperview()

        })
    }
    
    //MARK: - Handlers
    @objc func handlePanGesture(sender: UIPanGestureRecognizer){
        let card = sender.view as! TinderCardView
        let point = sender.translation(in: self)
        let centerOfParentContainer = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        card.center = CGPoint(x: centerOfParentContainer.x + point.x, y: centerOfParentContainer.y + point.y)
        
        switch sender.state {
        case .ended:
            if (card.center.x) > 400 {
                delegate?.swipeDidEnd(on: card)
                UIView.animate(withDuration: 0.2) {
                    card.center = CGPoint(x: centerOfParentContainer.x + point.x + 200, y: centerOfParentContainer.y + point.y + 75)
                    card.alpha = 0
                    self.layoutIfNeeded()
                }
                return
            }else if card.center.x < -65 {
                delegate?.swipeDidEnd(on: card)
                UIView.animate(withDuration: 0.2) {
                    card.center = CGPoint(x: centerOfParentContainer.x + point.x - 200, y: centerOfParentContainer.y + point.y + 75)
                    card.alpha = 0
                    self.layoutIfNeeded()
                }
                return
            }
            UIView.animate(withDuration: 0.2) {
                card.transform = .identity
                card.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
                self.layoutIfNeeded()
            }
        case .changed:
            let rotation = tan(point.x / (self.frame.width * 2.0))
            card.transform = CGAffineTransform(rotationAngle: rotation)
            
        default:
            break
        }
    }
}
