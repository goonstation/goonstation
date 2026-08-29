/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { DisplayAnatomicalAnomalies } from '../common/health/anatomy';
import { DisplayDiseases } from '../common/health/disease';
import { DisplayImplants } from '../common/health/implants';
import {
  DisplayBloodstreamContent,
  DisplayPatientTitle,
} from '../common/health/index';
import { KeyHealthIndicators } from '../common/health/key_indicators';
import { DisplayVitals } from '../common/health/vitals';
import { HealthAnalyzerData } from './type';

export const HealthAnalyzer = () => {
  const { act, data } = useBackend<HealthAnalyzerData>();
  const { organ_scan_upgrade, reagent_scan_upgrade } = data;
  let height = 350;
  if (organ_scan_upgrade) height += 200;
  if (reagent_scan_upgrade) height += 90;
  return (
    <Window title="Health Analyzer" width={480} height={height}>
      <Window.Content scrollable>
        {!data.clumsy_scan && (
          <Section>
            <DisplayPatientTitle
              occupied={data.occupied}
              patient_name={data.patient_name}
              patient_health={data.current_health}
              patient_max_health={data.max_health}
              patient_status={data.patient_status}
            />
            <DisplayVitals
              occupied={data.occupied}
              oxygen={data.oxygen}
              toxin={data.toxin}
              burn={data.burn}
              brute={data.brute}
            />
            <KeyHealthIndicators
              occupied={data.occupied}
              patient_status={data.patient_status}
              blood_pressure_rendered={data.blood_pressure_rendered}
              blood_pressure_status={data.blood_pressure_status}
              blood_volume={data.blood_volume}
              bleeding={data.bleeding}
              body_temp={data.body_temp}
              optimal_temp={data.optimal_temp}
              embedded_objects={data.embedded_objects}
              rad_stage={data.rad_stage}
              rad_dose={data.rad_dose}
              brain_damage={data.brain_damage}
            />
            {!!data.reagent_scan_upgrade && (
              <DisplayBloodstreamContent
                occupied={data.occupied}
                show_type="list"
                reagent_container={data.reagent_container}
              />
            )}
            {!!data.organ_scan_upgrade && (
              <DisplayAnatomicalAnomalies
                occupied={data.occupied}
                organs={data.organ_status}
                limbs={data.limb_status}
              />
            )}
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
            <Button icon="print" onClick={() => act('print')}>
              Print Report
            </Button>
          </Section>
        )}
        {!!data.clumsy_scan && (
          <Section>
            <DisplayPatientTitle
              occupied
              patient_name="The Floor"
              patient_health={100}
              patient_max_health={100}
              patient_status={0}
            />
            <DisplayVitals occupied oxygen={0} toxin={0} burn={0} brute={0} />
            <KeyHealthIndicators
              occupied
              patient_status={0}
              blood_pressure_rendered="???"
              blood_pressure_status="???"
              blood_volume={0}
              bleeding={0}
              body_temp={'???'}
              optimal_temp={'???'}
              embedded_objects={null}
              rad_stage={0}
              rad_dose={0}
              brain_damage={0}
            />
            {!!data.reagent_scan_upgrade && (
              <DisplayBloodstreamContent
                occupied
                show_type="list"
                reagent_container={null}
              />
            )}
            {!!data.organ_scan_upgrade && (
              <DisplayAnatomicalAnomalies occupied organs={null} limbs={null} />
            )}
            <DisplayImplants occupied implants={null} />
            <DisplayDiseases occupied diseases={null} />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
