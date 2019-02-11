//
//  ViewController.swift
//  ARRollingDice
//
//  Created by Dylan on 29/1/19.
//  Copyright © 2019 Dylan. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show the points of detection
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's 	session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // Detecting touches on screen and translate them into locations
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // Get the 2D location of the screen touch
            let touchLocation = touch.location(in: sceneView)
            
            // Convert 2D location on screen into 3D location in scen view
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            // Check if the touch is on the the plane
            if !results.isEmpty {
                print("Touched the plane")
            } else {
                print("Didn't touch the plane, it might be somewhere else")
            }
            if let hitResult = results.first {
                print(hitResult)
                
                // Add a dice to the touched point
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                // look for the child node inside the rootnode of the diceScene, and add it into the sceneView
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    // Set postion for the dice, based on the hit result of touch
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        // Add radius of the dice's bounding sphere, so that it can be displayed above the plane.
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResult.worldTransform.columns.3.z
                    )
                    sceneView.scene.rootNode.addChildNode(diceNode)
                }
            }
        }
    }
    
    // Call this method when detected a horizontal surface
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            
            // Create a plane, with converted dimensions of anchor as its width and height
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            // Create a node for the plane, using the center of anchor
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            // Tranform plane from vertical into horizontal
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            // Add a grid to the detected plane
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            
            // Add planeNode
            node.addChildNode(planeNode)
        } else {
            return
        }
    }
}
