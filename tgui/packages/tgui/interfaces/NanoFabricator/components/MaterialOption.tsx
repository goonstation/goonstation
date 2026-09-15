/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Box, Button, Image, Stack } from 'tgui-core/components';

import type { NanoPartOptionData, NanoStorageData } from '../type';

type MaterialOptionData = NanoPartOptionData | NanoStorageData;

const MATERIAL_OPTION_LINE_HEIGHT = '20px';

const isPartOption = (
  option: MaterialOptionData,
): option is NanoPartOptionData => 'insufficient' in option;

interface MaterialOptionProps {
  onChoose?: () => void;
  onEject: () => void;
  option: MaterialOptionData;
  selectingPart: boolean;
}

const MaterialOptionContent = (props: { option: MaterialOptionData }) => {
  const { option } = props;

  return (
    <Stack align="center" lineHeight={MATERIAL_OPTION_LINE_HEIGHT}>
      {option.img && (
        <Stack.Item>
          <Image src={option.img} />
        </Stack.Item>
      )}
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
};

export const MaterialOption = (props: MaterialOptionProps) => {
  const { onChoose, onEject, option, selectingPart } = props;
  const insufficient = isPartOption(option) && !!option.insufficient;

  return (
    <Stack width="100%">
      <Stack.Item grow minWidth="0px">
        {selectingPart ? (
          <Button fluid disabled={insufficient} onClick={onChoose}>
            <MaterialOptionContent option={option} />
          </Button>
        ) : (
          <Box width="100%" px={1}>
            <MaterialOptionContent option={option} />
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
