# 08 — Lab 5-bis: Sensorless FOC with the Motor Control Blockset (optional, advanced)

**Goal:** see a sensorless FOC drive built with the **Motor Control Blockset (MCB)** — which provides
**ready-to-use FOC algorithms and observers** — using a **target + host model** workflow to visualise
data and tune parameters, on the same MCLV-48V-300W + dsPIC33AK512MC510 hardware. It solves the same
problem as Lab 5 but with a **different observer**: an **SMO** (sliding-mode observer) here, versus the
**PLL** observer you built in Lab 5.

**Time:** demo / self-study · **Build+flash:** ✅ optional
**Folder:** `Lab_v2\Lab5bis_MCB_DualModel\`

> This lab is **optional and advanced**. It is a Microchip reference demo shipped **as-is**. We only
> point you to it and explain the *idea*; the full step-by-step is in the demo's own guide:
> `Lab5bis_MCB_DualModel\docs\README.pdf`.

---

## The idea: ready-to-use blocks + a target + host workflow

The **Motor Control Blockset** supplies **ready-to-use FOC algorithms, SMO observers, and
serial-visualisation blocks** off the shelf. Where Lab 5 put the observer, the loops, **and** the
live scopes in one hand-built model, MCB uses a **target + host model** workflow — two models:

| Model | Runs on | Job |
|-------|---------|-----|
| **`pmsm_smo.slx`** | the **target** (dsPIC33AK512MC510) | the SMO sensorless FOC — deployed to the chip |
| **`mcb_hostmodel_dsPIC33A.slx`** | the **host PC** | visualise target data and tune parameters live |

The two talk over the **UART serial interface** — the host model **visualises data and tunes
parameters** on the running controller without stopping it.

---

## Requirements (beyond the rest of the class)

- **Motor Control Blockset** add-on installed (MathWorks licence).
- The rest is the **same bench** as Labs 1–5 (MCLV-48V-300W + dsPIC33AK512MC510 DIM + ACT 57BLF02 PMSM).

> Labs 1–5 use only the MPLAB Device Blocks and need no MCB licence, so the class runs fully without
> it. Where the Motor Control Blockset **is** available, this lab shows how its ready-to-use blocks
> speed up building the same drive.

---

## How to run (summary — full detail in the demo README)

1. `cd 'D:\26061_MTR6\Lab_v2\Lab5bis_MCB_DualModel'`
2. Run the data script `mchp_pmsm_foc_smo_dsPIC33_data.m` (loads motor + board parameters).
3. Open **`pmsm_smo.slx`**, simulate to check, then **Build, Deploy & Start** to the target.
4. Open **`mcb_hostmodel_dsPIC33A.slx`**, set the target's **COM port**, and **Run** to plot live
   data. Start/stop the motor with **SW1**, vary speed with **POT**.

> 📄 **Read `docs\README.pdf`** for the exact steps, jumper notes, and the signal list. This lab
> complements Lab 5 by showing how the Motor Control Blockset builds the same drive from ready-made
> blocks.

---

## What to take away

- The **Motor Control Blockset** provides **ready-to-use** FOC and observer blocks that get a working
  sensorless drive up quickly — a useful complement to the hand-built, dependency-free Lab 5 model.
- The **target + host model** workflow is a common industry pattern: one model is the embedded
  controller on the chip, a second model on the PC **visualises data and tunes parameters** live.

---

## You're done 🎉

You went from a blinking LED to a full **sensorless FOC** drive — hand-built in Lab 5, and built here
from the Motor Control Blockset's ready-to-use blocks. See `09_Troubleshooting.md` if anything
misbehaved, and the slides for the theory behind the observer.

---

> 📌 **Pinout reference** — which DIM/MCU pin carries each signal:
> [**MCLV-48V-300W + dsPIC33AK512MC510 DIM viewer**](https://mplab-blockset.github.io/MPLAB-Device-Blocks-for-Simulink/tools/dim_viewer/%23dim=dsPIC33AK512MC510%26bb=MCLV%26sort=function%26grp=1%26alt=0%26mc=1)
