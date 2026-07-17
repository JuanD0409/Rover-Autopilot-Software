# Rover-Autopilot-Software
A program, made in kOS (Kerboscript), to automatically navigate a rover, using waypoints, in KSP.

## Quick Start guide
1. While controlling the rover you want to automate, open the kOS terminal and type the command "EDIT rover.script." this will open a window below the terminal to edit the code.
2. Copy the code on the "Rover_Autopilot_Software.ks" file, paste it to the window below the terminal, and click on the "save" button on that same window. The terminal should confirm that the changes were saved correctly.
3. Next, run the script and follow the prompts on that appear on the terminal. The rover will then actuate on its own.

## Features
* Waypoint-based Navigation
* Waypoint Selection Menu
* Point-Turn capability
* Speed and Heading Control
* Wheel Motor Reversal
* Scientific Analysis Sequence
* Automatic Data scan and Transmission

## Local Deployment Tutorial

1. Execute the quick start guide.
2. Type the following command on the terminal: "RUN rover.script.".
3. When the list of waypoints appears on the terminal, type the number of the waypoint you want to reach.
4. When the rover reaches the target waypoint, it will automatically execute the scientific analysis sequence and transmit all found data.
5. After this is completed, the rover will re-check if the brakes are applied and end the script.

## Version Information

### Requirements

* Kerbal Space Program: v1.12.5.3190
* Breaking Ground DLC: v1.7.1
* kerbal Operation System: v1.6.0.1
* Dependencies of each mod installed: latest compatible version

### Recommendations

* Infernal Robotics-Next: v3.1.22
* kOS for All!: v0.0.5 (stable release) 

## How the script works

### Waypoint-based Navigation

When first started, the program searches for all waypoints within the planet the rover is located.
If at least one is found, the terminal prints a coded UI and a list of the found waypoints with their names.
After the list appears on the terminal, its length is determined by the number of waypoints found.
The program orders the waypoints by alphabetical order and numbers them as so starting from 0 all the way to the last found waypoint.
Then, the user is required to simply enter the number of the desired waypoint to target. 
If no waypoint is found, the program asks to set a waypoint on the current planet and ends.

### Main Control Function

The program's main control loop is structured to remain in the heading range, no matter what obstacle the rover is moving through.
While cruising, the rover uses normal steering corrections to stay on course.
If, for some reason, the rover exits its target heading range, the point-turn function is activated.

### Point-Turn Function

After a waypoint is found and targeted, the autopilot initiates its operating sequence.
The program scans for the heading it needs to target in order to reach the selected waypoint.
If the target heading is more than 1 degree away from where the rover is facing, it starts the point-turn sequence.
The rover rotates its front and rear wheels and starts rotating until the rover's heading is within a 1 degree range of the target.
After the rover is within this range, the brakes are applied, stopping the point-turn. Then, the rover rotates its wheels back to normal.
If the rover is already within the target heading range, it simply adjusts its heading with normal steering.

### Speed Control Function

The rover's speed control function is designed to maintain its ground speed between 1.0 and 2.0 m/s.
If its speed is lower than 1.0 m/s, it speeds up. If its speed is higher than 2.0 m/s, it applies the brakes.
This function has this range for safety reasons, because the rover is completely autonomous and any unexpected event may result in a crash.

### Wheel Reverse Function (Under development, test, and fix)

The wheel reverse function is programmed to set all the wheels from one side of the rover to reverse.
The main idea of this function is that, upon performing a point-turn, certain wheels are reversed, contributing to better rotation.
After a point-turn is completed, the reversed wheels should return to normal direction. Therefore, the rover should drive normally.

### Scientific Analysis Function

This function has various aspects. These include performing analysis with a laser camera; extending, maneuvering, and retracting a robotic arm that drills and stores a sample; activating multiple scientific devices; and transmitting all collected data.
This sequence structure is engineered by adequately managing action groups, Kal-1000 controllers, and "WAIT" commands.
Every action group activates a Kal-1000 controller that performs a certain animation that acts either on the laser camera or on the robotic arm.
The action groups activated also trigger "WAIT" commands that force the program to stop until the Kal-1000's animations are completed.
Then, another action group activates various scientific instruments that gather readings that are stored on-board for transfer.
The sequence then commands to drill a sample from the soil, store it, and retract the robotic arm back to its rest/drive position.
After the arm is done retracting, the program continues the function's structure and starts the data transmission procedure.
The program then searches for scientific modules on the rover that have data, and starts transmitting data.

Once transmission is done, the program re-checks that the brakes are enabled and ends the sequence.

The program's use is intended to be for controlling a NASA rover -such as Curiosity or Perseverance- in a completely autonomous way inside Kerbal Space Program.
For adequate operation, the user's Kerbal Space Program install requires Breaking Ground DLC and the kerbal Operating System (kOS) mod (accompanied by the kOS for All! mod for kOS enabling on all probe cores). It is also recommended to have installed the latest version of all.

## Optional characteristics:
* Robotic servos that steer the front and rear wheels 45 degrees towards the rover, Rocker-Bogie suspension for better handling under harsh terrain and slopes, large electricity reservoir and generator, and a robotic arm with various scientific instruments and a drill (included with Infernal Robotics-Next). 
