
import { useBackend } from "../backend";
import { truncate } from "../format.js";
import { Button, NumberInput, Section, Box, Table, Tooltip } from "../components";
import { Window } from "../layouts";

export const ChemDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window width={570}
      height={505}
      theme="ntos">
      <Window.Content scrollable>
        <ReagentDispenser />
        <Beaker />
        <ChemGroups />
      </Window.Content>
    </Window>
  );
};





export const ReagentDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const capitalize = (str, lower = false) => (lower ? str.toLowerCase() : str).replace(/(?:^|\s|["'([{])+\S/g, match => match.toUpperCase());
  const {
    beakerName,
    addAmount,
    maximumBeakerVolume,
    beakerTotalVolume,
  } = data;
  const dispensableReagents = data.dispensableReagents || [];
  return (
    <Section
      title="Dispense"
      buttons={(
        <NumberInput
          fontFamily="ariel"
          value={addAmount}
          width={5}
          minValue={1}
          maxValue={100}
          onChange={(e, value) => act("setDispense", {
            amount: value,
          })} />
      )}>
      {(maximumBeakerVolume === beakerTotalVolume
      && maximumBeakerVolume > 0) && (
        beakerName + " Is full."
      )}
      {(maximumBeakerVolume !== beakerTotalVolume
      && maximumBeakerVolume > 0) && (
        <Box>
          {dispensableReagents.map(reagent => (
            <Button
              key={reagent.id}
              align="center"
              width="129.5px"
              lineHeight={1.75}
              onClick={() => act("dispense", {
                reagentId: reagent.id,
              })}>
              {truncate(capitalize(reagent.name), 18)}
              {reagent.name.length > 18 && (
                <Tooltip
                  overrideLong
                  position="bottom"
                  content={capitalize(reagent.name)} />
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
      title={beakerName + " (" + beakerTotalVolume + "/" + maximumBeakerVolume + ")"}
      buttons={(
        <Box align="left">
          <Button
            icon="eject"
            content="Eject"
            onClick={() => act("eject")} />
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
          "Nothing"
        )}
      </Box>
      {beakerContents.map(reagent => (
        <Table.Row key={reagent.id}>
          <Table.Cell collapsing textAlign="left">
            {reagent.name + " ( " + reagent.volume + "u )"}
          </Table.Cell>
          <Table.Cell collapsing textAlign="left">
            <Box mt={0.5}>
              <Button
                icon="minus"
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



export const ChemGroups = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    groupList,
  } = data;
  return (
    <Section title="Reagent Groups">

      {groupList.map(group => (
        <Box key={group.name}>
          <Button
            key={group.name}
            icon="tint"
            lineHeight={1.75}
            onClick={() => act('deleteGroup', {
              selectedGroup: group.name,
            })}>
            {group.name}
          </Button>
          {group.info}
        </Box>
      ))}
    </Section>
  );
};
