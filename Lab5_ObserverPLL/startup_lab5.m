% startup_lab5  (SCRIPT - run once before opening the Lab5 models)
% Loads all Lab5 parameters into base. Load order matters: motor plant -> observer -> FOC controller.
%   1) params_ACT_57BLF02.m  - ACT 57BLF02 PMSM plant (p, Rs, Ls, psi, Kt, Vbase)
%   2) obs_params.m          - PLL observer gains (also re-runs params, forces Ts = 1/20e3)
%   3) foc_ctrl_params.m     - current/speed PI, I-f startup, saturations
% Path-independent: all files are referenced by absolute path; no addpath needed
% (run from the lab folder; PMSM_Motor_sref is copied into each lab that needs it).
d = fileparts(mfilename('fullpath'));

run(fullfile(d,'params_ACT_57BLF02.m'));   % 1) plant
run(fullfile(d,'obs_params.m'));            % 2) PLL observer (sets Ts = 50 us, 20 kHz)
run(fullfile(d,'foc_ctrl_params.m'));       % 3) FOC controller + I-f startup

disp('Lab5 ready - PLL sensorless observer.');
disp('  Simulation : open PLL_FOC_Simulation_single.slx  and run (3 s).');
disp('  Hardware   : open PLL_FOC_33AK512MC510_MCLV_48V.slx (student) or');
disp('               PLL_FOC_33AK512MC510_MCLV_48V_solution.slx (solution),');
disp('               build with Ctrl+B, tune live via Microchip toolstrip -> Monitor & Tune.');
