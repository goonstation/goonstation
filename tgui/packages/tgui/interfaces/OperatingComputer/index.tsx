
import { useBackend, useSharedState } from '../../backend';
import { Box, ColorBox, Chart, Section, Stack, Tabs, Table } from '../../components';
import { Window } from '../../layouts';
import { HealthStat } from '../common/HealthStat';
import { COLORS } from '../../constants';
import { ReagentGraph } from '../common/ReagentInfo';
import { processStatsData, getStatsMax } from '../common/graphUtils';
import { capitalize, spaceUnderscores } from '../common/stringUtils';
import {
  OperatingComputerData,
  OperatingComputerDisplayTitleProps,
  PatientSummaryProps,
  DisplayTempImplantRowProps,
  DisplayBloodstreamContentProps,
  DisplayAnatomicalAnomoliesProps,
  DisplayTemperatureProps,
  DisplayGeneticAnalysisProps,
  DisplayBloodPressureProps,
  OrganData,
  DisplayLimbsProps,
  DisplayLimbProps,
  LimbData,
  DisplayOrgansProps,
  DisplayBrainProps,
} from './type';

export const OperatingComputer = (props, context) => {
  const [tabIndex, setTabIndex] = useSharedState(context, 'tabIndex', 1);

  return (
    <Window title="Operating Computer" width="560" height="760">
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={tabIndex === 1}
            onClick={() => setTabIndex(1)}>
            Patient Health
          </Tabs.Tab>
        </Tabs>
        <ComputerTabs tabIndex={tabIndex} />
      </Window.Content>
    </Window>
  );
};

const ComputerTabs = (props) => {
  const { tabIndex } = props;
  if (tabIndex === 1) { return (<PatientTab />); }
};

// mob.stat parsing
const PatientSummary = (props:PatientSummaryProps) => {
  const { occupied, patient_status, isCrit } = props;
  let text = "NONE";
  let color = "grey";
  if (occupied) {
    if (patient_status === 2) {
      text = "DEAD";
      color = "red";
    }
    else if (isCrit) {
      text = "CRIT";
      color = "orange";
    }
    else if (patient_status === 0 || !patient_status) {
      text = "STABLE";
      color = "green";
    }
    else if (patient_status === 1) {
      text = "UNCON"; // unconscious
      color = "yellow";
    }
  }
  return (
    <Stack.Item width={20} textAlign="right">
      <Box fontSize={1}>Status</Box>
      <Box fontSize={1.5}><Box color={color}>{text}</Box>
      </Box>
    </Stack.Item>);

};

const HealthSummary = (props) => {
  const { health_text, health_color } = props;

  return (
    <Stack.Item width={20} textAlign="right">
      <Box fontSize={1}>Overall Health</Box>
      <Box fontSize={1.5}>
        <Box color={health_color}>{health_text}<span style={{ color: "white" }}>%</span></Box>
      </Box>
    </Stack.Item>
  );
};

const PatientTab = (props, context) => {
  const { data } = useBackend<OperatingComputerData>(context);
  return (
    <Section>
      <DisplayTitle
        occupied={data.occupied}
        patient_name={data.patient_name}
        patient_health={data.current_health}
        patient_max_health={data.max_health}
        patient_status={data.patient_status}
      />
      <DisplayVitals />
      <Section title="Key Health Indicators">
        <Table>
          <DisplayBloodPressure
            occupied={data.occupied}
            patient_status={data.patient_status}
            blood_pressure_rendered={data.blood_pressure_rendered}
            blood_pressure_status={data.blood_pressure_status}
            blood_volume={data.blood_volume}
          />
          <DisplayTempImplantRow
            occupied={data.occupied}
            body_temp={data.body_temp}
            optimal_temp={data.optimal_temp}
            embedded_objects={data.embedded_objects}
          />
          { data.occupied ? <DisplayRads rad_stage={data.rad_stage} rad_dose={data.rad_dose} />: ""}
          <DisplayBrain
            occupied={data.occupied}
            status={data.brain_damage}
          />
        </Table>
        { data.occupied? <DisplayEmbeddedObjects embedded_objects={data.embedded_objects} />: ""}
      </Section>
      <DisplayAnatomicalAnomolies
        occupied={data.occupied}
        organs={data.organ_status}
        limbs={data.limb_status}
      />
      <DisplayBloodstreamContent
        occupied={data.occupied}
        reagent_container={data.reagent_container}
      />
      <DisplayGeneticAnalysis
        occupied={data.occupied}
        age={data.age}
        blood_type={data.blood_type}
        blood_color_value={data.blood_color_value}
        blood_color_name={data.blood_color_name}
        clone_generation={data.clone_generation}
        cloner_defect_count={data.cloner_defect_count}
        genetic_stability={data.genetic_stability}
      />
    </Section>
  );

};

const HealthGraph = (props) => {
  const { metric, value, metric_data, title } = props;
  return (
    <Stack.Item width={25}>
      <HealthStat type={metric}>{title}<br /><Box fontSize={4}>{value}</Box>
        <Box>
          <Chart.Line
            mt="5px"
            height="5em"
            data={metric_data}
            rangeX={[0, metric_data.length - 1]}
            rangeY={[0, Math.max(100, getStatsMax(metric_data))]}
            strokeColor={COLORS.damageType[metric]}
            fillColor={COLORS.damageTypeFill[metric]}
          />
        </Box>
      </HealthStat>
    </Stack.Item>
  );
};

const DisplayBloodPressure = (props:DisplayBloodPressureProps) => {
  const {
    occupied,
    patient_status,
    blood_pressure_rendered,
    blood_pressure_status,
    blood_volume,
  } = props;
  let pressure_color = "grey";
  if (occupied) {
    if (blood_volume <= 299) {
      pressure_color = "red";
    } else if (blood_volume <= 414) {
      pressure_color = "yellow";
    } else if (blood_volume <= 584) {
      pressure_color = "green";
    } else if (blood_volume <= 665) {
      pressure_color = "yellow";
    } else {
      pressure_color = "red";
    }
  }

  return (
    <Table.Row>
      <Table.Cell header textAlign="right" width={10}>Blood Pressure:</Table.Cell>
      <Table.Cell width={10} color={pressure_color}>{occupied && patient_status !== 2 ? blood_pressure_rendered : "--/--"} ({occupied && patient_status !== 2 ? blood_pressure_status : "NO PULSE"})</Table.Cell>
      <Table.Cell header textAlign="right" width={10}>Blood Volume:</Table.Cell>
      <Table.Cell width={10} color={pressure_color}>{occupied ? blood_volume.toString() : "--"} units</Table.Cell>
    </Table.Row>
  );
};

const DisplayRads = (props) => {
  const { rad_stage, rad_dose } = props;
  if (rad_stage > 0) {
    return (
      <Table.Row>
        <Table.Cell header textAlign="right" color="yellow" width={10}>Radiation:</Table.Cell>
        <Table.Cell width={10}>Stage {rad_stage}</Table.Cell>
        <Table.Cell header textAlign="right" width={10}>Sieverts:</Table.Cell>
        <Table.Cell width={10}>{rad_dose} units</Table.Cell>
      </Table.Row>
    );
  }
};

const DisplayBrain = (props:DisplayBrainProps) => {
  const { occupied, status } = props;
  if (occupied && status.desc !== "Okay" && status.desc !== "Missing") {
    return (
      <Table.Row>
        <Table.Cell header textAlign="right" color="pink" width={10}>
          Brain Damage:
        </Table.Cell>
        <Table.Cell width={10} color={status.color}>{status.desc}</Table.Cell>
        <Table.Cell header textAlign="right" width={10}>Neuron Cohesion:</Table.Cell>
        <Table.Cell>{((120-status.value)/120*100).toFixed(2)}%</Table.Cell>
      </Table.Row>
    );
  }
};


const DisplayOrgans = (props: DisplayOrgansProps) => {
  const { occupied, organs } = props;
  if (occupied) {
    return (
      <Stack.Item width={20}>
        <Table>
          <Table.Row>
            <Table.Cell header textAlign="right">Organ</Table.Cell>
            <Table.Cell header>Status</Table.Cell>
          </Table.Row>
          {
            organs.map((organ_data: OrganData) => {
              return (
                <DisplayOrgan
                  key={organ_data["organ"]}
                  organ={organ_data["organ"]}
                  state={organ_data["state"]}
                  color={organ_data["color"]}
                  special={organ_data["special"]}
                />
              );
            })
          }
        </Table>
      </Stack.Item>
    ); }
};

const DisplayOrgan = (props: OrganData) => {
  const {
    organ,
    state,
    color,
    special,
  } = props;

  if (state !== "Okay" || special) {
    return (
      <Table.Row>
        <Table.Cell header textAlign="right" width={10}>
          {capitalize(spaceUnderscores(organ))}:
        </Table.Cell>
        <Table.Cell
          width={10}
          color={color}
          bold={state==="Missing" || state === "Dead" || state === "Critical"}
        >
          {state !== "Okay" ? state : "" }
          {special ? <Box color="white">{special}</Box>: "" }
        </Table.Cell>
      </Table.Row>
    );
  }
};

const DisplayLimbs = (props:DisplayLimbsProps) => {
  const { occupied, limbs } = props;
  if (occupied) {
    return (
      <Stack.Item width={20}>
        <Table>
          <Table.Row>
            <Table.Cell header textAlign="right">Limb</Table.Cell>
            <Table.Cell header>Status</Table.Cell>
          </Table.Row>
          {
            limbs.map((limb_data: LimbData) => {
              return (
                <DisplayLimb
                  key={limb_data["limb"]}
                  limb={limb_data["limb"]}
                  status={limb_data["status"]}
                />
              );
            })
          }
        </Table>
      </Stack.Item>
    );
  }
};

const DisplayLimb = (props:DisplayLimbProps) => {
  const { limb, status } = props;
  if (status !== "Okay") {
    return (
      <Table.Row>
        <Table.Cell header textAlign="right" width={10}>
          {capitalize(spaceUnderscores(limb))}:
        </Table.Cell>
        <Table.Cell
          width={10}
          color={status==="Missing" ? "red" : "white"}
          bold={status==="Missing"}>{status}
        </Table.Cell>
      </Table.Row>
    );
  }
};

const DisplayTemperature = (props: DisplayTemperatureProps) => {
  const { occupied, body_temp, optimal_temp } = props;
  let font_color = "grey";
  if (occupied) {
    if (body_temp >= (optimal_temp + 60)) { font_color="red"; }
    else if (body_temp >= (optimal_temp + 30)) { font_color="yellow"; }
    else if (body_temp <= (optimal_temp - 60)) { font_color="purple"; }
    else if (body_temp <= (optimal_temp - 30)) { font_color="blue"; }
    else { font_color = "green"; }
  }

  return (
    <>
      <Table.Cell header textAlign="right">
        Temperature:
      </Table.Cell>
      <Table.Cell color={font_color}>
        {occupied ? (body_temp - 273.15).toPrecision(4) : "--"}°C  /  {occupied ?((body_temp - 273.15) * 1.8 + 32).toPrecision(4) : "--" }°F
      </Table.Cell>
    </>
  );
};

const DisplayVitals = (props, context) => {
  const { data } = useBackend<OperatingComputerData>(context);
  const processedData = processStatsData(data.patient_data);
  const oxy = data.occupied ? Math.floor(data.oxygen).toString() : "--";
  const oxy_data = data.occupied && processedData ? processedData["oxygen"] : [];
  const toxin = data.occupied ? Math.floor(data.toxin).toString() : "--";
  const toxin_data = data.occupied && processedData ? processedData["toxin"] : [];
  const burn = data.occupied ? Math.floor(data.burn).toString() : "--";
  const burn_data = data.occupied && processedData ? processedData["burn"] : [];
  const brute = data.occupied ? Math.floor(data.brute).toString() : "--";
  const brute_data = data.occupied && processedData ? processedData["brute"] : [];

  return (
    <Section title="Vitals">
      <Stack textAlign="center">
        <HealthGraph title="Suffocation" value={oxy} metric_data={oxy_data} metric="oxy" />
        <HealthGraph title="Toxin" value={toxin} metric_data={toxin_data} metric="toxin" />
        <HealthGraph title="Burn" value={burn} metric_data={burn_data} metric="burn" />
        <HealthGraph title="Brute" value={brute} metric_data={brute_data} metric="brute" />
      </Stack>
    </Section>
  );
};

const DisplayAnatomicalAnomolies = (props:DisplayAnatomicalAnomoliesProps) => {
  const {
    occupied,
    organs,
    limbs,
  } = props;

  if (occupied) {
    return (
      <Section title="Anatomical Anomalies">
        <Stack>
          <DisplayOrgans occupied={occupied} organs={organs} />
          <DisplayLimbs occupied={occupied} limbs={limbs} />
        </Stack>
      </Section>);
  } else {
    return (<Section title="Anatomical Anomalies" color="grey">No Patient Detected</Section>);
  }
};

const DisplayBloodstreamContent = (props:DisplayBloodstreamContentProps) => {
  const { occupied, reagent_container } = props;
  if (occupied) {
    return (
      <Section title="Bloodstream Contents">
        <ReagentGraph container={reagent_container} />
      </Section>
    );
  }
  else {
    return (<Section title="Bloodstream Contents" color="grey">No Patient Detected</Section>);
  }
};

const DisplayGeneticAnalysis = (props: DisplayGeneticAnalysisProps) => {
  const {
    occupied,
    age,
    blood_type,
    blood_color_value,
    blood_color_name,
    clone_generation,
    cloner_defect_count,
    genetic_stability,
  } = props;
  if (occupied) {
    return (
      <Section title="Genetic Analysis">
        <Stack>
          <Stack.Item width={20}>
            <Table>
              <Table.Row>
                <Table.Cell header textAlign="right">Age:</Table.Cell>
                <Table.Cell >{age}</Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell header textAlign="right">Blood Type:</Table.Cell>
                <Table.Cell>{blood_type}</Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell header textAlign="right">Blood Color:</Table.Cell>
                <Table.Cell>
                  <ColorBox backgroundColor={blood_color_value} /> <span>{blood_color_name}</span>
                </Table.Cell>
              </Table.Row>
            </Table>
          </Stack.Item>
          <Stack.Item width={14}>
            <Table>
              <Table.Row>
                <Table.Cell header textAlign="right">Clone Generation:</Table.Cell>
                <Table.Cell >{clone_generation}</Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell header textAlign="right">Genetic Defects:</Table.Cell>
                <Table.Cell>{cloner_defect_count}</Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell header textAlign="right">Genetic Stability:</Table.Cell>
                <Table.Cell>{genetic_stability}</Table.Cell>
              </Table.Row>
            </Table>
          </Stack.Item>
        </Stack>
      </Section>
    );
  } else {
    return (<Section title="Genetic Analysis" color="grey">No Patient Detected</Section>);
  }
};

const DisplayTitle = (props:OperatingComputerDisplayTitleProps) => {
  const {
    occupied,
    patient_name,
    patient_health,
    patient_max_health,
    patient_status,
  } = props;
  const patient_name_color = occupied ? "white" : "grey";
  const is_crit = occupied && patient_health < 0;
  const patient_health_percent = occupied ? Math.floor(100 * patient_health / patient_max_health) : 0;
  let patient_health_percent_text = "--";
  let color = "grey";

  if (occupied) {
    if (patient_max_health <= 0) {
      color = "purple";
      patient_health_percent_text = "???";
    }
    else {
      patient_health_percent_text = patient_health_percent.toString();
      if (patient_health_percent >= 51 && patient_health_percent <= 100) { color = "green"; }
      else if (patient_health_percent >= 1 && patient_health_percent <= 50) { color = "yellow"; }
      else { color="red"; }
    }
  }

  return (
    <Stack>
      <Stack.Item width={60}>
        <Box fontSize={1}>Patient Name</Box>
        <Box fontSize={1.5} color={patient_name_color} >
          {patient_name ? patient_name : "No Patient Detected"}
        </Box>
      </Stack.Item>
      <HealthSummary health_text={patient_health_percent_text} health_color={color} />
      <PatientSummary occupied={occupied} patient_status={patient_status} isCrit={is_crit} />
    </Stack>
  );
};

const DisplayTempImplantRow = (props: DisplayTempImplantRowProps) => {
  const {
    occupied,
    body_temp,
    optimal_temp,
    embedded_objects,
  } = props;

  return (
    <Table.Row>
      <DisplayTemperature occupied={occupied} body_temp={body_temp} optimal_temp={optimal_temp} />
      <DisplayImplants occupied={occupied} embedded_objects={embedded_objects} />
    </Table.Row>
  );
};

const DisplayImplants = (props) => {
  const { embedded_objects, occupied } = props;
  return (
    <>
      <Table.Cell header textAlign="right">Implants:</Table.Cell>
      <Table.Cell color={occupied ? "white": "grey"}>
        {occupied ? `${embedded_objects["implant_count"]} implant${embedded_objects["implant_count"]===1 ? "" : "s"}` : "--"}
      </Table.Cell>
    </>
  );
};

const DisplayEmbeddedObjects = (props) => {
  const { embedded_objects } = props;
  return (
    <Box textAlign="center">
      {embedded_objects["has_chest_object"] ? <Box bold fontSize={1.2} color="red">Sizable foreign object located below sternum!</Box>: ""}
      {embedded_objects["foreign_object_count"] ? <Box bold fontSize={1.2} color="red">Foreign object{embedded_objects["foreign_object_count"] > 1 ?"s" : ""} detected!</Box> : ""}
    </Box>
  );
};
