# Sample Grid for Sonic Pi

A Sample Grid Sequencer for Sonic Pi controlled by a TouchOSC interface

## Interface

### Grid Screen

![Sample Grid Interface: Grid](touchosc-sample-grid-grid.png?raw=true "Sample Grid Interface: Grid")

1. **Row and Sample Selector**: The sequencer LEDs (4) will follow this row. The sample options (see: sample option screen) will apply to this row/sample. Same as no. 1 of sample option screen.
2. **Grid**: One horizontal row represents one of 16 slices of a sample. You can toggle if a slice should be played or not. To play the whole sample click on all 16 buttons of a row.
3. **Mute Row**: Mutes all buttons/sample slices of the respective row.
4. **Sequencer LEDs**: Gives feedback which slice is being played. Represents the sample which is currently selected by (1). Same as no. 8 of sample option screen.

### Sample Option Screen

![Sample Grid Interface: Individual Sample Options (per Grid Row)](touchosc-sample-grid-sample.png?raw=true "Sample Grid Interface: Individual Sample Options (per Grid Row)")

1. **Row and Sample Selector**: The sequencer LEDs (8) will follow this row. The sample options (see: sample option screen) will apply to this row/sample. Same as no. 1 of grid screen.
2. **Rotary Controllers for Sample different Options**: amp, lpf, hpf, attack, sustain, pitch, rpitch, window_size/pitch_dis/time_dis (only applied if pitch is used).
3. **Sequencer Direction**: forward, reverse, random.
4. **Time Resolution**: 1 = default meaning `sleep 0.5` between each sample slice. 0.5 = multiply with 0.5, 2 multiply with 2 aso.
5. **Beat Stretch**: Beat stretch.
6. **Number of Slices**: Num slices. Note: if you check all buttons of a row the sequencer will play 16 slices if set to 16; if you set this option to less than 16 the sample slices will start overlay each other (which can give very nice sounds).
7. **Rate**: Rate. Note: Beat stretch and rate will both manipulate pitch and can suspend or augment each other.
8. **Sequencer LEDs**: Gives feedback which slice is being played. Represents the sample which is currently selected by (1). Same as no. 4 of grid screen.


## Quickstart

To start and try out the application adjust the following parameters at the top of `touchosc-sample-grid.rb`. IP and PORT of device running TouchOSC and path to direction from which the first 8 samples will be choosen to populate the grid:

```
# /// Quickstart for Configuration //////////////////////////////////////////////
# Set the following parameters and ...
#
# IP of Device running TouchOSC
set :ip, "[IP]" # e. g. 192.168.2.114
# Port configured on device running TouchOSC
set :port, [PORT] # e. g. 9000

# path to sample folder (at the moment first 8 samples will be taken)
set :path, "Path/to/your/sample/for/grid/control/"
#
# ... leave everything after here as it is.
# \\\ Quickstart for Configuration \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

```
