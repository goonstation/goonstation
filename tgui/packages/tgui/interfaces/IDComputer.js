/**
 * @file
 * @copyright 2022
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from "../backend";
import { Button, Tabs, Section, NoticeBox, LabeledList, Image, Slider, Dropdown, Box } from "../components";
import { Window } from '../layouts';

const DeptBox = (props, context) => {
  const { act } = useBackend(context);
  const {
    name,
    colour,

    jobs,
    current_job,
    isCustomRank,

    accesses,
  } = props;
  return (
    <Section title={name} class={`IDComputer__DeptBox ${(colour && `IDComputer__DeptBox_color_${colour}`)}`}>
      {jobs && jobs.map((job, index) => {
        return (
          <>
            {!isCustomRank && (
              <Button
                onClick={() => act("assign", { assign: job, colour: colour })}
                key={job}
                selected={job === current_job}
              >
                {job}
              </Button>
            )}
            {isCustomRank && (
              <>
                {job}
                <Button icon="save" tooltip="Save"
                  onClick={() => act("save", { save: index + 1 })}
                  pl="10px" mx="0.2rem" />
                <Button icon="check" tooltip="Apply"
                  onClick={() => act("apply", { apply: index + 1 })}
                  pl="10px" mx="0.2rem" mr="1rem" />
              </>
            )}
          </>);
      })}
      {accesses && accesses.map(access => {
        return (
          <Button
            onClick={() => act("access", { access: access.id, allowed: !access.allowed })}
            key={access.id}
            selected={access.allowed}
          >{access.name}
          </Button>);
      })}
    </Section>
  );
};

export const IDComputer = (_props, context) => {
  const { act, data } = useBackend(context);
  const { mode, manifest, target_name, target_owner, target_rank, scan_name, pronouns, custom_names,
    civilian_access, engineering_access, supply_access, research_access, security_access, command_access,
    icons } = data;

  return (
    <Window
      width={620}
      height={780}>
      <Window.Content scrollable>
        <Section>
          <Tabs>
            <Tabs.Tab
              selected={mode !== "manifest"}
              onClick={() => act("mode", { mode: 0 })}>
              ID Modification
            </Tabs.Tab>
            <Tabs.Tab
              selected={mode === "manifest"}
              onClick={() => act("mode", { mode: 1 })}>
              Crew Manifest
            </Tabs.Tab>
          </Tabs>

          {mode === "manifest" && (
            <>
              <h1>Crew Manifest:</h1>
              <em>Please use the security record computer to modify entries.</em>
              <Box my="0.5rem" dangerouslySetInnerHTML={{ __html: manifest }} />
              <Button onClick={() => act("print")} icon="print">
                Print
              </Button>
            </>
          )}

          {mode !== "manifest" && (
            <>
              <LabeledList>
                <LabeledList.Item label="Confirm identity">
                  <Button
                    onClick={() => act("scan")}
                    icon="eject">
                    {scan_name || "Insert card"}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Target">
                  <Button
                    onClick={() => act("modify")}
                    icon="eject">
                    {target_name || "Insert card or inplant"}
                  </Button>
                </LabeledList.Item>
              </LabeledList>

              {mode === "authenticated" && (
                <>
                  <hr />

                  <LabeledList>
                    <LabeledList.Item label="Registered">
                      <Button
                        onClick={() => act("reg")}>
                        {target_owner && target_owner.trim() || "(blank)"}
                      </Button>
                    </LabeledList.Item>
                    <LabeledList.Item label="Assignment">
                      <Button
                        onClick={() => act("assign", { assign: "Custom Assignment" })}>
                        {target_rank && target_rank.trim() || "Unassigned"}
                      </Button>
                    </LabeledList.Item>
                    <LabeledList.Item label="Pronouns">
                      <Button
                        onClick={() => act("pronouns", { pronouns: "next" })}>
                        {pronouns || "None"}
                      </Button>
                      {pronouns
                      && (
                        <Button onClick={() => act("pronouns", { pronouns: "remove" })}
                          icon="trash" tooltip="Remove" />
                      )}
                    </LabeledList.Item>
                    <LabeledList.Item label="PIN">
                      <Button
                        onClick={() => act("pin")}>
                        ****
                      </Button>
                    </LabeledList.Item>
                  </LabeledList>

                  {/* Jobs organised into sections */}
                  <Section title="Standard Job Assignment">
                    <DeptBox name="Civilian" colour="blue" current_job={target_rank}
                      jobs={["Staff Assistant", "Bartender", "Chef", "Botanist", "Rancher", "Chaplain", "Janitor", "Clown"]} />
                    <DeptBox name="Supply and Maintainence" colour="yellow" current_job={target_rank}
                      jobs={["Engineer", "Miner", "Quartermaster"]} />
                    <DeptBox name="Research and Medical" colour="purple" current_job={target_rank}
                      jobs={["Scientist", "Medical Doctor", "Geneticist", "Roboticist", "Pathologist"]} />
                    <DeptBox name="Security" colour="red" current_job={target_rank}
                      jobs={["Security Officer", "Security Assistant", "Detective"]} />
                    <DeptBox name="Command" colour="green" current_job={target_rank}
                      jobs={["Head of Personnel", "Chief Engineer", "Research Director", "Medical Director", "Captain"]} />

                    <DeptBox name="Custom" current_job={target_rank}
                      jobs={custom_names} isCustomRank />
                  </Section>

                  <Section title="Specific Area Access">
                    <DeptBox name="Civilian" colour="blue" accesses={civilian_access} />
                    <DeptBox name="Engineering" colour="yellow" accesses={engineering_access} />
                    <DeptBox name="Supply" colour="yellow" accesses={supply_access} />
                    <DeptBox name="Science and Medical" colour="purple" accesses={research_access} />
                    <DeptBox name="Security" colour="red" accesses={security_access} />
                    <DeptBox name="Command" colour="green" accesses={command_access} />
                  </Section>

                  <Section title="Custom Card Look">
                    {icons.map(icon => (
                      <Button key={icon.style} onClick={() => act("colour", { colour: icon.style })}>
                        <Image
                          verticalAlign="middle"
                          my="0.2rem"
                          mr="0.5rem"
                          height="24px"
                          width="24px"
                          src={`data:image/png;base64,${icon.icon}`} />
                        {icon.name}
                      </Button>
                    ))}
                  </Section>
                </>
              )}
              {mode === "unauthenticated" && scan_name && target_name && (
                <NoticeBox mt="0.5rem" warning>Identity <em>{scan_name}</em> unauthorized to perform ID modifications.</NoticeBox>
              )}
            </>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
