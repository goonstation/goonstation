/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */
import { Button } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { KeybindsData } from './types';

export const Footer = () => {
  const { act, data } = useBackend<KeybindsData>();
  const { hasChanges, resetting } = data;

  return (
    <>
      <Button
        onClick={() => act('confirm')}
        color={!hasChanges ? null : 'good'}
        icon="save"
      >
        Confirm
      </Button>
      <Button
        onClick={() => act('reset')}
        color={!resetting ? null : 'bad'}
        icon="trash"
      >
        {!resetting ? 'Reset All' : 'Confirm?'}
      </Button>
      <Button onClick={() => act('cancel')}>Cancel</Button>
    </>
  );
};
