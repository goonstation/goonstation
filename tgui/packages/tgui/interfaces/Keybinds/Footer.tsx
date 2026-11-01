/**
 * @file
 * @copyright 2025
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */
import { Button } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { KeybindsData } from './types';

export const Footer = () => {
  const { act, data } = useBackend<KeybindsData>();
  const { hasChanges } = data;

  return (
    <>
      <Button
        onClick={() => act('confirm')}
        color={!hasChanges ? undefined : 'good'}
        icon="save"
      >
        Confirm
      </Button>
      <Button.Confirm
        onClick={() => act('reset')}
        color="bad"
        icon="trash"
        confirmContent="Confirm Reset All?"
      >
        Reset All
      </Button.Confirm>
      <Button onClick={() => act('cancel')}>Cancel</Button>
    </>
  );
};
