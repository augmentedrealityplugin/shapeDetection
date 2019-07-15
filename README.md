# Augmented Reality Plugin
A Swift based ARKit plugin to recognize real-world objects using feature points and implement Occlusion.

Occlusion is defined as the practice of hiding virtual objects behind real-world objects. Currently (as of Jul 2019) iOS ARKit2 and ARKit3 does not have this functionality.

### Why is Occlusion implementation difficult?
To hide virtual objects we first have to identify and capture the real-world world objects, get their coordinates and orientation with regards to the 3D World Origin, and the put our virtual objects behind them.

<insert a pic>

### How does this plugin help?
1. Takes the feature points from the object, and when you click them the point is selected. This point acts as a vertex/node 	of the polygonal shape you want to make.
2. Keep selecting points to get a good shape approximation of the object.
3. Once you have selected all the points, you can view the selected area. What the plugin does is save this objects' 			coordinates and orientation with respect to the 3D World Origin made by the ARKit. It further gives you the centroid of 	the so called object and you can place virtual objects w.r.t to this centroid. 

<insert a pic>

### How to use this plugin?

The plugin when called loads its own ARKit for Swift initializes its methods. 
1. Place the ARKit on your view controller and stretch it to cover the entire screen.
2. Name the SRKit Scene View in your ViewController.swift (or Game Controller.swift) file as an @IBOutlet ARSCView.
3. Place three buttons, 1 each for start tapping, stop tapping, and show playing area. Name the button similar to the ones 		in the plugin/code.
4. Copy paste the code or call the plugin and run app.

<insert a pic>

### Who should use this plugin?
1. Need Object/Shape detection in ARKit.
2. If you require coordinates and orientation of real-world objects for your AR game/app.
3. If you want to hide virtual objects behind real-world.

<insert a montage>

### Key features:
1. Select as many objects as you want
2. Any shape can be selected
3. Scale of the object can be as large or small as possible 
4. The orientation of objects can be anything, it is not limited to similar plane objects
5. Can select objects while moving

<insert a montage>

### Conditions:
The plugin works on using feature points, so in dim lighting or against same color background as the object the points may not be immediately visible and may hinder detection. There are certain workarounds that can help tackle this in minor ways like placing a finger on the object to give contrast and get features, as well as using flashlight of the phone in dark.
