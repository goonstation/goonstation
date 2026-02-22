/**
 * @file
 * @copyright 2025
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { useCallback, useContext } from 'react';
import { Modal } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { ListInputModal } from '../../ListInputWindow/ListInputModal';
import * as jobActions from '../actions';
import { type JobModalOptions } from '../type';
import { ModalContext } from './ModalContext';

const JOIN_AS_JOB_STRING = 'Join As This Job';
const OPEN_WIKI_PAGE_STRING = 'Open Wiki Page';
const MODAL_HEIGHT = 14;

export const JobModal = (props: JobModalOptions) => {
  const { job_name, has_wiki_link, job_ref, silicon_latejoin } = props;
  const { act } = useBackend();
  const modalContext = useContext(ModalContext);
  const { setJobModalOptions } = modalContext;

  const handleLevelSelected = useCallback((option: string) => {
    switch (option) {
      case JOIN_AS_JOB_STRING: {
        jobActions.joinAsJob(act, job_ref, silicon_latejoin);
        break;
      }
      case OPEN_WIKI_PAGE_STRING: {
        jobActions.openJobWikiPage(act, job_ref);
        break;
      }
    }

    setJobModalOptions(undefined);
  }, []);

  const handleEscape = useCallback(
    () => setJobModalOptions(undefined),
    [setJobModalOptions],
  );

  return (
    <Modal onEscape={handleEscape} height={MODAL_HEIGHT}>
      <ListInputModal
        items={
          has_wiki_link
            ? [JOIN_AS_JOB_STRING, OPEN_WIKI_PAGE_STRING]
            : [JOIN_AS_JOB_STRING]
        }
        default_item={JOIN_AS_JOB_STRING}
        message={job_name}
        on_selected={handleLevelSelected}
        on_cancel={handleEscape}
        start_with_search={false}
        capitalize={false}
      />
    </Modal>
  );
};
