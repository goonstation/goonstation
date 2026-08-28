/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Box, Button, Image, Stack } from 'tgui-core/components';

import type { NanoPartOptionData, NanoStorageData } from '../type';

type MaterialOptionData = NanoPartOptionData | NanoStorageData;

interface MaterialOptionProps {
  onChoose?: () => void;
  onEject: () => void;
  option: MaterialOptionData;
  selectingPart: boolean;
}

export const MaterialOption = (props: MaterialOptionProps) => {
  const { onChoose, onEject, option, selectingPart } = props;
  const insufficient = 'insufficient' in option && !!option.insufficient;
  const materialContent = (
    <Stack align="center">
      <Stack.Item>{option.img && <Image src={option.img} />}</Stack.Item>
      <Stack.Item grow minWidth="0px" overflow="hidden">
        <Box
          width="100%"
          nowrap
          overflow="hidden"
          style={{ textOverflow: 'ellipsis' }}
        >
          {option.name}
        </Box>
        <Box italic>{option.amount} available</Box>
      </Stack.Item>
    </Stack>
  );

  return (
    <Stack width="100%" g={0.5}>
      <Stack.Item grow minWidth="0px">
        {selectingPart ? (
          <Button fluid disabled={insufficient} onClick={onChoose}>
            {materialContent}
          </Button>
        ) : (
          <Box width="100%" px={1} lineHeight="var(--button-height)">
            {materialContent}
          </Box>
        )}
      </Stack.Item>
      {!selectingPart && (
        <Stack.Item>
          <Button
            height="100%"
            verticalAlignContent="middle"
            icon="eject"
            tooltip="Eject"
            onClick={onEject}
          />
        </Stack.Item>
      )}
    </Stack>
  );
};
