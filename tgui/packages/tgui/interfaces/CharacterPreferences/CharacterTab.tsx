import { Fragment } from 'inferno';
import { useBackend } from '../../backend';
import { Box, Button, ColorBox, LabeledList, Section } from '../../components';
import { CharacterPreferencesData } from './type';

const CustomDetail = ({ id, color, style }, context) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);

  return (
    <Fragment>
      <Button onClick={() => act('update', { detail: 1, id, color: 1 })}>
        <ColorBox color={color} mr="5px" />
        <Box as="code">{color}</Box>
      </Button>
      <Button icon="chevron-left" onClick={() => act('update', { detail: 1, id, previousStyle: 1 })} />
      <Button onClick={() => act('update', { detail: 1, id, nextStyle: 1 })} icon="chevron-right" />
      <Button onClick={() => act('update', { detail: 1, id, style: 1 })}>{style}</Button>
    </Fragment>
  );
};

export const CharacterTab = (_props, context) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);

  return (
    <Fragment>
      <Section title="Appearance">
        <LabeledList>
          <LabeledList.Item label="Skin Tone">
            <Button onClick={() => act('update', { skinTone: 1 })}>
              <ColorBox color={data.skinTone} mr="5px" />
              <Box as="code">{data.skinTone}</Box>
            </Button>
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Eye Color">
            <Button onClick={() => act('update', { eyeColor: 1 })}>
              <ColorBox color={data.eyeColor} mr="5px" />
              <Box as="code">{data.eyeColor}</Box>
            </Button>
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Top Detail">
            <CustomDetail id="custom3" color={data.customColor3} style={data.customStyle3} />
          </LabeledList.Item>
          <LabeledList.Item label="Middle Detail">
            <CustomDetail id="custom2" color={data.customColor2} style={data.customStyle2} />
          </LabeledList.Item>
          <LabeledList.Item label="Bottom Detail">
            <CustomDetail id="custom1" color={data.customColor1} style={data.customStyle1} />
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Underwear">
            <CustomDetail id="underwear" color={data.underwearColor} style={data.underwearStyle} />
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Randomization">
            <Button.Checkbox checked={data.randomAppearance}>Always use a randomized appearance</Button.Checkbox>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Sounds">
        <LabeledList>
          <LabeledList.Item label="Fart">
            <Button onClick={() => act('update', { fartsound: 1 })}>{data.fartsound}</Button>
            <Button icon="volume-up" onClick={() => act('previewSound', { fartsound: 1 })}>
              Preview
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Scream">
            <Button onClick={() => act('update', { screamsound: 1 })}>{data.screamsound}</Button>
            <Button icon="volume-up" onClick={() => act('previewSound', { screamsound: 1 })}>
              Preview
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Chat">
            <Button onClick={() => act('update', { chatsound: 1 })}>{data.chatsound}</Button>
            <Button icon="volume-up" onClick={() => act('previewSound', { chatsound: 1 })}>
              Preview
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};
