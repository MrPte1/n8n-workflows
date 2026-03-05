#!/usr/bin/env python3
"""
Meeting pipeline integration test.
Tests: transcribe-docker API, diarization, n8n webhook reachability.

Usage:
  python3 test_pipeline.py                   # basic (no diarization)
  python3 test_pipeline.py --diarize         # full diarization test
  python3 test_pipeline.py --audio FILE.m4a  # use specific audio file
"""

import argparse
import json
import struct
import sys
import time
import urllib.request
import urllib.error
import wave
from pathlib import Path

TRANSCRIBE_URL = "http://localhost:8000"
N8N_URL        = "http://localhost:5678"
POLL_INTERVAL  = 10   # seconds
MAX_POLLS      = 60   # 10 min max

PASS = "\033[92m✓\033[0m"
FAIL = "\033[91m✗\033[0m"
INFO = "\033[94m•\033[0m"

results: list[tuple[str, bool, str]] = []


def check(name: str, ok: bool, detail: str = "") -> bool:
    results.append((name, ok, detail))
    icon = PASS if ok else FAIL
    line = f"  {icon} {name}"
    if detail:
        line += f"  ({detail})"
    print(line)
    return ok


def get(url: str) -> tuple[int, dict | str]:
    try:
        with urllib.request.urlopen(url, timeout=10) as r:
            raw = r.read().decode()
            try:
                return r.status, json.loads(raw)
            except json.JSONDecodeError:
                return r.status, raw
    except urllib.error.HTTPError as e:
        return e.code, e.reason
    except Exception as e:
        return 0, str(e)


def post_json(url: str, data: dict, timeout: int = 10) -> tuple[int, dict | str]:
    body = json.dumps(data).encode()
    req = urllib.request.Request(url, data=body,
                                 headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            raw = r.read().decode()
            try:
                return r.status, json.loads(raw)
            except json.JSONDecodeError:
                return r.status, raw
    except urllib.error.HTTPError as e:
        return e.code, e.reason
    except Exception as e:
        return 0, str(e)


def post_multipart(url: str, fields: dict, file_path: Path) -> tuple[int, dict | str]:
    boundary = b"testboundary1234567890"
    body = b""
    for name, value in fields.items():
        body += b"--" + boundary + b"\r\n"
        body += f'Content-Disposition: form-data; name="{name}"\r\n\r\n'.encode()
        body += value.encode() + b"\r\n"
    # file field
    suffix = file_path.suffix
    body += b"--" + boundary + b"\r\n"
    body += f'Content-Disposition: form-data; name="file"; filename="{file_path.name}"\r\n'.encode()
    body += b"Content-Type: application/octet-stream\r\n\r\n"
    body += file_path.read_bytes() + b"\r\n"
    body += b"--" + boundary + b"--\r\n"

    req = urllib.request.Request(
        url, data=body,
        headers={"Content-Type": f"multipart/form-data; boundary={boundary.decode()}"},
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            raw = r.read().decode()
            try:
                return r.status, json.loads(raw)
            except json.JSONDecodeError:
                return r.status, raw
    except urllib.error.HTTPError as e:
        try:
            return e.code, json.loads(e.read().decode())
        except Exception:
            return e.code, e.reason
    except Exception as e:
        return 0, str(e)


def make_test_wav(path: Path) -> None:
    """Generate a 3-second 16kHz mono WAV with two alternating tones (simulates two speakers)."""
    sample_rate = 16000
    duration = 3
    import math
    samples = []
    for i in range(sample_rate * duration):
        t = i / sample_rate
        # alternate between 440 Hz and 880 Hz every 1.5s
        freq = 440 if t < 1.5 else 880
        val = int(32767 * 0.3 * math.sin(2 * math.pi * freq * t))
        samples.append(struct.pack("<h", val))
    with wave.open(str(path), "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        wf.writeframes(b"".join(samples))


def poll_job(job_id: str) -> dict | None:
    print(f"  {INFO} Polling job {job_id[:8]}… ", end="", flush=True)
    for i in range(MAX_POLLS):
        time.sleep(POLL_INTERVAL)
        code, data = get(f"{TRANSCRIBE_URL}/jobs/{job_id}")
        if code != 200:
            print(f"\n  error polling: {code} {data}")
            return None
        status = data.get("status", {}).get("status", "unknown") if isinstance(data, dict) else "unknown"
        print(f"{status} ", end="", flush=True)
        if status == "done":
            print()
            return data
        if status == "failed":
            print()
            error = data.get("status", {}).get("error", "")
            print(f"  {FAIL} Job failed: {error}")
            return None
    print("\n  timeout")
    return None


# ─── Test sections ────────────────────────────────────────────────────────────

def test_services():
    print("\n── Service Health ──────────────────────────────────────────────")
    code, data = get(f"{TRANSCRIBE_URL}/")
    check("transcribe-docker reachable", code in (200, 404), f"HTTP {code}")

    code, data = get(f"{N8N_URL}/healthz")
    check("n8n reachable", code == 200 and (data == {"status": "ok"} if isinstance(data, dict) else False),
          str(data))


def test_transcription(audio_file: Path) -> str | None:
    """Submit job without diarization. Returns job_id on success."""
    print("\n── Transcription (no diarization) ──────────────────────────────")
    code, data = post_multipart(
        f"{TRANSCRIBE_URL}/jobs",
        {"language_hint": "fi", "diarize": "false"},
        audio_file,
    )
    if not check("POST /jobs accepted", code == 200, f"HTTP {code} {data}"):
        return None

    job_id = data.get("job_id") if isinstance(data, dict) else None
    if not check("job_id in response", bool(job_id), str(data)):
        return None

    result = poll_job(job_id)
    if not check("job completed", result is not None):
        return None

    # artifacts
    code, txt = get(f"{TRANSCRIBE_URL}/jobs/{job_id}/artifacts/transcript.txt")
    check("transcript.txt exists", code == 200, f"HTTP {code}")

    code, js = get(f"{TRANSCRIBE_URL}/jobs/{job_id}/artifacts/transcript.json")
    check("transcript.json exists", code == 200, f"HTTP {code}")

    if isinstance(js, dict):
        segs = js.get("segments", [])
        check("segments non-empty", len(segs) > 0, f"{len(segs)} segments")
        no_speaker = all("speaker" not in s for s in segs)
        check("no speaker field (diarize=false)", no_speaker)

    if isinstance(txt, str) and txt.strip():
        first_line = txt.strip().splitlines()[0]
        check("transcript.txt has content", True, repr(first_line[:80]))
    else:
        check("transcript.txt has content", False, "empty")

    return job_id


def test_diarization(audio_file: Path, participants: list[str]) -> None:
    print("\n── Diarization ─────────────────────────────────────────────────")
    fields = {
        "language_hint": "fi",
        "diarize": "true",
        "participants": json.dumps(participants),
    }
    code, data = post_multipart(f"{TRANSCRIBE_URL}/jobs", fields, audio_file)
    if not check("POST /jobs (diarize=true) accepted", code == 200, f"HTTP {code} {data}"):
        return

    job_id = data.get("job_id") if isinstance(data, dict) else None
    if not check("job_id in response", bool(job_id), str(data)):
        return

    result = poll_job(job_id)
    if not check("job completed", result is not None):
        return

    code, js = get(f"{TRANSCRIBE_URL}/jobs/{job_id}/artifacts/transcript.json")
    check("transcript.json exists", code == 200, f"HTTP {code}")

    if isinstance(js, dict):
        segs = js.get("segments", [])
        speakers_found = {s.get("speaker") for s in segs if "speaker" in s}
        check("speaker field present on segments", bool(speakers_found), str(speakers_found))
        check("speaker_map in transcript.json", "speaker_map" in js, str(js.get("speaker_map")))

    code, txt = get(f"{TRANSCRIBE_URL}/jobs/{job_id}/artifacts/transcript.txt")
    check("transcript.txt exists", code == 200, f"HTTP {code}")
    if isinstance(txt, str) and txt.strip():
        has_bracket = "[" in txt
        check("transcript.txt has speaker prefix", has_bracket, repr(txt.strip().splitlines()[0][:80]))


def test_n8n_webhook():
    print("\n── n8n Webhook ─────────────────────────────────────────────────")
    # Just verify the webhook endpoint is registered (will fail execution without valid file_id)
    import urllib.request
    req = urllib.request.Request(
        f"{N8N_URL}/webhook/meeting-audio",
        data=json.dumps({"file_id": "test", "chat_id": "0", "bot_token": "test",
                         "meeting_name": "Test", "participants": [], "date": "2026-01-01"}).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            status = r.status
            body = r.read().decode()
            # 200 means workflow triggered (even if it'll fail later on bad file_id)
            check("webhook endpoint registered", status == 200, f"HTTP {status}: {body[:60]}")
    except urllib.error.HTTPError as e:
        body = e.read().decode() if hasattr(e, 'read') else ""
        # 404 = workflow not published; 500 = triggered but errored internally
        check("webhook endpoint registered", e.code != 404,
              f"HTTP {e.code} {'(not published)' if e.code == 404 else body[:60]}")
    except Exception as e:
        check("webhook endpoint registered", False, str(e))


def print_summary():
    print("\n── Summary ─────────────────────────────────────────────────────")
    passed = sum(1 for _, ok, _ in results if ok)
    total  = len(results)
    for name, ok, detail in results:
        icon = PASS if ok else FAIL
        print(f"  {icon} {name}" + (f"  ({detail})" if detail else ""))
    print(f"\n  {passed}/{total} checks passed")
    return passed == total


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--diarize", action="store_true", help="Run diarization test")
    parser.add_argument("--audio", help="Audio file to use (default: synthetic WAV)")
    parser.add_argument("--participants", default="Petri,Mikko",
                        help="Comma-separated participant names for diarization test")
    args = parser.parse_args()

    # Resolve audio file — prefer a real speech file if available
    REAL_AUDIO = Path("/srv/transcribe/jobs/f6613a83050d4d558d6541c876d95df2/input.m4a")
    if args.audio:
        audio = Path(args.audio)
        if not audio.exists():
            print(f"Audio file not found: {audio}")
            sys.exit(1)
    elif REAL_AUDIO.exists():
        audio = REAL_AUDIO
    else:
        audio = Path("/tmp/test_meeting.wav")
        print(f"{INFO} Generating synthetic test WAV → {audio}")
        make_test_wav(audio)
    print(f"{INFO} Using audio: {audio} ({audio.stat().st_size // 1024} KB)")

    participants = [p.strip() for p in args.participants.split(",") if p.strip()]

    test_services()
    test_transcription(audio)
    if args.diarize:
        test_diarization(audio, participants)
    else:
        print(f"\n  {INFO} Skipping diarization test (pass --diarize to enable)")
    test_n8n_webhook()

    ok = print_summary()
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
