
import { useBackend, useSharedState, useLocalState } from "../backend";
import { truncate } from "../format.js";
import { Button, NumberInput, Section, Box, Table, Tooltip, Icon, Tabs, Input, Fragment, Modal, Flex } from "../components";
import { Window } from "../layouts";

export const titleCase = str => {
  let splitStr = str.toLowerCase().split(" ");
  for (let i = 0; i < splitStr.length; i++) {
    splitStr[i] = splitStr[i].charAt(0).toUpperCase()
    + splitStr[i].substring(1);
  }
  return splitStr.join(" ");
};



const stateMap = {
  1: {
    icon: "square", // solid
    pr: 0.5,
  },
  2: {
    icon: "tint", // liquid
    pr: 0.9,
  },
  3: {
    icon: "wind", // gas
    pr: 0.5,
  },
};


export const ChemDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    beakerContents,
  } = data;
  return (
    <Window width={570}
      height={705}
      theme="science">
      <Window.Content scrollable>
        <Box>
          <ReagentDispenser />
          <Beaker />
          {!!beakerContents.length && (
            <BeakerContentsGraph />
          )}
          <ChemGroups />
        </Box>
      </Window.Content>
    </Window>
  );
};





export const ReagentDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    beakerName,
    currentBeakerName,
    addAmount,
    maximumBeakerVolume,
    beakerTotalVolume,
  } = data;
  const [iconToggle, setIconToggle] = useSharedState(context, 'iconToggle', false);
  const [hoverOverId, setHoverOverId] = useLocalState(context, 'hoverOver', "");

  const dispensableReagents = data.dispensableReagents || [];

  return (
    <Section
      fontSize="12px"
      title={(
        <Fragment>
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
        </Fragment>
      )}
      buttons={(
        <Box>
          {"Dispense Amount: "}
          <NumberInput
            value={addAmount}
            width={5}
            minValue={1}
            maxValue={100}
            onChange={(e, value) => act("setDispense", {
              amount: value,
            })} />
        </Box>
      )}>
      {(!maximumBeakerVolume || maximumBeakerVolume === beakerTotalVolume) && (
        <Modal
          fontSize="20px"
          mr={2}
          p={3}>
          <Box>
            {!maximumBeakerVolume &&(
              "No " + titleCase(beakerName) + " Inserted"
            ) || titleCase(currentBeakerName) + " Full"}
          </Box>
        </Modal>
      )}
      <Box>
        {dispensableReagents.map((reagent, index) => (
          <Button
            key={index}
            position="relative"
            backgroundColor={""}
            align="left"
            width="129.5px"
            onMouseEnter={() => setHoverOverId(reagent.id)}
            onMouseLeave={() => setHoverOverId("")}
            disabled={maximumBeakerVolume === beakerTotalVolume}
            lineHeight={1.75}
            onClick={() => act("dispense", {
              reagentId: reagent.id,
            })}>
            <Icon
              style={{
                "text-shadow": "0 0 3px #000;",
              }}
              align="center"
              color={"rgba(" + reagent.colorR + "," + reagent.colorG + ", " + reagent.colorB + ", 1)"}
              name={iconToggle ? stateMap[reagent.state].icon : "circle"} />
            {truncate(titleCase(reagent.name), 16)}
            {reagent.name.length > 16 && (
              <Tooltip
                position="bottom"
                content={titleCase(reagent.name)} />
            )}
          </Button>
        ))}
        <Box italic pt={0.5}> {"Reagent ID: " + hoverOverId}</Box>
      </Box>
    </Section>
  );
};

export const Beaker = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    beakerName,
    maximumBeakerVolume,
    currentBeakerName,
    beakerTotalVolume,
    removeAmount,
  } = data;

  const [iconToggle] = useSharedState(context, 'iconToggle', false);
  const removeReagentButtons = [removeAmount, 10, 5, 1];
  const beakerContents = data.beakerContents || [];

  return (
    <Section
      fontSize="12px"
      title={
        <Button
          icon="eject"
          onClick={() => act("eject")}>
          {!maximumBeakerVolume ? "Insert " + beakerName : "Eject " + titleCase(currentBeakerName) + " (" + beakerTotalVolume + "/" + maximumBeakerVolume + ")"}
        </Button>
      }
      buttons={(
        <Box align="left" as="span">
          {"Remove Amount: "}
          <NumberInput
            width={5}
            value={removeAmount}
            minValue={1}
            maxValue={100}
            onChange={(e, value) => act("setRemove", {
              amount: value,
            })} />
        </Box>
      )}>
      <Table.Row>
        <Table.Cell bold collapsing textAlign="center" />
        <Table.Cell collapsing />
      </Table.Row>
      <Box color="label">
        {!beakerContents.length && (
          "No Contents"
        )}
      </Box>
      {beakerContents.map((reagent, index) => (
        <Table.Row key={index}>
          <Table.Cell collapsing
            textAlign="left"
            position="relative">
            <Icon
              pr={stateMap[reagent.state].pr}
              style={{
                "text-shadow": "0 0 3px #000;",
              }}
              color={"rgba(" + reagent.colorR + "," + reagent.colorG + ", " + reagent.colorB + ", 1)"}
              name={iconToggle ? stateMap[reagent.state].icon : "circle"} />
            {truncate(titleCase(reagent.name), 33) + " ( " + reagent.volume + "u )"}
            {reagent.name.length >= 33 && (
              <Tooltip
                position="bottom"
                content={titleCase(reagent.name)} />
            )}
          </Table.Cell>
          <Table.Cell collapsing textAlign="left">
            <Box mt={0.5}>
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
                  reagentId: reagent.id,
                })}>
                All
              </Button>
              {removeReagentButtons.map((amount, index) => (
                <Button
                  key={index}
                  icon="minus"
                  onClick={() => act("remove", {
                    amount: amount, reagentId: reagent.id,
                  })}>
                  {amount}
                </Button>
              ))}
            </Box>
          </Table.Cell>
        </Table.Row>))}
    </Section>
  );
};




export const BeakerContentsGraph = (props, context) => {
  const { act, data } = useBackend(context);
  const [sort, setSort] = useSharedState(context, 'sort', 1);
  const {
    beakerContents,
    maximumBeakerVolume,
    beakerTotalVolume,
  } = data;
  const finalColor = data.finalColor || "";
  const sortMap = [
    {
      id: 0,
      icon: "sort-amount-down",
      contents: "",
      algorithm: (a, b) => b.volume - a.volume,
    },
    {
      id: 1,
      icon: "sort-amount-up",
      contents: "",
      algorithm: (a, b) => a.volume - b.volume,
    },
    {
      id: 2,
      contents: "Density",
      algorithm: (a, b) => a.state - b.state,
    },
    {
      id: 3,
      contents: "Order Added",
      algorithm: (a, b) => a.state,
    },
  ];
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
      )}>
      <Box
        position="relative"
        py={1.5}
        pl={4}
        backgroundColor={finalColor.substring(0, 7)}>
        <Tooltip
          position="top"
          content="Current Mixture Color" />
      </Box>
      {beakerContents.slice().sort(sortMap[sort].algorithm).map(
        (reagent, index) => (
          <Box
            position="relative"
            as="span"
            pl={((reagent.volume / maximumBeakerVolume)*100) / 1.146}
            py={1}
            key={index}
            tooltip="test"
            backgroundColor={"rgba(" + reagent.colorR + "," + reagent.colorG + ", " + reagent.colorB + ", 1)"}>
            <Tooltip
              position="top"
              content={titleCase(reagent.name) + " ( " + reagent.volume + "u )"} />
          </Box>
        ))}
      <Box
        as="span"
        position="relative"
        pl={((maximumBeakerVolume - beakerTotalVolume)
          / maximumBeakerVolume * 100) / 1.146}
        py={1}
        tooltip="test"
        backgroundColor="black">
        <Tooltip
          position="top"
          content={" ( " + (maximumBeakerVolume - beakerTotalVolume) + "u )"} />
      </Box>
    </Section>
  );
};


export const ChemGroups = (props, context) => {
  const { act, data } = useBackend(context);
  const [groupName, setGroupName] = useLocalState(context, 'groupName', "");
  const [reagents, setReagents] = useLocalState(context, 'reagents', "");
  const {
    groupList,
    idCardName,
    idCardInserted,
  } = data;

  return (
    <Fragment>
      <Section
        title="Reagent Groups"
        buttons={
          <Box>
            <Button
              icon="eject"
              onClick={() => act("card")}>
              {idCardInserted ? ("Eject ID: " + idCardName) : "Insert ID"}
            </Button>
          </Box>
        }>
        <Box>

          <Box>
            <Box pt={1} pr={9} as="span">
              {"Group Name:"}
            </Box>
            <Box pt={1} as="span">
              {"Reagents:"}
            </Box>
          </Box>

          <Input
            pl={5}
            placeholder="Name"
            value={groupName}
            onInput={(e, value) => setGroupName(value)} />
          <Box pt={1} as="span">
            <Input
              pl={5}
              placeholder="Reagents"
              value={reagents}
              onInput={(e, value) => setReagents(value)} />
          </Box>
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
        <Box pt={0.5}>
          {"Reagents Format: water=1;sugar=1;"}
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
    </Fragment>
  );
};
