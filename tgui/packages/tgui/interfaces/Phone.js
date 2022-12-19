/**
 * @file
 * @copyright 2022
 * @author DisturbHerb (https://github.com/disturbherb)
 * @license MIT
 */

import { useBackend } from '../backend';
import { Button, Collapsible, Section } from '../components';
import { Window } from '../layouts';

export const Phone = (props, context) => {
  const { data } = useBackend(context);
  const { name } = data;
  return (
    <Window title={name} width={250} height={350}>
      <Window.Content>
        <Section title="Phonebook" fill scrollable>
          <AddressGroup category="bridge" name="Bridge" depColour="green" />
          <AddressGroup category="engineering" name="Engineering" depColour="yellow" />
          <AddressGroup category="medical" name="Medical" depColour="blue" />
          <AddressGroup category="research" name="Research" depColour="purple" />
          <AddressGroup category="security" name="Security" depColour="red" />
          <AddressGroup category="uncategorized" name="Uncategorized" depColour="brown" />
        </Section>
      </Window.Content>
    </Window>
  );
};

const AddressGroup = (props, context) => {
  const { act, data } = useBackend(context);
  const { category, name, depColour } = props;
  const { phonebook } = data;

  return (
    <Collapsible title={name} color={depColour}>
      {phonebook.map(
        (currentPhone) =>
          currentPhone.category === category && (
            <Button
              fluid
              content={currentPhone.id}
              key={currentPhone.id}
              onClick={() => act('call', { target: currentPhone.id })}
              textAlign="center"
            />
          )
      )}
    </Collapsible>
  );
};
