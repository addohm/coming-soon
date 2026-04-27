# coming-soon — context

Static placeholder page for `jimimi.fit`. One nginx container, no backend, no build step.

## What this is
A throwaway "Coming Soon" page that sits behind Nginx Proxy Manager (NPM) until the real `jimimi.fit` site is ready. Visual style is borrowed from `/srv/aidev/addohmnet/frontend` so it feels like part of the same family.

## Branding
- **Brand label (top, monospace):** `JIMIMI`
- **Headline:** `Coming Soon`
- **Tagline:** `Something new is on the way.`
- **Domain:** `jimimi.fit`

## Deployment architecture
Same shape as every other prod stack in `/srv/aidev/`:

- Container attaches to the **external** Docker network `npm-network`.
- Container `expose`s port `80` — **no host port published**. NPM reaches it over `npm-network`.
- NPM (admin UI, separate stack) holds the Proxy Host: `jimimi.fit` → `jimimi-frontend:80`, SSL via Let's Encrypt.
- Compose project name: `jimimi`. Container name: `jimimi-frontend`.

Reference stacks using the same pattern:
- `/srv/aidev/addohmnet/docker-compose.prod.yml`
- `/srv/aidev/flashquestapp/docker-compose.prod.yml`

## Style source of truth
Visual tokens, fonts, and the cyan orb come from:
- `/srv/aidev/addohmnet/frontend/src/index.css` — CSS variables (`--bg #060608`, `--cyan #00f2ff`, `--light #f0eff8`, `--dim`), `@keyframes pulseWave`, `@keyframes orbGlow`.
- `/srv/aidev/addohmnet/frontend/src/pages/Landing.jsx` — orb markup, pulse rings, monospace top/bottom labels, fadeIn timings.
- Google Fonts: `Syne` (display) + `Space Grotesk` (sans), loaded via the same URL as `addohmnet/frontend/index.html`.

GSAP/magnetic mouse effect is **intentionally omitted** — pure CSS animations only, since this is a single static page with no JS framework.

## Operational notes
- No `.env`, no secrets, nothing to parameterize. Edit `index.html` directly to change copy.
- Build & run: `docker compose -f docker-compose.prod.yml up -d --build` from this directory.
- Tear down: `docker compose -f docker-compose.prod.yml down`. Removes only this stack.
- After teardown, also remove the NPM Proxy Host for `jimimi.fit` so the domain stops pointing at a dead container.

## When this gets retired
Once the real `jimimi.fit` site exists, delete this directory and the NPM Proxy Host, then point NPM at the real container. Nothing else in `/srv/aidev/` depends on this stack.
