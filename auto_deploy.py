import subprocess, time, os, sys

GH = r"C:\Users\faysal\.gemini\antigravity\scratch\gh\bin\gh.exe"
GIT = r"C:\Users\faysal\.gemini\antigravity\scratch\mingit\cmd\git.exe"
UCRT_GIT = r"C:\Users\faysal\.gemini\antigravity\scratch\mingit\ucrt64\bin\git.exe"
CWD = r"C:\Users\faysal\.gemini\antigravity\scratch\twenty_nine_card_game"

def run(cmd, cwd=CWD):
    env = os.environ.copy()
    env["PATH"] = r"C:\Users\faysal\.gemini\antigravity\scratch\mingit\ucrt64\bin;C:\Users\faysal\.gemini\antigravity\scratch\mingit\cmd;C:\Users\faysal\.gemini\antigravity\scratch\gh\bin;" + env.get("PATH", "")
    p = subprocess.run(cmd, shell=True, cwd=cwd, env=env, capture_output=True, text=True)
    return p.returncode, p.stdout.strip(), p.stderr.strip()

print("Waiting for GitHub authorization...")
for _ in range(60):
    code, out, _ = run(f'"{GH}" auth status')
    if code == 0:
        print("Authenticated successfully with GitHub!")
        break
    time.sleep(2)
else:
    print("Auth timed out. Please authorize at https://github.com/login/device")
    sys.exit(1)

print("Configuring git credential helper...")
run(f'"{GH}" auth setup-git')

print("Committing updates...")
run(f'"{UCRT_GIT}" add .')
run(f'"{UCRT_GIT}" commit -m "fix: replace deprecated bluetooth with modern nearby_connections and fix score_board import"')

print("Pushing to GitHub...")
code, out, err = run(f'"{UCRT_GIT}" push -u origin main')
print("Push output:", out or err)

print("Monitoring GitHub Actions build...")
time.sleep(5)
for _ in range(60):
    code, out, err = run(f'"{GH}" run list -R zodf3/Game --limit 1')
    print("Latest run:", out.splitlines()[0] if out else "fetching...")
    if "completed" in out.lower() or "success" in out.lower():
        break
    time.sleep(10)

print("Downloading release APK...")
run(f'"{GH}" run download -R zodf3/Game -n TwentyNine-Release-APK --dir .')
if os.path.exists(os.path.join(CWD, "app-release.apk")):
    print("APK DOWNLOADED SUCCESSFULLY TO:", os.path.join(CWD, "app-release.apk"))
