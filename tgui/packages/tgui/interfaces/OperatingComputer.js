
import { useBackend, useLocalState } from '../backend';
import { Box, ColorBox, Chart, Section, Stack, Tabs, Table } from '../components';
import { Window } from '../layouts';
import { HealthStat } from './common/HealthStat';
import { COLORS } from '../constants';
import { ReagentGraph } from './common/ReagentInfo';
import { getStatsMax, processStatsData } from './EngineStats';
import { capitalize, spaceUnderscores } from './common/stringUtils';

export const OperatingComputer = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 1);
  const {
    patient_name,
    health,
    max_health,
    brute,
    burn,
    toxin,
    oxygen,
    victim_status,
    victim_data,
    age,
    blood_color_name,
    blood_color_value,
    blood_type,
    dna_id,
    clone_generation,
    genetic_stability,
    blood_pressure,
    occupied,
    rad_stage,
    rad_dose,
    reagent_container,
  } = data;

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

const ComputerTabs = (props, context) => {
  const { act, data } = useBackend(context);
  const { tabIndex } = props;
  if (tabIndex === 1) { return (<PatientStatus data={data} />); }
};

// mob.stat & crit parsing
const VictimStatus = (props) => {
  const { victim_status, health } = props;
  if (victim_status === 2) { return <Box color="red">DEAD</Box>; }
  if (health < 0) { return <Box color="orange">CRIT</Box>; }
  if (victim_status === 0 || !victim_status) { return <Box color="green">ALIVE</Box>; }
  if (victim_status === 1) { return <Box color="yellow">UNCON</Box>; }
};

const HealthSummary = (props) => {
  const { health, max_health } = props;
  const health_percent = Math.floor(100 * health / max_health);
  let display_color = "purple";

  if (max_health <= 0) {
    return (
      <Stack.Item width={20} textAlign="right">
        <Box fontSize={1}>Overall Health</Box>
        <Box fontSize={1.5} color="purple">???</Box>
      </Stack.Item>
    );
  }

  if (health_percent >= 51 && health_percent <= 100) { display_color = "green"; }
  else if (health_percent >= 1 && health_percent <= 50) { display_color = "yellow"; }
  else { display_color="red"; }

  return (
    <Stack.Item width={20} textAlign="right">
      <Box fontSize={1}>Overall Health</Box>
      <Box fontSize={1.5}>
        <Box color={display_color}>{health_percent}<span style={{ color: "white" }}>%</span></Box>
      </Box>
    </Stack.Item>
  );
};

const PatientStatus = (props) => {
  const { tabIndex, data, act } = props;
  const processedData = processStatsData(data.victim_data);

  if (data.occupied === 1) {
    return (
      <Section title={
        <Stack>
          <Stack.Item width={60}>
            <Box fontSize={1}>Patient Name</Box>
            <Box fontSize={1.5} >
              {data.patient_name}
            </Box>
          </Stack.Item>
          <HealthSummary health={data.health} max_health={data.max_health} />
          <Stack.Item width={20} textAlign="right">
            <Box fontSize={1}>Status</Box>
            <Box fontSize={1.5}><VictimStatus victim_status={data.victim_status} health={data.health} />
            </Box>
          </Stack.Item>
        </Stack>
      }>
        <Section title="Vitals">
          <Stack textAlign="center">
            <Stack.Item width={25}>
              <HealthStat type="oxy">Suffocation<br /><Box fontSize={4}>{Math.floor(data.oxygen)}</Box>
                <Box>
                  <Chart.Line
                    mt="5px"
                    height="5em"
                    data={processedData["oxygen"]}
                    rangeX={[0, processedData["oxygen"].length - 1]}
                    rangeY={[0, Math.max(100, getStatsMax(processedData["oxygen"]))]}
                    strokeColor={COLORS.damageType["oxy"]}
                    fillColor="rgba(52, 152, 219, 0.5)"
                  />
                </Box>
              </HealthStat>
            </Stack.Item>
            <Stack.Item width={25}>
              <HealthStat type="toxin">Toxin<br /><Box fontSize={4}>{Math.floor(data.toxin)}</Box>
                <Box>
                  <Chart.Line
                    mt="5px"
                    height="5em"
                    data={processedData["toxin"]}
                    rangeX={[0, processedData["toxin"].length - 1]}
                    rangeY={[0, Math.max(100, getStatsMax(processedData["toxin"]))]}
                    strokeColor={COLORS.damageType["toxin"]}
                    fillColor="rgba(46, 204, 113, 0.5)"
                  />
                </Box>
              </HealthStat>
            </Stack.Item>
            <Stack.Item width={25}>
              <HealthStat type="burn">Burns<br /><Box fontSize={4}>{Math.floor(data.burn)}</Box>
                <Box>
                  <Chart.Line
                    mt="5px"
                    height="5em"
                    data={processedData["burn"]}
                    rangeX={[0, processedData["burn"].length - 1]}
                    rangeY={[0, Math.max(100, getStatsMax(processedData["burn"]))]}
                    strokeColor={COLORS.damageType["burn"]}
                    fillColor="rgba(230, 126, 34, 0.5)"
                  />
                </Box>
              </HealthStat>
            </Stack.Item>
            <Stack.Item width={25}>
              <HealthStat type="brute">
                <Box>Brute</Box>
                <Box fontSize={4}>{Math.floor(data.brute)}</Box>
                <Box>
                  <Chart.Line
                    mt="5px"
                    height="5em"
                    data={processedData["brute"]}
                    rangeX={[0, processedData["brute"].length - 1]}
                    rangeY={[0, Math.max(100, getStatsMax(processedData["brute"]))]}
                    strokeColor={COLORS.damageType["brute"]}
                    fillColor="rgba(231, 76, 60, 0.5)"
                  />
                </Box>
              </HealthStat>
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Key Health Indicators">
          <Table>
            <DisplayBloodPressure blood_pressure={data.blood_pressure} />
            <DisplayRads rad_stage={data.rad_stage} rad_dose={data.rad_dose} />
            <DisplayBrain brain_damage={data.brain_damage} />
            <DisplayOrgans organ_status={data.organ_status} />
          </Table>
        </Section>
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
                  <Table.Cell header textAlign="right">Genetic Stability:</Table.Cell>
                  <Table.Cell>{data.genetic_stability}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell header textAlign="right">Cloner Defects:</Table.Cell>
                  <Table.Cell>{data.cloner_defects}</Table.Cell>
                </Table.Row>
              </Table>
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Bloodstream Analysis">
          <ReagentGraph container={data.reagent_container} />
        </Section>
      </Section>
    );
  } else {
    return (
      <Stack>
        <Stack.Item>No Patient Detected</Stack.Item>
      </Stack>);
  }
};

const DisplayBloodPressure = (props) => {
  const { blood_pressure } = props;
  return (
    <Table.Row>
      <Table.Cell header textAlign="right" width={10}>Blood Pressure:</Table.Cell>
      <Table.Cell width={10}>{blood_pressure["rendered"]} ({blood_pressure["status"]})</Table.Cell>
      <Table.Cell header textAlign="right" width={10}>Blood level:</Table.Cell>
      <Table.Cell width={10}>{blood_pressure["total"]} units</Table.Cell>
    </Table.Row>
  );
};

const DisplayRads = (props) => {
  const { rad_stage, rad_dose } = props;
  if (rad_stage > 0) {
    return (
      <Table.Row>
        <Table.Cell header textAlign="right" width={10} color="yellow">Radiation:</Table.Cell>
        <Table.Cell width={10}>Stage {rad_stage}</Table.Cell>
        <Table.Cell header textAlign="right" width={10}>Sieverts:</Table.Cell>
        <Table.Cell width={10}>{rad_dose} units</Table.Cell>
      </Table.Row>
    );
  }
};

const DisplayBrain = (props) => {
  const { brain_damage } = props;
  if (brain_damage !== "Okay") {
    return (
      <Table.Row>
        <Table.Cell header textAlign="right" color="pink">
          Brain Damage:
        </Table.Cell>
        <Table.Cell>{brain_damage}</Table.Cell>
      </Table.Row>
    );
  }
};

const DisplayOrgans = (props) => {
  const { organ_status } = props;
  return (
    organ_status.map((organ_bundle) => {
      return (
        <DisplayOrgan
          key={organ_bundle["organ_name"]}
          bundle={organ_bundle}
        />
      );
    })
  );
};

const DisplayOrgan = (props) => {
  const { bundle } = props;
  const organ_special = bundle["special"];
  const organ_state = bundle["organ_state"];
  const organ_name = bundle["organ_name"];

  let font_color = "green";
  let special_color = "purple";
  let is_bold = false;

  if (organ_special === "Cybernetic") {
    special_color = "teal";
  }
  if (organ_special === "Synthetic") {
    special_color = "olive";
  }
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
        <Table.Cell header textAlign="right">
          {capitalize(spaceUnderscores(organ_name))}:
        </Table.Cell>
        <Table.Cell color={font_color} bold={is_bold}>{organ_state}{organ_special ? <span style={{ "color": special_color }}> - {organ_special}</span> :"" }</Table.Cell>
      </Table.Row>
    );
  }

};
