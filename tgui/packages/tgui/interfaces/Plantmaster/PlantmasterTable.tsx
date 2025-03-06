/**
 * @file
 * @copyright 2022
 * @author Original Amylizzle (https://github.com/amylizzle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { Button, Table } from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { truncate } from '../../format';
import { type ExtractableData, isSeedData, type PlantmasterData } from './type';

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

interface TitleRowProps {
  showDamage?: boolean;
  sortAsc: boolean;
  sortBy?: string | null;
}

export const TitleRow = (props: TitleRowProps) => {
  const { act } = useBackend<PlantmasterData>();
  const { showDamage, sortBy, sortAsc } = props;

  return (
    <Table.Row className="candystripe">
      {headings.map(
        (heading, index) =>
          (showDamage || (heading !== 'damage' && heading !== 'count')) && (
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
                    asc: sortBy === sortname[index] ? !sortAsc : true,
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

type PlantRowProps = Pick<PlantmasterData, 'allow_infusion'> & {
  extractable: ExtractableData;
  show_damage?: boolean;
  infuse?: boolean;
  extract?: boolean;
  splice?: boolean;
  splice_disable?: boolean;
};

export const Row = (props: PlantRowProps) => {
  const { act } = useBackend<PlantmasterData>();
  const {
    allow_infusion,
    extractable,
    show_damage,
    infuse,
    extract,
    splice,
    splice_disable,
  } = props;
  return (
    <Table.Row className="candystripe">
      <Table.Cell width="100px" textAlign="center">
        <Button.Input
          width="100px"
          tooltip="Click to rename"
          color="transparent"
          textColor="#FFFFFF"
          defaultValue={extractable.name}
          currentValue={extractable.name}
          onCommit={(_e, new_name) =>
            act('label', {
              label_ref: extractable.item_ref,
              label_new: new_name,
            })
          }
        >
          {truncate(extractable.name, 10)}
        </Button.Input>
      </Table.Cell>
      <Table.Cell
        width="100px"
        textAlign="center"
        verticalAlign="middle"
        bold={!!extractable.species[1]}
        backgroundColor={extractable.species[1] ? '#333333' : undefined}
      >
        {extractable.species[0]}
      </Table.Cell>
      {show_damage && isSeedData(extractable) && (
        <Table.Cell
          textAlign="center"
          verticalAlign="middle"
          bold={!!extractable.damage[1]}
          backgroundColor={extractable.damage[1] ? '#333333' : undefined}
        >
          {extractable.damage[0]}%
        </Table.Cell>
      )}
      {show_damage && (
        <Table.Cell textAlign="center" verticalAlign="middle">
          {extractable.charges}
        </Table.Cell>
      )}
      <Table.Cell textAlign="center" verticalAlign="middle">
        {extractable.genome}
      </Table.Cell>
      <Table.Cell textAlign="center" verticalAlign="middle">
        {extractable.generation}
      </Table.Cell>
      <Table.Cell
        textAlign="center"
        verticalAlign="middle"
        bold={!!extractable.growtime[1]}
        backgroundColor={extractable.growtime[1] ? '#333333' : ''}
      >
        {extractable.growtime[0]}
      </Table.Cell>
      <Table.Cell
        textAlign="center"
        verticalAlign="middle"
        bold={!!extractable.harvesttime[1]}
        backgroundColor={extractable.harvesttime[1] ? '#333333' : ''}
      >
        {extractable.harvesttime[0]}
      </Table.Cell>
      <Table.Cell
        textAlign="center"
        verticalAlign="middle"
        bold={!!extractable.lifespan[1]}
        backgroundColor={extractable.lifespan[1] ? '#333333' : ''}
      >
        {extractable.lifespan[0]}
      </Table.Cell>
      <Table.Cell
        textAlign="center"
        verticalAlign="middle"
        bold={!!extractable.cropsize[1]}
        backgroundColor={extractable.cropsize[1] ? '#333333' : ''}
      >
        {extractable.cropsize[0]}
      </Table.Cell>
      <Table.Cell
        textAlign="center"
        verticalAlign="middle"
        bold={!!extractable.potency[1]}
        backgroundColor={extractable.potency[1] ? '#333333' : ''}
      >
        {extractable.potency[0]}
      </Table.Cell>
      <Table.Cell
        textAlign="center"
        verticalAlign="middle"
        bold={!!extractable.endurance[1]}
        backgroundColor={extractable.endurance[1] ? '#333333' : ''}
      >
        {extractable.endurance[0]}
      </Table.Cell>
      <Table.Cell textAlign="center" verticalAlign="middle" nowrap>
        {infuse && isSeedData(extractable) && (
          <Button
            icon="fill-drip"
            tooltip="Infuse"
            disabled={!allow_infusion}
            onClick={() => act('infuse', { infuse_ref: extractable.item_ref })}
          />
        )}
        {extract && (
          <Button
            icon="seedling"
            tooltip="Extract Seeds"
            onClick={() =>
              act('extract', { extract_ref: extractable.item_ref })
            }
          />
        )}
        {splice && isSeedData(extractable) && (
          <Button
            disabled={!extractable.splicing[1] && splice_disable}
            icon={extractable.splicing[1] ? 'window-close' : 'code-branch'}
            color={extractable.splicing[1] ? 'red' : undefined}
            tooltip={extractable.splicing[1] ? 'Cancel Splice' : 'Splice'}
            onClick={() =>
              act('splice_select', {
                splice_select_ref: extractable.item_ref,
              })
            }
          />
        )}
        <Button
          icon="search"
          tooltip="Analyze"
          onClick={() => act('analyze', { analyze_ref: extractable.item_ref })}
        />
        <Button
          icon="eject"
          tooltip="Eject"
          onClick={() => act('eject', { eject_ref: extractable.item_ref })}
        />
      </Table.Cell>
    </Table.Row>
  );
};

export const compare = function (a, b, sortBy, sortAsc?: boolean) {
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
