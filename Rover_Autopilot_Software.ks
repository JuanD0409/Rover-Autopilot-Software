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
    IF ABS(headingError) > 10 {
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
    LOCAL currentSpeed IS SHIP:VELOCITY:SURFACE:MAG.

    IF currentSpeed > maxSpeed {
        BRAKES ON.
        SET SHIP:CONTROL:WHEELTHROTTLE TO 0.
    } ELSE IF currentSpeed < minSpeed {
        BRAKES OFF.
    SET SHIP:CONTROL:WHEELTHROTTLE TO 0.25. 
    } ELSE {
        BRAKES OFF.
        SET SHIP:CONTROL:WHEELTHROTTLE TO 0.1.
    }
}

FUNCTION executePointTurn {
    PARAMETER targetGeo.

    PRINT "Heading error is greater than 5 degrees. Initiating point-turn...".

    // 1. Completely stop the rover.
    SET SHIP:CONTROL:WHEELTHROTTLE TO 0.
    BRAKES ON. 
    WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < 0.05.
    
    // 2. Turn the front and rear wheels 45 degrees using robotic servos controlled by a Kal-1000 toggled by two action groups.
    TOGGLE AG1. // Set action group 1 to set to normal play and activate the Kal-1000 that steers the wheels.
    WAIT 5. // The time the program pauses while the wheels turn can be changed.
    BRAKES OFF.

    // 3. Rotate the rover until it's aligned within 1 degree of target heading.
    UNTIL ABS(targetGeo:BEARING) < 1 {
        IF targetGeo:BEARING > 0 {
            SET SHIP:CONTROL:WHEELTHROTTLE TO 0.5. // Rover spins clockwise
        } ELSE {
            SET SHIP:CONTROL:WHEELTHROTTLE TO -0.5. // Rover spins counter-clockwise.
        }
        WAIT 0.05.
    }

    // 4. Stop the rover's rotation.
    SET SHIP:CONTROL:WHEELTHROTTLE TO 0.
    BRAKES ON.
    WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < 0.05.
 
    //5. Return wheels to normal driving position.
    TOGGLE AG2. // Set this action group to make the same Kal-1000 as AG1 play in reverse, straightening the wheels to drive mode.
    WAIT 5. // The time the program pauses while the wheels straighten out.
    BRAKES OFF.

    PRINT "Point-Turn complete. Resuming cruise.".
}

FUNCTION setWheelReverse {
    PARAMETER tag, shouldReverse. // shouldReverse is either true or false.
    
    LOCAL wheelList IS SHIP:PARTSTAGGED(tag).
    FOR w IN wheelList {
        IF w:HASMODULE("ModuleWheelMotor"){
            LOCAL motor IS w:GETMODULE("ModuleWheelMotor").
            
            // Thorough search of all KSP modules for wheel motors.
            LOCAL fields IS LIST("invert direction", "direction inverted", "invert motor", "motor direction").
            FOR f IN fields {
                IF motor:HASFIELD(f){
                    IF f = "motor direction"{
                        IF shouldReverse { motor:SETFIELD(f, "Inverted"). }
                        ELSE { motor:SETFIELD(f, "Normal"). }
                    } ELSE {
                        motor:SETFIELD(f, shouldReverse).
                    }
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