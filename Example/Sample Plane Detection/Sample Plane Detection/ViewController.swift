//
//  ViewController.swift
//  Sample Plane Detection
//
//  Created by Sunny Singh on 7/14/19.
//  Copyright © 2019 Epoch. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ShapeDetection
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()

    @IBOutlet weak var showPlane: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        // Create a new scene
        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneView.addGestureRecognizer(gestureRecognizer)
        showPlane.isHidden=false
    }
    
    @IBAction func showPlanes(_ sender: Any) {
        /* plotShape: Show scanned planes*/
        let sd  = ShapeDetection()
        sd.plotShape(sceneView: self.sceneView)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let currentPoint = sender.location(in: sceneView)
        // Get all feature points in the current frame
        let fp = self.sceneView.session.currentFrame?.rawFeaturePoints
        let sd = ShapeDetection()
        /* recordPoint : Record Tapped point */
        sd.recordPoint(pointcloud: fp, sceneView: sceneView, currentPoint: currentPoint)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
