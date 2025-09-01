import { createContext, useState } from 'react';

import { useConstant } from '../../common/hooks';
import type { ModalContextState, ModalContextValue } from '../type';

const stubModalContextType: ModalContextValue = {
  setOccupationModalOptions: () => undefined,
};

export const ModalContext = createContext(stubModalContextType);

export const useModalContext = () => {
  const [modalContextState, setModalContextState] = useState<ModalContextState>(
    () => ({
      occupationModal: undefined,
    }),
  );
  const modalContextValue = useConstant<ModalContextValue>(() => ({
    setOccupationModalOptions: (options) =>
      setModalContextState((prev) => ({
        ...prev,
        occupationModal: options,
      })),
  }));
  return [ModalContext, modalContextValue, modalContextState] as const;
};
