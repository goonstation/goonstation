import { useBackend, useLocalState } from "../../backend";
import { Box, Section, Stack, Tabs } from "../../components";
import { ReportData, ReportTabData } from "./type";

export const ReportTab = (props, context) => {
  const { data } = useBackend<ReportTabData>(context);
  const { reports } = data;
  return (
    <Section>
      {!reports.length && "No reports filed."}
      {reports.map((report, index) => {
        return (
          <Report key={index} {...report} />
        );
      })}
    </Section>
  );
};
const Report = (props: ReportData, context) => {
  const [menu, setMenu] = useLocalState(context, 'reportMenu', 1);
  const { pages } = props;
  return (
    <Stack vertical>
      <Stack.Item>
        <Tabs>
          {pages.map((page, index) => {
            return (
              <Tabs.Tab
                key={index}
                selected={menu === index}
                onClick={() => setMenu(index)}
              >
                {page.title ? page.title : "paper"}
              </Tabs.Tab>
            );

          })}
        </Tabs>
      </Stack.Item >
      {pages.map((page, index) => {
        return (
          <Stack.Item key={index}>
            { menu === index && <ReportSheetView value={page.info} backgroundColor="white" readOnly />}
          </Stack.Item>
        );

      })}

    </Stack>
  );
};


const setInputReadonly = (text, readonly) => {
  return readonly
    ? text.replace(/<input\s[^d]/g, '<input disabled ')
    : text.replace(/<input\sdisabled\s/g, '<input ');
};

// only difference is unsetting fillPositionedParent
const ReportSheetView = (props, context) => {
  const {
    value = "",
    backgroundColor,
    readOnly,
  } = props;
  const textHtml = {
    __html: '<span class="paper-text">'
      + setInputReadonly(value, readOnly)
      + '</span>',
  };
  return (
    <Box
      className="paper__page"
      position="relative"
      backgroundColor={backgroundColor}
      width="100%"
      height="100%">
      <Box
        color="black"
        backgroundColor={backgroundColor}
        width="100%"
        height="100%"
        dangerouslySetInnerHTML={textHtml}
        p="10px" />
    </Box>
  );
};
