/**
 * @file
 * @copyright 2022
 * @author Original Amylizzle (https://github.com/amylizzle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { Button, NumberInput, Section, Table } from 'tgui-core/components';
import { clamp } from 'tgui-core/math';

import { useBackend } from '../../../backend';
import { compare, Row, TitleRow } from '../PlantmasterTable';
import type { ExtractablesViewData, PlantmasterData } from '../type';

type ExtractablesTabProps = Pick<
  ExtractablesViewData,
  'allow_infusion' | 'seedoutput' | 'sortAsc' | 'sortBy'
> & {
  page: number;
  setPage: (value: number) => void;
  produce: ExtractablesViewData['extractables'];
};

export const ExtractablesView = (props: ExtractablesTabProps) => {
  const { act } = useBackend<PlantmasterData>();
  const {
    allow_infusion,
    seedoutput,
    produce,
    sortBy,
    sortAsc,
    page,
    setPage,
  } = props;
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
          <Row
            allow_infusion={allow_infusion}
            extractable={extractable}
            key={extractable.ref[1]}
            extract
          />
        ))}
      </Table>
    </Section>
  );
};
