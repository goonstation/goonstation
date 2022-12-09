import { BooleanLike } from "common/react";
import { useBackend } from "../backend";
import { Box, Section } from "../components";
import { Window } from "../layouts";

interface CrewCreditsData {
  groups: GroupBlockProps[]
}

export const CrewCredits = (props, context) => {
  const { data } = useBackend<CrewCreditsData>(context);
  return (
    <Window title="Crew Credits" width={600} height={600} theme={"paper"}>
      <Window.Content scrollable>
        {data.groups?.map((group, index) =>
          (!!(data.groups[index].crew.length > 0) && <GroupBlock key={index} group={group.group} crew={group.crew} />)
        )}
      </Window.Content>
    </Window>);
};

interface GroupBlockProps {
  group: string,
  crew: CrewMemberProps[]
}

const GroupBlock = (props:GroupBlockProps) => {
  const { group, crew } = props;
  const group_title = group;
  return (
    <Section title={group_title}>
      {crew?.map((member, index) =>
        (
          !!member.head && <CrewMember
            key={"head" + index}
            real_name={member.real_name}
            dead={member.dead}
            player={member.player}
            role={member.role}
            head />
        )
      )}
      {crew?.map((member, index) =>
        (
          !member.head && <CrewMember
            key={index}
            real_name={member.real_name}
            dead={member.dead}
            player={member.player}
            role={member.role} />
        )
      )}
    </Section>
  );

};

interface CrewMemberProps {
  real_name: string,
  dead: BooleanLike,
  player: string,
  role: string,
  head?: BooleanLike,
}

const CrewMember = (props: CrewMemberProps) => {
  const { real_name, dead, player, role, head } = props;
  return (
    <>
      <Box as="span" bold={head}>{real_name} {!!dead && "[DEAD]"} (played by {player}) as {role}</Box>
      <br />
    </>
  );
};
