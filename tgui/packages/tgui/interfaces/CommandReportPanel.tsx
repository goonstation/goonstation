/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import {
  Button,
  Dropdown,
  Input,
  Slider,
  Section,
  Stack,
  TextArea,
  BlockQuote,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface CommandReportPanelData {
  origin: string;
  origin_choices: string[];
  header: string;
  body: string;
  show_origin: BooleanLike;

  sound_to_play: string;
  sound_volume: number;
}

export const CommandReportPanel = (_props) => {
  const { act, data } = useBackend<CommandReportPanelData>();

  return (
    <Window title="Command Report Panel" width={500}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section title="Origin">
              <Stack fill>
                <Stack.Item grow>
                  <Input
                    fluid
                    onBlur={(value) => act('set_origin', { value })}
                    value={data.origin}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Dropdown
                    icon="list"
                    selected={data.origin}
                    options={data.origin_choices}
                    iconOnly
                    menuWidth={'200px'}
                    onSelected={(value) => act('set_origin', { value })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button.Checkbox
                    checked={data.show_origin}
                    onClick={() => act('toggle_show_origin')}
                  >
                    Show Origin
                  </Button.Checkbox>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Header">
              <Input
                fluid
                onBlur={(value) => act('set_header', { value })}
                value={data.header}
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill title="Body">
              <TextArea
                height="100%"
                fluid
                onBlur={(value) => act('set_body', { value })}
                value={data.body}
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Sound">
              <Button>{data.sound_to_play}</Button>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Volume">
              <BlockQuote>Always 100 if showing origin</BlockQuote>
              <Slider
                minValue={0}
                maxValue={100}
                value={data.sound_volume}
                onChange={(event, value) =>
                  act('set_sound_volume', { volume: value })
                }
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Button
              fontSize="24px"
              fluid
              color="green"
              icon="bullhorn"
              onClick={() => act('announce')}
              align="center"
            >
              Announce
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
