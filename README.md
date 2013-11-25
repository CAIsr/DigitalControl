Digital Control (Mac)
=============

Digital Remote Control Application is an open source MAC application which allows the user to take control of photography remotely. The original idea of this application is for serial block-face imaging (generate high resolution three-dimensional images from brain sample) but the application is not limited to other purpose. This application required a server which is also developed by Centre for Advanced Imaging. Please refer to following link (Digital Control Server): https://github.com/NIF-au/DigitalControlServer
<BR/><BR/>
Note: Current version is only supported by USB 2.0. There is an issue with USB 3.0 (libusb support issue in BananaCam). In order to make it works, please connect your Camera to your computer using USB 2.0 then run BananaCam before start up Digital Control.

## Interface
The interface contents several key environments. Centre penal is a main control interface for cameras. It contents base control and liveview support. Left penal is a message (log) penal. It provides information and log to users while triggering any camera functions. Right penal is a file and image viewer. It shows image location and provides based image editor. 
<BR/>
<IMG SRC="https://dl.dropboxusercontent.com/u/24447938/DigitalControl.png" ALT="DigitalControl" WIDTH=600 HEIGHT=350>

## Functions

Remotely: 
    Using the USB 2.0 for select models (1700 models supported and be found in http://www.gphoto.org/proj/libgphoto2/support.php), Digital Control enables you to capture unique images no matter what the subject. The current development has only been tested with Nikon and Canon cameras.
<BR/><BR/>
LiveView Support: 
    Live previews direct from the camera are supported on selected cameras when this feature is enabled. See what you are about to shoot! 

## Dependency
The software depends on the following libraries:
	libgphoto2 and libusb
with frameworks:
	IOKit; CoreFundation; QTKit and OpenGL
