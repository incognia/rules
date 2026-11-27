"""Tests for scripts/python_check.py. Run: python3 -m unittest discover -s tests"""

import os
import subprocess
import sys
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "scripts"))

import python_check  # noqa: E402


class StatusTest(unittest.TestCase):
    def test_end_of_life_branch_is_refused(self):
        ok, reason = python_check.status((3, 9, 21))
        self.assertFalse(ok)
        self.assertIn("end of life", reason)

    def test_each_branch_below_its_minimum_is_refused(self):
        for branch, patch in python_check.MINIMUMS.items():
            ok, reason = python_check.status(branch + (patch - 1,))
            self.assertFalse(ok, branch)
            self.assertIn("lacks security fixes", reason)

    def test_each_branch_at_its_minimum_passes(self):
        for branch, patch in python_check.MINIMUMS.items():
            self.assertTrue(python_check.status(branch + (patch,))[0], branch)

    def test_newer_branch_passes(self):
        newest = max(python_check.MINIMUMS)
        self.assertTrue(python_check.status((newest[0], newest[1] + 1, 0))[0])

    def test_message_names_interpreter_minimums_and_escape_hatch(self):
        text = python_check.message("Python 3.9 is end of life")
        self.assertIn(sys.executable, text)
        self.assertIn(python_check.ENV_PREFIX + "ALLOW_PYTHON", text)
        for branch, patch in python_check.MINIMUMS.items():
            self.assertIn("%d.%d.%d" % (branch + (patch,)), text)


class CopiesTest(unittest.TestCase):
    def test_every_plugin_copy_is_identical(self):
        with open(os.path.join(ROOT, "scripts", "python_check.py"), "rb") as handle:
            reference = handle.read()
        plugins = os.path.join(ROOT, "plugins")
        for plugin in sorted(os.listdir(plugins)):
            copy = os.path.join(plugins, plugin, "scripts", "python_check.py")
            if os.path.exists(copy):
                with open(copy, "rb") as handle:
                    self.assertEqual(reference, handle.read(), copy)


class ExampleHelperTest(unittest.TestCase):
    helper = os.path.join(ROOT, "plugins", "example", "scripts", "hello.py")

    def run_helper(self, *args):
        return subprocess.run([sys.executable, self.helper] + list(args), capture_output=True, text=True)

    def test_prints_one_json_object(self):
        result = self.run_helper("Ada")
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout.strip(), '{"greeting": "Hello, Ada"}')

    def test_invalid_field_is_named(self):
        result = self.run_helper(" ")
        self.assertEqual(result.returncode, 1)
        self.assertIn("ERROR [name]", result.stderr)


if __name__ == "__main__":
    unittest.main()
