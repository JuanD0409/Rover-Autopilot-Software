# Rover-Autopilot-Software
A program, made in kOS (Kerboscript), to automatically navigate a rover, using waypoints, in Kerbal Space Program.

<img width="512" height="512" alt="rover-selfie" src="https://github.com/user-attachments/assets/95b7ea34-a8b7-4ea4-80f9-521446e4d360" />

Image of the test rover (based on NASA's Curiosity MSL) taken by a camera on the robotic arm.

## Quick Start guide
1. While controlling the rover you want to automate, open the kOS terminal and type the command `EDIT rover.script.` This will open a window below the terminal to edit the code.
2. Copy the code on the "Rover_Autopilot_Software.ks" file, paste it to the window below the terminal, and click on the "save" button on that same window. The terminal should confirm that the changes were saved correctly.
3. Next, run the script and follow the prompts on that appear on the terminal. The rover will then actuate on its own.

## Features
* Waypoint-based Navigation and Selection Menu
* Point-Turn capability by Differential Steering (Torque Vectoring)
* Speed and Heading Control
* Scientific Analysis Sequence and Automatic Data Transmission
* Slope-Awareness and Maneuvering
* Distance, Speed, and ETA Calculator and Display

## Local Deployment Tutorial

1. Check the Requirements section below and confirm everything is correctly installed and set up.
2. Execute the quick start guide.
3. Type the following command on the terminal: `RUN rover.script.`
4. When the list of waypoints appears on the terminal, type the number of the waypoint you want to reach.
5. When the rover reaches the target waypoint, it will automatically execute the scientific analysis sequence and transmit all found data.
6. After this is completed, the rover will re-check if the brakes are applied and end the script.

Note: The code will work without this characteristics. However, most Action Group activation, `WAIT`, and `PRINT` commands inside the `executeScienceSequence` function should be deleted or marked as comments for correct functioning.

## Version Information

### Requirements (as tested)

* Kerbal Space Program: v1.12.5.3190
* Breaking Ground DLC: v1.7.1
* kerbal Operating System (kOS): v1.6.0.1.
* kOS's Dependencies: latest compatible version.

Notes: Any kOS version provides KerboScript compatibility; main difference between versions is syntax for commands.

### Additional Mod Recommendations (as tested)

* CKAN: v1.36.4.26132 (For mod install, management, update, and compatibility check.)
* Infernal Robotics-Next: v3.1.22
* kOS for All!: v0.0.5 (stable release)
* Neptune Camera v4.3 
* Dependencies of mods installed: latest compatible version.

Note: The code will work without these mods. However they are strongly recommended for better integration and overall experience.

### Required Rover Characteristics
* kOS computer (kOS for All! enables the mod in any probe core).
* Large electricity reservoir and generator.
* Antenna that meets communications range between current planet and Kerbin.
* Wheels that hold the rover's weight.

### Optional Rover Characteristics
* Robotic servos that steer the front and rear wheels 45 degrees towards the rover (Recommended build with Infernal Robotics-Next).
* Rocker-Bogie suspension for better handling under harsh terrain and slopes (Infernal Robotics-Next is required for this).
* Robotic arm with various scientific instruments (Recommended build with Infernal Robotics-Next).
* Sample drill and Laser Camera (included with Infernal Robotics-Next).
* Camera systems on the front, rear, mast, and robotic arm (Neptune Camera is required for this). 

## How the script works

### Navigation

The program first scans the planet for waypoints; if none are found, a message saying "No waypoints found on this planet." appears on the terminal. If at least one is found, a list appears on the terminal asking the user to select the number (from 0-9) of the waypoint that wants to be reached. After targeting the waypoint, the rover initiates its autopilot script. The main control loop remains active until the rover is within a 1-meter range of the targeted waypoint and constantly corrects the rover's heading using normal steering. Additionally, the program shows a coded UI displaying data like remaining distance to target, current ground speed, and estimated arrival time; and updates those values every physics tick until the target waypoint is reached. When the rover reaches the target waypoint, it will shut down the main control loop and brake until completely stopping. If the target heading is 5 degrees away or more from the rover's current heading, it will initiate a point-turn sequence that turns the front and rear wheels 45 degrees toward the rover and rotates it on its place using differential steering (torque vectoring) all the way to the target heading. The old `setWheelReverse` function was swapped for the differential steering function as a tradeoff, because, despite multiple attempts to fix, it never worked. Once the point-turn is completed, the rover returns the wheels to normal and starts driving. The rover's speed control function has a limiter range between 1.0 and 2.0 m/s, for safety reasons. It is also equipped with a smart slope-awareness function that determines and actuates upon the following conditions:

* Flat Area: Maintains cruise speed between range
* Uphill: Increases power (or maximum power if starting to reverse)
* Downhill: Idles power and Brakes if needed

Note: For better maneuvering and overall behavior it is recommended to set traction control to 0 and friction control to 10. If your rover has a rocker-bogie suspension, set the wheels' spring strength to 3 (max) and damper resistance to 2 (max).

### Scientific Analysis

This function has various aspects. These include performing analysis with a laser camera; extending, maneuvering, and retracting a robotic arm that drills and stores a sample; activating multiple scientific devices; and transmitting all collected data. This sequence structure is engineered by adequately managing action groups, Kal-1000 controllers, and `WAIT` commands. Every action group activates a Kal-1000 controller that performs a certain animation acting either on the laser camera or on the robotic arm. The action groups activated also trigger `WAIT` commands that force the program to stop until the Kal-1000's animations are completed. Then, another action group activates various scientific instruments that gather readings which are stored on-board for transfer. The sequence then commands to drill a sample from the soil, store it, and retract the robotic arm back to its rest/drive position. After the arm is done retracting, the program continues the function's structure and starts the data transmission procedure. The program then searches for scientific modules on the rover that have data and starts transmitting it.

Once transmission is done, the program re-checks that the brakes are enabled and ends the sequence.

### Limitations

The following is a complete list of the limitations the script presented while on multiple tests.

* Both rover and script were unable to perform point-turns on hills greater than 5 degress.
* Script has to be re-run after reaching the target waypoint (or after completing the scientific analysis sequence). This means no complex course correction or re-routing can be done by the script.
* Kal-1000 controllers have to be reset to 0.0 play position after every activation (for adequate sequence activation).
* Script is unable to evade physical objects (like rocks or ship parts) since there is no way to write a function that makes the cameras recognize them (unlike a real-world rover would).
* Depending on the rover's weight and wheel power, it might or might not climb extremely steep hills (15 degrees or higher).

## Acknowledgements

* Original kOS creator: Github user Nivekk (Kevin Laity).
* All 126 kOS developers and contributors.
