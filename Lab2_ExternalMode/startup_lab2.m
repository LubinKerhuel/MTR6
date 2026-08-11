% startup_lab2  (SCRIPT, run from the Lab2 model PreLoadFcn)
% Path-independent: all files referenced by absolute path; no addpath needed.
% Lab 2 tunable parameters - changed LIVE over External Mode, no rebuild.
Blink_rate = 5;      % LED blink frequency [Hz]   try 1 .. 20
ADC_gain   = 1;      % scaling on the POT reading  try 1 .. 4
lpf_a      = 0.05;   % Live LPF coefficient        try 0.01 (smooth) .. 0.5 (sharp)
disp('Lab2 ready - External Mode. Open Lab2_ExtMode_hw.slx and read the two cards on the canvas.');
disp('  Live tuning : Microchip toolstrip -> Ext Mode settings -> Monitor & Tune.');
disp('  To tune     : change the variable here, then press Ctrl+D. Nothing is sent until you do.');
disp('               (already Tunable - no rebuild, no reflash needed)');
