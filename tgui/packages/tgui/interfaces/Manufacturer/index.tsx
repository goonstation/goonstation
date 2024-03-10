/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { toTitleCase } from 'common/string';
import { Box, Button, Collapsible, Divider, Flex, Input, LabeledList, Section, Slider, Stack } from '../../components';
import { ButtonWithBadge } from '../../components/goonstation/ButtonWithBadge';
import { truncate } from '../../format';
import { formatMoney } from '../../format';
import { Manufacturable, ManufacturerData, Ore, Resource, Rockbox, WireIndicators } from './type';
import { CenteredText } from '../../components/goonstation/CenteredText';

const backgroundPop = "rgba(0,0,0,0.2)";
const credit_symbol = "⪽";

const CategoryDropdown = (props, context) => {
  const { act } = useBackend(context);
  const { category, blueprints } = props;
  let buttons = [];
  for (let i in blueprints) {
    buttons.push(<ButtonWithBadge width={12.75} height={5.5} image_path={blueprints[i].img} text={truncate(blueprints[i].name, 40)} onClick={() => act("product", { "blueprint_ref": blueprints[i].byondRef })} />);
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
    <Flex backgroundColor={backgroundPop} p={1}>
      <Flex.Item grow>
        <CenteredText text="No Account Found" />
      </Flex.Item>
      <Flex.Item>
        <Button icon="add" onClick={() => act("card", { "scan": true })}>Add Account</Button>
      </Flex.Item>
    </Flex>
  ) : (
    <Section
      title="Account Info"
      buttons={<Button icon="minus" onClick={() => act("card", { "remove": true })}>Log Out</Button>}
    >
      <LabeledList>
        <LabeledList.Item
          label="Owner"
        >
          {data.card_owner}
        </LabeledList.Item>
        <LabeledList.Item
          label="Balance"
        >
          {formatMoney(data.card_balance)}{credit_symbol}
        </LabeledList.Item>
      </LabeledList>
    </Section>
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
        <Flex>
          <Flex.Item textColor={data.wires[wire]}>
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
            {data.indicators.malfunctioning ? "Unstable" : "Stable"}
          </LabeledList.Item>
          <LabeledList.Item
            label="Inventory">
            {data.indicators.hacked ? "Expanded" : "Standard"}
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
        <Stack>
          <Stack.Item width="80%">
            <Section>
              {dropdowns}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack vertical>
              <Stack.Item>
                <Input placeholder="Search..." icon="search" width="100%" />
              </Stack.Item>
              <Stack.Item>
                <Section title="Materials Loaded" textAlign="center">
                  <LabeledList>
                    {data.resource_data.map((resourceData:Resource) => (
                      <LabeledList.Item
                        key={resourceData.id}
                        buttons={[
                          <Button key="eject" icon="eject" onClick={() => act("material_eject", { "resource": resourceData.id })} />,
                          <Button key="swap" icon="add" onClick={() => act("material_swap", { "resource": resourceData.id })} />,
                        ]}
                        label={toTitleCase(resourceData.name)}
                        textAlign="center"
                      >
                        {resourceData.amount/10}
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <CardInfo />
              </Stack.Item>
              <Stack.Item>
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
              </Stack.Item>
              <Stack.Item>
                {data.panel_open ? <CollapsibleWireMenu /> : ""}
              </Stack.Item>
              <Stack.Item>
                {data.rockboxes.map((rockbox:Rockbox) => (
                  <Section
                    key={rockbox.byondRef}
                    title={rockbox.area_name}
                  >
                    <LabeledList>
                      {rockbox.ores.map((ore:Ore) => (
                        <LabeledList.Item
                          key={ore.name}
                          label={ore.name}
                        >
                          <Button
                            textAlign="center"
                            onClick={() => act("ore_purchase", { "ore": ore.name, "storage_ref": rockbox.byondRef })}
                            key={ore.name}
                          >
                            {ore.amount} {"("}{ore.cost}{credit_symbol}{")"}
                          </Button>
                        </LabeledList.Item>
                      ))}
                    </LabeledList>
                  </Section>
                ))}
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>

      </Window.Content>
    </Window>
  );
};
