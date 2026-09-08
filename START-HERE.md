# START-HERE.md — the simple system (for a non-coder)

You will **never type a git command**. You talk to Claude in a window, in plain English,
and Claude does the work. This page is the whole system.

---

## First, three words explained

**Your folder.** There is exactly **one** folder on your computer with your app in it,
e.g. `Documents/somanifabs`. There is no copy inside it. One folder.

**Git.** A time machine for that folder. Every time you publish (and every time Claude
saves), git stores the complete state of the folder. You can return to any earlier state
in a minute. Nothing is ever really lost.

**Branch.** A *name for a line of versions* — not a folder. Switching branch makes git
rewrite the files inside your one folder to match that version. `main` is the line your
live website is built from. You mostly won't need any other branch (see Part 4).

---

## PART 1 — Setup (once, about 30 minutes)

**1.** Go to <https://claude.ai> and subscribe to **Pro** (~$20/month). Claude Code is included.

**2.** Install the **Claude desktop app**: <https://claude.ai/download> (Mac or Windows).
Open it, log in, let it update itself.

**3.** Create an empty folder, e.g. `Documents/somanifabs`. In the Claude app open the
**Code** tab → **select project folder** → choose that folder.

**4.** Paste this message to Claude (change the username and your operating system):

> Download my project from GitHub into this folder. My repository is
> `https://github.com/MY_USERNAME/somanifabs`. Install whatever my computer needs
> (git, node, yarn, python). Guide me one step at a time in simple words — I am not a
> programmer. I am on a Mac.

Claude asks permission before each command — click **Allow**.

**5.** Paste this last setup message:

> Read CLAUDE.md and WORKFLOW.md so you know this project's rules. Then make sure
> `bash check.sh` runs successfully on my computer, fixing anything that is missing.
> Explain what you did in simple words.

When it reports the check passed, setup is finished. You never do Part 1 again.

---

## PART 2 — The loop for ANY change (four messages)

Open the Claude app → **Code** tab → your project folder. Send these one at a time.

**Message 1 — always start with this**

> Read CLAUDE.md first, then wait for my instruction.

**Message 2 — say what you want, in your own words**

> Here is the change I want: <describe it plainly — what screen, what should happen,
> who uses it>. Keep it small and don't change anything else. Follow the rules in
> CLAUDE.md. If any new text appears on screen, add it in all three languages.

**Message 3 — see it before anyone else does**

> Run `bash dev.sh` so I can test the app on my own computer, and tell me which address
> to open.

Open that address (usually `http://localhost:3000`) and use the app the way your staff
would. **This is a private copy using a test database — real customer data cannot be
touched.** Keep telling Claude what to adjust until you are happy.

**Message 4 — publish**

> Run `bash check.sh`. If it passes, run `bash ship.sh "<short description of the
> change>"`, then tell me in simple words what happened and whether the live website was
> updated.

Then open your live website and look. That's the entire cycle.

*(Prefer your own deploy button? Say "just push, don't deploy" and click
**Actions → Deploy → Run workflow** on GitHub instead.)*

---

## PART 3 — What each command does

| Command | In plain English | Why it exists |
|---|---|---|
| `bash dev.sh` | Runs a **private copy** of the app on your own computer with a **test database** | So you can click around and judge the change before customers see it. Cannot affect the shop. |
| `bash check.sh` | Builds the app the same strict way the server does | If this fails, the deploy would have failed too. It catches the mistake before it reaches the shop. |
| `bash ship.sh "message"` | Saves the change, sends it to GitHub, updates the live website | Your publish button. Refuses to publish a broken build; asks you to type `live` first. |

---

## PART 4 — Do you need a branch every time? No.

You are one person making one change at a time and testing it before publishing, so
**work directly and just use Part 2**. If you dislike a change, say:

> Undo everything you just changed and go back to the last saved version.

Git makes that instant and exact — that is the protection a branch would have given you.

**Use a branch only when:**
- the change is big and will take you several days, or
- you want to pause halfway and come back later.

Then say:

> Put this work on a separate branch named `<any label you like>` so my live version
> stays untouched, and tell me how to get back to my normal version.

And when it is tested and you want it live:

> Publish that branch to the live website and then delete the branch.

The name is only a label for you. Nothing depends on it.

---

## PART 5 — When something goes wrong

Paste this to Claude:

> Something is broken. Read CLAUDE.md, look at the error below, explain in simple words
> what happened, then fix it and run `bash check.sh`.
> <paste the red error text here>

If the **live website** is broken after a publish:

> The live website is broken. Put the previous working version back on the server right
> now, then explain in simple words what went wrong.

---

## PART 6 — Five rules

1. One change at a time. Never ask for three things at once.
2. Always begin a session with *"Read CLAUDE.md first."*
3. Always test with `bash dev.sh` before publishing.
4. Publish in the morning, never on a busy shop evening — then watch the site for 10 minutes.
5. Before publishing, ask: *"Explain in simple words what you changed and what could
   break."* If it mentions anything you did not ask for, say *"undo that, do only what I
   asked."*

---

Setup once (Part 1). Then four messages per change (Part 2). That is the whole system.
