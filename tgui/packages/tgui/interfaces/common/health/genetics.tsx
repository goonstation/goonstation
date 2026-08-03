/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */
import { Collapsible, LabeledList, Section } from 'tgui-core/components';

import { DisplayOccupiedProps } from './type';

type DisplayGeneticAnalysisProps = DisplayOccupiedProps & {
  clone_generation: number | null;
  cloner_defect_count: number | null;
  genetic_stability: number | null;
};

export const DisplayGeneticAnalysis = (props: DisplayGeneticAnalysisProps) => {
  const { occupied, clone_generation, cloner_defect_count, genetic_stability } =
    props;

  return (
    <Collapsible
      open
      color={!occupied && 'grey'}
      sideIcon="dna"
      title="Genetic Analysis"
    >
      <Section>
        {!occupied && 'No Patient Detected.'}
        {!!occupied && (
          <LabeledList>
            <LabeledList.Item label="Clone Generation">
              {clone_generation}
            </LabeledList.Item>
            <LabeledList.Item label="Genetic Defects">
              {cloner_defect_count}
            </LabeledList.Item>
            <LabeledList.Item label="Genetic Stability">
              {genetic_stability}
            </LabeledList.Item>
          </LabeledList>
        )}
      </Section>
    </Collapsible>
  );
};
