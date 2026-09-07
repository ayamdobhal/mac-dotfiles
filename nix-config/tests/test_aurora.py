import importlib.util
from pathlib import Path
import plistlib
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("aurora", Path(__file__).parents[1] / "modules/home/scripts/apply-aurora.py")
aurora = importlib.util.module_from_spec(spec)
spec.loader.exec_module(aurora)


class AuroraTests(unittest.TestCase):
    def test_backup_selection(self):
        self.assertEqual(aurora.apply_commands("", "", "1.2.3", "2.44"), ["backup", "apply"])
        self.assertEqual(aurora.apply_commands("1.2.2", "2.44", "1.2.3", "2.44"), ["backup", "apply"])
        self.assertEqual(aurora.apply_commands("1.2.3", "2.43", "1.2.3", "2.44"), ["restore", "backup", "apply"])
        self.assertEqual(aurora.apply_commands("1.2.3", "2.44", "1.2.3", "2.44"), ["apply"])

    def test_missing_version(self):
        self.assertIsNone(aurora.application_version("not-a-version=1"))
        self.assertEqual(aurora.application_version('app.last-launched-version="1.2.3.hash"'), "1.2.3.hash")

    def fixture(self, folder):
        home = Path(folder)
        source = home / "source"
        (source / "theme").mkdir(parents=True)
        (source / "theme/user.css").write_text("/* Aurora */")
        (source / "extensions").mkdir()
        (source / "extensions/test.js").write_text("// extension")
        spotify = home / "Spotify.app"
        (spotify / "Contents").mkdir(parents=True)
        (spotify / "Contents/Info.plist").write_bytes(plistlib.dumps({"CFBundleShortVersionString": "1.2.3"}))
        prefs = home / "Library/Application Support/Spotify/prefs"
        prefs.parent.mkdir(parents=True)
        prefs.write_text('app.last-launched-version="1.2.3.hash"')
        root = home / ".config/spicetify"
        root.mkdir(parents=True)
        config = root / "config-xpui.ini"
        config.write_text("[Backup]\nversion = 1.2.3.hash\nwith = 2.44\n[AdditionalOptions]\ncustom_apps = marketplace\n")
        state = home / "state"
        state.mkdir()
        return source, home, state, spotify, config

    def test_deploy_is_idempotent_and_keeps_backup_metadata(self):
        with tempfile.TemporaryDirectory() as folder:
            source, home, state, spotify, config = self.fixture(folder)
            with patch.object(aurora.subprocess, "check_output", return_value="2.44\n"), patch.object(aurora.subprocess, "run") as run:
                aurora.deploy(source, home, state, cli=Path("/fake/spicetify"), spotify=spotify)
                self.assertEqual(run.call_args.args[0][-1], "apply")
                self.assertIn("--no-restart", run.call_args.args[0])
                cfg = aurora.read_config(config)
                self.assertEqual(cfg["Backup"]["version"], "1.2.3.hash")
                self.assertEqual(cfg["AdditionalOptions"]["extensions"], "test.js")
                self.assertEqual(cfg["AdditionalOptions"]["custom_apps"], "")
                self.assertTrue((state / "before-nix/config-xpui.ini").exists())
                run.reset_mock()
                aurora.deploy(source, home, state, cli=Path("/fake/spicetify"), spotify=spotify)
                run.assert_not_called()

    def test_failure_is_not_marked_successful(self):
        with tempfile.TemporaryDirectory() as folder:
            source, home, state, spotify, config = self.fixture(folder)
            with patch.object(aurora.subprocess, "check_output", return_value="2.44"), patch.object(aurora.subprocess, "run", side_effect=[None, subprocess.CalledProcessError(1, "apply")]):
                with self.assertRaises(subprocess.CalledProcessError):
                    aurora.deploy(source, home, state, cli=Path("/fake/spicetify"), spotify=spotify)
            self.assertFalse((state / "applied.json").exists())


if __name__ == "__main__":
    unittest.main()
