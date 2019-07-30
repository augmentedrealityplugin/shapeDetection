//
//  viewControllerPlane.swift
//  Nasty Pumpkins
//
//  Created by Sunny Singh on 6/13/19.
//  Copyright © 2019 Aditya Gupta. All rights reserved.
//

import UIKit
import ARKit
import Foundation

class viewControllerPlane: UIViewController, ARSCNViewDelegate {
    
    let configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet weak var sceneView: ARSCNView!
    var objectCount = -1
    var lastEulerAngleDetetedForObject: SCNVector3 = SCNVector3(0,0,0)
    
    var dist_x: [Float] = []
    var dist_y: [Float] = []
    var dist_z: [Float] = []
    var param_array = Set<vector_float3>()
    var realWorldObjectArray: [Set<vector_float3>] = []
    var realWorldObjectCentroidArray: [SCNVector3] = []
    var realWorldObjectEulerArray: [SCNVector3] = []
    var realWorldObjectMaxBoundriesArray: [ObjectBoundaries] = []
    var transformcordinate : simd_float4x4 = matrix_identity_float4x4
    var scanningComplete = true
    
    //Buttons
    @IBOutlet weak var startButtonObject: UIButton!
    
    @IBOutlet weak var stopButtonObject: UIButton!
    
    
    
    @IBOutlet weak var showAllModelledObjButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        sceneView.preferredFramesPerSecond = 30
        sceneView.session.run( configuration )
        guard let currentFrame = sceneView.session.currentFrame else {return}
        let camera = currentFrame.camera
        
        self.transformcordinate = camera.transform
        self.sceneView.delegate = self
        
    }
    @IBAction func burronpress(_ sender: Any) {
        performSegue(withIdentifier: "moveToGame", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! ViewController
//        vc.centroidList = self.realWorldObjectCentroidArray
//        vc.eulerList = self.realWorldObjectEulerArray
//        vc.boundaryList = self.realWorldObjectMaxBoundriesArray
//        vc.transform = self.transformcordinate
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        //If scanning is not on. Return from here
        if(self.isScanningComplete()){
            // TODO: Show a message to tell the user to press the start tapping option
            return
        }
        
        let currentPoint = touch.location(in: sceneView)
        // Get all feature points in the current frame
        
        let fp = self.sceneView.session.currentFrame?.rawFeaturePoints
        guard let count = fp?.points.count else{return}
        // Create a material
        let material = createMaterial()
        // Loop over them and check if any exist near our touch location
        // If a point exists in our range, let's draw a sphere at that feature point
        for index in 0..<count {
            let point = SCNVector3.init((fp?.points[index].x)!, (fp?.points[index].y)!, (fp?.points[index].z)!)
            let projection = self.sceneView.projectPoint(point)
            let xRange:ClosedRange<Float> = Float(currentPoint.x)-100.0...Float(currentPoint.x)+100.0
            let yRange:ClosedRange<Float> = Float(currentPoint.y)-100.0...Float(currentPoint.y)+100.0
            if (xRange ~= projection.x && yRange ~= projection.y) {
                let ballShape = SCNSphere(radius: 0.001)
                ballShape.materials = [material]
                let ballnode = SCNNode(geometry: ballShape)
                ballnode.position = point
                self.sceneView.scene.rootNode.addChildNode(ballnode)
                // We'll also save it for later use in our [SCNVector]
                //                let p_oints = CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
                //                points.append(p_oints)
                self.param_array.insert(vector_float3(point))
                self.lastEulerAngleDetetedForObject = self.getDyamicEulerAngles()
            }
        }
    }
    
    func getDyamicEulerAngles() -> SCNVector3 {
        guard let pointOfView = self.sceneView.pointOfView else {return SCNVector3(0,0,0)}
        let transform = pointOfView.eulerAngles
        return SCNVector3(transform.x, transform.y, transform.z)
    }
    
    func createMaterial() -> SCNMaterial {
        let clearMaterial = SCNMaterial()
        clearMaterial.diffuse.contents = UIColor(red:0.12, green:0.61, blue:1.00, alpha:1.0)
        clearMaterial.locksAmbientWithDiffuse = true
        clearMaterial.transparency = 0.2
        return clearMaterial
    }
    
    func showAllModelledObjects() {
        if(self.isCentroidCalculationRequired()){
            self.calculateCentroidForAllRealWorldObjects()
            print("All Centroids and Boundaries Calculated")
            print(self.realWorldObjectCentroidArray)
        }
        //Now proceed to show the object
//        var count = 0;
//        //Objects are scanned  scanned now. Lets Store its 3D ARCloud Model
//        for _ in self.realWorldObjectArray{
//            self.placePlaneInFrontOfObjects(index: count)
//            count += 1
//        }
    }
    
    //Used For Occlusion. NOt being used now
    func placeInvisiblePlane(point: SCNVector3,width:Double, height:Double, z: Double, index: Int) {
        let maskMaterial = SCNMaterial()
        maskMaterial.diffuse.contents = UIColor.white
        maskMaterial.colorBufferWriteMask = SCNColorMask(rawValue: 0)
        maskMaterial.isDoubleSided = true
        let wallNode = SCNNode(geometry: SCNPlane(width: CGFloat(width), height: CGFloat(height)))
        //wallNode.geometry?.firstMaterial = maskMaterial
        wallNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        //wallNode.renderingOrder = -1
        wallNode.position = SCNVector3( point.x,point.y + 0.09,Float(z))
        wallNode.eulerAngles = self.realWorldObjectEulerArray[index]
        //wallNode.position = SCNVector3(0,0,0)
        self.sceneView.scene.rootNode.addChildNode ( wallNode )
    }
    
    func placeSphere( point: SCNVector3, width:Float, height: Float ) {
        let spehere = SCNNode(geometry: SCNSphere(radius: 0.05))
        spehere.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        spehere.position = SCNVector3( point.x ,point.y, point.z-0.5)
        self.sceneView.scene.rootNode.addChildNode( spehere )
    }
    
    func isCentroidCalculationRequired() -> Bool {
        if(realWorldObjectArray.count == realWorldObjectCentroidArray.count){
            return false
        }
        return true
    }
    
    func calculateCentroidForAllRealWorldObjects() {
        var count = 0
        for temp_param_array in self.realWorldObjectArray{
            if(count >= realWorldObjectCentroidArray.count ){
                let centroidAndBoundaries = self.calculateCentroidOfPoints(points: temp_param_array)
                
                realWorldObjectCentroidArray.append( centroidAndBoundaries.0)
                
                realWorldObjectMaxBoundriesArray.append(centroidAndBoundaries.1)
                
            }
            count += 1
        }
    }
    
    func calculateCentroidOfPoints(points :Set<vector_float3>) -> (SCNVector3, ObjectBoundaries){
        var xSum: Float = 0.0;
        var ySum: Float = 0.0;
        var zSum: Float = 0.0;
        let pointCount = Float(points.count)
        for point in points {
            var vectorFloatPoint = vector_float3( point )
            xSum += vectorFloatPoint.x
            ySum += vectorFloatPoint.y
            zSum += vectorFloatPoint.z
        }
        
        let xC = xSum / pointCount
        let yC = ySum / pointCount
        let zC = zSum / pointCount
        
        for point in points {
            dist_x.append(abs(point.x-xC))
            dist_y.append(abs(point.y-yC))
            dist_z.append(abs(point.z-zC))
        }
        
        dist_x = dist_x.sorted(by: >)
        dist_y = dist_y.sorted(by: >)
        dist_z = dist_z.sorted(by: >)
        
        let maxX = dist_x[0]
        let maxY = dist_y[0]
        let maxZ = dist_z[0]
        
        let objectBoundaries = ObjectBoundaries(maxX: maxX, maxY: maxY, maxZ: maxZ)
        
        return (SCNVector3(xC,yC,zC), objectBoundaries )
    }
    
    //We will Place the plane based on the Euler Angles. TC
    func placePlaneInFrontOfObjects(index: Int) {
        let objectBoundaries = self.realWorldObjectMaxBoundriesArray[index]
        
        let height = self.getHeightBasedOnOrientation(objectBoundaries: objectBoundaries,eulerAngle: self.realWorldObjectEulerArray[index])
        let width = CGFloat(objectBoundaries.getMaxX())
            
        self.realWorldObjectMaxBoundriesArray[index].height = Float(height)
        self.realWorldObjectMaxBoundriesArray[index].width = Float(width)
       

        let planeOfReference = SCNNode(geometry: SCNPlane(width: 2 * CGFloat(objectBoundaries.getMaxX()), height: 2 * height))
        
        planeOfReference.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        planeOfReference.position = SCNVector3(self.realWorldObjectCentroidArray[index].x,self.realWorldObjectCentroidArray[index].y,self.realWorldObjectCentroidArray[index].z)
        planeOfReference.eulerAngles = self.realWorldObjectEulerArray[index]
        planeOfReference.geometry?.firstMaterial?.isDoubleSided = true
        self.sceneView.scene.rootNode.addChildNode(planeOfReference)
        let sphere = SCNNode(geometry: SCNSphere(radius: 0.03))
        sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        sphere.position = SCNVector3(self.realWorldObjectCentroidArray[index].x,self.realWorldObjectCentroidArray[index].y,self.realWorldObjectCentroidArray[index].z)
        self.sceneView.scene.rootNode.addChildNode(sphere)
    }
    
    func getHeightBasedOnOrientation(objectBoundaries: ObjectBoundaries, eulerAngle: SCNVector3) -> CGFloat {
        
        //Get Orientation
        //If orientation is straight - OK x and y
        //else show x and z
        let xDegree = GLKMathRadiansToDegrees(eulerAngle.x)
        let normalisedX = 90 - abs(xDegree)
        
        if( normalisedX < abs(xDegree)){
            return CGFloat(objectBoundaries.getMaxZ())
        }
        else{
            return CGFloat(objectBoundaries.getMaxY())
        }
    }
    
    func getAllPlanesToRender(){
        
    }
    
    func isScanningComplete() -> Bool {
        return self.scanningComplete;
    }
    
    func _onScanningComplete() {
        self.scanningComplete = true
        //Add the scanned object to the realWorldObjectArray
        self.realWorldObjectArray.insert(self.param_array, at: self.objectCount)
        self.realWorldObjectEulerArray.insert( self.lastEulerAngleDetetedForObject , at: self.objectCount)
        self.param_array.removeAll()
    }
    
    func _onScanningStart() {
        self.scanningComplete = false
        self.objectCount += 1
    }
    
    @IBAction func onStartScanningClick(_ sender: Any) {
        print("Start Tap Button Clicked")
        self.startButtonObject.isEnabled = false
        self.stopButtonObject.isEnabled = true
        self.showAllModelledObjButton.isEnabled = false
        self._onScanningStart()
    }

    
    @IBAction func onStopScanningClick(_ sender: Any) {
        print("End Tap Button Clicked")
        if(isScanningComplete()){
            return
        }
        self.startButtonObject.isEnabled = true
        self.stopButtonObject.isEnabled = false
        self.showAllModelledObjButton.isEnabled = true
        self._onScanningComplete()
    }

    @IBAction func onShowAllModelledObjectsClick(_ sender: Any) {
        if(self.startButtonObject.isEnabled == false){
            self.destroyAllModelledObjects();
            self.startButtonObject.isEnabled = true
            return
    }
   
        self.showAllModelledObjects()
        self.startButtonObject.isEnabled = false
        self.stopButtonObject.isEnabled = false
    }
    
    func destroyAllModelledObjects(){
        
    }
    
    

}


extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */



