/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/DisturbHerb)
 * @license MIT
 */

import { createContext } from 'react';

import { ClothingBoothSlotKey } from '../type';

interface TagsContextValues {
  slotFilters: Partial<Record<ClothingBoothSlotKey, boolean>>;
  setSlotFilters: React.Dispatch<
    React.SetStateAction<Record<ClothingBoothSlotKey, boolean>>
  >;
  mergeSlotFilter: (filter: ClothingBoothSlotKey) => void;
}

export const FiltersContext = createContext<TagsContextValues>({
  slotFilters: {},
  setSlotFilters: () => {},
  mergeSlotFilter: () => {},
});
