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
roam | searches for obstacles <br> once found goes to choose | chooses the closest obstacle <br> orientation of robot is set toward the choosen obstacle <br> state is changed to approach
approach | we go near the chosen obstacle <br> and change state to grab
grab | grab the obstacle<br> change to nearest_border_orient state
nearest_border_orient | according to pos we decide which side to go<br>change state to home
home | we try to go to black area<br> once there drop there drop the obstacle<br>change state to roam back again
