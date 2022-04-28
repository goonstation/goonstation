/**
 * @file
 * @copyright 2022
 * @author CodeJester (https://github.com/codeJester27)
 * @license ISC
 */

import { useBackend } from "../backend";
import { Box, Button, Collapsible, Dimmer, Section, TimeDisplay } from "../components";
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

  const onCooldown = true;

  return (
    <Window
      width={300}
      height={500}>
      <Window.Content>
        <Box>
          {linkedMagnets.map(magnet => (
            <Button
              key={magnet.ref}
              onClick={() => act('linkmagnet', magnet)}
            >
              {`${magnet.name} at (${magnet.x}, ${magnet.y})`}
            </Button>
          ))}
        </Box>
        {!isLinked || (
          <>
            <Section title="Magnet Status">
              <Box>
                Condition: {getMagnetCondition(magnetHealth)}
              </Box>
              <Box>
                Status: {magnetActive ? "Pulling New Mineral Source" : (
                  onCooldown ? (
                    <>
                      Cooling Down: <TimeDisplay value={Math.max(magnetLastUsed - time, 0)}
                        timing
                        format={value => formatTime(value)} />
                    </>
                  ) : "Idle" // bless this mess
                )}
              </Box>
            </Section>
            <Section title="Magnet Controls">
              <Section textAlign="center">
                {onCooldown && !magnetCooldownOverride && (
                  <Dimmer fontSize={1.75}>
                    On Cooldown
                  </Dimmer>
                )}
                <Button
                  textAlign="center"
                  color={onCooldown && magnetCooldownOverride && "average"}
                  fluid >
                  Activate Magnet
                </Button>
                <Collapsible title="Activate telescope location"
                  textAlign="center"
                  color={onCooldown && magnetCooldownOverride && "average"} >
                  placeholder
                </Collapsible>
                <Button.Checkbox checked={magnetCooldownOverride}
                  style={{ 'z-index': '2' }}>
                  Override Cooldown
                </Button.Checkbox>

              </Section>

            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
