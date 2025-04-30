/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { Box, Button, Input, LabeledList } from 'tgui-core/components';

import { useBackend, useSharedState } from '../../../backend';
import { Modal } from '../../../components';
import type { GeneTekData } from '../type';

export const UnlockModal = () => {
  const { data, act } = useBackend<GeneTekData>();
  const [unlockCode, setUnlockCode] = useSharedState('unlockcode', '');
  const { autoDecryptors, unlock } = data;

  if (!unlock) {
    return;
  }

  return (
    <Modal full>
      <Box width={22} mr={2}>
        <LabeledList>
          <LabeledList.Item label="Detected Length">
            {unlock.length} characters
          </LabeledList.Item>
          <LabeledList.Item label="Possible Characters">
            {unlock.chars.join(' ')}
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Enter Unlock Code">
            <Input
              value={unlockCode}
              onChange={(code) => setUnlockCode(code.toUpperCase())}
            />
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Correct Characters">
            {unlock.correctChar} of {unlock.length}
          </LabeledList.Item>
          <LabeledList.Item label="Correct Positions">
            {unlock.correctPos} of {unlock.length}
          </LabeledList.Item>
          <LabeledList.Item label="Attempts Remaining">
            {unlock.tries} before mutation
          </LabeledList.Item>
        </LabeledList>
        <Box textAlign="right" mt={2}>
          <Button
            icon="magic"
            color="average"
            tooltip={'Auto-Decryptors Available: ' + autoDecryptors}
            disabled={autoDecryptors < 1}
            onClick={() => {
              setUnlockCode('');
              act('unlock', { code: 'UNLOCK' });
            }}
          >
            Use Auto-Decryptor
          </Button>
        </Box>
        <Box textAlign="right" mt={1}>
          <Button
            mr={1}
            icon="check"
            color="good"
            tooltip={
              unlockCode.length !== unlock.length
                ? 'Code is the wrong length.'
                : unlockCode
                      .split('')
                      .some((c) => unlock.chars.indexOf(c) === -1)
                  ? 'Invalid character in code.'
                  : ''
            }
            disabled={
              unlockCode.length !== unlock.length ||
              unlockCode.split('').some((c) => unlock.chars.indexOf(c) === -1)
            }
            onClick={() => {
              setUnlockCode('');
              act('unlock', { code: unlockCode });
            }}
          >
            Attempt Decryption
          </Button>
          <Button
            icon="times"
            color="bad"
            onClick={() => {
              setUnlockCode('');
              act('unlock', { code: null });
            }}
          >
            Cancel
          </Button>
        </Box>
      </Box>
    </Modal>
  );
};
