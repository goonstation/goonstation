import { useBackend } from '../backend';
import { Button, Divider, Flex, LabeledList, NumberInput, ProgressBar, Section } from '../components';
import { Window } from '../layouts';
import { PortableBasicInfo } from './common/PortableAtmos';

const FanState = {
  Off: 0,
  In: 1,
  Out: 2,
};

export const Pressurizer = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    airSafe,
    blastArmed,
    blastDelay,
    connected,
    emagged,
    fanState,
    materialsCount,
    materialsProgress,
    maxArmDelay,
    maxPressure,
    maxRelease,
    minArmDelay,
    minRelease,
    pressure,
    processRate,
    releasePressure,
  } = data;

  const handleSetPressure = releasePressure => {
    act("set-pressure", {
      releasePressure,
    });
  };

  const handleSetBlastDelay = blastDelay => {
    act("set-blast-delay", {
      blastDelay,
    });
  };

  const handleSetProcessRate = processRate => {
    act("set-process_rate", {
      processRate,
    });
  };

  const handleSetFan = fanState => {
    act("fan", {
      fanState,
    });
  };

  const getArmedState = () => {
    if (pressure < maxPressure * 0.2) {
      return "Insufficient Pressure";
    }
    if (!airSafe) {
      return "AIR UNSAFE - Locked";
    }
    if (blastArmed) {
      return "Armed";
    }
    return "Ready";
  };

  const handleEjectContents = () => {
    act("eject-materials");
  };

  const handleArmPressurizer = () => {
    act("arm");
  };

  return (
    <Window
      theme={emagged ? 'syndicate' : 'ntos'}
      width={390}
      height={390}>
      <Window.Content>
        <Flex>
          <Flex.Item>
            <PortableBasicInfo
              connected={connected}
              pressure={pressure}
              maxPressure={maxPressure}>
              <Divider />
              <LabeledList>
                <LabeledList.Item label="Emergency Blast Release">
                  <Button
                    fluid
                    textAlign="center"
                    icon="circle"
                    content={getArmedState()}
                    disabled={pressure<maxPressure*0.2 || !airSafe}
                    color={blastArmed ? 'bad' : 'average'}
                    onClick={() => handleArmPressurizer()} />
                </LabeledList.Item>
                <LabeledList.Item label="Delay">
                  <Button onClick={() => handleSetBlastDelay(minArmDelay)}>
                    Min
                  </Button>
                  <NumberInput
                    animated
                    width="7em"
                    value={blastDelay}
                    minValue={minArmDelay}
                    maxValue={maxArmDelay}
                    onChange={(e, targetDelay) => handleSetBlastDelay(targetDelay)} />
                  <Button onClick={() => handleSetBlastDelay(maxArmDelay)}>
                    Max
                  </Button>
                </LabeledList.Item>
              </LabeledList>
              <Divider />
              <LabeledList>
                <LabeledList.Item label="Fan Status">
                  <Button
                    color={fanState === FanState.Off ? 'bad' : 'default'}
                    onClick={() => handleSetFan(FanState.Off)}
                  >
                    Off
                  </Button>
                  <Button
                    color={fanState === FanState.In ? 'good' : 'default'}
                    onClick={() => handleSetFan(FanState.In)}
                  >
                    In
                  </Button>
                  <Button
                    color={fanState === FanState.Out ? 'good' : 'default'}
                    onClick={() => handleSetFan(FanState.Out)}
                  >
                    Out
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Release Pressure">
                  <Button onClick={() => handleSetPressure(minRelease)}>
                    Min
                  </Button>
                  <NumberInput
                    animated
                    width="7em"
                    value={releasePressure}
                    minValue={minRelease}
                    maxValue={maxRelease}
                    onChange={(e, targetPressure) => handleSetPressure(targetPressure)} />
                  <Button onClick={() => handleSetPressure(maxRelease)}>
                    Max
                  </Button>
                </LabeledList.Item>
              </LabeledList>
            </PortableBasicInfo>
            <Section
              title="Material Processing"
              minHeight="90px"
              buttons={(
                <Button
                  icon="eject"
                  disabled={!materialsCount}
                  onClick={() => handleEjectContents()}>
                  Eject
                </Button>
              )}>
              <LabeledList>
                <LabeledList.Item label="Speed">
                  <Button color={processRate === 1 ? 'good' : 'default'}
                    onClick={() => handleSetProcessRate(1)}>
                    1
                  </Button>
                  <Button color={processRate === 2 ? 'good' : 'default'}
                    onClick={() => handleSetProcessRate(2)}>
                    2
                  </Button>
                  <Button color={processRate === 3 ? 'good' : 'default'}
                    onClick={() => handleSetProcessRate(3)}>
                    3
                  </Button>
                  { !!emagged && (<Button
                    content="4"
                    color={processRate === 4 ? 'good' : 'default'}
                    onClick={() => handleSetProcessRate(4)} />)}
                  { !!emagged && <Button
                    content="5"
                    color={processRate === 5 ? 'good' : 'default'}
                    onClick={() => handleSetProcessRate(5)} /> }
                </LabeledList.Item>
                <LabeledList.Item label="Progress">
                  <ProgressBar
                    mt="0.5em"
                    ranges={{
                      good: [1, Infinity],
                      average: [0.75, 1],
                      bad: [-Infinity, 0.75],
                    }}
                    value={materialsProgress/100} />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
