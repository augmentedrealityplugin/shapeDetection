//
//  ViewController.swift
//  Nasty Pumpkins
//
//  Created by Aditya Gupta on 6/10/19.
//  Copyright © 2019 Aditya Gupta. All rights reserved.
//

import UIKit
import ARKit
import AVFoundation
import AudioToolbox
import ShapeDetection
enum BitMaskCategory: Int {
    case rock = 2
    case target = 5
    case plane = 0
}

class ViewController: UIViewController, SCNPhysicsContactDelegate {
    
    //Max and current sones/objects
    var currentStones: Float = 0.0
    var maxStones: Float = 15.0
    
    var audioPlayer = AVAudioPlayer()
    
//    var centroidList: [SCNVector3] = []
//    var eulerList: [SCNVector3] = []
//    var boundaryList: [ObjectBoundaries] = []
//    var transform : simd_float4x4 = matrix_identity_float4x4
    //variable to toggle oreientation button
    var buttonIsOn: Bool = false
    var gameison: Bool = false
    var realWorldObjectArray: [SCNVector3] = []
    var realWorldPOVOrientation: [SCNVector3] = []
    var realWorldObjectEulerArray: [SCNVector3] = []
    var realWorldObjectCentroidArray: [SCNVector3] = []
    @IBOutlet weak var homeButton: UIButton!
    //No. of stones progress bar
    @IBOutlet weak var timeLeft: UIProgressView!

    @IBOutlet weak var target: UIButton!
    @IBOutlet weak var view3d: UIButton!
    @IBOutlet weak var label: UIButton!
    @IBOutlet weak var showAllModelledObjButton: UIButton!
    
    
    @IBOutlet weak var gameOverLabel: UIButton!
    
    //Button press to go back to main page
    @IBOutlet weak var startgame: UIButton!
    // Added for shape optimization
   
    
    
    
    //Button press to show 3D Orientation and feature points
    @IBAction func orientation(_ sender: Any) {
        if buttonIsOn{
            self.sceneView.debugOptions = []
            buttonIsOn = false
        } else{
            self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
            buttonIsOn = true
        }
    }
    
    @IBAction func gameOverPopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //Add sceneView
    @IBOutlet var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var power: Float = 50
    var Target: SCNNode?
    var rock: SCNNode?
    
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true

        timeLeft.isHidden = true
        homeButton.isHidden = true
        view3d.isHidden  = true
        label.isHidden = true
        target.isHidden = true
        gameOverLabel.isHidden = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneView.addGestureRecognizer(gestureRecognizer)
        self.sceneView.scene.physicsWorld.contactDelegate = self
        
        
        timeLeft.layer.cornerRadius = 2
        timeLeft.clipsToBounds = true
        timeLeft.layer.sublayers![1].cornerRadius = 2
        timeLeft.subviews[1].clipsToBounds = true
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "ghostly", ofType: "mp3")!))
            audioPlayer.prepareToPlay()
        }
        catch{
            print("Sound File Not Found")
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if gameison{
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfView = sceneView.pointOfView else {return}
        //Standard position of objects intake
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        
        //making a rock to throw at pumpkins
        let rock = SCNNode(geometry: SCNSphere(radius: 0.2))
        rock.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "rock1")
        //make rock initial starting point as cameras/users loci
        rock.position = position
        //body type is dynamic as rock is to be thrown, unlike pumpinks which are kept static
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: rock, options: nil))
        
        //let rocks take a parabolic throw curve, thus affected by gravity
        body.isAffectedByGravity = true
        rock.physicsBody = body
        rock.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
        rock.physicsBody?.categoryBitMask = BitMaskCategory.rock.rawValue
        rock.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
        self.sceneView.scene.rootNode.addChildNode(rock)
        
        
        //Counting stones
        perform(#selector(updateProgress), with: nil, afterDelay: 1.0 )
        }
        else{
            let currentPoint = sender.location(in: sceneView)
            let fp = self.sceneView.session.currentFrame?.rawFeaturePoints
            let sd = ShapeDetection()
            sd.recordPoint(pointcloud: fp, sceneView: sceneView, currentPoint: currentPoint)
            
            
        
    }
}
    
    
    
    @IBAction func addTargets(_ sender: UIButton) {
        
        sender.isHidden = true
        

        var index = 0;
        var x:Float = 0
        var y:Float = 0
        var z:Float = 0
        
        var eulerangles : SCNVector3
        var sd  = ShapeDetection()
        var polyshapeinfo:([[SCNVector3]],[SCNVector3],[SCNVector3],[SCNVector3]) = sd.getObjectInfo()
        realWorldObjectEulerArray = polyshapeinfo.1
        realWorldPOVOrientation = polyshapeinfo.2
        realWorldObjectCentroidArray = polyshapeinfo.3
        for _ in realWorldObjectCentroidArray{
            x = realWorldObjectCentroidArray[index].x
            y = realWorldObjectCentroidArray[index].y
            z = realWorldObjectCentroidArray[index].z
        
            let sphere3 = SCNNode(geometry: SCNSphere(radius: 0.03))
            sphere3.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            sphere3.position = SCNVector3(x,y,z)
            
            
            self.sceneView.scene.rootNode.addChildNode(sphere3)
            eulerangles = polyshapeinfo.1[index]
            
            self.addPumpkin(x: x+realWorldPOVOrientation[index].x, y: y+realWorldPOVOrientation[index].y, z: z+realWorldPOVOrientation[index].z,eulerangles:eulerangles)
            self.addPumpkin(x: x+realWorldPOVOrientation[index].x, y: y+realWorldPOVOrientation[index].y, z: z+realWorldPOVOrientation[index].z,eulerangles:eulerangles)
            self.addPumpkin(x: x+realWorldPOVOrientation[index].x, y: y+realWorldPOVOrientation[index].y, z: z+realWorldPOVOrientation[index].z,eulerangles:eulerangles)
            
            index += 1
        }
       
        
        
        
        //Call horizontal progress bar
        timeLeft.setProgress(currentStones, animated: true)
        //perform(#selector(updateProgress), with: nil, afterDelay: 1.0 )
        
        //Call circular progress bar
        self.perform(#selector(animateProgress), with: nil, afterDelay: 1)
        
    }
    
    func addPumpkin(x: Float, y: Float, z: Float,eulerangles: SCNVector3) {
        //Pumpkin is a 3D scnekit item
        let pumpkinScene = SCNScene(named: "Media.scnassets/Halloween_Pumpkin.scn")
        let pumpkinNode = (pumpkinScene?.rootNode.childNode(withName: "Halloween_Pumpkin", recursively: false))!
        pumpkinNode.position = SCNVector3(x,y,z)
        pumpkinNode.eulerAngles = eulerangles
        let phy_body = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: pumpkinNode, options: nil))
        pumpkinNode.physicsBody = phy_body
        pumpkinNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        pumpkinNode.physicsBody?.contactTestBitMask = BitMaskCategory.rock.rawValue
        self.sceneView.scene.rootNode.addChildNode(pumpkinNode)
        
        //randomly assigning either 2D movement or movement towards POV
        let number = Int.random(in: 0 ... 1)
        if number == 0 {
            self.twoDimensionalMovement(node: pumpkinNode)
        } else {
            self.towardsPOVMovement(node: pumpkinNode)
        }
        
        audioPlayer.play()
    }
    
    func towardsPOVMovement(node: SCNNode) {
        guard let pointOfView1 = self.sceneView.pointOfView else {return}
        let transform1 = pointOfView1.transform
        let location1 = SCNVector3(transform1.m41, transform1.m42, transform1.m43)
        let hover = SCNAction.move(to: location1, duration: 3)
        node.runAction(hover)
        // bokeh when pumpkin reaches POV        
        let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
        dispatchQueue.async{
            //Time consuming task here
            while (true) {
                if(SCNVector3EqualToVector3(node.position, location1)) {
                    let bokeh2 = SCNParticleSystem(named: "Media.scnassets/bokeh2.scnp", inDirectory: nil)
                    bokeh2?.loops = false
                    bokeh2?.particleLifeSpan = 6
                    bokeh2?.emitterShape = node.geometry
                    let bokeh2Node = SCNNode()
                    bokeh2Node.addParticleSystem(bokeh2!)
                    bokeh2Node.position = location1
                    self.sceneView.scene.rootNode.addChildNode(bokeh2Node)
                    node.runAction(SCNAction.removeFromParentNode())
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    AudioServicesPlaySystemSound (SystemSoundID(1003))
                    
                    let plane_count = self.realWorldObjectCentroidArray.count
                    
                    if (plane_count > 0) {
                        
                        let index_val = Int.random(in: 0 ... plane_count-1)
                        let x = self.realWorldObjectCentroidArray[index_val].x
                        let y = self.realWorldObjectCentroidArray[index_val].y
                        let z = self.realWorldObjectCentroidArray[index_val].z
                        let eulerangles = self.realWorldObjectEulerArray[index_val]
                        self.addPumpkin(x: x+self.realWorldPOVOrientation[index_val].x, y: y+self.realWorldPOVOrientation[index_val].y, z: z+self.realWorldPOVOrientation[index_val].z,eulerangles:eulerangles)
                    }
                    break
                }
            }
        }

    }
    
    
    func twoDimensionalMovement(node: SCNNode) {
        let hover_x = CGFloat.random(in: -5...5)
        let hover_y = CGFloat.random(in: -5...5)
        let hoverUp = SCNAction.moveBy(x: hover_x, y: hover_y, z: 0, duration: 1)
        let hoverDown = SCNAction.moveBy(x: -(hover_x), y: -(hover_y), z: 0, duration: 1)
        let hoverSequence = SCNAction.sequence([hoverUp, hoverDown])
        let repeatForever = SCNAction.repeatForever(hoverSequence)
        
        node.runAction(repeatForever)
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        // Nothing should happen if rock or pumpkin touches the plane
        if (nodeA.physicsBody?.categoryBitMask == BitMaskCategory.plane.rawValue || nodeB.physicsBody?.categoryBitMask == BitMaskCategory.plane.rawValue) {
            return
        }
        else {
            if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
                self.Target = nodeA
                self.rock = nodeB
            } else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
                self.Target = nodeB
                self.rock = nodeA
            }
            var x:Float = 0
            var y:Float = 0
            var z:Float = 0
            //Add animation = bokeh to pumkin being hit, then delte pumpkin child node
            let bokeh = SCNParticleSystem(named: "Media.scnassets/bokeh.scnp", inDirectory: nil)
            bokeh?.loops = false
            bokeh?.particleLifeSpan = 3
            bokeh?.emitterShape = Target?.geometry
            let bokehNode = SCNNode()
            bokehNode.addParticleSystem(bokeh!)
            bokehNode.position = contact.contactPoint
            self.sceneView.scene.rootNode.addChildNode(bokehNode)
            Target?.removeFromParentNode()
            rock?.removeFromParentNode()
            let plane_count = self.realWorldObjectCentroidArray.count
            // Add a new pumpkin everytime one gets shot
            if (plane_count > 0) {
                let index_val = Int.random(in: 0 ... plane_count-1)
                let eulerangles = self.realWorldObjectEulerArray[index_val]
                x = self.realWorldObjectCentroidArray[index_val].x
                y = self.realWorldObjectCentroidArray[index_val].y
                z = self.realWorldObjectCentroidArray[index_val].z
                self.addPumpkin(x: x+self.realWorldPOVOrientation[index_val].x, y: y+self.realWorldPOVOrientation[index_val].y, z: z+self.realWorldPOVOrientation[index_val].z,eulerangles:eulerangles)
            }
        }
        
    }


    @objc func updateProgress(){
        
        if currentStones < maxStones{
            currentStones = currentStones + 1.0
            timeLeft.progress = currentStones/maxStones
            
        }else{
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            timeLeft.isHidden = true
            homeButton.isHidden = true
            view3d.isHidden  = true
            label.isHidden = true
            target.isHidden = true
            

            gameOverLabel.isHidden = false

        }
      
    }
    
    @objc func animateProgress() {
        let cp = self.view.viewWithTag(101) as! CircularProgress
        //Define time duration allowed
        cp.setProgressWithAnimation(duration: 15.0, value: 1.0)
    }
   
    
    @IBAction func startGame(_ sender: Any) {
        showAllModelledObjButton.isHidden = true
        timeLeft.isHidden = false
        homeButton.isHidden = false
        view3d.isHidden  = false
        label.isHidden = false
        target.isHidden = false
        let circularProgress = CircularProgress(frame: CGRect(x: 10.0, y: 30.0, width: 100.0, height: 100.0))
        circularProgress.progressColor = UIColor.orange
        circularProgress.trackColor = UIColor.white
        circularProgress.tag = 101
        circularProgress.center = self.view.center
        self.view.addSubview(circularProgress)
        gameison = true
        startgame.isHidden=true
        
    }
    
    
   
    
    @IBAction func onShowAllModelledObjectsClick(_ sender: Any) {
        let sd  = ShapeDetection()
        sd.plotShape(sceneView: self.sceneView)
       
    }
   
    
    
}

//Function to define "+" sign to add POV and Orentation = Location
func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}




