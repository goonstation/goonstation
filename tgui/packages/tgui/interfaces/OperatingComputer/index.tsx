/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { DisplayAnatomicalAnomalies } from '../common/health/anatomy';
import { DisplayDiseases } from '../common/health/disease';
import { DisplayGeneticAnalysis } from '../common/health/genetics';
import { DisplayImplants } from '../common/health/implants';
import {
  DisplayBloodstreamContent,
  DisplayPatientTitle,
} from '../common/health/index';
import { KeyHealthIndicators } from '../common/health/key_indicators';
import { DisplayMiscellaneousDetails } from '../common/health/misc';
import { HealthGraphData } from '../common/health/type';
import { DisplayVitalsGraph } from '../common/health/vitals';

export const OperatingComputer = () => {
  const { data } = useBackend<HealthGraphData>();
  return (
    <Window title="Operating Computer" width={560} height={760}>
      <Window.Content scrollable>
        <Section>
          <DisplayPatientTitle
            occupied={data.occupied}
            patient_name={data.patient_name}
            patient_health={data.current_health}
            patient_max_health={data.max_health}
            patient_status={data.patient_status}
          />
          <DisplayVitalsGraph />
          <KeyHealthIndicators
            occupied={data.occupied}
            patient_status={data.patient_status}
            blood_pressure_rendered={data.blood_pressure_rendered}
            blood_pressure_status={data.blood_pressure_status}
            blood_volume={data.blood_volume}
            body_temp={data.body_temp}
            bleeding={data.bleeding}
            optimal_temp={data.optimal_temp}
            embedded_objects={data.embedded_objects}
            rad_stage={data.rad_stage}
            rad_dose={data.rad_dose}
            brain_damage={data.brain_damage}
          />
          <DisplayBloodstreamContent
            occupied={data.occupied}
            show_type="both"
            reagent_container={data.reagent_container}
          />
          <DisplayAnatomicalAnomalies
            occupied={data.occupied}
            organs={data.organ_status}
            limbs={data.limb_status}
          />
          <DisplayImplants
            occupied={data.occupied}
            implants={
              data.embedded_objects ? data.embedded_objects.implants : null
            }
          />
          <DisplayDiseases
            occupied={data.occupied}
            diseases={data.disease_status}
          />
          <DisplayGeneticAnalysis
            occupied={data.occupied}
            clone_generation={data.clone_generation}
            cloner_defect_count={data.cloner_defect_count}
            genetic_stability={data.genetic_stability}
          />
          <DisplayMiscellaneousDetails
            occupied={data.occupied}
            age={data.age}
            blood_type={data.blood_type}
            blood_color_value={data.blood_color_value}
            blood_color_name={data.blood_color_name}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
