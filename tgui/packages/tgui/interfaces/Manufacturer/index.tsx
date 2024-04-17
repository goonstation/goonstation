/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend, useLocalState, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { toTitleCase } from 'common/string';
import { Button, Collapsible, Divider, Input, LabeledList, Section, Slider, Stack } from '../../components';
import { formatMoney } from '../../format';
import { MaintenencePanel, Manufacturable, ManufacturerData, Ore, QueueBlueprint, Resource, Rockbox, WireData } from './type';

import { BlueprintButton } from './blueprintButton';
import { ProductionCard } from './productionCard';

const is_set = (bits, bit) => bits & (1 << bit);

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
  // Get a Manufacturable from a QueueBlueprint using its type, category, and name.
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
