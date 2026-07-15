// Rover Autopilot Software
CLEARSCREEN.
PRINT "=== ROVER AUTOPILOT INITIALIZED ==="

// Waypoint Scan Function
LOCAL wpList is LIST().
FOR wp IN ALLWAYPOINTS() {
    IF wp:BODY:NAME = "Duna"{ // "Duna" can be changed to whatever other planet or moon a rover is sent. Duna is where I tested the rover's code.
        wpList:ADD(wp).
    }
}

IF wpList:LENGTH = 0 {
    PRINT "No active waypoint found in this planet.". // "Duna" was written above in order for the script to search exclusively for waypoints in Duna.
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
    LOCAL userNum IS userInput:TONUMBER(-1). //Returns -1 is text is unvalid
    
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