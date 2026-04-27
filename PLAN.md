# JIMIMI "Coming Soon" Container

## Context
You want a placeholder page for the `jimimi.fit` domain on the production server. Branding/style should feel like `/srv/aidev/addohmnet/frontend` (dark, glowing-cyan-orb, Syne + Space Grotesk typography), and the deployment must drop into the existing prod pattern: a single container on the external `npm-network`, fronted by Nginx Proxy Manager — same shape as `addohmnet-frontend` and `flashquestapp-frontend`.

Inputs locked in:
- **Brand:** `JIMIMI` (small monospace, top-center)
- **Headline:** `Coming Soon`
- **Tagline:** `Something new is on the way.`
- **Domain:** `jimimi.fit` (wired in NPM after the container is up)
- **Project location:** `/srv/aidev/coming-soon/`

## Approach
A single `nginx:1.27-alpine` container serving one static `index.html`. No build step, no Node, no proxying — purely a placeholder. All style is inlined into `index.html` so there is no asset pipeline to maintain.

## Files to create

### 1. `/srv/aidev/coming-soon/index.html`
Single static page replicating the addohmnet visual language (verified against `/srv/aidev/addohmnet/frontend/src/index.css` and `src/pages/Landing.jsx`):

- `<head>`: preconnect + Google Fonts URL exactly as used by addohmnet:
  `https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700&family=Space+Grotesk:wght@300;400;500&display=swap`
- Inline CSS (no Tailwind, no React) using these tokens lifted from `addohmnet/frontend/src/index.css`:
  - `--bg: #060608` body background
  - `--cyan: #00f2ff` orb + accents
  - `--light: #f0eff8` text
  - `--dim: rgba(240,239,248,0.55)` tagline
  - Display font `'Syne', system-ui, sans-serif` for the headline
  - Sans font `'Space Grotesk', system-ui, sans-serif` for body
- `@keyframes pulseWave` and `@keyframes orbGlow` copied verbatim from `addohmnet/frontend/src/index.css:101-109` (no GSAP — pure CSS, since we don't need the magnetic-mouse effect for a static page).
- Layout (top-to-bottom, flex-centered, `position: fixed; inset: 0`):
  1. Top monospace `JIMIMI` (10px, letter-spacing 6px, color `rgba(255,255,255,0.2)`, fadeIn 1.5s)
  2. Center: 160px cyan glow orb (radial gradient + 3 pulse rings, exactly as `Landing.jsx:140-177`)
  3. Below orb: `COMING SOON` headline in Syne 600, letter-spacing 8px, ~28px
  4. Tagline `Something new is on the way.` in Space Grotesk 300, color `var(--dim)`
  5. Bottom monospace cyan hint (e.g. `JIMIMI.FIT`) — letter-spacing 4px, color `rgba(0,242,255,0.25)` — mirrors the bottom hint in `Landing.jsx:115-133`

### 2. `/srv/aidev/coming-soon/Dockerfile`
```dockerfile
FROM nginx:1.27-alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
```
No nginx config customization needed — the default `/etc/nginx/conf.d/default.conf` already serves `/usr/share/nginx/html` on port 80, and there's no SPA routing or backend proxying to do.

### 3. `/srv/aidev/coming-soon/docker-compose.prod.yml`
Mirrors the deployment pattern from `/srv/aidev/addohmnet/docker-compose.prod.yml:52-78` and `/srv/aidev/flashquestapp/docker-compose.prod.yml:62-87`:

```yaml
name: jimimi

services:
  frontend:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: jimimi-frontend
    expose:
      - "80"
    networks:
      - npm-network
    restart: unless-stopped

networks:
  npm-network:
    external: true
```

Notes:
- `expose` (not `ports`) — NPM reaches the container via `npm-network`, no host port published. Same convention as the existing prod stacks.
- `name: jimimi` namespaces the compose project so `docker compose ls` shows it cleanly alongside `addohmnet` / `flashquest_prod`.
- No `.env` needed — nothing to parameterize.

## Reused patterns
- `nginx:1.27-alpine` base image (matches addohmnet/Dockerfile.prod stage 2)
- `expose: ["80"]` + `networks: [npm-network]` deployment shape (addohmnet, flashquestapp)
- Color tokens, fonts, keyframes from `addohmnet/frontend/src/index.css`
- Orb structure from `addohmnet/frontend/src/pages/Landing.jsx:140-177`

## Verification
1. **Build & run** from `/srv/aidev/coming-soon/`:
   ```
   docker compose -f docker-compose.prod.yml up -d --build
   ```
2. **Container is up:** `docker ps --filter name=jimimi-frontend` shows running.
3. **Page serves correctly** (from any container on `npm-network`, or via `docker exec`):
   ```
   docker exec jimimi-frontend wget -qO- http://localhost/ | head -20
   ```
   Expect HTML containing `JIMIMI` and `Coming Soon`.
4. **NPM wiring** (manual, outside this plan): in NPM admin UI, add a Proxy Host for `jimimi.fit` → forward to `jimimi-frontend` port `80`, attach SSL via Let's Encrypt. After this, `https://jimimi.fit` should render the page. Visual check: dark background, glowing cyan orb pulsing, `JIMIMI` top, `COMING SOON` centered, tagline below.
5. **Rollback:** `docker compose -f docker-compose.prod.yml down` removes only this stack; nothing else on the server is touched. `rm -rf /srv/aidev/coming-soon` cleans up the source.
