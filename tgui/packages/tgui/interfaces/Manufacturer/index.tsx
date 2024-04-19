/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend, useLocalState, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { toTitleCase } from 'common/string';
import { Button, Collapsible, Input, LabeledList, ProgressBar, Section, Slider, Stack } from '../../components';
import { formatMoney } from '../../format';
import { MaintenencePanel, Manufacturable, ManufacturerData, Ore, QueueBlueprint, Resource, Rockbox } from './type';

import { BlueprintButton } from './blueprintButton';
import { ProductionCard } from './productionCard';
import { clamp } from 'common/math';
import { CollapsibleWireMenu } from './collapsibleWireMenu';

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
  const all_blueprint_lists = [
    data.available_blueprints,
    data.downloaded_blueprints,
    data.recipe_blueprints,
    data.hidden_blueprints,
  ];
  const all_blueprint_list_strings = [
    "available",
    "download",
    "drive_blueprint",
    "hidden",
  ];
  // Get a Manufacturable from a QueueBlueprint using its type, category, and name.
  let getBlueprintFromQueueData = (queueData:QueueBlueprint) => {
    let index_from_type = all_blueprint_list_strings.findIndex((type:string) => (type === queueData.type));
    let targetList = all_blueprint_lists[index_from_type];
    return targetList[queueData.category].find((key) => (key.name === queueData.name));
  };
  /*
    Converts the blueprints we get into one larger list sorted by category.
    This is done here instead of sending one big list to reduce the amount of times we need to refresh static data.
  */
  let blueprints_by_category:Record<string, Manufacturable[]> = {};
  let test = "";
  for (let category_index = 0; category_index < data.all_categories.length; category_index++) {
    let category = data.all_categories[category_index];
    blueprints_by_category[category] = [];
    for (let blueprint_index = 0; blueprint_index < all_blueprint_lists.length; blueprint_index++) {
      if (!data.hacked && (all_blueprint_list_strings[blueprint_index] === "hidden")) {
        continue;
      }
      let blueprint_list = all_blueprint_lists[blueprint_index];
      if (blueprint_list[category] === undefined) {
        continue;
      }
      for (let blueprint of blueprint_list[category]) {
        if (blueprint.name.toLowerCase().includes(search)) {
          blueprints_by_category[blueprint.category].push(blueprint);
        }
      }
    }
  }
  return (
    <Window width={1200} height={600} title={data.fabricator_name}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item width="80%">
            <Section>
              {test}
              {data.all_categories.map((category:string) => (
                blueprints_by_category[category].length > 0 && (
                  <Collapsible
                    key={category}
                    open
                    title={`${category} (${blueprints_by_category[category].length})`}
                  >
                    {blueprints_by_category[category].map((blueprint:Manufacturable, index:number) => (
                      <BlueprintButton
                        key={index}
                        blueprintData={blueprint}
                        manufacturerSpeed={data.speed}
                        materialData={data.resource_data}
                      />
                    ))}
                  </Collapsible>
                )
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
                        maxValue={data.hacked ? data.max_speed_hacked : data.max_speed_normal}
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
                  {data.queue.length > 0 ? (
                    <Stack.Item>
                      <ProgressBar
                        value={clamp(data.progress_pct, 0, 1)}
                        minValue={0}
                        maxValue={1}
                        position="relative"
                      />
                    </Stack.Item>
                  ) : null}
                  {data.queue.map((queued:QueueBlueprint, index:number) => (
                    <ProductionCard
                      key={index}
                      index={index}
                      data={getBlueprintFromQueueData(queued)}
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
