#!/usr/bin/env python3
"""Restore the plugins used by herdr/config.toml, preserving local dev links."""

import json
import subprocess


PLUGINS = (
    ("herdr-bar", "jeffarese/herdr-bar", "d9cdd88cb734615e96b1c37ed17fc39be904f060"),
    ("persiyanov.reviewr", "ShreyeshArangath/herdr-reviewr", "b0fbb6b8c26dc7080ea01a41048d138fee7f8bf9"),
    ("shrey.git", "ShreyeshArangath/herdr-git", "2e929e878a53322488b7353a9c044a0a5683b863"),
)


def main():
    response = subprocess.check_output(["herdr", "plugin", "list", "--json"], text=True)
    installed = {plugin["plugin_id"]: plugin for plugin in json.loads(response)["result"]["plugins"]}
    for plugin_id, repository, commit in PLUGINS:
        plugin = installed.get(plugin_id, {})
        source = plugin.get("source", {})
        if source.get("kind") == "local":
            print(f"Keep local development link: {plugin_id}", flush=True)
        elif (source.get("kind") == "github"
              and f"{source.get('owner')}/{source.get('repo')}" == repository
              and source.get("resolved_commit") == commit):
            print(f"Already installed: {plugin_id} at {commit[:7]}", flush=True)
        else:
            subprocess.run(["herdr", "plugin", "install", repository, "--ref", commit, "--yes"], check=True)
        if not plugin.get("enabled", False):
            subprocess.run(["herdr", "plugin", "enable", plugin_id], check=True)


if __name__ == "__main__":
    main()
