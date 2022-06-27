import { useBackend, useLocalState } from '../backend';
import { Button, Input, Section, Box, Stack, NumberInput } from '../components';
import { Window } from '../layouts';
import { KEY_ENTER } from 'common/keycodes';
import { capitalize } from '../../common/string';
import { ListSearch } from './common/ListSearch';

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

const ReagentSearch = (props, context) => {
  const { act } = useBackend(context);
  const { chemicals } = props;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const filteredReagents = (
    Object.keys(chemicals).filter(chemical => chemical.includes(searchText))
  );
  const handleSelectReagent = (reagent) => {
    act("set_reagent", { reagent_name: reagent, reagent_id: chemicals[reagent] });
    setSearchText('');
  };
  return (
    <ListSearch
      autoFocus
      currentSearch={searchText}
      options={filteredReagents}
      onSearch={setSearchText}
      onSelect={handleSelectReagent}
    />
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
  const [notesText, setNotesText] = useLocalState(context, 'notesText', '');
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
                <ReagentSearch chemicals={chemicals} />
              )}
              {!!selected_reagent && (
                <Button onClick={() => { act("set_reagent", { reagent: null }); }}>{capitalize(selected_reagent)}</Button>
              )}
              <NumberInput unit="u" minValue={5} step={5} maxValue={max_volume} value={volume} onChange={(e, value) => { act("set_volume", { volume: value }); }} />
            </Stack.Item>
            <Stack.Item>
              <Box align="left">Notes:</Box>
              <Input
                width="100%"
                value={notesText}
                onInput={(e, value) => { setNotesText(value.substring(0, 80)); }}
                onChange={(e, value) => { act("set_notes", { notes: value }); }} >{notes}
              </Input>
            </Stack.Item>
            <Stack.Item>
              <Button onClick={() => {
                act("submit");
                setNotesText('');
              }}
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
