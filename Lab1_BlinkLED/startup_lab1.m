% startup_lab1  (SCRIPT, run from the Lab1 model PreLoadFcn)
% Path-independent: all files referenced by absolute path; no addpath needed.
disp('Lab1 ready - Blink an LED.');
disp('  Part A  : open Lab1_LED_SIM_START, Run, then drop Compare To Zero on the wire.');
disp('  Part B  : add Microchip Master (chip dsPIC33AK512MC510, 200 MIPS) + Digital Output Write E2, then Build.');
disp('  Answers : Lab1_LED_SIM_SOLUTION (Part A), Lab1_LED_HW_REFERENCE (Part B).');
disp('  Optional: Lab1_LED_FADE_DEMO (fading LED, PWM dimming).');

url = ['https://mplab-blockset.github.io/MPLAB-Device-Blocks-for-Simulink/tools/dim_viewer/#dim=dsPIC33AK512MC510&bb=MCLV&sort=function&grp=1&alt=0&mc=1'];
fprintf('  Board pinout link: <a href="matlab:java.awt.Desktop.getDesktop().browse(java.net.URI(''%s''))">%s</a>\n', url, url);
