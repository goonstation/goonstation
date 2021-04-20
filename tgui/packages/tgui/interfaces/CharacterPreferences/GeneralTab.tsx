import { decodeHtmlEntities } from 'common/string';
import { useBackend } from '../../backend';
import { BlockQuote, Box, Button, LabeledList, Section } from '../../components';
import { CharacterPreferencesData } from './type';

export const GeneralTab = (_props, context) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);

  return (
    <>
      <Section title="Records">
        <LabeledList>
          <LabeledList.Item
            label="Name"
            buttons={
              <Button.Checkbox checked={data.randomName} onClick={() => act('update-randomName')}>
                Random
              </Button.Checkbox>
            }>
            <Button onClick={() => act('update-nameFirst')}>{data.nameFirst}</Button>
            <Button onClick={() => act('update-nameMiddle')}>{data.nameMiddle}</Button>
            <Button onClick={() => act('update-nameLast')}>{data.nameLast}</Button>
          </LabeledList.Item>
          <LabeledList.Item label="Gender">
            <Button onClick={() => act('update-gender')}>{data.gender}</Button>
          </LabeledList.Item>
          <LabeledList.Item label="Age">
            <Button onClick={() => act('update-age')}>{data.age}</Button>
          </LabeledList.Item>
          <LabeledList.Item label="Blood Type">
            <Button onClick={() => act('update-bloodType')}>
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
              <Button.Checkbox checked={!data.pin} onClick={() => act('update-pin', { random: !!data.pin })}>
                Random
              </Button.Checkbox>
            }>
            <Button onClick={() => act('update-pin')}>
              {data.pin ?? (
                <Box as="span" italic>
                  Random
                </Box>
              )}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item
            label="Flavor Text"
            buttons={
              <Button onClick={() => act('update-flavorText')} icon="wrench">
                Edit
              </Button>
            }>
            <BlockQuote>{data.flavorText ? decodeHtmlEntities(data.flavorText) : <Box italic>None</Box>}</BlockQuote>
          </LabeledList.Item>
          <LabeledList.Item
            label="Security Note"
            buttons={
              <Button onClick={() => act('update-securityNote')} icon="wrench">
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
              <Button onClick={() => act('update-medicalNote')} icon="wrench">
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
            <Button onClick={() => act('update-pdaRingtone')}>{data.pdaRingtone}</Button>
            <Button onClick={() => act('previewSound', { pdaRingtone: 1 })} icon="volume-up">
              Preview
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Background Color">
            <Button.Color color={data.pdaColor} onClick={() => act('update-pdaColor')} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </>
  );
};
