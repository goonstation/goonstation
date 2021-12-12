import { useBackend } from '../backend';
import { Button, Box, LabeledList, Section } from '../components';
import { Window } from '../layouts';



export const PhoneDefault = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    contactList, // a list of associative lists, where "id" = phone id, "name" = phone name
    phoneCallMembers, // we do this so getting an index is Easier
    pendingCallMembers, // since i cant fucking figure out how to make an object constructor in jsx
    callHost,
    phonecallID,
    elementSettings,
  } = data;

  const hangupButton = (
    <Button
      onClick={() => act("leaveCall")}
    >
      Hang up
    </Button>
  );

  return (
    <Window>
      <Window.Content scrollable>
        {!!elementSettings["hangupButton"] && (
          hangupButton
        )}
        <Section title="Contact List">
          <Box>
            {contactList.map((contact) => (
              <LabeledList label={contact["name"]} key={contact["id"]}>
                {
                  <Button
                    onClick={() => act("makeCall", { target: contact["id"] })}
                  >
                    {contact["name"]}
                  </Button>
                }
              </LabeledList>
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
