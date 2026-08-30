import {
  Button,
  Image,
  Input,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface AgentCardData {
  userName: string;
  cachedName: string;
  cachedAssignment: string;
  cachedAppearance: string;
  cachedPronouns: string;
  cachedKeepIcon: boolean;
  cardAppearances: CardAppearance[];
  canForge: boolean;
}

interface CardAppearance {
  style: string;
  name: string;
  state: string;
  icon: string;
  keep_icon_on_job_change: boolean;
}

export const AgentCard = () => {
  const { act, data } = useBackend<AgentCardData>();
  const {
    userName,
    cachedName,
    cachedAssignment,
    cachedAppearance,
    cachedPronouns,
    cachedKeepIcon,
    cardAppearances,
    canForge,
  } = data;

  return (
    <Window width={400} height={360} theme="syndicate">
      <Window.Content>
        <Section
          title="Identity"
          buttons={
            <Button.Confirm
              icon="undo"
              color="green"
              onClick={() => act('reset_cached')}
            >
              Reset
            </Button.Confirm>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Name">
              <Input
                fluid
                placeholder={userName}
                value={cachedName}
                maxLength={100}
                onBlur={(val: string) => act('set_name', { name: val })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Assignment">
              <Input
                fluid
                placeholder="Staff Assistant"
                value={cachedAssignment}
                maxLength={100}
                onBlur={(val: string) =>
                  act('set_assignment', { assignment: val })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Pronouns">
              <Button onClick={() => act('set_pronouns')}>
                {cachedPronouns || 'None'}
              </Button>
              {cachedPronouns && (
                <Button onClick={() => act('remove_pronouns')} icon="trash" />
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Card Appearance"
          buttons={
            <Button.Checkbox
              checked={cachedKeepIcon}
              tooltip="Maintains the card's icon if its job is changed in an ID computer."
              onClick={() => act('toggle_keep_icon')}
            >
              Keep icon?
            </Button.Checkbox>
          }
        >
          {cardAppearances.map((icon) => (
            <Button
              key={icon.state}
              onClick={() => act('set_appearance', { appearance: icon.state })}
              selected={icon.state === cachedAppearance}
            >
              <Image
                verticalAlign="middle"
                my="0.2rem"
                mr="0.5rem"
                height="24px"
                width="24px"
                src={`data:image/png;base64,${icon.icon}`}
              />
              {icon.name}
            </Button>
          ))}
        </Section>
        <Section fontSize="16px" textAlign="center">
          <Button.Confirm
            icon="id-card"
            fluid
            tooltip="You can only do this once!"
            onClick={() => act('do_forge')}
            disabled={!canForge}
          >
            Forge ID
          </Button.Confirm>
        </Section>
      </Window.Content>
    </Window>
  );
};
