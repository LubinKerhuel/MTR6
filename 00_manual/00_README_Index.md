# MTR6 — Model-Based Motor Control Lab

**Duration:** 3 hours · **Level:** introductory (no prior Model-Based Design required)
**Toolchain:** MATLAB/Simulink R2025b + MPLAB Device Blocks for Simulink
**Hardware:** MCLV-48V-300W board + dsPIC33AK512MC510 DIM + ACT 57BLF02 PMSM (Hall)

---

## What you will build (the "crescendo")

You start from *nothing* — a blinking LED — and finish by running a **PLL sensorless
observer in a full closed-loop FOC drive on the real motor**. Each lab focuses on **one
main new idea** and builds on the previous workflow.

| # | Lab | New idea | You do | On hardware? |
|---|-----|----------|--------|--------------|
| 1 | **Blink LED** | Simulink + deploy (all-discrete Counter) | add 1 Compare block, click Build | ✅ build+flash |
| 2 | **External Mode** | tune & watch a live signal over USB | configure the link, then tune 3 parameters live (`Ctrl+D`) | ✅ build+flash |
| 3 | **Hall log** | read a real sensor, log it (down-sampled) | add 1 Rate Transition tap | ⚙️ guided build |
| 4 | **Template → logged data** | how the board template + a Hall sensor captured our logs | replay a log, compare sim vs real | 💻 simulation |
| 5 | **PLL observer** | sensorless FOC: simulate, then run on HW | run the sim, then build & run on the motor | 💻 sim → ✅ build+flash |
| 5-bis | **MCB two-model** *(optional)* | the same drive from the Motor Control Blockset's ready-to-use blocks (target + host workflow) | read the demo, run if MCB licensed | ✅ optional |

> **Labs 1, 2, and 5 include build+flash steps.** Lab 3 is an instructor-guided build. Lab 5-bis is
> **optional** and needs the Motor Control Blockset licence. Most hands-on labs include a
> `*_solution.slx`; where not, the manual names the reference/demo model to open.

---

## Manual contents (one file per part)

1. `01_Hardware_Requirements.md` — what's on the bench, cabling, safety.
2. `02_Software_Setup.md` — MATLAB, blockset, COM-port check, first-run smoke test.
2b. `02b_Create_From_Template.md` — start the motor labs from the Microchip **board template**.
3. `03_Lab1_BlinkLED.md`
4. `04_Lab2_ExternalMode.md`
5. `05_Lab3_HallLog.md`
6. `06_Lab4_Identify.md` — board template → logged motor data → replay & compare.
7. `07_Lab5_ObserverSim.md` — PLL sensorless FOC, simulation → hardware.
8. `08_Lab5bis_MCB_DualModel.md` — the same drive with the Motor Control Blockset (optional, advanced).
9. `09_Troubleshooting.md` — COM/External-Mode/motor recovery, reset ritual.

Read **`01`** and **`02`** before the lab starts; read **`02b`** before Lab 3 (first motor lab);
do **`03`–`07`** in order (**`08`** is optional).

---

## Teaching animations (optional, for the intro / concept slides)

We have short MPLAB-branded animations (Clarke-Park, SVPWM, six-step-with-Hall, stator field) under
`D:\26061_MTR6\Animations\`. Representative still frames are in `00_manual/img/anim_*.png` for use in
the manual; the full `.mp4` / `.webm` clips can be played to introduce a lab or embedded in the slides:

| Animation | Use it to introduce |
|-----------|---------------------|
| `anim_clarkepark.png` (ClarkePark.mp4) | Clarke/Park — before Lab 5 (the observer uses αβ / dq) |
| `anim_svpwm.png` (SVPWM.webm) | how the inverter synthesises the voltage vector |
| `anim_statorfield.png` (StatorField.webm) | the rotating stator field — motor-control intro |
| `anim_sixstep_hall.png` (SixStepRotor_wHall.webm) | six-step + Hall — the sensored baseline (concept slides) |

---

## Suggested timing (instructor keeps the clock)

- **Before the break:** Labs 1–2 (build & flash the LED, then live tuning over External Mode) and
  Lab 3 (read & log the Hall sensor).
- **After the break:** Lab 4 (board template → logged data → replay in simulation) and Lab 5 (PLL
  sensorless FOC — simulate, then build & run on the motor). Lab 5-bis (MCB) is optional self-study.

> ⏱ **Time gate:** if any build slips, open the `*_solution.slx` model and keep moving.
> You keep the lab flow moving and can revisit the build issue later.

---

## Golden rules

- **One model open at a time.** Between labs run `bdclose all` (or just close the model).
- **Never touch the MATLAB path.** Each lab folder is self-contained — `cd` into it and open the model.
- **The file name tells you its role.** `*_START` = the model **you** complete;
  `*_SOLUTION` = the answer; `*_HW_REFERENCE` = a known-good deploy model to fall back on
  (do not edit it); `*_DEMO` = optional extra. A model with **no suffix** (e.g.
  `Lab2_ExtMode_hw.slx`) ships complete — there is nothing to draw, you configure and run it.
- **Motor safety first** — see `01_Hardware_Requirements.md` §Safety before any spin-up.

---

## Colour code used in every model

| Colour | Meaning |
|--------|---------|
| 🟩 green | inputs / outputs (pins, ADC, LED, sensors) |
| 🟦 blue | control / logic you tune |
| 🟧 orange | observer / estimation |
| ⬜ grey | scopes / logging / display |

The same block names carry from lab to lab: `v_ab` / `i_ab` (αβ), `theta_obs`,
`we_obs` (observer outputs), `theta_true` / `we_true` (plant truth, sim only), and the speed
reference `wref`.

---

## A note on the figures

The **model screenshots** and **simulation-result plots** are generated from the lab models
(`00_manual/img/`) — e.g. Lab 5's `lab5_sim_model`, `lab5_hw_solution`, and `lab5_pll_tracking`
(the measured angle/speed tracking). The **hardware photos** (`hw_bench`, `hw_cabling_motor`,
`hw_cabling_power`, `hw_dim_insert`) are reused from the **MTR4 class** (identical hardware) —
provenance is noted in the text beneath each; the **FTDI cable** photo (`ftdi_cable`) is the
C232HD used for the optional high-bandwidth link (see `01`). The **teaching-animation frames**
(`anim_*`) come from our own MPLAB animations.

> **No placeholder figures.** Every `![...]` in this manual resolves to a file that exists.
> Where a live bench photo or IDE screenshot would have gone (Device-Manager COM port, the
> blinking LED, the Monitor & Tune session), the expected result is stated **in words**
> instead. Real captures can be added later — but the manual never ships with a broken image.

---

> 📌 **Pinout reference** — which DIM/MCU pin carries each signal (motor phases, Hall, ADC, PWM, LED, UART), for cabling any peripheral:
> [**MCLV-48V-300W + dsPIC33AK512MC510 DIM viewer**](https://mplab-blockset.github.io/MPLAB-Device-Blocks-for-Simulink/tools/dim_viewer/%23dim=dsPIC33AK512MC510%26bb=MCLV%26sort=function%26grp=1%26alt=0%26mc=1)
