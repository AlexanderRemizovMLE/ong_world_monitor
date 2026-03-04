# Deploy to Render

This project deploys as a **static site** on [Render](https://render.com): the dashboard and the embedded World Map (worldmonitor) are built together and served from one app.

## Repo layout

Your Git repository root must contain:

- `ong_monitoring_dashboard/` — main React dashboard
- `worldmonitor/` — map app (built in embed mode and copied into the dashboard)
- `render-build.sh` — build script used by Render (and by `npm run build` from root)

**For the embedded map to work**, the `worldmonitor/` folder must contain the full app: `index.html`, `src/`, `vite.config.ts`, `package.json`, etc. If `worldmonitor/index.html` is missing, the build still succeeds but the World Map tab will show a stub that redirects to worldmonitor.app.

## Option 1: Deploy with Blueprint (recommended)

1. Push your code to GitHub or GitLab (include both `ong_monitoring_dashboard` and `worldmonitor`).
2. In [Render Dashboard](https://dashboard.render.com), click **New** → **Blueprint**.
3. Connect the repository that contains the root with `render.yaml`.
4. Render will create a **Static Site** using:
   - **Build command:** build worldmonitor embed → copy into dashboard → build dashboard (see `render.yaml`).
   - **Publish directory:** `ong_monitoring_dashboard/dist`.
5. Deploy. The site will be available at `https://<name>.onrender.com`.

The built map is served from `/worldmonitor/` on the same origin (no env var needed).

### Environment variables (Render Dashboard → Environment)

For the **news feed** (World Map and Market tabs) to work in production, set:

| Variable | Value | Required |
|----------|--------|----------|
| `VITE_WORLDMONITOR_NEWS_API` | `https://www.worldmonitor.app/api/news/v1/list-feed-digest` | **Yes** for news |

On a static site there is no server to proxy `/api/worldmonitor-news`, so the client must call the public API. Add this variable in Render **before** the first build (or trigger a new deploy after adding it).

Optional:

| Variable | Description |
|----------|-------------|
| `VITE_WORLDMONITOR_MAP_URL` | Override map iframe URL. Leave unset to use the embedded map at `/worldmonitor/`. |

## Option 2: Manual static site setup

If you don’t use the Blueprint:

1. **New** → **Static Site**.
2. Connect the same repository (root with `ong_monitoring_dashboard` and `worldmonitor`).
3. Set:
   - **Build command:**
     ```bash
     cd worldmonitor && npm ci && npm run build:embed && cd ../ong_monitoring_dashboard && npm run worldmonitor:copy && npm ci && npm run build
     ```
   - **Publish directory:** `ong_monitoring_dashboard/dist`
4. Under **Redirects/Rewrites** (or **Routes**), add a rewrite so the SPA works:
   - **Source:** `/*`
   - **Destination:** `/index.html`
   - (Type: Rewrite)

## Build from repo root (local)

From the repo root (parent of `ong_monitoring_dashboard` and `worldmonitor`):

```bash
cd worldmonitor && npm ci && npm run build:embed && \
cd ../ong_monitoring_dashboard && npm run worldmonitor:copy && npm ci && npm run build
```

Output: `ong_monitoring_dashboard/dist/` (ready to upload or serve).

## If the repo contains only the dashboard

If `worldmonitor` is not in the same repo (e.g. you only deploy `ong_monitoring_dashboard`):

1. Build and copy worldmonitor into the dashboard **before** pushing, then commit the `public/worldmonitor` folder.
2. In Render, set **Root Directory** to `ong_monitoring_dashboard`.
3. Use:
   - **Build command:** `npm ci && npm run build`
   - **Publish directory:** `dist`

The map will work as long as `public/worldmonitor` is present in the repo.
