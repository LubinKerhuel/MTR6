%% obs_params.m  --  ACT 57BLF02 PMSM + PLL observer parameters  [Lab 5: PLL only]
% Motor = ACT 57BLF02 (the motor we actually use), loaded from ./params_ACT_57BLF02.m so the
% simulation and the hardware FOC model share ONE plant. Observer runs at a 20 kHz control rate.
% NOTE (Lab 5): this file was reduced to the PLL back-EMF observer only. The SMO / butterfly /
% Luenberger gain blocks from the multi-observer study have been removed to keep the lab focused.

%% ---- motor (ACT 57BLF02 surface PMSM) ----
% STANDARDIZED on the ACT 57BLF02 (the motor we actually use). The plant parameters are the single
% source of truth in ./params_ACT_57BLF02.m (identified from the 20 kHz external-mode logs); we load
% them here so the simulation and the hardware FOC model run the SAME motor.
run(fullfile(fileparts(mfilename('fullpath')),'params_ACT_57BLF02.m'));  % p,Rs,Ls,Ld,Lq,psi,J,B,T0,Kw,psi,Vdc...
Ls   = (Ld+Lq)/2;    % effective stator inductance for the (surface) observer [H]
Kt   = 1.5*p*psi;    % torque constant [N.m/A]

%% ---- Hall (not used here; observer is sensorless) ----
phi            = 0;
hall_edges_deg = 0:60:300;
hall_seq       = [1 2 3 4 5 6];

%% ---- inverter / bus ----
% Vdc/Vbase already come from params_ACT_57BLF02.m (Vdc=24). Kept implicit (do not re-hardcode).

%% ---- timing ----
% The ACT plant params file (params_ACT_57BLF02.m, run above) defines its OWN solver step Ts=25e-6
% (40 kHz) -- that is only the fixed-step period for the standalone Custom_PMSM identification plant,
% NOT a property of the motor. The observer STUDY runs the SAME ACT motor at a 20 kHz control rate
% (matching the FOC models' Tsc=1/Fsw=50us). So we DELIBERATELY override Ts here to the 20 kHz control
% step; the motor is unchanged (defined only by p,Rs,Ls,psi,J,B). We clear the imported plant-solver
% value first so it can never silently leak into the controller rate.
clear Ts Tstop;
PWM_frequency = 20e3;  Ts = 1/PWM_frequency;   % 20 kHz control step (observer + solver-base rate)
Tstop = 2;
assert(abs(Ts-1/20e3)<eps, 'observer control rate must be 20 kHz');

%% ---- ADC current-sense noise model (12-bit, +/-4.4 A shunt front end @ 20 kHz) ----
adc.ISenseMax = 4.4;                       % A  current full-scale (+/-)
adc.bits      = 12;                        % ADC resolution
adc.LSB       = 2*adc.ISenseMax/(2^adc.bits-1);   % = 2.15 mA current quantum
adc.quant     = adc.LSB;                   % Quantizer interval [A]
adc.noiseRMS  = 0.008;                     % A  analog+thermal+switching noise (~4 LSB, typical MCLV shunt)
adc.noiseVar  = adc.noiseRMS^2;            % variance for the Band-Limited White Noise block
adc.noiseTs   = Ts;                        % noise sampled at the ADC/control rate
adc.enable    = 1;                         % 1 = inject ADC noise+quantization on measured currents

%% ---- PLL back-EMF observer (quadrature PLL on the voltage-model EMF) ----
% e = v - Rc*i - Lc*di/dt (voltage model), LPF, then a quadrature PLL locks the angle:
%   perr = -e_alpha*cos(th) - e_beta*sin(th) ; we = Kp*perr + Ki*INT(perr) ; th = INT(we).
% Type-2 PLL, critically damped: Kp=2*zeta*wn, Ki=wn^2, wn=2*pi*fn.
pll.Rc  = Rs; pll.Lc = Ls;
pll.fLP = 400;  pll.aLP = 2*pi*pll.fLP*Ts;   % EMF pre-filter (discrete 1st-order coeff)
pll.fn  = 35;   pll.zeta = 1.0;  pll.wn = 2*pi*pll.fn;   % PLL bandwidth (sweep-optimum): fast lock,
                                                          % 0.5 Hz min speed, best noise (1.75 deg).
pll.Kp  = 2*pll.zeta*pll.wn;  pll.Ki = pll.wn^2;

%% ---- common test-bench drive defaults (build_obs_bench) ----
Vmag     = 3.0;   % open-loop V/f voltage magnitude [V] (sets the operating current/torque)
f_cmd    = 30;    % commanded (held) electrical frequency [Hz] (constant; swept to find min-converge speed)
t_ramp   = 0.6;   % V/f frequency ramp time 0->f_cmd [s] (open-loop start so the motor catches sync)
tau_load = 0;     % load-torque step amplitude [Nm]
tau_t    = 1.5;   % load-step time [s]

fprintf('obs_params: ACT57BLF02 p=%d Rs=%.3f Ls=%.2e psi=%.3e | PLL fn=%.0fHz Kp=%.1f Ki=%.0f | Ts=%.1e (%.0f kHz)\n', ...
        p, Rs, Ls, psi, pll.fn, pll.Kp, pll.Ki, Ts, 1e-3/Ts);
