/**
 * @file
 * @copyright 2022
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */

import { useBackend, useLocalState } from '../backend';
import { Button, Input, Section, Stack, NumberInput, LabeledList } from '../components';
import { Window } from '../layouts';
import { capitalize } from '../../common/string';
import { ListSearch } from './common/ListSearch';
import { IDCard } from './common/IDCard';

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
    silicon_user,
  } = data;
  const [notesText, setNotesText] = useLocalState(context, 'notesText', '');
  return (
    <Window title="Chemical request" width={400} height={600}>
      <Window.Content align="center">
        {!!card && (
          <Stack vertical>
            <Stack.Item>
              <IDCard card={card} onEject={() => { act("reset_id"); }} />
            </Stack.Item>
            <Stack.Item>
              {!selected_reagent && (
                <Section height={36} fill scrollable>
                  <ReagentSearch chemicals={chemicals} />
                </Section>
              )}
              {!!selected_reagent && (
                <Button onClick={() => { act("set_reagent", { reagent: null }); }}>{capitalize(selected_reagent)}</Button>
              )}
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Amount">
                  <NumberInput align="left" unit="u" minValue={5} step={5} maxValue={max_volume} value={volume} onChange={(e, value) => { act("set_volume", { volume: value }); }} />
                </LabeledList.Item>
                <LabeledList.Item label="Notes">
                  <Input
                    width="100%"
                    value={notesText}
                    maxLength={65}
                    onInput={setNotesText}
                    onChange={(e, value) => { act("set_notes", { notes: value }); }} >{notes}
                  </Input>
                </LabeledList.Item>
              </LabeledList>
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
        {!card && !silicon_user && <Section>Please swipe ID to place request.</Section>}
        {!card && !!silicon_user && (
          <Section>
            <Button onClick={() => act("silicon_login")}>Login to place request.</Button>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
