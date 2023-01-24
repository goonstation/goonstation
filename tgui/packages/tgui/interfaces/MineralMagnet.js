/**
 * @file
 * @copyright 2022
 * @author CodeJester (https://github.com/codeJester27)
 * @license ISC
 */

import { useBackend, useLocalState } from "../backend";
import { Box, Button, Dimmer, Divider, Flex, Icon, Modal, Section, Stack, TimeDisplay } from "../components";
import { formatTime } from "../format";
import { Window } from '../layouts';

const getMagnetCondition = (condition) => {
  if (condition >= 95) return <Box inline color="good">Optimal</Box>;
  else if (condition >= 70) return <Box inline color="olive">Mild Structural Damage</Box>;
  else if (condition >= 40) return <Box inline color="yellow">Heavy Structural Damage</Box>;
  else if (condition >= 10) return <Box inline color="average">Extreme Structural Damage</Box>;
  else return <Box inline color="bad">Destruction Imminent</Box>;
};

export const MineralMagnet = (_props, context) => {
  const { act, data } = useBackend(context);

  const { isLinked, magnetActive, magnetAutomaticMode, magnetCooldownOverride, magnetHealth, magnetLastUsed } = data;
  const { time } = data;
  const linkedMagnets = data.linkedMagnets || [];
  const miningEncounters = data.miningEncounters || [];

  const onCooldown = magnetLastUsed > time;

  const [viewEncounters, setViewEncounters] = useLocalState(context, 'viewEncounters', false);

  return (
    <Window
      width={300}
      height={240}>
      <Window.Content>
        <Section title="Magnet Status">
          <Box>
            Condition: {isLinked ? getMagnetCondition(magnetHealth) : <Box inline color="bad">No Magnet Linked</Box>}
          </Box>
          <Box>
            Status: {magnetActive ? "Pulling New Mineral Source" : (
              onCooldown ? (
                <>
                  Cooling Down: <TimeDisplay value={Math.max(magnetLastUsed - time, 0)}
                    timing
                    format={value => formatTime(value)} />
                </>
              ) : "Idle"
            )}
          </Box>
        </Section>
        <Section title="Magnet Controls"
          buttons={
            <Button
              textAlign="center"
              icon="rss"
              onClick={() => act('geoscan')}>
              Scan
            </Button>
          }>
          {(!!magnetActive || (onCooldown && !magnetCooldownOverride)) && (
            <Dimmer fontSize={1.75} pb={2}>
              {magnetActive ? "Magnet Active" : "On Cooldown"}
            </Dimmer>
          )}
          <Button
            textAlign="center"
            color={onCooldown && magnetCooldownOverride && "average"}
            icon="magnet"
            onClick={() => act('activatemagnet')}
            fluid>
            Activate Magnet
          </Button>
          <Button
            textAlign="center"
            color={onCooldown && magnetCooldownOverride && "average"}
            icon="search"
            disabled={!miningEncounters.length}
            onClick={() => setViewEncounters(true)}
            fluid>
            Activate telescope location
          </Button>
          <Button.Checkbox checked={magnetCooldownOverride}
            onClick={() => act('overridecooldown')}
            style={{ 'z-index': '1' }}>
            Override Cooldown
          </Button.Checkbox>
          <Button.Checkbox checked={magnetAutomaticMode}
            onClick={() => act('automode')}
            style={{ 'z-index': '1' }}>
            Automatic Mode
          </Button.Checkbox>
        </Section>
        {viewEncounters && (
          <Modal full
            ml={1} // For some reason modals only seem properly centered with this
            width="230px"
            height="200px">
            <Stack vertical fill>
              <Stack.Item grow>
                <Section scrollable fill>
                  {miningEncounters.map(encounter => (
                    <Button key={encounter.id}
                      onClick={() => {
                        act('activateselectable', { encounter_id: encounter.id });
                        setViewEncounters(false);
                      }}
                      fluid>
                      {encounter.name}
                    </Button>
                  ))}
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Flex>
                  <Flex.Item grow
                    pt={0.5}
                    color="label">
                    <Icon name="search" /> Choose a location
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      color="bad"
                      icon="times"
                      onClick={() => setViewEncounters(false)}>
                      Cancel
                    </Button>
                  </Flex.Item>
                </Flex>
              </Stack.Item>
            </Stack>
          </Modal>
        )}
        {!!isLinked || (
          <Modal full
            ml={1}
            width="270px"
            height="200px">
            <Section title="Choose Linked Magnet" scrollable fill>
              <Button
                textAlign="center"
                icon="rss"
                fluid
                onClick={() => act('magnetscan')}
              >
                Scan for Magnets
              </Button>
              <Divider />
              {linkedMagnets.map(magnet => (
                <Button
                  icon={magnet.angle === undefined ? "circle" : "arrow-right"}
                  iconRotation={magnet.angle ?? 0}
                  textAlign="center"
                  fluid
                  key={magnet.ref}
                  onClick={() => act('linkmagnet', magnet)}
                >
                  {`${magnet.name} at (${magnet.x}, ${magnet.y})`}
                </Button>
              ))}
            </Section>
          </Modal>
        )}
      </Window.Content>
    </Window>
  );
};
