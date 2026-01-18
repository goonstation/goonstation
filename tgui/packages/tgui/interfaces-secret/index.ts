/**
 * Secret interface registry.
 *
 * This file is tracked in the public repository and intentionally does NOT
 * enumerate secret interfaces. Secret interfaces are built as separate bundles
 * and loaded by opaque filename provided by the server at runtime.
 */

export { hasSecretInterface, loadSecretInterface } from './registry.generated';
