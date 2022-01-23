import { useBackend, useSharedState, useLocalState } from "../backend";
import { Box, Button, ColorBox, Dimmer, Divider, Flex, Icon, NoticeBox, NumberInput, Section, Stack, Tooltip } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';

// Feel free to adjust this for performance
const extractablesPerPage = 25;

const clamp = (value, min, max) => Math.min(Math.max(min, value), max);

const noContainer = {
  name: "No Beaker Inserted",
  id: "inserted",
  maxVolume: 100,
  totalVolume: 0,
  fake: true,
};

export const ReagentExtractor = (props, context) => {
  const { data } = useBackend(context);

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
          {/* Insertable Container */}
          <Stack.Item basis={19.5}>
            <ReagentDisplay container={inserted} insertable />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              {/* Extractables (produce) */}
              <Stack.Item grow>
                <ExtractableList />
              </Stack.Item>
              {/* Storage Tanks */}
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
  const { act } = useBackend(context);
  const { insertable } = props;
  const container = props.container || noContainer;
  const [transferAmount, setTransferAmount] = useSharedState(context, `transferAmount_${container.id}`, 10);

  return (
    <Section
      title={
        <Flex inline nowrap>
          <Flex.Item grow
            overflow="hidden"
            style={{
              "text-overflow": "ellipsis",
              "text-transform": "capitalize",
            }}>
            {container.name}
          </Flex.Item>
          <Flex.Item px={4} /> {/* this prevents the title buttons from being overlapped by the title text */}
        </Flex>
      }
      buttons={
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
      }>
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
      <ReagentList container={container} />
      <Flex wrap justify="center">
        <Flex.Item grow />
        <Flex.Item grow>
          <Button
            mb={0.5}
            width={17}
            textAlign="center"
            selected={container.selected}
            tooltip="Select Extraction and Transfer Target"
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
  const { maxVolume, totalVolume, finalColor } = container;
  const contents = container.contents || [];

  return (
    <>
      <Flex>
        {contents.map((reagent, index) => (
          <Flex.Item grow={reagent.volume/maxVolume} key={reagent.id}>
            <Tooltip content={`${reagent.name} (${reagent.volume}u)`} position="bottom">
              <Box
                py={3}
                px={0}
                my={0}
                backgroundColor={`rgb(${reagent.colorR}, ${reagent.colorG}, ${reagent.colorB})`}
              />
            </Tooltip>
          </Flex.Item>
        ))}
        <Flex.Item grow={((maxVolume - totalVolume)/maxVolume)}>
          <Tooltip content={`Nothing (${maxVolume - totalVolume}u)`} position="bottom">
            <NoticeBox
              py={3}
              px={0}
              my={0}
              backgroundColor="rgba(0, 0, 0, 0)" // invisible noticebox kind of nice
            />
          </Tooltip>
        </Flex.Item>
      </Flex>
      <Tooltip
        content={
          <Box>
            <ColorBox color={finalColor} /> Current Mixture Color
          </Box>
        }
        position="bottom">
        <Box height="14px" // same height as a Divider
          backgroundColor={contents.length ? finalColor : "rgba(0, 0, 0, 0.1)"}
          textAlign="center">
          {container.fake || (
            <Box
              as="span"
              backgroundColor="rgba(0, 0, 0, 0.5)"
              px={1}>
              {`${totalVolume}/${maxVolume}`}
            </Box>
          )}
        </Box>
      </Tooltip>
    </>
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
                color={`rgb(${reagent.colorR}, ${reagent.colorG}, ${reagent.colorB})`}
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
  const [page, setPage] = useLocalState(context, 'page', 1);
  const totalPages = Math.max(1, Math.ceil(extractables.length / extractablesPerPage));
  if (page < 1 || page > totalPages) setPage(clamp(page, 1, totalPages));
  const extractablesOnPage = extractables.slice(extractablesPerPage*(page - 1),
    extractablesPerPage*(page - 1) + extractablesPerPage);

  return (
    <Section fill
      title="Extractable Items"
      buttons={(
        <Button.Checkbox
          checked={autoextract}
          tooltip="Items will be extracted into the selected container automatically upon insertion."
          onClick={() => act('autoextract')}>
          Auto-Extract
        </Button.Checkbox>
      )}>
      <Flex height="100%" direction="column">
        <Flex.Item grow>
          <Section scrollable fill>
            {extractablesOnPage.map((extractable, index) => (
              <Fragment key={extractable.id}>
                <Flex>
                  <Flex.Item grow>
                    {extractable.name}
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
                <Divider />
              </Fragment>
            ))}
          </Section>
        </Flex.Item>
        {totalPages < 2 || (
          <Flex.Item textAlign="center" basis={1.5}>
            <Button
              icon="caret-left"
              tooltip="Previous Page"
              disabled={page < 2}
              onClick={() => setPage(page - 1)}
            />
            <NumberInput
              value={page}
              format={value => "Page " + value + "/" + totalPages}
              minValue={1}
              maxValue={totalPages}
              stepPixelSize={15}
              onChange={(e, value) => setPage(value)}
            />
            <Button
              icon="caret-right"
              tooltip="Next Page"
              disabled={page > totalPages - 1}
              onClick={() => setPage(page + 1)}
            />
          </Flex.Item>
        )}
      </Flex>
    </Section>
  );
};
