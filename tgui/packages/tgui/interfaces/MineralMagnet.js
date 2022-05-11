/**
 * @file
 * @copyright 2022
 * @author CodeJester (https://github.com/codeJester27)
 * @license ISC
 */

import { useBackend } from "../backend";
import { Box, Button, Collapsible, Dimmer, Divider, Icon, Section, TimeDisplay } from "../components";
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

  return (
    <Window
      width={300}
      height={364}>
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
        {isLinked ? (
          <Section title="Magnet Controls">
            <Button
              textAlign="center"
              color="teal"
              icon="rss"
              onClick={() => act('geoscan')}
              fluid >
              Scan
            </Button>
            <Section textAlign="center">
              {(!!magnetActive || (onCooldown && !magnetCooldownOverride)) && (
                <Dimmer fontSize={1.75} pb={2}>
                  {magnetActive ? "Magnet Active" : "On Cooldown"}
                </Dimmer>
              )}
              <Button
                textAlign="center"
                color={onCooldown && magnetCooldownOverride ? "average" : "purple"}
                icon="magnet"
                onClick={() => act('activatemagnet')}
                fluid >
                Activate Magnet
              </Button>
              <Collapsible title={<><Icon name="search" />Activate telescope location</>}
                textAlign="center"
                color={onCooldown && magnetCooldownOverride ? "average" : "purple"} >
                <Section height={7} pl={2} scrollable fill>
                  {miningEncounters.map(encounter => (
                    <Button key={encounter.id}
                      onClick={() => act('activateselectable', { encounter_id: encounter.id })}
                      fluid>
                      {encounter.name}
                    </Button>
                  ))}
                </Section>
              </Collapsible>
              <Button.Checkbox checked={magnetCooldownOverride}
                onClick={() => act('overridecooldown')}
                style={{ 'z-index': '2' }}>
                Override Cooldown
              </Button.Checkbox>
              <Button.Checkbox checked={magnetAutomaticMode}
                onClick={() => act('automode')}
                style={{ 'z-index': '2' }}>
                Automatic Mode
              </Button.Checkbox>
            </Section>
          </Section>
        ) : (
          <Section title="Choose Linked Magnet">
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
            <Divider />
            <Button
              textAlign="center"
              color="teal"
              icon="rss"
              fluid
              onClick={() => act('magnetscan')}
            >
              Scan for Magnets
            </Button>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
