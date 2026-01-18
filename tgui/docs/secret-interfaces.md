# Secret TGUI interfaces

Secret React UIs get stored in `+secret`, get mirrored into the workspace for builds, turn into uuid-named bundles, are delivered to clients via the server sending over the correct uuid for an interface.

## Core idea
- Secret interfaces live in `+secret/tgui/interfaces/`.
- Each interface gets a secret salted HMAC-MD5 id. Bundle is `secret-<id>.bundle.js`.
- The client only ever gets the id when it displays, the ids are not exposed in webpack.

## Files
- `+secret/tgui/interfaces/` – secret UIs are stored here (hidden in VSCode file browser to avoid LSP errors)
- `tgui/packages/tgui/interfaces-secret/` – mirrored sources + auto-generated wrappers + runtime loader
- `+secret/tgui/secret-salt.txt` – salt (and 11 herbs and spices)
- `+secret/tgui/secret-mapping.json` – interface → id string (private; chunk = `secret-${id}.bundle.js`).
- `+secret/browserassets/src/tgui/` – built secret bundles stored in +secret.


## Build flow (rspack)
1) Pre-build sync: copy `+secret/tgui/interfaces/*` into `tgui/packages/tgui/interfaces-secret/`, generate wrappers, write the mapping.
2) Build: each wrapper is an entrypoint `secret-${token}` with `dependOn: 'tgui'` so bundles stay tiny.
3) Post-build mirror (production): copy `secret-*.bundle.js` to `+secret/browserassets/src/tgui/` and prune stale ones.

## Runtime flow (DM → client)
1) DM checks access, reads `+secret/tgui/secret-mapping.json` to get the token.
2) DM sends the bundle as a normal asset and sends a `secret/interface` message with `{ name, token }`.
3) Client routes see `config.secretInterfaces[name].token`, persist it in sessionStorage, and lazy-load via the loader.
4) Loader injects `/secret-${token}.bundle.js`, waits for the bundle to self-register in `globalThis.__SECRET_TGUI_INTERFACES__[token]`.

## Adding a secret UI
1) Drop a TSX in `+secret/tgui/interfaces/` (name or `name/index.tsx` decides interface name).
2) Build (`bin/tgui --build` or `yarn run tgui:build`). Sync → mapping → build → mirror happens automatically.
3) Open it from DM by interface name.

## Gotchas / sanity checks
- VSCode hides `+secret/tgui/interfaces/`; builds use the mirrored copy under `interfaces-secret`.
- If it doesn’t load: confirm the bundle exists in `+secret/browserassets/src/tgui/`, the mapping has a token for your interface, and the browser console isn’t showing a failed script load.
