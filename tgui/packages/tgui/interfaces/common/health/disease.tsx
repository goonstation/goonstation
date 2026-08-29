/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */
import { Box, Collapsible, Section } from 'tgui-core/components';

import { DiseaseData, DisplayOccupiedProps } from './type';

type DisplayDiseasesProps = DisplayOccupiedProps & {
  diseases: DiseaseData[] | null;
};

export const DisplayDiseases = (props: DisplayDiseasesProps) => {
  const { occupied, diseases } = props;

  return (
    <Collapsible
      open
      title="Detected Diseases"
      sideIcon="bacterium"
      color={!occupied && 'grey'}
    >
      <Section>
        {!occupied && <Box>No Patient Detected.</Box>}
        {!!occupied && (diseases === null || diseases.length === 0) && (
          <Box>No diseases detected.</Box>
        )}
        {!!occupied &&
          diseases &&
          diseases.map((disease_data: DiseaseData, index) => {
            return <DisplayDisease key={index} disease={disease_data} />;
          })}
      </Section>
    </Collapsible>
  );
};

interface DisplayDiseaseProps {
  disease: DiseaseData;
}

export const DisplayDisease = (props: DisplayDiseaseProps) => {
  const { disease } = props;

  return (
    <Collapsible
      title={`${disease.state} ${disease.scantype}: ${disease.disease_name} (Stage: ${disease.stage}/${disease.max_stage})`}
    >
      {!!disease.info && (
        <span>
          Info: {disease.info}
          <br />
        </span>
      )}
      Spread: {disease.spread}
      <br />
      {disease.cure_method}
    </Collapsible>
  );
};
