//
//  ContentView.swift
//  RealityKitCollisionsAndPhysics
//
//  Created by Anupam Chugh on 13/01/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options: [])
        
        arView.addCoaching()
        arView.setupGestures()
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

extension ARView{
    
    func setupGestures() {

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        guard let touchInView = sender?.location(in: self) else {
            return
        }

        rayCastingMethod(point: touchInView)
    }
    
    func rayCastingMethod(point: CGPoint) {
        
        guard let raycastQuery = self.makeRaycastQuery(from: point,
                                                       allowing: .existingPlaneInfinite,
                                                       alignment: .horizontal) else {
                                                        return
        }
        
        guard let result = self.session.raycast(raycastQuery).first else {return}
        
        let transformation = Transform(matrix: result.worldTransform)
        
        if GlobalVariable.isBox{
            let box = CustomEntityA(color: .yellow)
            self.installGestures(.all, for: box)
            
            box.addCollisions(scene: self.scene)
            box.transform = transformation
            
            let raycastAnchor = AnchorEntity(raycastResult: result)
            raycastAnchor.addChild(box)
            
            self.scene.addAnchor(raycastAnchor)
        }
        else{
            let sphere = CustomEntityB(color: .yellow)
            self.installGestures(.all, for: sphere)

            sphere.addCollisions(scene: self.scene)
            sphere.transform = transformation

            let raycastAnchor = AnchorEntity(raycastResult: result)
            raycastAnchor.addChild(sphere)
            self.scene.addAnchor(raycastAnchor)
        }
        
        GlobalVariable.isBox = !GlobalVariable.isBox
    }
}

extension ARView: ARCoachingOverlayViewDelegate {
    
    func addCoaching() {
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        coachingOverlay.goal = .horizontalPlane
        self.addSubview(coachingOverlay)
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        coachingOverlayView.activatesAutomatically = false
        //Ready to add objects
    }
    
}

struct GlobalVariable {
    static var isBox = true
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

