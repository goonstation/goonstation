/**
 * @file
 * @copyright 2022
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from "../backend";
import { Button, Tabs, Section, NoticeBox, LabeledList, Image, Box } from "../components";
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
  const { mode, manifest, target_name, target_owner, target_rank, target_card_look, scan_name, pronouns, custom_names,
    standard_jobs, accesses_by_area, icons } = data;

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
                    {standard_jobs.map(jobGrouping =>
                      jobGrouping.jobs && (
                        <DeptBox key={jobGrouping.name} name={jobGrouping.name} colour={jobGrouping.color}
                          current_job={target_rank} jobs={jobGrouping.jobs} />
                      )
                    )}

                    <DeptBox name="Custom" current_job={target_rank}
                      jobs={custom_names} isCustomRank />
                  </Section>

                  <Section title="Specific Area Access">
                    {accesses_by_area.map(area =>
                      area.accesses.length > 0 && (
                        <DeptBox key={area.name} name={area.name} colour={area.color} accesses={area.accesses} />
                      )
                    )}
                  </Section>

                  <Section title="Custom Card Look">
                    {icons.map(icon => (
                      <Button key={icon.style} onClick={() => act("colour", { colour: icon.style })}
                        selected={icon.card_look === target_card_look}>
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
