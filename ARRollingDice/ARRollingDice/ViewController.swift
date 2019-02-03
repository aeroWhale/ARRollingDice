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
        
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        // look for the child node inside the rootnode of the diceScene, and add it into the sceneView
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            // Set postion for the dice
            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
            sceneView.scene.rootNode.addChildNode(diceNode)
        }
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
            gridMaterial.diffuse.contents = UIImage(named: "art.scnasserts/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            
            // Add planeNode
            node.addChildNode(planeNode)
        } else {
            return
        }
    }
}
