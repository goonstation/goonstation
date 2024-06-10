/**
 * @file
 * @copyright 2023
 * @author Original glowbold (https://github.com/pgmzeta)
 * @author Changes Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Box, Icon, Section, Stack } from '../../components';
import { CrewMemberProps, CrewTabData, GroupBlockProps } from './type';

export const CrewTab = (props, context) => {
  const { data } = useBackend<CrewTabData>(context);
  return (
    <Box>
      {data.groups?.map(
        (group, index) =>
          data.groups[index].crew.length > 0 && <GroupBlock key={index} title={group.title} crew={group.crew} />
      )}
    </Box>
  );
};

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
