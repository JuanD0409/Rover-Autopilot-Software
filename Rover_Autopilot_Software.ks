// Rover Autopilot Software
CLEARSCREEN.
PRINT "=== ROVER AUTOPILOT INITIALIZED ===".

// Waypoint Scan Function
LOCAL wpList is LIST().
FOR wp IN ALLWAYPOINTS() {
    IF wp:BODY:NAME = "Duna"{ // "Duna" can be changed to whatever other planet or moon a rover is sent. Duna is where I tested the rover's code.
        wpList:ADD(wp).
    }
}

IF wpList:LENGTH = 0 {
    PRINT "No active waypoints found in this planet.". // "Duna" was written above in order for the script to search exclusively for waypoints in Duna.
    SET SHIP:CONTROL:WHEELTHROTTLE TO 0.
    BRAKES ON.
}

// Waypoint Selection Menu
CLEARSCREEN.
PRINT "===================================".
PRINT "        AVAILABLE WAYPOINTS        ".
PRINT "===================================".
LOCAL idx IS 0.
FOR wp IN wpList {
    PRINT "[" + idx + "] " + wp:NAME.
    SET idx TO idx + 1.
}
PRINT "===================================".

LOCAL validChoise IS FALSE.
LOCAL currentWP IS 0.

UNTIL validChoise {
    PRINT "Enter the waypoint number to target: ".
    LOCAL userInput IS TERMINAL:INPUT:GETCHAR().
    LOCAL userNum IS userInput:TONUMBER(-1). //Returns -1 is text is invalid
    
    IF userNum >=0 AND userNum < wpList:LENGTH {
        SET currentWP TO wpList[userNum].
        SET validChoise TO TRUE.
    } ELSE {
        PRINT "Invalid choise. Please select a number from the list above.".
    }
}

CLEARSCREEN.
PRINT "Target Locked: " + currentWP:NAME.
PRINT "Activating Autopilot...".
WAIT 3.

//Main Autopilot Loop
UNTIL currentWP:GEOPOSITION:DISTANCE < 8 {
    LOCAL targetGeo IS currentWP:GEOPOSITION.
    LOCAL headingError TO targetGeo:BEARING.

    // Check if 360 degree turn is necessary.
    IF ABS(headingError) > 5 {
        executePointTurn(targetGeo). 
    } ELSE {
        SET SHIP:CONTROL:WHEELSTEER TO -1 * (headingError / 20). // If 360 turn is not needed, activates normal steering.
        controlSpeed(1.0, 2.0).
    }

    WAIT 0.1. //Physics tick pause
}

// After destination is reached...
//executeScienceSequence(). // Executes a list of commands (found below) to analyze multiple things with cameras, a robotic arm, and other instruments.

PRINT "=== MISSION COMPLETE ===".
SET SHIP:CONTROL:WHEELTHROTTLE TO 0.
SET SHIP:CONTROL:WHEELSTEER TO 0.
BRAKES ON.

// Rover Functions:

FUNCTION controlSpeed {
    PARAMETER minSpeed, maxSpeed.
    
    // Vector calculations to detect slopes. Negative value means downhills. Positive value means uphills.
    LOCAL forwardSpeed IS VDOT(SHIP:VELOCITY:SURFACE, SHIP:FACING:FOREVECTOR).
    LOCAL slopeAngle IS VDOT(SHIP:FACING:FOREVECTOR, SHIP:UP:VECTOR).
    LOCAL isDownhill IS slopeAngle < -0.01. // Math threshold for downhills.

    // Downhill mode
    IF isDownhill {
       SET SHIP:CONTROL:WHEELTHROTTLE TO 0. // Idles the wheels completely when going downhill.
       
        IF forwardSpeed > maxSpeed { 
            BRAKES ON. // Speed limit exceeded; apply brakes.
            PRINT "Downhill Detected: Braking..." AT (0, 10).
        } ELSE {
            BRAKES OFF. // Safe speed; coast freely.
            PRINT "Downhill Detected: Coasting..." AT (0, 10). 
        }
    } ELSE {
        
        // Plane/Uphill mode 
        IF forwardSpeed > maxSpeed {
            BRAKES ON.
            SET SHIP:CONTROL:WHEELTHROTTLE TO 0. // Idles wheels to make decelerating easier.
            PRINT "Plane/Uphill: Speed limit exceeded. Braking..." AT (0, 10).
        } ELSE IF forwardSpeed < minSpeed {
            BRAKES OFF.
            
            IF forwardSpeed < 0 {
                SET SHIP:CONTROL:WHEELTHROTTLE TO 1.0. // Sets maximum power mode to stop reversing on slope.
                PRINT "WARNING: Slope Reverse detected. Recovering..." AT (0, 10).
            } ELSE {
                SET SHIP:CONTROL:WHEELTHROTTLE TO 0.8. // Increased power to climb slope easier.
                PRINT "Uphill Detected: Increased power." AT (0, 10).
            }
        } ELSE {
            BRAKES OFF.
            SET SHIP:CONTROL:WHEELTHROTTLE TO 0.2. // Normal cruise setting (can be changed according to rover power and mass).
            PRINT "Normal Cruise enabled." AT (0, 10).
        }
    }
}

FUNCTION executePointTurn {
    PARAMETER targetGeo.
    PRINT "Heading error is greater than 5 degrees. Initiating point-turn...".

    // 1. Completely stop the rover and set wheel power for torque vectoring.
    SET SHIP:CONTROL:WHEELTHROTTLE TO 0.
    BRAKES ON. 
    LOCAL stopTimeout IS TIME:SECONDS + 2. // Prevents getting stuck anywhere by adding a timeout command.
    WAIT UNTIL (SHIP:VELOCITY:SURFACE:MAG < 0.1) OR (TIME:SECONDS > stopTimeout).
    
    // 2. Turn the front and rear wheels 45 degrees using robotic servos controlled by a Kal-1000 toggled by two action groups.
    TOGGLE AG1. // Set action group 1 to set to normal play and activate the Kal-1000 that steers the wheels.
    WAIT 5. // The time the program pauses while the wheels turn can be changed.
    BRAKES OFF.
    setWheelPower("left_wheel", 25).
    setWheelPower("right_wheel", 50).
    WAIT 0.5. 

    // 3. Rotate the rover until it's aligned within 1 degree of target heading.
    UNTIL ABS(targetGeo:BEARING) < 1 {
        IF targetGeo:BEARING > 0 {
            SET SHIP:CONTROL:WHEELTHROTTLE TO -1.0. // Rover turns right when throttling backward.
        } ELSE {
            SET SHIP:CONTROL:WHEELTHROTTLE TO 1.0. // Rover turns left when throttling forward.
        }
        WAIT 0.05.
    }

    // 4. Stop the rover's rotation.
    SET SHIP:CONTROL:WHEELTHROTTLE TO 0.
    BRAKES ON.
    setWheelPower("left_wheel", 100).
    setWheelPower("right_wheel", 100).
    SET stopTimeout TO TIME:SECONDS + 2.
    WAIT UNTIL (SHIP:VELOCITY:SURFACE:MAG < 0.1) OR (TIME:SECONDS > stopTimeout).
 
    //5. Return wheels to normal driving position.
    TOGGLE AG2. // Set this action group to make the same Kal-1000 as AG1 play in reverse, straightening the wheels to drive mode.
    WAIT 5. // The time the program pauses while the wheels straighten out.
    BRAKES OFF.

    PRINT "Point-Turn complete. Resuming cruise.".
}

FUNCTION setWheelPower {
    PARAMETER tag, powerPercent.
    FOR P IN SHIP:PARTSTAGGED(tag) {
        FOR m IN p:MODULES {
            IF m:TOUPPER:CONTAINS("WHEEL") AND m:TOUPPER:CONTAINS("MOTOR") {
                IF p:GETMODULE(m):HASFIELD("drive limiter") {
                    p:GETMODULE(m):SETFIELD("drive limiter", powerPercent).
                }
            }
        }
    }
}

FUNCTION executeScienceSequence {
    PRINT "Destination reached. Initiating science analysis...".
    SET SHIP:CONTROL:WHEELTHROTTLE TO 0.
    BRAKES ON.
    WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < 0.05.

    // Deploy Laser Camera
    PRINT "Deploying Laser Camera...".
    TOGGLE AG6. // Remember to reset Kal-1000 after activation. Otherwise, the sequence will not work correctly.
    WAIT 15.
    
    // Deploy Robotic Arm
    PRINT "Deploying robotic arm...".
    TOGGLE AG3.
    WAIT 90. //Adjust time based on the time the Kal-1000 deploy animation takes to finish.
    
    //Instrument Activation
    PRINT "Analyzing local conditions...".
    TOGGLE AG7. // Set various scientific experiments to this action group.
    WAIT 5. // Forces the program to wait 5 seconds while instruments acquire the readings.
    PRINT "Analysis terminated.".
    
    // Sample Collection
    PRINT "Drilling soil to collect sample...".
    TOGGLE AG8. // Set this action group to activate a drill that collects a sample.
    WAIT 15. // Forces the program to wait while the sample is drilled.
    PRINT "Sample acquired.".

    // Sample Storage
    PRINT "Storing sample...".
    TOGGLE AG4. // Set this action group to activate a Kal-1000 controller that moves the robotic arm in a way that appears as a NASA rover performing a sample collection. Also, place an Experiment Return Unit in your rover, and set it to collect all at the end of the Kal-1000 sequence.
    WAIT 75. // Forces the program to wait while the robotic arm stores the sample.
    
    // Retract Robotic Arm.
    PRINT "Retracting arm to rest position...".
    TOGGLE AG5. // Set this action group to activate another Kal-1000 controller that retracts the robotic arm for its sample storage position to its rest position.
    WAIT 75. // Forces the program to wait until the robotic arm retracts safely to its rest/drive position.
}

PRINT "Science sequence terminated.".

// Transmit all collected data back to Kerbin (Earth).
FOR p IN SHIP:PARTS {
    IF p:HASMODULE("ModuleScienceExperiment") {
        LOCAL scienceModule IS p:GETMODULE("ModuleScienceExperiment").
        IF scienceModule:HASDATA {
            scienceModule:TRANSMIT().
            WAIT 1. // 1 second delay to prevent transmission overlap.
        }
    }
}
PRINT "Data transmission complete.".
// End of script