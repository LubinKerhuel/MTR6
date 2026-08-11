function prep_replay_lab4(which_log)
%PREP_REPLAY_LAB4  Load ONE clean bench log and publish faithful replay signals.
%  Feeds the SIMPLE replay model (Lab4_ReplayCompare2): the logged applied voltage
%  Vabc is used DIRECTLY (no re-synthesis, no magnitude guess), so the simulated
%  current has the right amplitude. Also publishes the measured Ia(alpha), We and
%  electrical rotor angle Theta so the model output can be overlaid on the real motor.
%
%  which_log : the log's OWN log_index, or the matching tag:
%                1 | 'FOC'      -> Log_FOC_fixed_speed.mat   (closed-loop FOC)
%                2 | 'SixStep'  -> Log_SixStep_Hall.mat      (Hall six-step)
%                3 | 'VF'       -> Log_VF_ramp.mat           (open-loop V/f)
%              Omit it (prep_replay_lab4) to get an interactive menu to pick the log.
%              The menu numbers ARE the log_index stored inside each .mat file.
%
%  Published base-workspace signals (identical names for every log):
%    replay_vabc   3-phase applied voltage  [V]          -> PMSM Motor .v_abc
%    replay_Ia     measured alpha current   [A]          -> compare vs model
%    replay_We     measured elec speed      [rad/s]      -> compare vs model  (= 2*pi*Speed)
%    replay_Theta  measured elec rotor angle[rad, 0..2pi]-> compare vs model
%    replay_Tend   log duration             [s]
%    log_index     experiment id (1 FOC, 2 SixStep, 3 V/f) copied from the log

here = fileparts(mfilename('fullpath'));
run(fullfile(here,'params_ACT_57BLF02.m'));   % params (p, Rs, Ls, psi, ...)

% ---- catalogue, INDEXED BY log_index (row k == log_index k) ----
%       log_index | tag       | menu label                            | file
cat = { 1, 'FOC',     'FOC 10Hz  (closed-loop, best match)', 'Log_FOC_fixed_speed.mat'
        2, 'SIXSTEP', 'Six-step  (Hall-commutated)',         'Log_SixStep_Hall.mat'
        3, 'VF',      'V/f ramp  (open-loop, stalls <13Hz)', 'Log_VF_ramp.mat'     };

% ---- no argument -> interactive menu (number == log_index) ----
if nargin < 1 || isempty(which_log)
    fprintf('\nWhich bench log do you want to replay?\n');
    for k = 1:size(cat,1)
        fprintf('  %d) %s   [%s]\n', cat{k,1}, cat{k,3}, cat{k,4});
    end
    which_log = input('Enter choice [1-3] (default 1): ');
    if isempty(which_log), which_log = 1; end
end

% ---- resolve the selection to a catalogue row ----
if isnumeric(which_log)
    row = find([cat{:,1}] == which_log, 1);      % by log_index number
else
    row = find(strcmpi(which_log, cat(:,2)), 1); % by tag
end
assert(~isempty(row), ...
    'prep_replay_lab4: choice must be 1|2|3 or FOC|SixStep|VF.');
f = cat{row,4};
L = load(fullfile(here,'logs',f));

% ---- sanity: the file's own log_index must match the catalogue row ----
if isfield(L,'log_index') && L.log_index ~= cat{row,1}
    warning('prep_replay_lab4:indexMismatch', ...
        '%s carries log_index=%d but catalogue expects %d.', f, L.log_index, cat{row,1});
end

% --- applied voltage: use the LOGGED Vabc directly (this is the true drive) ---------
vabc = L.Vabc;                                   % timeseries Nx3 [V]

% --- measured signals to overlay -----------------------------------------------------
Ia    = timeseries(L.Iab.Data(:,1), L.Iab.Time);         % alpha current [A]
We    = timeseries(2*pi*L.Speed.Data, L.Speed.Time);     % elec speed [rad/s] (Speed is elec Hz)
Theta = L.Theta;                                          % elec rotor angle [rad], 0..2pi

assignin('base','replay_vabc',  vabc);
assignin('base','replay_Ia',    Ia);
assignin('base','replay_We',    We);
assignin('base','replay_Theta', Theta);
assignin('base','replay_Tend',  vabc.Time(end));
assignin('base','replay_source',f);
if isfield(L,'log_index'), assignin('base','log_index', L.log_index); end

fprintf(['prep_replay_lab4: "%s" (log_index=%d)  %.1f s.  Vabc peak %.2f V, Ia peak %.2f A.\n' ...
         '  base vars: replay_vabc, replay_Ia, replay_We, replay_Theta, replay_Tend, log_index\n'], ...
        f, cat{row,1}, vabc.Time(end), max(abs(vabc.Data(:))), max(abs(Ia.Data)));
end
