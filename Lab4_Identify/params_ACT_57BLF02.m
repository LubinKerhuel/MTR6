%% params_ACT_57BLF02.m  --  ACT 57BLF02 PMSM simulation parameters (USER-TUNABLE)
% Run this before opening / simulating Custom_PMSM.slx  (it is also the model PreLoadFcn).
% Edit any value below and re-run to retune the simulated motor. All quantities are SI.
%
% These are the parameters IDENTIFIED from the 20 kHz external-mode logs; see the report
% (report/pmsm_identification_report.pdf) and the journal (id_logs/ident_run.log) for provenance.
% They are also regenerated automatically by the identification analyzer (analyze_motor_log ->
% write_params_m), so re-running an identification overwrites this file with fresh values.
%
% CROSS-CHECK 2026-07-22 against the OPEN-LOOP V/f log (Log_2026_07_22.mat, triangular 0->50->0 Hz
% elec frequency sweep). That log's SPEED IS FORCED open-loop and the rotor STALLS below ~13 Hz
% (locked only for t in [8.3, 26.7] s), so it is a POOR direct source for plant parameters -- see
% compare_replay.m / build_replay_compare.m and the findings below. What it DID confirm (see the
% VERIFIED tags on Rs and psi): Rs and psi are consistent with the datasheet; no change warranted.
% It also produced a useful OPERATING-LIMIT datum (pull-out/sync envelope), recorded at the bottom.

%% ------------------------------------------------------------------ motor (surface PMSM)
% TWO-STAGE identification (2026-07-18): Stage 1 fits the ELECTRICAL params alone from the
% fundamental voltage balance |V|=psi*we+Rs*|I| (PLAIN-PWM voltage 0.5*V_bus*q, MEASURED V_bus),
% then FREEZES them; Stage 2 fits the mechanical/load with the electrical fixed. Fit resid 0.094 V
% on 6.2 V (1.5%); cross-validated on session 1 (FOC) at 16.5%.
p    = 4;          % pole pairs                                             [-]
% R,L RE-IDENTIFIED from the log via the full dq equations across the SPEED RAMP (fundamental,
% high-SNR; back-EMF-derived rotor angle; incl. L*di/dt transient terms) -> R2=0.982. The ramp
% acts as a frequency sweep giving the omega*L leverage, and the six-step naturally injects d-axis
% current (<id>=-1.3A) making L observable. Agrees with datasheet (Rs 0.267, synchronous Ls-M~2e-4).
Rs   = 0.251;      % stator resistance (log full-dq fit; datasheet 0.2672 per-phase)      [ohm]
                   % VERIFIED 2026-07-22: V/f active-power balance over the synced sweep gives
                   % Rs ~ 0.25-0.31 ohm (upper bound - open-loop over-fluxing adds iron loss),
                   % straddling this value and datasheet 0.267. Kept unchanged.
Ls   = 1.9e-4;     % SYNCHRONOUS inductance Ls-M (log full-dq fit; datasheet per-phase 1.35e-4,
                   % Ls-M ~ 1.5*Ls ~ 2.0e-4; this is the value the dq/alphabeta model needs)  [H]
                   % NOTE 2026-07-22: Ls is NOT identifiable from the V/f log -- at these speeds the
                   % back-EMF term dominates the voltage balance and R,L have no leverage; fitting L
                   % returned unphysical/negative values (artifact of the unknown open-loop load
                   % angle). Kept at the datasheet-coherent dq value.
Ld   = Ls;         % d-axis inductance                                       [H]
Lq   = Ls;         % q-axis inductance                                       [H]
psi  = 9.2386e-3;  % PM flux linkage (Stage-1 fit; nom 9.056e-3, +2%)        [Wb]
                   % VERIFIED 2026-07-22: back-EMF |E|=psi*we regressions BRACKET the datasheet
                   % (V/f 8.78e-3, Hall-ramp 1.05e-2, datasheet 9.056e-3); this value sits inside
                   % the bracket and within 2% of nominal. Kept unchanged.

%% ------------------------------------------------------------------ mechanical load
% Base friction/loss identified from the COAST-DOWN maneuver (no drive) -> free-spin
% bearing + windage + iron only. The friction seen during a LOADED run is larger; the
% shipped B/Kw below are the loaded operating point. For an UNLOADED sim, use B0_id/Kw0_id.
J    = 1.40e-4;    % rotor inertia                                          [kg.m^2]
B0_id = 3.99e-4;   % viscous friction (+ iron loss, effective) - coast-down  [N.m.s]
T0_id = 5.0e-3;    % dry / Coulomb friction (+ constant load, lumped)        [N.m]
Kw0_id= 5.52e-6;   % quadratic (windage) loss - coast-down                   [N.m.s^2]
% STAGE 2 load fit (electrical FROZEN at Stage 1): Te=Kt*|I| (Kt from fitted psi) regressed vs
% mechanical speed, near-steady points: T = B*wm + Kw*wm^2 + T0,  R^2=0.998. Viscous-dominated
% (generator/eddy-brake). Ship the OPERATING load (the log was taken loaded); coast-down free-spin
% values kept above (B0_id/T0_id/Kw0_id) for an unloaded sim.
B    = 1.050e-3;   % viscous load  (Stage-2 fit, electrical frozen)          [N.m.s]
Kw   = 3.255e-6;   % windage load  (Stage-2 fit)                             [N.m.s^2]
T0   = 1.13e-2;    % Coulomb / constant load (Stage-2 fit)                    [N.m]
% NOTE: J is NOT identifiable from session 3's slow ramp (accel torque ~0.004 Nm, in the noise);
% kept at the coast-down value. To identify J, run the fast-step V/f sequence (design_vf_sequence.m).
%
% NOTE 2026-07-22 (V/f log did NOT improve the load params -- kept unchanged): a naive load fit on
% the V/f sweep looked great (R^2=0.995) but is BIASED HIGH. Open-loop V/f runs heavily over-fluxed
% (recovered d-axis current ~ -4.2 A), so its (Pe - Rs*I^2)/wm air-gap torque double-counts d-axis
% copper + iron loss that produces NO torque. The clean electromagnetic torque (1.5*p*psi*iq, true
% rotor frame) of the V/f run is ~2x the efficient Hall-ramp curve at the same speed -- a different
% (over-fluxed) operating condition, not a better load estimate. The Hall-ramp (id ~ -1.3 A, near
% efficient) remains the authority for the shipped LOADED B/Kw/T0. See figs/load_curve_AB.png and
% figs/load_curve_clean.png; the A/B replay in compare_replay.m confirms the V/f load values do NOT
% improve (and slightly worsen) the Hall-ramp current match.

%% ------------------------------------------------------------------ Hall sensor
phi            = -1.8801;                                   % Hall mounting offset (-107.7 deg) [rad]
hall_edges_deg = [0 65.71 135.73 177.83 247.84 315.85];     % measured sector-start angles      [deg elec]
hall_seq       = [4 6 2 3 1 5];                             % Hall index per sector             [-]

%% ------------------------------------------------------------------ inverter / bus
Vdc   = 24;        % DC-bus voltage                                          [V]
Vbase = Vdc/2;     % modulation voltage base (Vdc/2, intersective PWM)       [V]

%% ------------------------------------------------------------------ simulation
Ts    = 50e-6;     % base control step / fixed-step solver period (ode3, 20 kHz)     [s]
Tstop = 30;        % default stop time                                       [s]

%% ------------------------------------------------------------------ derived (do not edit)
Kt = 1.5*p*psi;    % torque constant  Te = Kt * iq                           [N.m/A]

fprintf('params.m loaded: ACT 57BLF02  p=%d Rs=%.3f L=%.2e psi=%.3e Kt=%.4f  Vbase=%.0f V\n', ...
        p, Rs, Ld, psi, Kt, Vbase);

wth = 1.0;   % rad/s  smooth-Coulomb speed threshold (friction regularisation)

tau_l_ext = 0;   % N.m   external load torque (edit or replace the Load block with a signal)

%% ---- speed-force option (Custom_PMSM_LK): 1 = impose we_forced, 0 = torque-driven (default) ----
we_force_en = 0;   % set 1 and drive the PMSM Motor 'we_forced' input to run in speed-forced mode

%% ---- replay (Replay_Log): 1 = use MEASURED Hall from the log, 0 = SIMULATED Hall from the plant ----
hall_use_meas = 1;

%% ---- replay session (Replay_Log): 1 = open-loop FOC-10Hz, 3 = Hall-looped ramp ----
replay_session = 3;

%% ---- replay choice (Replay_Compare / prep_replay): 1=FOC-10Hz, 2=Hall ramp, 3=V/f ramp ----
replay_choice = 3;

%% ------------------------------------------------------------------ operating limits (informational)
% OPEN-LOOP V/f pull-out / synchronization envelope, from Log_2026_07_22.mat (triangular 0->50->0 Hz
% elec sweep, kvf ~ constant-flux). The rotor tracks the commanded angle only while locked; it STALLS
% (loses sync, chaotic current) below ~13 Hz elec. Locked window in that log: t in [8.3, 26.7] s.
% Use for choosing a safe open-loop V/f start frequency, NOT as a plant parameter.
vf_sync_fmin_hz = 13;   % min elec frequency that stays synchronized in open-loop V/f (this rig/load)
