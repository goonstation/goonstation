import { useBackend } from '../backend';
import { Button, Collapsible } from '../components';
import { Window } from '../layouts';

export const Phone = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      title="Phonebook"
      width={250}
      height={500}
    >
      <Window.Content scrollable>
        <AddressGroup department="Civilian" depColour="brown" />
        <AddressGroup department="Command" depColour="green" />
        <AddressGroup department="Engineering" depColour="orange" />
        <AddressGroup department="Medical" depColour="blue" />
        <AddressGroup department="Research" depColour="purple" />
        <AddressGroup department="Security" depColour="red" />
        <AddressGroup department="Uncategorized" depColour="grey" />
      </Window.Content>
    </Window>
  );
};

const AddressGroup = (props, context) => {
  const {
    department,
    depColour,
  } = props;
  return (
    <Collapsible
      title={department}
      color={depColour}
    >
      <Button fluid content="Bridge" color="green" />
      <Button fluid content="Captain's Office" color="green" />
      <Button fluid content="Chief Engineer's Office" color="green" />
      <Button fluid content="Customs" color="green" />
      <Button fluid content="HoP's Office" color="green" />
      <Button fluid content="HoS Office" color="green" />
      <Button fluid content="Medical Director's Office" color="green" />
      <Button fluid content="Research Director's Office" color="green" />
    </Collapsible>
  );
};
