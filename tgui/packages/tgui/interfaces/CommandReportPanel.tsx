/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import {
  BlockQuote,
  Button,
  Dropdown,
  Input,
  Section,
  Slider,
  Stack,
  TextArea,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface CommandReportPanelData {
  origin_choices: string[];
  show_origin: BooleanLike;
  origin: string;
  header: string;
  body: string;
  text_styling: string;
  text_styling_options: string[];
  send_printout: BooleanLike;
  sound_to_play: string;
  sound_options: string[];
  sound_volume: number;
}

export const CommandReportPanel = (_props) => {
  const { act, data } = useBackend<CommandReportPanelData>();

  return (
    <Window title="Command Report Panel" width={450} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section title="Origin">
              <Stack fill align="center">
                <Stack.Item>
                  <Dropdown
                    icon="list"
                    selected={data.origin}
                    options={data.origin_choices}
                    iconOnly
                    menuWidth={'300px'}
                    onSelected={(value) => act('set_origin', { value })}
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Input
                    fluid
                    onBlur={(value) => act('set_origin', { value })}
                    value={data.origin}
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
            <Section
              buttons={
                <Button
                  icon="download"
                  onClick={() =>
                    act('set_header', {
                      value: 'AREA Announcement by NAME (JOB)',
                    })
                  }
                >
                  Announcement Computer Format
                </Button>
              }
              title="Header"
            >
              <Input
                fluid
                onBlur={(value) => act('set_header', { value })}
                value={data.header}
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              title="Body"
              buttons={
                <Dropdown
                  selected={data.text_styling}
                  options={data.text_styling_options}
                  onSelected={(value) => {
                    act('set_text_styling', { value });
                  }}
                />
              }
            >
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
              <Stack fill align="center">
                <Stack.Item>
                  <Dropdown
                    icon="list"
                    selected={data.sound_to_play}
                    options={data.sound_options}
                    iconOnly
                    menuWidth={'400px'}
                    onSelected={(value) => act('set_sound', { value })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button icon="file-audio" onClick={() => act('upload_sound')}>
                    {data.sound_to_play}
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="refresh"
                    color="green"
                    tooltip="Sync sound settings to origin"
                    onClick={() => act('sync_sound')}
                  />
                </Stack.Item>
              </Stack>
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
