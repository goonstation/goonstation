import { useBackend, useSharedState, useLocalState } from "../backend";
import { Box, Button, Dimmer, Divider, Dropdown, Flex, Icon, NoticeBox, NumberInput, Section, Stack, Tabs, Tooltip } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';

const noContainer = {
  name: "No Beaker Inserted",
  id: "inserted",
  maxVolume: 100,
  totalVolume: 0,
  /*
  contents: [
    {
      name: "Reagent 1",
      volume: 10,
      colorR: 0,
      colorG: 255,
      colorB: 0,
    },
    {
      name: "Reagent 2",
      volume: 50,
      colorR: 0,
      colorG: 0,
      colorB: 255,
    },
  ],
  */
}; // PLACEHOLDER

export const ReagentExtractor = (props, context) => {
  const { act, data } = useBackend(context);

  const { containersData } = data;

  const { inserted, storage_tank_1, storage_tank_2 } = containersData;

  return (
    <Window
      title="Reagent Extractor"
      width={500}
      height={739}
      theme="ntos">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <ReagentDisplay container={inserted} insertable />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              {/* Extractables (produce) */}
              <Stack.Item grow>
                <ExtractableList />
              </Stack.Item>
              {/* Extraction Containers */}
              <Stack.Item basis={18}>
                <Stack vertical fill>
                  <Stack.Item basis={19.5} grow>
                    <ReagentDisplay container={storage_tank_1} />
                  </Stack.Item>
                  <Stack.Item basis={19.5}>
                    <ReagentDisplay container={storage_tank_2} />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ReagentDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const { insertable } = props;
  const container = props.container || noContainer;
  const [transferAmount, setTransferAmount] = useSharedState(context, `transferAmount_${container.id}`, 10);

  return (
    <Section
      title={
        <Flex inline nowrap>
          <Flex.Item grow overflow="hidden">
            {container.name}
          </Flex.Item>
          <Flex.Item px={4} /> {/* this prevents the title buttons from being overlapped by the title text */}
        </Flex>
      }
      buttons={(
        <>
          <Button
            tooltip="Flush All"
            icon="times"
            color="red"
            disabled={!container.totalVolume}
            onClick={() => act('flush', { container_id: container.id })}
          />
          {!insertable || (
            <Button
              tooltip="Eject"
              icon="eject"
              disabled={!props.container}
              onClick={() => act('ejectcontainer')}
            />
          )}
        </>
      )}>
      {!!props.container || (
        <Dimmer>
          <Button
            icon="eject"
            fontSize={1.5}
            onClick={() => act('insertcontainer')}
            bold>
            Insert Beaker
          </Button>
        </Dimmer>
      )}
      <ReagentGraph container={container} />
      <Divider />
      <ReagentList container={container} />
      <Flex wrap justify="center">
        <Flex.Item grow />
        <Flex.Item grow>
          <Button
            mb={0.5}
            width={17}
            textAlign="center"
            selected={container.selected}
            icon={container.selected ? "check-square-o" : "square-o"}
            onClick={() => act('extractto', { container_id: container.id })}
          >
            Select
          </Button>
        </Flex.Item>
        <Flex.Item>
          <Flex width={17}>
            <Flex.Item grow>
              <Button
                disabled={container.selected}
                onClick={() => act('chemtransfer', { container_id: container.id, amount: transferAmount })}
              >
                Transfer
              </Button>
              <NumberInput
                value={transferAmount}
                format={value => value + "u"}
                minValue={1}
                maxValue={500}
                onDrag={(e, value) => setTransferAmount(value)}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                disabled={container.selected}
                onClick={() => act('chemtransfer', { container_id: container.id, amount: 500 })}
              >
                Transfer All
              </Button>
            </Flex.Item>
          </Flex>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const ReagentGraph = (props, context) => {
  const { container } = props;
  const { maxVolume, totalVolume } = container;
  const contents = container.contents || [];

  return (
    <Flex>
      {contents.map((reagent, index) => (
        <Flex.Item grow={reagent.volume/maxVolume} key={index}>
          <Tooltip content={reagent.name + " (" + reagent.volume + "u)"} position="bottom">
            <Box
              py={3}
              px={0}
              my={0}
              backgroundColor={"rgba(" + reagent.colorR + ", " + reagent.colorG + ", " + reagent.colorB + ", 1)"}
            />
          </Tooltip>
        </Flex.Item>
      ))}
      <Flex.Item grow={((maxVolume - totalVolume)/maxVolume)}>
        <Tooltip content={"Nothing (" + (maxVolume - totalVolume) + "u)"} position="bottom">
          <NoticeBox
            py={3}
            px={0}
            my={0}
            backgroundColor="rgba(0,0,0,0)" // invisible noticebox kind of nice
          />
        </Tooltip>
      </Flex.Item>
    </Flex>
  );
};

const ReagentList = (props, context) => {
  const { act } = useBackend(context);
  const { container } = props;
  const contents = container.contents || [];

  return (
    <Section scrollable>
      <Box height={6}>
        {contents.length ? contents.map((reagent, index) => (
          <Flex key={reagent.id} mb={0.5}>
            <Flex.Item grow>
              <Icon
                pr={0.9}
                name="circle"
                style={{
                  "text-shadow": "0 0 3px #000;",
                }}
                color={"rgba(" + reagent.colorR + ", " + reagent.colorG + ", " + reagent.colorB + ", 1)"}
              />
              {`( ${reagent.volume}u ) ${reagent.name}`}
            </Flex.Item>
            <Flex.Item>
              <Button
                px={0.5}
                icon="times"
                color="red"
                tooltip="Flush"
                onClick={() => act('flush_reagent', { container_id: container.id, reagent_id: reagent.id })}
              />
            </Flex.Item>
          </Flex>
        )) : (
          <Box color="label">
            <Icon
              pr={0.9}
              name="circle-o"
              style={{
                "text-shadow": "0 0 3px #000;",
              }}
            />
            Empty
          </Box>)}
      </Box>
    </Section>
  );
};

const ExtractableList = (props, context) => {
  const { act, data } = useBackend(context);
  const { autoextract } = data;
  const extractables = data.ingredientsData || [];
  return (
    <Section fill scrollable
      title="Extractable Items"
      buttons={(
        <Button.Checkbox
          checked={autoextract}
          onClick={() => act('autoextract')}>
          Auto-Extract
        </Button.Checkbox>
      )}>
      {extractables.map((extractable, index) => (
        <Fragment key={extractable.id}>
          <Flex my={0.5}>
            <Flex.Item grow>
              {extractable.name + ": " + extractable.id}
            </Flex.Item>
            <Flex.Item nowrap>
              <Button
                onClick={() => act('extractingredient', { ingredient_id: extractable.id })}
              >
                Extract
              </Button>
              <Button
                icon="eject"
                tooltip="Eject"
                onClick={() => act('ejectingredient', { ingredient_id: extractable.id })}
              />
            </Flex.Item>
          </Flex>
          <Divider /> {/* this is sometimes more thin than it should be and I have no idea why */}
        </Fragment>
      ))}
    </Section>
  );
};
