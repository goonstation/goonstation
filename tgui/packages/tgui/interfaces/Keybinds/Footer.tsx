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
  const { act } = useBackend<KeybindsData>();
  return (
    <>
      <Button onClick={() => act('confirm')} color="good" icon="save">
        Confirm
      </Button>
      <Button onClick={() => act('reset')} color="bad" icon="trash">
        Reset All Keybinding Data
      </Button>
      <Button onClick={() => act('cancel')}>Cancel</Button>
    </>
  );
};
