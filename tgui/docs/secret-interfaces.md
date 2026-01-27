# Secret TGUI interfaces

Secret React UIs get stored in `+secret` and are mirrored into the main workspace for builds. Each secret UI compiles into an id-named bundle and is delivered to clients by the server.

Keep in mind that once a player opens a UI, they can dive into the minified React code.

## Core idea
- Secret interfaces live in `+secret/tgui/interfaces/`.
- Builds compile secret entrypoints into bundles named like `secret-<id>.bundle.js`.
- IDs are a salted HMAC-MD5 using `+secret/tgui/secret-salt.txt`.
- The client only learns an id at runtime when it opens the UI; ids are not baked into the public bundle.

## Adding a secret UI
1) Create an interface in `tgui/packages/tgui/interfaces-secret/<Name>.tsx`. The file name (or `Name/index.tsx`) determines the interface name.
2) Build (`bin/tgui --build` or `yarn run tgui:build`). Sync → build → mirror happens automatically.
3) Open it from DM by interface name as normal.

## Files
- `+secret/tgui/interfaces/` – secret UIs
- `tgui/packages/tgui/interfaces-secret/` – build-time mirror + auto-generated wrappers + runtime loader
- `+secret/tgui/secret-salt.txt` – salt (and 11 herbs and spices)
- `+secret/tgui/secret-mapping.json` – interface name → id mapping
- `+secret/browserassets/src/tgui/` – built secret bundles stored in `+secret`

## Build flow (rspack)
1) Pre-build sync:
	- Both sides have entries: it merges per-interface, copying whichever file is newer for that interface to the other side.
	- Only one side has entries: that side is the source and the other is the mirror.

	During sync, wrappers are generated into `tgui/packages/tgui/interfaces-secret/` and the mapping is written to `+secret/tgui/secret-mapping.json`.
2) Build:
	- Each wrapper becomes an entrypoint named `secret-<id>`.
	- A `secret-dummy` entry is always present to keep the rspack runtime in the bundle stable whether `+secret` exists or not.
3) Post-build storage:
	- `secret-*.bundle.js` bundles are moved into `+secret/browserassets/src/tgui/`.

## Runtime flow (DM → client)
1) DM checks access and obtains the id (token) for the interface from `+secret/tgui/secret-mapping.json`.
2) The server provides the secret JS bundle to the client.
3) The UI config includes `config.secretInterfaces[name] = id` (flat name → id mapping). The client persists this in `sessionStorage` to survive reloads.
4) The loader injects `/secret-<id>.bundle.js` and waits for the bundle to self-register in `globalThis.__SECRET_TGUI_INTERFACES__[id]`.

## Deleting a secret UI
Because deletions only propagate in one-way sync mode, remove the interface in both places:
1) Delete the interface entry from `+secret/tgui/interfaces/`.
2) Delete the mirrored entry from `tgui/packages/tgui/interfaces-secret/`.
3) Run the build (`tgui/bin/tgui` or `yarn run tgui:build`). The mapping is rewritten and the secret bundle is stripped from the public output and mirrored cleanup happens in `+secret/browserassets/src/tgui/`.

## Troubleshooting
- You can edit either copy: `+secret/tgui/interfaces/` or the mirrored `tgui/packages/tgui/interfaces-secret/`. If both sides have changes, merge mode copies the newer mtime of each interface over the older one (no conflict prompts).
- If it doesn’t load: confirm the bundle exists in `+secret/browserassets/src/tgui/`, the mapping has an id for your interface name, and the browser console isn’t showing a failed script load.

## Notes

A `dummy.tsx` in `interfaces-secret/` is bundled as `secret-dummy` to force a stable secret entry for all builds, keeping the rspack-generated runtime in the main `tgui.bundle.js` identical for contributors without `+secret` and maintainers with `+secret`.
