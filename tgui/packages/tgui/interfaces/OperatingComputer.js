
import { useBackend, useLocalState } from '../backend';
import { Box, ColorBox, Chart, Section, Stack, Tabs, Table } from '../components';
import { Window } from '../layouts';
import { HealthStat } from './common/HealthStat';
import { COLORS } from '../constants';
import { ReagentGraph } from './common/ReagentInfo';
import { getStatsMax, processStatsData } from './EngineStats';
import { capitalize, spaceUnderscores } from './common/stringUtils';

export const OperatingComputer = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 1);

  return (
    <Window title="Operating Computer" width="560" height="760">
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={tabIndex === 1}
            onClick={() => setTabIndex(1)}>
            Patient Health
          </Tabs.Tab>
          {/* <Tabs.Tab
            selected={tabIndex === 2}
            onClick={() => setTabIndex(2)}>
            Emergency Medical Helper
          </Tabs.Tab> */}
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

// mob.stat & crit parsing
const PatientSummary = (props) => {
  const { occupied, patient_status, health } = props;
  let text = "NONE";
  let color = "grey";
  if (occupied) {
    if (patient_status === 2) {
      text = "DEAD";
      color = "red";
    }
    else if (health < 0) {
      text = "CRIT";
      color = "orange";
    }
    else if (patient_status === 0 || !patient_status) {
      text = "STABLE";
      color = "green";
    }
    else if (patient_status === 1) {
      text = "UNCON";
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
  return (
    <Section title={<DisplayTitle />}>
      <DisplayVitals />
      <DisplayKeyHealthIndicators />
      <DisplayAnatomicalAnomolies />
      <DisplayBloodstreamContent />
      <DisplayGeneticAnalysis />
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

const DisplayBloodPressure = (props, context) => {
  const { data } = useBackend(context);
  let blood_pressure_rendered = "--/--";
  let blood_pressure_status = "NO PULSE";
  let blood_pressure_total = "--";
  let pressure_color = "grey";
  if (data.occupied) {
    if (data.victim_status !== 2) {
      const blood_pressure = data.blood_pressure;
      blood_pressure_rendered = blood_pressure["rendered"];
      blood_pressure_status = blood_pressure["status"];
      blood_pressure_total = blood_pressure["total"];
      if (blood_pressure_total <= 299) {
        pressure_color = "red";
      } else if (blood_pressure_total <= 414) {
        pressure_color = "yellow";
      } else if (blood_pressure_total <= 584) {
        pressure_color = "green";
      } else if (blood_pressure_total <=665) {
        pressure_color = "yellow";
      } else {
        pressure_color = "red";
      }
    }
  }

  return (
    <Table.Row>
      <Table.Cell header textAlign="right" width={10}>Blood Pressure:</Table.Cell>
      <Table.Cell width={10} color={pressure_color}>{blood_pressure_rendered} ({blood_pressure_status})</Table.Cell>
      <Table.Cell header textAlign="right" width={10}>Blood Volume:</Table.Cell>
      <Table.Cell width={10} color={pressure_color}>{blood_pressure_total} units</Table.Cell>
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

const DisplayBrain = (props) => {
  const { brain_damage_desc, brain_damage_value } = props;
  if (brain_damage_desc !== "Okay") {
    return (
      <Table.Row>
        <Table.Cell header textAlign="right" color="pink" width={10}>
          Brain Damage:
        </Table.Cell>
        <Table.Cell width={10}>{brain_damage_desc}</Table.Cell>
        <Table.Cell header textAlign="right" width={10}>Neuron Cohesion:</Table.Cell>
        <Table.Cell>{((120-brain_damage_value)/120*100).toFixed(2)}%</Table.Cell>
      </Table.Row>
    );
  }
};

const DisplayOrgans = (props, context) => {
  const { organ_status } = props;
  const { data } = useBackend(context);
  if (data.occupied) {
    return (
      <Stack.Item width={20}>
        <Table>
          <Table.Row>
            <Table.Cell header textAlign="right">Organ</Table.Cell>
            <Table.Cell header>Status</Table.Cell>
          </Table.Row>
          {
            organ_status.map((organ_bundle) => {
              return (
                <DisplayOrgan
                  key={organ_bundle["organ_name"]}
                  bundle={organ_bundle}
                />
              );
            })
          }
        </Table>
      </Stack.Item>
    ); }
};

const DisplayOrgan = (props) => {
  const { bundle } = props;
  const organ_special = bundle["special"];
  const organ_state = bundle["organ_state"];
  const organ_name = bundle["organ_name"];

  const special_color = organTraitToColor(organ_special);

  let font_color = "green";
  let is_bold = false;

  if (organ_state === "Missing") {
    font_color = "red";
    is_bold = true;
  }
  if (organ_state === "Dead") {
    font_color = "red";
    is_bold = true;
  }
  if (organ_state === "Critical") {
    font_color = "orange";
    is_bold = true;
  }
  if (organ_state === "Significant") {
    font_color = "orange";
  }
  if (organ_state === "Moderate") {
    font_color = "yellow";
  }
  if (organ_state === "Minor") {
    font_color = "green";
  }

  if (organ_state !== "Okay" || organ_special) {
    return (
      <Table.Row>
        <Table.Cell header textAlign="right" width={10}>
          {capitalize(spaceUnderscores(organ_name))}:
        </Table.Cell>
        <Table.Cell width={10} color={font_color} bold={is_bold}>{organ_state}{organ_special ? <Box inline color={special_color}>, {organ_special}</Box> :"" }</Table.Cell>
      </Table.Row>
    );
  }

};

const organTraitToColor = (organ_trait) => {
  let special_color = "";
  if (organ_trait) {
    special_color = "white";
  }
  if (organ_trait === "UNKNOWN") {
    special_color = "purple";
  }
  if (organ_trait === "Missing") {
    special_color = "red";
  }
  if (organ_trait === "Cybernetic") {
    special_color = "teal";
  }
  if (organ_trait === "Synthetic") {
    special_color = "olive";
  }
  return special_color;
};

const DisplayLimbs = (props, context) => {
  const { limb_status } = props;
  const { data } = useBackend(context);
  if (data.occupied) {
    return (
      <Stack.Item width={20}>
        <Table>
          <Table.Row>
            <Table.Cell header textAlign="right">Limb</Table.Cell>
            <Table.Cell header>Status</Table.Cell>
          </Table.Row>
          {
            limb_status.map((limb_bundle) => {
              return (
                <DisplayLimb
                  key={limb_bundle["limb"]}
                  bundle={limb_bundle}
                />
              );
            })
          }
        </Table>
      </Stack.Item>
    );
  }
};

const DisplayLimb = (props) => {
  const { bundle } = props;
  const limb_name = bundle["limb"];
  const limb_status = bundle["status"];
  const limb_color = organTraitToColor(bundle["status"]);
  let is_bold = false;

  if (limb_status === "Missing") {
    is_bold = true;
  }

  if (limb_status !== "Okay") {
    return (
      <Table.Row>
        <Table.Cell header textAlign="right" width={10}>
          {capitalize(spaceUnderscores(limb_name))}:
        </Table.Cell>
        <Table.Cell width={10} color={limb_color} bold={is_bold}>{limb_status}</Table.Cell>
      </Table.Row>
    );
  }
};

const DisplayTemperature = (props, context) => {
  const { data } = useBackend(context);
  const { body_temp, optimal_temp } = props;
  let font_color = "grey";
  let body_temp_c = "--";
  let body_temp_f = "--";
  if (data.occupied) {
    if (body_temp >= (optimal_temp + 60)) { font_color="red"; }
    else if (body_temp >= (optimal_temp + 30)) { font_color="yellow"; }
    else if (body_temp <= (optimal_temp - 60)) { font_color="purple"; }
    else if (body_temp <= (optimal_temp - 30)) { font_color="blue"; }
    else { font_color = "green"; }
    body_temp_c = (body_temp - 273.15).toFixed(2);
    body_temp_f = (body_temp_c * 1.8 + 32).toFixed(2);
  }

  return (
    <Table.Row>
      <Table.Cell header textAlign="right">
        Temperature:
      </Table.Cell>
      <Table.Cell color={font_color}>
        { body_temp_c + "°C / " + body_temp_f + "°F"}
      </Table.Cell>
    </Table.Row>
  );
};

const DisplayVitals = (props, context) => {
  const { data } = useBackend(context);
  const processedData = processStatsData(data.victim_data);

  let oxy = "--";
  let oxy_data = [];
  let toxin = "--";
  let toxin_data =[];
  let burn = "--";
  let burn_data = [];
  let brute = "--";
  let brute_data = [];
  if (data.occupied) {
    oxy = Math.floor(data.oxygen);
    toxin = Math.floor(data.toxin);
    burn = Math.floor(data.burn);
    brute = Math.floor(data.brute);
    oxy_data = processedData["oxygen"];
    toxin_data = processedData["toxin"];
    burn_data = processedData["burn"];
    brute_data = processedData["brute"];
  }

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

const DisplayAnatomicalAnomolies = (props, context) => {
  const { data } = useBackend(context);
  if (data.occupied) {
    return (
      <Section title="Anatomical Anomalies">
        <Stack>
          <DisplayOrgans organ_status={data.organ_status} />
          <DisplayLimbs limb_status={data.limb_status} />
        </Stack>
      </Section>);
  } else {
    return (<Section title="Anatomical Anomalies" color="grey">No Patient Detected</Section>);
  }
};

const DisplayBloodstreamContent = (props, context) => {
  const { data } = useBackend(context);
  if (data.occupied) {
    return (
      <Section title="Bloodstream Contents">
        <ReagentGraph container={data.reagent_container} />
      </Section>
    );
  }
  else {
    return (<Section title="Bloodstream Contents" color="grey">No Patient Detected</Section>);
  }
};

const DisplayGeneticAnalysis = (props, context) => {
  const { data } = useBackend(context);
  if (data.occupied) {
    return (
      <Section title="Genetic Analysis">
        <Stack>
          <Stack.Item width={20}>
            <Table>
              <Table.Row>
                <Table.Cell header textAlign="right">Age:</Table.Cell>
                <Table.Cell >{data.age}</Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell header textAlign="right">Blood Type:</Table.Cell>
                <Table.Cell>{data.blood_type}</Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell header textAlign="right">Blood Color:</Table.Cell>
                <Table.Cell>
                  <ColorBox backgroundColor={data.blood_color_value} /> <span>{data.blood_color_name}</span>
                </Table.Cell>
              </Table.Row>
            </Table>
          </Stack.Item>
          <Stack.Item width={14}>
            <Table>
              <Table.Row>
                <Table.Cell header textAlign="right">Clone Generation:</Table.Cell>
                <Table.Cell >{data.clone_generation}</Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell header textAlign="right">Genetic Defects:</Table.Cell>
                <Table.Cell>{data.cloner_defects}</Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell header textAlign="right">Genetic Stability:</Table.Cell>
                <Table.Cell>{data.genetic_stability}</Table.Cell>
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

const DisplayTitle = (props, context) => {
  const { data } = useBackend(context);
  let patient_name = "No Patient Detected";
  let patient_name_color = "grey";
  let patient_health = "--";
  let patient_health_percent = "--";
  let patient_status = "--";
  let color = "grey";
  if (data.occupied) {
    patient_name = data.patient_name;
    patient_name_color = "white";
    patient_health_percent = Math.floor(100 * data.health / data.max_health);
    patient_health = data.health;
    patient_status = data.victim_status;

    color = "purple";

    if (data.max_health <= 0) {
      patient_health_percent = "???";
    }

    if (patient_health_percent >= 51 && patient_health_percent <= 100) { color = "green"; }
    else if (patient_health_percent >= 1 && patient_health_percent <= 50) { color = "yellow"; }
    else { color="red"; }
  }
  return (
    <Stack>
      <Stack.Item width={60}>
        <Box fontSize={1}>Patient Name</Box>
        <Box fontSize={1.5} color={patient_name_color} >
          {patient_name}
        </Box>
      </Stack.Item>
      <HealthSummary health_text={patient_health_percent} health_color={color} />
      <PatientSummary occupied={data.occupied} patient_status={patient_status} health={patient_health} />
    </Stack>
  );
};

const DisplayKeyHealthIndicators = (props, context) => {
  const { data } = useBackend(context);
  return (
    <Section title="Key Health Indicators">
      <Table>
        <DisplayBloodPressure />
        <DisplayTemperature body_temp={data.body_temp} optimal_temp={data.optimal_temp} />
        { data.occupied? <DisplayRads rad_stage={data.rad_stage} rad_dose={data.rad_dose} />: ""}
        { data.occupied? <DisplayBrain brain_damage_desc={data.brain_damage_desc} brain_damage_value={data.brain_damage_value} />:""}
      </Table>
    </Section>);
};
