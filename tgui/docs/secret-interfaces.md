# Secret TGUI interfaces

Secret React UIs get stored in `+secret`, get mirrored into the workspace for builds, turn into id-named bundles, are delivered to clients via the server sending over the correct id for an interface.

Keep in mind that once a player opens a UI, they can dive into the minified React code.

## Core idea
- Secret interfaces live in `+secret/tgui/interfaces/`.
- Each interface gets a secret salted HMAC-MD5 id. Bundle is `secret-<id>.bundle.js`.
- The client only ever gets the id when it displays, the ids are not exposed in webpack.

## Adding a secret UI
**TODO**: fix issue of having to create file in +secret/tgui/interfaces for sync to not go batshit and delete
**also not overwriting, shit got fucked at some point**
1) Create an interface in `tgui/packages/tgui/interfaces-secret` (name or `name/index.tsx` decides interface name).
2) Build (`bin/tgui --build` or `yarn run tgui:build`). Sync → build → mirror happens automatically.
3) Open it from DM by interface name as normal.

## Files
- `+secret/tgui/interfaces/` – secret UIs are stored here (hidden in VSCode file browser to avoid LSP errors)
- `tgui/packages/tgui/interfaces-secret/` – mirrored sources + auto-generated wrappers + runtime loader
- `+secret/tgui/secret-salt.txt` – salt (and 11 herbs and spices)
- `+secret/tgui/secret-mapping.json` – interface → id string (private; chunk = `secret-${id}.bundle.js`).
- `+secret/browserassets/src/tgui/` – built secret bundles stored in +secret.

## Build flow (rspack)
1) Pre-build sync: copy `+secret/tgui/interfaces/*` into `tgui/packages/tgui/interfaces-secret/`, generate wrappers, write the mapping.
2) Build: each wrapper is an entrypoint `secret-${token}` with `dependOn: 'tgui'` so bundles stay tiny.
3) Post-build mirror (production): copy `secret-*.bundle.js` to `+secret/browserassets/src/tgui/`W and prune stale ones.

> Limitation: `interfaces-secret/` is treated as a mirror of `+secret/tgui/interfaces/`. Anything not in `+secret` gets wiped during the sync step (except a couple of preserved files). Always add new secret interfaces under `+secret/tgui/interfaces/` so they survive sync and wrapper generation.

## Runtime flow (DM → client)
1) DM checks access, reads `+secret/tgui/secret-mapping.json` to get the token.
2) DM sends the bundle as an asset and sends a `backend/secret-id` message with `{ name : id }`.
3) Client routes see `config.secretInterfaces[name]`, persist it in sessionStorage, and lazy-load via the loader.
4) Loader injects `/secret-${token}.bundle.js`, waits for the bundle to self-register in `globalThis.__SECRET_TGUI_INTERFACES__[token]`.

## Troubleshooting
- VSCode hides `+secret/tgui/interfaces/`; use the mirrored copy under `interfaces-secret`.
- If it doesn’t load: confirm the bundle exists in `+secret/browserassets/src/tgui/`, the mapping has a token for your interface, and the browser console isn’t showing a failed script load.

## Notes

A `dummy.tsx` in `interfaces-secret/` is bundled as `secret-dummy` to force a stable secret entry for all coders, keeping the main `tgui.bundle.js` rspack-generated runtime identical. If this was not present, rspack would prune some of the loader code.
