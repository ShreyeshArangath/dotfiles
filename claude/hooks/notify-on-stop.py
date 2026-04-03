#!/usr/bin/env python3
import json
import os
import subprocess
import sys

LOGO_PATH = os.path.expanduser("~/.claude/claude-logo.png")


def get_summary(transcript_path):
    if not transcript_path or not os.path.exists(transcript_path):
        return "Task completed"

    with open(transcript_path, "r", encoding="utf-8") as f:
        lines = f.read().strip().split("\n")

    for line in reversed(lines):
        try:
            entry = json.loads(line)
            msg = entry.get("message", entry)
            if msg.get("role") != "assistant":
                continue
            content = msg.get("content", "")
            if isinstance(content, str) and content.strip():
                return content.strip().splitlines()[0][:80]
            if isinstance(content, list):
                for block in content:
                    if block.get("type") == "text" and block.get("text", "").strip():
                        return block["text"].strip().splitlines()[0][:80]
        except (json.JSONDecodeError, AttributeError):
            continue

    return "Task completed"


def get_tmux_context():
    try:
        session = subprocess.check_output(
            ["tmux", "display-message", "-p", "#S"], encoding="utf-8"
        ).strip()
        window = subprocess.check_output(
            ["tmux", "display-message", "-p", "#W"], encoding="utf-8"
        ).strip()
        return session, window
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None, None


def main():
    try:
        data = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, ValueError):
        return

    summary = get_summary(data.get("transcript_path"))
    session, window = get_tmux_context()

    context = ""
    if session and window:
        context = f"session_id: {session}, window_id: {window}\n"

    message = f"{context}{summary}"

    cmd = [
        "terminal-notifier",
        "-title", "Skynet",
        "-message", message,
        "-activate", "com.mitchellh.ghostty",
        "-sound", "Funk",
    ]
    if os.path.exists(LOGO_PATH):
        cmd += ["-contentImage", LOGO_PATH]

    subprocess.run(cmd, check=False)


if __name__ == "__main__":
    main()
