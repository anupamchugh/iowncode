//
//  CameraView.swift
//  BlinkPoseAndSwipeiOSMLKit
//
//  Created by Anupam Chugh on 25/01/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseMLVision

final class CameraView: UIView {
    
    private lazy var vision = Vision.vision()
    
    var blinkDelegate : BlinkSwiperDelegate?
    var restingFace = true
    
    lazy var options : VisionFaceDetectorOptions = {
        let o = VisionFaceDetectorOptions()
        o.performanceMode = .accurate
        o.classificationMode = .all
        o.isTrackingEnabled = false
        
        return o
    }()
    
    
    private lazy var videoDataOutput: AVCaptureVideoDataOutput = {
        let v = AVCaptureVideoDataOutput()
        v.alwaysDiscardsLateVideoFrames = true
        v.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        v.connection(with: .video)?.isEnabled = true
        return v
    }()
    
    private let videoDataOutputQueue: DispatchQueue = DispatchQueue(label: "VideoDataOutputQueue")
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let l = AVCaptureVideoPreviewLayer(session: session)
        l.videoGravity = .resizeAspect
        return l
    }()
    
    private let captureDevice: AVCaptureDevice? = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    private lazy var session: AVCaptureSession = {
        return AVCaptureSession()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func beginSession() {
        
        guard let captureDevice = captureDevice else { return }
        guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        layer.masksToBounds = true
        layer.addSublayer(previewLayer)
        previewLayer.frame = bounds
        session.startRunning()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}

extension CameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer from sample buffer.")
            return
        }
        let visionImage = VisionImage(buffer: sampleBuffer)
        let metadata = VisionImageMetadata()
        let visionOrientation = visionImageOrientation(from: imageOrientation())
        metadata.orientation = visionOrientation
        visionImage.metadata = metadata
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        
        DispatchQueue.global().async {
            self.detectFacesOnDevice(in: visionImage, width: imageWidth, height: imageHeight)
        }
        
        
    }
    
    public func visionImageOrientation(
        from imageOrientation: UIImage.Orientation
    ) -> VisionDetectorImageOrientation {
        switch imageOrientation {
        case .up:
            return .topLeft
        case .down:
            return .bottomRight
        case .left:
            return .leftBottom
        case .right:
            return .rightTop
        case .upMirrored:
            return .topRight
        case .downMirrored:
            return .bottomLeft
        case .leftMirrored:
            return .leftTop
        case .rightMirrored:
            return .rightBottom
        @unknown default:
            fatalError()
        }
    }
    
    public  func imageOrientation(
        fromDevicePosition devicePosition: AVCaptureDevice.Position = .front
    ) -> UIImage.Orientation {
        var deviceOrientation = UIDevice.current.orientation
        if deviceOrientation == .faceDown || deviceOrientation == .faceUp ||
            deviceOrientation == .unknown {
            deviceOrientation = currentUIOrientation()
        }
        switch deviceOrientation {
        case .portrait:
            return devicePosition == .front ? .leftMirrored : .right
        case .landscapeLeft:
            return devicePosition == .front ? .downMirrored : .up
        case .portraitUpsideDown:
            return devicePosition == .front ? .rightMirrored : .left
        case .landscapeRight:
            return devicePosition == .front ? .upMirrored : .down
        case .faceDown, .faceUp, .unknown:
            return .up
        @unknown default:
            fatalError()
        }
    }
    
    private func currentUIOrientation() -> UIDeviceOrientation {
        let deviceOrientation = { () -> UIDeviceOrientation in
            switch UIApplication.shared.statusBarOrientation {
            case .landscapeLeft:
                return .landscapeRight
            case .landscapeRight:
                return .landscapeLeft
            case .portraitUpsideDown:
                return .portraitUpsideDown
            case .portrait, .unknown:
                return .portrait
            @unknown default:
                fatalError()
            }
        }
        guard Thread.isMainThread else {
            var currentOrientation: UIDeviceOrientation = .portrait
            DispatchQueue.main.sync {
                currentOrientation = deviceOrientation()
            }
            return currentOrientation
        }
        return deviceOrientation()
    }
    
    private func detectFacesOnDevice(in image: VisionImage, width: CGFloat, height: CGFloat) {
        
        let faceDetector = vision.faceDetector(options: options)
        
        faceDetector.process(image, completion: { features, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard error == nil, let features = features, !features.isEmpty else {
                //print("On-Device face detector returned no results.")
                return
            }
            
            if let face = features.first{
                
                let leftEyeOpenProbability = face.leftEyeOpenProbability
                let rightEyeOpenProbability = face.rightEyeOpenProbability
                
                print("head euler angle is \(face.headEulerAngleZ)")
                
                if leftEyeOpenProbability > 0.95 && rightEyeOpenProbability < 0.1
                {
                    if self.restingFace{
                        self.restingFace = false
                        self.blinkDelegate?.rightBlink()
                    }
                }
                else if rightEyeOpenProbability > 0.95 && leftEyeOpenProbability < 0.1
                {
                    if self.restingFace{
                        self.restingFace = false
                        self.blinkDelegate?.leftBlink()
                        
                    }
                }
                else{
                    self.restingFace = true
                }
            }
        })
    }
    
}
