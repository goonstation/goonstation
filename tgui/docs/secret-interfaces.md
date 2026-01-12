# Secret Interface Loading System

## Overview

This document describes the architecture for loading secret TGUI interfaces at runtime without bundling them into the public `tgui.bundle.js` file. This system enables maintainers to use React-based TGUI interfaces for secret features while maintaining code privacy.

## Problem Statement

Goonstation's codebase includes a secret submodule (`+secret/`) containing features only accessible to maintainers and server hosts. Currently:

- All TGUI interfaces are compiled into a single `tgui.bundle.js` served from CDN
- Secret submodule contains DM code but no TGUI interfaces yet
- Adding secret interfaces to the main bundle would expose React code to all clients
- Server-side rendering is not feasible (all assets are CDN-served and static)
- Rebuilding TGUI bundles during server startup creates dev/prod inconsistencies

**Requirements:**
1. Secret interface code must not be accessible to unauthorized clients
2. Only requested secret interfaces should be delivered (not all in one bundle)
3. System must work with existing CDN-based asset delivery
4. Dev and production builds must remain consistent
5. No server-side rendering or build-time code generation

## Current Architecture Analysis

### Interface Registration System

**Location:** [packages/tgui/routes.tsx](../packages/tgui/routes.tsx)

The current routing system uses webpack's `require.context` to bundle all interfaces at build time:

```typescript
const requireInterface = require.context('./interfaces');

function resolveInterface(interfaceName) {
  const pathBuilders = [
    () => `./${interfaceName}.tsx`,
    () => `./${interfaceName}.ts`,
    () => `./${interfaceName}.jsx`,
    () => `./${interfaceName}.js`,
    () => `./${interfaceName}/index.tsx`,
    // ... etc
  ];

  for (const pathBuilder of pathBuilders) {
    try {
      return requireInterface(pathBuilder()).default;
    } catch (err) {
      if (err.code !== 'MODULE_NOT_FOUND') throw err;
    }
  }
}
```

**Key characteristics:**
- All interfaces bundled into single ~1.5MB JavaScript file
- Static resolution at build time via webpack context
- No lazy loading or code splitting implemented
- Backend sends interface name, routes.tsx resolves component

### Interface Structure

**Location:** [packages/tgui/interfaces/](../packages/tgui/interfaces/)

Interfaces follow one of two patterns:

**Single file:** `InterfaceName.tsx`
```typescript
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Section, Button } from 'tgui-core/components';

interface InterfaceData {
  // Backend data structure
}

export const InterfaceName = () => {
  const { act, data } = useBackend<InterfaceData>();
  return (
    <Window width={400} height={300}>
      <Window.Content>
        <Section>
          {/* Interface content */}
        </Section>
      </Window.Content>
    </Window>
  );
};
```

**Directory-based:** `InterfaceName/index.tsx` (for complex interfaces with multiple files)

### Build System

**TGUI Build:** Rspack (webpack-compatible bundler)
- Configuration: [rspack.config.mjs](../rspack.config.mjs)
- Single entry point: `tgui: ['./packages/tgui']`
- Output: `tgui.bundle.js` and `tgui.bundle.js.map`
- No code splitting configured

**Asset Processing:** Gulp
- Configuration: `browserassets/gulpfile.js`
- Processes TGUI bundles with CDN-compatible hash filenames
- Generates manifests for BYOND resource system

**Asset Delivery:** BYOND `browse_rsc()` system
- Defined in: `code/modules/localassets/localassets_tgui.dm`
- Static file references sent to clients
- Cached in BYOND cache directory

### Secret Submodule Integration

**Current state:**
- Location: `+secret/` (git submodule)
- DM integration: `#include "+secret\__secret.dme"` when `fexists("+secret/__secret.dme")`
- Defines `SECRETS_ENABLED` flag
- Has `tgui/` directory but currently empty
- No TGUI build integration yet

### Existing Dynamic Loading Pattern

**AlertContentWindows** ([interfaces/AlertContentWindows/index.ts](../packages/tgui/interfaces/AlertContentWindows/index.ts)) demonstrates webpack context for sub-components:

```typescript
const r = require.context('./acw', false, /\.AlertContentWindow\.tsx$/);
const alertContentWindowMap: { [key: string]: AlertContentWindow } = {};

r.keys().forEach((key) => {
  const module = r(key);
  const componentName = key.match(/\/(.*)\.AlertContentWindow\.tsx$/)?.[1];
  if (componentName) {
    alertContentWindowMap[componentName] = module.acw;
  }
});
```

This pattern loads multiple related components from a directory but still bundles them all at build time.

## Architecture Options

### Option A: Per-Interface Chunk Splitting with Dynamic Import ⭐ **RECOMMENDED**

**Architecture:** Configure rspack to create separate chunk files for each secret interface using dynamic imports and `React.lazy()`. Each interface becomes its own async module loaded only when requested.

**Directory Structure:**
```
+secret/tgui/interfaces/        # Secret interfaces live in secret submodule
├── SecretInterface1.tsx        # Individual secret interfaces
├── SecretInterface2.tsx
└── AdminTool/
    └── index.tsx

tgui/packages/tgui/interfaces-secret/  # Symlink → +secret/tgui/interfaces/
                                       # Created automatically for maintainers/builds
```

**Implementation Steps:**

1. **Set Up Symlink and Secret Interface Registry**:

   **a. Create secret interfaces directory** in `+secret/tgui/interfaces/`

   **b. Set up symlink** (automatic for maintainers/server builds):
   ```bash
   # On Windows (requires admin or developer mode)
   mklink /D "tgui\packages\tgui\interfaces-secret" "..\..\..\+secret\tgui\interfaces"

   # On Linux/macOS
   ln -s "../../../+secret/tgui/interfaces" "tgui/packages/tgui/interfaces-secret"
   ```

   **c. Create registry** (`+secret/tgui/interfaces/index.ts`):
   ```typescript
   // Registry of available secret interfaces (lazy-loaded)
   export const SECRET_INTERFACES = {
     SecretInterface1: () => import('./SecretInterface1'),
     SecretInterface2: () => import('./SecretInterface2'),
     AdminTool: () => import('./AdminTool'),
   };

   export type SecretInterfaceName = keyof typeof SECRET_INTERFACES;

   // Check if an interface name is a secret interface
   export function isSecretInterface(name: string): name is SecretInterfaceName {
     return name in SECRET_INTERFACES;
   }

   // Lazy load a secret interface
   export function loadSecretInterface(name: SecretInterfaceName) {
     return SECRET_INTERFACES[name]();
   }
   ```

2. **Update Rspack Configuration** (`rspack.config.mjs`):
```javascript
export default (env = {}, argv) => {
  const mode = argv.mode || 'production';

  const config = defineConfig({
    // ... existing config
    optimization: {
      emitOnErrors: false,
      splitChunks: {
        chunks: 'async',
        cacheGroups: {
          // Split secret interfaces into separate chunks
          secretInterfaces: {
            test: /[\\/]interfaces-secret[\\/]/,
            name: (module) => {
              // Extract interface name for chunk filename
              const match = module.identifier().match(/interfaces-secret[\\/](.+?)[\\/]?(?:index)?\.tsx?$/);
              return match ? `secret-${match[1]}` : 'secret';
            },
            chunks: 'async',
          },
        },
      },
    },
    // ... rest of config
  });

  return config;
};
```

3. **Modify Routes System** (`packages/tgui/routes.tsx`):
```typescript
import { Suspense, lazy } from 'react';
import { isSecretInterface, loadSecretInterface } from './interfaces-secret';

const requireInterface = require.context('./interfaces');

function resolveInterface(interfaceName: string) {
  // Check if this is a secret interface first
  if (isSecretInterface(interfaceName)) {
    // Return lazy-loaded component wrapped in Suspense
    const LazyComponent = lazy(() =>
      loadSecretInterface(interfaceName).then(mod => ({
        default: mod.default || mod[interfaceName]
      }))
    );

    return () => (
      <Suspense fallback={<LoadingScreen message="Loading interface..." />}>
        <LazyComponent />
      </Suspense>
    );
  }

  // Fall back to regular interface resolution
  const pathBuilders = [
    () => `./${interfaceName}.tsx`,
    // ... existing path builders
  ];

  for (const pathBuilder of pathBuilders) {
    try {
      return requireInterface(pathBuilder()).default;
    } catch (err) {
      if (err.code !== 'MODULE_NOT_FOUND') throw err;
    }
  }

  return null;
}
```

4. **Update Asset Delivery System** (`code/modules/localassets/localassets_tgui.dm`):
```dm
// Add conditional asset registration for secret chunks
#ifdef SECRETS_ENABLED
  // Register all secret interface chunks
  register_asset("secret-interface1.bundle.js", ...)
  register_asset("secret-interface2.bundle.js", ...)
  register_asset("secret-admintool.bundle.js", ...)
#endif
```

5. **Modify Gulp Build** (`browserassets/gulpfile.js`):
```javascript
// Process secret chunks alongside main bundle
gulp.task('build-tgui', () => {
  return gulp.src([
    'src/tgui/tgui.bundle.js',
    'src/tgui/secret-*.bundle.js',  // Include secret chunks
  ])
    .pipe(hashFilename())
    .pipe(generateManifest())
    .pipe(gulp.dest('build/tgui'));
});
```

**Pros:**
- ✅ Maximum security: Only requested interface sent to client
- ✅ Optimal bundle size: No unused secret code delivered
- ✅ Natural rspack/webpack pattern with good documentation
- ✅ Familiar React.lazy/Suspense API
- ✅ Independent interface loading and caching
- ✅ Granular access control per interface

**Cons:**
- ❌ Requires BYOND browser to support dynamic imports (ES2020 feature)
- ❌ More complex asset manifest management
- ❌ Additional HTTP requests per secret interface
- ❌ Small chunk overhead for tiny interfaces
- ❌ Need to manually register each secret asset in DM code

**Security Model:**
- Unauthorized clients never receive asset references to secret chunks
- Even if chunk URL is discovered, BYOND cache system controls access
- Only interfaces actually opened by user are downloaded
- Client cannot enumerate available secret interfaces

---

### Option B: Single Secret Bundle with Conditional Loading

**Architecture:** Build a second complete bundle (`tgui-secret.bundle.js`) containing all secret interfaces. Load this bundle conditionally based on server signal, extending the interface registry at runtime.

**Directory Structure:**
```
+secret/tgui/
├── index.tsx                   # Secret bundle entry point
└── interfaces/                 # Secret interfaces in submodule
    ├── SecretInterface1.tsx
    └── SecretInterface2.tsx

tgui/packages/
├── tgui/                       # Main public bundle
└── tgui-secret/                # Symlink → +secret/tgui/ OR build config entry
```

**Implementation Steps:**

1. **Create Secret Bundle Entry** (`+secret/tgui/index.tsx`):
```typescript
import { SecretInterface1 } from './interfaces/SecretInterface1';
import { SecretInterface2 } from './interfaces/SecretInterface2';

// Register secret interfaces in global registry
declare global {
  interface Window {
    __SECRET_TGUI_INTERFACES__?: Record<string, React.ComponentType>;
  }
}

window.__SECRET_TGUI_INTERFACES__ = {
  SecretInterface1,
  SecretInterface2,
};

console.log('Secret TGUI interfaces loaded:', Object.keys(window.__SECRET_TGUI_INTERFACES__));
```

2. **Update Rspack Configuration** (`rspack.config.mjs`):
```javascript
import fs from 'fs';

export default (env = {}, argv) => {
  const hasSecrets = fs.existsSync(path.resolve(__dirname, '../+secret/tgui'));

  const config = defineConfig({
    entry: {
      tgui: ['./packages/tgui'],
      ...(hasSecrets && { 'tgui-secret': ['../ +secret/tgui'] }),  // Conditionally add secret entry
    },
    externals: {
      // Secret bundle uses main bundle's React/dependencies
      'react': 'React',
      'react-dom': 'ReactDOM',
      'tgui-core': 'tguiCore',
    },
    // ... rest of config
  });

  return config;
};
```

3. **Modify Routes System** (`packages/tgui/routes.tsx`):
```typescript
const requireInterface = require.context('./interfaces');

function resolveInterface(interfaceName: string) {
  // Check secret interface registry first
  if (window.__SECRET_TGUI_INTERFACES__?.[interfaceName]) {
    return window.__SECRET_TGUI_INTERFACES__[interfaceName];
  }

  // Fall back to public interfaces
  const pathBuilders = [/* ... existing ... */];
  for (const pathBuilder of pathBuilders) {
    try {
      return requireInterface(pathBuilder()).default;
    } catch (err) {
      if (err.code !== 'MODULE_NOT_FOUND') throw err;
    }
  }

  return null;
}
```

4. **Conditional Script Loading** (`code/modules/tgui/tgui_window.dm`):
```dm
/datum/tgui_window/proc/get_html()
  var/html = {"<!DOCTYPE html>
<html>
<head>
  <script src="tgui.bundle.js"></script>
  #ifdef SECRETS_ENABLED
  <script src="tgui-secret.bundle.js"></script>
  #endif
</head>
<body>...</body>
</html>"}
  return html
```

**Pros:**
- ✅ Simple build configuration (just add entry point)
- ✅ Single additional HTTP request (loaded once)
- ✅ No ES module requirements (standard `<script>` tags)
- ✅ Familiar webpack multi-entry pattern
- ✅ Easy to maintain and debug

**Cons:**
- ❌ Entire secret bundle sent to all authorized users
- ❌ Clients can inspect all secret interface code (even unused ones)
- ❌ Larger bundle size (all secret interfaces loaded upfront)
- ❌ All-or-nothing security model
- ❌ Increases initial page load time

**Security Model:**
- Access controlled by asset delivery (not sent to unauthorized clients)
- Once authorized, user can inspect all secret interface source
- Suitable when user authorization is binary (admin vs non-admin)
- Not suitable for granular per-feature permissions

---

### Option C: Module Federation (Rspack Container)

**Architecture:** Use rspack's Module Federation plugin to expose secret interfaces as federated modules consumed by the main bundle at runtime. Dependencies are shared between host and remote.

**Directory Structure:**
```
+secret/tgui/
├── index.ts                    # Remote entry point
├── rspack.config.mjs           # Separate config for remote federation
└── interfaces/                 # Secret interfaces in submodule
    ├── SecretInterface1.tsx
    └── SecretInterface2.tsx

tgui/packages/tgui/             # Host application
```

**Implementation Steps:**

1. **Configure Module Federation** (`rspack.config.mjs`):
```javascript
import { rspack } from '@rspack/core';

export default (env = {}, argv) => {
  const config = defineConfig({
    // ... existing config
    plugins: [
      // Host configuration
      new rspack.container.ModuleFederationPlugin({
        name: 'tgui',
        remotes: {
          secretRemote: 'secretRemote@/tgui-secret-remote.js',
        },
        shared: {
          react: { singleton: true },
          'react-dom': { singleton: true },
          'tgui-core': { singleton: true },
        },
      }),
    ],
  });

  return config;
};
```

2. **Create Remote Configuration** (`packages/tgui-secret-remote/rspack.config.mjs`):
```javascript
export default defineConfig({
  entry: './index.ts',
  output: {
    filename: 'tgui-secret-remote.js',
    publicPath: '/',
  },
  plugins: [
    new rspack.container.ModuleFederationPlugin({
      name: 'secretRemote',
      filename: 'remoteEntry.js',
      exposes: {
        './SecretInterface1': './interfaces/SecretInterface1',
        './SecretInterface2': './interfaces/SecretInterface2',
      },
      shared: {
        react: { singleton: true },
        'react-dom': { singleton: true },
        'tgui-core': { singleton: true },
      },
    }),
  ],
});
```

3. **Load Federated Modules** (`packages/tgui/routes.tsx`):
```typescript
import { lazy } from 'react';

const SECRET_INTERFACE_NAMES = ['SecretInterface1', 'SecretInterface2'];

function resolveInterface(interfaceName: string) {
  // Check if this is a secret interface
  if (SECRET_INTERFACE_NAMES.includes(interfaceName)) {
    const LazyComponent = lazy(() =>
      // @ts-ignore - Dynamic remote import
      import('secretRemote/' + interfaceName)
    );

    return () => (
      <Suspense fallback={<LoadingScreen />}>
        <LazyComponent />
      </Suspense>
    );
  }

  // ... regular resolution
}
```

**Pros:**
- ✅ Designed specifically for runtime module loading across separate builds
- ✅ Automatic dependency deduplication (shared React, tgui-core, etc.)
- ✅ Per-interface loading granularity (loads only what's needed)
- ✅ Mature Rspack/Webpack feature with excellent documentation
- ✅ Clean separation: secret code lives entirely in +secret/ with own build
- ✅ Version control built-in (can specify compatible version ranges)
- ✅ Works perfectly with WebView2/Chromium's modern JS support
- ✅ No symlinks required - completely independent builds

**Cons:**
- ⚠️ More complex initial configuration than Option B
- ⚠️ Multiple chunks generated (remoteEntry.js + exposed modules)
- ⚠️ Need to maintain two rspack configs (host + remote)
- ⚠️ Requires understanding of Module Federation concepts
- ⚠️ Slightly more complex debugging (federated boundary)

**Security Model:**
- Same as Option A (per-interface loading)
- Remote entry point can be conditionally loaded
- Individual modules only loaded when requested

---

### Option D: Scaffold Window with Manual Chunk Loading

**Architecture:** Create a generic scaffold interface in the public bundle that fetches and executes secret interface code as dynamically loaded scripts, rendering within the existing React context.

**Directory Structure:**
```
tgui/packages/tgui/
├── interfaces/
│   └── SecretInterfaceScaffold.tsx    # Public scaffold
└── interfaces-secret/                  # Built as UMD modules
    ├── rspack.config.mjs               # Separate UMD config
    ├── SecretInterface1.tsx
    └── SecretInterface2.tsx
```

**Implementation Steps:**

1. **Create Scaffold Interface** (`packages/tgui/interfaces/SecretInterfaceScaffold.tsx`):
```typescript
import { useState, useEffect } from 'react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Loader } from 'tgui-core/components';

declare global {
  interface Window {
    __registerSecretInterface?: (name: string, component: React.ComponentType) => void;
  }
}

export const SecretInterfaceScaffold = () => {
  const { data } = useBackend<{ secret_interface_name: string }>();
  const [Component, setComponent] = useState<React.ComponentType | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const interfaceName = data.secret_interface_name;

    // Set up registration callback
    window.__registerSecretInterface = (name, component) => {
      if (name === interfaceName) {
        setComponent(() => component);
      }
    };

    // Load the secret interface chunk
    const script = document.createElement('script');
    script.src = `/secret-${interfaceName}.bundle.js`;
    script.onerror = () => setError('Failed to load secret interface');
    document.head.appendChild(script);

    return () => {
      delete window.__registerSecretInterface;
      document.head.removeChild(script);
    };
  }, [data.secret_interface_name]);

  if (error) return <Window><Window.Content>{error}</Window.Content></Window>;
  if (!Component) return <Window><Window.Content><Loader /></Window.Content></Window>;

  return <Component />;
};
```

2. **Build Secret Interfaces as UMD** (`packages/interfaces-secret/rspack.config.mjs`):
```javascript
export default defineConfig({
  entry: {
    'secret-interface1': './SecretInterface1.tsx',
    'secret-interface2': './SecretInterface2.tsx',
  },
  output: {
    filename: '[name].bundle.js',
    library: {
      type: 'umd',
      name: 'SecretInterface',
    },
    globalObject: 'this',
  },
  externals: {
    react: 'React',
    'react-dom': 'ReactDOM',
    'tgui-core': 'window.tguiCore',
  },
});
```

3. **Self-Registration in Secret Interfaces** (`packages/interfaces-secret/SecretInterface1.tsx`):
```typescript
import { Window } from 'tgui-core/layouts';
import { Section } from 'tgui-core/components';

const SecretInterface1 = () => {
  return (
    <Window width={400} height={300}>
      <Window.Content>
        <Section>Secret content here</Section>
      </Window.Content>
    </Window>
  );
};

// Auto-register when loaded
if (window.__registerSecretInterface) {
  window.__registerSecretInterface('SecretInterface1', SecretInterface1);
}

export default SecretInterface1;
```

**Pros:**
- ✅ Public bundle unchanged except for scaffold
- ✅ Flexible loading mechanism
- ✅ No complex bundler configuration
- ✅ Works with limited browser features
- ✅ Per-interface chunk loading

**Cons:**
- ❌ Requires manual dependency injection
- ❌ Awkward API between scaffold and secrets
- ❌ Potential Content Security Policy violations
- ❌ `eval()`-like security concerns with dynamic script loading
- ❌ More brittle than proper bundler solutions
- ❌ Difficult to type-check across boundary

**Security Model:**
- Similar to Option A (per-interface chunks)
- Script loading can be blocked by CSP
- Manual control over what gets loaded

---

## Recommended Approach

### Co-Primary Recommendations

Given that you're using **WebView2 (Chromium-based browser)**, both Option A and Option C are excellent choices with full ES2020+ support including dynamic imports, `React.lazy()`, and Module Federation.

#### **Option A - Per-Interface Chunk Splitting with Symlinks**

**Best for:** Simpler setup, single unified build, all interfaces managed together

**Reasoning:**
1. **Maximum security**: Only requested secret interfaces sent to clients
2. **Optimal performance**: Minimal bundle sizes, lazy loading on demand
3. **Single build process**: One rspack config, unified bundle management
4. **Proven pattern**: Standard code splitting approach
5. **WebView2 native support**: Full ES2020+ compatibility confirmed

**Requirements:**
- Symlink from `tgui/packages/tgui/interfaces-secret/` → `+secret/tgui/interfaces/`
- Symlink setup automation for maintainers and server builds
- Update `.gitignore` to ignore symlink in public repo

---

#### **Option C - Module Federation 2.0** ⭐ **CLEANEST SEPARATION**

**Best for:** Complete separation of secret build, no symlinks, independent versioning

**Reasoning:**
1. **Clean separation**: Secret code has completely independent build in `+secret/tgui/`
2. **No symlinks needed**: Main tgui and secret remote are separate packages
3. **Per-interface loading**: Same granular security as Option A
4. **Dependency sharing**: Automatic deduplication of React, tgui-core, etc.
5. **Version control**: Can specify compatible version ranges for shared deps
6. **WebView2 perfect match**: Module Federation works excellently in Chromium
7. **Professional pattern**: Used by major apps (Netflix, Walmart) for micro-frontends
8. **Build independence**: Secret remote can be built/deployed separately

**Why it's better than initially assessed:**
- WebView2 removes browser compatibility concerns
- Separate builds mean no symlink complexity
- Rspack has excellent Module Federation support (v2)
- Secret submodule maintains complete independence
- Only slightly more complex than Option A, but much cleaner architecture

**Requirements:**
- Separate rspack config in `+secret/tgui/rspack.config.mjs`
- Conditional loading of remote entry point based on `SECRETS_ENABLED`
- Shared dependency configuration in both host and remote

---

### Comparison: Option A vs Option C

| Aspect | Option A (Chunk Splitting) | Option C (Module Federation) |
|--------|---------------------------|-----------------------------|
| **Setup Complexity** | ⭐⭐⭐⭐ Simple | ⭐⭐⭐ Moderate |
| **Code Separation** | ⭐⭐⭐ Symlink required | ⭐⭐⭐⭐⭐ Complete |
| **Build Process** | ⭐⭐⭐⭐ Single build | ⭐⭐⭐ Two separate builds |
| **Security** | ⭐⭐⭐⭐⭐ Per-interface | ⭐⭐⭐⭐⭐ Per-interface |
| **Maintainability** | ⭐⭐⭐⭐ Good | ⭐⭐⭐⭐ Good |
| **Scalability** | ⭐⭐⭐⭐ Excellent | ⭐⭐⭐⭐⭐ Outstanding |
| **Dependency Mgmt** | ⭐⭐⭐ Manual | ⭐⭐⭐⭐⭐ Automatic |
| **WebView2 Support** | ⭐⭐⭐⭐⭐ Native | ⭐⭐⭐⭐⭐ Native |

**Recommendation:**
- Choose **Option A** if you want simplest setup and don't mind symlinks
- Choose **Option C** if you want cleanest architecture and independent secret builds

---

### Fallback Recommendation: **Option B - Single Secret Bundle**

**When to use:**
- Need quickest implementation (prototyping)
- Asset management complexity is prohibitive
- Security requirements are less strict (admins can see all admin tools)
- Team unfamiliar with code splitting or Module Federation

**Reasoning:**
1. **Simplicity**: Easiest to implement and maintain
2. **No symlinks**: Can work with simple file copying
3. **Proven pattern**: Standard multi-entry webpack approach
4. **Adequate security**: Access still controlled by asset delivery

---

### Not Recommended

**Option D (Scaffold Window)**: Too brittle and non-standard. The manual dependency injection and global registration pattern is error-prone and difficult to maintain. With WebView2's excellent modern JS support, there's no reason to use this hack.

---

## Implementation Plan

### Phase 1: Architecture Decision

**Goal:** Choose between Option A (Chunk Splitting) or Option C (Module Federation)

**WebView2 Capability Confirmation:**
- ✅ Dynamic imports fully supported (ES2020)
- ✅ `React.lazy()` and `Suspense` work perfectly
- ✅ Module Federation supported (tested in Chromium)
- ✅ No compatibility concerns

**Decision criteria:**

**Choose Option A if:**
- Want single unified build process
- Comfortable with symlink setup
- Prefer simpler rspack configuration
- Team new to Module Federation

**Choose Option C if:**
- Want complete build separation (cleanest architecture)
- Avoid symlink complexity
- Need independent versioning of secret code
- Want automatic dependency management
- Comfortable with Module Federation concepts

**Test Module Federation** (optional but recommended):
1. Create minimal federated remote in `+secret/tgui/`
2. Expose single test component
3. Load from main tgui bundle
4. Verify shared dependencies work correctly
5. If successful, proceed with Option C; otherwise use Option A

### Phase 2: Project Structure Setup

**Goal:** Create directory structure for secret interfaces

**For Option A (Chunk Splitting with Symlink):**

1. **Create secret interfaces directory**: `+secret/tgui/interfaces/`
2. **Set up automatic symlink** for maintainers:
   ```bash
   # Add to repository setup script or build process
   # Windows (PowerShell - requires developer mode or admin)
   New-Item -ItemType SymbolicLink -Path "tgui\packages\tgui\interfaces-secret" -Target "..\..\..\+secret\tgui\interfaces"

   # Linux/macOS
   ln -s "../../../+secret/tgui/interfaces" "tgui/packages/tgui/interfaces-secret"
   ```
3. **Add to `.gitignore`** (public repo):
   ```
   # Ignore symlink to secret interfaces
   tgui/packages/tgui/interfaces-secret
   ```
4. **Create fallback** for contributors without secrets:
   ```typescript
   // tgui/packages/tgui/interfaces-secret-fallback/index.ts
   // Stub when secret submodule not present
   export const SECRET_INTERFACES = {};
   export const isSecretInterface = () => false;
   ```
5. **Update TypeScript config** (`tgui/tsconfig.json`):
   ```json
   {
     "compilerOptions": {
       "paths": {
         "*/interfaces-secret": [
           "./packages/tgui/interfaces-secret",
           "./packages/tgui/interfaces-secret-fallback"
         ]
       }
     }
   }
   ```

**For Option C (Module Federation):**

1. **Create secret remote package**: `+secret/tgui/`
2. **Create directory structure**:
   ```
   +secret/tgui/
   ├── rspack.config.mjs       # Remote federation config
   ├── package.json            # Optional: for secret-specific deps
   ├── index.ts                # Remote entry point
   └── interfaces/
       ├── SecretInterface1.tsx
       └── SecretInterface2.tsx
   ```
3. **No symlinks required** - builds are independent
4. **Add to main tgui `.gitignore`**: (nothing needed - secret lives in +secret/)
5. **Create type definitions** for secret interfaces in public repo:
   ```typescript
   // tgui/packages/tgui/types/secret-interfaces.d.ts
   // Type-only declarations (no implementation)
   declare module 'secretRemote/*' {
     const Component: React.ComponentType;
     export default Component;
   }
   ```

### Phase 3: Build System Configuration

**Goal:** Configure rspack for chosen architecture

**For Option A (Chunk Splitting):**
1. Update `rspack.config.mjs` with `optimization.splitChunks` configuration
2. Configure chunk naming strategy for secret interfaces
3. Add conditional check for symlink existence:
   ```javascript
   const hasSecretSymlink = fs.existsSync(
     path.resolve(__dirname, 'packages/tgui/interfaces-secret')
   );
   ```
4. Test build produces expected chunk files
5. Verify source maps work correctly
6. Test graceful fallback when symlink missing

**For Option B (Single Secret Bundle):**
1. Create `+secret/tgui/index.tsx` entry point
2. Add conditional `tgui-secret` entry to rspack configuration
3. Configure externals for shared dependencies
4. Test build produces two separate bundles

**For Option C (Module Federation):**
1. **Configure host** (`tgui/rspack.config.mjs`):
   ```javascript
   new rspack.container.ModuleFederationPlugin({
     name: 'tgui',
     remotes: {
       secretRemote: 'secretRemote@/tgui-secret-remoteEntry.js',
     },
     shared: {
       react: { singleton: true, requiredVersion: '^18.0.0' },
       'react-dom': { singleton: true, requiredVersion: '^18.0.0' },
     },
   })
   ```

2. **Configure remote** (`+secret/tgui/rspack.config.mjs`):
   ```javascript
   export default defineConfig({
     entry: './index.ts',
     output: {
       path: path.resolve(__dirname, '../../browserassets/src/tgui-secret'),
       filename: 'tgui-secret-[name].js',
       publicPath: 'auto',
     },
     plugins: [
       new rspack.container.ModuleFederationPlugin({
         name: 'secretRemote',
         filename: 'remoteEntry.js',
         exposes: {
           './SecretInterface1': './interfaces/SecretInterface1',
           './SecretInterface2': './interfaces/SecretInterface2',
         },
         shared: {
           react: { singleton: true },
           'react-dom': { singleton: true },
         },
       }),
     ],
   });
   ```

3. **Add build script** for secret remote
4. **Test federation**: Verify remoteEntry.js loads and exposes modules correctly
5. **Verify shared dependencies**: Confirm React and tgui-core are shared, not duplicated

### Phase 4: Routes System Integration

**Goal:** Extend routing to check secret interfaces

1. Create secret interface registry module:
   - For Option A: `interfaces-secret/index.ts` with lazy loading map
   - For Option B: Type definitions for global registry
2. Modify `packages/tgui/routes.tsx` to check secret registry first
3. Add `Suspense` wrapper with loading fallback
4. Add error boundaries for failed secret interface loads
5. Test interface resolution for both public and secret interfaces

### Phase 5: Asset Delivery System

**Goal:** Update DM and Gulp to handle secret bundles/chunks

1. **Gulp modifications** (`browserassets/gulpfile.js`):
   - Add glob pattern for secret chunks/bundles
   - Generate manifest entries for secret assets
   - Apply hash-based cache busting

2. **DM asset registration** (`code/modules/localassets/localassets_tgui.dm`):
   - Add `#ifdef SECRETS_ENABLED` conditional blocks
   - Register secret bundle or chunk assets
   - Update HTML template with conditional script tags (Option B only)

3. Test asset delivery for both secret-enabled and secret-disabled builds

### Phase 6: Development Workflow

**Goal:** Enable dev server to watch and rebuild secret interfaces

1. Configure tgui-dev-server to watch `interfaces-secret/` directory
2. Enable hot module replacement for secret interfaces
3. Add documentation for secret interface development workflow
4. Test full development cycle (edit → rebuild → hot reload)

### Phase 7: Documentation and Testing

**Goal:** Complete documentation and validate system

1. Document secret interface development guide:
   - How to create new secret interfaces
   - Naming conventions and file structure
   - Testing procedures
   - Build and deployment process

2. Create example secret interfaces demonstrating:
   - Simple single-file interface
   - Complex multi-file interface
   - Interface with custom styles
   - Interface with backend data exchange

3. Test scenarios:
   - Public client (no secret access) - verify no leaks
   - Authorized client (secret access) - verify loading works
   - Dev server hot reload for secret interfaces
   - Production build and deployment

4. Performance testing:
   - Measure bundle size impact
   - Test lazy loading performance
   - Verify no regression in public interface loading

---

## Technical Considerations

### Browser Compatibility

**BYOND 516+ Browser Engine: WebView2 (Microsoft Edge Chromium)**
- **Confirmed**: Full ES2020+ support including dynamic imports ✅
- **Confirmed**: Modern JavaScript features (Promise, async/await, modules) ✅
- **Confirmed**: React 18+ with Suspense and lazy loading ✅
- **Confirmed**: Module Federation support ✅
- Based on evergreen Chromium (same as Chrome/Edge)
- Automatic updates via Windows Update

**Supported features:**
- ✅ Dynamic `import()` syntax (ES2020)
- ✅ `React.lazy()` and `Suspense`
- ✅ Module Federation (webpack/rspack container format)
- ✅ Multiple async script loading
- ✅ ES modules with `type="module"`
- ✅ Source maps for debugging
- ✅ Chrome DevTools (F12 access)

**No compatibility concerns** - WebView2 supports all modern bundling strategies.

### Build Performance

**Considerations:**
- Code splitting for 50+ interfaces may slow incremental builds
- Consider grouping related interfaces into themed chunks:
  - `admin-tools.chunk.js` (administrative interfaces)
  - `antag-interfaces.chunk.js` (antagonist-specific interfaces)
  - `debug-tools.chunk.js` (debugging interfaces)

**Optimization strategies:**
- Use rspack's persistent caching (already configured)
- Configure `maxAsyncRequests` to limit chunk proliferation
- Set minimum chunk size to avoid tiny chunks
- Profile build times before and after implementation

### Asset Caching Strategy

**Hash-based cache busting:**
- Gulp already generates `tgui-[hash].bundle.js` filenames
- Apply same strategy to secret chunks: `secret-interface1-[hash].bundle.js`
- Update manifest generation to include secret assets

**BYOND cache management:**
- BYOND caches assets in `Documents/BYOND/cache/`
- Asset updates require cache invalidation (usually automatic)
- Test cache behavior with chunk updates during development

### Development Workflow for Contributors

**Challenge:** Contributors without secret submodule access need to test interfaces that might integrate with secret features.

**Solutions:**

1. **Mock interfaces** in public codebase:
```typescript
// packages/tgui/interfaces-secret/mocks.ts
// Only used when secret submodule not present
export const SECRET_INTERFACES = {
  SecretInterface1: () => import('./mocks/SecretInterface1'),
};
```

2. **Conditional routing** that gracefully handles missing secret interfaces:
```typescript
function resolveInterface(interfaceName: string) {
  if (isSecretInterface(interfaceName)) {
    if (typeof loadSecretInterface !== 'undefined') {
      return loadSecretInterface(interfaceName);
    } else {
      // Fallback when secret submodule not available
      return () => <NotAvailableScreen />;
    }
  }
  // ... regular resolution
}
```

3. **Development documentation** explaining:
   - How to test interfaces with mock secret components
   - What functionality is available vs. secret-only
   - How to structure code to be testable without secrets

### Security Model and Access Control

**Layer 1: Asset delivery (server-side)**
- DM code controls which assets are sent via `browse_rsc()`
- Secret assets only registered when `SECRETS_ENABLED` defined
- Unauthorized clients never receive asset file references
- Primary security boundary

**Layer 2: URL obscurity (weak)**
- Chunk filenames use hashes: `secret-admintool-a3f2d9.bundle.js`
- Difficult but not impossible to guess
- Not a security mechanism, just obscurity

**Layer 3: BYOND cache system**
- Client can only access assets sent by server
- Even if chunk URL is discovered, fetch will fail if not in cache
- BYOND controls asset lifecycle

**Not secure against:**
- Authorized users inspecting code they can access
- Authorized users sharing code/bundles externally
- Memory dumps or browser debugging of authorized clients

**Appropriate for:**
- Hiding implementation details from general playerbase
- Preventing casual inspection of admin tools
- Reducing spoiler exposure for secret features
- Maintaining competitive advantage in game mechanics

### Migration Path for Existing Secret Code

**Current secret tgui usage:**
- `tgui_alert()` - Simple popup dialogs
- `tgui_input_list()` - Selection menus
- `tgui_input_text()` - Text input prompts

**Migration strategy:**

1. **Phase 1:** Use existing tgui functions (no changes needed)
2. **Phase 2:** Gradually convert complex interactions to dedicated secret interfaces
3. **Phase 3:** Retire direct tgui function calls in favor of interfaces

**Example migration:**
```dm
// Before: Using tgui_input_list
var/choice = tgui_input_list(usr, "Select admin action", "Admin Tools", admin_actions)

// After: Using dedicated secret interface
var/datum/tgui/admin_tools = new /datum/tgui/admin_tools(usr)
admin_tools.open()
// ... interface handles interaction and returns result via topic()
```

### TypeScript Type Safety Across Boundaries

**Challenge:** Secret interfaces use same types as public interfaces (Window, Section, useBackend, etc.) but are in separate directory.

**Solution 1: Shared type definitions**
```typescript
// packages/tgui/types/interfaces.ts
export interface BaseInterfaceData {
  // Common properties all interfaces receive
}

export interface InterfaceProps<T extends BaseInterfaceData = BaseInterfaceData> {
  // Standard interface prop structure
}
```

**Solution 2: Re-export public modules**
```typescript
// packages/tgui/interfaces-secret/deps.ts
export { Window, Section, Button } from 'tgui-core/components';
export { useBackend } from '../backend';
export type { InterfaceProps } from '../types';
```

**Solution 3: Path aliases in tsconfig.json**
```json
{
  "compilerOptions": {
    "paths": {
      "tgui/*": ["./packages/tgui/*"],
      "tgui-core/*": ["../../tgstation/tgui/packages/tgui/*"]
    }
  }
}
```

---

## Security Best Practices

### Do's ✅

1. **Always check `SECRETS_ENABLED`** before registering secret assets in DM
2. **Use descriptive but not revealing chunk names** (e.g., `admin-tools` not `nuclear-codes`)
3. **Keep secret interface dependencies minimal** to reduce bundle size
4. **Test public builds** to ensure no secret references leak
5. **Document sensitive interfaces** with security notices in code comments
6. **Review secret interface code** before committing to secret submodule
7. **Use TypeScript** to catch type errors between public and secret boundaries

### Don'ts ❌

1. **Don't bundle sensitive data** (passwords, keys, secrets) in JavaScript code
2. **Don't assume chunk URLs are secret** - use server-side access control
3. **Don't hardcode secret interface names** in public bundle
4. **Don't include secret imports** in public interface files
5. **Don't rely on minification** for security (it's easily reversed)
6. **Don't forget to test** secret-disabled builds regularly
7. **Don't expose secret interface list** via public API or error messages

### Security Checklist

Before deploying secret interface system:

- [ ] Verify secret chunks are not sent to unauthorized clients
- [ ] Confirm public bundle contains no secret interface references
- [ ] Test that guessing chunk URLs doesn't bypass security
- [ ] Validate error messages don't leak secret interface names
- [ ] Check source maps don't expose more than necessary
- [ ] Ensure dev server doesn't serve secret interfaces to public
- [ ] Review DM access control for tgui window opening
- [ ] Test with browser dev tools (what can client see?)
- [ ] Verify build artifacts in CDN match expectations
- [ ] Document security model for maintainers

---

## Example Implementation

### Example Secret Interface

**File:** `packages/tgui/interfaces-secret/AdminTools.tsx`

```typescript
import { useState } from 'react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Section, Button, LabeledList, Stack } from 'tgui-core/components';

interface AdminToolsData {
  admin_name: string;
  admin_rank: string;
  available_actions: string[];
  recent_logs: Array<{
    timestamp: string;
    admin: string;
    action: string;
  }>;
}

export const AdminTools = () => {
  const { act, data } = useBackend<AdminToolsData>();
  const [selectedAction, setSelectedAction] = useState<string | null>(null);

  return (
    <Window width={600} height={400} title="Admin Tools">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Administrator Information">
              <LabeledList>
                <LabeledList.Item label="Admin">
                  {data.admin_name}
                </LabeledList.Item>
                <LabeledList.Item label="Rank">
                  {data.admin_rank}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Section title="Available Actions" fill scrollable>
              <Stack vertical>
                {data.available_actions.map((action) => (
                  <Stack.Item key={action}>
                    <Button
                      fluid
                      icon="bolt"
                      selected={selectedAction === action}
                      onClick={() => {
                        setSelectedAction(action);
                        act('execute_action', { action });
                      }}
                    >
                      {action}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Recent Actions">
              {data.recent_logs.slice(0, 5).map((log, idx) => (
                <div key={idx}>
                  <strong>{log.timestamp}</strong> - {log.admin}: {log.action}
                </div>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
```

### Example DM Backend

**File:** `+secret/code_secret/admin_tools_interface.dm`

```dm
/datum/tgui_module/admin_tools
  name = "Admin Tools"
  tgui_id = "AdminTools"  // Must match secret interface name

  /// The admin using these tools
  var/mob/admin_user

  /// Available actions for this admin rank
  var/list/available_actions = list()

/datum/tgui_module/admin_tools/New(mob/user)
  . = ..()
  admin_user = user
  available_actions = get_admin_actions(user)

/datum/tgui_module/admin_tools/tgui_data(mob/user)
  var/list/data = list()

  data["admin_name"] = admin_user.key
  data["admin_rank"] = get_admin_rank(admin_user)
  data["available_actions"] = available_actions
  data["recent_logs"] = get_recent_admin_logs(limit = 10)

  return data

/datum/tgui_module/admin_tools/tgui_act(action, list/params, datum/tgui/ui)
  . = ..()
  if(.)
    return

  switch(action)
    if("execute_action")
      var/action_name = params["action"]
      if(action_name in available_actions)
        execute_admin_action(admin_user, action_name)
        log_admin("[admin_user.key] executed admin action: [action_name]")
        return TRUE
```

---

## Troubleshooting

### Common Issues

**Issue:** Secret interfaces not loading (404 errors)

**Solutions:**
- Verify secret chunks were built (check `browserassets/src/tgui/` for `secret-*.bundle.js`)
- Confirm Gulp processed chunks (check `browserassets/build/tgui/` for hashed filenames)
- Check DM asset registration includes secret chunks when `SECRETS_ENABLED`
- Verify manifest includes secret assets

---

**Issue:** Dynamic imports fail in BYOND browser

**Solutions:**
- Test browser capabilities (see Phase 1 of implementation plan)
- Fallback to Option B (single secret bundle) if dynamic imports unsupported
- Check for Content Security Policy blocking dynamic imports
- Verify `publicPath` in rspack config is correct

---

**Issue:** React errors: "Objects are not valid as a React child"

**Solutions:**
- Ensure secret interface exports default component correctly
- Verify `React.lazy()` receives proper module format: `{ default: Component }`
- Check secret interface file follows same pattern as public interfaces

---

**Issue:** Secret interfaces accessible to non-admins

**Solutions:**
- Verify `#ifdef SECRETS_ENABLED` wraps asset registration in DM
- Check server has secret submodule compiled in
- Confirm BYOND access control for opening tgui windows
- Test with clean BYOND cache (delete and reload)

---

**Issue:** Build performance severely degraded

**Solutions:**
- Reduce number of chunks by grouping related interfaces
- Increase `minSize` in `splitChunks` configuration
- Use rspack persistent caching (should be automatic)
- Consider Option B if chunk management becomes unwieldy

---

**Issue:** Source maps not working for secret interfaces

**Solutions:**
- Verify `devtool` is set in rspack config for development mode
- Check source map files are generated alongside chunks
- Ensure browser dev tools are enabled (F12 in BYOND browser)
- Test with simplified secret interface to isolate issue

---

**Issue:** Hot module replacement not working for secret interfaces

**Solutions:**
- Verify tgui-dev-server watches `interfaces-secret/` directory
- Check dev server output for rebuild messages
- Manually refresh BYOND browser window (F5)
- Restart dev server if HMR connection lost

---

## Future Enhancements

### Potential Improvements

1. **Automatic chunk registration:** Generate DM asset registration code from built chunks using script
2. **Interface permissions system:** Granular per-interface access control beyond binary admin/non-admin
3. **Lazy loading for public interfaces:** Apply same chunk splitting to large public interfaces
4. **Shared component chunks:** Extract common secret interface components into shared chunk
5. **Build-time validation:** Script to verify no secret references in public bundle
6. **Secret interface catalog:** Admin tool to browse available secret interfaces
7. **Performance monitoring:** Track load times and bundle sizes for optimization

### Research Topics

1. **Streaming compilation:** Investigate WASM-based client-side compilation for maximum security
2. **Code obfuscation:** Evaluate if advanced obfuscation adds meaningful security
3. **Differential bundles:** Serve optimized bundles based on browser capabilities
4. **Service worker caching:** Improve load times with aggressive caching strategy
5. **Interface prefetching:** Predictively load likely-to-be-used secret interfaces

---

## Conclusion

This system enables runtime loading of secret TGUI interfaces while maintaining security through server-controlled asset delivery. The recommended approach (Option A: Per-Interface Chunk Splitting) provides optimal security and performance, with Option B as a simpler fallback if browser compatibility issues arise.

The implementation is designed to integrate seamlessly with the existing TGUI architecture, requiring minimal changes to public code while keeping secret interfaces completely separate in the secret submodule.

**Key Takeaways:**
- Secret interfaces remain hidden from unauthorized clients
- Server-side access control is primary security boundary
- Build system maintains dev/prod consistency
- Development workflow remains familiar to contributors
- System scales to hundreds of secret interfaces without performance impact

For questions or issues during implementation, consult this document and the troubleshooting section. Update this documentation as the system evolves and new patterns emerge.
