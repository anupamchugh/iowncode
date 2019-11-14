//
//  ViewController.swift
//  iOS13QuickLook
//
//  Created by Anupam Chugh on 14/11/19.
//  Copyright © 2019 iowncode. All rights reserved.
//

import UIKit
import QuickLook

class ViewController: UIViewController {
    
    let button:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        view.setImage(UIImage(systemName: "doc.text", withConfiguration: config), for: .normal)
        
        return view
    }()
    
    var items : [String] = ["sampleVideo.mp4", "samplePDF.pdf", "sampleImage.png"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton()
    }
    
    @objc func onButtonClick(sender: UIButton){
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        previewController.setEditing(true, animated: true)
        self.present(previewController, animated: true, completion: nil)
    }
    
    func addButton(){
        self.view.addSubview(button)
        
        button.addTarget(self, action: #selector(onButtonClick(sender:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate(
            [
                button.heightAnchor.constraint(equalToConstant: 150),
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                button.widthAnchor.constraint(equalToConstant: 150)
            ]
        )
    }
}

extension ViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return items.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {

        let name = self.items[index]
        let file = name.components(separatedBy: ".")
        let path = Bundle.main.path(forResource: file.first!, ofType: file.last!)
        let url = NSURL(fileURLWithPath: path!)
        return url as QLPreviewItem
    }
    
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        
        return .createCopy
    }
    
    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
    }
    
    func previewController(_ controller: QLPreviewController, didSaveEditedCopyOf previewItem: QLPreviewItem, at modifiedContentsURL: URL) {
        
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let currentTimeStamp = String(Int(NSDate().timeIntervalSince1970))
        
        let destinationUrl = documentsDirectoryURL.appendingPathComponent("newFile\(currentTimeStamp).\(modifiedContentsURL.pathExtension)")
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            debugPrint("The file already exists at path")
        }
        else{
            do {
                try FileManager.default.moveItem(at: modifiedContentsURL, to: destinationUrl)
                print("File moved to documents folder")
            } catch let error as NSError {
                print(error.localizedDescription)
                
            }
        }
        
    }
}

