/**
 * Copyright (c) 2021 @Azrun
 * SPDX-License-Identifier: MIT
 */

import {
  Button,
  Divider,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { PortableBasicInfo } from './common/PortableAtmos';

const FanState = {
  Off: 0,
  In: 1,
  Out: 2,
};

const GaugeRanges: Record<string, [number, number]> = {
  good: [1, Infinity],
  average: [0.75, 1],
  bad: [-Infinity, 0.75],
};

interface PressurizerData {
  airSafe;
  blastArmed;
  blastDelay;
  connected;
  emagged;
  fanState;
  materialsCount;
  materialsProgress;
  maxArmDelay;
  maxPressure;
  maxRelease;
  minArmDelay;
  minBlastPercent;
  minRelease;
  pressure;
  processRate;
  releasePressure;
}

export const Pressurizer = () => {
  const { act, data } = useBackend<PressurizerData>();

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
    minBlastPercent,
    minRelease,
    pressure,
    processRate,
    releasePressure,
  } = data;

  const handleSetPressure = (releasePressure) => {
    act('set-pressure', {
      releasePressure,
    });
  };

  const handleSetBlastDelay = (blastDelay) => {
    act('set-blast-delay', {
      blastDelay,
    });
  };

  const handleSetProcessRate = (processRate) => {
    act('set-process_rate', {
      processRate,
    });
  };

  const handleSetFan = (fanState) => {
    act('fan', {
      fanState,
    });
  };

  const hasSufficientPressure = pressure < maxPressure * minBlastPercent;

  const getArmedState = () => {
    if (hasSufficientPressure) {
      return 'Insufficient Pressure';
    }
    if (!airSafe) {
      return 'AIR UNSAFE - Locked';
    }
    if (blastArmed) {
      return 'Armed';
    }
    return 'Ready';
  };

  const handleEjectContents = () => {
    act('eject-materials');
  };

  const handleArmPressurizer = () => {
    act('arm');
  };

  return (
    <Window theme={emagged ? 'syndicate' : 'ntos'} width={390} height={380}>
      <Window.Content>
        <PortableBasicInfo
          connected={connected}
          pressure={pressure}
          maxPressure={maxPressure}
        >
          <LabeledList>
            <LabeledList.Item label="Emergency Blast Release">
              <Button
                fluid
                textAlign="center"
                icon="circle"
                disabled={hasSufficientPressure || !airSafe}
                color={blastArmed ? 'bad' : 'average'}
                onClick={() => handleArmPressurizer()}
              >
                {getArmedState()}
              </Button>
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
                step={1}
                onChange={(targetDelay) => handleSetBlastDelay(targetDelay)}
              />
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
                selected={fanState === FanState.In}
                onClick={() => handleSetFan(FanState.In)}
              >
                In
              </Button>
              <Button
                selected={fanState === FanState.Out}
                onClick={() => handleSetFan(FanState.Out)}
              >
                Out
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Release Pressure">
              <Button onClick={() => handleSetPressure(minRelease)}>Min</Button>
              <NumberInput
                animated
                width="7em"
                value={releasePressure}
                minValue={minRelease}
                maxValue={maxRelease}
                step={1}
                onChange={(targetPressure) => handleSetPressure(targetPressure)}
              />
              <Button onClick={() => handleSetPressure(maxRelease)}>Max</Button>
            </LabeledList.Item>
          </LabeledList>
        </PortableBasicInfo>
        <Section
          title="Material Processing"
          buttons={
            <Button
              icon="eject"
              disabled={materialsCount === 0}
              onClick={() => handleEjectContents()}
            >
              Eject
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Speed">
              <Button
                selected={processRate === 1}
                onClick={() => handleSetProcessRate(1)}
              >
                1
              </Button>
              <Button
                selected={processRate === 2}
                onClick={() => handleSetProcessRate(2)}
              >
                2
              </Button>
              <Button
                selected={processRate === 3}
                onClick={() => handleSetProcessRate(3)}
              >
                3
              </Button>
              {!!emagged && (
                <>
                  <Button
                    selected={processRate === 4}
                    onClick={() => handleSetProcessRate(4)}
                  >
                    4
                  </Button>
                  <Button
                    selected={processRate === 5}
                    onClick={() => handleSetProcessRate(5)}
                  >
                    5
                  </Button>
                </>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Progress">
              <ProgressBar
                ranges={GaugeRanges}
                value={materialsProgress / 100}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
