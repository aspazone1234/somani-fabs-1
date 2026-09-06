# CLAUDE.md — project context for AI coding tools

Read this file before making any change. It is the map of this codebase.
(Works with Claude Code, Cursor, Codex, Copilot — any tool that reads repo context.)

## What this app is
"Somani Fabs" — an unstitched-fabric shop in Kuchaman City, Rajasthan.
A staff-operated tool: staff create a customer session, photograph fabrics, and Google
Gemini generates a photorealistic try-on image of that customer wearing garments made
from those fabrics. The try-on shows on a big LED display in the shop.

Users are shop staff on phones, not tech people. Default UI language is **Hinglish**
(English + Hindi toggle). Simplicity and speed matter more than features.

## Stack
- **Backend:** FastAPI (`backend/server.py`, single file) + MongoDB (motor/async) + JWT auth (bcrypt).
- **AI:** Google Gemini image models via `google-genai` (`backend/gemini_service.py`).
- **Frontend:** React 19 (CRA + craco), Tailwind CSS, shadcn/ui, framer-motion.
- **Infra:** Docker Compose on a DigitalOcean droplet, nginx in front, MongoDB Atlas, HTTPS via certbot.
- **Deploy:** push to `main` → GitHub Actions → SSH into droplet → `deploy/deploy.sh`.

## Layout
```
backend/
  server.py             all API routes, auth, models, startup seeding  (~765 lines)
  gemini_service.py     prompt building + Gemini call with retry/fallback
  requirements.prod.txt deps used by the Docker image  <-- update this, not requirements.txt
frontend/src/
  pages/Landing.js      public heritage page  (route /)
  pages/Display.js      chrome-less LED display  (route /d/:secret)
  admin/AdminApp.js     login + admin shell  (route /admin)
  admin/Canvas.js       session list / create session
  admin/Camera.js       guided customer photo capture
  admin/NewTrial.js     try-on wizard + generation polling
  admin/SessionView.js  trials list, preview modal, live display push, end session
  admin/Settings.js     customer DB, history, stats, config, admins, logs
  i18n.js               ALL UI strings (hinglish / en / hi) — add keys to all three
  lib/api.js            axios client, uses REACT_APP_BACKEND_URL
deploy/                 droplet setup, nginx config, deploy script, env template
MIGRATION-GUIDE.md      how the server was set up
WORKFLOW.md             how to make changes safely
```

## Hard rules (breaking these breaks production)
1. **Every backend route must start with `/api`** except `GET /health`. nginx routes only
   `/api/*` and `/health` to the backend; everything else goes to the React app.
2. `GET /health` must stay fast (its Mongo ping is wrapped in a 2s timeout) — the
   container healthcheck uses it.
3. **Frontend must call the API through `lib/api.js`** (`${process.env.REACT_APP_BACKEND_URL}/api`).
   In production that variable is empty on purpose = same-origin `/api`. Never hardcode a URL.
4. **All secrets come from env vars only** (`MONGO_URL`, `DB_NAME`, `JWT_SECRET`,
   `SUPER_ADMIN_*`, `GEMINI_API_KEY`, `GEMINI_IMAGE_MODEL`). Never commit a `.env`.
   Never change `DB_NAME` — that would orphan all existing data.
5. **Try-on generation is asynchronous.** `POST /api/sessions/{id}/trials/generate` returns
   immediately with `status:"generating"`; a background task does the Gemini call; the
   frontend polls a tiny status endpoint. Never make generation synchronous again — it
   times out behind nginx/Cloudflare.
6. **Never send full base64 images in polled endpoints.** The LED display polls every 2s
   and uses a `version` check that returns `{unchanged:true}`; images are sent only when
   they change. Ignoring this caused site-wide 500s once.
7. Customer portrait = kept forever. Try-on/fabric images = auto-deleted after 7 days
   (Mongo TTL index on `trials.expire_at`).
8. New UI text must be added to **all three** languages in `i18n.js`.
9. Every interactive element gets a `data-testid`.
10. Frontend build runs with warnings-as-errors in some CI setups — keep `yarn build` clean.

## Definition of done for any change
- `cd backend && python -c "import server"` succeeds.
- `cd frontend && CI=true yarn build` succeeds with no warnings.
- Tested locally against a **test** database (never point local dev at the production
  Atlas database).
- Small, single-purpose commit with a clear message.

## Style
- Keep changes minimal and focused; do not refactor unrelated code.
- Match existing patterns; reuse shadcn components in `frontend/src/components/ui/`.
- No new comments unless something is genuinely non-obvious.
