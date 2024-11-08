import { createContext } from 'react';

import type { UiState } from './type';

export const UiStateContext = createContext<UiState>({
  showTagsModal: false,
  setShowTagsModal: () => {}, // no-op setter by default, as value/setter are not wired up
});
