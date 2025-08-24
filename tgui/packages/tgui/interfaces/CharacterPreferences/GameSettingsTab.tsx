/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { Box, Button, Image, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  CharacterPreferencesData,
  CharacterPreferencesScrollTarget,
  CharacterPreferencesTooltip,
} from './type';

export const GameSettingsTab = () => {
  const { act, data } = useBackend<CharacterPreferencesData>();

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item
          label="Popup Font Size"
          buttons={
            <Button onClick={() => act('update-fontSize', { reset: 1 })}>
              Reset
            </Button>
          }
        >
          <Box mb="5px" color="label">
            Changes the font size used in popup windows. Only works when CHUI is
            disabled.
          </Box>
          <Button onClick={() => act('update-fontSize')}>
            {data.fontSize ? data.fontSize + '%' : 'Default'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Messages">
          <Box mb="5px" color="label">
            Toggles if certain messages are shown in the chat window by default.
            You can change these mid-round by using the Toggle OOC/LOOC commands
            under the Commands tab in the top right.
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
        <LabeledList.Item label="HUD Theme">
          <Box mb="5px">
            <Button onClick={() => act('update-hudTheme')}>Change</Button>
          </Box>
          <Box>
            <Image
              src={`data:image/png;base64,${data.hudThemePreview}`}
              width="32px"
              height="32px"
            />
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Targeting Cursor">
          <Box mb="5px">
            <Button onClick={() => act('update-targetingCursor')}>
              Change
            </Button>
          </Box>
          <Box>
            <Image
              src={`data:image/png;base64,${data.targetingCursorPreview}`}
              width="32px"
              height="32px"
            />
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Tooltips">
          <Box mb="5px" color="label">
            Tooltips can appear when hovering over items. These tooltips can
            provide bits of information about the item, such as attack strength,
            special moves, etc.
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={
                data.tooltipOption === CharacterPreferencesTooltip.Always
              }
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
            TGUI is the UI framework we use for some game windows, and it comes
            with options!
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
        <LabeledList.Item label="Popups">
          <Box mb="5px" color="label">
            These options toggle the popups that appear when logging in and at
            the end of a round.
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
          <Box color="label">
            Familiar with /tg/station controls? You can enable/disable them
            under the Game/Interface menu in the top left.
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Scroll Targeting">
          <Box mb="5px" color="label">
            This option allows you to change which limb to target with the
            scroll wheel.
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
      </LabeledList>
    </Section>
  );
};
