import { Fragment } from "inferno";
import { useBackend } from "../../backend";
import {
  Box,
  Button,
  Divider,
  Flex,
  LabeledList,
  NoticeBox,
  Section,
} from "../../components";
import { CharacterPreferencesData, CharacterPreferencesProfile } from "./type";

export const SavesTab = (_props, context) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);

  return (
    <Fragment>
      <Section title="Profiles">
        {data.profiles.map((profile, index) => (
          <Fragment key={index}>
            <Profile profile={profile} index={index} />
            {index !== data.profiles.length - 1 && <Divider />}
          </Fragment>
        ))}
      </Section>
      <Section title="Cloud Saves">
        {data.cloudSaves ? (
          <Fragment>
            {data.cloudSaves.map((save, index) => (
              <Fragment key={save.name}>
                <Cloudsave name={save.name} index={index} />
                <Divider />
              </Fragment>
            ))}
            <Box mt="5px">
              <Button onClick={() => act("cloud-new")}>Create new save</Button>
            </Box>
          </Fragment>
        ) : (
          <Box italic color="label">
            Cloud saves could not be loaded.
          </Box>
        )}
      </Section>
    </Fragment>
  );
};

const Profile: (
  props: { index: number; profile: CharacterPreferencesProfile },
  context: any
) => JSX.Element = ({ profile, index }, context) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);

  return (
    <Flex
      backgroundColor={profile.active ? "#0c2e60" : "transparent"}
      p="5px"
      align="center"
    >
      <Flex.Item color="label">Profile {index + 1}:</Flex.Item>
      <Flex.Item mx="5px" grow>
        {profile.name ? (
          <Box>{profile.name}</Box>
        ) : (
          <Box italic color="label">
            Empty
          </Box>
        )}
      </Flex.Item>
      <Flex.Item>
        {/* Just a small gap between these so you dont accidentally hit one */}
        <Button
          disabled={!profile.name}
          onClick={() => act("load", { index: index + 1 })}
        >
          Load
        </Button>{" "}
        -{" "}
        <Button onClick={() => act("save", { index: index + 1 })}>
          Save
        </Button>
      </Flex.Item>
    </Flex>
  );
};

const Cloudsave: (
  props: { name: string; index: number },
  context: any
) => JSX.Element = ({ name, index }, context) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);

  return (
    <LabeledList>
      <LabeledList.Item
        label={`Cloud save ${index + 1}`}
        buttons={
          <Fragment>
            {/* Just a small gap between these so you dont accidentally hit one */}
            <Button onClick={() => act("cloud-load", { name })}>Load</Button>{" "}
            -{" "}
            <Button onClick={() => act("cloud-save", { name })}>Save</Button>{" "}
            -{" "}
            <Button.Confirm
              onClick={() => act("cloud-delete", { name })}
              content="Delete"
            />
          </Fragment>
        }
      >
        {name}
      </LabeledList.Item>
    </LabeledList>
  );
};
