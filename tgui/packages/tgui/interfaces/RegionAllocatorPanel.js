/**
 * @file
 * @copyright 2024
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Button, Divider, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

const RegionItem = ({ region, removeRegion, gotoRegion, gotoRegionCenter }) => (
  <LabeledList>
    <LabeledList.Item
      label="Name"
      buttons={
        <Button.Confirm
          icon="trash"
          color="bad"
          tooltip="Deallocate"
          onClick={() => removeRegion(region.ref)} />
      }
    >
      {region.name ? region.name : region.ref}
    </LabeledList.Item>
    <LabeledList.Item
      label="Source Turf"
      buttons={
        <>
          <Button
            icon="location-dot"
            tooltip="Jump to Source"
            onClick={() => gotoRegion(region.ref)} />
          <Button
            icon="arrows-to-dot"
            tooltip="Jump to Center"
            onClick={() => gotoRegionCenter(region.ref)} />
        </>
      }
    >
      {`${region.x}, ${region.y}, ${region.z}`}
    </LabeledList.Item>
    <LabeledList.Item label="Width">{`${region.width} tiles`}</LabeledList.Item>
    <LabeledList.Item label="Height">{`${region.height} tiles`}</LabeledList.Item>
  </LabeledList>
);

export const RegionAllocatorPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { regions } = data;

  const customRegion = () => act('customRegion');
  const loadPrefab = () => act('loadPrefab');
  const loadFile = () => act('loadFile');
  const removeRegion = ref => act('removeRegion', { ref });
  const gotoRegion = ref => act('gotoRegion', { ref });
  const gotoRegionCenter = ref => act('gotoRegionCenter', { ref });

  return (
    <Window title="Region Allocator" width={500} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section title="Allocate New Region">
              <Button content="Custom Region" onClick={customRegion} />
              <Button content="Load Prefab" onClick={loadPrefab} />
              <Button content="Load From File" onClick={loadFile} />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Current Allocations" fill scrollable>
              <Stack vertical>
                {regions ? regions.map(region => (
                  <Stack.Item key={region.ref}>
                    <RegionItem
                      region={region}
                      removeRegion={removeRegion}
                      gotoRegion={gotoRegion}
                      gotoRegionCenter={gotoRegionCenter}
                    />
                    <Divider />
                  </Stack.Item>
                )) : null}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
