/**
 * @file
 * @copyright 2022
 * @author Original Amylizzle (https://github.com/amylizzle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { Box, Button, Dimmer, Section } from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../../../backend';
import {
  NoContainer,
  ReagentContainer,
  ReagentGraph,
  ReagentList,
} from '../../common/ReagentInfo';
import type { OverviewViewData, PlantmasterData } from '../type';

export const OverviewView = () => {
  const { data } = useBackend<OverviewViewData>();
  const { inserted_container, num_extractables, num_seeds } = data;

  return (
    <Section title="Overview">
      <Box>
        Items ready for extraction: <b>{num_extractables}</b>
        <br />
        Seeds ready for experimentation: <b>{num_seeds}</b>
      </Box>
      <ReagentDisplay container={inserted_container} />
    </Section>
  );
};

interface ReagentDisplayProps {
  container: ReagentContainer | null;
}

const ReagentDisplay = (props: ReagentDisplayProps) => {
  const { container } = props;
  const { act } = useBackend<PlantmasterData>();
  const resolvedContainer = container ?? NoContainer;

  return (
    <Section title={capitalize(resolvedContainer.name ?? '')}>
      {!container && (
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
      <ReagentGraph container={resolvedContainer} />
      <ReagentList container={resolvedContainer} />
    </Section>
  );
};
