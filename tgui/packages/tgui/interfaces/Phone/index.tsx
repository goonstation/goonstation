/**
 * @file
 * @copyright 2023
 * @author DisturbHerb (https://github.com/disturbherb)
 * @license MIT
 */

import {
  Button,
  Collapsible,
  Dimmer,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { capitalize } from '../common/stringUtils';
import { Phonebook, PhoneData } from './type';

const CategoryColors = [
  { department: 'bridge', color: 'green' },
  { department: 'engineering', color: 'yellow' },
  { department: 'medical', color: 'blue' },
  { department: 'research', color: 'purple' },
  { department: 'security', color: 'red' },
  { department: 'uncategorized', color: 'brown' },
];

const categorySort = (a, b) => a.category.localeCompare(b.category);
const idSort = (a, b) => a.id.localeCompare(b.id);

export const Phone = () => {
  const { data } = useBackend<PhoneData>();
  const { dialing, inCall, lastCalled, name } = data;
  const phonebook = data.phonebook.sort(categorySort) || [];

  return (
    <Window title={name} width={250} height={350}>
      <Window.Content>
        {(dialing || inCall) && (
          <Dimmer>
            <h1>LINE BUSY</h1>
          </Dimmer>
        )}
        <Stack vertical fill>
          <Stack.Item>
            <Section fill>
              <LabeledList>
                <LabeledList.Item label="Last Called">
                  {lastCalled ? `${lastCalled}` : `None`}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section title="Phonebook" fill scrollable>
              {phonebook.map((category) => (
                <AddressGroup key={category.category} phonebook={category} />
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type AddressGroupProps = {
  phonebook: Phonebook;
};

const AddressGroup = ({ phonebook }: AddressGroupProps) => {
  const { act } = useBackend<PhoneData>();
  const categoryName = capitalize(phonebook.category);
  const phones = phonebook.phones.sort(idSort);

  const getCategoryColor =
    CategoryColors[
      CategoryColors.findIndex(
        ({ department }) => department === phonebook.category,
      )
    ].color;

  return (
    <Collapsible
      title={categoryName}
      color={!!getCategoryColor && getCategoryColor}
    >
      {phones.map((currentPhone) => (
        <Button
          fluid
          key={currentPhone.id}
          onClick={() => act('call', { target: currentPhone.id })}
          textAlign="center"
          className="phone__button"
        >
          {currentPhone.id}
        </Button>
      ))}
    </Collapsible>
  );
};
