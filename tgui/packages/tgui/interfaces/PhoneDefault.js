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
  const numberString = String(number);
  let toReturn = number;

  if (numberString.length > 3) {
    toReturn = String.spliceSlice(number, 3, 0, "-"); }

  if (numberString.length > 7) {
    toReturn = String.spliceSlice(toReturn, 8, 0, "("); }

  toReturn = toReturn.slice(-9);

  return toReturn;

};

export const PhoneDefault = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    contactList,
    elementSettings,
    dialledNumber,
    incomingCall,
    currentCall,
  } = data;


  const onDial = (text) => {
    act("dialpad", { text });
  };



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

  const hangupButton = (
    <Button
      m={0.5}
      height={5}
      width={7.75}
      fontSize={2.25}
      bold={1}
      fontFamily={'Sans-serif'}
      backgroundColor="red"
      onClick={() => onDial("HANG")}
    >
      <div
        style={{
          position: 'absolute', left: '50%', top: '50%',
          transform: 'translate(-50%, -50%)',
        }}
      >
        HANG
      </div>
    </Button>
  );

  const callButton = (
    <Button
      m={0.5}
      height={5}
      width={7.75}
      fontSize={2.25}
      bold={1}
      fontFamily={'Sans-serif'}
      disabled={(currentCall | incomingCall)}
      onClick={() => onDial("CALL")}
    >
      <div
        style={{
          position: 'absolute', left: '50%', top: '50%',
          transform: 'translate(-50%, -50%)',
        }}
      >
        CALL
      </div>
    </Button>
  );

  const dialScreen = (
    <Section>
      <Box
        backgroundColor="#86ab6c"
        textColor="black" bold={1}
        opacity={1}
        height={3}
        fontSize={2.9}
        fontFamily="monospace">
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
                {(dialButton("1"))}
                {(dialButton("4"))}
                {(dialButton("7"))}
                {(dialButton("∗"))}
              </Stack>
              <Stack direction="column">
                {(dialButton("2"))}
                {(dialButton("5"))}
                {(dialButton("8"))}
                {(dialButton("0"))}
              </Stack>
              <Stack direction="column">
                {(dialButton("3"))}
                {(dialButton("6"))}
                {(dialButton("9"))}
                {(dialButton("#"))}
              </Stack>
            </Stack>
            {(hangupButton)}
            {(callButton)}
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
                <Button disabled={(!!(incomingCall | currentCall))}
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

  let ourTheme;

  if (elementSettings["syndicate"]) {
    ourTheme = "syndicate";
  }

  return (
    <Window width={600} height={450} theme={(ourTheme)} >
      <Window.Content>
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
