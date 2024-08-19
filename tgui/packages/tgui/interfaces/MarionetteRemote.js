import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Button, Flex, Input, LabeledList, Section } from '../components';

const onChange = (value) => act('set_data', { value });

export const MarionetteRemote = (_props, context) => {
  const { act, data } = useBackend(context);
  const { entered_data, selected_command, implants } = data;

  return (
    <Window
      title="Marionette Remote"
      width={410}
      height={550}
      theme="syndicate">
      <Window.Content scrollable>
        <Section title="Controls">
          <Flex direction="column">
            <Flex.Item>
              <LabeledList>
                <LabeledList.Item key="data" label="Data">
                  {selected_command !== "step" ? (
                    <Input
                      fluid
                      onChange={(_, data) => act("set_data", { new_data: data })}
                      value={entered_data}
                      placeholder="Unset..."
                    />)
                    : (
                      <>
                        <Button
                          onClick={() => act("set_data", { new_data: "NORTH" })}
                          icon="arrow-up"
                          selected={entered_data === "NORTH"}
                        />
                        <Button
                          onClick={() => act("set_data", { new_data: "SOUTH" })}
                          icon="arrow-down"
                          selected={entered_data === "SOUTH"}
                        /><Button
                          onClick={() => act("set_data", { new_data: "WEST" })}
                          icon="arrow-left"
                          selected={entered_data === "WEST"}
                        /><Button
                          onClick={() => act("set_data", { new_data: "EAST" })}
                          icon="arrow-right"
                          selected={entered_data === "EAST"}
                        />
                      </>)}
                </LabeledList.Item>
                <LabeledList.Item key="command" label="Command">
                  <Button
                    onClick={() => act("set_command", { new_command: "say" })}
                    content="Say"
                    selected={selected_command === "say"}
                  />
                  <Button
                    onClick={() => act("set_command", { new_command: "emote" })}
                    content="Emote"
                    selected={selected_command === "emote"}
                  />
                  <Button
                    onClick={() => act("set_command", { new_command: "step" })}
                    content="Step"
                    selected={selected_command === "step"}
                  />
                  <Button
                    onClick={() => act("set_command", { new_command: "drop" })}
                    content="Drop"
                    selected={selected_command === "drop"}
                  />
                  <Button
                    onClick={() => act("set_command", { new_command: "use" })}
                    content="Use"
                    selected={selected_command === "use"}
                  />
                  <Button
                    onClick={() => act("set_command", { new_command: "shock" })}
                    content="Shock"
                    selected={selected_command === "shock"}
                  />
                </LabeledList.Item>
                <LabeledList.Item key="action_heat" label="Heat Per Action">
                  {selected_command === "shock" || selected_command === "drop" ? "HIGH"
                    : selected_command === "step" ? "LOW" : "MEDIUM"}
                </LabeledList.Item>
              </LabeledList>
            </Flex.Item>
          </Flex>
        </Section>
        <Section title="Implants" buttons={(
          <Button
            icon="rotate"
            content="Ping All"
            onClick={() => act('ping_all')}
          />
        )}>
          {mapImplants(act, entered_data, selected_command, implants)}
        </Section>
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
      return "This implant is dangerously hot. Further short-term use will likely cause it to break.";
    case "NO RESPONSE":
      return "This implant is not responding to pings. It could have been destroyed, or it could just be far away.";
    case "BURNED OUT":
      return "This implant has been rendered permanently unusable by overuse and can be removed from the tracking list.";
    default:
      return "Unknown.";
  }
};

const mapImplants = (act, entered_data, selected_command, implants) => {
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
                onClick={() => act('ping', { address: implant.address })}
                disabled={implant.status === "BURNED OUT"}
              />
              <Button
                icon="envelope"
                content="Activate"
                onClick={() => act('activate', { address: implant.address, packet_data: entered_data, packet_command: selected_command })}
                disabled={implant.status === "BURNED OUT"}
              />
              <Button.Confirm
                icon="link-slash"
                onClick={() => act('remove_from_list', { address: implant.address })}
                tooltip="Stops tracking this implant. This doesn't destroy the implant, only removes it from the list."
              />
            </>
          )}>
          {implant.status}
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
};
