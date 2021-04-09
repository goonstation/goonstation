import { useBackend, useLocalState, useSharedState } from "../../backend";
import {
  Box,
  Button,
  Divider,
  Flex,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from "../../components";
import { Window } from "../../layouts";
import { CharacterPreferencesData, CharacterPreferencesTabKeys } from "./type";
import { SavesTab } from "./SavesTab";
import { CharacterTab } from "./CharacterTab";
import { GeneralTab } from "./GeneralTab";
import { GameSettingsTab } from "./GameSettingsTab";
import { Fragment } from "inferno";

export const CharacterPreferences = (_props, context) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);
  const [menu, setMenu] = useSharedState(
    context,
    "menu",
    CharacterPreferencesTabKeys.General
  );

  const activeProfileIndex = data.profiles.findIndex(p => p.active);

  return (
    <Window width={600} height={750} title="Character Setup">
      <Window.Content scrollable>
        <Box>
          <Section>
            <LabeledList>
              <LabeledList.Item
                label="Profile Name"
                buttons={
                  activeProfileIndex > -1 ? (
                    <Fragment>
                      <Button
                        onClick={() =>
                          act("load", { index: activeProfileIndex + 1 })}
                      >
                        Reload
                      </Button>{" "}
                      -{" "}
                      <Button
                        onClick={() =>
                          act("save", { index: activeProfileIndex + 1 })}
                      >
                        Save
                      </Button>
                    </Fragment>
                  ) : null
                }
              >
                <Button onClick={() => act("update", { profileName: 1 })}>
                  {data.profileName}
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
                      <Box>
                        Any unsaved changes will take effect for this round
                        only.
                      </Box>
                    </Flex.Item>
                  </Flex>
                </NoticeBox>
              </Fragment>
            ) : null}
          </Section>

          <Tabs>
            <Tabs.Tab
              selected={menu === CharacterPreferencesTabKeys.Saves}
              onClick={() => setMenu(CharacterPreferencesTabKeys.Saves)}
            >
              Saves
            </Tabs.Tab>
            <Tabs.Tab
              selected={menu === CharacterPreferencesTabKeys.General}
              onClick={() => setMenu(CharacterPreferencesTabKeys.General)}
            >
              General
            </Tabs.Tab>
            <Tabs.Tab
              selected={menu === CharacterPreferencesTabKeys.Character}
              onClick={() => setMenu(CharacterPreferencesTabKeys.Character)}
            >
              Appearance
            </Tabs.Tab>
            <Tabs.Tab onClick={() => act("occupation-window")}>
              Occupation
            </Tabs.Tab>
            <Tabs.Tab onClick={() => act("traits-window")}>Traits</Tabs.Tab>
            <Tabs.Tab
              selected={menu === CharacterPreferencesTabKeys.GameSettings}
              onClick={() => setMenu(CharacterPreferencesTabKeys.GameSettings)}
            >
              Game Settings
            </Tabs.Tab>
          </Tabs>

          {menu === CharacterPreferencesTabKeys.Saves && <SavesTab />}
          {menu === CharacterPreferencesTabKeys.General && <GeneralTab />}
          {menu === CharacterPreferencesTabKeys.Character && <CharacterTab />}
          {menu === CharacterPreferencesTabKeys.GameSettings && (
            <GameSettingsTab />
          )}
          <Section>
            <Button.Confirm content="Reset All" onClick={() => act("reset")} />
          </Section>
        </Box>
      </Window.Content>
    </Window>
  );
};
