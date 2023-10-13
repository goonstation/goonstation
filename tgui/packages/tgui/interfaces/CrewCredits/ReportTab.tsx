import { useBackend, useLocalState } from "../../backend";
import { Section, Stack, Tabs } from "../../components";
import { PaperSheetView } from "../PaperSheet";
import { CrewCreditsTabKeys, ReportData, ReportTabData } from "./type";

export const ReportMenuTab = (props, context) => {
  const { menu, setMenu } = props;
  const { data } = useBackend<ReportTabData>(context);
  const { reports } = data;
  if (!reports.length) {
    return;
  }
  return (
    <Tabs.Tab
      selected={menu === CrewCreditsTabKeys.Report}
      onClick={() => setMenu(CrewCreditsTabKeys.Report)}>
      Inspector&apos;s Report
    </Tabs.Tab>
  );
};

export const ReportTab = (props, context) => {
  const [menu, setMenu] = useLocalState(context, 'issuersMenu', 0);
  const { data } = useBackend<ReportTabData>(context);
  const { reports } = data;
  return (
    <Section>
      <Stack vertical>
        <Stack.Item>
          <Tabs>
            {reports.map((report, index) => {
              return (
                <Tabs.Tab
                  key={index}
                  selected={menu === index}
                  onClick={() => setMenu(index)}
                >
                  {report.issuer}
                </Tabs.Tab>
              );

            })}
          </Tabs>
        </Stack.Item >
        {reports.map((report, index) => {
          return (
            <Stack.Item key={index}>
              { menu === index && <Report multi={index} {...report} />}
            </Stack.Item>
          );

        })}

      </Stack>
    </Section>
  );
};

const Report = (props: ReportData, context) => {
  const [menu, setMenu] = useLocalState(context, 'pageMenu', "0-0");
  const { issuer, pages, multi } = props;
  return (
    <Stack vertical>
      <Stack.Item>
        <Section title={issuer}>
          <Tabs>
            {pages.map((page, index) => {
              const multi_index = `${multi}-${index}`;
              return (
                <Tabs.Tab
                  key={multi_index}
                  selected={menu === multi_index}
                  onClick={() => setMenu(multi_index)}
                >
                  {page.name ? page.name : "paper"}
                </Tabs.Tab>
              );
            })}
          </Tabs>
        </Section>
      </Stack.Item >
      {pages.map((page, index) => {
        const multi_index = `${multi}-${index}`;
        return (
          <Stack.Item key={multi_index}>
            { menu === multi_index
             && <PaperSheetView
               value={page.text}
               stamps={page.stamps}
               backgroundColor={page.paperColor}
               readOnly
               fillWindow={false} />}
          </Stack.Item>
        );

      })}

    </Stack>
  );
};
