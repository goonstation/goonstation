import { useBackend } from '../backend';
import { Button, Divider, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

const RegionItem = ({ region, removeRegion, gotoRegion }) => (
  <LabeledList>
    <LabeledList.Item
      label="Label"
      buttons={
        <Button.Confirm
          icon="trash"
          color="bad"
          onClick={() => removeRegion(region.ref)} />
      }
    >
      {region.label ? region.label : region.ref}
    </LabeledList.Item>
    <LabeledList.Item label="Source Turf"
      buttons={
        <Button
          icon="location-dot"
          onClick={() => gotoRegion(region.ref)} />
      }
    >
      {`${region.x}, ${region.y}, ${region.z} `}
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

  return (
    <Window title="Region Allocator" width={500} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section title="Allocate New Region" >
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
