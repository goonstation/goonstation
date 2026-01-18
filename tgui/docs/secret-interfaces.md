# Secret TGUI interfaces

This is the “secret UI” setup for TGUI.

Goals:
- keep secret React code out of public bundles/repos
- don’t leak interface names via a public registry
- keep secret bundles tiny (no re-bundling all of TGUI)

Non-goal:
- “un-downloadable”. If someone has the exact filename, they can fetch it from a public CDN. The whole point is making filenames not guessable.

## Where stuff lives

```
+secret/tgui/interfaces/            # secret TSX source (private)
  SecretThing.tsx
  AdminStuff/index.tsx

+secret/tgui/secret-salt.txt        # private salt used for token IDs
+secret/tgui/secret-mapping.json    # private mapping DM reads

+secret/browserassets/src/tgui/     # built secret bundles (mirrored back into +secret)
  secret-<token>.bundle.js
  secret-<token>.bundle.js.map

tgui/packages/tgui/interfaces-secret/ # build-time mirror target (public repo)
  registry.generated.ts               # runtime loader (tracked)
  *.wrapper.tsx                       # auto-generated per secret interface
  (mirrored secret sources)           # copied in during build
```

## The ID scheme (token)

Every secret interface gets an opaque token:
- token = HMAC-MD5(salt, interfaceName), hex, truncated
- chunk filename is `secret-${token}.bundle.js`
- salt is only in `+secret/tgui/secret-salt.txt`

So: you can’t derive tokens/chunk names from interface names without the salt.

## Build pipeline (rspack)

This is all wired in rspack config (the “secret” helper file is where the logic lives):

1) Pre-build sync
- copies `+secret/tgui/interfaces/*` into `tgui/packages/tgui/interfaces-secret/`
- generates a wrapper per interface that does:
  - import the real component
  - register it into `globalThis.__SECRET_TGUI_INTERFACES__[token]`
- writes `+secret/tgui/secret-mapping.json` for DM

2) Build
- each secret wrapper becomes its own entrypoint named `secret-${token}`
- entrypoints `dependOn: 'tgui'`, so they don’t re-bundle React/TGUI

3) Post-build mirror
- on production builds, any `secret-*.bundle.js` (+ maps) get copied to `+secret/browserassets/src/tgui/`
- stale secret bundles get cleaned up

## Runtime flow (DM → client)

1) DM decides the player is allowed to open a secret interface
2) DM reads `+secret/tgui/secret-mapping.json` and finds the token
3) DM sends the bundle as a normal BYOND asset (`/datum/asset/basic/tgui_secret_chunk`)
4) DM sends a message:
   - type: `secret/interface`
   - payload: `{ name, token }`
5) TGUI routes see `config.secretInterfaces[name].token` and lazy-load via the loader

Loader is intentionally dumb/safe:
- it injects a `<script src="/secret-${token}.bundle.js">`
- waits for the bundle to self-register `globalThis.__SECRET_TGUI_INTERFACES__[token]`

## Adding a new secret interface

1) Add a TSX file under `+secret/tgui/interfaces/`
   - `Foo.tsx` → interface name is `Foo`
   - `Foo/index.tsx` → interface name is `Foo`

2) Build TGUI
   - `bin/tgui --build` or `yarn run tgui:build`
   - it’ll sync + generate mapping + build + mirror bundles

3) Open it from DM like a normal interface name
   - the “secret” stub handles delivering the chunk + token message

## Gotchas

- `registry.generated.ts` is tracked and must not get wiped by the sync step.
- VS Code may ignore `+secret` in search/watch (on purpose). The build uses the mirrored copy under `tgui/packages/tgui/interfaces-secret/`.
- If something doesn’t load:
  - check `+secret/browserassets/src/tgui/` has the expected `secret-*.bundle.js`
  - check `+secret/tgui/secret-mapping.json` has your interface name → token
  - check browser console for script load errors

  'assets',
  'config',
  'browserassets',
  '+secret/assets',
  '+secret/browserassets',  // Include this
  '+secret/config',
  '+secret/strings',
];
```

The CDN manifest generation should also process secret chunks if using CDN-based asset delivery.

## Security Model

- **Source code privacy**: Secret interface source lives only in `+secret` submodule
- **Chunk delivery control**: BYOND asset system ensures only authorized clients receive chunks
- **Filename obscurity**: Chunk names use MD5 hash only—no English interface names visible on CDN
- **No enumeration**: Clients cannot discover or guess what secret interfaces exist without server permission
- **Lazy loading**: Only requested interfaces are delivered, minimizing exposure

## Technical Details

### Rspack Configuration

**splitChunks priority**: `40` ensures secret interfaces split before other async chunks

**enforce**: `true` forces chunk creation even for small modules

**test pattern**: `/[\\/]interfaces-secret[\\/].+\.[tj]sx?$/` matches any TypeScript/JavaScript file in the interfaces-secret directory

### Chunk Naming Logic

```javascript
function deriveSecretChunkName(identifier) {
  const match = identifier.match(/interfaces-secret[\\/](.+?)\.[tj]sx?$/i);
  if (!match) return null;

  const raw = match[1].replace(/\\/g, '/');
  const segments = raw.split('/');
  const last = segments[segments.length - 1];

  // Derive interface name from file structure
  const interfaceName =
    last === 'index' && segments.length > 1
      ? segments[segments.length - 2]  // Directory-based: AdminTool/index.tsx → AdminTool
      : last;                           // File-based: SecretTest.tsx → SecretTest

  // Hash the interface name for obscurity
  const hash = createHash('md5').update(interfaceName).digest('hex').slice(0, 12);
  return `secret-${hash}`;
}
```

Examples:
- `SecretTest.tsx` → MD5("SecretTest") → `secret-a7f3d8c9beef`
- `AdminTool/index.tsx` → MD5("AdminTool") → `secret-e4b2a1c7fade`

### Registry Discovery

Uses `require.context('.', true, /^\.\/(?!index\.[tj]sx?$).*\.[tj]sx$/, 'lazy')` to:
- Recursively scan directory
- Match `.ts`, `.tsx`, `.js`, `.jsx` files
- Exclude `index.ts` itself
- Use lazy mode for dynamic imports

### Component Resolution Priority

When loading a secret interface module:
1. Default export (`export default Component`)
2. Named export matching interface name (`export const InterfaceName`)
3. First function export found

This flexibility allows various export patterns.

## Troubleshooting

### Build Issues

**"Secret interface source not found"**
- The `+secret` submodule is missing or not initialized
- Run `git submodule update --init`

**"Secret interface source is empty"**
- No `.tsx` files in `+secret/tgui/interfaces/`
- Add at least one interface file

**Chunk not created**
- Check that filename matches pattern (`.tsx`, `.jsx`, `.ts`, `.js`)
- Ensure file is not named `index.ts` at the root level
- Verify rspack build completed without errors

### Runtime Issues

**"Interface [name] was not found"**
- Interface name doesn't match filename
- Check registry: interface should appear in `secretInterfaceNames`
- Verify sync plugin ran (check build logs)

**"Cannot find module" errors in +secret**
- This is cosmetic; imports resolve correctly after mirroring
- Files are edited in `+secret` but built from `interfaces-secret`
- VS Code should hide these errors via workspace settings

**Chunk loads but shows blank/error**
- Check component export (default, named, or first function)
- Inspect browser console for React errors
- Verify data contract matches between DM and TypeScript

### Performance Considerations

- Each secret interface adds ~1 HTTP request at runtime
- Chunks are small (typically <1 KB for simple interfaces)
- React.lazy provides automatic code splitting
- Suspense fallback shows empty window during load
- Component caching prevents duplicate lazy loads

## Future Enhancements

Possible improvements:
- **CDN manifest integration**: Auto-update manifest with secret chunk hashes
- **Development mode chunks**: Allow secret chunks in dev mode for faster iteration
- **Preload hints**: Send `<link rel="preload">` for known secret interfaces
- **Bundle analysis**: Visualize secret chunk sizes and dependencies
- **Type definitions**: Generate `.d.ts` files for secret interfaces in public repo (types only, no implementation)
