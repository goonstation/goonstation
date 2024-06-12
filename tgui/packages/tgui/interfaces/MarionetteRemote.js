import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Button, Flex, LabeledList, Section, Stack } from '../components';

export const MarionetteRemote = (_props, context) => {
  const { act, data } = useBackend(context);
  const { data_field, set_command, implants } = data;

  return (
    <Window
      title="Marionette Remote"
      width={400}
      height={550}
      theme="syndicate" >
      <Window.Content scrollable>
        <Stack vertical fill minHeight="1%" maxHeight="100%">
          <Section title="Controls">
            <Flex direction="column">
              <Flex.Item>
                <LabeledList>
                  <LabeledList.Item key="data" label="Data">
                    {set_command !== "step" ? (
                      <Button
                        fluid
                        onClick={() => act("set_data")}
                        disabled={set_command !== "say" && set_command !== "emote"}
                        content={data_field ? data_field : "UNSET"}
                      />)
                      : <><Button
                          onClick={() => act("set_data", { new_data: "NORTH" })}
                          icon="arrow-up"
                          selected={data_field === "NORTH"}
                      /><Button
                        onClick={() => act("set_data", { new_data: "SOUTH" })}
                        icon="arrow-down"
                        selected={data_field === "SOUTH"}
                      /><Button
                        onClick={() => act("set_data", { new_data: "WEST" })}
                        icon="arrow-left"
                        selected={data_field === "WEST"}
                      /><Button
                        onClick={() => act("set_data", { new_data: "EAST" })}
                        icon="arrow-right"
                        selected={data_field === "EAST"}
                      />
                      </>}
                  </LabeledList.Item>
                  <LabeledList.Item key="command" label="Command">
                    <Button
                      onClick={() => act("set_command", { new_command: "say" })}
                      content="Say"
                      selected={set_command === "say"}
                    />
                    <Button
                      onClick={() => act("set_command", { new_command: "emote" })}
                      content="Emote"
                      selected={set_command === "emote"}
                    />
                    <Button
                      onClick={() => act("set_command", { new_command: "step" })}
                      content="Step"
                      selected={set_command === "step"}
                    />
                    <Button
                      onClick={() => act("set_command", { new_command: "drop" })}
                      content="Drop"
                      selected={set_command === "drop"}
                    />
                    <Button
                      onClick={() => act("set_command", { new_command: "use" })}
                      content="Use"
                      selected={set_command === "use"}
                    />
                    <Button
                      onClick={() => act("set_command", { new_command: "shock" })}
                      content="Shock"
                      selected={set_command === "shock"}
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Flex.Item>
            </Flex>
          </Section>
          <Section title="Implants" buttons={(
            <Button
              icon="rotate"
              content="Refresh"
              onClick={() => act('ping_all')}
            />
          )}>
            {mapImplants(act, data_field, set_command, implants)}
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const tooltipForStatus = (status) => {
  switch (status) {
    case "IDLE":
      return "This implant is not located inside a living being.";
    case "ACTIVE":
      return "This implant is inside a living being and ready to accept signals.";
    case "WAITING...":
      return "Awaiting ping response...";
    case "DANGER":
      return "This implant is dangerously hot. Further use will likely cause it to break.";
    case "NO RESPONSE":
      return "This implant is not responding to pings. It could have been destroyed, or it could just be far away.";
    case "BURNED OUT":
      return "This implant has been rendered permanently unusable by overuse and can be removed from the tracking list.";
    default:
      return "Unknown.";
  }
};

const mapImplants = (act, data_field, set_command, implants) => {
  if (!implants || !implants.length)
  { return (<i>No implants detected.</i>); }
  return (
    <LabeledList>
      {implants.map(implant => (
        <LabeledList.Item
          key={implant.address}
          label={implant.address}
          buttons={(
            <>
              <Button
                icon="info"
                tooltip={tooltipForStatus(implant.status)}
              />
              <Button
                icon="satellite-dish"
                content="Ping"
                onClick={() => act('ping_implant', { address: implant.address })}
                disabled={implant.status === "BURNED OUT"}
              />
              <Button
                icon="envelope"
                content="Activate"
                onClick={() => act('message_implant', { address: implant.address, packet_data: data_field, packet_command: set_command })}
                disabled={implant.status === "BURNED OUT"}
              />
              <Button.Confirm
                icon="x"
                onClick={() => act('remove_implant', { address: implant.address })}
              />
            </>
          )}>
          {implant.status}
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
};
