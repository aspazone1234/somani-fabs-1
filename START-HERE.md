# START-HERE.md — the simple version (for a non-coder)

You will **never type git commands**. You will talk to Claude in a window, in English,
and Claude does the work. This page is the whole system on one page.

---

## PART 1 — One-time setup (about 30 minutes)

### 1. Subscribe to Claude Pro
Go to <https://claude.ai> → subscribe to **Pro** (~$20/month). This includes Claude Code.

### 2. Install the Claude desktop app
Download from <https://claude.ai/download> (works on Mac and Windows). Install, open it,
log in. Make sure it updates itself to the latest version.

### 3. Get your project on your computer
Open the Claude app → click the **Code** tab → **select a project folder**.
If you don't have the project on your computer yet, first make an empty folder
(e.g. `Documents/somanifabs`), select it, and then paste this message to Claude:

> Download my project from GitHub into this folder. My repository is
> `https://github.com/MY_USERNAME/somanifabs`. Install anything you need
> (git, node, yarn, python) and tell me one step at a time in simple words.
> I am not a programmer. I am on a Mac / on Windows (delete the wrong one).

Claude will ask permission before running each command — click **Allow**. That's it:
your code is now on your computer and Claude can see all of it.

### 4. One last setup message
Paste this to Claude:

> Read the files CLAUDE.md and WORKFLOW.md in this project so you know the rules.
> Then check that `bash check.sh` runs successfully, and fix anything missing on my
> computer so it does. Explain what you did in simple words.

When Claude says the check passed, your setup is complete. You never do this again.

---

## PART 2 — Making a change (every time, 4 messages)

Open the Claude app → **Code** tab → your project. Then send these four messages, one
after the other, waiting for Claude to finish each time.

**Message 1 — start safely**

> Read CLAUDE.md first. Then create a new branch for a change called
> "whatsapp-share" and tell me when you're ready.

*(A "branch" is a private copy of the app. Anything you do in it cannot affect the shop's
live website until you deliberately publish it. This is your seatbelt.)*

**Message 2 — ask for the change**

> Now do this change: <describe it in plain English, e.g. "On the try-on preview screen,
> add a button that sends the generated photo to the customer on WhatsApp using their
> saved mobile number">.
> Keep it small, don't change anything else, add the button text in all three languages,
> and follow the rules in CLAUDE.md.

**Message 3 — try it yourself before anyone else does**

> Run `bash dev.sh` so I can open the app on my own computer and test it.
> Tell me the address to open.

Open the address it gives you (usually <http://localhost:3000>) in your browser and use
the app like your staff would. This is a **private copy with a test database** — you
cannot damage real customer data here. Tell Claude what you want fixed until you're happy.

**Message 4 — publish it**

> Run `bash check.sh`. If it passes, run
> `bash ship.sh "Add WhatsApp share button"` and then tell me in simple words what
> happened and whether the website was updated.

`check.sh` is the safety gate. `ship.sh` saves your change, sends it to GitHub, and
deploys it. Then open <https://somanifabs.com> and see your change live.

*(If you prefer your own manual deploy button: tell Claude "just push, don't deploy",
then click **Actions → Deploy → Run workflow** on GitHub as you do today.)*

---

## PART 3 — What those three commands actually do

| Command | In plain English | Why you need it |
|---|---|---|
| `bash dev.sh` | Starts a **private copy** of your app on your own computer, using a test database | So you can click around and see the change before customers do. Nothing here touches the shop. |
| `bash check.sh` | Builds the app the same strict way your server does | If this fails, the deploy would have failed too. It catches the mistake **before** it reaches the shop. |
| `bash ship.sh "message"` | Saves the change, sends it to GitHub, and updates the live website | This is your publish button. It refuses to publish if `check.sh` failed, and asks you to type `live` before touching the real website. |

And two words you'll keep hearing:

- **Branch** = a private copy of the app where you experiment. Free, unlimited, harmless.
- **Merge / publish** = deliberately moving that copy into the real website.

---

## PART 4 — When something goes wrong

Paste this to Claude:

> Something is broken. Read CLAUDE.md, look at the error below, explain in simple words
> what happened, and fix it. Then run `bash check.sh`.
> <paste the red error text here>

If the **live website** breaks after a publish, paste this:

> The live website is broken. Undo my last change on the server immediately and put the
> previous working version back. Then explain what went wrong.

Nothing is ever permanently lost — every version of your app is saved in GitHub forever,
and going back is a one-minute job.

---

## PART 5 — Your five rules

1. One change at a time. Never ask for three things in one go.
2. Always start with *"Read CLAUDE.md first."*
3. Always test with `bash dev.sh` before publishing.
4. Never publish on a busy shop evening. Publish in the morning, then watch it for 10 minutes.
5. Before publishing, ask Claude: *"Explain in simple words what you changed and what
   could break."* If it mentions things you didn't ask for, say *"undo that and only do
   what I asked."*

---

That's the entire system. Setup once (Part 1), then four messages per change (Part 2).
