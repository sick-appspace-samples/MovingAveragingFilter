## MovingAveragingFilter

Demonstration of applying MovingAveragingFilter on scan data.

### Description

Scan data is loaded from a file in the resources directory and the moving averaging filter is applied to that data. The filtered data is displayed and the difference between the original and the filtered scan is evaluated.

### How to run

This sample may currently be outdated.
Editing the UI might not work properly in the latest version of SICK AppStudio. In order to edit the UI, you can either use SICK AppStudio version <= 2.4.2 or recreate it within the current version of SICK AppStudio by using the ScanView element from the extended control library (available for download).

Starting this sample is possible either by running the App (F5) or debugging (F7+F10). Output is printed to the console and the scan can be seen on the viewer in the web page.
The playback stops after the last scan in the file. To replay, the Sample must be restarted.
To run this sample, a device with AppEngine >= 2.10.0 is required.

### Implementation

To run with real device data, the file provider has to be exchanged with the appropriate scan provider.

### Topics

algorithm, scan, filtering, sample, sick-appspace
