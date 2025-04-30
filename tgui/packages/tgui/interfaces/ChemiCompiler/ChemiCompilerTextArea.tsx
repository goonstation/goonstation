/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { useEffect, useState } from 'react';
import { TextArea } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ChemiCompilerData } from './type';

export const ChemiCompilerTextArea = () => {
  const { act, data } = useBackend<ChemiCompilerData>();
  const { inputValue, loadTimestamp, theme } = data;

  const [localInputValue, setLocalInputValue] = useState(inputValue);

  // When loadTimestamp changes, it means a load button was clicked, so only then should we erase local input value with what was received from the server.
  useEffect(() => {
    setLocalInputValue(inputValue);
  }, [loadTimestamp]);

  return (
    <TextArea
      value={localInputValue}
      onInput={(value) => {
        setLocalInputValue(value);
        act('updateInputValue', { value });
      }}
      height="100%"
      fontFamily="Consolas, monospace"
      fontSize="13px"
      style={{
        wordBreak: 'break-all',
        borderColor: theme === 'syndicate' ? '#397439' : undefined,
      }}
    />
  );
};
