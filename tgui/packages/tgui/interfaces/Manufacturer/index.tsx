/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { toTitleCase } from 'common/string';
import { useCallback, useMemo, useState } from 'react';
import {
  Button,
  Collapsible,
  Dimmer,
  Divider,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { clamp } from 'tgui-core/math';
import { pluralize } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { is_set } from '../common/bitflag';
import { useHashedMemo } from '../common/hooks';
import { BlueprintButton } from './components/BlueprintButton';
import { CardInfo } from './components/CardInfo';
import { CollapsibleWireMenu } from './components/CollapsibleWireMenu';
import { ManufacturerSettings } from './components/ManufacturerSettings';
import { PowerAlertModal } from './components/PowerAlertModal';
import { ProductionCard } from './components/ProductionCard';
import { Rockbox } from './components/Rockbox';
import {
  AccessLevels,
  MANUDRIVE_UNLIMITED,
  SETTINGS_WINDOW_WIDTH,
} from './constant';
import {
  ManufacturableData,
  ManufacturerData,
  ResourceData,
  RockboxData,
} from './type';

export const Manufacturer = () => {
  const { act, data } = useBackend<ManufacturerData>();
  const {
    all_categories,
    available_blueprints,
    banking_info,
    delete_allowed,
    downloaded_blueprints,
    error,
    fabricator_name,
    hacked,
    hidden_blueprints,
    indicators,
    manudrive,
    manudrive_uses_left,
    max_speed_hacked,
    max_speed_normal,
    mode,
    panel_open,
    progress_pct,
    queue,
    recipe_blueprints,
    repeat,
    resource_data,
    producibility_data,
    rockboxes,
    speed,
    wire_bitflags,
    wires,
  } = data;
  const [search, setSearchData] = useState('');
  const [swappingMaterialRef, setSwappingMaterialRef] = useState<string | null>(
    null,
  );
  const staticActions = useMemo(
    () => ({
      handleBlueprintRemove: (byondRef: string) =>
        act('delete', { blueprint_ref: byondRef }),
      handleCardLogout: () => act('card', { remove: true }),
      handleCardLogin: () => act('card', { scan: true }),
      handleOrePurchase: (rockboxRef: string, oreName: string) =>
        act('ore_purchase', {
          ore: oreName,
          storage_ref: rockboxRef,
        }),
      handleProductVend: (byondRef: string) =>
        act('request_product', { blueprint_ref: byondRef }),
      handleQueueClear: () => act('clear'),
      handleQueueRemove: (index: number) => act('remove', { index: index + 1 }),
      handleQueueTogglePause: (mode: string) =>
        act('pause_toggle', {
          action: mode === 'working' ? 'pause' : 'continue',
        }),
      handleRepeatToggle: () => act('repeat'),
      handleSpeedSet: (newSpeed: number) => act('speed', { value: newSpeed }),

      handleWirePulse: (index: number) =>
        act('wire', { action: 'pulse', wire: index + 1 }),
    }),
    [act],
  );
  const handleWireCutOrMend = useCallback(
    (index: number) =>
      act('wire', {
        action: is_set(wire_bitflags, wires[index] - 1) ? 'cut' : 'mend',
        wire: index + 1,
      }),
    [act, wire_bitflags, wires],
  );
  // Local states for pleasant UX while selecting one button (highlight green) and then second button (perform action)
  const handleSwapPriority = useCallback(
    (materialRef: string) => {
      if (swappingMaterialRef === null) {
        setSwappingMaterialRef(materialRef);
      } else if (swappingMaterialRef === materialRef) {
        setSwappingMaterialRef(null);
      } else {
        act('material_swap', {
          resource_1: swappingMaterialRef,
          resource_2: materialRef,
        });
        setSwappingMaterialRef(null);
      }
    },
    [act, swappingMaterialRef],
  );
  const hasPower = !!indicators?.hasPower;
  const manudriveName = manudrive?.name ?? '';
  const manudriveLimit = manudrive?.limit;

  // Only change producibility_data if it actually changes. Not doing this will cause issues for performance with blueprint buttons.
  const diffedProducibilityData = useHashedMemo(producibility_data);

  // Converts the blueprints we get into one larger list sorted by category.
  // This is done here instead of sending one big list to reduce the amount of times we need to refresh static data.
  const blueprints_by_category = useMemo(() => {
    const all_blueprints = {
      available: available_blueprints,
      download: downloaded_blueprints,
      drive_recipes: recipe_blueprints,
      hidden: hidden_blueprints,
    };
    const blueprint_types = Object.keys(all_blueprints);
    const blueprints_by_category: Record<string, ManufacturableData[]> = {};
    for (
      let category_index = 0;
      category_index < (all_categories?.length ?? 0);
      category_index++
    ) {
      let category = all_categories[category_index];
      blueprints_by_category[category] = [];
      for (
        let blueprint_index = 0;
        blueprint_index < blueprint_types.length;
        blueprint_index++
      ) {
        const category_name = blueprint_types[blueprint_index];
        if (!hacked && category_name === 'hidden') {
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
    return blueprints_by_category;
  }, [
    all_categories,
    available_blueprints,
    downloaded_blueprints,
    hacked,
    hidden_blueprints,
    recipe_blueprints,
    search,
  ]);

  // Get a ManufacturableData from a QueueBlueprint using its type, category, and name.
  const queueBlueprintRefs = useMemo(
    () =>
      (queue ?? []).reduce((acc, cur) => {
        const manufacturableData = blueprints_by_category[cur.category]?.find(
          (blueprint) => blueprint.name === cur.name,
        );
        if (manufacturableData) {
          acc.push(manufacturableData);
        }
        return acc;
      }, [] as ManufacturableData[]),
    [blueprints_by_category, queue],
  );

  return (
    <Window width={1200} height={600} title={fabricator_name}>
      {!hasPower && (
        <PowerAlertModal width={100 - SETTINGS_WINDOW_WIDTH} height="100%" />
      )}
      <Window.Content scrollable>
        <Stack>
          <Stack.Item grow>
            <Section>
              {!hasPower && <Dimmer />}
              {all_categories?.map(
                (category: string) =>
                  blueprints_by_category[category].length > 0 && (
                    <Collapsible
                      key={category}
                      open
                      title={`${category} (${blueprints_by_category[category].length})`}
                    >
                      {(blueprints_by_category[category] ?? []).map(
                        (blueprint, index) => (
                          <BlueprintButton
                            key={index}
                            onBlueprintRemove={
                              staticActions.handleBlueprintRemove
                            }
                            onVendProduct={staticActions.handleProductVend}
                            blueprintData={blueprint}
                            manufacturerSpeed={speed}
                            blueprintProducibilityData={
                              diffedProducibilityData[blueprint.byondRef]
                            }
                            deleteAllowed={
                              delete_allowed !== AccessLevels.DENIED
                            }
                            hasPower={!!indicators?.hasPower}
                          />
                        ),
                      )}
                    </Collapsible>
                  ),
              )}
            </Section>
          </Stack.Item>
          <Stack.Item width={SETTINGS_WINDOW_WIDTH}>
            <Stack vertical>
              <Stack.Item>
                <Input
                  placeholder="Search..."
                  width="100%"
                  onChange={(value) => setSearchData(value)}
                />
              </Stack.Item>
              <Stack.Item>
                <Section title="Loaded Materials" textAlign="center">
                  <LabeledList>
                    {resource_data?.map((resourceData: ResourceData) => (
                      <LabeledList.Item
                        key={resourceData.byondRef}
                        buttons={
                          <>
                            <Button
                              icon="eject"
                              onClick={() =>
                                act('material_eject', {
                                  resource: resourceData.byondRef,
                                })
                              }
                            />
                            <Button
                              icon="arrows-up-down"
                              color={
                                swappingMaterialRef !== resourceData.byondRef
                                  ? null
                                  : 'green'
                              }
                              onClick={() =>
                                handleSwapPriority(resourceData.byondRef)
                              }
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
                repeat={repeat}
                hacked={hacked}
                speed={speed}
                max_speed_normal={max_speed_normal}
                max_speed_hacked={max_speed_hacked}
                mode={mode}
                onSpeedSet={staticActions.handleSpeedSet}
                onRepeatToggle={staticActions.handleRepeatToggle}
              />
              {manudriveLimit !== null && (
                <Stack.Item>
                  <Section
                    title="Loaded Manudrive"
                    buttons={
                      <Button
                        icon="eject"
                        disabled={mode !== 'ready'}
                        onClick={() => act('manudrive', { action: 'eject' })}
                      >
                        Eject
                      </Button>
                    }
                  >
                    {manudriveName}
                    <Divider />
                    <LabeledList>
                      <LabeledList.Item label="Fabrication Limit">
                        {manudriveLimit === MANUDRIVE_UNLIMITED
                          ? 'Unlimited'
                          : `${manudriveLimit} ${pluralize('use', manudriveLimit)}`}
                      </LabeledList.Item>
                      {manudriveLimit !== MANUDRIVE_UNLIMITED && (
                        <LabeledList.Item label="Remaining Uses">
                          {manudrive_uses_left}
                        </LabeledList.Item>
                      )}
                    </LabeledList>
                  </Section>
                </Stack.Item>
              )}
              {!!panel_open && (
                <Stack.Item>
                  <CollapsibleWireMenu
                    onWirePulse={staticActions.handleWirePulse}
                    onWireCutOrMend={handleWireCutOrMend}
                    indicators={indicators}
                    wires={wires}
                    wire_bitflags={wire_bitflags}
                  />
                </Stack.Item>
              )}
              <Stack.Item>
                <CardInfo
                  onCardLogin={staticActions.handleCardLogin}
                  onCardLogout={staticActions.handleCardLogout}
                  banking_info={banking_info}
                />
              </Stack.Item>
              <Stack.Item>
                <Section title="Rockbox™ Containers" textAlign="center">
                  {rockboxes?.map((rockbox: RockboxData) => (
                    <Rockbox
                      key={rockbox.byondRef}
                      data={rockbox}
                      onPurchase={staticActions.handleOrePurchase}
                    />
                  ))}
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Stack vertical>
                  {error !== null && <Section title="ERROR">{error}</Section>}
                  <Stack textAlign="center">
                    <Stack.Item width="50%">
                      <Button
                        icon={mode !== 'working' ? 'play' : 'pause'}
                        onClick={() =>
                          staticActions.handleQueueTogglePause(mode)
                        }
                        width="100%"
                      >
                        {mode !== 'working' ? 'Resume' : 'Pause'}
                      </Button>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        icon="trash"
                        onClick={staticActions.handleQueueClear}
                        width="100%"
                      >
                        Clear Queue
                      </Button>
                    </Stack.Item>
                  </Stack>
                  {queue?.length > 0 && (
                    <Stack.Item>
                      <ProgressBar
                        value={clamp(progress_pct, 0, 1)}
                        minValue={0}
                        maxValue={1}
                        position="relative"
                      />
                    </Stack.Item>
                  )}
                  {queueBlueprintRefs.map((queued, index) => (
                    <ProductionCard
                      key={index}
                      index={index}
                      onQueueRemove={staticActions.handleQueueRemove}
                      mode={mode}
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
