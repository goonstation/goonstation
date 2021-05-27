import { Component } from 'inferno';
import { useBackend } from '../backend';
import { Box, Divider, Flex, Section, Button, LabeledList, NumberInput, ProgressBar } from '../components';
import { Window } from '../layouts';
import { PortableBasicInfo } from './common/PortableAtmos';

export const Pressurizer = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    pressure,
    connected,
    fanState,
    maxPressure,
    releasePressure,
    blastArmed,
    blastDelay,
    materialsCount,
    materialsProgress,
    processRate,
    minRelease,
    maxRelease,
    minArmDelay,
    maxArmDelay,
    emagged,
  } = data;

  const FanState = {
    Off: 0,
    In: 1,
    Out: 2,
  };

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
    if (blastArmed)
    { return "Armed"; }
    else
    { return "Not Armed"; }

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
      height={410}>
      <Window.Content>
        <Flex>
          <Flex.Item width="900px">
            <PortableBasicInfo
              connected={connected}
              pressure={pressure}
              maxPressure={maxPressure}>
              <Divider />
              <LabeledList>
                <LabeledList.Item label="Emergency Blast Release" >
                  <Button
                    fluid
                    textAlign="center"
                    icon="circle"
                    content={getArmedState()}
                    disabled={pressure<maxPressure*0.2}
                    color={blastArmed ? 'bad' : 'average'}
                    onClick={() => handleArmPressurizer()} />
                </LabeledList.Item>
                <LabeledList.Item label="Delay">
                  <Button
                    onClick={() => handleSetBlastDelay(minArmDelay)}
                    content="Min" />
                  <NumberInput
                    animated
                    width="7em"
                    value={blastDelay}
                    minValue={minArmDelay}
                    maxValue={maxArmDelay}
                    onChange={(e, targetDelay) => handleSetBlastDelay(targetDelay)} />
                  <Button
                    onClick={() => handleSetBlastDelay(maxArmDelay)}
                    content="Max" />
                </LabeledList.Item>
              </LabeledList>

              <Divider />
              <LabeledList>
                <LabeledList.Item label="Fan Status">
                  <Button
                    content="Off"
                    color={fanState === FanState.Off ? 'bad' : 'default'}
                    onClick={() => handleSetFan(FanState.Off)} />
                  <Button
                    content="In"
                    color={fanState === FanState.In ? 'good' : 'default'}
                    onClick={() => handleSetFan(FanState.In)} />
                  <Button
                    content="Out"
                    color={fanState === FanState.Out ? 'good' : 'default'}
                    onClick={() => handleSetFan(FanState.Out)} />
                </LabeledList.Item>
                <LabeledList.Item label="Release pressure">
                  <Button
                    onClick={() => handleSetPressure(minRelease)}
                    content="Min" />
                  <NumberInput
                    animated
                    width="7em"
                    value={releasePressure}
                    minValue={minRelease}
                    maxValue={maxRelease}
                    onChange={(e, targetPressure) => handleSetPressure(targetPressure)} />
                  <Button
                    onClick={() => handleSetPressure(maxRelease)}
                    content="Max" />
                </LabeledList.Item>
              </LabeledList>
            </PortableBasicInfo>
            <Section
              title="Material Processing"
              minHeight="90px"
              buttons={(
                <Button
                  icon="eject"
                  content="Eject"
                  disabled={!materialsCount}
                  onClick={() => handleEjectContents()} />
              )}>
              <LabeledList.Item label="Speed">
                <Button
                  content="1"
                  color={processRate === 1 ? 'good' : 'default'}
                  onClick={() => handleSetProcessRate(1)} />
                <Button
                  content="2"
                  color={processRate === 2 ? 'good' : 'default'}
                  onClick={() => handleSetProcessRate(2)} />
                <Button
                  content="3"
                  color={processRate === 3 ? 'good' : 'default'}
                  onClick={() => handleSetProcessRate(3)} />
                { !!emagged && (<Button
                  content="4"
                  color={processRate === 4 ? 'good' : 'default'}
                  onClick={() => handleSetProcessRate(4)} />)}
                { !!emagged && <Button
                  content="5"
                  color={processRate === 5 ? 'good' : 'default'}
                  onClick={() => handleSetProcessRate(5)} /> }
              </LabeledList.Item>
              <LabeledList>
                <LabeledList.Item label="Progress" />
              </LabeledList>
              <ProgressBar
                mt="0.5em"
                ranges={{
                  good: [1, Infinity],
                  average: [0.75, 1],
                  bad: [-Infinity, 0.75],
                }}
                value={materialsProgress/100} />
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
