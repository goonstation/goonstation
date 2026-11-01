/**
 * @file
 * @copyright 2025
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { createContext, useState } from 'react';

import { useConstant } from '../../common/hooks';
import type { ModalContextState, ModalContextValue } from '../type';

const stubModalContextType: ModalContextValue = {
  setOccupationPriorityModalOptions: () => undefined,
  showResetOccupationPreferencesModal: () => undefined,
};

export const ModalContext = createContext(stubModalContextType);

export const useModalContext = () => {
  const [modalContextState, setModalContextState] = useState<ModalContextState>(
    () => ({
      occupationModal: undefined,
      resetOccupationPreferencesModal: undefined,
    }),
  );
  const modalContextValue = useConstant<ModalContextValue>(() => ({
    setOccupationPriorityModalOptions: (options) =>
      setModalContextState((prev) => ({
        ...prev,
        occupationModal: options,
      })),
    showResetOccupationPreferencesModal: (show) =>
      setModalContextState((prev) => ({
        ...prev,
        resetOccupationPreferencesModal: show,
      })),
  }));
  return [modalContextValue, modalContextState, ModalContext] as const;
};
