# mbpfan-glide

Fan control for Macs running Linux that ramps the fans up immediately and glides them down slowly, so the fan pitch doesn't wander every time the temperature flickers.

## Why

[mbpfan](https://github.com/linux-on-mac/mbpfan) reads the hottest CPU core every second and adjusts the fan right away in both directions. Core temperatures swing by tens of degrees within seconds under bursty load, so the fan follows them. On a 2019 iMac (iMac19,1) under a stop-start workload, mbpfan swung the fan across its full 1200–2700 rpm range nine times in two minutes, sometimes dropping 1500 rpm in a single second. The constant change in pitch is more noticeable than a steady fan.

mbpfan also only reads CPU temperatures. On machines with a discrete GPU sharing the same fan, a hot GPU can make Apple's SMC throttle the CPU (to 800 MHz on the iMac above) while the CPU itself looks cool.

## How it works

Every `poll_seconds`:

1. Read the hottest CPU core (from `coretemp`) and smooth it with a moving average. Read the GPU temperature (from `amdgpu`, `radeon` or `nouveau`) if there is one.
2. Map each temperature through a linear curve: minimum fan speed at `*_low`, maximum at `*_high`. The higher of the two is the target.
3. If the target is above the current speed, jump to it.
4. If it is below, hold the current speed for `hold_seconds`, then descend at most `down_rpm_per_second` toward it.

Fan limits come from the SMC (`fanN_min`, `fanN_max`), and every fan the SMC exposes is controlled, so machines with one fan or several work the same way. On exit the fans are handed back to the SMC's automatic control.

On the same two-minute iMac recording, mbpfan-glide changed speed once.

## Requirements

- Linux with the `applesmc` and `coretemp` drivers loaded, and the SMC exposing `fanN_manual` and `fanN_output` under `/sys/devices/platform/applesmc.*`. Macs with a T2 chip need T2 patches for this.
- Python 3.6 or later (standard library only).
- systemd, to run it as a service.

Tested on an iMac19,1 (i9-9900K, Radeon Pro, one fan) running Debian 13. Other Macs that work with mbpfan should work, but haven't been tried.

## Install

```sh
git clone https://github.com/znation/mbpfan-glide
cd mbpfan-glide
./mbpfan-glide --dry-run    # optional: print decisions without touching the fans
sudo ./install.sh
```

This installs `/usr/local/bin/mbpfan-glide`, `/etc/mbpfan-glide.conf` (kept if it already exists) and a `mbpfan-glide` systemd service. If mbpfan is enabled, the installer disables it; the two can't both control the fans.

Logs: `journalctl -u mbpfan-glide`. A line is logged whenever a fan moves by 200 rpm or more.

## Configure

Edit `/etc/mbpfan-glide.conf`, then `sudo systemctl restart mbpfan-glide`. The installed file lists every setting with its default. To start ramping earlier, lower `cpu_low`/`cpu_high` or `gpu_low`/`gpu_high`. For a calmer fan, raise `hold_seconds` or lower `down_rpm_per_second`.

## Uninstall

```sh
sudo ./uninstall.sh
```

The fans return to the SMC's automatic control. To go back to mbpfan, `sudo systemctl enable --now mbpfan`.

## License

BSD 2-Clause; see [LICENSE](LICENSE). Not affiliated with mbpfan, whose approach this builds on.
