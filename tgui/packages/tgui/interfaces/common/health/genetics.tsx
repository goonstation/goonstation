/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */
import { Collapsible, Section, Stack, Table } from 'tgui-core/components';

import { DisplayOccupiedProps } from './type';

export interface DisplayGeneticAnalysisProps extends DisplayOccupiedProps {
  clone_generation: number | null;
  cloner_defect_count: number | null;
  genetic_stability: number | null;
}

export const DisplayGeneticAnalysis = (props: DisplayGeneticAnalysisProps) => {
  const { occupied, clone_generation, cloner_defect_count, genetic_stability } =
    props;

  return (
    <Collapsible
      fontSize={1.2}
      open
      color={!occupied && 'grey'}
      sideIcon="dna"
      title="Genetic Analysis"
    >
      <Section>
        {!occupied && 'No Patient Detected.'}
        {!!occupied && (
          <Stack>
            <Stack.Item width={14}>
              <Table>
                <Table.Row>
                  <Table.Cell header textAlign="right">
                    Clone Generation:
                  </Table.Cell>
                  <Table.Cell>{clone_generation}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell header textAlign="right">
                    Genetic Defects:
                  </Table.Cell>
                  <Table.Cell>{cloner_defect_count}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell header textAlign="right">
                    Genetic Stability:
                  </Table.Cell>
                  <Table.Cell>{genetic_stability}</Table.Cell>
                </Table.Row>
              </Table>
            </Stack.Item>
          </Stack>
        )}
      </Section>
    </Collapsible>
  );
};
