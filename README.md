# Brake-Light-Controller-Design
Design a brake light controller for the next generation of vehicles.

## Design Requirements
### The tail lights shall be visible in bright sunshine:
> For daytime illumination (when the headlights are turned off), the brake and turn signal light intensity shall
be 100%. The tail light illumination shall be 0% when the brake and turn signals are disabled and the 
headlights are off. 

### The tail light illumination intensity shall be reduced at night:
> For nighttime illumination (when the headlights are turned on), the brake and turn signal light intensity 
shall be 50%. The tail light illumination shall be 10% when the brake and turn signals are disabled and 
the headlights are on.

### Turn signals shall present a consistent flashing pattern:
> The turn signal period shall be 1.5 seconds, with the tail light illuminated at the high intensity level for 0.75
second and illuminated at the low intensity level for 0.75 second. Upon application of the turn signal, the 
high intensity illumination shall begin within 2 mS. Upon removal of the turn signal input, the turn signal 
shall not terminate until after the 0.75 second high intensity illumination period has expired. When the 
emergency flashers are are (which is indicated by both the left and right signal inputs being on), both tail 
lights shall flash in unison.

### The controller shall use the following interface:
> Four control inputs shall be used to determine the illumination of the tail lights: LIGHTS (1 = headlights 
on), BRAKES (1 = brake pedal applied), LTURN (1 = left turn signal enabled), RTURN (1 = right turn signal 
enabled). Two outputs shall be generated; one that controls the tail lights on the left side of the vehicle 
(LEFT), and one that controls the tail lights on the right side (RIGHT).

## Design Considerations
LEDs are normally either fully on or fully off; however, there are two ways to change the apparent 
brightness of the LED. One is to select from a set of current limiting resistors on the board. The second 
method digitally controls the brightness of the LED by varying the duty cycle of the voltage that is applied 
to the LED, which is known as Pulse Width Modulation (PWM). The PWM technique is what we will use 
for this project, which works as follows:
One design consideration to take into account for a PWM signal is the period at which the generator runs.
Although the human eye cannot perceive individual frames of a movie above approximately 24 frames per
second, it can perceive flicker at a much higher rate. Indeed, the eye is more sensitive to flicker in the 
periphery than straight on (this is probably a survival trait). Early vehicles that used PWM to control tail 


## Design simulation and testing
The controller design will be proven out on a Nexys 4 board. The master clock rate on the board is 
100 Mhz. This will not be the clock rate used in the vehicle, since a 100 MHz clock would cause channel 
quieting in the FM band and affect the performance of the vehicle’s radio. You will need to create a clock 
divider that uses a generic to set the divide rate. Since the PWM generator runs at a period of 2 kHz, this 
divider will need to produce a clock enable pulse train that runs at a rate equal to 2 kHz times your PWM 
resolution count. Therefore, for a PWM generator with a period of 2 kHz with a resolution of 1%, the clock
enable would need to run at 200 kHz (100 × 2 kHz).
