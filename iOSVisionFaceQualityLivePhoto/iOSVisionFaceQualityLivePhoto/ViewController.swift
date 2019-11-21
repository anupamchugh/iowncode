//
//  ViewController.swift
//  iOSVisionFaceQualityLivePhoto
//
//  Created by Anupam Chugh on 21/11/19.
//  Copyright © 2019 iowncode. All rights reserved.
//


import UIKit
import Photos
import MobileCoreServices
import Vision

public struct CustomData {
    var faceQualityValue: String = ""
    var frameImage: UIImage
}


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let workQueue = DispatchQueue(label: "VisionRequest", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    
    var generator: AVAssetImageGenerator!
    var numberOfFrames = 12
    
    var frames:[UIImage] = []{
        didSet{
            DispatchQueue.main.async {
                self.setCustomData()
            }
        }
    }
    
    var data : [CustomData] = []

    var videoUrl : URL? {
        didSet{
            DispatchQueue.global(qos: .background).async {
                guard let videoURL = self.videoUrl else{ return }
                self.imagesFromVideo(url: videoURL)
            }
        }
    }
    
    //MARK:- UI properties
    let marginConstant : CGFloat = 20.0

    let button:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        view.setImage(UIImage(systemName: "photo.fill", withConfiguration: config), for: .normal)
        
        return view
    }()
    
    let visionButton:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        view.setImage(UIImage(systemName: "eye.fill", withConfiguration: config), for: .normal)
        
        return view
    }()
    
    
    fileprivate let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(CustomCell.self, forCellWithReuseIdentifier: "cell")
        cv.backgroundColor = .clear
        return cv
    }()
    
    var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupImageView()
        setupImagePickerBtn()
        setupVisionButton()
        setupCollectionView()
    }
    
    
    func setupCollectionView(){
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 90).isActive = true
    }
    
    func setupImageView(){
        imageView = UIImageView(frame: .zero)
        imageView?.contentMode = .scaleAspectFit
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView!)
        
        
        NSLayoutConstraint.activate([
            imageView!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: marginConstant*2),
            imageView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -marginConstant*2),
            imageView!.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: marginConstant*2),
            imageView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -marginConstant*2),
        ])
    }
    
    func setupImagePickerBtn(){
        self.view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 150),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -marginConstant),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -marginConstant/2),
            button.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        button.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
    }
    
    func setupVisionButton(){
        self.view.addSubview(visionButton)
        
        NSLayoutConstraint.activate([
            visionButton.heightAnchor.constraint(equalToConstant: 150),
            visionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: marginConstant),
            visionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -marginConstant/2),
            visionButton.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        visionButton.addTarget(self, action: #selector(startVisionRequest(sender:)), for: .touchUpInside)
    }
    
    func setCustomData(){
        
        data = []
        for frame in frames{
            let customData = CustomData(frameImage: frame)
            data.append(customData)
        }
        collectionView.reloadData()
    }
    
    
    @objc func startVisionRequest(sender: UIButton){
                
        var bestFrameIndex = -1
        var bestThreshold : Float = 0.0

        workQueue.async {
            
            for i in 0..<self.data.count
            {
                guard let cgImage = self.data[i].frameImage.cgImage else {return}
                let request = VNDetectFaceCaptureQualityRequest()
                
                
                let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                do{
                    try requestHandler.perform([request])
                    if let faceObservation = request.results?.first as? VNFaceObservation{
                        if let faceCaptureQuality = faceObservation.faceCaptureQuality{
                            self.data[i].faceQualityValue = "\(faceCaptureQuality)"
                            if faceCaptureQuality > bestThreshold{
                                bestThreshold = faceCaptureQuality
                                bestFrameIndex = i
                            }
                        }
                    }
                    else{
                        self.data[i].faceQualityValue = "0.00"
                    }

                }catch(let error){
                    print(error.localizedDescription)
                }
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                if bestFrameIndex != -1{
                    self.imageView?.image = self.data[bestFrameIndex].frameImage
                }
            }
        }
    }
    
    @objc func onButtonClick(sender: UIButton){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage, kUTTypeLivePhoto] as [String]
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.livePhoto] as? PHLivePhoto {
                self.processLivePhoto(livePhoto: image)
            }
        }
    }
    
    func processLivePhoto(livePhoto: PHLivePhoto)
    {
        let livePhotoResources = PHAssetResource.assetResources(for: livePhoto)
        guard let photoDir = generateFolderForLivePhotoResources() else{ return }
        for resource in livePhotoResources {
            
            if resource.type == PHAssetResourceType.pairedVideo {
                saveAssetResource(resource: resource, inDirectory: photoDir, buffer: nil, maybeError: nil)
            }
        }
    }
    
    func saveAssetResource(
        resource: PHAssetResource,
        inDirectory: NSURL,
        buffer: NSMutableData?, maybeError: Error?
    ) -> Void {
        guard maybeError == nil else {
            return
        }
        
        let maybeExt = UTTypeCopyPreferredTagWithClass(
            resource.uniformTypeIdentifier as CFString,
            kUTTagClassFilenameExtension
            )?.takeRetainedValue()
        
        guard let ext = maybeExt else {
            return
        }
        
        guard var fileUrl = inDirectory.appendingPathComponent(NSUUID().uuidString) else {
            print("file url error")
            return
        }
        
        fileUrl = fileUrl.appendingPathExtension(ext as String)
        
        if let buffer = buffer, buffer.write(to: fileUrl, atomically: true) {
            self.videoUrl = fileUrl
        } else {
            PHAssetResourceManager.default().writeData(for: resource, toFile: fileUrl, options: nil) { (error) in
                self.videoUrl = fileUrl
            }
        }
    }
    
    func generateFolderForLivePhotoResources() -> NSURL? {
        let photoDir = NSURL(
            fileURLWithPath: NSTemporaryDirectory(),
            isDirectory: true
        ).appendingPathComponent(NSUUID().uuidString)
        
        let fileManager = FileManager()
        let success : ()? = try? fileManager.createDirectory(
            at: photoDir!,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        return success != nil ? photoDir! as NSURL : nil
    }

    func imagesFromVideo(url: URL) {
        let asset = AVURLAsset(url: url)
        
        generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.apertureMode = .encodedPixels
        let duration:Float64 = CMTimeGetSeconds(asset.duration)
        
        let frameInterval = duration/Double(numberOfFrames)
        
        var nsValues : [NSValue] = []
        
        for index in stride(from: 0, through: duration, by: frameInterval) {
            let cmTime  = CMTime(seconds: Double(index), preferredTimescale: 60)
            let nsValue = NSValue(time: cmTime)
            nsValues.append(nsValue)
        }
        
        self.getFrame(nsValues: nsValues)
    }
    
    private func getFrame(nsValues:[NSValue]) {
        
        var images : [UIImage] = []
        generator.generateCGImagesAsynchronously(forTimes: nsValues) { (time, cgImage, time2, result, error) in
            if let cgImage = cgImage{
                images.append(UIImage(cgImage: cgImage))
            }
            if images.count == nsValues.count{
                self.frames = images
            }
        }
    }
}

//MARK:- CollectionViewDelegate methods.
extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 75)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("data count \(data.count)")
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        cell.data = self.data[indexPath.item]
        return cell
    }
}
