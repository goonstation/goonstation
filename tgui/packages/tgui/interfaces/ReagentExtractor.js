/**
 * @file
 * @copyright 2022
 * @author CodeJester (https://github.com/codeJester27)
 * @license ISC
 */

import { useBackend, useSharedState, useLocalState } from "../backend";
import { Button, Dimmer, Divider, Flex, NumberInput, Section, SectionEx, Stack } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';
import { NoContainer, ReagentGraph, ReagentList } from './common/ReagentInfo';

// Feel free to adjust this for performance
const extractablesPerPage = 25;

const clamp = (value, min, max) => Math.min(Math.max(min, value), max);

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
  const container = props.container || NoContainer;
  const [transferAmount, setTransferAmount] = useSharedState(context, `transferAmount_${container.id}`, 10);

  return (
    <SectionEx
      capitalize
      title={container.name}
      buttons={
        <>
          <Button
            title="Flush All"
            icon="times"
            color="red"
            disabled={!container.totalVolume}
            onClick={() => act('flush', { container_id: container.id })}
          />
          {!insertable || (
            <Button
              title="Eject"
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
      <ReagentList container={container}
        renderButtons={(reagent) => {
          return (
            <>
              <Button
                px={0.75}
                mr={1.5}
                icon="filter"
                color="red"
                title="Isolate"
                onClick={() => act('isolate', { container_id: container.id, reagent_id: reagent.id })}
              />
              <Button
                px={0.75}
                icon="times"
                color="red"
                title="Flush"
                onClick={() => act('flush_reagent', { container_id: container.id, reagent_id: reagent.id })}
              />
            </>
          );
        }}
      />
      <Flex wrap justify="center">
        <Flex.Item grow />
        <Flex.Item grow>
          <Button
            mb={0.5}
            width={17}
            textAlign="center"
            selected={container.selected}
            title="Select Extraction and Transfer Target"
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
    </SectionEx>
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
                      title="Eject"
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
              title="Previous Page"
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
              title="Next Page"
              disabled={page > totalPages - 1}
              onClick={() => setPage(page + 1)}
            />
          </Flex.Item>
        )}
      </Flex>
    </Section>
  );
};
