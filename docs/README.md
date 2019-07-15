# Augmented Reality Plugin
A Swift based ARKit plugin to recognize real-world objects (Occlusion) of **Anyshape, Anywhere, and of Anysize.**

Github Rep Link: https://github.com/augmentedrealityplugin/shapeDetection

Occlusion is defined as the practice of hiding virtual objects behind real-world objects. Currently (as of Jul 2019) iOS ARKit2 and ARKit3 does not have this functionality.

[![Plugin In-Action](plugin.gif)](https://www.youtube.com/watch?v=Coz21NN_kms&t=4s)

## Why is Occlusion implementation difficult?
To hide virtual objects we first have to identify and capture the real-world objects, get their coordinates and orientation with regards to the 3D World Origin, and the put our virtual objects behind them.

## Who should use this plugin?
1. Need Object/Shape detection in ARKit.
2. If you require coordinates and orientation of real-world objects for your AR game/app.
3. If you want to hide virtual objects behind real-world.


## How does this plugin help?
1. Captures the intended point in the real world based on the UI Tap action of the user. This is done by filtering all the feature points in the current frame and mapping it to the touch location.
2. Keep selecting points to get a good shape approximation of the object.
3. Once you have selected all the points, you can view the selected area. You also get it's Orientation, coordinates, and centorid w.r.t the 3D World Origin.


## Key features:
1. Select as many objects as you want
2. Any shape can be selected
3. Scale of the object can be as large or small as possible
4. The orientation of objects can be anything, it is not limited to similar plane objects
5. Can select objects while moving


## How to import this plugin into your project?
1. Clone the Shape detection plugin repo from Github.
2. In your project setting scroll down to Embedded Binaries -> Click on "+" -> Click on Add Other -> Select shapedetection.framework from the cloned repo and click open.
3. In your .swift file add the following line : "import ShapeDetection" to start using the plugin.

## How to use this plugin?
The plugin provides 3 methods.
1. recordPoint(featurepoints, ARSCNView, currentpoint): The method requires 3 parameters i.e featurepoints, your current sceneview, and sender location. This method should be implemented in a UITapGestureRecognizer action like a handleTap.
2. plotShape(ARSCNView): After you are done tapping and recording points pass the current sceneview to this method to plot an approximated shape of the object you scanned.
3. getObjectInfo(): Return the vertices scanned, centroid, eulerangles, and orientation w.r.t PoV.

Refer to the Example section which has demos showing the implementation of the plugin to create a game and a basic implementation of the plugin showing how the methods should be called.


---
### Conditions:
The plugin works on using feature points, so in dim lighting or against same color background as the object the points may not be immediately visible and may hinder detection. There are certain workarounds that can help tackle this in minor ways like placing a finger on the object to give contrast and get features, as well as using flashlight of the phone in dark.
