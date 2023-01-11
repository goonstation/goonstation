
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Section, Stack, Button, Box, ProgressBar } from '../../components';
import { PortableHoldingTank } from '../common/PortableAtmos';
import { LocalGeneratorData } from './type';

export const LocalGenerator = (props, context) => {
  const { act, data } = useBackend<LocalGeneratorData>(context);

  const {
    name,
    holding,
    internalCell,
    connectedAPC,
    chargeAPC,
    boltsStatus,
    generatorStatus,
  } = data;

  const handleToggleBolts = () => {
    act("toggle-bolts");
  };

  const handleToggleGenerator = () => {
    act("toggle-generator");
  };

  const handleSwapChargeTarget = () => {
    act("swap-target");
  };

  const handleEjectTank = () => {
    act("eject-tank");
  };

  const handleEjectCell = () => {
    act("eject-cell");
  };

  const handleConnectAPC = () => {
    act("connect-APC");
  };

  return (
    <Window title={name} width={300} height={470}>
      <Window.Content>
        <Stack vertical>
          <Section title="Generator">
            <Stack vertical>
              <Stack.Item>
                <Stack align="baseline">
                  <Stack.Item basis="50%">
                    <Button
                      width={11.4}
                      onClick={() => handleToggleBolts()}
                      icon={boltsStatus ? ("toggle-on") : ("toggle-off")}>
                      Toggle Floor Bolts
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    Status:
                  </Stack.Item>
                  {boltsStatus ? (
                    <Stack.Item color="good">
                      ACTIVE
                    </Stack.Item>
                  ) : (
                    <Stack.Item color="average">
                      INACTIVE
                    </Stack.Item>
                  )}
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Stack align="baseline">
                  <Stack.Item basis="50%">
                    <Button
                      width={11.4}
                      onClick={() => handleToggleGenerator()}
                      icon={generatorStatus ? ("toggle-on") : ("toggle-off")}>
                      Toggle Generator
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    Status:
                  </Stack.Item>
                  {generatorStatus ? (
                    <Stack.Item color="good">
                      ACTIVE
                    </Stack.Item>
                  ) : (
                    <Stack.Item color="average">
                      INACTIVE
                    </Stack.Item>
                  )}
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Stack align="baseline">
                  <Stack.Item basis="50%">
                    <Button
                      width={11.4}
                      onClick={() => handleSwapChargeTarget()}
                      icon="bolt">
                      Change Target
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    Target:
                  </Stack.Item>
                  {chargeAPC ? (
                    <Stack.Item color="good">
                      APC
                    </Stack.Item>
                  ) : (
                    <Stack.Item color="good">
                      CELL
                    </Stack.Item>
                  )}
                </Stack>
              </Stack.Item>
            </Stack>
          </Section>
          <PortableHoldingTank
            holding={holding}
            onEjectTank={handleEjectTank} />
          <Section
            title="Internal Cell"
            height={7.25}
            buttons={(
              <Button
                icon="eject"
                disabled={!internalCell}
                onClick={() => handleEjectCell()}>
                Eject
              </Button>
            )}>
            {internalCell ? (
              <Stack vertical>
                <Stack.Item>
                  <Box>
                    {internalCell.name}
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <ProgressBar value={internalCell.chargePercent}
                    minValue={0}
                    maxValue={100}
                    color={internalCell.chargePercent < 20 ? "red" : internalCell.chargePercent < 50 ? "yellow" : "green"} />
                </Stack.Item>
              </Stack>
            ) : (
              <Box
                color="average">
                No cell
              </Box>)}
          </Section>
          <Section
            title="Local APC"
            height={7.25}
            buttons={(
              <Button
                icon="wifi"
                disabled={!holding}
                onClick={() => handleConnectAPC()}>
                Connect
              </Button>
            )}>
            {connectedAPC ? (
              <Stack vertical>
                <Stack.Item>
                  <Box>
                    {connectedAPC.name}
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <ProgressBar value={connectedAPC.chargePercent}
                    minValue={0}
                    maxValue={100}
                    color={connectedAPC.chargePercent < 20 ? "red" : connectedAPC.chargePercent < 50 ? "yellow" : "green"} />
                </Stack.Item>
              </Stack>
            ) : (
              <Box
                color="average">
                No connected APC
              </Box>)}
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
