/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { KEY_LEFT, KEY_RIGHT } from 'common/keycodes';
import { useState } from 'react';
import {
  Box,
  Button,
  ByondUi,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { CharacterTab } from './CharacterTab';
import { GameSettingsTab } from './GameSettingsTab';
import { GeneralTab } from './GeneralTab';
import { useModalContext } from './modals/ModalContext';
import { OccupationPriorityModal } from './modals/OccupationPriorityModal';
import { ResetOccupationPreferencesModal } from './modals/ResetOccupationPreferencesModal';
import { OccupationTab } from './OccupationTab';
import { SavesTab } from './SavesTab';
import { TraitsTab } from './TraitsTab';
import {
  CharacterPreferencesData,
  CharacterPreferencesProfile,
  CharacterPreferencesTabKeys,
} from './type';

let nextRotateTime = 0;

export const CharacterPreferences = (_props: any) => {
  const { act, data } = useBackend<CharacterPreferencesData>();
  const [menu, setMenu] = useState(CharacterPreferencesTabKeys.General);
  const [modalContextValue, modalContextState, ModalContext] =
    useModalContext();
  const { occupationModal, resetOccupationPreferencesModal } =
    modalContextState;
  const handleKeyDown = (e) => {
    if (
      (menu === CharacterPreferencesTabKeys.General ||
        menu === CharacterPreferencesTabKeys.Character) &&
      (e.keyCode === KEY_LEFT || e.keyCode === KEY_RIGHT)
    ) {
      e.preventDefault();
      if (nextRotateTime > performance.now()) {
        return;
      }
      nextRotateTime = performance.now() + 125;

      let direction = 'rotate-counter-clockwise';
      if (e.keyCode === KEY_RIGHT) {
        direction = 'rotate-clockwise';
      }

      act(direction);
    }
  };

  return (
    <Window width={600} height={750} title="Character Setup">
      <ModalContext value={modalContextValue}>
        <Window.Content onKeyDown={handleKeyDown}>
          <Stack vertical fill>
            <Stack.Item>
              <SavesAndProfile />
            </Stack.Item>
            <Stack.Item>
              <Tabs>
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
                <Tabs.Tab
                  selected={menu === CharacterPreferencesTabKeys.Occupation}
                  onClick={() =>
                    setMenu(CharacterPreferencesTabKeys.Occupation)
                  }
                >
                  Occupation
                </Tabs.Tab>
                <Tabs.Tab
                  selected={menu === CharacterPreferencesTabKeys.Traits}
                  onClick={() => setMenu(CharacterPreferencesTabKeys.Traits)}
                >
                  Traits
                </Tabs.Tab>
                <Tabs.Tab
                  selected={menu === CharacterPreferencesTabKeys.GameSettings}
                  onClick={() =>
                    setMenu(CharacterPreferencesTabKeys.GameSettings)
                  }
                >
                  Game Settings
                </Tabs.Tab>
                <Tabs.Tab
                  selected={menu === CharacterPreferencesTabKeys.Saves}
                  onClick={() => setMenu(CharacterPreferencesTabKeys.Saves)}
                >
                  Cloud Saves
                </Tabs.Tab>
              </Tabs>
            </Stack.Item>
            <Stack.Item grow={1}>
              {(menu === CharacterPreferencesTabKeys.General ||
                menu === CharacterPreferencesTabKeys.Character) && (
                <Stack fill>
                  <Stack.Item basis={0} grow={1}>
                    <Section scrollable fill>
                      {menu === CharacterPreferencesTabKeys.General && (
                        <GeneralTab />
                      )}
                      {menu === CharacterPreferencesTabKeys.Character && (
                        <CharacterTab />
                      )}
                    </Section>
                  </Stack.Item>
                  <Stack.Item>
                    <Section fill>
                      <ByondUi
                        params={{
                          id: data.preview,
                          type: 'map',
                        }}
                        style={{
                          width: '64px',
                          height: '128px',
                        }}
                      />
                      <Box textAlign="center" mt="5px">
                        <Button
                          icon="chevron-left"
                          onClick={() => act('rotate-counter-clockwise')}
                        />
                        <Button
                          icon="chevron-right"
                          onClick={() => act('rotate-clockwise')}
                        />
                      </Box>
                    </Section>
                  </Stack.Item>
                </Stack>
              )}
              {(menu === CharacterPreferencesTabKeys.Occupation ||
                menu === CharacterPreferencesTabKeys.GameSettings ||
                menu === CharacterPreferencesTabKeys.Saves) && (
                <Section scrollable fill>
                  {menu === CharacterPreferencesTabKeys.Occupation && (
                    <OccupationTab />
                  )}
                  {menu === CharacterPreferencesTabKeys.GameSettings && (
                    <GameSettingsTab />
                  )}
                  {menu === CharacterPreferencesTabKeys.Saves && <SavesTab />}
                </Section>
              )}
              {menu === CharacterPreferencesTabKeys.Traits && <TraitsTab />}
            </Stack.Item>
            <Stack.Item>
              <Section>
                <Button.Confirm onClick={() => act('reset')}>
                  Reset All
                </Button.Confirm>
              </Section>
            </Stack.Item>
          </Stack>
        </Window.Content>
        {occupationModal && <OccupationPriorityModal {...occupationModal} />}
        {resetOccupationPreferencesModal && <ResetOccupationPreferencesModal />}
      </ModalContext>
    </Window>
  );
};

const SavesAndProfile = () => {
  const { act, data } = useBackend<CharacterPreferencesData>();

  const activeProfileIndex = data.profiles.findIndex((p) => p.active);

  return (
    <Stack vertical>
      <Stack.Item>
        <Stack>
          {data.profiles.map((profile, index) => (
            <Stack.Item key={index} basis={0} grow={1}>
              <Profile profile={profile} index={index} />
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section>
          <LabeledList>
            <LabeledList.Item
              label="Profile Name"
              buttons={
                activeProfileIndex > -1 ? (
                  <>
                    <Button
                      onClick={() =>
                        act('profile-file-import', {
                          index: activeProfileIndex + 1,
                        })
                      }
                    >
                      Import
                    </Button>
                    <Button
                      onClick={() =>
                        act('profile-file-export', {
                          index: activeProfileIndex + 1,
                        })
                      }
                    >
                      Export
                    </Button>
                    <Button
                      onClick={() =>
                        act('load', { index: activeProfileIndex + 1 })
                      }
                    >
                      Reload
                    </Button>
                    <Button
                      onClick={() =>
                        act('save', { index: activeProfileIndex + 1 })
                      }
                      icon={
                        data.profileModified
                          ? 'exclamation-triangle'
                          : undefined
                      }
                      color={data.profileModified ? 'danger' : undefined}
                      tooltip={
                        data.profileModified
                          ? 'You may have unsaved changes! Any unsaved changes will take effect for this round only.'
                          : undefined
                      }
                      tooltipPosition="left"
                    >
                      Save
                    </Button>
                  </>
                ) : null
              }
            >
              <Button onClick={() => act('update-profileName')}>
                {data.profileName ? data.profileName : <Box italic>None</Box>}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

type ProfileProps = {
  index: number;
  profile: CharacterPreferencesProfile;
};

const Profile = (props: ProfileProps) => {
  const { index, profile } = props;
  const { act } = useBackend<CharacterPreferencesData>();

  return (
    <Section
      title={`Profile ${index + 1}`}
      textAlign="center"
      backgroundColor={profile.active ? 'rgba(0, 0, 0, 0.10)' : null}
      fill
    >
      <Stack vertical fill justify="space-between">
        <Stack.Item>
          <Box>
            {profile.name ? (
              <Box>{profile.name}</Box>
            ) : (
              <Box italic color="label">
                Empty
              </Box>
            )}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Button
            disabled={!profile.name}
            onClick={() => act('load', { index: index + 1 })}
          >
            Load
          </Button>
          {' - '}
          <Button onClick={() => act('save', { index: index + 1 })}>
            Save
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
