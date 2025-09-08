/**
 * @file
 * @copyright 2025
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { useCallback, useContext } from 'react';
import { Modal } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { ListInputModal } from '../../ListInputWindow/ListInputModal';
import * as occupationActions from '../actions';
import { PriorityLevel } from '../type';
import { ModalContext } from './ModalContext';

const items: [number, string][] = [
  [PriorityLevel.Medium, 'Medium Priority'],
  [PriorityLevel.Low, 'Low Priority'],
  [PriorityLevel.Unwanted, 'Unwanted'],
];
const itemStrings = items.map((item) => item[1]);
const MODAL_HEIGHT = 16; // hardcoded to fit all options

const stringToLevel = (itemString: string) =>
  items.find((item) => item[1] === itemString)?.[0];

export const ResetOccupationPreferencesModal = () => {
  const { act } = useBackend();
  const modalContext = useContext(ModalContext);
  const { showResetOccupationPreferencesModal } = modalContext;
  const handleEscape = useCallback(
    () => showResetOccupationPreferencesModal(undefined),
    [showResetOccupationPreferencesModal],
  );
  const handleLevelSelected = useCallback((itemString: string) => {
    const selectedLevel = stringToLevel(itemString);
    if (selectedLevel !== undefined) {
      occupationActions.resetJobPriorityLevels(act, selectedLevel);
    }
    showResetOccupationPreferencesModal(undefined);
  }, []);
  return (
    <Modal onEscape={handleEscape} height={MODAL_HEIGHT}>
      <ListInputModal
        items={itemStrings}
        default_item={itemStrings[0]}
        message="Reset All"
        on_selected={handleLevelSelected}
        on_cancel={handleEscape}
        start_with_search={false}
        capitalize={false}
      />
    </Modal>
  );
};
