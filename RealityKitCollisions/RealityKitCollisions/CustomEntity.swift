//
//  CustomBox.swift
//  RealityKitCollisionsAndPhysics
//
//  Created by Anupam Chugh on 14/01/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import SwiftUI
import RealityKit
import Combine

class CustomEntityA: Entity, HasModel, HasAnchoring, HasCollision {
    
    var collisionSubs: [Cancellable] = []
    
    required init(color: UIColor) {
        super.init()
        
        self.components[CollisionComponent] = CollisionComponent(
            shapes: [.generateBox(size: [0.05,0.05,0.05])],
            mode: .trigger,
            filter: CollisionFilter(group: CollisionGroup(rawValue: 1), mask: CollisionGroup(rawValue: 1))
        )
        
        self.components[ModelComponent] = ModelComponent(
            mesh: .generateBox(size: [0.05,0.05,0.05]),
            materials: [SimpleMaterial(
                color: color,
                isMetallic: false)
            ]
        )
    }
    
    convenience init(color: UIColor, position: SIMD3<Float>) {
        self.init(color: color)
        self.position = position
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

class CustomEntityB: Entity, HasModel, HasAnchoring, HasCollision {
    
    var collisionSubs: [Cancellable] = []
    
    required init(color: UIColor) {
        super.init()
        
        self.components[CollisionComponent] = CollisionComponent(
            shapes: [.generateSphere(radius: 0.03)],
            mode: .trigger,
            filter: CollisionFilter(group: CollisionGroup(rawValue: 2), mask: CollisionGroup(rawValue: 2))
        )
        
        self.components[ModelComponent] = ModelComponent(
            mesh: .generateSphere(radius: 0.03),
            materials: [SimpleMaterial(
                color: color,
                isMetallic: false)
            ]
        )
    }
    
    convenience init(color: UIColor, position: SIMD3<Float>) {
        self.init(color: color)
        self.position = position
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}


extension CustomEntityA {
    func addCollisions(scene: Scene? = nil) {
        
        
    var myScene = scene
        
    if scene == nil{
        guard let _ = self.scene else {
          return
        }
        
        myScene = self.scene
    }
        
    collisionSubs.append(myScene!.subscribe(to: CollisionEvents.Began.self, on: self) { event in
        guard let boxA = event.entityA as? CustomEntityA else {
        return
      }

    boxA.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
    
    })
    collisionSubs.append(myScene!.subscribe(to: CollisionEvents.Ended.self, on: self) { event in
        guard let boxA = event.entityA as? CustomEntityA else {
        return
      }
      boxA.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: false)]
    })
  }
}

extension CustomEntityB {
  func addCollisions(scene: Scene? = nil) {
    var myScene = scene
    if scene == nil{
        guard let _ = self.scene else {
          return
        }
        
        myScene = self.scene
    }
    
    collisionSubs.append(myScene!.subscribe(to: CollisionEvents.Began.self, on: self) { event in
        guard let sphere = event.entityA as? CustomEntityB else {
        return
      }

    sphere.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
    
    })
    collisionSubs.append(myScene!.subscribe(to: CollisionEvents.Ended.self, on: self) { event in
        guard let sphere = event.entityA as? CustomEntityB else {
        return
      }
      sphere.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: false)]
    })
  }
}
