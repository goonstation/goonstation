/**
 * Copyright (c) 2021 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const LongRangeTeleporter = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    destinations,
    receive_allowed,
    send_allowed,
    syndicate,
  } = data;

  return (
    <Window
      theme={syndicate ? 'syndicate' : 'ntos'}
      width={390}
      height={380}>
      <Window.Content>
        <Section title="Destinations">
          <LabeledList>
            {destinations.length ? destinations.map((d) => (
              <LabeledList.Item label={d["destination"]} key={d["destination"]}>
                {send_allowed && (
                  <Button
                    icon="sign-out-alt"
                    onClick={() => act("send", { target: d["ref"], name: d["destination"] })}
                  >
                    Send
                  </Button>
                )}
                {receive_allowed && (
                  <Button
                    icon="sign-in-alt"
                    onClick={() => act("receive", { target: d["ref"], name: d["destination"] })}
                  >
                    Receive
                  </Button>
                )}
              </LabeledList.Item>
            )) : (
              <LabeledList.Item>
                No destinations are currently available.
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
