/**
 * @file
 * @copyright 2022
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */

import { capitalize } from 'common/string';
import { useState } from 'react';
import {
  Button,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { IDCard } from './common/IDCard';
import { ListSearch } from './common/ListSearch';

interface ChemRequesterData {
  chemicals;
  card;
  selected_reagent;
  volume;
  max_volume;
  notes;
  silicon_user;
}

const ReagentSearch = (props) => {
  const { act } = useBackend();
  const { chemicals } = props;
  const [searchText, setSearchText] = useState('');
  const filteredReagents = Object.keys(chemicals).filter((chemical) =>
    chemical.includes(searchText),
  );
  const handleSelectReagent = (reagent) => {
    act('set_reagent', {
      reagent_name: reagent,
      reagent_id: chemicals[reagent],
    });
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

export const ChemRequester = () => {
  const { act, data } = useBackend<ChemRequesterData>();
  const {
    chemicals,
    card,
    selected_reagent,
    volume,
    max_volume,
    notes,
    silicon_user,
  } = data;
  return (
    <Window title="Chemical Request" width={400} height={600}>
      <Window.Content align="center">
        {!!card && (
          <Stack vertical>
            <Stack.Item>
              <IDCard
                card={card}
                onEject={() => {
                  act('reset_id');
                }}
              />
            </Stack.Item>
            <Stack.Item>
              {!selected_reagent && (
                <Section height={36} fill scrollable>
                  <ReagentSearch chemicals={chemicals} />
                </Section>
              )}
              {!!selected_reagent && (
                <Button
                  onClick={() => {
                    act('set_reagent', { reagent: null });
                  }}
                >
                  {capitalize(selected_reagent)}
                </Button>
              )}
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Amount">
                  <NumberInput
                    unit="u"
                    minValue={5}
                    step={5}
                    maxValue={max_volume}
                    value={volume}
                    onChange={(value) => {
                      act('set_volume', { volume: value });
                    }}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Notes">
                  <Input
                    width="100%"
                    value={notes}
                    maxLength={65}
                    onChange={(e, value) => {
                      act('set_notes', { notes: value });
                    }}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <Button
                onClick={() => {
                  act('submit');
                  act('set_notes', { notes: '' });
                }}
              >
                Submit request
              </Button>
            </Stack.Item>
          </Stack>
        )}
        {!card && !silicon_user && (
          <Section>Please swipe ID to place request.</Section>
        )}
        {!card && !!silicon_user && (
          <Section>
            <Button onClick={() => act('silicon_login')}>
              Login to place request.
            </Button>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
