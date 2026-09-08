# AGENTS.md

All project rules, architecture and constraints live in **[CLAUDE.md](./CLAUDE.md)**.
Read that file first, before making any change. It applies to every AI coding agent
(Codex, Claude Code, Cursor, Copilot, Aider, Gemini/Antigravity).

Quick reminders:
- Backend routes must start with `/api` (only `GET /health` is outside it).
- The frontend talks to the API only through `frontend/src/lib/api.js`; never hardcode a URL.
- Secrets come from environment variables only. Never commit a `.env`. Never change `DB_NAME`.
- Try-on generation must stay asynchronous (generate → background task → poll status).
- Never return full base64 images from endpoints that are polled.
- New UI text goes into all three languages in `frontend/src/i18n.js`.
- Every interactive element needs a `data-testid`.

Before finishing any task, run:

```bash
bash check.sh
```

Both the backend import check and `CI=true yarn build` must pass. Keep changes small and
focused on what was asked; do not refactor unrelated code.
