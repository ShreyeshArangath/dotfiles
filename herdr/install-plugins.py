#!/usr/bin/env python3
"""Restore the plugins used by herdr/config.toml, preserving local dev links."""

import json
import subprocess


PLUGINS = (
    ("herdr-bar", "jeffarese/herdr-bar", "d9cdd88cb734615e96b1c37ed17fc39be904f060"),
    ("persiyanov.reviewr", "ShreyeshArangath/herdr-reviewr", "2aee9c5dd976c90e28b251e77f199c919aefaf29"),
    ("shrey.git", "ShreyeshArangath/herdr-git", "fee207820a98b916c237750fdd70d3c4e60a551d"),
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
