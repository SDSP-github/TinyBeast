# TinyBeast FPGA DMA Demo Application #

This application show how to do DA to TinyBeast FPGA boards. The application shows how to do DMA to DDR4 and LSRAM and also measure DMA speed. 

## Building project with CMake and Visual Studio
To build this application, three software should be installed:
### Visual Studio Community Edition
Download and install the latest version of Visual Studio Community edition from [here](https://visualstudio.microsoft.com/vs/community/)   
### CMake
Download and install CMake from [here](https://cmake.org/download/)   
### VCPKG
Download and install vcpkg rom [here](https://vcpkg.io/en/)   
Set an environmental variable called ``` vcpkg_root ``` to point to where the vcpkg is installed, for example in windows:
```
setx VCPKG_ROOT=c:/local/vcpkg
```
Please note that after setting vcpkg, you need to close and reopen all windows that will use the environment variable (for example cmake or command windows) 
### Building project
To build project in visual studio, use cmake.   
open a command windows in the directory that CMakeLists.txt exist and run build_project.bat.  
When project is create, a visual studio solution called TinyBeast_DMA.sln is created in the build directory. Open this solution by double clicking on it, or open visual studio and then from file menu open this file. 
### building executable
In visual studio, right click on   ``` TinyBeastDemo ``` and select "set as start up project" from context menu (mouse right click).






