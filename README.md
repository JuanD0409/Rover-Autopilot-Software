# Rover-Autopilot-Software
A program, made in kOS (Kerboscript), to automatically navigate a rover, using waypoints, in KSP.

## Quick Start guide
1. While controlling the rover you want to automate, open the kOS terminal and type the command `EDIT rover.script.` This will open a window below the terminal to edit the code.
2. Copy the code on the "Rover_Autopilot_Software.ks" file, paste it to the window below the terminal, and click on the "save" button on that same window. The terminal should confirm that the changes were saved correctly.
3. Next, run the script and follow the prompts on that appear on the terminal. The rover will then actuate on its own.

## Features
* Waypoint-based Navigation and Selection Menu
* Point-Turn capability by Torque Vectoring
* Speed and Heading Control
* Scientific Analysis Sequence, and Automatic Data Transmission
* Slope-Awareness and Maneuvering.

## Local Deployment Tutorial

1. Execute the quick start guide.
2. Type the following command on the terminal: `RUN rover.script.`
3. When the list of waypoints appears on the terminal, type the number of the waypoint you want to reach.
4. When the rover reaches the target waypoint, it will automatically execute the scientific analysis sequence and transmit all found data.
5. After this is completed, the rover will re-check if the brakes are applied and end the script.

## Version Information

### Requirements (as tested)

* Kerbal Space Program: v1.12.5.3190
* Breaking Ground DLC: v1.7.1
* kerbal Operating System: v1.6.0.1
* Dependencies of each mod installed: latest compatible version

### Recommendations (as tested)

* Infernal Robotics-Next: v3.1.22
* kOS for All!: v0.0.5 (stable release) 

## How the script works

### Navigation

The program first scans the planet for all waypoints found; if there are none, a message saying "No waypoints found on this planet." appears on the terminal. If at least one is found, a list appears on the terminal asking the user to select the number (from 0-9) of the waypoint that wants to be reached. After targeting the waypoint, the rover initiates its autopilot script. The main control loop constantly evaluates if the rover is within a 1-meter range of the targeted waypoint and constantly corrects itself using normal steering. When the rover reaches the target waypoint, it will shut down the main control loop and brake until completely stopping. If the target heading is 5 degrees away or more from the rover's current heading, it will initiate a point-turn sequence that turns the front and rear wheels 45 degrees toward the rover and rotate on its place all the way to the target heading. Once the point-turn is completed, the rover returns the wheels to normal and starts driving. The rover's speed control function has a limiter range between 1.0 and 2.0 m/s, for safety reasons. It is also equipped with a smart slope-awareness function that determines and actuates upon the following conditions:

* Flat Area: Maintains cruise speed between range
* Uphill: Increases power (or maximum power if starting to reverse)
* Downhill: Idles power and Brakes if needed

### Scientific Analysis

This function has various aspects. These include performing analysis with a laser camera; extending, maneuvering, and retracting a robotic arm that drills and stores a sample; activating multiple scientific devices; and transmitting all collected data. This sequence structure is engineered by adequately managing action groups, Kal-1000 controllers, and `WAIT` commands. Every action group activates a Kal-1000 controller that performs a certain animation acting either on the laser camera or on the robotic arm. The action groups activated also trigger `WAIT` commands that force the program to stop until the Kal-1000's animations are completed. Then, another action group activates various scientific instruments that gather readings that are stored on-board for transfer. The sequence then commands to drill a sample from the soil, store it, and retract the robotic arm back to its rest/drive position. After the arm is done retracting, the program continues the function's structure and starts the data transmission procedure. The program then searches for scientific modules on the rover that have data, and starts transmitting it.

Once transmission is done, the program re-checks that the brakes are enabled and ends the sequence.

## Optional Rover Characteristics
* Robotic servos that steer the front and rear wheels 45 degrees towards the rover (Recommended build with Infernal Robotics-Next)
* Rocker-Bogie suspension for better handling under harsh terrain and slopes (Infernal Robotics-Next is required for this)
* Large electricity reservoir and generator
* Robotic arm with various scientific instruments (Recommended build with Infernal Robotics-Next)
* Sample drill and Laser Camera (included with Infernal Robotics-Next). 

Note: The code will work without this characteristics. However, most Action Group activation, `WAIT`, and `PRINT` commands inside the `executeScienceSequence` should be deleted or marked as comments for correct functioning.
