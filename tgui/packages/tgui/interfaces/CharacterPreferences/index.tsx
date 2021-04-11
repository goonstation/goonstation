import { useBackend, useLocalState, useSharedState } from '../../backend';
import {
  Box,
  Button,
  ByondUi,
  Divider,
  Flex,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from '../../components';
import { Window } from '../../layouts';
import { CharacterPreferencesData, CharacterPreferencesProfile, CharacterPreferencesTabKeys } from './type';
import { SavesTab } from './SavesTab';
import { CharacterTab } from './CharacterTab';
import { GeneralTab } from './GeneralTab';
import { GameSettingsTab } from './GameSettingsTab';
import { Fragment } from 'inferno';

export const CharacterPreferences = (_props, context) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);
  const [menu, setMenu] = useSharedState(context, 'menu', CharacterPreferencesTabKeys.General);

  return (
    <Window width={600} height={750} title="Character Setup">
      <Window.Content scrollable>
        <SavesAndProfile />
        <Tabs>
          <Tabs.Tab
            selected={menu === CharacterPreferencesTabKeys.General}
            onClick={() => setMenu(CharacterPreferencesTabKeys.General)}>
            General
          </Tabs.Tab>
          <Tabs.Tab
            selected={menu === CharacterPreferencesTabKeys.Character}
            onClick={() => setMenu(CharacterPreferencesTabKeys.Character)}>
            Appearance
          </Tabs.Tab>
          <Tabs.Tab onClick={() => act('occupation-window')}>Occupation</Tabs.Tab>
          <Tabs.Tab onClick={() => act('traits-window')}>Traits</Tabs.Tab>
          <Tabs.Tab
            selected={menu === CharacterPreferencesTabKeys.GameSettings}
            onClick={() => setMenu(CharacterPreferencesTabKeys.GameSettings)}>
            Game Settings
          </Tabs.Tab>
          <Tabs.Tab
            selected={menu === CharacterPreferencesTabKeys.Saves}
            onClick={() => setMenu(CharacterPreferencesTabKeys.Saves)}>
            Cloud Saves
          </Tabs.Tab>
        </Tabs>
        {menu === CharacterPreferencesTabKeys.General || menu === CharacterPreferencesTabKeys.Character ? (
          <Flex>
            <Flex.Item grow="1">
              <Box>
                {menu === CharacterPreferencesTabKeys.General && <GeneralTab />}
                {menu === CharacterPreferencesTabKeys.Character && <CharacterTab />}
              </Box>
            </Flex.Item>
            <Flex.Item ml="5px">
              <Section fill>
                <ByondUi
                  params={{
                    id: data.preview,
                    type: 'map',
                  }}
                  style={{
                    width: '80px',
                    height: '80px',
                  }}
                />
                <Box textAlign="center" mt="5px">
                  <Button icon="chevron-left" onClick={() => act('rotate-clockwise')} />
                  <Button icon="chevron-right" onClick={() => act('rotate-counter-clockwise')} />
                </Box>
              </Section>
            </Flex.Item>
          </Flex>
        ) : (
          <Fragment>
            {menu === CharacterPreferencesTabKeys.GameSettings && <GameSettingsTab />}
            {menu === CharacterPreferencesTabKeys.Saves && <SavesTab />}
          </Fragment>
        )}

        <Section mt="5px">
          <Button.Confirm content="Reset All" onClick={() => act('reset')} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const SavesAndProfile = (_props, context) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);

  const activeProfileIndex = data.profiles.findIndex((p) => p.active);

  return (
    <Fragment>
      <Flex mb="5px">
        {data.profiles.map((profile, index) => (
          <Flex.Item key={index} ml={index === 0 ? '0' : '5px'} grow="1">
            <Profile profile={profile} index={index} />
          </Flex.Item>
        ))}
      </Flex>

      <Section>
        <LabeledList>
          <LabeledList.Item
            label="Profile Name"
            buttons={
              activeProfileIndex > -1 ? (
                <Fragment>
                  <Button onClick={() => act('load', { index: activeProfileIndex + 1 })}>Reload</Button> -{' '}
                  <Button onClick={() => act('save', { index: activeProfileIndex + 1 })}>Save</Button>
                </Fragment>
              ) : null
            }>
            <Button onClick={() => act('update', { profileName: 1 })}>
              {data.profileName ? data.profileName : <Box italic>None</Box>}
            </Button>
          </LabeledList.Item>
        </LabeledList>
        {data.profileModified ? (
          <Fragment>
            <Divider />
            <NoticeBox danger mt="10px">
              <Flex>
                <Flex.Item align="center" mr="5px">
                  <Icon name="exclamation-triangle" />
                </Flex.Item>
                <Flex.Item>
                  <Box>You may have unsaved changes!</Box>
                  <Box>Any unsaved changes will take effect for this round only.</Box>
                </Flex.Item>
              </Flex>
            </NoticeBox>
          </Fragment>
        ) : null}
      </Section>
    </Fragment>
  );
};

type ProfileProps = {
  index: number,
  profile: CharacterPreferencesProfile
}

const Profile = (
  { profile, index } : ProfileProps,
  context: any
) => {
  const { act } = useBackend<CharacterPreferencesData>(context);

  return (
    <Section
      title={`Profile ${index + 1}`}
      textAlign="center"
      backgroundColor={profile.active ? 'rgba(0, 0, 0, 0.10)' : null}>
      <Box mb="5px">
        {profile.name ? (
          <Box>{profile.name}</Box>
        ) : (
          <Box italic color="label">
            Empty
          </Box>
        )}
      </Box>
      {/* Just a small gap between these so you dont accidentally hit one */}
      <Button disabled={!profile.name} onClick={() => act('load', { index: index + 1 })}>
        Load
      </Button>{' '}
      - <Button onClick={() => act('save', { index: index + 1 })}>Save</Button>
    </Section>
  );
};
