/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Button, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type {
  NanoFabricatorData,
  NanoPartOptionData,
  NanoSelectedPartData,
  NanoSelectingPartData,
  NanoStorageData,
} from '../type';
import { MaterialOption } from './MaterialOption';

// Ignore stack amounts when sorting stored material names.
const MATERIAL_NAME_PREFIX_REGEX = /^\d+\s+/;
const MATERIAL_BUTTON_WIDTH = 15;

type MaterialOptionData = NanoPartOptionData | NanoStorageData;

interface MaterialStorageProps {
  partOptions: NanoPartOptionData[];
  selectedPart: NanoSelectedPartData | undefined;
  selectingPart: NanoSelectingPartData | null;
  storage: NanoStorageData[];
}

const getSortableMaterialName = (name: string) =>
  name.replace(MATERIAL_NAME_PREFIX_REGEX, '').trim().toLowerCase();

const sortMaterialOptions = (a: MaterialOptionData, b: MaterialOptionData) =>
  getSortableMaterialName(a.name).localeCompare(
    getSortableMaterialName(b.name),
  );

export const MaterialStorage = (props: MaterialStorageProps) => {
  const { act } = useBackend<NanoFabricatorData>();
  const { partOptions, selectedPart, selectingPart, storage } = props;
  const sortedPartOptions = [...partOptions].sort(sortMaterialOptions);
  const sortedStorage = [...storage].sort(sortMaterialOptions);
  const materialOptions = selectingPart ? sortedPartOptions : sortedStorage;

  const materialSection = (
    <Section
      m={0}
      title={
        selectingPart
          ? `Choose ${selectingPart.part_name || selectingPart.name}`
          : 'Storage'
      }
      buttons={
        selectingPart ? (
          <Stack>
            <Stack.Item>
              <Button
                icon="eraser"
                color="bad"
                disabled={!selectedPart?.assigned}
                onClick={() => act('clear_part')}
              >
                Clear
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button icon="times" onClick={() => act('cancel_part')}>
                Close
              </Button>
            </Stack.Item>
          </Stack>
        ) : undefined
      }
    >
      {materialOptions.length ? (
        <Stack wrap="wrap">
          {materialOptions.map((option) => {
            return (
              <Stack.Item key={option.ref} width={MATERIAL_BUTTON_WIDTH}>
                <MaterialOption
                  onChoose={
                    selectingPart
                      ? () => act('choose_part', { ref: option.ref })
                      : undefined
                  }
                  onEject={() => act('eject', { ref: option.ref })}
                  option={option}
                  selectingPart={!!selectingPart}
                />
              </Stack.Item>
            );
          })}
        </Stack>
      ) : (
        <NoticeBox>
          {selectingPart
            ? 'No valid components are available for this slot.'
            : 'No objects found in storage.'}
        </NoticeBox>
      )}
    </Section>
  );

  return materialSection;
};
