import { useBackend } from '../../backend';
import { Button, Box, LabeledList, Section } from '../../components';
import { Window } from '../../layouts';



export const PhoneDefault = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    contactList, // this is a single object which we'll need to break down into a list of objects
    phoneCallMembers,
    pendingCallMembers,
    callHost,
    phonecallID,
  } = data;
  /*
  const formattedContactList = () => {
    const ContactFromID = (phoneID) => {
      contactID = phoneID;
      contactName = contactList.String(phoneID);
    };
    let phoneIDList = Object.keys(contactList);
    let formattedContactList = phoneIDList.map(contactFromID(currentValue));
    return formattedContactList;
  };
*/
  return (
    <Window>
      <Window.Content scrollable>
        test
      </Window.Content>
    </Window>
  );
};
