# Minisforum AI Series - ALC245 Audio Fix

Hardware quirk fixes for the Realtek ALC245 codec on Minisforum AI series mini PCs
(subsystem ID `1f4c:b020`, AMD Ryzen AI 9 HX 370).

## Problems solved

1. **PipeWire deadlock** - A custom `~/.config/pipewire/pipewire.conf` can override
   default module loading and break the PulseAudio compatibility layer, causing all
   audio clients (including games) to hang on connect.

2. **No headphone output** - The BIOS pin defaults don't enable EAPD (external
   amplifier) on the headphone pin (Node 0x21), so no audio reaches the jack.

3. **No headphone jack detection** - Hardware jack detect on Node 0x21 always
   returns "unplugged". Node 0x17 has working jack sense but isn't wired to the
   audio output. The driver's auto-mute logic therefore keeps headphones muted.

## What the fix does

- **HDA firmware patch** (`alc245-minisforum.fw`) - Configures pin defaults and
  sends init verbs to enable EAPD, set pin control, unmute, and select the correct
  DAC on Node 0x21.

- **modprobe config** (`alc245-jack.conf`) - Enables 500ms jack polling and loads
  the firmware patch for the correct sound card.

- **Autostart script** (`fix-alc245-headphone`) - At desktop login, disables
  auto-mute and unmutes headphones (since the driver's auto-mute re-mutes them
  based on broken jack detect).

## Install

```bash
./install.sh
# then reboot
```

## Uninstall

```bash
./uninstall.sh
# then reboot
```

## Notes

- With auto-mute disabled, audio plays through both speakers and headphones
  simultaneously. Use your desktop sound settings to switch outputs if needed.
- The jack detect quirk should ideally be upstreamed as a kernel patch to
  `sound/pci/hda/patch_realtek.c` for subsystem ID `0x1f4c:0xb020`.
