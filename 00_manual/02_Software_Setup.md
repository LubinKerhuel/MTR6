# 02 — Software Setup

Goal: get MATLAB, the Microchip blockset, and the USB link working **before** the
first lab, so you spend the 3 hours on motor control, not on installers.

---

## 1. Software you need

| Software | Version | Purpose |
|----------|---------|---------|
| MATLAB + Simulink | **R2025b** | modelling & simulation |
| Simulink Coder / Embedded Coder | R2025b | code generation for the chip |
| **MPLAB Device Blocks for Simulink** | latest | the Microchip target + peripheral blocks |
| MPLAB X + XC-DSC compiler | as bundled | builds the generated C for dsPIC33A |

The instructor's machines are pre-installed. If you install your own, use the
offline installer under `D:\26061_MTR6\MATLAB_Install\`.

---

## 2. Check the blockset is available

In the MATLAB Command Window:

```matlab
ver                       % should list Simulink, Simulink Coder, Embedded Coder
picInfo                   % MPLAB Device Blocks: version, install path, up-to-date status
```

`picInfo` prints the installed **MPLAB Device Blocks** version, its install folder, the MATLAB
release, and whether you are up to date. If it errors or is not found, the add-on is not installed —
tell the instructor.

---

## 3. Find your board's COM port

1. Plug the board USB (PKoB4) into the PC and power the board logic (USB is enough for logic).
2. Windows → **Device Manager → Ports (COM & LPT)**. You should see a virtual COM
   port appear (e.g. `COMx`). Note the number.
3. In MATLAB you can confirm:

```matlab
serialportlist("available")     % your board's COMx should be in this list
```

> **Expected:** under *Ports (COM & LPT)* a **USB Serial Device (COMn)** appears when the
> board is plugged in and disappears when you unplug it. Note that **n** — you need it for
> the External-Mode settings in Lab 2. (On this bench it enumerates as `COM9`.)

> Write your COM number here: **COM____**. You'll need it for External Mode (Lab 2).

---

## 4. First-run smoke test (each lab folder)

Every lab folder is **self-contained**. To open a lab:

```matlab
cd 'D:\26061_MTR6\Lab_v2\Lab1_BlinkLED'   % <-- the lab you want
open Lab1_LED_SIM_START.slx                % *_START = the model you complete
```

Opening the model triggers its **PreLoadFcn**, which:
- adds *only this folder* to the path (no global path edits),
- loads the lab's parameters,
- prints a one-line confirmation in the Command Window.

You should see something like:

```
Lab1 ready — Blink LED (simulation). Solver=fixed-step, Ts=... .
```

If you see that line, the lab is ready.

---

## 5. Golden reset ritual (use it whenever anything feels wrong)

```matlab
bdclose all          % close every open model (avoids duplicate-name confusion)
clear;  clc
cd '<the lab folder you want>'
open  <the model>
```

Because each lab ships its **own copy** of the motor model and parameters, you
never need to change the MATLAB path between labs — just `bdclose all` and `cd`.

---

## 6. Before you start Lab 1

- [ ] `ver` shows Simulink + Coder + Embedded Coder.
- [ ] `picInfo` prints the MPLAB Device Blocks version (add-on present).
- [ ] Board enumerates a COM port; you noted the number.
- [ ] Opening a lab model prints its "ready" line.

All good → go to **`03_Lab1_BlinkLED.md`**.

---

> 📌 **Pinout reference** — which DIM/MCU pin carries each signal (motor phases, Hall, ADC, PWM, LED, UART), for cabling any peripheral:
> [**MCLV-48V-300W + dsPIC33AK512MC510 DIM viewer**](https://mplab-blockset.github.io/MPLAB-Device-Blocks-for-Simulink/tools/dim_viewer/%23dim=dsPIC33AK512MC510%26bb=MCLV%26sort=function%26grp=1%26alt=0%26mc=1)
