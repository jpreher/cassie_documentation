# The Caltech Cassie Documentation Repository
This serves as the central repository for the publicly released operational instructions and installation scripts for the Caltech Cassie biped project. If you use our code, please throw us a citation or acknowledgement (relevant papers listed below).

Review the documentation here thoroughly before pulling our other repos and trying to use them on your robot, we provide helpful instructions and examples for how to set up your Linux development computer for testing in Gazebo or to prepare the Intel NUC on the actual Cassie hardware as we have done. If you are unsure of how to modify part of the existing code, or if the gains and controllers which are provided here are having problems, feel free to raise a issue here or reach out: jreher@caltech.edu.

[<img src="https://www.jennareher.com/s/cassie_crouch_clf.gif" width="40%">](hthttps://youtu.be/bzCYE3DETMI) 

[<img src="https://www.jennareher.com/s/cassie_inverse_dynamics.gif" width="40%">](https://youtu.be/SvhjPZqSGFI)

*Note: The C++ version of our walking controller has been released within the cassie_controllers repo. Our HZD trajectory optimization will be released soon.*

## Description of associated repositories:
Below is a list of all packages used for the Caltech controller implementation. A general installation procedure is detailed lower in this README. For package specific instructions if you are looking to modify the code, please see the instructions in each repo.

* [Amber Developer Stack](https://github.com/jpreher/amber_developer_stack): This is a set of general base utilities. These are primarily focused on debugging, wrappers for various things such as YAML, Eigen, and qpOASES, and general utilities which are not necessarily Cassie specific.
* [Cassie Description](https://github.com/jpreher/cassie_description): Contains all necessary files for running the MATLAB codegen for the Cassie model. It also has classes for MATLAB and for C++ with several general functions to compute the constraints, dynamics, and kinematics efficiently.
* [Cassie Common Toolbox](https://github.com/jpreher/cassie_common_toolbox): This is a common set of utilities and helper functions that are specific to Cassie.
* [Cassie Interface](https://github.com/jpreher/cassie_interface): Contains the launch files for starting up the various processes. Also has the primary ROS node, which interfaces to the Simulink xPC via UDP and listens for control inputs to pass along.
* [Cassie Estimation](https://github.com/jpreher/cassie_estimation): Contains functionality for estimating the heelspring deflections, contacts, and linear velocity.
* [Cassie Controllers](https://github.com/jpreher/cassie_controllers): The main control code which chooses the torques to send to the robot.

## Setting up a computer for using the packages:
This section will first detail the setup of a fresh Intel NUC computer, assuming that it has not yet been used. If you have already established your NUC, feel free to follow along with the instructions, and see if there are any additional steps that would be helpful to implement. If you are looking to just run the controller on a Linux computer in simulation or for development, you can skip the Intel NUC on Cassie section, and start with the Development Computer section.

### Intel NUC on Cassie
First, we recommend purchasing and using two small accessories, which will make your life significantly easier. A [network switch](https://www.amazon.com/dp/B074VZ236M/ref=twister_B074W7YZY3?_encoding=UTF8&psc=1) will allow you to connect the Simulink xPC with the NUC, and still leave an additional connection for you to directly connect and subscribe to the ROS network on a development computer. Also, a USB splitter will let you connect peripherals easily to the already exposed ports on the top of Cassie's pelvis. Finally, we drilled a small hole along the top of the back cover of the robot, so that we could run an HDMI cable to a monitor from the NUC.  

Assuming that the computer does not yet have an OS, we recomend using [Ubuntu 18.04](http://releases.ubuntu.com/18.04.4/). Install accordingly, and choose the minimal installation and automatic login options. Once the OS is installed, we want to ensure that the machine boots into Console mode and does not run graphics. This will save additional overhead and help the controller run more smoothly, since our current implementation is only soft real-time. To do this, simply open a terminal and set
``` bash
sudo systemctl set-default multi-user.target
```
At any point, if you would like to pull up the GUI mode, you can do that by just running
``` bash
sudo systemctl start gdm3.service
```
If you have already installed or prefer lightdm, this would just be `sudo lightdm start`. As a side note, you can also work in multiple terminals simultaneously while in this mode. Simply press `CTRL+ALT+F(1-6)` and this will switch between six distinct terminals. You will see the current terminal `tty(1-6)` at the top of your screen.

If you have not been working on the NUC already, the minimal installation is likely not running unnecessary background processes. However, if you have, you may want to disable all unncessessary boot and background processes which may interfere with the controller. We also recommend disabling bluetooth, and possibly the wifi after you have installed all packages (though we have not had any issues leaving the wifi connected). You will be able to tell that you are having timing issues is there are small 'pops' in the controller, or if you look at the timing data from the logger and see greater than 5-10% jitter in the loop frequency.

As a final step, you should also install the [PREEMPT_RT kernel](https://rt.wiki.kernel.org/index.php/Main_Page). This will be useful for mitigating timing issues when we are later elevating our controller and interface nodes into real-time priority.

For the Simulink xPC, our code is built around using a UDP connection as Agility Robotics had built out some support for this functionality. You can simply go to their software page [here](https://github.com/agilityrobotics/cassie-doc/tree/master/Software) and use their `UdpRealTime` controller. We have specified the network address in [cassie_interface.cpp](https://github.com/jpreher/cassie_interface/blob/e9230be69e1300bea12b9643510c64d4795e582c/src/cassie_interface_node.cpp#L109), please ensure that this address matches what is in your compiled Simulink code as it is different from their default. Agility had a version which can be edited and compiled in their code examples folder.


### Development Computer

The packages are built around a ROS framework, we recommend following the instructions for installing the Desktop-Full version of [ROS Melodic](http://wiki.ros.org/melodic/Installation/Ubuntu) if you used Ubuntu 18.04, or if using an older version using [ROS Kinetic](http://wiki.ros.org/kinetic/Installation/Ubuntu). *Note: We have only tested on hardware with Melodic, however, there does not appear to be any compatability issues in simulation for Kinetic, you will just need to manually upgrade a few packages as shown below.*

and then install several necessary packages
``` bash
sudo apt install libeigen3-dev libyaml-dev build-essential ros-melodic-gazebo-ros
```
If you are using Kinetic, you will need to remove Gazebo7 and manually install Gazebo9
``` bash
sudo apt remove ros-kinetic-gazebo* gazebo*
sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
sudo apt update
sudo apt install ros-kinetic-gazebo9-*
sudo apt upgrade
```

If you plan to run Gazebo simulations, you will also need to add the following lines to the `.bashrc` or `.bash_aliases` file to ensure that it can find the associated model and plugin.
``` bash
export GAZEBO_PLUGIN_PATH=${HOME}/cassie_ws/devel/lib/:$GAZEBO_PLUGIN_PATH
export GAZEBO_MODEL_PATH=${HOME}/cassie_ws/src/cassie_description/:$GAZEBO_MODEL_PATH
```
If you open another terminal before finishing the instructions below then you will see an error when it executes the command. After building `cassie_ws` they should go away.

Create a separate install space for third party repositories we are going to install, and install the [RBDL](https://rbdl.github.io/) package with the optional URDF parser. 
``` bash
mkdir ~/repos
cd ~/repos
git clone https://github.com/rbdl/rbdl.git
sed -i 's/boost::shared_ptr/std::shared_ptr/g' ~/repos/rbdl/addons/urdfreader/urdfreader.cc # ONLY RUN THIS LINE IF USING UBUNTU 18.04
mkdir ~/repos/rbdl/build
cd ~/repos/rbdl/build
cmake -D CMAKE_BUILD_TYPE=Release -D RBDL_BUILD_ADDON_URDFREADER=true ../
make
sudo make install
```
If you are using Ubuntu 16.04 then you will need to install a newer version of Eigen (>3.3) than comes with ROS Kinetic *(i.e. you only need to do this if using 16.04)* - This is a temporary fix until a better solution is found for the Eigen 3.3 unsupported packages
``` bash
cd ~/repos
curl https://gitlab.com/libeigen/eigen/-/archive/3.3.7/eigen-3.3.7.tar.gz | tar -xz
mkdir ~/repos/eigen-3.3.7/build
cd ~/repos/eigen-3.3.7/build
cmake ..
sudo make install
sed -i 's/Eigen\/EulerAngles/eigen3\/unsupported\/Eigen\/EulerAngles/g' ~/cassie_ws/src/cassie_common_toolbox/include/cassie_common_toolbox/geometry.hpp
```


Create the catkin workspace where our code will live
``` bash
mkdir ~/cassie_ws
mkdir ~/cassie_ws/src
cd ~/cassie_ws/src
catkin_init_workspace
```
then clone all of the necessary repositories
``` bash
git clone https://github.com/jpreher/cassie_description.git
git clone https://github.com/jpreher/cassie_interface.git
git clone https://github.com/jpreher/cassie_controllers.git
git clone https://github.com/jpreher/cassie_estimation.git
git clone https://github.com/jpreher/cassie_common_toolbox.git
git clone https://github.com/jpreher/amber_developer_stack.git
```

Before building, the Cassie model source code needs to either be generated or downloaded and extracted. We detail instructions for populating the code in the `cassie_description` package in the [associated README](https://github.com/jpreher/cassie_description/blob/master/README.md). *Note: If you don't have access to Matlab and Mathematica, or are not interested in modifying the expressions, you can just [download an archive here](https://www.dropbox.com/s/ff3dfvctna8amwy/cassie_description_pregen.zip?dl=0) and extract it into the `cassie_description` folder.*

Then simply build the workspace in Release mode, there should be no errors.
``` bash
cd ~/cassie_ws
catkin_make -DCMAKE_BUILD_TYPE=Release
```

*Note: For running individual simulations in Gazebo of the walking controllers and crouching controller there does not yet exist a simple flag or switch to determine the behavior that you would like. Instead, the corresponding behavior can be commanded to the simulation controller by manually changing a spoofed joystick value in [cassie_interface.cpp](https://github.com/jpreher/cassie_interface/blob/e9230be69e1300bea12b9643510c64d4795e582c/src/cassie_interface_node.cpp#L435)*


## Running the software

The software is launched from two roslaunch files, one for simulation and the other for hardware. 
``` bash
roslaunch cassie_interface cassie_interface_simulated.launch
roslaunch cassie_interface cassie_interface_hardware.launch
```

There is currently a separate launchfile example for running the full locomotion QP controller (standing and walking). To run this instead of the inverse dynamics controller, simply use this launch command instead:
``` bash
roslaunch cassie_interface cassie_interface_walkqp_simulated.launch
```

On hardware this will initialize all control and estimation parameters, as well as boot up the controller node. In simulation this will spawn a Gazebo instance, and link the plugin with our interface node. The controller must be started in a separate terminal window via
``` bash
rosrun cassie_controllers locomotion_node
```
You can also simply modify the launch files to run, or not run the various nodes on launch. This is mainly if you would prefer to have more granular control over what gets started when, or when debugging.

The Gazebo instance will start paused, you can start the simulation by clicking play on the bottom bar. The simulation will then lower Cassie, and then let go of the pelvis entirely. The controller will then simply run the optimization based crouching controller presented presented in our literature below.

If you see `Error in REST request` when launching the Gazebo simulation, simply open the file `~/.ignition/fuel/config.yaml` and change `url: https://api.ignitionfuel.org` to `url: https://api.ignitionrobotics.org`.

I have provided a [script](https://github.com/jpreher/cassie_documentation/blob/master/MATLAB/read_experiment_binary.m) which can be used to plot the data logged from experiments. There are three data files which are produced if the [associated flag is set in the launchfile](https://github.com/jpreher/cassie_interface/blob/255acd667f8fc447c9666cc4327aeeab6340b44b/launch/cassie_interface_hardware.launch#L8): 1) estimation_log.bin (enabled through the flag log_estimation) - this logs almost all data which is passed in and out of the cassie_interface_node, covering kinematic data, and all values from the floating-base, spring, and contact estimators. 2) stand_log.bin (enabled through the flag log_controller) containing all control feedback data from the CLF-QP or ID standing controller. 3) qp_walk_log.bin (enabled through the flag log_controller) containing all control feedback data from the CLF-QP or ID walking controller.


## Related literature:
* Reher, Jenna and Aaron D. Ames. "Inverse Dynamics Control of Compliant Hybrid Zero Dynamic Walking." Submitted to 2021 IEEE ICRA and Robotics and Automation Letters (RA-L).
```
@inproceedings{reher2021inversedynamicswalking,
  title={Inverse Dynamics Control of Compliant Hybrid Zero Dynamic Walking},
  author={Reher, Jenna and Ames, Aaron D},
  booktitle={Submitted to 2021 IEEE ICRA and Robotics and Automation Letters (RA-L)},
}
```

* Reher, Jenna, Claudia Kann, and Aaron D. Ames. "An inverse dynamics approach to control Lyapunov functions." 2020 American Control Conference (ACC). IEEE, 2020.
```
@inproceedings{reher2020inverse,
  title={An inverse dynamics approach to control {Lyapunov} functions},
  author={Reher, Jenna and Kann, Claudia and Ames, Aaron D},
  booktitle={2020 American Control Conference (ACC)},
  pages={2444--2451},
  year={2020},
  organization={IEEE}
}
```

* Reher, Jenna, Wen-Loong Ma, and Aaron D. Ames. "Dynamic walking with compliance on a Cassie bipedal robot." 2019 18th European Control Conference (ECC). IEEE, 2019.
```
@inproceedings{reher2019dynamic,
  title={Dynamic walking with compliance on a {Cassie} bipedal robot},
  author={Reher, Jenna and Ma, Wen-Loong and Ames, Aaron D},
  booktitle={2019 18th European Control Conference (ECC)},
  pages={2589--2595},
  year={2019},
  organization={IEEE}
}
```

* The official Agility Robotics documentation and software release for the Cassie biped.

https://github.com/agilityrobotics/agility-cassie-doc
