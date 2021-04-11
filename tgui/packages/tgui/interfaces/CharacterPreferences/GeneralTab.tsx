import { Fragment } from 'inferno';
import { decodeHtmlEntities } from 'common/string';
import { useBackend } from '../../backend';
import { BlockQuote, Box, Button, ColorBox, LabeledList, Section } from '../../components';
import { CharacterPreferencesData } from './type';

export const GeneralTab = (_props, context) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);

  return (
    <Fragment>
      <Section title="Records">
        <LabeledList>
          <LabeledList.Item
            label="Name"
            buttons={
              <Button.Checkbox checked={data.randomName} onClick={() => act('update', { randomName: 1 })}>
                Random
              </Button.Checkbox>
            }>
            <Button onClick={() => act('update', { nameFirst: 1 })}>{data.nameFirst}</Button>
            <Button onClick={() => act('update', { nameMiddle: 1 })}>{data.nameMiddle}</Button>
            <Button onClick={() => act('update', { nameLast: 1 })}>{data.nameLast}</Button>
          </LabeledList.Item>
          <LabeledList.Item label="Gender">
            <Button onClick={() => act('update', { gender: 1 })}>{data.gender}</Button>
          </LabeledList.Item>
          <LabeledList.Item label="Age">
            <Button onClick={() => act('update', { age: 1 })}>{data.age}</Button>
          </LabeledList.Item>
          <LabeledList.Item label="Blood Type">
            <Button onClick={() => act('update', { bloodType: 1 })}>
              {data.bloodRandom ? (
                <Box as="span" italic>
                  Random
                </Box>
              ) : (
                data.bloodType
              )}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item
            label="Bank PIN"
            buttons={
              <Button.Checkbox checked={!data.pin} onClick={() => act('update', { pin: data.pin ? 'random' : 1 })}>
                Random
              </Button.Checkbox>
            }>
            <Button onClick={() => act('update', { pin: 1 })}>
              {data.pin ? (
                data.pin
              ) : (
                <Box as="span" italic>
                  Random
                </Box>
              )}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item
            label="Flavor Text"
            buttons={
              <Button onClick={() => act('update', { flavorText: 1 })} icon="wrench">
                Edit
              </Button>
            }>
            <BlockQuote>{data.flavorText ? decodeHtmlEntities(data.flavorText) : <Box italic>None</Box>}</BlockQuote>
          </LabeledList.Item>
          <LabeledList.Item
            label="Security Note"
            buttons={
              <Button onClick={() => act('update', { securityNote: 1 })} icon="wrench">
                Edit
              </Button>
            }>
            <BlockQuote>
              {data.securityNote ? decodeHtmlEntities(data.securityNote) : <Box italic>None</Box>}
            </BlockQuote>
          </LabeledList.Item>
          <LabeledList.Item
            label="Medical Note"
            buttons={
              <Button onClick={() => act('update', { medicalNote: 1 })} icon="wrench">
                Edit
              </Button>
            }>
            <BlockQuote>{data.medicalNote ? decodeHtmlEntities(data.medicalNote) : <Box italic>None</Box>}</BlockQuote>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="PDA">
        <LabeledList>
          <LabeledList.Item label="Ringtone">
            <Button onClick={() => act('update', { pdaRingtone: 1 })}>{data.pdaRingtone}</Button>
            <Button onClick={() => act('previewSound', { pdaRingtone: 1 })} icon="volume-up">
              Preview
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Background Color">
            <Button onClick={() => act('update', { pdaColor: 1 })}>
              <ColorBox color={data.pdaColor} mr="5px" />
              <Box as="code">{data.pdaColor}</Box>
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};
