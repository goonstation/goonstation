/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend, useLocalState, useSharedState } from '../../backend';
import { BooleanLike } from 'common/react';
import { Window } from '../../layouts';
import { toTitleCase } from 'common/string';
import { Button, Collapsible, Divider, Input, LabeledList, ProgressBar, Section, Slider, Stack } from '../../components';
import { formatMoney } from '../../format';
import { CardInfoProps, ManufacturableData, ManufacturerData, OreData, QueueBlueprint, ResourceData, RockboxData } from './temp/type';
import { BlueprintButton } from './BlueprintButton';
import { ProductionCard } from './ProductionCard';
import { clamp } from 'common/math';
import { CollapsibleWireMenu } from './CollapsibleWireMenu';
import { pluralize } from '../common/stringUtils';

const CardInfo = (props:CardInfoProps) => {
  const {
    actionCardLogin,
    actionCardLogout,
    card_owner,
    card_balance,
  } = props;
  return (card_owner === null || card_balance === null) ? (
    <Section
      textAlign="center"
    >
      <Stack vertical>
        <Stack.Item>
          No Account Found.
        </Stack.Item>
        <Stack.Item>
          <Button icon="add" onClick={() => actionCardLogin()}>Add Account</Button>
        </Stack.Item>
      </Stack>
    </Section>
  ) : (
    <Section
      title="Account Info"
      buttons={<Button icon="minus" onClick={() => actionCardLogout()}>Log Out</Button>}
    >
      <LabeledList>
        <LabeledList.Item
          label="Owner"
        >
          {card_owner}
        </LabeledList.Item>
        <LabeledList.Item
          label="Balance"
        >
          {formatMoney(card_balance)}⪽
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
  // Define some variables used for the interface
  const blueprintWindowWidthPercentage = "80%";
  const manudriveIsUnlimited = (value:any) => value === -1;
  // Define some actions for the interface and its children
  const actionCardLogout = () => act("card", { "remove": true });
  const actionCardLogin = () => act("card", { "scan": true });
  const actionQueueRemove = (index:number) => act("remove", { "index": index+1 });
  const actionQueueTogglePause = (mode:string) => act("pause_toggle", { "action": (mode === "working") ? "pause" : "continue" });
  const actionWirePulse = (index:number) => act('wire', { action: "pulse", wire: index+1 });
  const actionWireCutOrMend = (index:number, is_cut:BooleanLike) => act("wire", { action: (is_cut ? "cut" : "mend"), wire: index+1 });
  const actionVendProduct = (byondRef:string) => act("product", { "blueprint_ref": byondRef });

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
    "drive_recipes",
    "hidden",
  ];
  /*
    Converts the blueprints we get into one larger list sorted by category.
    This is done here instead of sending one big list to reduce the amount of times we need to refresh static data.
  */
  let blueprints_by_category:Record<string, ManufacturableData[]> = {};
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


  // Get a ManufacturableData from a QueueBlueprint using its type, category, and name.
  let queueBlueprintRefs = data.queue.map((queued:QueueBlueprint) =>
    blueprints_by_category[queued.category].find((key) => (key.name === queued.name))
  );

  return (
    <Window width={1200} height={600} title={data.fabricator_name}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item grow>
            <Section>
              {data.all_categories.map((category:string) => (
                blueprints_by_category[category].length > 0 && (
                  <Collapsible
                    key={category}
                    open
                    title={`${category} (${blueprints_by_category[category].length})`}
                  >
                    {blueprints_by_category[category].map((blueprint:ManufacturableData, index:number) => (
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
                    {data.resource_data.map((resourceData: ResourceData) => (
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
                  title="Fabricator Settings"
                >
                  <LabeledList>
                    <LabeledList.Item
                      label="Repeat"
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
                        onChange={(_e: any, value: number) => act("speed", { value })}
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
                {data.manudrive.limit !== null && (
                  <Stack.Item>
                    <Section
                      title="Loaded Manudrive"
                      buttons={
                        <Button
                          icon="eject"
                          content="Eject"
                          disabled={data.mode !== "ready"}
                          onClick={() => act("manudrive", { "action": "eject" })}
                        />
                      }
                    >
                      {data.manudrive.name}
                      <Divider />
                      <LabeledList>
                        <LabeledList.Item
                          label="Fabrication Limit"
                        >
                          {manudriveIsUnlimited(data.manudrive.limit) ? "Unlimited" : `${data.manudrive.limit} ${pluralize("use", data.manudrive.limit)}`}
                        </LabeledList.Item>
                        {!manudriveIsUnlimited(data.manudrive.limit) && (
                          <LabeledList.Item
                            label="Remaining Uses"
                          >
                            {data.manudrive_uses_left}
                          </LabeledList.Item>
                        )}
                      </LabeledList>
                    </Section>
                  </Stack.Item>
                )}
                {!!data.panel_open && (
                  <Stack.Item>
                    <CollapsibleWireMenu
                      actionWirePulse={actionWirePulse}
                      actionWireCutOrMend={actionWireCutOrMend}
                      indicators={data.indicators}
                      wires={data.wires}
                      wire_bitflags={data.wire_bitflags}
                    />
                  </Stack.Item>
                )}
                <CardInfo
                  actionCardLogin={actionCardLogin}
                  actionCardLogout={actionCardLogout}
                  card_owner={data.card_owner}
                  card_balance={data.card_balance}
                />
              </Stack.Item>
              <Stack.Item>
                <Section
                  title="Rockbox™ Containers"
                  textAlign="center"
                >
                  {data.rockboxes.map((rockbox: RockboxData) => (
                    <Section
                      title={rockbox.area_name}
                      key={rockbox.byondRef}
                    >
                      {rockbox.ores.length !== 0 ? (rockbox.ores.map((ore: OreData) => (
                        <LabeledList
                          key={ore.name}
                        >
                          <LabeledList.Item
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
                        </LabeledList>
                      ))) : "No Ores Loaded."}
                    </Section>
                  ))}
                  {data.rockbox_message}
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Stack vertical>
                  {data.error !== null && (
                    <Section
                      title="ERROR"
                    >
                      {data.error}
                    </Section>
                  )}
                  {data.queue.length > 0 && (
                    <Stack.Item>
                      <ProgressBar
                        value={clamp(data.progress_pct, 0, 1)}
                        minValue={0}
                        maxValue={1}
                        position="relative"
                      />
                    </Stack.Item>
                  )}
                  {queueBlueprintRefs.map((queued:ManufacturableData, index:number) => (
                    <ProductionCard
                      key={index}
                      index={index}
                      actionQueueRemove={actionQueueRemove}
                      actionQueueTogglePause={actionQueueTogglePause}
                      mode={data.mode}
                      img={queued.img}
                      name={queued.name}
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
