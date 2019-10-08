//
//  ViewController.swift
//  iOSUIImageToPDF
//
//  Created by Anupam Chugh on 09/10/19.
//  Copyright © 2019 Anupam Chugh. All rights reserved.
//

import UIKit
import VisionKit
import PDFKit

class ViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var btnPdf: UIButton!
    
    var pdfView : PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnPdf.isHidden = true
        addPDFView()
    }
    
    func addPDFView()
    {
        pdfView = PDFView()

        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)

        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: btnScan.bottomAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: btnPdf.topAnchor).isActive = true
    }

    @IBAction func btnViewPDF(_ sender: Any) {
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let docURL = documentDirectory.appendingPathComponent("Scanned-Docs.pdf")
        
        
        if fileManager.fileExists(atPath: docURL.path){
            pdfView.document = PDFDocument(url: docURL)
        }
        else{
            print("file does not exist..")
        }
        
    }
    
    @IBAction func btnScanDocument(_ sender: Any) {
        
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = self
        present(scannerViewController, animated: true)
    }
    
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        DispatchQueue.main.async {

            let pdfDocument = PDFDocument()

            for i in 0 ..< scan.pageCount {
                if let image = scan.imageOfPage(at: i).resize(toWidth: 250){
                    print("image size is \(image.size.width), \(image.size.height)")
                    // Create a PDF page instance from your image
                    let pdfPage = PDFPage(image: image)
                    // Insert the PDF page into your document
                    pdfDocument.insert(pdfPage!, at: i)
                }
            }
            
            
            // Get the raw data of your PDF document
            let data = pdfDocument.dataRepresentation()
            
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let docURL = documentDirectory.appendingPathComponent("Scanned-Docs.pdf")
            do{
            try data?.write(to: docURL)
            }catch(let error)
            {
                print("error is \(error.localizedDescription)")
            }
            
        }
        controller.dismiss(animated: true)
        btnPdf.isHidden = false
        
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print(error)
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
    
}

extension UIImage{
    func resize(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}

