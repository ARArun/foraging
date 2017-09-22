--------------------------------------------------------------------------------
--------------------------------Foraging----------------------------------------
--------------------------------------------------------------------------------
count_time = 0
--------------------------------------------------------------------------------
-----------------------------Function Init--------------------------------------
--------------------------------------------------------------------------------
function init()
    state = "roam"
    prev_state = "dummy"
    robot.colored_blob_omnidirectional_camera.enable()
    robot.turret.set_position_control_mode()
end
--------------------------------------------------------------------------------
----------------------------Function Step---------------------------------------
--------------------------------------------------------------------------------
function step()
    if state ~= prev_state then
        log(state)
    end
    prev_state = state
    if state == "roam" then
        roam()
    elseif state == "choose" then
        choose()
    elseif state == "approach" then
        approach()
    elseif state == "grab" then
        grab()
    elseif state == "nearest_border_orient" then
        nearest_border_orient()
    elseif state == "home" then
        home()
    end
end
--------------------------------------------------------------------------------
-----------------------------Reset & Destroy------------------------------------
--------------------------------------------------------------------------------
function reset()
    init()
end

function destroy()

end
--------------------------------------------------------------------------------
--------------------------------Roam State--------------------------------------
--------------------------------------------------------------------------------
function roam()
    sensingLeft =     robot.proximity[3].value +
                      robot.proximity[4].value +
                      robot.proximity[5].value +
                      robot.proximity[6].value +
                      robot.proximity[2].value +
                      robot.proximity[1].value

    sensingRight =    robot.proximity[19].value +
                      robot.proximity[20].value +
                      robot.proximity[21].value +
                      robot.proximity[22].value +
                      robot.proximity[24].value +
                      robot.proximity[23].value
    if #robot.colored_blob_omnidirectional_camera >= 1 then
        state = "choose"
    elseif sensingLeft ~= 0 then
        robot.wheels.set_velocity(7,3)
    elseif sensingRight ~= 0 then
        robot.wheels.set_velocity(3,7)
    elseif robot.motor_ground[1].value < 0.40 then
        robot.wheels.set_velocity(7,3)
    elseif robot.motor_ground[4].value < 0.40 then
        robot.wheels.set_velocity(3,7)
    else
        robot.wheels.set_velocity(10,10)
    end
end
--------------------------------------------------------------------------------
--------------------------Function Choose---------------------------------------
--------We choose the nearest obstacle and orient our robot towards it----------
--------------------------------------------------------------------------------
function choose()

    robot.wheels.set_velocity(0,0)
    dist = robot.colored_blob_omnidirectional_camera[1].distance
    ang =  robot.colored_blob_omnidirectional_camera[1].angle

    for i = 1, #robot.colored_blob_omnidirectional_camera do

        if dist > robot.colored_blob_omnidirectional_camera[i].distance then
            dist = robot.colored_blob_omnidirectional_camera[i].distance
            ang = robot.colored_blob_omnidirectional_camera[i].angle
        end

    end

    if ang > 0.1 then
        robot.wheels.set_velocity(-1,1)
    elseif ang < -0.1 then
        robot.wheels.set_velocity(1,-1)
    elseif ang >= -0.1 and ang <= 0.1 then
        state = "approach"
    end

end
--------------------------------------------------------------------------------
----------------------------Function approach-----------------------------------
-----------We move towards the nearest obstacle we have choosen-----------------
--------------------------------------------------------------------------------
function approach()
    x = 0
    for i = 1, 24 do --some modification must be done here as we need not check
                     --all proximity sensors then ones located in fron tshall do
        if x < robot.proximity[i].value then
            x = robot.proximity[i].value
        end
    end
-------trying to keep the orientation while approaching the obstacle------------
    dist = robot.colored_blob_omnidirectional_camera[1].distance
    ang =  robot.colored_blob_omnidirectional_camera[1].angle

    for i = 1, #robot.colored_blob_omnidirectional_camera do

        if dist > robot.colored_blob_omnidirectional_camera[i].distance then
            dist = robot.colored_blob_omnidirectional_camera[i].distance
            ang = robot.colored_blob_omnidirectional_camera[i].angle
        end

    end
    if ang > 0 then
        robot.wheels.set_velocity(5,6)
    end
    if ang < 0 then
        robot.wheels.set_velocity(6,5)
    end
    if ang == 0 then
        robot.wheels.set_velocity(5,5)
    end
-------------trying to slow down when reaching near the obstacle----------------
    if x >= 0.5 then
        robot.wheels.set_velocity((1 - x) * 10, (1 - x) * 10)
    end
    if x >= 0.9 then
        robot.wheels.set_velocity(0,0)
        state = "grab"
    end
end
--------------------------------------------------------------------------------
--------------------------------Function Grab-----------------------------------
------------------------We rotate the turret and grab the box-------------------
--------------------------------------------------------------------------------
function grab()
    grip_ang = 200
    x = robot.proximity[1]
    x.value = 0
    pos = 0
    for i = 1,24 do
        if robot.proximity[i].value >= x.value then
            x = robot.proximity[i]
            pos = i
        end
    end
    if x.value == 1 then
        grip_ang = x.angle
    elseif pos >= 1 and pos <= 12 then
        robot.wheels.set_velocity(0,0.75)
    elseif pos >= 13 and pos <= 24 then
        robot.wheels.set_velocity(0.75,0)
    end
    if grip_ang ~= 200 then
        --log(pos," angle: ",x.angle,grip_ang,"value: ",robot.proximity[pos].value)
        robot.wheels.set_velocity(0,0)
        robot.turret.set_rotation(grip_ang)
        robot.gripper.lock_negative()
        count_time = count_time + 1
    end
    if count_time == 50 then
        robot.gripper.lock_negative()
        robot.turret.set_passive_mode()
        count_time = 0
        state = "nearest_border_orient"
    end
end
--------------------------------------------------------------------------------
-------------------Function nearest_border_orient-------------------------------
----------We Choose which side is nearest to the location of robot--------------
function nearest_border_orient()
    x = robot.positioning.position.x
    y = robot.positioning.position.y
    angle = robot.positioning.orientation.angle
    sign = robot.positioning.orientation.axis.z
    if (x >= 0 and y >= 0) and x >=y then --first quadrant --go top
        if (sign == 1 and angle < 0.1) or (sing == -1 and angle > 6.1) then
            state = "home"
        else
            robot.wheels.set_velocity(-1,1)
        end
    elseif (x > 0 and y > 0) and y > x then --first quadrant --go left
        if (sign == 1 and angle > 1.4 and angle < 1.6) or (sign == -1 and angle > 4.6 and angle < 4.7) then
            state = "home"
        else
            robot.wheels.set_velocity(-1,1)
        end
    elseif (x < 0 and y > 0) and -x > y then --second quadrant --go bottom
        if angle > 3 and angle < 3.2 then
            state = "home"
        else
            robot.wheels.set_velocity(-1,1)
        end
    elseif (x < 0 and y > 0) and y > -x then --second quadrant --go left
        if (sign == 1 and angle > 1.4 and angle < 1.6) or (sign == -1 and angle > 4.6 and angle < 4.7) then
            state = "home"
        else
            robot.wheels.set_velocity(-1,1)
        end
    elseif (x > 0 and y < 0) and math.abs(x) > math.abs(y) then --fourth quadrant --go top
        if (sign == 1 and angle < 0.1) or (sing == -1 and angle > 6.1) then
            state = "home"
        else
            robot.wheels.set_velocity(-1,1)
        end
    elseif (x > 0 and y < 0) and math.abs(x) < math.abs(y) then --fourth quadrant --go right
        if (sign == 1 and angle > 4.6 and angle < 4.7) or (sign == -1 and angle > 1.4 and angle < 1.6) then
            state = "home"
        else
            robot.wheels.set_velocity(-1,1)
        end
    elseif (x < 0 and y < 0) and math.abs(x) > math.abs(y) then --third quadrant --go bottom
        if angle > 3 and angle < 3.2 then
            state = "home"
        else
            robot.wheels.set_velocity(-1,1)
        end
    elseif (x < 0 and y < 0) and math.abs(x) < math.abs(y) then --third quadrant --go right
        if (sign == 1 and angle > 4.6 and angle < 4.7) or (sign == -1 and angle > 1.4 and angle < 1.6) then
            state = "home"
        else
            robot.wheels.set_velocity(-1,1)
        end
    end
end
