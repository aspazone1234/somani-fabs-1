# LAPTOP-SETUP.md — from a brand-new laptop to shipping code

You have a fresh laptop and no AI subscription. This is the exact order to do things.
Total time: about one hour. Cost to start: **₹0**.

---

## PART A — Which AI coding tool should you pay for? (as of mid-2026)

Honest picture of the market:

| Tool | Price | Reality |
|---|---|---|
| **GitHub Copilot Free** | **₹0** | Best free starting point. Unlimited inline completions, limited chat/agent requests per month. Works inside VS Code. Enough to make small changes and learn. |
| **Antigravity CLI (Google)** | **₹0** | Google's free terminal agent for individuals (replaced the old free Gemini Code Assist tier). Good second free option. |
| **GitHub Copilot Pro** | **~$10/mo** | Cheapest paid tier. Credit-based for agent work (1,500 credits included). Also gives you the *coding agent*: file a GitHub issue → it opens a pull request for you. Very good fit for a non-coder owner. |
| **Claude Code** (Claude Pro) | **~$20/mo** | The closest thing to your Emergent experience, and the strongest at "read my whole repo and make this change safely". No free tier. Heavy daily use may need Max ($100/mo). **My recommendation once you're ready to pay.** |
| **Cursor Pro** | **~$20/mo** | An editor with AI built in. Best if you like *seeing* the files and clicking. Monthly model allowance, then pay-as-you-go. |
| **Aider** | free tool + API costs | Terminal agent, you pay only for tokens used. Cheapest for occasional work, but least beginner-friendly. |

Prices and quotas change often — check the vendor page before paying.

**Recommended path for you:**
1. **Week 1-2:** VS Code + **GitHub Copilot Free**. Make tiny changes (text, colours, a button).
   Learn the branch → test → merge loop with zero money at risk.
2. **When you feel limited** (you will, within a couple of weeks): subscribe to **Claude Pro
   ($20/mo)** and use **Claude Code** in the terminal. That single tool + your GitHub +
   your droplet is a complete professional setup.
3. Only if you start shipping several changes a week, consider Claude Max or Copilot Pro+.

One warning about budget: agentic AI tools bill by usage underneath the flat fee. Set a
spend limit in the vendor dashboard on day one so a runaway session can't surprise you.

---

## PART B — Install the basics

### If your laptop is a Mac
Open **Terminal** and paste these one at a time:

```bash
# 1. Xcode command line tools (includes git)
xcode-select --install

# 2. Homebrew (the Mac software installer)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. The things this project needs
brew install git node python@3.11
npm install -g yarn

# 4. Check everything
git --version && node --version && python3 --version && yarn --version
```

### If your laptop is Windows
Use **WSL2** (a real Ubuntu inside Windows). Every command in this project then works
exactly like on the droplet — this saves you a lot of pain.

1. Open **PowerShell as Administrator** and run: `wsl --install` → restart the laptop.
2. Open the **Ubuntu** app from the Start menu, create a username/password.
3. Inside Ubuntu, paste:

```bash
sudo apt update && sudo apt install -y git python3 python3-venv python3-pip curl
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g yarn
git --version && node --version && python3 --version && yarn --version
```

### Also install (both platforms)
- **VS Code** — <https://code.visualstudio.com> (your window into the code)
- Extensions inside VS Code: *Python*, *ESLint*, *GitHub Copilot* (sign in with the free tier)
- Optional: **GitHub Desktop** — <https://desktop.github.com> — if you'd rather click than type git commands

---

## PART C — Connect your laptop to GitHub

```bash
git config --global user.name "Your Name"
git config --global user.email "you@email.com"

# create an SSH key so you never type passwords
ssh-keygen -t ed25519 -C "my-laptop" -N ""
cat ~/.ssh/id_ed25519.pub
```

Copy that output → GitHub → **Settings → SSH and GPG keys → New SSH key** → paste → save.

Test and get the code:

```bash
ssh -T git@github.com          # should say "Hi YOUR_USERNAME!"
mkdir -p ~/code && cd ~/code
git clone git@github.com:YOUR_USERNAME/somanifabs.git
cd somanifabs
code .                         # opens the project in VS Code
```

---

## PART D — Make a safe dev database

Never let your laptop touch the shop's live data.

1. MongoDB Atlas → your project → **Network Access** → add your home IP (or `0.0.0.0/0`).
2. You do **not** need a new cluster — just a different database name.
3. In the project folder run:

```bash
bash dev.sh
```

The first run creates `backend/.env` from the template and stops. Open `backend/.env` in
VS Code and fill in:

- `MONGO_URL` → same Atlas string as production
- `DB_NAME` → **`somanifabs_dev`**  ← the important difference
- `JWT_SECRET` → any random text
- `SUPER_ADMIN_USERNAME` / `SUPER_ADMIN_PASSWORD` → your test login
- `GEMINI_API_KEY` → your Google AI Studio key
- models → `gemini-3.1-flash-image` / `gemini-2.5-flash-image`

Then run it again:

```bash
bash dev.sh
```

Backend starts on <http://localhost:8001>, the app opens on <http://localhost:3000>.
It's a complete private copy of your shop app. Break it freely. `Ctrl+C` stops both.

---

## PART E — Your first real change (do this today, it's the whole skill)

```bash
git checkout main && git pull
git checkout -b change/my-first-edit
```

Now change something tiny and visible — e.g. in `frontend/src/i18n.js`, edit a piece of
text. Use Copilot/Claude Code, or just type it yourself in VS Code. Watch
<http://localhost:3000> update instantly.

```bash
cd frontend && CI=true yarn build && cd ..     # must finish without errors
git add -A
git commit -m "Reword the session screen heading"
git push -u origin change/my-first-edit
```

GitHub → **Compare & pull request** → look at the green/red diff → **Merge**.
Wait ~4 minutes → refresh <https://somanifabs.com> → your change is live, and you did it
without Emergent. That loop is now yours forever.

Next: read `WORKFLOW.md` (the daily discipline) and `STAGING-SETUP.md` (test like a real
user before customers see anything).
