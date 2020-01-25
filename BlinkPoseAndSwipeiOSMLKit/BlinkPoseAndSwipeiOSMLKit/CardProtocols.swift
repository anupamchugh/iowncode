//
//  CardProtocols.swift
//  BlinkPoseAndSwipeiOSMLKit
//
//  Created by Anupam Chugh on 25/01/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import UIKit

protocol SwipeCardsDataSource {
    func numberOfCardsToShow() -> Int
    func card(at index: Int) -> TinderCardView
    func emptyView() -> UIView?
    
}

protocol SwipeCardsDelegate {
    func swipeDidEnd(on view: TinderCardView)
}
