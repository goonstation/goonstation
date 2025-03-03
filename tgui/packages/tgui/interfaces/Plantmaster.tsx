/**
 * @file
 * @copyright 2022
 * @author Amylizzle (https://github.com/amylizzle)
 * @license MIT
 */

import { useState } from 'react';
import {
  Box,
  Button,
  Dimmer,
  NumberInput,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { clamp } from 'tgui-core/math';

import { useBackend } from '../backend';
import { truncate } from '../format';
import { Window } from '../layouts';
import { NoContainer, ReagentGraph, ReagentList } from './common/ReagentInfo';
import { capitalize } from './common/stringUtils';

const headings = [
  'name',
  'species',
  'damage',
  'count',
  'genome',
  'generation',
  'maturity rate',
  'production rate',
  'lifespan',
  'yield',
  'potency',
  'endurance',
  'controls',
];
const sortname = [
  'name',
  'species',
  'damage',
  'count',
  'genome',
  'generation',
  'growtime',
  'harvesttime',
  'lifespan',
  'cropsize',
  'potency',
  'endurance',
  '',
];

interface PlantmasterData {
  extractables;
  seeds;
  category;
  category_lengths;
  inserted;
  inserted_container;
  seedoutput;
  splice_chance;
  show_splicing;
  splice_seeds;
  sortBy;
  sortAsc;
}

export const Plantmaster = () => {
  const { act, data } = useBackend<PlantmasterData>();
  const {
    extractables,
    seeds,
    category,
    category_lengths,
    inserted,
    inserted_container,
    seedoutput,
    splice_chance,
    show_splicing,
    splice_seeds,
    sortBy,
    sortAsc,
  } = data;
  const [page, setPage] = useState(1);
  return (
    <Window title="Plantmaster Mk4" width={1200} height={450}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={category === 'overview'}
                onClick={() => {
                  act('change_tab', { tab: 'overview' });
                }}
              >
                Overview
              </Tabs.Tab>
              <Tabs.Tab
                selected={category === 'extractables'}
                onClick={() => {
                  act('change_tab', { tab: 'extractables' });
                }}
              >
                Seed Extraction ({category_lengths[0]})
              </Tabs.Tab>
              <Tabs.Tab
                selected={category === 'seedlist'}
                onClick={() => {
                  act('change_tab', { tab: 'seedlist' });
                }}
              >
                Seeds ({category_lengths[1]})
              </Tabs.Tab>
              <Tabs.Tab
                backgroundColor={inserted_container !== null ? 'green' : 'blue'}
                selected={inserted_container !== null}
                icon="eject"
                onClick={() =>
                  inserted_container !== null
                    ? act('ejectbeaker')
                    : act('insertbeaker')
                }
                bold
              >
                {inserted_container !== null ? inserted : 'Insert Beaker'}
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {category === 'overview' && (
              <PlantOverview
                cat_lens={category_lengths}
                container={inserted ? inserted_container : null}
                seedoutput={seedoutput}
              />
            )}
            {category === 'extractables' && (
              <PlantExtractables
                seedoutput={seedoutput}
                produce={extractables}
                sortBy={sortBy}
                sortAsc={sortAsc}
                page={page}
                setPage={setPage}
              />
            )}
            {category === 'seedlist' && (
              <PlantSeeds
                seeds={seeds}
                seedoutput={seedoutput}
                splicing={show_splicing}
                splice_chance={splice_chance}
                splice_seeds={splice_seeds}
                sortBy={sortBy}
                sortAsc={sortAsc}
                page={page}
                setPage={setPage}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const compare = function (a, b, sortBy, sortAsc) {
  if (sortBy === 'name' || sortBy === 'species') {
    if (sortAsc) {
      return (a[sortBy] ?? '').toString().localeCompare(b[sortBy] ?? '');
    } else {
      return (b[sortBy] ?? '').toString().localeCompare(a[sortBy] ?? '');
    }
  }
  if (sortAsc) {
    return parseFloat(a[sortBy]) - parseFloat(b[sortBy]);
  } else {
    return parseFloat(b[sortBy]) - parseFloat(a[sortBy]);
  }
};

const ReagentDisplay = (props) => {
  const { act } = useBackend<PlantmasterData>();
  const container = props.container || NoContainer;

  return (
    <Section title={capitalize(container.name)}>
      {!!props.container || (
        <Dimmer>
          <Button
            icon="eject"
            fontSize={1.5}
            onClick={() => act('insertbeaker')}
            bold
          >
            Insert Beaker
          </Button>
        </Dimmer>
      )}
      <ReagentGraph container={container} />
      <ReagentList container={container} />
    </Section>
  );
};

const PlantOverview = (props) => {
  const { cat_lens, container } = props;
  return (
    <Section title="Overview">
      <Box>
        Items ready for extraction: <b>{cat_lens[0]}</b> <br />
        Seeds ready for experimentation: <b>{cat_lens[1]}</b>
      </Box>
      <ReagentDisplay container={container} />
    </Section>
  );
};
const TitleRow = (props) => {
  const { act } = useBackend<PlantmasterData>();
  const { show_damage, sortBy, sortAsc } = props;

  return (
    <Table.Row className="candystripe">
      {headings.map(
        (heading, index) =>
          (show_damage || (heading !== 'damage' && heading !== 'count')) && (
            <Table.Cell key={heading} textAlign="center">
              <Button
                color="transparent"
                icon={
                  sortBy !== '' && sortBy === sortname[index]
                    ? sortAsc
                      ? 'angle-up'
                      : 'angle-down'
                    : ''
                }
                onClick={() =>
                  act('sort', {
                    sortBy: sortname[index],
                    asc: sortBy === sortname[index] ? !sortAsc : sortAsc,
                  })
                }
              >
                <b>{capitalize(heading)}</b>
              </Button>
            </Table.Cell>
          ),
      )}
    </Table.Row>
  );
};
const PlantRow = (props) => {
  const { act } = useBackend<PlantmasterData>();
  const { extractable, show_damage, infuse, extract, splice, splice_disable } =
    props;
  return (
    <Table.Row className="candystripe">
      <Table.Cell width="100px" textAlign="center">
        <Button.Input
          width="100px"
          tooltip="Click to rename"
          color="transparent"
          textColor="#FFFFFF"
          defaultValue={extractable.name[0]}
          currentValue={extractable.name[0]}
          onCommit={(_e, new_name) =>
            act('label', {
              label_ref: extractable.ref[0],
              label_new: new_name,
            })
          }
        >
          {truncate(extractable.name[0], 10)}
        </Button.Input>
      </Table.Cell>
      <Table.Cell
        width="100px"
        textAlign="center"
        verticalAlign="middle"
        bold={extractable.species[1]}
        backgroundColor={extractable.species[1] ? '#333333' : ''}
      >
        {extractable.species[0]}
      </Table.Cell>
      {show_damage && (
        <Table.Cell
          textAlign="center"
          verticalAlign="middle"
          bold={extractable.damage[1]}
          backgroundColor={extractable.damage[1] ? '#333333' : ''}
        >
          {extractable.damage[0]}%
        </Table.Cell>
      )}
      {show_damage && (
        <Table.Cell
          textAlign="center"
          verticalAlign="middle"
          bold={extractable.charges[1]}
          backgroundColor={extractable.charges[1] ? '#333333' : ''}
        >
          {extractable.charges[0]}
        </Table.Cell>
      )}
      <Table.Cell
        textAlign="center"
        verticalAlign="middle"
        bold={extractable.genome[1]}
        backgroundColor={extractable.genome[1] ? '#333333' : ''}
      >
        {extractable.genome[0]}
      </Table.Cell>
      <Table.Cell
        textAlign="center"
        verticalAlign="middle"
        bold={extractable.generation[1]}
        backgroundColor={extractable.generation[1] ? '#333333' : ''}
      >
        {extractable.generation[0]}
      </Table.Cell>
      <Table.Cell
        textAlign="center"
        verticalAlign="middle"
        bold={extractable.growtime[1]}
        backgroundColor={extractable.growtime[1] ? '#333333' : ''}
      >
        {extractable.growtime[0]}
      </Table.Cell>
      <Table.Cell
        textAlign="center"
        verticalAlign="middle"
        bold={extractable.harvesttime[1]}
        backgroundColor={extractable.harvesttime[1] ? '#333333' : ''}
      >
        {extractable.harvesttime[0]}
      </Table.Cell>
      <Table.Cell
        textAlign="center"
        verticalAlign="middle"
        bold={extractable.lifespan[1]}
        backgroundColor={extractable.lifespan[1] ? '#333333' : ''}
      >
        {extractable.lifespan[0]}
      </Table.Cell>
      <Table.Cell
        textAlign="center"
        verticalAlign="middle"
        bold={extractable.cropsize[1]}
        backgroundColor={extractable.cropsize[1] ? '#333333' : ''}
      >
        {extractable.cropsize[0]}
      </Table.Cell>
      <Table.Cell
        textAlign="center"
        verticalAlign="middle"
        bold={extractable.potency[1]}
        backgroundColor={extractable.potency[1] ? '#333333' : ''}
      >
        {extractable.potency[0]}
      </Table.Cell>
      <Table.Cell
        textAlign="center"
        verticalAlign="middle"
        bold={extractable.endurance[1]}
        backgroundColor={extractable.endurance[1] ? '#333333' : ''}
      >
        {extractable.endurance[0]}
      </Table.Cell>
      <Table.Cell textAlign="center" verticalAlign="middle" nowrap>
        {infuse && (
          <Button
            icon="fill-drip"
            tooltip="Infuse"
            disabled={!extractable.allow_infusion[1]}
            onClick={() => act('infuse', { infuse_ref: extractable.ref[0] })}
          />
        )}
        {extract && (
          <Button
            icon="seedling"
            tooltip="Extract Seeds"
            onClick={() => act('extract', { extract_ref: extractable.ref[0] })}
          />
        )}
        {splice && (
          <Button
            disabled={!extractable.splicing[1] && splice_disable}
            icon={extractable.splicing[1] ? 'window-close' : 'code-branch'}
            color={extractable.splicing[1] ? 'red' : ''}
            tooltip={extractable.splicing[1] ? 'Cancel Splice' : 'Splice'}
            onClick={() =>
              act('splice_select', {
                splice_select_ref: extractable.ref[0],
              })
            }
          />
        )}
        <Button
          icon="search"
          tooltip="Analyze"
          onClick={() => act('analyze', { analyze_ref: extractable.ref[0] })}
        />
        <Button
          icon="eject"
          tooltip="Eject"
          onClick={() => act('eject', { eject_ref: extractable.ref[0] })}
        />
      </Table.Cell>
    </Table.Row>
  );
};

const PlantSeeds = (props) => {
  const { act } = useBackend<PlantmasterData>();
  const {
    seedoutput,
    seeds,
    splicing,
    splice_seeds,
    splice_chance,
    sortBy,
    sortAsc,
    page,
    setPage,
  } = props;
  const extractables = (seeds || []).sort((a, b) =>
    compare(a, b, sortBy, sortAsc),
  );
  const extractablesPerPage = splicing ? 7 : 10;
  const totalPages = Math.max(
    1,
    Math.ceil(extractables.length / extractablesPerPage),
  );
  if (page < 1 || page > totalPages) setPage(clamp(page, 1, totalPages));
  const extractablesOnPage = extractables.slice(
    extractablesPerPage * (page - 1),
    extractablesPerPage * (page - 1) + extractablesPerPage,
  );
  const splice_disable = splice_seeds[0] !== null && splice_seeds[1] !== null;
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section
          title="Seeds"
          fill
          scrollable
          scrollableHorizontal
          buttons={
            <>
              <Button
                icon="eject"
                tooltip="All seeds will be ejected from the Plantmaster"
                onClick={() => act('ejectseeds')}
              >
                Eject All
              </Button>
              <Button
                icon="caret-left"
                tooltip="Previous Page"
                disabled={page < 2}
                onClick={() => setPage(page - 1)}
              />
              <NumberInput
                value={page}
                format={(value) => 'Page ' + value + '/' + totalPages}
                minValue={1}
                maxValue={totalPages}
                step={1}
                stepPixelSize={15}
                onChange={(value) => setPage(value)}
              />
              <Button
                icon="caret-right"
                tooltip="Next Page"
                disabled={page > totalPages - 1}
                onClick={() => setPage(page + 1)}
              />
              <Button.Checkbox
                checked={!seedoutput}
                tooltip="Seeds will be extracted into the Plantmaster."
                onClick={() => act('outputmode')}
              >
                Output Internally
              </Button.Checkbox>
            </>
          }
        >
          {' '}
          <Table>
            <TitleRow show_damage sortBy={sortBy} sortAsc={sortAsc} />
            {extractablesOnPage.map((extractable, index) => (
              <PlantRow
                extractable={extractable}
                key={extractable.ref[1]}
                show_damage
                infuse
                splice
                splice_disable={splice_disable}
              />
            ))}
          </Table>
        </Section>
      </Stack.Item>
      {splicing && (
        <Stack.Item>
          <Section
            title="Splicing"
            scrollable
            scrollableHorizontal
            buttons={
              <>
                {`Splice Chance: ${splice_chance}%`}
                <Button ml={1} onClick={() => act('splice')}>
                  Splice
                </Button>
              </>
            }
          >
            <Table>
              <TitleRow show_damage sortBy={sortBy} sortAsc={sortAsc} />
              {splice_seeds
                .filter((x) => x !== null)
                .sort((a, b) => compare(a, b, sortBy, sortAsc))
                .map((extractable) => (
                  <PlantRow
                    extractable={extractable}
                    key={extractable.ref[1]}
                    show_damage
                    infuse
                    splice
                  />
                ))}
            </Table>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};

const PlantExtractables = (props, context) => {
  const { act } = useBackend<PlantmasterData>();
  const { seedoutput, produce, sortBy, sortAsc, page, setPage } = props;
  const extractables = (produce || []).sort((a, b) =>
    compare(a, b, sortBy, sortAsc),
  );
  const extractablesPerPage = 10;
  const totalPages = Math.max(
    1,
    Math.ceil(extractables.length / extractablesPerPage),
  );
  if (page < 1 || page > totalPages) {
    setPage(clamp(page, 1, totalPages));
  }
  const extractablesOnPage = extractables.slice(
    extractablesPerPage * (page - 1),
    extractablesPerPage * (page - 1) + extractablesPerPage,
  );

  return (
    <Section
      title="Extractable Items"
      scrollable
      scrollableHorizontal
      buttons={
        <>
          <Button
            icon="eject"
            tooltip="All produce will be ejected from the Plantmaster"
            onClick={() => act('ejectextractables')}
          >
            Eject All
          </Button>
          <Button
            icon="caret-left"
            tooltip="Previous Page"
            disabled={page < 2}
            onClick={() => setPage(page - 1)}
          />
          <NumberInput
            value={page}
            format={(value) => 'Page ' + value + '/' + totalPages}
            minValue={1}
            maxValue={totalPages}
            step={1}
            stepPixelSize={15}
            onChange={(value) => setPage(value)}
          />
          <Button
            icon="caret-right"
            tooltip="Next Page"
            disabled={page > totalPages - 1}
            onClick={() => setPage(page + 1)}
          />
          <Button.Checkbox
            checked={!seedoutput}
            tooltip="Seeds will be extracted into the Plantmaster."
            onClick={() => act('outputmode')}
          >
            Output Internally
          </Button.Checkbox>
        </>
      }
    >
      <Table>
        <TitleRow sortBy={sortBy} sortAsc={sortAsc} />
        {extractablesOnPage.map((extractable) => (
          <PlantRow
            extractable={extractable}
            key={extractable.ref[1]}
            extract
          />
        ))}
      </Table>
    </Section>
  );
};
