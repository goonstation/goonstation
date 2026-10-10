/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import {
  Box,
  Button,
  DmIcon,
  ImageButton,
  LabeledList,
  Slider,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import {
  CharacterPreferencesData,
  CharacterPreferencesScrollTarget,
  CharacterPreferencesTooltip,
} from '../type';
import {
  ClientChoice,
  ClientToggle,
  useClientSetting,
} from './ClientSettingControls';

export const GeneralSettings = () => {
  const { act, data } = useBackend<CharacterPreferencesData>();
  return (
    <>
      <LabeledList.Item label="Popup Font Size">
        <Box mb="5px" color="label">
          Changes the font size in some popup windows.
        </Box>
        <Button onClick={() => act('update-fontSize')}>
          {data.fontSize ? data.fontSize + '%' : 'Default'}
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Messages">
        <Box mb="5px" color="label">
          Toggles if certain messages are shown in the chat window. You can also
          change these by using the Toggle OOC/LOOC commands under Commands in
          the top right.
        </Box>
        {data.isMentor ? (
          <Box mb="5px">
            <Button.Checkbox
              checked={data.seeMentorPms}
              onClick={() => act('update-seeMentorPms')}
            >
              Display Mentorhelp
            </Button.Checkbox>
          </Box>
        ) : null}
        <Box mb="5px">
          <Button.Checkbox
            checked={data.listenOoc}
            onClick={() => act('update-listenOoc')}
            tooltip="Out-of-Character chat. This mostly just shows up on the RP server and at the end of rounds."
          >
            Display OOC chat
          </Button.Checkbox>
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.listenLooc}
            onClick={() => act('update-listenLooc')}
            tooltip="Local Out-of-Character is OOC chat, but only appears for nearby players. This is basically only used on the RP server."
          >
            Display LOOC chat
          </Button.Checkbox>
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={!data.flyingChatHidden}
            onClick={() => act('update-flyingChatHidden')}
            tooltip="Chat messages will appear over characters as they're talking."
          >
            See chat above people&apos;s heads
          </Button.Checkbox>
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.autoCapitalization}
            onClick={() => act('update-autoCapitalization')}
            tooltip="Chat messages you send will be automatically capitalized."
          >
            Auto-capitalize your messages
          </Button.Checkbox>
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.localDeadchat}
            onClick={() => act('update-localDeadchat')}
            tooltip="You'll only hear chat messages from living people on your screen as a ghost."
          >
            Local ghost hearing
          </Button.Checkbox>
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="Popups">
        <Box mb="5px" color="label">
          The popups that appear when logging in and at the end of a round.
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.viewChangelog}
            onClick={() => act('update-viewChangelog')}
            tooltip="The changelog can be shown at any time by using the 'Changelog' command, under the Commands tab in the top right."
            tooltipPosition="top"
          >
            Auto-open changelog
          </Button.Checkbox>
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.viewScore}
            onClick={() => act('update-viewScore')}
            tooltip="The end-of-round scoring shows various stats on how the round went. If this option is off, you won't be able to see it."
            tooltipPosition="top"
          >
            Auto-open end-of-round score
          </Button.Checkbox>
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.viewTickets}
            onClick={() => act('update-viewTickets')}
            tooltip="The end-of-round ticketing summary shows the various tickets and fines that were handed out. If this option is off, you can still see them on Goonhub (goonhub.com)."
            tooltipPosition="top"
          >
            Auto-open end-of-round ticket summary
          </Button.Checkbox>
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="Preferred Map">
        <Button onClick={() => act('update-preferredMap')}>
          {data.preferredMap ? data.preferredMap : <Box italic>None</Box>}
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Examine help">
        <Button.Checkbox
          checked={data.helpTextInExamine}
          onClick={() => act('update-helpTextInExamine')}
          tooltip="If help messages in examine text annoy you, you can turn them off here. They will still be available by alt+doubleclicking the item or in the right click menu."
          tooltipPosition="top"
        >
          See help messages when you examine?
        </Button.Checkbox>
      </LabeledList.Item>
      <LabeledList.Item label="Observer">
        <Button.Checkbox
          checked={data.observerDnr}
          onClick={() => act('update-observerDnr')}
          tooltip="Automatically set yourself to DNR when joining as observer, will prevent some ghost spawn roles. Only applies when joining as observer from the lobby, not on death."
          tooltipPosition="top"
        >
          Automatically set DNR when joining as an observer
        </Button.Checkbox>
      </LabeledList.Item>
    </>
  );
};

export const InterfaceSettings = () => {
  const { act, data } = useBackend<CharacterPreferencesData>();
  return (
    <>
      <LabeledList.Item label="HUD Theme">
        <Stack wrap>
          {data.hudThemes.map((theme) => (
            <Stack.Item key={theme.name}>
              <ImageButton
                dmIcon={theme.icon}
                dmIconState="handl0"
                imageSize={64}
                selected={data.hudTheme === theme.name}
                onClick={() => act('update-hudTheme', { value: theme.name })}
              >
                {theme.name}
              </ImageButton>
            </Stack.Item>
          ))}
        </Stack>
      </LabeledList.Item>
      <LabeledList.Item label="HUD Layout">
        <ClientToggle setting="tg_layout">Use /tg/ HUD layout</ClientToggle>
        <ClientToggle setting="hand_ghosts">
          Show item ghosts on mouse-over
        </ClientToggle>
      </LabeledList.Item>
      <LabeledList.Item label="Targeting Cursor">
        <Stack align="center">
          <Stack.Item>
            <DmIcon
              icon={data.targetingCursorIcon}
              icon_state=""
              width="32px"
              height="32px"
            />
          </Stack.Item>
          <Stack.Item>
            <Button onClick={() => act('update-targetingCursor')}>
              Change
            </Button>
          </Stack.Item>
        </Stack>
      </LabeledList.Item>
      <LabeledList.Item label="Tooltips">
        <Box mb="5px" color="label">
          Tooltips can appear when hovering over items. These can provide bits
          of information, such as attack strength, special moves, etc.
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.tooltipOption === CharacterPreferencesTooltip.Always}
            onClick={() =>
              act('update-tooltipOption', {
                value: CharacterPreferencesTooltip.Always,
              })
            }
          >
            Show Always
          </Button.Checkbox>
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.tooltipOption === CharacterPreferencesTooltip.Alt}
            onClick={() =>
              act('update-tooltipOption', {
                value: CharacterPreferencesTooltip.Alt,
              })
            }
          >
            Show When ALT is held
          </Button.Checkbox>
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.tooltipOption === CharacterPreferencesTooltip.Never}
            onClick={() =>
              act('update-tooltipOption', {
                value: CharacterPreferencesTooltip.Never,
              })
            }
          >
            Never Show
          </Button.Checkbox>
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="tgui">
        <Box mb="5px" color="label">
          The UI framework we use for most game windows.
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.tguiFancy}
            onClick={() => act('update-tguiFancy')}
          >
            Makes TGUI windows look better, at the cost of compatibility.
          </Button.Checkbox>
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.tguiLock}
            onClick={() => act('update-tguiLock')}
          >
            Locks TGUI windows to your main monitor.
          </Button.Checkbox>
        </Box>
      </LabeledList.Item>
    </>
  );
};

export const ControlsSettings = () => {
  const { act, data } = useBackend<CharacterPreferencesData>();
  return (
    <>
      <LabeledList.Item label="Controls">
        <Box mb="5px" color="label">
          Various options for how you control your character and the game.
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.useClickBuffer}
            onClick={() => act('update-useClickBuffer')}
            tooltip="There is a cooldown after clicking on things in-game. When enabled, if you click something during this cooldown, the game will apply that click after the cooldown. Otherwise, the click is ignored."
            tooltipPosition="top"
          >
            Queue Combat Clicks
          </Button.Checkbox>
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.useWasd}
            onClick={() => act('update-useWasd')}
            tooltip="Enabling this allows you to use WASD to move instead of the arrow keys, and enables a few other hotkeys."
            tooltipPosition="top"
          >
            Use WASD Mode
          </Button.Checkbox>
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.useAzerty}
            onClick={() => act('update-useAzerty')}
            tooltip="If you have an AZERTY keyboard, enable this. Yep. This sure is a tooltip."
            tooltipPosition="top"
          >
            Use AZERTY Keyboard Layout
          </Button.Checkbox>
        </Box>
        <ClientToggle
          setting="tg_controls"
          tooltip="Familiar with /tg/station controls? This switches the hotkeys to match them."
        >
          Use /tg/ style controls
        </ClientToggle>
        <Box mb="5px" color="label">
          Usually middle mouse is a handy shortcut to open and close lockers.
          Tick this to enable the legacy behaviour of it swapping hands instead.
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={data.middleMouseSwap}
            onClick={() => act('update-middleMouseSwap')}
            tooltip="Middle mouse swaps hands"
          >
            Middle mouse swaps hands.
          </Button.Checkbox>
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="Scroll Targeting">
        <Box mb="5px" color="label">
          This option allows you to change which limb to target with the scroll
          wheel.
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={
              data.scrollWheelTargeting ===
              CharacterPreferencesScrollTarget.Always
            }
            onClick={() =>
              act('update-scrollWheelTargeting', {
                value: CharacterPreferencesScrollTarget.Always,
              })
            }
          >
            Always
          </Button.Checkbox>
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={
              data.scrollWheelTargeting ===
              CharacterPreferencesScrollTarget.Hover
            }
            onClick={() =>
              act('update-scrollWheelTargeting', {
                value: CharacterPreferencesScrollTarget.Hover,
              })
            }
          >
            When hovering over targeting doll
          </Button.Checkbox>
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={
              data.scrollWheelTargeting ===
              CharacterPreferencesScrollTarget.Never
            }
            onClick={() =>
              act('update-scrollWheelTargeting', {
                value: CharacterPreferencesScrollTarget.Never,
              })
            }
          >
            Never
          </Button.Checkbox>
        </Box>
      </LabeledList.Item>
    </>
  );
};

export const GraphicsSettings = () => {
  const { settings, setSetting } = useClientSetting();
  const { act, data } = useBackend<CharacterPreferencesData>();
  return (
    <>
      <LabeledList.Item label="Framerate">
        <ClientChoice
          setting="fps"
          options={[
            ['velvety', 'Velvety (90fps, higher end PCs)'],
            ['creamy', 'Creamy (67fps, high end PCs)'],
            ['smooth', 'Smooth (40fps, default)'],
            ['chunky', 'Chunky (25fps, low end PCs)'],
          ]}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Screen">
        <Box mb="5px">
          <Button.Checkbox
            checked={!!settings.widescreen}
            onClick={() => setSetting('widescreen', 1)}
          >
            Widescreen
          </Button.Checkbox>
          <Button.Checkbox
            checked={!settings.widescreen}
            onClick={() => setSetting('widescreen', 0)}
          >
            Square
          </Button.Checkbox>
        </Box>
        <Box mb="5px">
          <Button.Checkbox
            checked={!settings.horizontal_split}
            onClick={() => setSetting('horizontal_split', 0)}
          >
            Vertical split
          </Button.Checkbox>
          <Button.Checkbox
            checked={!!settings.horizontal_split}
            onClick={() => setSetting('horizontal_split', 1)}
          >
            Horizontal split
          </Button.Checkbox>
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="Icon Size">
        <Box style={{ columns: 2 }}>
          <ClientChoice
            setting="icon_size"
            options={[
              ['0', 'Stretch to fit'],
              ['32', '32x32'],
              ['56', '56x56'],
              ['64', '64x64'],
              ['88', '88x88'],
              ['96', '96x96'],
              ['128', '128x128'],
            ]}
          />
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="Stretch Mode">
        <Box style={{ columns: 2 }}>
          <ClientChoice
            setting="zoom_mode"
            options={[
              ['distort', 'Distort (sharp pixels)'],
              ['normal', 'Blend (smooth)'],
            ]}
          />
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="Window">
        <ClientToggle setting="fullscreen">Fullscreen</ClientToggle>
        <ClientToggle setting="dark_mode">Dark mode</ClientToggle>
        <ClientToggle
          setting="hide_menu"
          tooltip="Hides the top menu bar. Use the Menu button in the top right to bring it back."
        >
          Hide top menu bar
        </ClientToggle>
      </LabeledList.Item>
      <LabeledList.Item label="Effects">
        <Box style={{ columns: 2 }}>
          <ClientToggle setting="depth_shadow">Depth shadowing</ClientToggle>
          <ClientToggle setting="distortion">Distortion</ClientToggle>
          <ClientToggle setting="parallax">Parallax</ClientToggle>
          <ClientToggle
            setting="view_tint"
            tooltip="Tints your view to match the glasses or visors you're wearing."
          >
            View tint
          </ClientToggle>
          <ClientToggle setting="camera_recoil">Camera recoil</ClientToggle>
          <Box mb="5px">
            <Button onClick={() => act('update-saturation')}>
              Saturation: {Math.round(data.saturation * 100)}%
            </Button>
          </Box>
        </Box>
      </LabeledList.Item>
    </>
  );
};

export const AccessibilitySettings = () => (
  <>
    <LabeledList.Item
      label="Colorblind Mode"
      tooltip="Shifts colors your type of colorblindness affects into ones you can (hopefully) tell apart."
    >
      <ClientChoice
        setting="colorblind"
        options={[
          ['none', 'None'],
          ['protanopia', 'Protanopia'],
          ['deuteranopia', 'Deuteranopia'],
          ['tritanopia', 'Tritanopia'],
        ]}
      />
    </LabeledList.Item>
    <LabeledList.Item label="Screen Flashes">
      <ClientToggle
        setting="dark_screenflashes"
        tooltip="Flashes, such as from flashbangs, darken your screen instead of whiting it out."
      >
        Dark screen flashes
      </ClientToggle>
    </LabeledList.Item>
  </>
);

export const AudioSettings = () => {
  const { act, data } = useBackend<CharacterPreferencesData>();
  return (
    <>
      {data.volumeChannels.map((channel, index) => (
        <LabeledList.Item
          key={channel.name}
          label={channel.name}
          tooltip={channel.description}
        >
          <Box
            onContextMenu={(e) => {
              e.preventDefault();
              act('update-volume', {
                channel: index,
                value: Math.round(channel.default * 100),
              });
            }}
          >
            <Slider
              value={Math.round(channel.volume * 100)}
              minValue={0}
              maxValue={200}
              step={1}
              unit="%"
              onChange={(_e, value) =>
                act('update-volume', { channel: index, value })
              }
            />
          </Box>
        </LabeledList.Item>
      ))}
      <LabeledList.Item>
        <Button.Confirm onClick={() => act('reset-volumes')}>
          Reset all volumes
        </Button.Confirm>
        <Box inline ml={1} color="label">
          Right-click a slider to reset just that channel.
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="Mute">
        <ClientToggle setting="mute_all">Disable game audio</ClientToggle>
        <ClientToggle setting="mute_speech">Disable speech audio</ClientToggle>
        <ClientToggle setting="mute_vox">
          Disable VOX and Dectalk audio
        </ClientToggle>
      </LabeledList.Item>
    </>
  );
};
