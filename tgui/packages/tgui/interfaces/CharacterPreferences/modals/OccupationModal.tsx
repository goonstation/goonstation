import { useCallback, useContext, useMemo } from 'react';
import { Modal } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { ListInputModal } from '../../ListInputWindow/ListInputModal';
import * as occupationActions from '../actions';
import { JobPriority, type OccupationModalOptions } from '../type';
import { ModalContext } from './ModalContext';

const items: [number, string][] = [
  [JobPriority.Favorite, 'Favorite'],
  [JobPriority.Medium, 'Medium Priority'],
  [JobPriority.Low, 'Low Priority'],
  [JobPriority.Unwanted, 'Unwanted'],
];
const OPEN_WIKI_PAGE_STRING = 'Open Wiki Page';
const MODAL_HEIGHT = 19; // hardcoded to fit all options

const levelToString = (level: number, defaultString: string) =>
  items.find((item) => item[0] === level)?.[1] ?? defaultString;
const stringToLevel = (itemString: string, defaultLevel: number) =>
  items.find((item) => item[1] === itemString)?.[0] ?? defaultLevel;

export const OccupationModal = (props: OccupationModalOptions) => {
  const { hasWikiLink, occupation, priorityLevel, required } = props;
  const { act } = useBackend();
  const modalContext = useContext(ModalContext);
  const { setOccupationModalOptions } = modalContext;
  const handleEscape = useCallback(
    () => setOccupationModalOptions(undefined),
    [setOccupationModalOptions],
  );
  const handleLevelSelected = useCallback((itemString: string) => {
    if (itemString === OPEN_WIKI_PAGE_STRING) {
      occupationActions.openJobWikiPage(act, occupation);
    } else {
      const selectedLevel = stringToLevel(itemString, priorityLevel);
      if (selectedLevel !== priorityLevel) {
        occupationActions.setJobPriorityLevel(
          act,
          occupation,
          priorityLevel,
          selectedLevel,
        );
      }
    }
    setOccupationModalOptions(undefined);
  }, []);
  const resolvedItems = useMemo(() => {
    const levelItems = (
      required
        ? items.filter(([level]) => level !== JobPriority.Unwanted)
        : items
    ).map(([_, itemString]) => itemString);
    return hasWikiLink ? [...levelItems, OPEN_WIKI_PAGE_STRING] : levelItems;
  }, [required]);
  const selectedItem = levelToString(priorityLevel, 'Unwanted');
  return (
    <Modal onEscape={handleEscape} height={MODAL_HEIGHT}>
      <ListInputModal
        items={resolvedItems}
        default_item={selectedItem}
        message={occupation}
        on_selected={handleLevelSelected}
        on_cancel={handleEscape}
        start_with_search={false}
        capitalize={false}
      />
    </Modal>
  );
};
