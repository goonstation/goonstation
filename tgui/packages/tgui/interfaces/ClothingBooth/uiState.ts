import { createContext } from 'react';

import type { UiState } from './type';

export const UiStateContext = createContext<UiState>({
  appliedTagFilters: {},
  showTagsModal: false,
  setAppliedTagFilters: () => {}, // no-op setter by default
  setShowTagsModal: () => {}, // no-op setter by default
});
