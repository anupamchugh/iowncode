//
//  ViewController.swift
//  iOSMapAndPencilKit
//
//  Created by Anupam Chugh on 18/10/19.
//  Copyright © 2019 Anupam Chugh. All rights reserved.
//

import UIKit
import MapKit
import PencilKit


class DragOrDraw{
    static var disableDrawing = true
}

class ViewController: UIViewController {
    
    var window: UIWindow?
    var mapView: MKMapView?
    
    let canvasView = PKCanvasView(frame: .zero)
    var navigationBar : UINavigationBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView = MKMapView(frame: CGRect(x: 0, y: 60, width: view.frame.size.width, height: view.frame.size.height - 60))
        self.view.addSubview(self.mapView!)
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.isOpaque = false
        view.addSubview(canvasView)
        
        canvasView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        setNavigationBar()
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
    
    var toggleDrawItem : UIBarButtonItem!
    
    var disableDraw : Bool = false
    
    func setNavigationBar() {

        let previewItem = UIBarButtonItem(title: "Preview", style: .done, target: self, action: #selector(preview))
        
        let clearItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clear))
        toggleDrawItem = UIBarButtonItem(title: "Drag", style: .plain, target: self, action: #selector(dragDrawToggler))

        let navigationItem = UINavigationItem(title: "")
        
        navigationItem.rightBarButtonItems = [clearItem,previewItem]
        navigationItem.leftBarButtonItem = toggleDrawItem
        
        navigationBar = UINavigationBar(frame: .zero)
        navigationBar?.isTranslucent = false
        
        navigationBar!.setItems([navigationItem], animated: false)
        navigationBar!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar!)

        navigationBar!.backgroundColor = .clear

        NSLayoutConstraint.activate([
            navigationBar!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            navigationBar!.heightAnchor.constraint(equalToConstant: 60),
            navigationBar!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func clippedImageForRect(clipRect: CGRect, inView view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(clipRect.size, true, UIScreen.main.scale)
        if let ctx = UIGraphicsGetCurrentContext(){
            ctx.translateBy(x: -clipRect.origin.x, y: -clipRect.origin.y);
            view.layer.render(in: ctx)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return img
        }
        return nil
    }
    
    func showPreviewImage(image: UIImage)
    {
        let alert = UIAlertController(title: "Preview", message: "", preferredStyle: .actionSheet)
        alert.addPreviewImage(image: image)

        alert.addAction(UIAlertAction(title: "Add To Photos", style: .default){
            action in
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        addActionSheetForiPad(actionSheet: alert)
        present(alert,
                    animated: true,
                    completion: nil)
    }
    
    @objc func preview() {
        let bounds = canvasView.drawing.bounds
        if let image = clippedImageForRect(clipRect: bounds, inView: mapView!){
            showPreviewImage(image: image)
        }
    }
    
    @objc func clear() {
        canvasView.drawing = PKDrawing()
    }
    
    @objc func dragDrawToggler() {
        if toggleDrawItem.title ?? "" == "Drag"{
           toggleDrawItem.title = "Draw"
            DragOrDraw.disableDrawing = false
        }
        else{
           toggleDrawItem.title = "Drag"
            DragOrDraw.disableDrawing = true
        }
    }
}


extension PKCanvasView{
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return DragOrDraw.disableDrawing
    }
}

extension UIAlertController {
    func addPreviewImage(image: UIImage) {
        let vc = PreviewVC(image: image)
        setValue(vc, forKey: "contentViewController")
    }
}

extension UIViewController {
  public func addActionSheetForiPad(actionSheet: UIAlertController) {
    if let popoverPresentationController = actionSheet.popoverPresentationController {
      popoverPresentationController.sourceView = self.view
      popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
      popoverPresentationController.permittedArrowDirections = []
    }
  }
}
