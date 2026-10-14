# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A throwaway static "Coming Soon" page for `jimimi.fit`, served by a single `nginx:1.27-alpine` container. No backend, no build step, no asset pipeline — `index.html` is the entire app and all CSS is inlined into it.

The repo is currently in a pre-implementation state: `CONTEXT.md` and `PLAN.md` describe the design, and `index.html`, `Dockerfile`, and `docker-compose.prod.yml` are the artifacts to be produced.

## Commands

All commands run from `/srv/aidev/coming-soon/`:

- Build & deploy: `docker compose -f docker-compose.prod.yml up -d --build`
- Tear down: `docker compose -f docker-compose.prod.yml down`
- Smoke test (page serves): `docker exec jimimi-frontend wget -qO- http://localhost/ | head -20`
- Status: `docker ps --filter name=jimimi-frontend`

To change copy, edit `index.html` directly and rebuild — there are no env vars or config files to parameterize.

## Deployment architecture

This stack follows the same pattern as every other prod stack under `/srv/aidev/` (see `/srv/aidev/addohmnet/docker-compose.prod.yml` and `/srv/aidev/flashquestapp/docker-compose.prod.yml` for reference):

- Container attaches to the **external** Docker network `npm-network` (must already exist).
- Container `expose`s port 80 — **no host port is published**. Nginx Proxy Manager (a separate stack) reaches it over `npm-network`.
- NPM holds the Proxy Host mapping `jimimi.fit` → `jimimi-frontend:80` with Let's Encrypt SSL. NPM wiring is done manually in its admin UI, not in this repo.
- Compose project name: `jimimi`. Container name: `jimimi-frontend`.

When changing the deployment shape, mirror the existing prod stacks rather than inventing new conventions.

## Visual style is borrowed, not original

The look (dark background, cyan glowing orb, Syne + Space Grotesk fonts, pulse/orb-glow keyframes) is lifted from `/srv/aidev/addohmnet/frontend`. Source of truth:

- `/srv/aidev/addohmnet/frontend/src/index.css` — color tokens (`--bg #060608`, `--cyan #00f2ff`, `--light #f0eff8`, `--dim`), `@keyframes pulseWave`, `@keyframes orbGlow`.
- `/srv/aidev/addohmnet/frontend/src/pages/Landing.jsx` — orb markup, pulse rings, top/bottom monospace labels, fadeIn timings.
- Google Fonts URL is the same one loaded by `addohmnet/frontend/index.html`.

When updating styles, copy from those files rather than reinventing — keeping these in sync visually is the whole point.

GSAP / magnetic-mouse interactions from the addohmnet Landing page are **intentionally omitted** here. This is a static page with no JS framework; pure CSS animations only.

## Retirement

When the real `jimimi.fit` site exists, this whole directory and the NPM Proxy Host are deleted. Nothing else under `/srv/aidev/` depends on this stack, so removal is local.
