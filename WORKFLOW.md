# WORKFLOW.md — how to keep improving the app now that it is live

You are not a coder, but you own the product. This is the setup professional teams use,
scaled down to one person. Read once, then follow the checklist at the bottom forever.

---

## 1. Your toolbox (what replaces Emergent)

| Need | Tool | Cost | Why |
|---|---|---|---|
| Write the code for you | **Claude Code** (terminal) — recommended | ~$20/mo Pro (or API pay-as-you-go) | Reads the whole repo, edits files, runs commands, makes commits. Closest to what you're used to, but on **your** machine and **your** repo. |
| Alternative / visual editor | **Cursor** (VS Code fork) | free tier / $20/mo | Same idea with a friendly editor UI. Good if you like seeing files. |
| Alternative | **GitHub Copilot Coding Agent** | $10-20/mo | You file a GitHub issue, it opens a pull request. Very hands-off. |
| Store code + history | **GitHub** (already done) | free | Every version is saved; you can always go back. |
| Ship to server | **GitHub Actions** (already done) | free | Push → live in ~4 min. |
| Server | **DigitalOcean droplet** (already done) | ~$6-12/mo | You own it. |
| Database | **MongoDB Atlas** (already done) | free M0 → $9/mo M2 | Managed backups. |
| Know when it breaks | **Better Stack** or **UptimeRobot** | free tier | Emails/WhatsApp you within a minute of downtime. |
| See errors customers hit | **Sentry** | free tier | Shows the exact error + which screen, before customers complain. |

**Recommendation for you:** Claude Code + GitHub + your droplet. That's it. Nothing else
is required. Add Sentry and an uptime monitor when you have real daily usage.

---

## 2. One-time setup on your laptop (30 min)

```bash
# 1. install git + node + python (Mac: brew install git node python; Windows: use WSL2)
# 2. get your code
git clone https://github.com/YOUR_USERNAME/somanifabs.git
cd somanifabs

# 3. install Claude Code
npm install -g @anthropic-ai/claude-code
claude          # log in once, then just run `claude` inside the repo folder
```

The repo already contains **`CLAUDE.md`** — a briefing file that tells any AI tool how
this app is built and what it must never break. Keep it updated; it is the single
biggest reason your AI edits will stay safe and professional.

### A safe local playground (do this — it is what makes you fearless)
Never test against the live shop database.

1. In MongoDB Atlas, create a **second free cluster** (or just a second database name)
   called `somanifabs_dev`.
2. In your local repo create `backend/.env` with the dev connection string and
   `DB_NAME=somanifabs_dev`, plus your own test admin user and the Gemini key.
3. Create `frontend/.env` with `REACT_APP_BACKEND_URL=http://localhost:8001`.
4. Run it:

```bash
cd backend && pip install -r requirements.prod.txt && uvicorn server:app --reload --port 8001
# new terminal
cd frontend && yarn install && yarn start        # opens http://localhost:3000
```

Now you can break anything with zero risk to the shop.

---

## 3. The change loop (use this every single time)

```
1. git checkout staging && git pull              # start from the tested copy
2. git checkout -b change/whatsapp-share         # a branch = a safe sandbox
3. claude                                        # describe the change in plain English
4. bash dev.sh          -> test it at localhost:3000
5. bash check.sh        -> must say "All checks passed"
6. bash ship.sh "Add WhatsApp share button"      # commits + pushes (+ deploys on main/staging)
7. merge the branch into `staging` on GitHub -> check https://staging.somanifabs.com
8. happy? merge `staging` into `main` -> the shop website updates
```

`ship.sh` runs `check.sh` for you, refuses to push a broken build, asks for confirmation
before touching `main`, and — if you have the GitHub CLI (`gh`) installed — triggers the
deploy and streams the progress in your terminal. Without `gh`, just click
**Actions → Deploy → Run workflow** on GitHub instead.

Why branches + pull request? Because `main` is what your shop runs on. A branch lets you
try, throw away, or park an idea. Merging is a deliberate one-click act — that is the
whole discipline, and it is what separates "hobby" from "professional".

**Never** edit files directly on the droplet. The droplet is disposable; GitHub is the truth.

### How to talk to Claude Code (this is the real skill)
Bad: *"make the app better"*.
Good:

> Read CLAUDE.md first. In SessionView.js, add a "Send on WhatsApp" button on the
> try-on preview modal that opens wa.me with the customer's mobile number and a short
> Hinglish message. Add the button text to all three languages in i18n.js. Add a
> data-testid. Don't change generation logic. Then run `CI=true yarn build` and show me
> what changed.

Rules that pay off:
- One change per request. Small changes are easy to review and easy to undo.
- Always say *"read CLAUDE.md first"*.
- Always ask it to run the build/import check at the end.
- Ask *"explain in simple words what you changed and what could break"* before merging.
- If it goes in circles twice, `git checkout .` to throw it away and re-describe the goal.

---

## 4. When something goes wrong in production

```bash
ssh root@YOUR_DROPLET_IP
cd /opt/somanifabs
docker compose ps                      # is anything down?
docker compose logs --tail=100 backend # what is the error?
```

**Instant rollback (memorise this):**

```bash
cd /opt/somanifabs
git log --oneline -10                  # find the last good commit id
git checkout <good_commit_id>
docker compose up -d --build           # shop is back on the old version
```

Then fix properly on a branch and merge. To undo a bad merge in GitHub history:
open the merged Pull Request → **Revert** → merge that → auto-deploys the fix.

---

## 5. Optional next-level setup (add when you feel ready)

1. **Staging site** — a second copy at `staging.somanifabs.com` (either a second small
   droplet, or the same droplet on different ports with its own `.env` + `somanifabs_stage`
   database) that deploys from a `staging` branch. You test there like a real user, then
   merge to `main`. This is the biggest single upgrade to your confidence.
2. **Sentry** — 10 minutes to add; tells you about errors before your staff do.
3. **Uptime monitor** on `https://somanifabs.com/health` → alert to your phone.
4. **Nightly Atlas backup** + a monthly DigitalOcean snapshot.
5. **A simple roadmap** — keep GitHub *Issues* as your idea list. Write ideas the moment
   staff mention them; pick one per week. Slow and steady beats big rewrites.

---

## 6. Your permanent checklist

- [ ] Ideas go into GitHub Issues, not your memory.
- [ ] One idea = one branch = one pull request.
- [ ] Test locally on the dev database before merging.
- [ ] `CI=true yarn build` clean + backend imports before merging.
- [ ] Merge to `main` only when you have 10 quiet minutes to check the live site after.
- [ ] Never deploy anything on a busy shop evening.
- [ ] Keep `CLAUDE.md` updated when the architecture changes.
- [ ] Keep a copy of the droplet `.env` in a password manager.
