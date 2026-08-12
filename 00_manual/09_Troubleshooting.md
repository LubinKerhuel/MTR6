# 09 — Troubleshooting & Recovery

Keep this open in a tab. Most problems fall into a handful of buckets.

---

## The reset ritual (try this first, always)

```matlab
bdclose all          % close all models — avoids duplicate-name / stale-state issues
clear;  clc
cd '<the lab folder you want>'
open  <the model>    % PreLoadFcn re-runs: re-adds local path, reloads params
```

Because each lab is self-contained (its own copy of the motor model + params), you
almost never need anything more than this.

---

## §COM port — board not found

- Board not in `serialportlist("available")` or Device Manager:
  - Replug the USB cable; try a different USB port.
  - Check the board has power (LED on the board lit).
  - It can take a few seconds to enumerate after plug-in.
- Wrong COM selected: the models auto-select via the target settings; if a dialog asks,
  pick the COM you noted in `02_Software_Setup.md` §3.
- Another program holding the port (a serial terminal, a previous MATLAB) → close it,
  or run `bdclose all` and reconnect.

---

## §Build — build+flash fails

- **Read the Diagnostic Viewer** — the real error is near the *first* red message, not the last.
- "Compiler/XC-DSC not found": the toolchain isn't installed/registered → instructor.
- Build stalls for minutes: normal is 2–4 min. If clearly hung (>8 min, no disk activity),
  Stop the build, `bdclose all`, reopen, retry.
- Repeated failure → **open the relevant `*_solution.slx`** and ask the instructor. Don't lose the
  session to one build.

---

## §External-Mode — won't connect or Scope frozen

- Confirm the board is powered and the COM port is present (§COM).
- Make sure only **one** MATLAB / one model is trying to use the port.
- Disconnect and re-run **Monitor & Tune**.
- Scope connects but is flat/choppy: you may be logging **too fast for 460 800 baud**.
  Reduce the log rate (Lab 3: set the Rate Transition back to **200 Hz**). Fewer/slower
  signals = a stable link.
- Still stuck: `bdclose all`, power-cycle the board, reopen, reconnect.

---

## §Motor — doesn't spin / spins wrong

- **PSU output OFF or current limit too low** → the motor can't draw current. Turn output
  ON, raise the limit to the instructor value.
- **Phase wiring** loose or swapped → power off, reseat U/V/W.
- Spins rough / jerks / buzzes → **Stop immediately, cut DC power** (§Safety in `01`).
  Likely wrong angle source or a loose Hall connector (§Hall).
- Won't start from rest (sensorless): normal — the models use a short **open-loop start**
  then hand over to the observer. If it never hands over, lower the speed reference.

---

## §Hall — angle looks random / motor won't commutate

- Hall connector not fully seated or wrong orientation → power off, reseat the keyed connector.
- Angle trace jumps randomly instead of ramping: Hall channel mis-wired → instructor.
- Lab 3 reads the Hall directly; if it looks random the Hall is bad. Lab 5's PLL observer does **not**
  use the Hall — so if Lab 3 fails on Hall but Lab 5 still spins the motor, that isolates the fault to
  the Hall wiring.

---

## §Params — simulation output is wildly wrong

- The lab's parameters load from its **PreLoadFcn** when you *open* the model. If you ran a
  script that cleared the workspace, **reopen the model** (or run its `startup_labN.m`).
- Never `clear all` mid-lab without reopening the model afterwards.

---

## §Duplicate model names

Every lab ships its **own** `PMSM_Motor_sref.slx`. If Simulink seems to use the "wrong"
one (e.g. after hopping between labs), you have two loaded with the same name:

```matlab
bdclose all      % clears them all
cd '<the correct lab folder>'
open  <the model>
```

Then only the correct local copy is loaded.

---

## When in doubt

1. `bdclose all` + reopen the model (fixes ~half of everything).
2. Power-cycle the board.
3. Fall back to the relevant `*_solution` model to keep progressing.
4. Ask the instructor — and note the **first** red line in the Diagnostic Viewer.

---

> 📌 **Pinout reference** — which DIM/MCU pin carries each signal (motor phases, Hall, ADC, PWM, LED, UART), for cabling any peripheral:
> [**MCLV-48V-300W + dsPIC33AK512MC510 DIM viewer**](https://mplab-blockset.github.io/MPLAB-Device-Blocks-for-Simulink/tools/dim_viewer/%23dim=dsPIC33AK512MC510%26bb=MCLV%26sort=function%26grp=1%26alt=0%26mc=1)
