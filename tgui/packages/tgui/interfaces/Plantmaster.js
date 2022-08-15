
import { useBackend, useSharedState, useLocalState } from "../backend";
import { Button, Dimmer, Divider, Flex, NumberInput, Section, Box, Dropdown, Tabs, SectionEx, Stack, Table } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';
import { NoContainer, ReagentGraph, ReagentList } from './common/ReagentInfo';
import { TableCell, TableRow } from "../components/Table";


/**
 * @file
 * @copyright 2022
 * @author Amylizzle (https://github.com/amylizzle)
 * @license MIT
 */

/**
*		<th><abbr title="Plant species">Type</abbr></th>
*   <th class="genes"><abbr title="Genome">GN</abbr></th>
*   <th class="genes"><abbr title="Generation">Gen</abbr></th>
*   <th class="genes"><abbr title="Maturity Rate (how fast the plant reaches maturity)">MR<sup>?</sup></abbr></th>
*   <th class="genes"><abbr title="Production Rate (how fast the plant produces harvests)">PR<sup>?</sup></abbr></th>
*   <th class="genes"><abbr title="Lifespan (how many harvests it gives; higher is better)">LS<sup>?</sup></abbr></th>
*   <th class="genes"><abbr title="Yield (how many crops are produced per harvest; higher is better)">Y<sup>?</sup>
</abbr></th>
*   <th class="genes"><abbr title="Potency (how potent crops are; higher is better)">P<sup>?</sup></abbr></th>
*   <th class="genes"><abbr title="Endurance (how resilient to damage the plant is; higher is better)">E<sup>?</sup>
</abbr></th>
 */

export const Plantmaster = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    extractables,
    seeds,
    category,
    category_lengths,
    inserted,
    inserted_container,
    seedoutput,
    splice_chance,
  } = data;
  return (
    <Window
      resizable
      title="Plantmaster Mk4"
      width={800}
      height={400}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={category === 'overview'}
            onClick={() => {
              act('change_tab', { 'tab': 'overview' });
            }}>
            Overview
          </Tabs.Tab>
          <Tabs.Tab
            selected={category === 'extractables'}
            onClick={() => {
              act('change_tab', { 'tab': 'extractables' });
            }}>
            Seed Extraction {`(${category_lengths[0]})`}
          </Tabs.Tab>
          <Tabs.Tab
            selected={category === 'seedlist'}
            onClick={() => {
              act('change_tab', { 'tab': 'seedlist' });
            }}>
            Seeds {`(${category_lengths[1]})`}
          </Tabs.Tab>
          <Tabs.Tab
            selected={category === 'splicing'}
            onClick={() => {
              act('change_tab', { 'tab': 'splicing' });
            }}>
            Splicing
          </Tabs.Tab>
        </Tabs>

        {category === 'overview' && <PlantOverview cat_lens={category_lengths} container={inserted ? inserted_container : null} seedoutput={seedoutput} />}
        {category === 'extractables' && <PlantExtractables extractables={extractables} />}
        {category === 'seedlist' && <PlantSeeds seeds={seeds} />}
        {category === 'splicing' && <PlantSplice seeds={seeds} seedoutput={seedoutput} />}
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
      title={container.name}>
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
    </SectionEx>
  );
};

const PlantOverview = (props, context) => {
  const { act } = useBackend(context);
  const { cat_lens, container } = props;
  return (
    <SectionEx
      capitalize
      title={"Overview"}
    >
      <Flex height="100%" direction="column">
        <Flex.Item grow>
          <Box>
            Extractables: {cat_lens[0]}
            Seeds: {cat_lens[1]}
          </Box>
          <ReagentDisplay container={container} />
        </Flex.Item>
      </Flex>
    </SectionEx>
  );
};

const PlantSeeds = (props, context) => {
  const { act, data } = useBackend(context);
  const { seedoutput } = data;
  const extractables = data.seeds || [];
  const extractablesPerPage = 10;
  const [page, setPage] = useLocalState(context, 'page', 1);
  const totalPages = Math.max(1, Math.ceil(extractables.length / extractablesPerPage));
  if (page < 1 || page > totalPages) setPage(clamp(page, 1, totalPages));
  const extractablesOnPage = extractables.slice(extractablesPerPage*(page - 1),
    extractablesPerPage*(page - 1) + extractablesPerPage);

  return (
    <Section fill
      title="Seeds"
      buttons={(
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
          <Button.Checkbox
            checked={!seedoutput}
            tooltip="Seeds will be extracted into the Plantmaster."
            onClick={() => act('outputmode')}>
            Output Internally
          </Button.Checkbox>
        </Flex.Item>
      )}>
      <Flex height="100%" direction="column">
        <Flex.Item grow>
          <Table>
            <TableRow>
              <TableCell>
                <b>Name</b>
              </TableCell>
              <TableCell>
                <b>Genome</b>
              </TableCell>
              <TableCell>
                <b>Generation</b>
              </TableCell>
              <TableCell>
                <b>Maturity Rate</b>
              </TableCell>
              <TableCell>
                <b>Production Rate</b>
              </TableCell>
              <TableCell>
                <b>Lifespan</b>
              </TableCell>
              <TableCell>
                <b>Yield</b>
              </TableCell>
              <TableCell>
                <b>Potency</b>
              </TableCell>
              <TableCell>
                <b>Endurance</b>
              </TableCell>
              <TableCell>
                <b>Controls</b>
              </TableCell>
            </TableRow>

            {extractablesOnPage.map((extractable, index) => (
              <Fragment key={extractable.ref[0]}>
                <TableRow>
                  <TableCell bold={extractable.name[1]} >
                    {extractable.name[0]}
                  </TableCell>
                  <TableCell bold={extractable.genome[1]} >
                    {extractable.genome[0]}
                  </TableCell>
                  <TableCell bold={extractable.generation[1]} >
                    {extractable.generation[0]}
                  </TableCell>
                  <TableCell bold={extractable.growtime[1]} >
                    {extractable.growtime[0]}
                  </TableCell>
                  <TableCell bold={extractable.harvesttime[1]} >
                    {extractable.harvesttime[0]}
                  </TableCell>
                  <TableCell bold={extractable.lifespan[1]} >
                    {extractable.lifespan[0]}
                  </TableCell>
                  <TableCell bold={extractable.cropsize[1]} >
                    {extractable.cropsize[0]}
                  </TableCell>
                  <TableCell bold={extractable.potency[1]} >
                    {extractable.potency[0]}
                  </TableCell>
                  <TableCell bold={extractable.endurance[1]} >
                    {extractable.endurance[0]}
                  </TableCell>
                  <TableCell>
                    <Flex>
                      <Flex.Item nowrap>
                        <Button
                          onClick={() => act('splice', { extract_ref: extractable.ref[0] })}
                        >
                          Splice
                        </Button>
                        <Button
                          icon="eject"
                          title="Eject"
                          onClick={() => act('eject', { eject_ref: extractable.ref[0] })}
                        />
                      </Flex.Item>
                    </Flex>
                  </TableCell>
                </TableRow>
                <Divider />
              </Fragment>
            ))}

          </Table>
        </Flex.Item>
      </Flex>
    </Section>
  );
};


const PlantSplice = (props, context) => {};


const PlantExtractables = (props, context) => {
  const { act, data } = useBackend(context);
  const { seedoutput } = data;
  const extractables = data.extractables || [];
  const extractablesPerPage = 10;
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
          checked={!seedoutput}
          tooltip="Seeds will be extracted into the Plantmaster."
          onClick={() => act('outputmode')}>
          Output Internally
        </Button.Checkbox>
      )}>
      <Flex height="100%" direction="column">
        <Flex.Item grow>
          <Table>
            <TableRow>
              <TableCell>
                <b>Name</b>
              </TableCell>
              <TableCell>
                <b>Genome</b>
              </TableCell>
              <TableCell>
                <b>Generation</b>
              </TableCell>
              <TableCell>
                <b>Maturity Rate</b>
              </TableCell>
              <TableCell>
                <b>Production Rate</b>
              </TableCell>
              <TableCell>
                <b>Lifespan</b>
              </TableCell>
              <TableCell>
                <b>Yield</b>
              </TableCell>
              <TableCell>
                <b>Potency</b>
              </TableCell>
              <TableCell>
                <b>Endurance</b>
              </TableCell>
              <TableCell>
                <b>Controls</b>
              </TableCell>
            </TableRow>

            {extractablesOnPage.map((extractable, index) => (
              <Fragment key={extractable.ref[0]}>
                <TableRow>
                  <TableCell bold={extractable.name[1]} >
                    {extractable.name[0]}
                  </TableCell>
                  <TableCell bold={extractable.genome[1]} >
                    {extractable.genome[0]}
                  </TableCell>
                  <TableCell bold={extractable.generation[1]} >
                    {extractable.generation[0]}
                  </TableCell>
                  <TableCell bold={extractable.growtime[1]} >
                    {extractable.growtime[0]}
                  </TableCell>
                  <TableCell bold={extractable.harvesttime[1]} >
                    {extractable.harvesttime[0]}
                  </TableCell>
                  <TableCell bold={extractable.lifespan[1]} >
                    {extractable.lifespan[0]}
                  </TableCell>
                  <TableCell bold={extractable.cropsize[1]} >
                    {extractable.cropsize[0]}
                  </TableCell>
                  <TableCell bold={extractable.potency[1]} >
                    {extractable.potency[0]}
                  </TableCell>
                  <TableCell bold={extractable.endurance[1]} >
                    {extractable.endurance[0]}
                  </TableCell>
                  <TableCell>
                    <Flex>
                      <Flex.Item nowrap>
                        <Button
                          onClick={() => act('extract', { extract_ref: extractable.ref[0] })}
                        >
                          Extract
                        </Button>
                        <Button
                          icon="eject"
                          title="Eject"
                          onClick={() => act('eject', { eject_ref: extractable.ref[0] })}
                        />
                      </Flex.Item>
                    </Flex>
                  </TableCell>
                </TableRow>
                <Divider />
              </Fragment>
            ))}

          </Table>
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
