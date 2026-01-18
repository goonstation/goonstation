# Secret TGUI Interfaces

## Overview

Secret TGUI interfaces are lazy-loaded at runtime without bundling them into the public `tgui.bundle.js`.
Secret interfaces are stored in the `+secret` submodule, automatically synced and stored during builds, and delivered as separate chunk files only when requested by authorized clients.

**Key features:**
- Secret interface code never appears in the public repository
- Each interface becomes its own lazy-loaded chunk (`secret-<hash>.bundle.js` where hash is MD5 of interface name, truncated to 12 chars)
- Automatic discovery—just add a `.tsx` file and it's registered
- Only requested interfaces are delivered to clients
- Chunk filenames are obscured (no English names, only hashes)
- Works seamlessly with the existing TGUI/BYOND asset pipeline

## Architecture

### Directory Structure

```
+secret/tgui/interfaces/          # Secret interface source (private repo)
├── SecretInterface1.tsx
├── SecretInterface2.tsx
└── AdminTool/
    └── index.tsx

+secret/browserassets/src/tgui/   # Built secret chunks (mirrored by plugin)
├── secret-a7f3d8c9beef.bundle.js
├── secret-e4b2a1c7fade.bundle.js
└── secret-9d3f7a8c1e2b.bundle.js

tgui/packages/tgui/interfaces-secret/
├── .gitignore                    # Ignores everything except tracked files
├── index.ts                      # Tracked registry with auto-discovery
└── (mirrored files)              # Copied from +secret during build (ignored)
```

### Data Flow

1. **Pre-build sync**: `SecretInterfaceSyncPlugin` mirrors `+secret/tgui/interfaces/*` into `tgui/packages/tgui/interfaces-secret/` before every rspack run
2. **Build**: Rspack's `splitChunks` creates separate `secret-*.bundle.js` files for each interface
3. **Post-build mirror**: `SecretBundleMirrorPlugin` copies built chunks back to `+secret/browserassets/src/tgui/`
4. **Runtime**: When a secret interface is requested, BYOND delivers the corresponding chunk and React lazy-loads the component

## How It Works

### 1. Sync Plugin (Pre-Build)

**File**: `tgui/rspack.config.mjs` → `SecretInterfaceSyncPlugin`

Runs on `beforeRun` and `watchRun` hooks:
- Copies everything from `+secret/tgui/interfaces/` to `tgui/packages/tgui/interfaces-secret/`
- Preserves tracked files (`.gitignore`, `index.ts`)
- Removes stale files from previous syncs
- Logs synced interface count

This ensures the workspace always has the latest secret interfaces before bundling.

### 2. Registry System

**File**: `tgui/packages/tgui/interfaces-secret/index.ts`

Auto-discovers secret interfaces using `require.context`:
- Scans for all `.tsx`/`.jsx` files in the directory (except `index.ts`)
- Derives interface names from filenames (e.g., `SecretTest.tsx` → `SecretTest`)
- Creates lazy loaders for dynamic imports
- Exports `hasSecretInterface(name)` and `loadSecretInterface(name)`

**Naming rules**:
- `InterfaceName.tsx` → `InterfaceName`
- `InterfaceName/index.tsx` → `InterfaceName`

### 3. Chunk Splitting

**File**: `tgui/rspack.config.mjs` → `optimization.splitChunks`

```javascript
splitChunks: {
  chunks: 'async',
  cacheGroups: {
    secretInterfaces: {
      test: /[\\/]interfaces-secret[\\/].+\.[tj]sx?$/,
      name(module) {
        return deriveSecretChunkName(module.identifier()) || undefined;
      },
      enforce: true,
      priority: 40,
    },
  },
}
```

Produces files named `secret-<hash>.bundle.js` where hash is the first 12 characters of MD5(interface name).

### 4. Bundle Mirror (Post-Build)

**File**: `tgui/rspack.config.mjs` → `SecretBundleMirrorPlugin`

After production builds:
- Collects all `secret-*.bundle.js` and `.map` files from build output
- Mirrors them to `+secret/browserassets/src/tgui/`
- Cleans up stale bundles
- Logs mirrored file count

This ensures the private repo contains the deployable chunks.

### 5. Route Resolution

**File**: `tgui/packages/tgui/routes.tsx` → `getRoutedComponent()`

When an interface is requested:
1. Checks `hasSecretInterface(name)` first
2. If secret, returns `getSecretComponent(name)` which:
   - Creates a `React.lazy()` wrapper around `loadSecretInterface()`
   - Wraps in `<Suspense>` with fallback
   - Caches the wrapped component
3. Falls back to regular interface resolution for public interfaces

### 6. Asset Delivery

**File**: `code/modules/tgui/tgui_secret_stub.dm`

When opening a secret interface:
```dm
tgui_send_secret_interface_assets(client, interface_name, window)
```

- Computes MD5 hash of interface name, takes first 12 chars
- Constructs chunk filename: `secret-<hash>.bundle.js`
- Checks if file exists locally or on CDN
- Creates `/datum/asset/basic/tgui_secret_chunk` with the chunk
- Sends asset through BYOND's `browse_rsc()` system

**File**: `code/modules/tgui/tgui.dm` → `open()`

Calls `tgui_send_secret_interface_assets()` after initializing the window, ensuring the chunk is available before the interface tries to load.

## Adding a New Secret Interface

### Step 1: Create the Interface

In `+secret/tgui/interfaces/NewSecretInterface.tsx`:

```tsx
import { Box, Button, Section } from "tgui-core/components";
import { useBackend } from "../../../tgui/packages/tgui/backend";
import { Window } from "../../../tgui/packages/tgui/layouts";

type NewSecretInterfaceData = {
  // Your data structure
};

export const NewSecretInterface = () => {
  const { act, data } = useBackend<NewSecretInterfaceData>();

  return (
    <Window width={400} height={300} title="Secret Feature">
      <Window.Content>
        <Section>
          {/* Your UI */}
        </Section>
      </Window.Content>
    </Window>
  );
};

export default NewSecretInterface;
```

**Import paths**: Use relative paths from `+secret/tgui/interfaces/` to reach `tgui/packages/tgui/`:
- `../../../tgui/packages/tgui/backend`
- `../../../tgui/packages/tgui/layouts`
- Components from `tgui-core/components` work directly

### Step 2: Build

Run any TGUI build command:
```bash
bin/tgui --build
# or
yarn tgui:build
```

The sync plugin automatically:
1. Copies your interface into the workspace
2. Registry discovers it
3. Rspack creates `secret-NewSecretInterface.bundle.js`
4. Mirror plugin copies the chunk to `+secret/browserassets/src/tgui/`

### Step 3: Use in DM Code

```dm
/datum/my_secret_feature
  var/datum/tgui/window

/datum/my_secret_feature/ui_interact(mob/user, datum/tgui/ui)
  ui = tgui_process.try_update_ui(user, src, ui)
  if (!ui)
    ui = new(user, src, "NewSecretInterface")
    ui.open()

/datum/my_secret_feature/ui_data(mob/user)
  . = list()
  // Return your data

/datum/my_secret_feature/ui_act(action, list/params)
  . = ..()
  if (.)
    return
  switch (action)
    // Handle actions
```

That's it. No manual registration required.

## Development Workflow

### Local Development

```bash
# Start dev server (watches +secret for changes)
bin/tgui --dev

# Build for testing
bin/tgui --build
```

The sync plugin runs automatically on every build and during watch mode, so edits in `+secret/tgui/interfaces/` propagate immediately.

### TypeScript in VS Code

The workspace settings in `.vscode/settings.json` exclude `+secret/tgui` from:
- File tree (`files.exclude`)
- File watcher (`files.watcherExclude`)
- Search results (`search.exclude`)

This prevents TypeScript errors on secret interfaces with relative import paths, since they're edited in the `+secret` directory but built from the mirrored workspace location.

### Debugging

**Interface not loading?**
1. Check `bin/tgui --build` output for sync/mirror plugin logs
2. Verify `+secret/browserassets/src/tgui/secret-<Name>.bundle.js` exists
3. Check DM runtime output for `tgui_send_secret_interface_assets()` calls
4. Inspect browser console for chunk loading errors

**TypeScript errors in +secret?**
- This is expected; the files are meant to be compiled from the mirrored location
- VS Code should ignore them due to workspace settings
- If errors persist, reload the window

## Deployment

The server build script must include `+secret/browserassets/src/tgui/` in deployment artifacts:

```php
// Example from server config
$include = [
  'goonstation.dmb',
  'goonstation.rsc',
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
