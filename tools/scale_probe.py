#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["bleak"]
# ///
"""BLE protocol probe for the Chipsea-BLE kitchen scale.

Scans for the scale, subscribes to the weight characteristic and prints every
*changed* frame as raw hex plus the decoded weight. The scale notifies many
times per second with identical payloads; repeated frames are counted and
summarized instead of printed, so the output only shows actual changes.

Bytes that differ from the previously printed frame are marked with [..] —
useful for spotting flag bytes (unit, stability, sign) we don't decode yet.

Usage:
    uv run tools/scale_probe.py
    uv run tools/scale_probe.py --all          # print every frame, no dedup
    uv run tools/scale_probe.py --scan-timeout 15
"""

import argparse
import asyncio
import sys
import time

from bleak import BleakClient, BleakScanner

DEVICE_NAME = "Chipsea-BLE"
WEIGHT_CHARACTERISTIC_FRAGMENT = "fff1"


def decode_weight(frame: bytes) -> int | None:
    """Weight in grams; mirrors ScaleNotifier._decodeWeightFromIntList."""
    if len(frame) < 8:
        return None
    weight = frame[6] | (frame[5] << 8)
    is_negative = frame[2] == 0x02
    return -weight if is_negative else weight


class FrameLogger:
    def __init__(self, print_all: bool):
        self.print_all = print_all
        self.started = time.monotonic()
        self.total = 0
        self.printed = 0
        self.repeats = 0
        self.last_frame: bytes | None = None

    def on_frame(self, _characteristic, data: bytearray) -> None:
        frame = bytes(data)
        self.total += 1

        if not self.print_all and frame == self.last_frame:
            self.repeats += 1
            return

        if self.repeats:
            print(f"    ... previous frame repeated {self.repeats}x")
            self.repeats = 0

        elapsed = time.monotonic() - self.started
        hex_bytes = " ".join(
            f"[{byte:02x}]"
            if self.last_frame is not None
            and (i >= len(self.last_frame) or byte != self.last_frame[i])
            else f" {byte:02x} "
            for i, byte in enumerate(frame)
        )
        weight = decode_weight(frame)
        weight_text = "frame too short" if weight is None else f"{weight} g"
        print(f"{elapsed:8.3f}s  {hex_bytes}  ->  {weight_text}")

        self.last_frame = frame
        self.printed += 1

    def summary(self) -> None:
        duration = time.monotonic() - self.started
        rate = self.total / duration if duration > 0 else 0
        print(
            f"\n{self.total} frames in {duration:.1f}s (~{rate:.1f}/s), "
            f"{self.printed} unique printed"
        )


async def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--all",
        action="store_true",
        help="print every frame instead of only changes",
    )
    parser.add_argument(
        "--name", default=DEVICE_NAME, help="advertised device name to look for"
    )
    parser.add_argument(
        "--scan-timeout", type=float, default=10.0, help="scan timeout in seconds"
    )
    args = parser.parse_args()

    print(f"Scanning for '{args.name}' ({args.scan_timeout:.0f}s) ...")
    device = await BleakScanner.find_device_by_name(
        args.name, timeout=args.scan_timeout
    )
    if device is None:
        print("No scale found. Is it switched on (put some weight on it)?")
        return 1

    print(f"Found {device.name} ({device.address}), connecting ...")
    logger = FrameLogger(print_all=args.all)

    async with BleakClient(device) as client:
        characteristic = next(
            (
                char
                for service in client.services
                for char in service.characteristics
                if WEIGHT_CHARACTERISTIC_FRAGMENT in char.uuid.lower()
            ),
            None,
        )
        if characteristic is None:
            print(f"No characteristic matching '{WEIGHT_CHARACTERISTIC_FRAGMENT}':")
            for service in client.services:
                for char in service.characteristics:
                    print(f"  {char.uuid}  {char.properties}")
            return 1

        print(f"Subscribed to {characteristic.uuid}. Ctrl+C to stop.\n")
        await client.start_notify(characteristic, logger.on_frame)
        try:
            while client.is_connected:
                await asyncio.sleep(0.5)
            print("\nScale disconnected.")
        except asyncio.CancelledError:
            pass
        finally:
            logger.summary()

    return 0


if __name__ == "__main__":
    try:
        sys.exit(asyncio.run(main()))
    except KeyboardInterrupt:
        print()
