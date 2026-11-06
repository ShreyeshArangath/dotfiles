import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
BAR_COMMIT = "d9cdd88cb734615e96b1c37ed17fc39be904f060"
FAKE_HERDR = r'''
import json, os, sys
from pathlib import Path
state_path = Path(os.environ["PLUGIN_TEST_STATE"])
state = json.loads(state_path.read_text())
args = sys.argv[1:]
if args == ["plugin", "list", "--json"]:
    print(json.dumps({"result": {"plugins": list(state["plugins"].values())}}))
else:
    state["calls"].append(args)
    if args[:2] == ["plugin", "install"]:
        owner, repo = args[2].split("/")
        plugin_id = {"herdr-bar": "herdr-bar", "herdr-reviewr": "persiyanov.reviewr", "herdr-git": "shrey.git"}[repo]
        state["plugins"][plugin_id] = {"plugin_id": plugin_id, "enabled": True,
            "source": {"kind": "github", "owner": owner, "repo": repo, "resolved_commit": args[4]}}
    elif args[:2] == ["plugin", "enable"]:
        state["plugins"][args[2]]["enabled"] = True
    else:
        sys.exit(98)
    state_path.write_text(json.dumps(state))
'''


class HerdrPluginTests(unittest.TestCase):
    def restore(self, plugins, repetitions=1):
        with tempfile.TemporaryDirectory(prefix="herdr-plugins-") as folder:
            root = Path(folder)
            stub = root / "herdr"
            stub.write_text(f"#!{sys.executable}\n" + FAKE_HERDR)
            stub.chmod(0o755)
            state = root / "state.json"
            state.write_text(json.dumps({"plugins": plugins, "calls": []}))
            env = dict(os.environ, PLUGIN_TEST_STATE=str(state), PATH=f"{root}:{os.environ['PATH']}")
            for _ in range(repetitions):
                subprocess.run([sys.executable, str(ROOT / "herdr/install-plugins.py")],
                               cwd=root, env=env, check=True, capture_output=True, text=True)
            return json.loads(state.read_text())

    def test_fresh_restore_installs_pinned_plugins_once(self):
        state = self.restore({}, repetitions=2)
        installs = [call for call in state["calls"] if call[:2] == ["plugin", "install"]]
        self.assertEqual([call[2] for call in installs], [
            "jeffarese/herdr-bar", "ShreyeshArangath/herdr-reviewr", "ShreyeshArangath/herdr-git"])
        for call in installs:
            self.assertEqual(call[3], "--ref")
            self.assertRegex(call[4], r"^[0-9a-f]{40}$")
            self.assertEqual(call[5:], ["--yes"])
        self.assertTrue(all(plugin["enabled"] for plugin in state["plugins"].values()))

    def test_restore_preserves_local_links_and_replaces_upstream_reviewr(self):
        state = self.restore({
            "shrey.git": {"plugin_id": "shrey.git", "enabled": False, "source": {"kind": "local"}},
            "herdr-bar": {"plugin_id": "herdr-bar", "enabled": True, "source": {
                "kind": "github", "owner": "jeffarese", "repo": "herdr-bar", "resolved_commit": BAR_COMMIT}},
            "persiyanov.reviewr": {"plugin_id": "persiyanov.reviewr", "enabled": True, "source": {
                "kind": "github", "owner": "persiyanov", "repo": "herdr-reviewr", "resolved_commit": "old"}},
        })
        self.assertEqual(state["calls"], [
            ["plugin", "install", "ShreyeshArangath/herdr-reviewr", "--ref",
             "2aee9c5dd976c90e28b251e77f199c919aefaf29", "--yes"],
            ["plugin", "enable", "shrey.git"],
        ])
        self.assertEqual(state["plugins"]["shrey.git"]["source"], {"kind": "local"})


if __name__ == "__main__":
    unittest.main()
