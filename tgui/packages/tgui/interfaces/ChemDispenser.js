
import { useBackend, useSharedState } from "../backend";
import { truncate } from "../format.js";
import { clamp } from "common/math";
import { Button, NumberInput, Section, Box, Table, Tooltip, Icon } from "../components";
import { Window } from "../layouts";

export const titleCase = str => {
  let splitStr = str.toLowerCase().split(" ");
  if (!splitStr === "the" || "on") {
    for (let i = 0; i < splitStr.length; i++) {
      splitStr[i] = splitStr[i].charAt(0).toUpperCase()
    + splitStr[i].substring(1);
    }
  }
  return splitStr.join(" ");
};


const sortMap = {
  0: {
    contents: "Big to Small",
    algorithm: (a, b) => b.volume - a.volume,
  },
  1: {
    contents: "Small to Big",
    algorithm: (a, b) => a.volume - b.volume,
  },
  2: {
    contents: "Density",
    algorithm: (a, b) => a.state - b.state,
  },
  3: {
    contents: "Order Added",
    algorithm: (a, b) => a.state,
  },
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

export const lightOrDark = (r, g, b) => {
  let hsp;
  hsp = Math.sqrt(
    0.299 * (r * r)
  + 0.587 * (g * g)
  + 0.114 * (b * b)
  );
  if (hsp>127.5) {
    return "black";
  }
  else {
    return "white";
  }
};

export const sortVolume = (a, b) => {
  return parseFloat(a.volume) - parseFloat(b.volume);
};


export const ChemDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    beakerContents,
  } = data;
  return (
    <Window width={570}
      height={605}
      theme="ntos">
      <Window.Content scrollable>
        <Box>
          <ReagentDispenser />
          <Beaker />
          {!!beakerContents.length && (
            <BeakerContentsMap />
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
    addAmount,
    maximumBeakerVolume,
    beakerTotalVolume,
  } = data;
  const dispensableReagents = data.dispensableReagents || [];
  return (
    <Section
      fontFamily="Arial"
      fontSize="12px"
      title="Dispense"
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
      {(maximumBeakerVolume === beakerTotalVolume
      && maximumBeakerVolume > 0) && (
        beakerName + " Is full."
      )}
      {(maximumBeakerVolume !== beakerTotalVolume
      && maximumBeakerVolume > 0) && (
        // lightOrDark(reagent.colorR, reagent.colorG, reagent.colorB)
        <Box>
          {dispensableReagents.map(reagent => (
            <Button
              key={reagent.id}
              backgroundColor={""}
              align="left"
              width="129.5px"
              lineHeight={1.75}
              onClick={() => act("dispense", {
                reagentId: reagent.id,
              })}>
              <Icon
                align="center"
                color={"rgba(" + reagent.colorR + "," + reagent.colorG + ", " + reagent.colorB + ", 1)"}
                name={stateMap[reagent.state].icon} />
              {truncate(titleCase(reagent.name), 16)}
              {reagent.name.length > 16 && (
                <Tooltip
                  position="bottom"
                  content={titleCase(reagent.name)} />
              )}
            </Button>
          ))}
        </Box>
      )}
    </Section>
  );
};

export const Beaker = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    beakerName,
    maximumBeakerVolume,
    beakerTotalVolume,
    removeAmount,
  } = data;

  const removeReagentButtons = [removeAmount, 10, 5, 1];
  const beakerContents = data.beakerContents || [];

  return (
    <Section
      fontFamily="Arial"
      fontSize="12px"
      title={
        <Button
          icon="eject"
          content={!maximumBeakerVolume ? "Insert " : "Eject " + beakerName + " (" + beakerTotalVolume + "/" + maximumBeakerVolume + ")"}
          onClick={() => act("eject")} />
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
      {beakerContents.map(reagent => (
        <Table.Row key={reagent.id}>
          <Table.Cell collapsing
            textAlign="left">
            <Icon
              pr={stateMap[reagent.state].pr}
              color={"rgba(" + reagent.colorR + "," + reagent.colorG + ", " + reagent.colorB + ", 1)"}
              name={stateMap[reagent.state].icon} />
            {titleCase(reagent.name) + " ( " + reagent.volume + "u )"}
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
              {removeReagentButtons.map(amount => (
                <Button
                  key={amount}
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




export const BeakerContentsMap = (props, context) => {
  const { act, data } = useBackend(context);
  const [sort, setSort] = useSharedState(context, 'sort', 1);
  const {
    beakerContents,
    maximumBeakerVolume,
    beakerTotalVolume,
  } = data;
  const finalColor = data.finalColor || "";
  return (
    <Section align="center" p={0.5}>
      <Button
        py={1}
        mb={1}
        onClick={() => setSort(sort === 3 ? 0 : sort + 1)}>
        <Box as="span">
          <Icon name="sort-amount-down" />
          {!sort ? (
            <Box as="span" bold>  {"Big to Small"} </Box>)
            : "Big to Small" }
          {" / "}
          <Icon name="sort-amount-up" />
          {sort === 1 ? (
            <Box as="span" bold> {"Small to Big"} </Box>)
            : "Small to Big" }
          {" / "}
          {sort === 2 ? (
            <Box as="span" bold> {"Density"} </Box>)
            : "Density" }
          {" / "}
          {sort === 3 ? (
            <Box as="span" bold> {"Order Added"} </Box>)
            : "Order Added" }
        </Box>
      </Button>
      <Box
        position="relative"
        py={1.5}
        pl={4}
        backgroundColor={finalColor.substring(0, 7)}>
        <Tooltip
          position="top"
          content="Current Mixture Color" />
      </Box>
      {beakerContents.sort(sortMap[sort].algorithm).map(reagent => (
        <Box
          position="relative"
          as="span"
          pl={((reagent.volume / maximumBeakerVolume)*100) / 1.146}
          py={1}
          key={reagent.name}
          tooltip="test"
          backgroundColor={"rgba(" + reagent.colorR + "," + reagent.colorG + ", " + reagent.colorB + ", 1)"}>
          <Tooltip
            overrideLong
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
          content={(maximumBeakerVolume - beakerTotalVolume)} />
      </Box>
    </Section>
  );
};


export const ChemGroups = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    groupList,
    idCardName,
    idCardInserted,
  } = data;
  return (
    <Section
      fontFamily="Arial"
      title={
        <Button
          icon="eject"
          onClick={() => act("card")}>
          {idCardInserted ? ("Eject ID: " + idCardName) : "Insert ID to Save Groups"}
        </Button>
      }
      buttons={
        <Button
          icon="plus-circle"
          lineHeight={1.75}
          onClick={() => act("newGroup")}>
          New Group
        </Button>
      }>

      {groupList.map(group => (
        <Box key={group.name}>
          <Button
            key={group.name}
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
  );
};
