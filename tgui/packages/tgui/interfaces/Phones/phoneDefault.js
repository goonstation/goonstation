import { useBackend } from '../../backend';
import { Button, Box, LabeledList, Section } from '../../components';
import { Window } from '../../layouts';



export const phoneDefault = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    contactList, // this is a single object which we'll need to break down into a list of objects
    phoneCallMembers,
    pendingCallMembers,
    callHost,
    phonecallID,
  } = data;
  const formattedContactList = () => {
    const ContactFromID = (phoneID) => {
      this.contactID = phoneID;
      this.contactName = contactList.String(phoneID);
    };
    let phoneIDList = Object.keys(contactList);
    let formattedContactList = phoneIDList.map(contactFromID(currentValue));
    return formattedContactList;
  };


  /* function assembleContactList() {
    function createContact(phoneID, phoneName) {
      var contact = {
        contactID = phoneID,
        contactName = phoneName,
      }
      return contact;
    }

    var assembledContactList = {
      var contact = {};
      for(let phoneID in contactList) {
        contact.push(createContact(contactID, contactList[contactID]));
      };
    }

    return assembledContactList;

  }*/
  return (
    <Window>
      <Window.Content scrollable>
        <Section title="Contact List">
          <Box>
            {formatContactList().map((currentValue) => (
              <Button
                key={currentValue.contactID}
                content={currentValue.contactName}
                onClick={() => act('makeCall', currentValue.contactID)} />
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
