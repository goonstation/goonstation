/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { Box, Button, Collapsible, Divider, Flex, Image, Input, LabeledList, Section, Slider, Stack, Table, Tooltip } from '../../components';
import { formatTime, truncate } from '../../format';
import { TableCell, TableRow } from '../../components/Table';

let backgroundPop = "rgba(0,0,0,0.2)"; // The intent is to use this akin to a #DEFINE but if this is foolish yell @ me

/* This code block explains the general flow of the code regarding menu structure
   This menu is rather big so hopefully it helps navigate the heavy nesting of elements

Window contains:
- Left section containing collapsibles of buttons
- Right section containing settings

  Left section contains:
    - Collapsibles with buttons

    Collapsibles contain:
      - Buttons which have image/name/tooltip based off own data.

    Buttons contain:
      - Leftmost: image of item
      - Middle: vertical stack, settings button on top and ? tooltip on bottom.
        - settings tooltip NYI
        - tooltip button contains information on material and time costs
      - Right: name, up to 3 lines / 30 characters

  Right section contains:
    - Search bar
    - Materials list containing material info/control

    Material list elements contain:
      - Eject button
      - Priority swap buttons (swap priority of two materials for fabricator use)
      - Speed control buttons
      - Repeat toggle button
      - Ore buying which contains ores by rockbox

      Each rockbox element contains:
        - List of ores available for purchase

        Each ore available for purchase contains:
          - Button with ore icon, name, amount, and cost
*/

const BlueprintTooltip = (props) => {
  let { blueprint } = props;
  let requirements = [];
  for (let i in blueprint.item_names) {
    requirements.push(<>{blueprint.item_amounts[i]/10} {blueprint.item_names[i]}<br /></>);
  }
  return (
    <>
      Resource Costs:<br />
      {requirements} <br />
      {formatTime(blueprint.time, "Instananeous")}
    </>
  );
};

const BlueprintButton = (props, context) => {
  const { act } = useBackend(context);
  const { name, blueprintData } = props;

  return (
    <Stack width={15} inline backgroundColor={backgroundPop} mx={0.575} mb={0} p={0.5}>
      <Stack.Item>
        <Button
          ellipsis
          width={12.2}
          height={5.3}
          p={0}
          onClick={() => act("product", { "blueprint_ref": blueprintData.ref })}
        >
          <Stack>
            <Stack.Item
              ml={0}
              pt={0}
              mt={0}
              backgroundColor={backgroundPop}
            >
              <Image pixelated src={blueprintData.img} width={5} />
            </Stack.Item>
            <Stack.Item>
              <Stack
                vertical
                fill
                style={{ "align-items": "center" }}
              >
                <Stack.Item
                  width={6}
                  textAlign="center"
                  style={{ "white-space": "normal" }}
                >
                  {truncate(name, 30)}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Button>
      </Stack.Item>

      <Stack.Item ml={0.5}>
        <Stack vertical p={0} m={0}>
          <Stack.Item pb={0.5}>
            <Button align="center" width={2} height={2.5} icon="gear" pt={0.9} />
          </Stack.Item>
          <Stack.Item p={0} m={0}>
            <Tooltip content={<BlueprintTooltip blueprint={blueprintData} />}>
              <Button align="center" width={2} height={2.5} icon="question" pt={0.9} />
            </Tooltip>
          </Stack.Item>
        </Stack>
      </Stack.Item>

    </Stack>
  );
};

const MaterialRow = (props, context) => {
  let { act } = useBackend(context);
  let { resource, resourceAmt } = props;

  return (
    <TableRow collapsing>
      <TableCell collapsing>
        <Button icon="eject" onClick={() => act("material_eject", { "material": resource })} />
      </TableCell>
      <TableCell>
        <Button icon="add" onClick={() => act("material_swap", { "resource": resource })} />
      </TableCell>
      <TableCell header>
        {resource}
      </TableCell>
      <TableCell>
        {resourceAmt/10}
      </TableCell>
    </TableRow>
  );
};

const LoadedMaterials = (props, context) => {
  let { resources } = props;
  let resourceRows = [];
  for (let resource in resources) {
    resourceRows.push(<MaterialRow resource={resource} resourceAmt={resources[resource]} />);
  }
  return (
    <Table>
      {resourceRows}
    </Table>
  );
};

const CategoryDropdown = (props) => {
  const { category, blueprints } = props;
  let buttons = [];
  for (let i in blueprints) {
    buttons.push(<BlueprintButton name={i} blueprintData={blueprints[i]} />);
  }

  return (
    <Collapsible open title={category}>
      {buttons}
    </Collapsible>
  );
};

const CardInfo = (props, context) => {
  const { data, act } = useBackend<ManufacturerData>(context);
  return (data.card_owner === null || data.card_balance === null) ? (
    <Flex backgroundColor={backgroundPop} py={1}>
      <Flex.Item grow>
        No Card Inserted
      </Flex.Item>
      <Flex.Item>
        <Button icon="add" onClick={() => act("card", { "scan": true })}>Insert Card</Button>
      </Flex.Item>
    </Flex>
  ) : (
    <Box backgroundColor={backgroundPop} py={1}>
      Card Owner: {data.card_owner}<br />
      Current Balance: {data.card_balance}⪽
      <Button icon="subtract" onClick={() => act("card", { "remove": true })}>Remove Card</Button>
    </Box>
  );
};

const is_set = (bits, bit) => { return bits & (1 << bit); };

export const CollapsibleWireMenu = (props, context) => {
  const { act, data } = useBackend<ManufacturerData>(context);
  let wireContent = [];
  let i = 0;
  wireContent.push(
    <>
      <Flex style={{ "align-items": "center" }}>
        <Flex.Item style={{ "width": "45%" }}>
          Panel {data.panel_open ? "open" : "closed"}.
        </Flex.Item>
        <Flex.Item grow>
          <Button
            icon={data.panel_open ? "warning" : "circle"}
            color={data.panel_open ? "orange" : "green"}
            onClick={() => act("toggle_panel")}
          >
            Screws {data.panel_open ? "Loose" : "Secure"}
          </Button>
        </Flex.Item>
      </Flex>
      <Divider />
    </>
  );
  if (data.panel_open)
  {
    for (let wire in data.wires)
    {
      let cut = is_set(data.wire_bitflags, i);
      i++;
      wireContent.push(
        <Flex textColor={data.wires[wire]} px={2}>
          <Flex.Item grow bold>
            {wire}
          </Flex.Item>
          <Flex.Item mr="5%">
            <Button
              ml="10%"
              my="1%"
              content="Pulse"
              onClick={() => act('wire', { action: "pulse", wire: i })}
            />
          </Flex.Item>
          <Flex.Item>
            <Button
              m="1%"
              content={cut ? "Cut" : "Mend"}
              onClick={() => act("wire", { action: (cut ? "mend" : "cut"), wire: i })}
            />
          </Flex.Item>
        </Flex>
      );
    }
  }
  return (
    <Collapsible
      mb="1%"
      title="Maintenence Panel"
      open={data.panel_open}
    >
      <Box backgroundColor={backgroundPop} p={1}>
        {wireContent}
        <Divider />
        <LabeledList>
          <LabeledList.Item
            label="Electrification Risk">
            {data.indicators.electrified ? "High" : "None"}
          </LabeledList.Item>
          <LabeledList.Item
            label="System Stability">
            {data.indicators.malfunctioning ? "100%" : "0%"}
          </LabeledList.Item>
          <LabeledList.Item
            label="Warranty">
            {data.indicators.hacked ? "Void" : "Valid"}
          </LabeledList.Item>
          <LabeledList.Item
            label="Power">
            {data.indicators.hasPower ? "Sufficient" : "Insufficient"}
          </LabeledList.Item>
        </LabeledList>
      </Box>
    </Collapsible>
  );
};

export const Manufacturer = (_, context) => {
  const { act, data } = useBackend<ManufacturerData>(context);
  const [repeat, toggleRepeatVar] = useSharedState(context, "repeat", data.repeat);
  const [speed, setSpeedVar] = useSharedState(context, "speed", data.speed);
  let toggleRepeat = () => {
    act("repeat");
    toggleRepeatVar(!repeat);
  };
  let updateSpeed = (newValue:number) => {
    act("speed", { "value": newValue });
    setSpeedVar(newValue);
  };
  let usable_blueprints = data.available_blueprints;
  let dropdowns = [];
  for (let i of data.all_categories) {
    if (!usable_blueprints[i]) continue;
    dropdowns.push(<CategoryDropdown category={i} blueprints={usable_blueprints[i]} />);
  }
  return (
    <Window width={1200} height={600} title={data.fabricator_name}>
      <Window.Content>
        <Flex>
          <Flex.Item
            style={{ "width": "80%" }}
            mr={1}
          >
            <Section>
              {dropdowns}
            </Section>
          </Flex.Item>
          <Flex.Item
            style={{ "width": "20%" }}
          >
            <Section
              fill
              align="center"
            >
              <Input placeholder={"Search..."} icon={"search"} style={{ "width": "100%" }} />
              <Section title="Materials Loaded" style={{ "width": "100%" }} textAlign="center" pt={1} backgroundColor={backgroundPop}>
                <LoadedMaterials resources={data.resources} />
              </Section>
              <Slider
                my={2}
                minValue={1}
                value={speed}
                maxValue={3}
                step={1}
                stepPixelSize={100}
                onChange={(_e:any, value:number) => updateSpeed(value)}
              >
                Speed: {speed}
              </Slider>
              <CardInfo />
              <Flex
                backgroundColor={backgroundPop}
                my={1}
                py={1}
                style={{ "align-items": "center" }}
              >
                <Flex.Item grow>
                  Repeat: {repeat ? "On" : "Off"}
                </Flex.Item>
                <Flex.Item>
                  <Button icon="repeat" onClick={() => toggleRepeat()}>Toggle Repeat</Button>
                </Flex.Item>
              </Flex>

              <CollapsibleWireMenu />

              {data.rockboxes.map((rockbox:Rockbox) => (
                <Section
                  key={rockbox.name}
                  backgroundColor={backgroundPop}
                  title={rockbox.name+ " at "+rockbox.area_name}
                  fontSize={0.875}
                >
                  {rockbox.ores.map((ore:Ore) => (
                    <Button
                      fontSize={1}
                      key={ore.name}
                      onClick={() => act("ore_purchase", { "ore": ore.name, "storage_ref": rockbox.reference })}
                      style={{ "width": "90%" }}
                    >
                      {ore.name}: {ore.amount} for {ore.cost}⪽ each
                    </Button>
                  ))}
                </Section>
              ))}
            </Section>
          </Flex.Item>
        </Flex>

      </Window.Content>
    </Window>
  );
};
