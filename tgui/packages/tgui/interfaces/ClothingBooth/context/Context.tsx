import { useMemo, useState } from 'react';

import { ClothingBoothSlotKey } from '../type';
import { FiltersContext } from './FiltersContext';
import { UiStateContext } from './UiState';

export const ProvideTheDamnContext = ({ children }) => {
  const [slots, setSlotFilters] = useState<
    Partial<Record<ClothingBoothSlotKey, boolean>>
  >({});

  const mergeSlotFilter = (filter: ClothingBoothSlotKey) =>
    setSlotFilters({
      ...slots,
      [filter]: !slots[filter],
    });

  const [showTagsModal, setShowTagsModal] = useState(false);
  const uiState = useMemo(
    () => ({
      showTagsModal,
      setShowTagsModal,
    }),
    [showTagsModal],
  );

  return (
    <FiltersContext.Provider
      value={{ slotFilters: slots, setSlotFilters, mergeSlotFilter }}
    >
      <UiStateContext.Provider value={uiState}>
        {children}
      </UiStateContext.Provider>
    </FiltersContext.Provider>
  );
};
