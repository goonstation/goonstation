/**
 * @file
 * @copyright 2020
 * @author ThePotato97 (https://github.com/ThePotato97)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useState } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  Icon,
  Input,
  Modal,
  NumberInput,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import {
  MatterState,
  MatterStateIconMap,
  Reagent,
  ReagentContainer,
  ReagentGraph,
  ReagentList,
} from './common/ReagentInfo';
import { capitalize } from './common/stringUtils';
import {
  getTemperatureColor,
  getTemperatureIcon,
} from './common/temperatureUtils';

interface ChemDispenserData {
  beakerName: string;
  container: ReagentContainer | null;
  dispensableReagents: Reagent[];
  groupList: {
    name: string;
    info: string;
    ref: string;
  }[];
  idCardInserted: BooleanLike;
  idCardName: string;
  isRecording: BooleanLike;
  activeRecording: string;
}

const sortMap = [
  {
    id: 0,
    icon: 'sort-amount-down',
    contents: '',
    compareFunction: (a: Reagent, b: Reagent) => b.volume - a.volume,
  },
  {
    id: 1,
    icon: 'sort-amount-up',
    contents: '',
    compareFunction: (a: Reagent, b: Reagent) => a.volume - b.volume,
  },
  {
    id: 2,
    contents: 'Density',
    compareFunction: (a: Reagent, b: Reagent) =>
      (a.state ?? MatterState.Solid) - (b.state ?? MatterState.Solid),
  },
  {
    id: 3,
    contents: 'Order Added',
    compareFunction: () => 1,
  },
];

export const ChemDispenser = () => {
  return (
    <Window width={570} height={730} theme="ntos">
      <Window.Content scrollable>
        <ReagentDispenser />
        <Beaker />
        <BeakerContentsGraph />
        <ChemGroups />
      </Window.Content>
    </Window>
  );
};

const sectionTitleResetProps = {
  style: {
    fontWeight: 'normal',
  },
};

export const ReagentDispenser = () => {
  const { act, data } = useBackend<ChemDispenserData>();
  const { beakerName = 'beaker', container } = data;
  const [addAmount, setAddAmount] = useSharedState('addAmount', 10);
  const [iconToggle, setIconToggle] = useSharedState('iconToggle', false);
  const [hoverOverId, setHoverOverId] = useState('');

  const dispensableReagents = data.dispensableReagents || [];

  return (
    <Section
      position="relative"
      title={
        <Stack align="center">
          <Stack.Item>Dispense</Stack.Item>
          <Stack.Item grow>
            <Stack justify="center" align="center">
              <Stack.Item>Icons:</Stack.Item>
              <Stack.Item>
                <Button
                  width={2}
                  textAlign="center"
                  backgroundColor="rgba(0, 0, 0, 0)"
                  textColor={
                    iconToggle
                      ? 'rgba(255, 255, 255, 0.5)'
                      : 'rgba(255, 255, 255, 1)'
                  }
                  onClick={() => setIconToggle(false)}
                >
                  <Icon mr={1} name={'circle'} />
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  width={2}
                  backgroundColor="rgba(0, 0, 0, 0)"
                  textColor={
                    iconToggle
                      ? 'rgba(255, 255, 255, 1)'
                      : 'rgba(255, 255, 255, 0.5)'
                  }
                  onClick={() => setIconToggle(true)}
                >
                  <Icon name="tint" />
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item {...sectionTitleResetProps}>
            <Stack align="center">
              <Stack.Item>Dispense Amount:</Stack.Item>
              <Stack.Item>
                <NumberInput
                  value={addAmount}
                  format={(value: number) => `${value}u`}
                  width={'4'}
                  minValue={1}
                  maxValue={100}
                  step={1}
                  onDrag={(value: number) => setAddAmount(value)}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      }
    >
      {(!container || container.maxVolume === container.totalVolume) && (
        <Modal fontSize={2} mr={2}>
          {container
            ? `${capitalize(beakerName)} Full`
            : `No ${capitalize(beakerName)} Inserted`}
        </Modal>
      )}
      <Stack vertical>
        <Stack.Item>
          {dispensableReagents.map((reagent, reagentIndex) => (
            <Button
              key={reagentIndex}
              className="chem-dispenser__dispense-buttons"
              align="left"
              width="130px"
              onMouseOver={() => setHoverOverId(reagent.id)}
              onMouseLeave={() => setHoverOverId('')}
              onClick={() => {
                act('dispense', {
                  amount: addAmount,
                  reagentId: reagent.id,
                });
              }}
              disabled={container?.maxVolume === container?.totalVolume}
            >
              <Icon
                color={`rgba(${reagent.colorR},${reagent.colorG},${reagent.colorB}, 1)`}
                name={
                  iconToggle
                    ? MatterStateIconMap[reagent.state ?? MatterState.Solid]
                        .icon
                    : 'circle'
                }
                style={{
                  textShadow: '0 0 3px #000',
                }}
                mr={1}
              />
              {reagent.name}
            </Button>
          ))}
        </Stack.Item>
        <Stack.Item>{`Reagent ID: ${hoverOverId}`}</Stack.Item>
      </Stack>
    </Section>
  );
};

export const Beaker = () => {
  const { act, data } = useBackend<ChemDispenserData>();
  const { beakerName, container } = data;

  const [iconToggle] = useSharedState('iconToggle', false);
  const [removeAmount, setRemoveAmount] = useSharedState('removeAmount', 10);
  const removeReagentButtons = [removeAmount, 10, 5, 1];

  return (
    <Section
      title={
        <Stack>
          <Stack.Item grow>
            <Button icon="eject" onClick={() => act('eject')}>
              {!container
                ? `Insert ${capitalize(beakerName)}`
                : `Eject ${container.name} (${container.totalVolume}/${container.maxVolume})`}
            </Button>
          </Stack.Item>
          <Stack.Item {...sectionTitleResetProps}>
            <Stack align="center">
              <Stack.Item>Remove Amount:</Stack.Item>
              <Stack.Item>
                <NumberInput
                  width={'4'}
                  format={(value: number) => `${value}u`}
                  value={removeAmount}
                  minValue={1}
                  maxValue={100}
                  step={1}
                  onDrag={(value: number) => setRemoveAmount(value)}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      }
    >
      <ReagentList
        container={container}
        height="auto"
        showState={iconToggle}
        renderButtons={(reagent) => (
          <>
            <Button
              icon="filter"
              onClick={() => {
                act('isolate', {
                  reagentId: reagent.id,
                });
              }}
            >
              Isolate
            </Button>
            <Button
              icon="minus"
              onClick={() => {
                act('all', {
                  amount: removeAmount,
                  reagentId: reagent.id,
                });
              }}
            >
              All
            </Button>
            {removeReagentButtons.map((amount, indexButtons) => (
              <Button
                key={indexButtons}
                icon="minus"
                onClick={() => {
                  act('remove', {
                    amount: amount,
                    reagentId: reagent.id,
                  });
                }}
              >
                {amount}
              </Button>
            ))}
          </>
        )}
        renderButtonsDeps={removeAmount}
      />
    </Section>
  );
};

export const BeakerContentsGraph = () => {
  const { data } = useBackend<ChemDispenserData>();
  const [sort, setSort] = useSharedState('sort', 1);
  const { container } = data;
  return (
    <Section>
      <Stack vertical>
        <Stack.Item>
          <Tabs>
            {sortMap.map((sortBy) => (
              <Tabs.Tab
                key={sortBy.id}
                selected={sort === sortBy.id}
                textAlign="center"
                onClick={() => setSort(sortBy.id)}
              >
                {sortBy.icon && <Icon name={sortBy.icon} />}
                {sortBy.contents}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        <Stack.Item>
          <ReagentGraph
            container={container}
            sort={sortMap[sort].compareFunction}
          />
        </Stack.Item>
        {!!container?.totalVolume && (
          <Stack.Item>
            <Box
              textAlign="center"
              fontSize={2}
              color={getTemperatureColor(container.temperature)}
            >
              <Icon name={getTemperatureIcon(container.temperature)} mr={0.5} />
              <AnimatedNumber value={container.temperature ?? 0} /> K
            </Box>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

export const ChemGroups = () => {
  const { act, data } = useBackend<ChemDispenserData>();
  const [groupName, setGroupName] = useState('');
  const [reagents, setReagents] = useState('');
  const {
    groupList,
    idCardName,
    idCardInserted,
    isRecording,
    activeRecording,
  } = data;

  return (
    <>
      <Section
        title="Reagent Groups"
        buttons={
          <>
            <Button icon="eject" onClick={() => act('card')}>
              {idCardInserted ? `Eject ID: ${idCardName}` : 'Insert ID'}
            </Button>
            <Button color="red" icon="circle" onClick={() => act('record')}>
              {isRecording ? 'Stop' : 'Record'}
            </Button>
            <Button
              color="bad"
              icon="eraser"
              disabled={!activeRecording}
              onClick={() => act('clear_recording')}
            >
              Clear
            </Button>
          </>
        }
      >
        <Stack vertical>
          <Stack.Item>
            <Input
              placeholder="Group Name"
              value={groupName}
              onInput={(value: string) => setGroupName(value)}
            />
            <Button
              icon="plus-circle"
              onClick={() => {
                act('newGroup', { reagents, groupName });
                setGroupName('');
                setReagents('');
              }}
            >
              Add Group
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Box
              italic={!activeRecording}
              color={!activeRecording ? 'grey' : undefined}
            >
              {activeRecording || 'Recording Empty'}
            </Box>
          </Stack.Item>
        </Stack>
      </Section>
      {!!groupList.length && (
        <Section>
          {groupList.map((group, index) => (
            <Box key={index}>
              <Button
                icon="tint"
                onClick={() => {
                  act('groupDispense', {
                    selectedGroup: group.ref,
                  });
                }}
              >
                {group.name}
              </Button>
              <Button
                icon="trash"
                onClick={() => {
                  act('deleteGroup', {
                    selectedGroup: group.ref,
                  });
                }}
              >
                Delete
              </Button>
              {' ' + group.info}
            </Box>
          ))}
        </Section>
      )}
    </>
  );
};
