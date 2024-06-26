/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { ChemiCompilerData } from './type';
import { TextArea } from '../../components';

export const ChemiCompilerTextArea = (_props, context) => {
  const { act, data } = useBackend<ChemiCompilerData>(context);
  const { inputValue, loadTimestamp, theme } = data;
  return (
    <TextArea
      value={inputValue}
      onInput={(_event, value) => act('updateInputValue', { value })}
      height="100%"
      // The load button would break if we pressed it between the input's act and the next refresh.
      // This ensures a refresh after every load button click
      key={loadTimestamp}
      fontFamily="Consolas, monospace"
      fontSize="13px"
      style={{ "word-break": "break-all", "border-color": (theme === "syndicate" ? "#397439" : null) }}
    />
  );
};
