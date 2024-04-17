/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend, useLocalState, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { toTitleCase } from 'common/string';
import { Box, Button, Collapsible, Divider, Input, LabeledList, ProgressBar, Section, Slider, Stack, Tooltip } from '../../components';
import { ButtonWithBadge } from '../../components/goonstation/ButtonWithBadge';
import { truncate } from '../../format';
import { formatMoney } from '../../format';
import { MaintenencePanel, Manufacturable, ManufacturerData, Ore, QueueBlueprint, Resource, Rockbox, WireData } from './type';
import { clamp, round } from 'common/math';
import { CenteredText } from '../../components/goonstation/CenteredText';

const getBlueprintTime = (time, manufacturerSpeed) => {
  return round(time / 10 / manufacturerSpeed, 0.01);
};

const ProductionCard = (params, context) => {
  const { act } = useBackend(context);
  const { data, progress_pct, index, mode } = params;
  // Simpler badge for the buttons where it doesn't matter, bottommost return for the bestest of buttons
  if (index !== 0) {
    return (
      <Stack.Item>
        <ButtonWithBadge
          width="100%"
          height={4.6}
          image_path={data.img}
          onClick={() => act("remove", { "index": index+1 })}
        >
          <CenteredText
            text={truncate(data.name, 40)}
            height={4.6}
          />
        </ButtonWithBadge>
      </Stack.Item>
    );
  }
  return (
    <Stack.Item>
      <Stack>
        <Stack.Item>
          <ButtonWithBadge
            width={16.5}
            height={4.6}
            image_path={data.img}
            onClick={() => act("remove", { "index": index+1 })}
          >
            <Stack vertical>
              <Stack.Item>
                <CenteredText text={truncate(data.name)} />
              </Stack.Item>
              <Stack.Item>
                <ProgressBar
                  value={clamp(progress_pct, 0, 1)}
                  minValue={0}
                  maxValue={1}
                  position="relative"
                  color="rgba(0,0,0,0.2)"
                />
              </Stack.Item>
            </Stack>
          </ButtonWithBadge>
        </Stack.Item>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <Button
                width={2}
                height={2}
                pt={0.5}
                pl={1.1}
                icon="trash"
                onClick={() => act("remove", { "index": index+1 })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                width={2}
                height={2}
                pl={1.3}
                pt={0.5}
                icon={(mode === "working") ? "pause" : "play"}
                onClick={() => act("pause_toggle", { "action": (mode === "working") ? "pause" : "continue" })}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const CardInfo = (_, context) => {
  const { data, act } = useBackend<ManufacturerData>(context);
  return (data.card_owner === null || data.card_balance === null) ? (
    <Section
      textAlign="center"
    >
      <Stack vertical>
        <Stack.Item>
          No Account Found.
        </Stack.Item>
        <Stack.Item>
          <Button icon="add" onClick={() => act("card", { "scan": true })}>Add Account</Button>
        </Stack.Item>
      </Stack>
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

export const CollapsibleWireMenu = (props, context) => {
  const { act } = useBackend<ManufacturerData>(context);
  const { wirePanel } = props;
  return (
    <Section
      textAlign="center"
      title="Maintenence Panel"
    >
      <LabeledList>
        {wirePanel.wires.map((wire: WireData, i: number) => (
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
              content={(is_set(wirePanel.wire_bitflags, i) !== 0) ? "Cut" : "Mend"}
              onClick={() => act("wire", { action: ((is_set(wirePanel.wire_bitflags, i) !== 0) ? "cut" : "mend"), wire: i+1 })}
            />)]}
          />
        ))}
      </LabeledList>
      <Divider />
      <LabeledList>
        <LabeledList.Item
          label="Electrification Risk"
        >
          {wirePanel.indicators.electrified ? "High" : "None"}
        </LabeledList.Item>
        <LabeledList.Item
          label="System Stability"
        >
          {wirePanel.indicators.malfunctioning ? "Unstable" : "Stable"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Inventory"
        >
          {wirePanel.indicators.hacked ? "Expanded" : "Standard"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Power"
        >
          {wirePanel.indicators.hasPower ? "Sufficient" : "Insufficient"}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

/*
Get whether or not there is a sufficient amount to make. does NOT affect sanity checks on the DM side,
this just offloads some of the computation to the client.

Consequently, if the checks on the .dm end change, this has to change as well.

Thankfully as this is mostly cosmetic, the only implication is that people might be able
to try printing blueprints that get refused, or they may not be allowed to fabricate
blueprints they should be allowed to.
*/
const GetProductionSatisfaction = (
  pattern_requirements:string[],
  amount_requirements:number[],
  materials_stored:Resource[]) =>
{
  let satisfaction:boolean[] = [];
  let availableMaterials:Record<string, number> = {};
  for (let i in pattern_requirements) {
    let required_pattern = pattern_requirements[i];
    let compatible_material:Resource = materials_stored.find((value:Resource) => (
      value.satisfies.find((satisfies_pattern:string) => (
        required_pattern === "ALL" || required_pattern === satisfies_pattern
      )) !== undefined
    ));
    if (compatible_material === undefined) {
      satisfaction.push(false);
    }
    else {
      satisfaction.push(true);
      if (Object.keys(availableMaterials).find((value:string) => (value === compatible_material.id)) === undefined) {
        availableMaterials[compatible_material.id] = compatible_material.amount;
      }
      availableMaterials[compatible_material.id] -= amount_requirements[i];
    }
  }
  return satisfaction;
};

const BlueprintButton = (props, context) => {

  const { blueprintData, materialData, manufacturerSpeed } = props;
  const { act } = useBackend(context);
  const blueprintSatisfaction:boolean[] = GetProductionSatisfaction(
    blueprintData.item_paths,
    blueprintData.item_amounts,
    materialData
  );
  const isProduceable = blueprintSatisfaction.find((value:boolean) => !(value)) === undefined;
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
      <LabeledList>
        {blueprintData.material_names.map((value:string, index:number) => (
          <LabeledList.Item
            key={index}
            labelColor={(blueprintSatisfaction[index]) ? "green" : "red"}
            label={value}
          >
            {blueprintData.item_amounts[index]/10} pieces<br />
          </LabeledList.Item>
        ))}
      </LabeledList>
      Time: {getBlueprintTime(blueprintData.time, manufacturerSpeed)}s<br />
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
          disabled={!isProduceable}
          onClick={() => act("product", { "blueprint_ref": blueprintData.byondRef })}
        >
          <CenteredText text={truncate(blueprintData.name, 40)} height={5.5} />
        </ButtonWithBadge>
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
                disabled={!isProduceable}
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
                disabled={!isProduceable}
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
  const [search, setSearchData] = useLocalState(context, "query", "");
  const [swap, setSwappingMaterial] = useLocalState(context, "swap", null);
  const wirePanel:MaintenencePanel = {
    indicators: data.indicators,
    wires: data.wires,
    wire_bitflags: data.wire_bitflags,
  };
  let toggleRepeat = () => {
    act("repeat");
    toggleRepeatVar(!repeat);
  };
  let swapPriority = (materialID: string) => {
    if (swap === null) {
      setSwappingMaterial(materialID);
    }
    else if (swap === materialID) {
      setSwappingMaterial(null);
    }
    else {
      act("material_swap", { "resource_1": swap, "resource_2": materialID });
      setSwappingMaterial(null);
    }
  };
  let getBlueprintFromQueueData = (queueData:QueueBlueprint) => {
    // "available", "hidden", "download", "drive_blueprint"
    let blueprintList = null;

    if (queueData.type === "available") {
      blueprintList = data.available_blueprints;
    }
    else if (queueData.type === "hidden") {
      blueprintList = data.hidden_blueprints;
    }
    else if (queueData.type === "download") {
      blueprintList = data.downloaded_blueprints;
    }
    else if (queueData.type === "drive_blueprint") {
      blueprintList = data.recipe_blueprints;
    }
    else {
      return null;
    }

    return blueprintList[queueData.category].find((key) => (key.name === queueData.name));
  };
  let usable_blueprints = [
    data.available_blueprints,
    data.downloaded_blueprints,
    data.recipe_blueprints,
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
                            <BlueprintButton
                              blueprintData={blueprintData}
                              manufacturerSpeed={data.speed}
                              materialData={data.resource_data}
                            />
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
                          <Button
                            key="eject"
                            icon="eject"
                            onClick={() => act("material_eject", { "resource": resourceData.id })}
                          />,
                          <Button
                            key="swap"
                            icon="arrows-up-down"
                            color={(swap !== resourceData.id) ? null : "green"}
                            onClick={() => swapPriority(resourceData.id)}
                          />,
                        ]}
                        label={toTitleCase(resourceData.name)}
                        textAlign="center"
                      >
                        {resourceData.amount}
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
                        value={data.speed}
                        maxValue={3}
                        step={1}
                        stepPixelSize={100}
                        disabled={data.mode !== "working"}
                        onChange={(_e: any, value: number) => act("speed", { "value": value })}
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
                {data.panel_open ? (
                  <Stack.Item mb={1} >
                    <CollapsibleWireMenu wirePanel={wirePanel} />
                  </Stack.Item>
                ) : null}
                <CardInfo />
              </Stack.Item>
              <Stack.Item>
                <Section
                  title="Rockbox™ Containers"
                  textAlign="center"
                >
                  {data.rockboxes.map((rockbox: Rockbox) => (
                    <Section
                      title={rockbox.area_name}
                      key={rockbox.byondRef}
                    >
                      <LabeledList>
                        {rockbox.ores.length !== 0 ? (rockbox.ores.map((ore: Ore) => (
                          <LabeledList.Item
                            key={ore.name}
                            label={ore.name}
                            textAlign="center"
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
                    </Section>
                  ))}
                  {data.rockbox_message}
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Stack vertical>
                  {data.queue.map((queued:QueueBlueprint, index:number) => (
                    <ProductionCard
                      key={index}
                      index={index}
                      data={getBlueprintFromQueueData(queued)}
                      progress_pct={data.progress_pct}
                      mode={data.mode}
                    />
                  ))}
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
