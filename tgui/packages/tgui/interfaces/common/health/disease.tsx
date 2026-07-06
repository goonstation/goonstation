/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */
import { Box, Collapsible, Section } from 'tgui-core/components';

import { DiseaseData, DisplayOccupiedProps } from './type';

interface DisplayDiseasesProps extends DisplayOccupiedProps {
  diseases: DiseaseData[] | null;
}

export const DisplayDiseases = (props: DisplayDiseasesProps) => {
  const { occupied, diseases } = props;

  return (
    <Collapsible
      fontSize={1.2}
      open
      title={'Detected Diseases'}
      sideIcon="bacterium"
      color={!occupied && 'grey'}
    >
      <Section>
        {!occupied && <Box>No Patient Detected.</Box>}
        {!!occupied && (!!diseases || diseases === null) && (
          <Box>No diseases detected.</Box>
        )}
        {!!occupied &&
          diseases &&
          diseases.map((disease_data: DiseaseData) => {
            return (
              <DisplayDisease
                key={disease_data['disease_ref']}
                disease_ref={disease_data['disease_ref']}
                scantype={disease_data['scantype']}
                state={disease_data['state']}
                spread={disease_data['spread']}
                info={disease_data['info']}
                disease={disease_data['disease']}
                stage={disease_data['stage']}
                max_stage={disease_data['max_stage']}
                cure_method={disease_data['cure_method']}
              />
            );
          })}
      </Section>
    </Collapsible>
  );
};

export const DisplayDisease = (props: DiseaseData) => {
  const {
    state,
    scantype,
    spread,
    info,
    disease,
    stage,
    max_stage,
    cure_method,
  } = props;

  return (
    <Collapsible
      title={`${state} ${scantype}: ${disease} (Stage: ${stage}/${max_stage})`}
    >
      {!!info && (
        <span>
          Info: {info}
          <br />
        </span>
      )}
      Spread: {spread}
      <br />
      {cure_method}
    </Collapsible>
  );
};
