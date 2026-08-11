%% foc_ctrl_params.m  --  FOC current + speed controller parameters for the SIMPLE sensorless model
% (build_pll_foc_simple). Runs AFTER obs_params.m (which loads the ACT 57BLF02 motor + pll observer).
% Kept minimal and hardware-portable: pole-cancellation current PI, cascade speed PI, one I-f start.

%% ---- control/observer electrical params (lump inverter drop into R, "think wide") ----
Rc  = Rs + 0.03;          % control resistance >= identified Rs (2*Rds_on + shunt ~ 0.03 ohm)   [ohm]
Lc  = Ls;                 % control inductance = synchronous Ls                                 [H]

%% ---- current loop (dq PI, pole-cancellation): closed loop = 1st-order @ fc_i ----
fc_i = 1000;              % current-loop bandwidth (<< 20 kHz)                                   [Hz]
wc_i = 2*pi*fc_i;
Kp_i = Lc*wc_i;           % [V/A]
Ki_i = Rc*wc_i;           % [V/(A*s)]   (Discrete-Time Integrator gainval; block multiplies by Ts)

%% ---- speed loop (outer PI on ELECTRICAL speed we = p*wm), ~10x slower than current loop ----
Tss  = 10*Ts;             % speed-loop sample time (500 us)                                     [s]
fc_w = 1.5;                % speed-loop bandwidth (keep it safe)                                                [Hz]
wc_w = 2*pi*fc_w;
Kp_w = J*wc_w/(p*Kt);            % [A / (elec rad/s)]
Ki_w = (B*wc_w + 0.1*J*wc_w^2)/(p*Kt);   % [A / (elec rad/s * s)]
iq_max = 4;               % use 4 (safety) instead of 8. q-axis current limit (rated phase-peak)                             [A]

%% ---- BUMPLESS I-f -> closed-loop handover (speed-PI integrator preload) ----
% During the open-loop (I-f) phase the speed-PI integrator is held reset by Startup/hold. If it is
% released from 0 at t_ho the PI output collapses from the open-loop torque command (I_start) to the
% pure P-term Kp_w*e ~ 0.19 A -> big torque step, speed sag, ~1.9 s to recover (Ki_w*e = 1.6 A/s).
% Cure (bumpless transfer): while held, preload the integrator state with
%       INT = iq_applied - Kp_w*e     so that     iq_ref(t_ho+) = Kp_w*e + INT = iq_applied.
% 'iq_applied' is taken from the MEASURED q-current (Park meas), which during the I-f phase is
% expressed in the I-f frame and therefore equals the open-loop command -> the preload tracks
% I_start automatically, including when I_start is retuned live over XCP / Monitor & Tune.
% Speed PI/Ki therefore uses InitialConditionSource = 'external', fed by (iq_meas_LPF - Kp_w*e).
f_ho_lpf = 200;                 % [Hz] LPF on the measured iq used for the preload (>> speed loop)
a_ho     = 2*pi*f_ho_lpf*Ts;    % first-order (EMA) discrete coefficient at the 20 kHz control rate

%% ---- voltage limit (space-vector circle) ----
Vmax = Vdc/sqrt(3);       % max |v_dq|                                                          [V]

%% ---- sensorless I-f startup -> handover (GPT-reviewed: align on id, then ramp iq) ----
%% ---- HARDWARE ADC-init phase ----
% On the real board, the first t_adc seconds are an ADC/offset-calibration phase during which ALL
% MOSFET duty cycles are held at 50%% (no active drive). Control starts only after t_adc; all absolute
% event times below are offset by t_adc so the simulation timeline matches the hardware.
t_adc      = 1.0;         % board ADC-init / 50%%-duty phase before any control action              [s]

%% ---- sensorless I-f startup -> handover (current-controlled: align on id, then ramp iq) ----
% Simple 2-state startup (see buildStartup): ONE comparison t>=t_ho selects OpenLoop vs ClosedLoop
% (two enabled subsystems, outputs merged). OpenLoop timeline (relative to t_adc):
%   [0..t_align]      align : id=I_align, iq=0, theta=0  (park rotor at 0)
%   [t_align..t_ho]   ramp  : id=0, iq=I_start, theta=INT(w_if), w_if ramps 0->2pi f_ho
t_align    = 0.15;        % alignment DURATION after t_adc (park rotor at theta=0)                  [s]
t_ramp     = 0.45;        % I-f frequency ramp DURATION (t_align..t_align+t_ramp)                   [s]
t_ho       = t_adc + t_align + t_ramp;   % absolute handover time                                  [s]
f_ho       = 25;          % I-f electrical frequency at end of ramp (back-EMF observable)           [Hz]
I_align    = 3.0;         % d-axis alignment current (parks rotor at theta=0)                       [A]
I_start    = 3.0;         % q-axis torque current during the open-loop I-f acceleration             [A]

%% ---- smooth handover extras (used by PLL_FOC_Simulation_single_v2 only) ----
% #2 : the speed-loop feedback we_fb is the RAW 20 kHz PLL speed, whose P-path gain (pll.Kp = 440)
%      passes observer noise straight through Kp_w -> +/-3.7 A spikes on iq_ref (seen on hardware).
%      A first-order LPF well above the 1.5 Hz speed-loop bandwidth removes it with no phase cost.
f_wfb    = 100;                 % [Hz] LPF on we_fb feeding the speed PI
a_wfb    = 2*pi*f_wfb*Ts;       % first-order (EMA) discrete coefficient
% #3 : at t_ho theta_cmd steps from the I-f angle to the observer angle by the I-f LOAD ANGLE
%      (measured +67 deg elec) -> the Park frame rotates in one step (id/iq step, current-PI kick,
%      PLL disturbance). Cure: latch dtheta = theta_if - theta_obs at t_ho and fade it out linearly
%      over t_cf so the reference frame rotates continuously into the rotor frame.
t_cf     = 0.020;               % [s] angle cross-fade duration after handover

%% ---- simulation scenario ----
wref       = 2*pi*30;     % speed reference (ELECTRICAL rad/s; we = p*wm; 30 Hz elec ~ 450 rpm mech @p=4) [rad/s]
tau_step   = 0.05;        % load-torque step amplitude                                          [N.m]
tau_step_t = t_adc + 0.7; % load-step time (after the drive is running)                         [s]
Tstop_sim  = t_adc + 1.0; % stop time (1 s of running after the 1 s ADC-init phase)             [s]

fprintf('foc_ctrl_params: Rc=%.3f Kp_i=%.3f Ki_i=%.0f | Kp_w=%.4f Ki_w=%.4f | iq_max=%g Vmax=%.1f | I-f %gHz/%gs\n', ...
        Rc, Kp_i, Ki_i, Kp_w, Ki_w, iq_max, Vmax, f_ho, t_ho);
