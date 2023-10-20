import { useBackend, useLocalState } from "../../backend";
import { Box, Section, Stack, Tabs } from "../../components";
import { PaperSheetView } from "../PaperSheet";
import { ReportData, ReportTabData } from "./type";


export const ReportsTab = (props, context) => {
  const [menu, setMenu] = useLocalState(context, 'issuersMenu', 0);
  const { data } = useBackend<ReportTabData>(context);
  const { reports } = data;
  return (
    <Section>
      <Stack vertical>
        <Stack.Item>
          {reports?.length > 1 && (
            <Tabs>
              {
                reports.map((report, index) => {
                  return (
                    <Tabs.Tab
                      key={index}
                      selected={menu === index}
                      onClick={() => setMenu(index)}
                    >
                      {report.issuer}
                    </Tabs.Tab>
                  );
                })
              }
            </Tabs>
          )}
        </Stack.Item>
        <Stack.Item>
          {reports.map((report, index) => {
            return (
              <Box key={index}>
                { menu === index && <Report {...report} />}
              </Box>
            );
          })}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const Report = (props: ReportData, context) => {
  const [menu, setMenu] = useLocalState(context, 'pageMenu', 0);
  const { issuer, pages } = props;
  return (
    <Stack>
      <Stack.Item>
        <Tabs vertical>
          {pages.map((page, index) => {
            return (
              <Tabs.Tab
                width={20}
                key={index}
                selected={menu === index}
                onClick={() => setMenu(index)}
              >
                {page.name ? page.name : "paper"}
              </Tabs.Tab>
            );
          })}
        </Tabs>
      </Stack.Item>
      <Stack.Item>
        {pages.map((page, index) => {
          return (
            <Box key={index}>
              { menu === index
             && <PaperSheetView
               value={page.text}
               stamps={page.stamps}
               backgroundColor={page.paperColor}
               readOnly
               fillWindow={false} />}
            </Box>
          );

        })}
      </Stack.Item>
    </Stack>
  );
};
