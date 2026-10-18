import os, shutil, subprocess, tempfile, unittest

HERE = os.path.dirname(os.path.abspath(__file__))
SCRIPT = os.path.join(HERE, "..", "skills", "debug-root-cause", "scripts", "what_changed.sh")


def git(cwd, *args):
    env = dict(os.environ, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t")
    subprocess.run(["git"] + list(args), cwd=cwd, check=True, capture_output=True, env=env)


class WhatChangedTests(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()
        git(self.dir, "init", "-q")
        self.write("app.js", "console.log(1)\n")
        self.write("package.json", '{"dependencies": {"left-pad": "1.0.0"}}\n')
        git(self.dir, "add", "-A")
        git(self.dir, "commit", "-q", "-m", "init")
        git(self.dir, "tag", "v1")
        self.write("package.json", '{"dependencies": {"left-pad": "1.3.0"}}\n')
        self.write(".env.example", "API_URL=\n")
        self.write("app.js", "console.log(2)\n")
        git(self.dir, "add", "-A")
        git(self.dir, "commit", "-q", "-m", "bump left-pad")
        self.write("app.js", "console.log(3)\n")

    def tearDown(self):
        shutil.rmtree(self.dir)

    def write(self, rel, text):
        with open(os.path.join(self.dir, rel), "w") as fh:
            fh.write(text)

    def run_script(self, *args):
        return subprocess.run(["bash", SCRIPT] + list(args), cwd=self.dir, capture_output=True, text=True)

    def test_ref_range(self):
        r = self.run_script("v1")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("bump left-pad", r.stdout)
        self.assertNotIn(" init", r.stdout.split("== Commits")[1].split("==")[0])
        self.assertIn("package.json", r.stdout.split("== Dependency changes")[1])
        self.assertIn("1.3.0", r.stdout)
        self.assertIn(".env.example", r.stdout.split("== Config")[1])

    def test_uncommitted_shown(self):
        r = self.run_script()
        self.assertIn("M app.js", r.stdout)

    def test_date_mode(self):
        r = self.run_script("1 hour ago")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("bump left-pad", r.stdout)

    def test_not_a_repo(self):
        d = tempfile.mkdtemp()
        try:
            r = subprocess.run(["bash", SCRIPT], cwd=d, capture_output=True, text=True)
            self.assertEqual(r.returncode, 1)
        finally:
            shutil.rmtree(d)


if __name__ == "__main__":
    unittest.main()
