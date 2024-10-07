/**
 * @file
 * @copyright 2023
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { toTitleCase } from 'common/string';
import { useState } from 'react';
import { Box, Divider, Section, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { AntagonistPanelData } from './type';

export const AntagonistTypeTabs = (props) => {
  const { data, act } = useBackend<AntagonistPanelData>();
  const [tabIndex, setTab] = useState(data.tabToOpenOn);

  const sortTabs =
    data.tabs.sort((a, b) => a.tabName.localeCompare(b.tabName)) || [];

  const SetTab = (index) => {
    setTab(index);
    act('set_tab', { index: index });
  };

  return (
    <Section inline fill>
      <Tabs vertical>
        <Tabs.Tab
          selected={tabIndex === null}
          onClick={() => SetTab(null)}
          width={12}
          my={0.2}
        >
          General
        </Tabs.Tab>
        <Box my={-0.5}>
          <Divider />
        </Box>
        {sortTabs.map((tab, index) => (
          <Tabs.Tab
            key={index}
            selected={tabIndex === tab.index}
            onClick={() => SetTab(tab.index)}
            width={12}
            my={0.2}
          >
            {toTitleCase(tab.tabName)}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Section>
  );
};
