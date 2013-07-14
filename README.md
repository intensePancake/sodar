<h2>SODAR sensing</h2>

Arduino and Processing code that can be used in tandem to sense objects within 300cm of a PING))) ultrasonic sensor spinning on top of a stepper motor.

This code was written for the DIY SODAR device instructable that can be found at <a href="http://www.instructables.com/id/DIY-360-Degree-SODAR-Device/">http://www.instructables.com/id/DIY-360-Degree-SODAR-Device/</a>.

<h3>The Processing Console</h3>

We wrote a basic console for our project that you can contribute to if you would like to. Here are the stuff we have already added:

<ul>
  <li><b>Tab completion</b>: This works by taking an array of strings that include all functions (that are in the list), and adding them to a k-mer tree where every node contains one character. Pressing tab goes to the first end node available in the tree.</li>
  <li><b>Up and down arrows</b>: Cycle through previous queries.</li>
  <li><b>speed/rpm</b>: Changes the speed of the motor if "(x)" specified. Using "()" sets it back to default. If the command is just "rpm" or "speed", it returns the current speed of the motor</li>
  <li><b>pps</b>: Pings per second. This will change the pings the sensor does per second if a value (x) is specified. Using "()" sets it back to default. If just "pps", it will return the current value.</li>
  <li><b>history</b>: With (x), changes the # of previous commands kept in memory. Using "()" sets it back to default. Just "history" returns the current value.</li>
  <li><b>move</b>: With (x): sets relative angle of motor to x. With (): Allows you to click a desired angle, which the motor will then move to. </li>
  <li><b>clear</b>: clears the console without deleting entire history</li>
  <li><b>stop</b>: stops the motor</li>
  <li><b>start</b>: starts the motor</li>
  <li><b>exit</b>: exits processing</li>
  <li><b>help</b>: Not actually written because we couldn't fit it into the few lines we had to hopefully this suffices</li>
