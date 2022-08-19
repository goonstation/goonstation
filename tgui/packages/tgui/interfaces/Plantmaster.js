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
import { capitalize } from './common/stringUtils';
import { truncate } from '../format';

const headings = ["name", "species", "damage", "genome", "generation", "maturity rate", "production rate", "lifespan", "yield", "potency", "endurance", "controls"];
const sortname = ["name", "species", "damage", "genome", "generation", "growtime", "harvesttime", "lifespan", "cropsize", "potency", "endurance", ""];

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
    show_splicing,
    splice_seeds,
    sortBy,
    sortAsc,
  } = data;
  return (
    <Window
      resizable
      title="Plantmaster Mk4"
      width={1100}
      height={450}>
      <Window.Content>
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
            Seed Extraction ({category_lengths[0]})
          </Tabs.Tab>
          <Tabs.Tab
            selected={category === 'seedlist'}
            onClick={() => {
              act('change_tab', { 'tab': 'seedlist' });
            }}>
            Seeds ({category_lengths[1]})
          </Tabs.Tab>
          <Tabs.Tab
            backgroundColor={inserted_container !== null ? "green" : "blue"}
            selected={inserted_container !== null}
            icon="eject"
            onClick={() => inserted_container !== null ? act('ejectbeaker') : act('insertbeaker')}
            bold>
            {inserted_container !== null ? inserted : "Insert Beaker"}
          </Tabs.Tab>
        </Tabs>

        {category === 'overview' && <PlantOverview cat_lens={category_lengths} container={inserted ? inserted_container : null} seedoutput={seedoutput} />}
        {category === 'extractables' && <PlantExtractables seedoutput={seedoutput} produce={extractables} sortBy={sortBy} sortAsc={sortAsc} />}
        {category === 'seedlist' && <PlantSeeds seeds={seeds} seedoutput={seedoutput} splicing={show_splicing} splice_chance={splice_chance} splice_seeds={splice_seeds} sortBy={sortBy} sortAsc={sortAsc} />}
      </Window.Content>
    </Window>
  );
};

const compare = function (a, b, sortBy, sortAsc) {
  if (sortBy === "name" || sortBy === "species") {
    if (sortAsc) {
      return (a[sortBy] ?? '').toString().localeCompare(b[sortBy] ?? '');
    }
    else
    {
      return (b[sortBy] ?? '').toString().localeCompare(a[sortBy] ?? '');
    }
  }
  if (sortAsc) {
    return parseFloat(a[sortBy]) - parseFloat(b[sortBy]);
  }
  else {
    return parseFloat(b[sortBy]) - parseFloat(a[sortBy]);
  }
};

const ReagentDisplay = (props, context) => {
  const { act } = useBackend(context);
  const container = props.container || NoContainer;

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
const TitleRow = (props, context) => {
  const { act } = useBackend(context);
  const { show_damage, sortBy, sortAsc } = props;

  return (
    <TableRow>
      {headings.map((heading, index) => (show_damage || heading !== "damage") && (
        <TableCell key={heading} textAlign="center" >
          <Button
            color="transparent"
            icon={sortBy !== "" && sortBy === sortname[index] ? (sortAsc ? "angle-up" : "angle-down") : ""}
            onClick={() => act('sort', { sortBy: sortname[index], asc: (sortBy === sortname[index] ? !sortAsc : sortAsc) })}>
            <b>{capitalize(heading)}</b>
          </Button>
        </TableCell>
      ))}
    </TableRow>
  );
};
const PlantRow = (props, context) => {
  const { act } = useBackend(context);
  const { extractable, show_damage, infuse, extract, splice, splice_disable } = props;
  return (
    <Fragment key={extractable.ref[1]}>
      <TableRow>
        <TableCell width="100px" textAlign="center">
          <Button.Input
            width="100px"
            tooltip="Click to rename"
            color="transparent"
            textColor="#FFFFFF"
            content={truncate(extractable.name[0], 10)}
            defaultValue={extractable.name[0]}
            currentValue={extractable.name[0]}
            onCommit={(e, new_name) => act('label', {
              label_ref: extractable.ref[0],
              label_new: new_name,
            })} />
        </TableCell>
        <TableCell width="100px" textAlign="center" bold={extractable.species[1]} backgroundColor={extractable.species[1] ? "#333333" : ""}>
          {extractable.species[0]}
        </TableCell>
        {show_damage && (
          <TableCell textAlign="center" bold={extractable.damage[1]} backgroundColor={extractable.damage[1] ? "#333333" : ""}>
            {extractable.damage[0]}%
          </TableCell>
        )}
        <TableCell textAlign="center" bold={extractable.genome[1]} backgroundColor={extractable.genome[1] ? "#333333" : ""}>
          {extractable.genome[0]}
        </TableCell>
        <TableCell textAlign="center" bold={extractable.generation[1]} backgroundColor={extractable.generation[1] ? "#333333" : ""}>
          {extractable.generation[0]}
        </TableCell>
        <TableCell textAlign="center" bold={extractable.growtime[1]} backgroundColor={extractable.growtime[1] ? "#333333" : ""}>
          {extractable.growtime[0]}
        </TableCell>
        <TableCell textAlign="center" bold={extractable.harvesttime[1]} backgroundColor={extractable.harvesttime[1] ? "#333333" : ""}>
          {extractable.harvesttime[0]}
        </TableCell>
        <TableCell textAlign="center" bold={extractable.lifespan[1]} backgroundColor={extractable.lifespan[1] ? "#333333" : ""}>
          {extractable.lifespan[0]}
        </TableCell>
        <TableCell textAlign="center" bold={extractable.cropsize[1]} backgroundColor={extractable.cropsize[1] ? "#333333" : ""}>
          {extractable.cropsize[0]}
        </TableCell>
        <TableCell textAlign="center" bold={extractable.potency[1]} backgroundColor={extractable.potency[1] ? "#333333" : ""}>
          {extractable.potency[0]}
        </TableCell>
        <TableCell textAlign="center" bold={extractable.endurance[1]} backgroundColor={extractable.endurance[1] ? "#333333" : ""}>
          {extractable.endurance[0]}
        </TableCell>
        <TableCell textAlign="center">
          <Flex>
            <Flex.Item nowrap>
              {infuse && (
                <Button
                  icon="fill-drip"
                  title="Infuse"
                  fontSize={1.1}
                  disabled={!extractable.allow_infusion[1]}
                  onClick={() => act('infuse', { infuse_ref: extractable.ref[0] })}
                />)}
              {extract && (
                <Button
                  icon="seedling"
                  title="Extract Seeds"
                  fontSize={1.1}
                  onClick={() => act('extract', { extract_ref: extractable.ref[0] })}
                />)}
              {splice && (
                <Button
                  disabled={!extractable.splicing[1] && splice_disable}
                  icon={extractable.splicing[1] ? "window-close" : "code-branch"}
                  color={extractable.splicing[1] ? "red" : ""}
                  title={extractable.splicing[1] ? "Cancel Splice" : "Splice"}
                  fontSize={1.1}
                  onClick={() => act('splice_select', { splice_select_ref: extractable.ref[0] })}
                />)}
              <Button
                icon="search"
                title="Analyze"
                fontSize={1.1}
                onClick={() => act('analyze', { analyze_ref: extractable.ref[0] })}
              />
              <Button
                icon="eject"
                title="Eject"
                fontSize={1.1}
                onClick={() => act('eject', { eject_ref: extractable.ref[0] })}
              />
            </Flex.Item>
          </Flex>
        </TableCell>
      </TableRow>
      <Divider />
    </Fragment>
  );
};

const PlantSeeds = (props, context) => {
  const { act } = useBackend(context);
  const { seedoutput, seeds, splicing, splice_seeds, splice_chance, sortBy, sortAsc } = props;
  const extractables = (seeds || []).sort(
    (a, b) => (compare(a, b, sortBy, sortAsc))
  );
  const extractablesPerPage = splicing ? 7 : 10;
  const [page, setPage] = useLocalState(context, 'page', 1);
  const totalPages = Math.max(1, Math.ceil(extractables.length / extractablesPerPage));
  if (page < 1 || page > totalPages) setPage(clamp(page, 1, totalPages));
  const extractablesOnPage = extractables.slice(extractablesPerPage*(page - 1),
    extractablesPerPage*(page - 1) + extractablesPerPage);
  const splice_disable = (splice_seeds[0] !== null && splice_seeds[1] !== null);
  return (
    <Section fill
      title="Seeds"
      buttons={(
        <Flex.Item textAlign="center" basis={1.5}>
          <Button
            icon="eject"
            tooltip="All seeds will be ejected from the Plantmaster"
            onClick={() => act('ejectseeds')}>
            Eject All
          </Button>
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
        <Flex.Item height={splicing ? "60%" : "100%"}>
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
        </Flex.Item>
        {splicing && (
          <Flex.Item height="30%">
            <Section
              title="Splicing"
              buttons={
                <Flex.Item textAlign="center" basis={1.5}>
                  Splice Chance: {splice_chance}%&nbsp;
                  <Button onClick={() => act('splice')}>Splice</Button>
                </Flex.Item>
              }>
              <Table>
                <TitleRow show_damage sortBy={sortBy} sortAsc={sortAsc} />
                {splice_seeds.filter((x) => (x !== null)).sort(
                  (a, b) => (compare(a, b, sortBy, sortAsc))
                ).map((extractable, index) => (
                  <PlantRow extractable={extractable} key={extractable.ref[1]} show_damage infuse splice />
                ))}
              </Table>
            </Section>
          </Flex.Item>
        )}
      </Flex>
    </Section>
  );
};

const PlantExtractables = (props, context) => {
  const { act } = useBackend(context);
  const { seedoutput, produce, sortBy, sortAsc } = props;
  const extractables = (produce || []).sort(
    (a, b) => (compare(a, b, sortBy, sortAsc))
  );
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
            icon="eject"
            tooltip="All produce will be ejected from the Plantmaster"
            onClick={() => act('ejectextractables')}>
            Eject All
          </Button>
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
            <TitleRow sortBy={sortBy} sortAsc={sortAsc} />
            {extractablesOnPage.map((extractable, index) => (
              <PlantRow extractable={extractable} key={extractable.ref[1]} extract />
            ))}
          </Table>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
