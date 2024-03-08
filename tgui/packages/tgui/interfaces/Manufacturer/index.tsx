/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { toTitleCase } from 'common/string';
import { Box, Button, Collapsible, Divider, Flex, Image, Input, LabeledList, Section, Slider, Stack, Table, Tooltip } from '../../components';
import { formatTime, truncate } from '../../format';
import { TableCell, TableRow } from '../../components/Table';
import { formatMoney } from '../../format';
import { Manufacturable, ManufacturerData, Ore, Rockbox, WireIndicators } from './type';

const backgroundPop = "rgba(0,0,0,0.2)";
const credit_symbol = "⪽";

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
    <Stack inline>
      <Stack.Item>
        <Button
          ellipsis
          onClick={() => act("product", { "blueprint_ref": blueprintData.byondRef })}
        >
          <Stack>
            <Stack.Item>
              <Image pixelated src={blueprintData.img} />
            </Stack.Item>
            <Stack.Item>
              <Stack
                vertical
                fill
              >
                <Stack.Item>
                  {truncate(name, 30)}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Button>
      </Stack.Item>

      <Stack.Item>
        <Stack vertical>
          <Stack.Item>
            <Button icon="gear" />
          </Stack.Item>
          <Stack.Item>
            <Tooltip content={<BlueprintTooltip blueprint={blueprintData} />}>
              <Button align="center" icon="question" />
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
    <TableRow>
      <TableCell collapsing>
        <Button icon="eject" onClick={() => act("material_eject", { "material": resource })} />
      </TableCell>
      <TableCell>
        <Button icon="add" onClick={() => act("material_swap", { "resource": resource })} />
      </TableCell>
      <TableCell header>
        {toTitleCase(resource)}
      </TableCell>
      <TableCell>
        {resourceAmt/10}
      </TableCell>
    </TableRow>
  );
};

const LoadedMaterials = (props) => {
  let { resources, resourceNames } = props;
  let resourceRows = [];
  let i = 0;
  for (let resource in resources) {
    resourceRows.push(<MaterialRow resource={resourceNames[i]} resourceAmt={resources[resource]} />);
    i++;
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

const CardInfo = (_, context) => {
  const { data, act } = useBackend<ManufacturerData>(context);
  return (data.card_owner === null || data.card_balance === null) ? (
    <Flex>
      <Flex.Item>
        No Card Inserted
      </Flex.Item>
      <Flex.Item>
        <Button icon="add" onClick={() => act("card", { "scan": true })}>Insert Card</Button>
      </Flex.Item>
    </Flex>
  ) : (
    <Box>
      Card: {data.card_owner}
      <Flex>
        <Flex.Item>
          Balance: {formatMoney(1000)}{credit_symbol}
        </Flex.Item>
        <Flex.Item>
          <Button icon="subtract" onClick={() => act("card", { "remove": true })}>Remove Card</Button>
        </Flex.Item>
      </Flex>
    </Box>
  );
};

const is_set = (bits, bit) => bits & (1 << bit);

export const CollapsibleWireMenu = (_, context) => {
  const { act, data } = useBackend<ManufacturerData>(context);
  let wireContent = [];
  let i = 0;
  if (data.panel_open)
  {
    for (let wire in data.wires)
    {
      let cut = is_set(data.wire_bitflags, i);
      i++;
      wireContent.push(
        <Flex textColor={data.wires[wire]}>
          <Flex.Item>
            {wire}
          </Flex.Item>
          <Flex.Item>
            <Button
              content="Pulse"
              onClick={() => act('wire', { action: "pulse", wire: i })}
            />
          </Flex.Item>
          <Flex.Item>
            <Button
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
      title="Maintenence Panel"
      open
    >
      <Box>
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
          <Flex.Item width="80%">
            <Section>
              {dropdowns}
            </Section>
          </Flex.Item>
          <Flex.Item grow>
            <Section>
              <Input placeholder="Search..." icon="search" width="100%" />
              <Section title="Materials Loaded" textAlign="center">
                <LoadedMaterials resources={data.resources} resourceNames={data.resource_names} />
              </Section>
              <CardInfo />
              <Box>
                <Flex>
                  <Flex.Item>
                    Repeat: {repeat ? "On" : "Off"}
                  </Flex.Item>
                  <Flex.Item>
                    <Button icon="repeat" onClick={() => toggleRepeat()}>Toggle Repeat</Button>
                  </Flex.Item>
                </Flex>
                <Slider
                  minValue={1}
                  value={speed}
                  maxValue={3}
                  step={1}
                  stepPixelSize={100}
                  onChange={(_e:any, value:number) => updateSpeed(value)}
                >
                  Speed: {speed}
                </Slider>
              </Box>

              {data.panel_open ? <CollapsibleWireMenu /> : ""}

              {data.rockboxes.map((rockbox:Rockbox) => (
                <Section
                  key={rockbox.name}
                  title={rockbox.name+ " at "+rockbox.area_name}
                >
                  {rockbox.ores.map((ore:Ore) => (
                    <Button
                      key={ore.name}
                      onClick={() => act("ore_purchase", { "ore": ore.name, "storage_ref": rockbox.byondRef })}
                    >
                      {ore.name}: {ore.amount} for {ore.cost}{credit_symbol} each
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
