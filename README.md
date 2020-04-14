# The Caltech Cassie Documentation Repository
This serves as the central repository for the publicly released operational instructions and installation scripts for the Caltech Cassie biped project. If you use our code, please throw us a citation or acknowledgement (relevant papers listed below).

Review the documentation here thoroughly before pulling our other repos and trying to use them on your robot, we provide helpful instructions and examples for how to set up your Linux development computer for testing in Gazebo or to prepare the Intel NUC on the actual Cassie hardware as we have done.

*Note: This current release is organized around a C++ implementation for modeling and control of dynamic crouching motions. A MATLAB, Simulink, and C++ implementation of our walking controller, along with an example of the associated trajectory optimization is expected to be released sometime summer 2020.*

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
First, we recommend purchasing and using two small accessories, which will make your life significantly easier. A [network switch](https://www.amazon.com/dp/B074VZ236M/ref=twister_B074W7YZY3?_encoding=UTF8&psc=1) will allow you to connect the Simulink xPC with the NUC, and still leave an additional connection for you to directly connect and subscribe to the ROS network on a development computer. Also, a USB splitter will let you connect peripherals easily to the already exposed ports on the top of Cassie's pelvis. Finally, we drilled a small hole along the top of the back cover of the robot, so that we could run an ethernet cable to a monitor from the NUC.  

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


### Development Computer

The packages are built around a ROS framework, we recommend following the instructions for installing the Desktop version of [ROS Melodic](http://wiki.ros.org/melodic/Installation/Ubuntu) if you used Ubuntu 18.04, or if using an older version using [ROS Kinetic](http://wiki.ros.org/kinetic/Installation/Ubuntu). *Note: We have only tested on hardware with Melodic, however, there does not appear to be any compatability issues in simulation for Kinetic.*

and then install several necessary packages
``` bash
sudo apt install libeigen3-dev libyaml-dev build-essential ros-melodic-gazebo-ros
```

If you plan to run Gazebo simulations, you will also need to add the following lines to the `.bashrc` or `.bash_aliases` file to ensure that it can find the associated model and plugin.
``` bash
export GAZEBO_PLUGIN_PATH=${HOME}/cassie_ws/devel/lib/:$GAZEBO_PLUGIN_PATH
export GAZEBO_MODEL_PATH=${HOME}/cassie_ws/src/cassie_description/:$GAZEBO_MODEL_PATH
```
If you open another terminal before finishing the instructions below then you will see an error when it executes the command. After building `cassie_ws` they should go away.

Create a separate install space for third party repositories we are going to install, and install the [RBDL](https://rbdl.github.io/) package with the optional URDF parser
``` bash
mkdir ~/repos
cd ~/repos
git clone https://github.com/rbdl/rbdl.git
mkdir ~/repos/rbdl/build
cd ~/repos/rbdl/build
cmake -D CMAKE_BUILD_TYPE=Release -D RBDL_BUILD_ADDON_URDFREADER=true  -D RBDL_USE_ROS_URDF_LIBRARY=false ../
make
sudo make install
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
catkin_make -D CMAKE_BUILD_TYPE=Release
```


## Related literature:
* Reher, Jenna, Claudia Kann, and Aaron D. Ames. "An Inverse Dynamics Approach to Control Lyapunov Functions." arXiv preprint arXiv:1910.10824 (2019).
```
@article{reher2019inversedynamics,
  title={An Inverse Dynamics Approach to Control {Lyapunov} Functions},
  author={Reher, Jenna and Kann, Claudia and Ames, Aaron D},
  journal={arXiv preprint arXiv:1910.10824},
  year={2019}
}
```

* Reher, Jenna, Wen-Loong Ma, and Aaron D. Ames. "Dynamic walking with compliance on a cassie bipedal robot." 2019 18th European Control Conference (ECC). IEEE, 2019.
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
