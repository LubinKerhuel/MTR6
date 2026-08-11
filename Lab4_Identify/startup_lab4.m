% startup_lab4  (SCRIPT, run from the Lab4 model PreLoadFcn)
% Path-independent: all files are referenced by absolute path; no addpath needed
% (run from the lab folder; PMSM_Motor_sref is copied into each lab that needs it).
d=fileparts(mfilename('fullpath'));
run(fullfile(d,'params_ACT_57BLF02.m'));
% --- pick ONE experiment by loading its clean log (same standard names in each) ---
load(fullfile(d,'logs','Log_VF_ramp.mat'));   % or Log_FOC_fixed_speed / Log_SixStep_Hall
% generator settings used by the bench-log source subsystem:
Vmag_gen = 2.2;                                   % rotating-vector magnitude (FOC / V/f) [V]
SIXSTEP_VEC = [1 1 -1 -1 -1 1; -1 1 1 1 -1 -1; -1 -1 -1 1 1 1];  % six-step phase pattern (3x6)
disp('Lab4 ready - Replay. log_index selects the matching Vabc generator; run to overlay sim vs real current.');
