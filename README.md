# wyoming-satellite-image

Automated Raspberry Pi OS image builder for a **Wyoming voice satellite** using a Raspberry Pi Zero 2 W + ReSpeaker 2-Mic HAT.

Built with [pi-gen](https://github.com/RPi-Distro/pi-gen) via GitHub Actions. Produces a flashable `.img.xz` compatible with Raspberry Pi Imager.

## Stages

| Stage | Contents |
|---|---|
| `stage0` + `stage1` + `stage2` | Pi OS Lite base (from pi-gen) |
| `01-stage-base` | SSH enabled, essential packages, locale |
| `02-stage-audiodriver-2michat` | ReSpeaker 2-Mic HAT driver (seeed-voicecard via DKMS) |
| `03-stage-wyoming-satellite` | wyoming-satellite + openWakeWord as systemd services |
| `04-stage-finish` | User config, SSH key regeneration, apt cleanup |

## Flash

Download the latest `.img.xz` from [Releases](../../releases) and flash with Raspberry Pi Imager → **Use Custom**.

Or add the custom URL to Raspberry Pi Imager:
```
https://raw.githubusercontent.com/piclaw-bot/wyoming-satellite-image/main/rpi-imager.json
```

## Configuration

After first boot, edit `/etc/wyoming-satellite/config.env`:

```bash
# IP of the machine running the piclaw voice-pipeline extension
WYOMING_SERVER_HOST=192.168.1.x

WYOMING_STT_PORT=10300
WYOMING_TTS_PORT=10200
WYOMING_HANDLE_PORT=10101
WAKE_WORD=ok_nabu
SATELLITE_NAME=living-room
```

Then: `sudo systemctl restart wyoming-satellite`

## Default credentials

- **User**: `pi`  **Password**: `raspberry`  ← change on first login
- **Hostname**: `wyoming-satellite`
- SSH enabled on port 22

## Hardware

- Raspberry Pi Zero 2 W (aarch64, `pi3-32bit` compatible)
- [ReSpeaker 2-Mics Pi HAT](https://wiki.seeedstudio.com/ReSpeaker_2_Mics_Pi_HAT/)
- MicroSD ≥ 4 GB
- USB-C power supply

## Connects to

The [piclaw voice-pipeline extension](https://github.com/rcarmo/piclaw) — Wyoming servers at `STT :10300`, `TTS :10200`, `handle :10101`.
