/**
 * @file
 * @copyright 2024
 * @author Ilysen (https://github.com/Ilysen)
 * @license MIT
 */

import {
  Button,
  Flex,
  Input,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface MarionetteRemoteData {
  entered_data;
  implants;
  selected_command;
}

export const MarionetteRemote = () => {
  const { act, data } = useBackend<MarionetteRemoteData>();
  const { entered_data, selected_command, implants } = data;

  return (
    <Window
      title="Marionette Remote"
      width={410}
      height={550}
      theme="syndicate"
    >
      <Window.Content scrollable>
        <Section title="Controls">
          <Flex direction="column">
            <Flex.Item>
              <LabeledList>
                <LabeledList.Item key="data" label="Data">
                  {selected_command !== 'step' ? (
                    <Input
                      fluid
                      onBlur={(data) => act('set_data', { new_data: data })}
                      value={entered_data}
                      placeholder="Unset..."
                    />
                  ) : (
                    <>
                      <Button
                        onClick={() => act('set_data', { new_data: 'NORTH' })}
                        icon="arrow-up"
                        selected={entered_data === 'NORTH'}
                      />
                      <Button
                        onClick={() => act('set_data', { new_data: 'SOUTH' })}
                        icon="arrow-down"
                        selected={entered_data === 'SOUTH'}
                      />
                      <Button
                        onClick={() => act('set_data', { new_data: 'WEST' })}
                        icon="arrow-left"
                        selected={entered_data === 'WEST'}
                      />
                      <Button
                        onClick={() => act('set_data', { new_data: 'EAST' })}
                        icon="arrow-right"
                        selected={entered_data === 'EAST'}
                      />
                    </>
                  )}
                </LabeledList.Item>
                <LabeledList.Item key="command" label="Command">
                  <Button
                    onClick={() => act('set_command', { new_command: 'say' })}
                    selected={selected_command === 'say'}
                  >
                    Say
                  </Button>
                  <Button
                    onClick={() => act('set_command', { new_command: 'emote' })}
                    selected={selected_command === 'emote'}
                  >
                    Emote
                  </Button>
                  <Button
                    onClick={() => act('set_command', { new_command: 'step' })}
                    selected={selected_command === 'step'}
                  >
                    Step
                  </Button>
                  <Button
                    onClick={() => act('set_command', { new_command: 'drop' })}
                    selected={selected_command === 'drop'}
                  >
                    Drop
                  </Button>
                  <Button
                    onClick={() => act('set_command', { new_command: 'use' })}
                    selected={selected_command === 'use'}
                  >
                    Use
                  </Button>
                  <Button
                    onClick={() => act('set_command', { new_command: 'shock' })}
                    selected={selected_command === 'shock'}
                  >
                    Shock
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item key="action_heat" label="Heat Per Action">
                  {selected_command === 'shock' || selected_command === 'drop'
                    ? 'HIGH'
                    : selected_command === 'step'
                      ? 'LOW'
                      : 'MEDIUM'}
                </LabeledList.Item>
              </LabeledList>
            </Flex.Item>
          </Flex>
        </Section>
        <Section
          title="Implants"
          buttons={
            <Button icon="rotate" onClick={() => act('ping_all')}>
              Ping All
            </Button>
          }
        >
          {mapImplants(act, entered_data, selected_command, implants)}
        </Section>
      </Window.Content>
    </Window>
  );
};

const tooltipForStatus = (status) => {
  switch (status) {
    case 'IDLE':
      return 'This implant is not located inside a living being.';
    case 'ACTIVE':
      return 'This implant is inside a living being and ready to accept signals.';
    case 'WAITING...':
      return 'Awaiting ping response...';
    case 'DANGER':
      return 'This implant is dangerously hot. Further short-term use will likely cause it to break.';
    case 'NO RESPONSE':
      return 'This implant is not responding to pings. It could have been destroyed, or it could just be far away.';
    case 'BURNED OUT':
      return 'This implant has been rendered permanently unusable by overuse and can be removed from the tracking list.';
    default:
      return 'Unknown.';
  }
};

const mapImplants = (act, entered_data, selected_command, implants) => {
  if (!implants || !implants.length) {
    return <i>No implants detected.</i>;
  }
  return (
    <LabeledList>
      {implants.map((implant) => (
        <LabeledList.Item
          key={implant.address}
          label={implant.address}
          buttons={
            <>
              <Button icon="info" tooltip={tooltipForStatus(implant.status)} />
              <Button
                icon="satellite-dish"
                onClick={() => act('ping', { address: implant.address })}
                disabled={implant.status === 'BURNED OUT'}
              >
                Ping
              </Button>
              <Button
                icon="envelope"
                onClick={() =>
                  act('activate', {
                    address: implant.address,
                    packet_data: entered_data,
                    packet_command: selected_command,
                  })
                }
                disabled={implant.status === 'BURNED OUT'}
              >
                Activate
              </Button>
              <Button.Confirm
                icon="link-slash"
                onClick={() =>
                  act('remove_from_list', { address: implant.address })
                }
                tooltip="Stops tracking this implant. This doesn't destroy the implant, only removes it from the list."
              />
            </>
          }
        >
          {implant.status}
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
};
