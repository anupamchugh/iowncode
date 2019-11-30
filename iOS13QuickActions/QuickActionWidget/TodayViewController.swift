//
//  TodayViewController.swift
//  QuickActionWidget
//
//  Created by Anupam Chugh on 30/11/19.
//  Copyright © 2019 iowncode. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onButtonTap(_ sender: Any) {
        self.extensionContext?.open(URL(string: "iOS13QuickActions://")!)
    }
    
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
}
