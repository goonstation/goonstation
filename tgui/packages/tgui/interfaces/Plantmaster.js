/**
 * @file
 * @copyright 2022
 * @author Amylizzle (https://github.com/amylizzle)
 * @license MIT
 */

import { useBackend, useSharedState, useLocalState } from "../backend";
import { Button, Dimmer, Divider, Flex, NumberInput, Section, Box, Dropdown, Tabs, SectionEx, Stack, Table } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';
import { NoContainer, ReagentGraph, ReagentList } from './common/ReagentInfo';
import { TableCell, TableRow } from "../components/Table";
import { clamp } from 'common/math';

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
      width={1000}
      height={450}>
      <Window.Content>
        <Tabs buttons={(
          <Button
            icon="eject"
            onClick={() => inserted_container !== null ? act('ejectbeaker') : act('insertbeaker')}
            bold>
            {inserted_container !== null ? inserted : "Insert Beaker"}
          </Button>
        )}>
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
        {category === 'splicing' && <PlantSplice seeds={seeds} seedoutput={seedoutput} chance={splice_chance} />}
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
            onClick={() => act('insertbeaker')}
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
            Items ready for extraction: <b>{cat_lens[0]}</b> <br />
            Seeds ready for experimentation: <b>{cat_lens[1]}</b>
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
                <b>Damage</b>
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
                <TableRow style={extractable.splicing[1] ? {
                  'box-shadow': '0px 0px 10px green',
                  'border-color': 'green',
                  'border-style': 'outset',
                  'border-radius': '4px',
                  'horizontal-align': 'middle',
                  'vertical-align': 'middle' } : ''}>
                  <TableCell bold={extractable.name[1]} >
                    {extractable.name[0]}
                  </TableCell>
                  <TableCell bold={extractable.damage[1]} >
                    {extractable.damage[0]}%
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
                          icon="fill-drip"
                          title="Infuse"
                          disabled={!extractable.allow_infusion[1]}
                          onClick={() => act('infuse', { infuse_ref: extractable.ref[0] })}
                        />
                        <Button
                          icon="code-branch"
                          title="Splice"
                          onClick={() => act('splice_select', { splice_select_ref: extractable.ref[0] })}
                        />
                        <Button
                          icon="search"
                          title="Analyze"
                          onClick={() => act('analyze', { analyze_ref: extractable.ref[0] })}
                        />
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


const PlantSplice = (props, context) => {
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
                <b>Damage</b>
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
                  <TableCell bold={extractable.damage[1]} >
                    {extractable.damage[0]}%
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
                          icon="search"
                          title="Analyze"
                          onClick={() => act('analyze', { analyze_ref: extractable.ref[0] })}
                        />
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
                          icon="seedling"
                          title="Extract Seeds"
                          onClick={() => act('extract', { extract_ref: extractable.ref[0] })}
                        />
                        <Button
                          icon="search"
                          title="Analyze"
                          onClick={() => act('analyze', { analyze_ref: extractable.ref[0] })}
                        />
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
