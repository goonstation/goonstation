/**
 * @file
 * @copyright 2023
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

interface CrewCreditsData {
  groups: GroupBlockProps[];
}

export const CrewCredits = (props, context) => {
  const { data } = useBackend<CrewCreditsData>(context);
  return (
    <Window title="Crew Credits" width={600} height={600}>
      <Window.Content scrollable>
        {data.groups?.map(
          (group, index) =>
            data.groups[index].crew.length > 0 && <GroupBlock key={index} title={group.title} crew={group.crew} />
        )}
      </Window.Content>
    </Window>
  );
};

interface GroupBlockProps {
  title: string;
  crew: CrewMemberProps[];
}

const GroupBlock = (props: GroupBlockProps) => {
  const { title: group_title, crew } = props;

  const heads = crew?.filter((member) => member.head);
  const non_heads = crew?.filter((member) => !member.head);

  return (
    <Section title={group_title}>
      <Stack fill vertical>
        {heads?.map((member, index) => (
          <CrewMember
            key={'head' + index}
            real_name={member.real_name}
            dead={member.dead}
            player={member.player}
            role={member.role}
            head
          />
        ))}
        {non_heads?.map((member, index) => (
          <CrewMember
            key={index}
            real_name={member.real_name}
            dead={member.dead}
            player={member.player}
            role={member.role}
          />
        ))}
      </Stack>
    </Section>
  );
};

interface CrewMemberProps {
  real_name: string;
  dead: BooleanLike;
  player: string;
  role: string;
  head?: BooleanLike;
}

const CrewMember = (props: CrewMemberProps) => {
  const { real_name, dead, player, role, head } = props;
  return (
    <Stack.Item>
      <Stack fill bold={head} justify="space-between">
        <Stack.Item grow>{role}</Stack.Item>
        <Stack.Item shrink textAlign="right">
          {!!dead && <Icon name="skull" />} {real_name} (played by {player})
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};
