import { useBackend, useLocalState, useSharedState } from "../backend";
import { Flex, Button, Stack, Tabs, Icon, Box, Section, Dropdown } from "../components";
import { Window } from '../layouts';

const FlockPartitions = (props, context) => {
  const { act } = useBackend(context);
  const {
    partitions,
  } = props;
  return (
    <Stack vertical>
      {partitions.map(partition => {
        return (
          <Stack.Item key={partition.ref}>
            <Stack align="center" height="100%">
              {/* name */}
              <Stack.Item width="20%" height="100%">
                <Section align="center" height="100%">
                  {partition.name}
                </Section>
              </Stack.Item>
              {/* show host if they are in one */}
              <Stack.Item height="100%" grow={1}>
                <Section height="100%">
                  {partition.host
                  && (
                    <Stack>
                      <Stack.Item><Icon name="wifi" size={3} /></Stack.Item>
                      <Stack.Item>
                        <Stack vertical align="center">
                          <Stack.Item>{partition.host}</Stack.Item>
                          <Stack.Item >{partition.health}<Icon name="heart" /></Stack.Item>
                        </Stack>
                      </Stack.Item>
                    </Stack>
                  )}
                </Section>
              </Stack.Item>
              {/* buttons */}
              <Stack.Item height="100%">
                <Section height="100%">
                  <Stack>
                    {partition.host
                    && (
                      <Stack.Item>
                        <Button onClick={() => act('eject_trace', { 'origin': partition.ref })} >
                          Eject
                        </Button>
                      </Stack.Item>
                    )}
                    <Stack.Item>
                      <Button onClick={() => act('delete_trace', { 'origin': partition.ref })} >
                        Remove sentience
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button onClick={() => act('jump_to', { 'origin': partition.ref })} >
                        Jump
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

// basic sorting function for numbers and strings
const compare = function (a, b, sortBy) {
  if (!isNaN(a[sortBy]) && !isNaN(b[sortBy])) {
    return b[sortBy] - a[sortBy];
  }
  return ('' + a[sortBy]).localeCompare(b[sortBy]);
};

// maps drone tasks to icons
const iconLookup = {
  "thinking": "brain",
  "shooting": "bolt",
  "rummaging": "dumpster",
  "wandering": "question",
  "building": "hammer",
  "harvesting": "cogs",
  "controlled": "wifi",
  "replicating": "egg",
  "rallying": "map-marker",
  "opening container": "box-open",
  "butchering": "recycle",
  "repairing": "tools",
  "capturing": "bars",
  "deposit": "puzzle-piece",
};
const taskIcon = function (task) {
  let iconString = iconLookup[task];
  if (iconString) {
    return <Icon size={3} name={iconString} />;
  }
  return "";
};

const capitalizeString = function (string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
};

const FlockDrones = (props, context) => {
  const { act } = useBackend(context);
  const {
    drones,
    sortBy,
  } = props;
  return (
    <Stack vertical>
      {drones
        .sort(
          (a, b) => (compare(a, b, sortBy))
        ).map(drone => {
          return (
            <Stack.Item key={drone.ref}>
              <Stack>
                {/* name, health and resources */}
                <Stack.Item width="20%">
                  <Section height="100%">
                    <Stack vertical align="center">
                      <Stack.Item >{drone.name}</Stack.Item>
                      <Stack.Item >{drone.health}<Icon name="heart" /> {drone.resources}<Icon name="cog" /></Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
                {/* area and task */}
                <Stack.Item grow={1}>
                  <Section height="100%">
                    <Stack align="center">
                      <Stack.Item width="50px">
                        <Box align="center">
                          {taskIcon(drone.task)}
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <b>{drone.area}</b> <br /> {capitalizeString(drone.task)}
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
                {/* buttons */}
                <Stack.Item>
                  <Section height="100%">
                    <Stack>
                      {drone.task === "controlled"
                          && (
                            <Stack.Item>
                              <Button onClick={() => act('eject_trace', { 'origin': drone.controller_ref })} >
                                Eject Trace
                              </Button>
                            </Stack.Item>
                          )}
                      <Stack.Item>
                        <Button onClick={() => act('rally', { 'origin': drone.ref })} >
                          Rally
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button onClick={() => act('jump_to', { 'origin': drone.ref })} >
                          Jump
                        </Button>
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>

              </Stack>
            </Stack.Item>
          );
        })}
    </Stack>
  );
};

// TODO: actual structure information (power draw/generation etc.)
const FlockStructures = (props, context) => {
  const { act } = useBackend(context);
  const { structures } = props;
  return (
    <Stack vertical>
      {structures.map(structure => {
        return (
          <Stack.Item key={structure.ref}>
            <Stack>
              {/* name and health */}
              <Stack.Item grow={1}>
                <Section>
                  <Stack vertical align="center">
                    <Stack.Item >{structure.name}</Stack.Item>
                    <Stack.Item >{structure.health}<Icon name="heart" /></Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              {/* buttons */}
              <Stack.Item>
                <Section height="100%">
                  <Stack>
                    {structure.name === "Construction Tealprint"
                          && (
                            <Stack.Item>
                              <Button onClick={() => act('cancel_tealprint', { 'origin': structure.ref })} >
                                Cancel
                              </Button>
                            </Stack.Item>
                          )}
                    <Stack.Item>
                      <Button onClick={() => act('jump_to', { 'origin': structure.ref })} >
                        Jump
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>

            </Stack>
          </Stack.Item>
        );
      })}
    </Stack>
  );
};


const FlockEnemies = (props, context) => {
  const { act } = useBackend(context);
  const { enemies } = props;
  return (
    <Stack vertical>
      {enemies.map(enemy => {
        return (
          <Stack.Item key={enemy.ref}>
            <Stack>
              {/* name and remove button */}
              <Stack.Item width="30%">
                <Section height="100%">
                  {enemy.name}
                </Section>
              </Stack.Item>
              {/* area and jump button */}
              <Stack.Item grow={1}>
                <Section height="100%">
                  <Stack>
                    <Stack.Item grow={1}>
                      <b>{enemy.area}</b>
                    </Stack.Item>

                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section height="100%">
                  <Stack>
                    <Stack.Item>
                      <Button icon="times" onClick={() => act('remove_enemy', { 'origin': enemy.ref })} >
                        Remove
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button onClick={() => act('jump_to', { 'origin': enemy.ref })} >
                        Jump
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>

            </Stack>
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

export const FlockPanel = (props, context) => {
  const { data, act } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 1);
  const [sortBy, setSortBy] = useLocalState(context, 'sortBy', 'resources');
  const {
    vitals,
    partitions,
    drones,
    structures,
    enemies,
  } = data;
  return (
    <Window
      theme="flock"
      title={"Flockmind " + vitals.name}
      width={600}
      height={450}
    >
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={tabIndex === 1}
            onClick={() => setTabIndex(1)}>
            Drones {"(" + drones.length + ")"}
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === 2}
            onClick={() => setTabIndex(2)}>
            Partitions {"(" + partitions.length + ")"}
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === 3}
            onClick={() => setTabIndex(3)}>
            Structures {"(" + structures.length + ")"}
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === 4}
            onClick={() => setTabIndex(4)}>
            Enemies {"(" + enemies.length + ")"}
          </Tabs.Tab>
        </Tabs>

        {tabIndex === 1
        && (
          <Box>
            <Dropdown
              options={["name", "health", "resources", "area"]}
              selected="resources"
              onSelected={(value) => setSortBy(value)}
            />
            <FlockDrones drones={drones} sortBy={sortBy} />
          </Box>
        )}
        {tabIndex === 2 && <FlockPartitions partitions={partitions} />}
        {tabIndex === 3 && <FlockStructures structures={structures} />}
        {tabIndex === 4 && <FlockEnemies enemies={enemies} />}
      </Window.Content>
    </Window>
  );
};
