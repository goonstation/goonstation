/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend, useLocalState, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { toTitleCase } from 'common/string';
import { Button, Collapsible, Divider, Flex, Input, LabeledList, Section, Slider, Stack, Tooltip } from '../../components';
import { ButtonWithBadge } from '../../components/goonstation/ButtonWithBadge';
import { truncate } from '../../format';
import { formatMoney } from '../../format';
import { MaintenencePanel, Manufacturable, ManufacturerData, Ore, Resource, Rockbox, WireData } from './type';
import { CenteredText } from '../../components/goonstation/CenteredText';
import { round } from 'common/math';

const CardInfo = (_, context) => {
  const { data, act } = useBackend<ManufacturerData>(context);
  return (data.card_owner === null || data.card_balance === null) ? (
    <Section>
      <Flex>
        <Flex.Item grow>
          <CenteredText text="No Account Found" />
        </Flex.Item>
        <Flex.Item>
          <Button icon="add" onClick={() => act("card", { "scan": true })}>Add Account</Button>
        </Flex.Item>
      </Flex>
    </Section>
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
          {formatMoney(data.card_balance)}⪽
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const is_set = (bits, bit) => bits & (1 << bit);

export const CollapsibleWireMenu = (props: MaintenencePanel, context) => {
  const { act } = useBackend<ManufacturerData>(context);
  return (
    <Section
      textAlign="center"
      title="Maintenence Panel"
    >
      <LabeledList>
        {props.wires.map((wire: WireData, i: number) => (
          <LabeledList.Item
            key={i}
            label={wire.colorName}
            labelColor={wire.color}
            buttons={[(<Button
              textAlign="center"
              width={4}
              key={i}
              content="Pulse"
              onClick={() => act('wire', { action: "pulse", wire: i+1 })}
            />),
            (<Button
              textAlign="center"
              width={4}
              key={i}
              content={(is_set(props.wire_bitflags, i) !== 0) ? "Cut" : "Mend"}
              onClick={() => act("wire", { action: ((is_set(props.wire_bitflags, i) !== 0) ? "cut" : "mend"), wire: i+1 })}
            />)]}
          />
        ))}
      </LabeledList>
      <Divider />
      <LabeledList>
        <LabeledList.Item
          label="Electrification Risk"
        >
          {props.indicators.electrified ? "High" : "None"}
        </LabeledList.Item>
        <LabeledList.Item
          label="System Stability"
        >
          {props.indicators.malfunctioning ? "Unstable" : "Stable"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Inventory"
        >
          {props.indicators.hacked ? "Expanded" : "Standard"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Power"
        >
          {props.indicators.hasPower ? "Sufficient" : "Insufficient"}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const BlueprintButton = (props, context) => {

  const { blueprintData, fabricatorSpeed } = props;
  const { act } = useBackend(context);
  // Don't include this flavor if we only output one item, because if so, then we know what we're making
  let outputs = (blueprintData.item_outputs.length < 2 && blueprintData.create === 1) ? null : (
    <>
      <br />
      Outputs: <br />
      {blueprintData.item_names.map((value:string, index:number) => (
        <b key={index}>
          {blueprintData.create}x {value}<br />
        </b>
      ))}
    </>
  );
  let content_requirements = (
    <>
      Material Requirements:<br />
      {blueprintData.material_names.map((value:string, index:number) => (
        <>
          {value}: {blueprintData.item_amounts[index]/10} pieces<br />
        </>
      ))}
      Time: {round(blueprintData.time / 10 / fabricatorSpeed, 0.01)}s<br />
      {outputs}
    </>
  );
  /*

  */
  // /datum/manufacture contains no description of its 'contents', so the first item works
  let content_info = blueprintData.item_descriptions[0];
  return (
    <Stack inline
      width={18.75}
      height={5.5}
      m={0.5}
    >
      <Stack.Item>
        <ButtonWithBadge
          key={blueprintData.name}
          width={16.25}
          height={5.5}
          image_path={blueprintData.img}
          text={truncate(blueprintData.name, 40)}
          onClick={() => act("product", { "blueprint_ref": blueprintData.byondRef })}
        />
      </Stack.Item>
      <Stack.Item ml={0.5}>
        <Stack vertical>
          <Stack.Item>
            <Tooltip
              content={content_info}
            >
              <Button
                align="center"
                width={2}
                height={2.625}
                mb={0.5}
                pt={0.7}
                icon="info"
                onClick={() => act("product", { "blueprint_ref": blueprintData.byondRef })}
              />
            </Tooltip>
          </Stack.Item>
          <Stack.Item m={0}>
            <Tooltip
              content={content_requirements}
            >
              <Button
                align="center"
                width={2}
                height={2.625}
                pt={0.7}
                icon="gear"
                onClick={() => act("product", { "blueprint_ref": blueprintData.byondRef })}
              />
            </Tooltip>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const Manufacturer = (_, context) => {
  const { act, data } = useBackend<ManufacturerData>(context);
  const [repeat, toggleRepeatVar] = useSharedState(context, "repeat", data.repeat);
  const [speed, setSpeedVar] = useSharedState(context, "speed", data.speed);
  const [search, setSearchData] = useLocalState(context, "query", "");
  let toggleRepeat = () => {
    act("repeat");
    toggleRepeatVar(!repeat);
  };
  let updateSpeed = (newValue: number) => {
    act("speed", { "value": newValue });
    setSpeedVar(newValue);
  };
  let usable_blueprints = [
    data.available_blueprints,
    data.downloaded_blueprints,
    data.drive_recipe_blueprints,
    (data.hacked ? data.hidden_blueprints : []),
  ];

  return (
    <Window width={1200} height={600} title={data.fabricator_name}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item width="80%">
            <Section>
              {data.all_categories.map((category: string) => (
                <Collapsible open title={category} key={category}>
                  {usable_blueprints.map((blueprints: Record<string, Manufacturable[]>) => (
                    (Object.keys(blueprints).find((key) => (key === category)))
                      ? blueprints[category].map((blueprintData: Manufacturable) => (
                        (blueprintData.name.toLowerCase().includes(search)
                          ? (
                            <BlueprintButton blueprintData={blueprintData} fabricatorSpeed={data.speed} />
                          ) : null)
                      )) : null
                  ))}
                </Collapsible>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Stack vertical>
              <Stack.Item>
                <Input placeholder="Search..." width="100%" onInput={(_, value) => setSearchData(value)} />
              </Stack.Item>
              <Stack.Item>
                <Section title="Loaded Materials" textAlign="center">
                  <LabeledList>
                    {data.resource_data.map((resourceData: Resource) => (
                      <LabeledList.Item
                        key={resourceData.id}
                        buttons={[
                          <Button key="eject" icon="eject" onClick={() => act("material_eject", { "resource": resourceData.id })} />,
                          <Button key="swap" icon="add" onClick={() => act("material_swap", { "resource": resourceData.id })} />,
                        ]}
                        label={toTitleCase(resourceData.name)}
                        textAlign="center"
                      >
                        {resourceData.amount / 10}
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section
                  textAlign="center"
                  title={"Fabricator Settings"}
                >
                  <LabeledList>
                    <LabeledList.Item
                      label={"Repeat"}
                      buttons={<Button icon="repeat" onClick={() => toggleRepeat()}>Toggle Repeat</Button>}
                      textAlign="center"
                    >
                      {data.repeat ? "On" : "Off"}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Speed"
                    >
                      <Slider
                        minValue={1}
                        value={speed}
                        maxValue={3}
                        step={1}
                        stepPixelSize={100}
                        onChange={(_e: any, value: number) => updateSpeed(value)}
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Stack.Item>
              <Stack.Item>
                {data.panel_open ? <CollapsibleWireMenu indicators={data.indicators} wires={data.wires} wire_bitflags={data.wire_bitflags} /> : ""}
              </Stack.Item>
              <Stack.Item>
                <CardInfo />
              </Stack.Item>
              <Stack.Item>
                <Section
                  title="Rockbox™ Containers"
                  textAlign="center"
                >
                  {data.rockboxes.map((rockbox: Rockbox) => (
                    <LabeledList
                      key={rockbox.byondRef}
                    >
                      <LabeledList.Item>
                        {rockbox.area_name}
                      </LabeledList.Item>
                      {rockbox.ores.length !== 0 ? (rockbox.ores.map((ore: Ore) => (
                        <LabeledList.Item
                          key={ore.name}
                          label={ore.name}
                        >
                          <Button
                            textAlign="center"
                            onClick={() => act("ore_purchase", { "ore": ore.name, "storage_ref": rockbox.byondRef })}
                            icon="add"
                          >
                            {ore.cost}⪽
                          </Button>
                        </LabeledList.Item>
                      ))) : "No Ores Loaded."}
                    </LabeledList>
                  ))}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
