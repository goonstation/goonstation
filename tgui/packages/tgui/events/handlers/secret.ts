import { configAtom, store } from '../store';

// --------- Handlers ------------------------------------------------------///

type SecretIdPayload = {
  id?: string;
  name?: string;
  token?: string;
};

/**
 * |GOONSTATION-ADD| Maps interface names to secret bundle IDs.
 */
export function secretId(payload: SecretIdPayload): void {
  const name = payload?.name;
  const id = payload?.token || payload?.id;

  if (!name || !id) {
    return;
  }

  store.set(configAtom, (prev) => ({
    ...prev,
    secretInterfaces: {
      ...prev.secretInterfaces,
      [name]: id,
    },
  }));
}
