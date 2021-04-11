import { Fragment } from 'inferno';
import { useBackend } from '../../backend';
import { Box, Button, Divider, LabeledList, Section } from '../../components';
import { CharacterPreferencesData } from './type';

export const SavesTab = (_props, context) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);

  return (
    <Section title="Cloud Saves">
      {data.cloudSaves ? (
        <>
          {data.cloudSaves.map((name, index) => (
            <Fragment key={name}>
              <Cloudsave name={name} index={index} />
              <Divider />
            </Fragment>
          ))}
          <Box mt="5px">
            <Button onClick={() => act('cloud-new')}>Create new save</Button>
          </Box>
        </>
      ) : (
        <Box italic color="label">
          Cloud saves could not be loaded.
        </Box>
      )}
    </Section>
  );
};

type CloudSaveProps = {
  name: string,
  index: number
}

const Cloudsave = ({ name, index }: CloudSaveProps, context: any) => {
  const { act } = useBackend<CharacterPreferencesData>(context);

  return (
    <LabeledList>
      <LabeledList.Item
        label={`Cloud save ${index + 1}`}
        buttons={
          <>
            {/* Just a small gap between these so you dont accidentally hit one */}
            <Button onClick={() => act('cloud-load', { name })}>Load</Button> -{' '}
            <Button onClick={() => act('cloud-save', { name })}>Save</Button> -{' '}
            <Button.Confirm onClick={() => act('cloud-delete', { name })} content="Delete" />
          </>
        }>
        {name}
      </LabeledList.Item>
    </LabeledList>
  );
};
