/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend, useLocalState } from '../../backend';
import { Window } from '../../layouts';
import { is_set } from '../common/bitflag';
import { clamp } from 'common/math';
import { toTitleCase } from 'common/string';
import { pluralize } from '../common/stringUtils';
import { Box, Button, Collapsible, Dimmer, Divider, Input, LabeledList, ProgressBar, Section, Stack } from '../../components';
import { ManufacturableData, ManufacturerData, OreData, QueueBlueprint, ResourceData, RockboxData } from './type';
import { AccessLevels, MANUDRIVE_UNLIMITED, RockboxStyle, SETTINGS_WINDOW_WIDTH } from './constant';
import { BlueprintButton } from './components/BlueprintButton';
import { CardInfo } from './components/CardInfo';
import { CollapsibleWireMenu } from './components/CollapsibleWireMenu';
import { ProductionCard } from './components/ProductionCard';
import { PowerAlertModal } from './components/PowerAlertModal';
import { ManufacturerSettings } from './components/ManufacturerSettings';

export const Manufacturer = (_, context) => {
  const { act, data } = useBackend<ManufacturerData>(context);
  const [search, setSearchData] = useLocalState(context, "query", "");
  const [swappingMaterialRef, setSwappingMaterialRef] = useLocalState<string | null>(context, "swap", null);
  // Define some actions for the interface and its children
  const actionCardLogout = () => act("card", { "remove": true });
  const actionCardLogin = () => act("card", { "scan": true });
  const actionQueueClear = () => act("clear");
  const actionQueueRemove = (index:number) => act("remove", { "index": index+1 });
  const actionQueueTogglePause = (mode:string) => act("pause_toggle", { "action": (mode === "working") ? "pause" : "continue" });
  const actionWirePulse = (index:number) => act('wire', { action: "pulse", wire: index+1 });
  const actionWireCutOrMend = (index:number) => act("wire", { action: ((is_set(data.wire_bitflags, data.wires[index]-1)) ? "cut" : "mend"), wire: index+1 });
  const actionVendProduct = (byondRef:string) => act("request_product", { "blueprint_ref": byondRef });
  const actionRemoveBlueprint = (byondRef:string) => act("delete", { "blueprint_ref": byondRef });
  const actionSetSpeed = (new_speed:number) => act("speed", { "value": new_speed });
  const actionRepeat = () => act("repeat");
  // Local states for pleasant UX while selecting one button (highlight green) and then second button (perform action)
  let swapPriority = (materialRef: string) => {
    if (swappingMaterialRef === null) {
      setSwappingMaterialRef(materialRef);
    }
    else if (swappingMaterialRef === materialRef) {
      setSwappingMaterialRef(null);
    }
    else {
      act("material_swap", { "resource_1": swappingMaterialRef, "resource_2": materialRef });
      setSwappingMaterialRef(null);
    }
  };
  const hasPower = !!data.indicators?.hasPower;
  const manudriveName = data.manudrive?.name ?? "";
  const manudriveLimit = data.manudrive?.limit;
  const all_blueprints = {
    available: data.available_blueprints,
    download: data.downloaded_blueprints,
    drive_recipes: data.recipe_blueprints,
    hidden: data.hidden_blueprints,
  };
  const blueprint_types = Object.keys(all_blueprints);
  /*
    Converts the blueprints we get into one larger list sorted by category.
    This is done here instead of sending one big list to reduce the amount of times we need to refresh static data.
  */
  let blueprints_by_category:Record<string, ManufacturableData[]> = {};
  for (let category_index = 0; category_index < (data.all_categories?.length ?? 0); category_index++) {
    let category = data.all_categories[category_index];
    blueprints_by_category[category] = [];
    for (let blueprint_index = 0; blueprint_index < blueprint_types.length; blueprint_index++) {
      const category_name = blueprint_types[blueprint_index];
      if (!data.hacked && (category_name === "hidden")) {
        continue;
      }
      let blueprint_list = all_blueprints[category_name];
      if (blueprint_list[category] === undefined) {
        continue;
      }
      for (let blueprint of blueprint_list[category]) {
        if (blueprint.name?.toLowerCase().includes(search)) {
          blueprints_by_category[blueprint.category].push(blueprint);
        }
      }
    }
  }

  // Get a ManufacturableData from a QueueBlueprint using its type, category, and name.
  const queueBlueprintRefs = (data.queue ?? []).map((queued:QueueBlueprint) =>
    blueprints_by_category?.[queued.category]?.find((blueprint) => (blueprint.name === queued.name))
  );

  return (
    <Window width={1200} height={600} title={data.fabricator_name}>
      {!hasPower && <PowerAlertModal width={100-SETTINGS_WINDOW_WIDTH} height={"100%"} />}
      <Window.Content scrollable>
        <Stack>
          <Stack.Item grow>
            <Section>
              {!hasPower && <Dimmer />}
              {data.all_categories?.map((category:string) => (
                blueprints_by_category[category].length > 0 && (
                  <Collapsible
                    key={category}
                    open
                    title={`${category} (${blueprints_by_category[category].length})`}
                  >
                    {(blueprints_by_category[category] ?? []).map((blueprint, index) => (
                      <BlueprintButton
                        actionRemoveBlueprint={actionRemoveBlueprint}
                        actionVendProduct={actionVendProduct}
                        key={index}
                        blueprintData={blueprint}
                        manufacturerSpeed={data.speed}
                        materialData={data.resource_data}
                        deleteAllowed={data.delete_allowed !== AccessLevels.DENIED}
                        hasPower={!!data.indicators?.hasPower}
                      />
                    ))}
                  </Collapsible>
                )
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item width={SETTINGS_WINDOW_WIDTH}>
            <Stack vertical>
              <Stack.Item>
                <Input placeholder="Search..." width="100%" onInput={(_, value) => setSearchData(value)} />
              </Stack.Item>
              <Stack.Item>
                <Section title="Loaded Materials" textAlign="center">
                  <LabeledList>
                    {data.resource_data?.map((resourceData: ResourceData) => (
                      <LabeledList.Item
                        key={resourceData.byondRef}
                        buttons={
                          <>
                            <Button
                              icon="eject"
                              onClick={() => act("material_eject", { "resource": resourceData.byondRef })}
                            />
                            <Button
                              icon="arrows-up-down"
                              color={(swappingMaterialRef !== resourceData.byondRef) ? null : "green"}
                              onClick={() => swapPriority(resourceData.byondRef)}
                            />
                          </>
                        }
                        label={toTitleCase(resourceData.name)}
                        textAlign="center"
                      >
                        {resourceData.amount.toFixed(1).padStart(5, '\u2007')}
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                </Section>
              </Stack.Item>
              <ManufacturerSettings
                repeat={data.repeat}
                hacked={data.hacked}
                speed={data.speed}
                max_speed_normal={data.max_speed_normal}
                max_speed_hacked={data.max_speed_hacked}
                mode={data.mode}
                actionSetSpeed={actionSetSpeed}
                actionRepeat={actionRepeat}
              />
              {(manudriveLimit !== null) && (
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
                    {manudriveName}
                    <Divider />
                    <LabeledList>
                      <LabeledList.Item
                        label="Fabrication Limit"
                      >
                        {(manudriveLimit === MANUDRIVE_UNLIMITED) ? "Unlimited" : `${manudriveLimit} ${pluralize("use", manudriveLimit)}`}
                      </LabeledList.Item>
                      {(manudriveLimit !== MANUDRIVE_UNLIMITED) && (
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
              <Stack.Item>
                <CardInfo
                  actionCardLogin={actionCardLogin}
                  actionCardLogout={actionCardLogout}
                  banking_info={data.banking_info}
                />
              </Stack.Item>
              <Stack.Item>
                <Section
                  title="Rockbox™ Containers"
                  textAlign="center"
                >
                  {data.rockboxes?.map((rockbox: RockboxData) => (
                    <Box
                      key={rockbox.byondRef}
                    >
                      <Box
                        mt={RockboxStyle.MarginTop}
                        textAlign="left"
                        bold
                      >
                        {rockbox.area_name}
                        <Divider />
                      </Box>

                      <LabeledList>
                        {(rockbox?.ores?.length) ? (rockbox.ores.map((ore: OreData) => (
                          <LabeledList.Item
                            key={ore.name}
                            label={ore.name}
                            textAlign="center"
                            buttons={
                              <Button
                                key={ore.name}
                                textAlign="center"
                                onClick={() => act("ore_purchase", { "ore": ore.name, "storage_ref": rockbox.byondRef })}
                              >
                                {ore.cost}⪽
                              </Button>
                            }
                          >
                            {ore.amount.toString().padStart(5, '\u2007')}
                          </LabeledList.Item>
                        ))) : "No Ores Loaded."}
                      </LabeledList>
                    </Box>
                  ))}
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
                  <Stack
                    textAlign="center"
                  >
                    <Stack.Item
                      width="50%"
                    >
                      <Button
                        icon={data.mode !== "working" ? "play" : "pause"}
                        onClick={() => actionQueueTogglePause(data.mode)}
                        width="100%"
                      >
                        {data.mode !== "working" ? "Resume" : "Pause"}
                      </Button>
                    </Stack.Item>
                    <Stack.Item
                      grow
                    >
                      <Button
                        icon="trash"
                        onClick={() => actionQueueClear()}
                        width="100%"
                      >
                        Clear Queue
                      </Button>
                    </Stack.Item>
                  </Stack>
                  {(data?.queue?.length > 0) && (
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
                    queued && (
                      <ProductionCard
                        key={index}
                        index={index}
                        actionQueueRemove={actionQueueRemove}
                        mode={data.mode}
                        img={queued.img}
                        name={queued.name}
                      />
                    )
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
