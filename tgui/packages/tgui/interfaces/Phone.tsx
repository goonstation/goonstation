/**
 * @file
 * @copyright 2023
 * @author DisturbHerb (https://github.com/disturbherb)
 * @license MIT
 */

import { useBackend } from '../backend';
import { Button, Collapsible, Dimmer, LabeledList, Section, Stack } from '../components';
import { capitalize } from './common/stringUtils';
import { Window } from '../layouts';

export interface PhoneData {
  dialing: boolean;
  inCall: boolean;
  lastCaller: string;
  name: string;
  phonebook: Phonebook[];
}

export interface Phonebook {
  category: string;
  color: string;
  phones: PhoneID[];
}

export interface PhoneID {
  id: string;
}

export const Phone = (props, context) => {
  const { data } = useBackend<PhoneData>(context);
  const { dialing, inCall, lastCaller, name } = data;
  const phonebook = data.phonebook || [];

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
                <LabeledList.Item label="Last Caller">{lastCaller ? `${lastCaller}` : `None`}</LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section title="Phonebook" fill scrollable>
              {phonebook.map((category) => (
                <AddressGroup
                  key={category.category}
                  category={category} />
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const AddressGroup = (props, context) => {
  const { act } = useBackend(context);
  const { category } = props;
  const categoryName = capitalize(category.category);
  const phones = category.phones;

  return (
    <Collapsible title={categoryName} color={category.color}>
      {phones.map((currentPhone) => (
        <Button
          fluid
          content={currentPhone.id}
          key={currentPhone.id}
          onClick={() => act('call', { target: currentPhone.id })}
          textAlign="center"
          className="phone__button"
        />
      ))}
    </Collapsible>
  );
};
