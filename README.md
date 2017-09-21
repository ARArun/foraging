# Foraging

## Aim

This is to design a simple foraging experiment. We are going to to write a generic  
program that lets robots taking objects and moving them to preferred locations.  

### sensors used

* proximity
* omni_directional_camera
* positioning
* differential_steering

### actuators used

* turret
* gripper
* differential_steering
* leds

### Implementation

So we have a set of robots that are going to search for obstacles find them,  
capture/grab them bring them to desired location. So first arena design.


### States Table

State | function
--- | ---
roam | searches for obstacles <br> once found goes to choose
