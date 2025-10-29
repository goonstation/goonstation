/**
 * Copyright (c) 2024 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { BooleanLike } from 'common/react';
import {
  Button,
  Collapsible,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { ColorButton } from '../components';
import { Window } from '../layouts';

interface AmbientLightProps {
  id: string;
  byondRef: string;
  active: BooleanLike;
  speed: number;
  cycle: number;
  time: number;
  color;
  advanced;
  samples: Array<string>;
}

interface AmbientTerrainifyProps {
  color1;
  color2;
}

interface AmbientPlanetProps {
  color1;
  cycle1: number;
  color2;
  cycle2: number;
}

interface AmbientAdvancedProps {
  byondRef: string;
  advanced: AmbientTerrainifyProps | AmbientPlanetProps | null;
}

type AmbientViewerData = {
  controllers: Array<AmbientLightProps>;
};

const AmbientTerrainify = (props: AmbientAdvancedProps) => {
  const { act } = useBackend();

  return (
    <Collapsible title="Terrainify Settings">
      <LabeledList>
        <LabeledList.Item label="Color 1">
          <ColorButton
            color={props.advanced?.color1}
            onClick={() =>
              act('modify_color', {
                byondRef: props.byondRef,
                type: 'color1',
                value: props.advanced?.color1,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Color 2">
          <ColorButton
            color={props.advanced?.color2}
            onClick={() =>
              act('modify_color', {
                byondRef: props.byondRef,
                type: 'color2',
                value: props.advanced?.color2,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Collapsible>
  );
};

const AmbientSources = (props: AmbientViewerData) => {
  const { act } = useBackend();

  return Object.entries(props.controllers).map(([source_key, sourceData]) => (
    <Section
      key={source_key}
      title={source_key}
      buttons={
        <Button
          icon="wand-magic-sparkles"
          tooltip="Effect"
          onClick={() => act('effect', { byondRef: sourceData.byondRef })}
        />
      }
    >
      <Collapsible
        style={{
          background: `linear-gradient(to right, ${[sourceData.samples].map((txt) => txt)})`,
        }}
      >
        <LabeledList>
          <LabeledList.Item label="Active">
            <Button.Checkbox
              checked={sourceData.active}
              icon={!sourceData.active ? 'pause' : 'play'}
              onClick={() =>
                act('modify', {
                  byondRef: sourceData.byondRef,
                  type: 'active',
                  value: !sourceData.active,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Speed">
            <NumberInput
              value={sourceData.speed}
              minValue={0}
              maxValue={100}
              step={0.1}
              format={(value) => toFixed(value, 1)}
              unit="x"
              width="80px"
              tickWhileDragging
              onChange={(value) =>
                act('modify', {
                  byondRef: sourceData.byondRef,
                  type: 'speed',
                  value: value,
                })
              }
            />
          </LabeledList.Item>

          <LabeledList.Item label="Cycle">
            <NumberInput
              value={sourceData.cycle}
              minValue={0}
              maxValue={1440}
              step={1}
              unit="Min"
              width="80px"
              tickWhileDragging
              onChange={(value) =>
                act('modify', {
                  byondRef: sourceData.byondRef,
                  type: 'cycle',
                  value: value,
                })
              }
            />
          </LabeledList.Item>

          <LabeledList.Item label="Time">
            <NumberInput
              value={sourceData.time}
              minValue={0}
              maxValue={sourceData.cycle}
              step={1}
              format={(value) => toFixed(value, 1)}
              unit="Min"
              width="80px"
              tickWhileDragging
              onChange={(value) =>
                act('modify', {
                  byondRef: sourceData.byondRef,
                  type: 'time',
                  value: value,
                })
              }
            />
          </LabeledList.Item>

          <LabeledList.Item label="Color">
            <ColorButton
              color={sourceData.color}
              onClick={() =>
                act('modify_color', {
                  byondRef: sourceData.byondRef,
                  type: 'color_picker',
                  value: sourceData.color,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item />
        </LabeledList>
        {sourceData.advanced ? (
          <AmbientTerrainify
            byondRef={sourceData.byondRef}
            advanced={sourceData.advanced}
          />
        ) : (
          ''
        )}
      </Collapsible>
    </Section>
  ));
};

export const AmbientViewer = () => {
  const { data } = useBackend<AmbientViewerData>();

  return (
    <Window title="Ambient Viewer" width={500} height={800}>
      <Window.Content scrollable>
        <AmbientSources controllers={data.controllers} />
      </Window.Content>
    </Window>
  );
};
