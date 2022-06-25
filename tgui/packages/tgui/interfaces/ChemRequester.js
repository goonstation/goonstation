import { useBackend } from '../backend';
import { Button, Input, Section, Box, Stack, NumberInput } from '../components';
import { Window } from '../layouts';
import { KEY_ENTER } from 'common/keycodes';
import { capitalize } from '../../common/string';

const IDCard = (props, context) => {
  if (!props.card) {
    return;
  }
  const { act } = useBackend(context);
  const {
    card,
  } = props;
  return (
    <Button
      icon="eject"
      content={card.name + ` (${card.role})`}
      tooltip="Clear scanned card"
      tooltipPosition="bottom-end"
      onClick={() => { act("reset_id"); }}
    />
  );
};

const AutocompleteInput = (props, context) => {
  const {
    words,
    onChosen,
  } = props;
  return (
    <>
      <Input
        onInput={(e, typedValue) => {
          // hide/unhide words based on whether they match our search term
          let children = document.getElementById("autocomplete").children;
          for (let i = 0; i < children.length; i++) {
            children[i].hidden = !(words[i].includes(typedValue));
          }
          // on hitting enter we pick the first matching word
          if (e.keyCode === KEY_ENTER) {
            for (let i = 0; i < children.length; i++) {
              if (!children[i].hidden) {
                onChosen(words[i]);
                return;
              }
            }
          }
        }}
      />
      <Section>
        <Stack vertical id="autocomplete">
          {words.map((word) => {
            return (
              <Stack.Item key={word} grow>
                <Button width={25} onClick={() => { onChosen(word); }}>{capitalize(word)}</Button>
              </Stack.Item>
            );
          })}
        </Stack>
      </Section>
    </>
  );
};

export const ChemRequester = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    chemicals,
    card,
    selected_reagent,
    volume,
    max_volume,
    notes,
  } = data;
  return (
    <Window title="Chemical request" width={400} height={600}>
      <Window.Content align="center">
        {!!card && (
          <Stack vertical>
            <Stack.Item>
              <IDCard card={card} />
            </Stack.Item>
            <Stack.Item height="50%">
              {!selected_reagent && (
                <AutocompleteInput words={Object.keys(chemicals)} onChosen={(reagent) => act("set_reagent", { reagent_name: reagent, reagent_id: chemicals[reagent] })} />
              )}
              {!!selected_reagent && (
                <Button onClick={() => { act("set_reagent", { reagent: null }); }}>{capitalize(selected_reagent)}</Button>
              )}
              <NumberInput unit="u" minValue={5} step={5} maxValue={max_volume} value={volume} onChange={(e, value) => { act("set_volume", { volume: value }); }} />
            </Stack.Item>
            <Stack.Item>
              <Box align="left">Notes:</Box>
              <Input width="100%" id="notes" onChange={(e, value) => { act("set_notes", { notes: value }); }} >{notes}</Input>
            </Stack.Item>
            <Stack.Item>
              <Button onClick={() => { act("submit"); }}
              >
                Submit request
              </Button>
            </Stack.Item>
          </Stack>
        )}
        {!card && <Section>Please swipe ID to place request.</Section>}
      </Window.Content>
    </Window>
  );
};
