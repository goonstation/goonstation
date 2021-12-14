import { useBackend } from '../backend';
import { Button, Box, LabeledList, Section, Flex, Stack } from '../components';
import { Window } from '../layouts';

String.spliceSlice = (str, index, count, add) => { // god bless stack overflow
  // We cannot pass negative indexes directly to the 2nd slicing operation.
  if (index < 0) {
    index = str.length + index;
    if (index < 0) {
      index = 0;
    }
  }

  return str.slice(0, index) + (add || "") + str.slice(index + count);
};

const formattedDialledNumber = (number) => {
  // We wanna render in format of xxx-xxxx(xxxxx...
  // We then slice it down to the last 9 digits for us to render
  let toReturn;

  toReturn = String.spliceSlice(number, 3, 0, "-");
  toReturn = String.spliceSlice(toReturn, 8, 0, "(");
  toReturn = toReturn.slice(-9);

  return toReturn;

};

export const PhoneDefault = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    contactList, // a list of associative lists, where "phoneNumber" = phone number, "name" = phone name
    phoneCallMembers, // we do this so getting an index is Easier
    pendingCallMembers, // since i cant fucking figure out how to make an object constructor in jsx
    callHost,
    phonecallID,
    elementSettings,
    dialledNumber,
  } = data;


  const onDial = (text) => {
    act("dialpad", { text });
  };

  const hangupButton = (
    <Button
      onClick={() => act("leaveCall")}
    >
      Hang up
    </Button>
  );

  const dialButton = (text) => (

    <Button m={0.5} height={5} width={5} fontSize={5} fontFamily={'Sans-serif'}
      onClick={() => (
        onDial(text)
      )}>
      <div
        style={{
          position: 'absolute', left: '50%', top: '50%',
          transform: 'translate(-50%, -50%)', // once again, all praise stack overflow
        }}
      >
        {text}
      </div>
    </Button>

  );



  const dialScreen = (
    <Section>
      <Box backgroundColor="#86ab6c" textColor="black" bold={1} opacity={1} height={3} fontSize={2.9} fontFamily="monospace">
        <div align="right">{formattedDialledNumber(dialledNumber)}</div>
      </Box>
    </Section>
  );

  const dialPad = (
    <Section>
      <Stack direction="column">
        <Box>
          <Stack.Item mx={0.5} maxWidth={16} overflow="hidden"> {/* cant think of another way to cleanly cap width */}
            {!!elementSettings["dialScreen"] && (
              dialScreen)}
          </Stack.Item>
          <Stack.Item>
            <Stack direction="row">
              <Stack direction="column">
                {(dialButton("7"))}
                {(dialButton("4"))}
                {(dialButton("1"))}
                {(dialButton("∗"))}
              </Stack>
              <Stack direction="column">
                {(dialButton("8"))}
                {(dialButton("5"))}
                {(dialButton("2"))}
                {(dialButton("0"))}
              </Stack>
              <Stack direction="column">
                {(dialButton("9"))}
                {(dialButton("6"))}
                {(dialButton("3"))}
                {(dialButton("#"))}
              </Stack>
            </Stack>
          </Stack.Item>
        </Box>
      </Stack>
    </Section>
  );

  const contactsSection = (
    <Section title="Contact List" scrollable fill>
      <LabeledList>
        <Box>
          {contactList.map((contact) => (
            <LabeledList.Item label={String.spliceSlice(contact["phoneNumber"], 3, 0, "-")} key={contact["phoneNumber"]}>
              {
                <Button
                  onClick={() => act("makeCall", { target: contact["phoneNumber"] })}
                >
                  {contact["name"]}
                </Button>
              }
            </LabeledList.Item>
          ))}
        </Box>
      </LabeledList>
    </Section>
  );



  return (
    <Window width={600} height={375} theme="retro-dark">
      <Window.Content>
        {!!elementSettings["hangupButton"] && (
          hangupButton
        )}
        <Stack.Item>
          <Stack direction="row">
            <Stack.Item grow={1}>
              {!!elementSettings["contactPanel"] && (
                contactsSection)}
            </Stack.Item>
            <Stack.Item>
              {!!elementSettings["dialPad"] && (
                dialPad)}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Window.Content>
    </Window>
  );
};
