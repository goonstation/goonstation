/**
 * @file
 * @copyright 2025
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { createContext, useState } from 'react';

import { useConstant } from '../../common/hooks';
import type { ModalContextState, ModalContextValue } from '../type';

const stubModalContextType: ModalContextValue = {
  setJobModalOptions: () => undefined,
};

export const ModalContext = createContext(stubModalContextType);

export const useModalContext = () => {
  const [modalContextState, setModalContextState] = useState<ModalContextState>(
    () => ({
      jobModal: undefined,
    }),
  );
  const modalContextValue = useConstant<ModalContextValue>(() => ({
    setJobModalOptions: (options) =>
      setModalContextState((prev) => ({
        ...prev,
        jobModal: options,
      })),
  }));
  return [modalContextValue, modalContextState, ModalContext] as const;
};
