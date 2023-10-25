/**
* @file
* @copyright 2020
* @author ThePotato97 (https://github.com/ThePotato97)
* @license ISC
*/

import { BooleanLike } from "common/react";
import { useBackend, useLocalState, useSharedState } from "../backend";
import { AnimatedNumber, Box, Button, Icon, Input, Modal, NumberInput, Section, Table, Tabs } from "../components";
import { Window } from "../layouts";
import { MatterStateIconMap, Reagent, ReagentContainer, ReagentGraph, ReagentList } from "./common/ReagentInfo";
import { getTemperatureColor, getTemperatureIcon } from './common/temperatureUtils';

type ChemDispenserData = {
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
};

const sortMap = [
  {
    id: 0,
    icon: "sort-amount-down",
    contents: "",
    compareFunction: (a: Reagent, b: Reagent) => b.volume - a.volume,
  },
  {
    id: 1,
    icon: "sort-amount-up",
    contents: "",
    compareFunction: (a: Reagent, b: Reagent) => a.volume - b.volume,
  },
  {
    id: 2,
    contents: "Density",
    compareFunction: (a: Reagent, b: Reagent) => a.state - b.state,
  },
  {
    id: 3,
    contents: "Order Added",
    compareFunction: () => 1,
  },
];

export const ChemDispenser = (props, context) => {
  return (
    <Window
      width={570}
      height={730}
      theme="ntos">
      <Window.Content scrollable>
        <Box>
          <ReagentDispenser />
          <Beaker />
          <BeakerContentsGraph />
          <ChemGroups />
        </Box>
      </Window.Content>
    </Window>
  );
};

export const ReagentDispenser = (props, context) => {
  const { act, data } = useBackend<ChemDispenserData>(context);
  const { beakerName, container } = data;
  const [addAmount, setAddAmount] = useSharedState(context, 'addAmount', 10);
  const [iconToggle, setIconToggle] = useSharedState(context, 'iconToggle', false);
  const [hoverOverId, setHoverOverId] = useLocalState(context, 'hoverOver', "");

  const dispensableReagents = data.dispensableReagents || [];

  return (
    <Section
      fontSize="12px"
      title={(
        <>
          Dispense
          <Box
            as="span"
            ml={18}>
            Icons:
            <Button
              width={2}
              textAlign="center"
              backgroundColor="rgba(0, 0, 0, 0)"
              textColor={iconToggle ? "rgba(255, 255, 255, 0.5)" : "rgba(255, 255, 255, 1)"}
              onClick={() => setIconToggle(false)}>
              <Icon mr={1} name={"circle"} />
            </Button>
            <Button
              width={2}
              backgroundColor="rgba(0, 0, 0, 0)"
              textColor={iconToggle ? "rgba(255, 255, 255, 1)" : "rgba(255, 255, 255, 0.5)"}
              onClick={() => setIconToggle(true)}>
              <Icon name={"tint"} />
            </Button>
          </Box>
        </>
      ) as any}
      buttons={(
        <Box>
          {"Dispense Amount: "}
          <NumberInput
            value={addAmount}
            format={value => value + "u"}
            width={4}
            minValue={1}
            maxValue={100}
            onDrag={(e, value) => setAddAmount(value)}
          />
        </Box>
      )}>
      <Section fitted backgroundColor="rgba(0,0,0,0)">
        {!container || container.maxVolume === container.totalVolume && (
          <Modal
            className="chem-dispenser__labels"
            fontSize="20px"
            mr={2}
            p={3}>
            <Box>
              {!container ? (
                "No " + beakerName + " Inserted"
              ) : container.name + " Full"}
            </Box>
          </Modal>
        )}
        {dispensableReagents.map((reagent, reagentIndex) => (
          <Button
            key={reagentIndex}
            className="chem-dispenser__dispense-buttons"
            align="left"
            width="130px"
            onMouseEnter={() => setHoverOverId(reagent.id)}
            onMouseLeave={() => setHoverOverId("")}
            disabled={container?.maxVolume === container?.totalVolume}
            lineHeight={1.75}
            onClick={() => act("dispense", {
              amount: addAmount,
              reagentId: reagent.id,
            })}
          >
            <Icon
              color={"rgba(" + reagent.colorR + "," + reagent.colorG + ", " + reagent.colorB + ", 1)"}
              name={iconToggle ? MatterStateIconMap[reagent.state].icon : "circle"}
              pt={1}
              style={{
                "text-shadow": "0 0 3px #000",
              }}
            />
            {reagent.name}
          </Button>
        ))}
      </Section>
      <Box italic pt={0.5}> {"Reagent ID: " + hoverOverId}</Box>
    </Section>
  );
};

export const Beaker = (props, context) => {
  const { act, data } = useBackend<ChemDispenserData>(context);
  const { beakerName, container } = data;

  const [iconToggle] = useSharedState(context, 'iconToggle', false);
  const [removeAmount, setRemoveAmount] = useSharedState(context, 'removeAmount', 10);
  const removeReagentButtons = [removeAmount, 10, 5, 1];

  return (
    <Section
      fontSize="12px"
      title={
        <Button
          className="chem-dispenser__buttons"
          icon="eject"
          onClick={() => act("eject")}>
          {!container ? "Insert " + beakerName : "Eject " + container.name + " (" + container.totalVolume + "/" + container.maxVolume + ")"}
        </Button> as any
      }
      buttons={(
        <Box align="left" as="span">
          {"Remove Amount: "}
          <NumberInput
            width={4}
            format={value => value + "u"}
            value={removeAmount}
            minValue={1}
            maxValue={100}
            onDrag={(e, value) => setRemoveAmount(value)}
          />
        </Box>
      )}>
      <Table.Row>
        <Table.Cell bold collapsing textAlign="center" />
        <Table.Cell collapsing />
      </Table.Row>
      <ReagentList container={container} height="auto" showState={iconToggle}
        renderButtons={reagent => (
          <>
            <Button
              icon="filter"
              onClick={() => act("isolate", {
                reagentId: reagent.id,
              })}>
              Isolate
            </Button>
            <Button
              icon="minus"
              onClick={() => act("all", {
                amount: removeAmount,
                reagentId: reagent.id,
              })}>
              All
            </Button>
            {removeReagentButtons.map((amount, indexButtons) => (
              <Button
                key={indexButtons}
                icon="minus"
                onClick={() => act("remove", {
                  amount: amount, reagentId: reagent.id,
                })}>
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

export const BeakerContentsGraph = (props, context) => {
  const { data } = useBackend<ChemDispenserData>(context);
  const [sort, setSort] = useSharedState(context, 'sort', 1);
  const { container } = data;

  return (
    <Section align="center" p={0.5}
      title={(
        <Tabs>
          {sortMap.map((sortBy, index) => (
            <Tabs.Tab
              key={index}
              fontSize="11px"
              textAlign="center"
              align="center"
              selected={sort === sortBy.id}
              onClick={() => setSort(sortBy.id)}>
              {sortBy.icon && (
                <Icon name={sortBy.icon} />
              )}
              {sortBy.contents}
            </Tabs.Tab>
          ))}
        </Tabs>
      ) as any}>
      <ReagentGraph container={container} sort={sortMap[sort].compareFunction} />
      {!!(container && container.totalVolume) && (
        <Box
          fontSize={2}
          color={getTemperatureColor(container.temperature)}
          className={"ChemHeater__TemperatureNumber"}>
          <Icon name={getTemperatureIcon(container.temperature)} pr={0.5} />
          <AnimatedNumber value={container.temperature} /> K
        </Box>
      )}
    </Section>
  );
};


export const ChemGroups = (props, context) => {
  const { act, data } = useBackend<ChemDispenserData>(context);
  const [groupName, setGroupName] = useLocalState(context, 'groupName', "");
  const [reagents, setReagents] = useLocalState(context, 'reagents', "");
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
          <Box>
            <Button
              className="chem-dispenser__buttons"
              icon="eject"
              onClick={() => act("card")}>
              {idCardInserted ? ("Eject ID: " + idCardName) : "Insert ID"}
            </Button>

            <Button color="red"
              className="chem-dispenser__buttons"
              icon="circle"
              onClick={() => act("record")}>
              {isRecording ? "Stop" : "Record"}
            </Button>
            <Button color="red"
              className="chem-dispenser__buttons"
              icon="eraser"
              disabled={!activeRecording}
              onClick={() => act("clear_recording")}>
              {"Clear"}
            </Button>

          </Box>
        }>
        <Box>

          <Box>
            <Box pt={1} pr={7} as="span">
              {"Group Name:"}
            </Box>
          </Box>
          <Input
            pl={5}
            placeholder="Name"
            value={groupName}
            onInput={(e, value) => setGroupName(value)} />
          <Box as="span">
            <Button
              icon="plus-circle"
              lineHeight={1.75}
              onClick={() => {
                act("newGroup", { reagents: reagents, groupName: groupName });
                setGroupName("");
                setReagents("");
              }}>
              Add Group
            </Button>
          </Box>

        </Box>
        <Box pt={0.5} italic={!activeRecording} color={!activeRecording ? "grey" : "default"}>
          {activeRecording || "Recording Empty"}
        </Box>
      </Section>
      {!!groupList.length && (
        <Section>
          {groupList.map((group, index) => (
            <Box key={index}>
              <Button
                key={index}
                icon="tint"
                lineHeight={1.75}
                onClick={() => act("groupDispense", {
                  selectedGroup: group.ref,
                })}>
                {group.name}
              </Button>
              <Button
                icon="trash"
                lineHeight={1.75}
                onClick={() => act("deleteGroup", {
                  selectedGroup: group.ref,
                })}>
                Delete
              </Button>
              {" " + group.info}
            </Box>
          ))}
        </Section>
      )}
    </>
  );
};
