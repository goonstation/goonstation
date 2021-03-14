import { useBackend, useSharedState } from '../backend';
import { Button, LabeledList, Section, Divider, Modal, Input, Box, Tooltip, Icon } from '../components';
import { Window } from '../layouts';
import { truncate } from '../format.js';

export const MixingDesk = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    voices,
    selected_voice,
    say_popup,
  } = data;
  const [message, setMessage] = useSharedState(context, "message", null);

  const sayPopup = () => (
    <Modal>
      Say as {
        selected_voice > 0 && selected_voice <= voices.length
          ? voices[selected_voice - 1].name
          : "yourself"
      }:
      <br />
      <Box
        pt={"5px"}
        pr={"10px"}
        textAlign={"center"}>
        <Input
          autoFocus
          selfClear
          width={20}
          value={message}
          onEnter={(_, msg) => {
            window.focus();
            act("say", { "message": msg });
            setMessage("");
          }}
          onChange={(_, msg) => setMessage(msg)} />
      </Box>
      <br />
      <Box
        textAlign={"center"}>
        <Button onClick={() => { act("say", { "message": message }); setMessage(""); }}>Say</Button>
        <Button onClick={() => { act("cancel_say"); setMessage(""); }}>Cancel</Button>
      </Box>
    </Modal>);

  const onKeyDown = e => {
    let key = String.fromCharCode(e.keyCode);
    let caught_key = true;
    if (key === "T") {
      act("say_popup");
    }
    else if (e.keyCode === 27 && say_popup) { // escape
      act("cancel_say");
      setMessage("");
    }
    else if (!say_popup) {
      let num = Number(key);
      if (String(num) === key) {
        // apparently in js this is the correct way to check if it's a number
        act("switch_voice", { id: num });
      }
      else {
        caught_key = false;
      }
    }
    else {
      caught_key = false;
    }
    if (caught_key) {
      e.stopPropagation();
    }
  };

  return (
    <Window
      height={375}
      width={370}>
      <Window.Content
        onkeydown={onKeyDown}>
        {!!say_popup && sayPopup()}
        <Section
          title="Voice Synthesizer">
          <Divider />
          <LabeledList>
            { voices.map((entry, id) => (
              <LabeledList.Item
                key={entry["name"]}
                label={(id + 1) + " " + (entry["accent"] ? truncate(entry["name"], 18) + " [" + entry["accent"] + "]" : truncate(entry["name"], 18))}
                labelColor={id + 1 === selected_voice ? "red" : "label"}>
                <Button
                  icon="trash-alt"
                  onClick={() => act("remove_voice", { id: id + 1 })} />
                <Button
                  icon="bullhorn"
                  onClick={() => act("say_popup", { id: id + 1 })} />
              </LabeledList.Item>
            )) }
            <LabeledList.Item>
              <Button
                icon="plus"
                onClick={() => act("add_voice")}
                disabled={voices.length >= 9} />
              <Box
                as="span"
                position="relative"
                pl="5px">
                <Icon name="question-circle" />
                <Tooltip
                  position="right"
                  content="Press T to talk and 1-9 keys to switch voices. Press 0 to reset to your normal voice." />
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
