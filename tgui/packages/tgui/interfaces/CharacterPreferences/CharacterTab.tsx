/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { Box, Button, Image, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ColorButton } from '../../components';
import { CharacterPreferencesData } from './type';

const CustomDetail = ({ id, color, style }) => {
  const { act } = useBackend<CharacterPreferencesData>();

  return (
    <>
      <ColorButton
        color={color}
        onClick={() => act('update-detail-color', { id })}
      />
      <Button
        icon="chevron-left"
        onClick={() => act('update-detail-style-cycle', { id, direction: -1 })}
      />
      <Button
        icon="chevron-right"
        onClick={() => act('update-detail-style-cycle', { id, direction: 1 })}
      />
      <Button onClick={() => act('update-detail-style', { id })}>
        {style}
      </Button>
    </>
  );
};

interface CustomPartProps {
  slot_id: string;
}

const CustomPart = ({ slot_id }: CustomPartProps) => {
  const { act, data } = useBackend<CharacterPreferencesData>();
  return (
    <Button
      onClick={() => act('pick_part', { slot_id })}
      tooltip={data.partsData[slot_id]?.name ?? 'Not Selected'}
    >
      {data.partsData[slot_id]?.img ? (
        <Image
          width="64px"
          height="64px"
          src={`data:image/png;base64,${data.partsData[slot_id]?.img}`}
          backgroundColor="transparent"
        />
      ) : (
        'Not Selected'
      )}
    </Button>
  );
};

export const CharacterTab = () => {
  const { act, data } = useBackend<CharacterPreferencesData>();

  return (
    <>
      <Section
        title="Appearance"
        buttons={
          <Button.Checkbox
            checked={data.randomAppearance}
            onClick={() => act('update-randomAppearance')}
          >
            Random appearance
          </Button.Checkbox>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Skin Tone">
            <ColorButton
              color={data.skinTone}
              onClick={() => act('update-skinTone')}
            />
            <Button
              icon="angle-double-left"
              onClick={() => act('decrease-skinTone', { alot: 1 })}
            />
            <Button
              icon="chevron-left"
              onClick={() => act('decrease-skinTone')}
            />
            <Button
              icon="chevron-right"
              onClick={() => act('increase-skinTone')}
            />
            <Button
              icon="angle-double-right"
              onClick={() => act('increase-skinTone', { alot: 1 })}
            />
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Eye Color">
            <ColorButton
              color={data.eyeColor}
              onClick={() => act('update-eyeColor')}
            />
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Top Detail">
            <CustomDetail
              id="custom3"
              color={data.customColor3}
              style={data.customStyle3}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Middle Detail">
            <CustomDetail
              id="custom2"
              color={data.customColor2}
              style={data.customStyle2}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Bottom Detail">
            <CustomDetail
              id="custom1"
              color={data.customColor1}
              style={data.customStyle1}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Special Style">
            <Button onClick={() => act('update-specialStyle')}>
              {data.specialStyle || 'default'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Underwear">
            <CustomDetail
              id="underwear"
              color={data.underwearColor}
              style={data.underwearStyle}
            />
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Bionics">
            <CustomPart slot_id="r_arm" />
            <CustomPart slot_id="l_arm" />
            <CustomPart slot_id="r_leg" />
            <CustomPart slot_id="l_leg" />
            <Box>
              {'Trait points: '}
              <Box
                as="span"
                color={data.traitsPointsTotal > 0 ? 'good' : 'bad'}
              >
                {data.traitsPointsTotal}
              </Box>
            </Box>
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Organs">
            <CustomPart slot_id="right_eye" />
            <CustomPart slot_id="left_eye" />
            <Box>
              {'Trait points: '}
              <Box
                as="span"
                color={data.traitsPointsTotal > 0 ? 'good' : 'bad'}
              >
                {data.traitsPointsTotal}
              </Box>
            </Box>
          </LabeledList.Item>
          <LabeledList.Divider />
        </LabeledList>
      </Section>
      <Section title="Sounds">
        <LabeledList>
          <LabeledList.Item label="Fart">
            <Button onClick={() => act('update-fartsound')}>
              {data.fartsound}
            </Button>
            <Button
              icon="volume-up"
              onClick={() => act('previewSound', { fartsound: 1 })}
            >
              Preview
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Scream">
            <Button onClick={() => act('update-screamsound')}>
              {data.screamsound}
            </Button>
            <Button
              icon="volume-up"
              onClick={() => act('previewSound', { screamsound: 1 })}
            >
              Preview
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Chat">
            <Button onClick={() => act('update-chatsound')}>
              {data.chatsound}
            </Button>
            <Button
              icon="volume-up"
              onClick={() => act('previewSound', { chatsound: 1 })}
            >
              Preview
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </>
  );
};
