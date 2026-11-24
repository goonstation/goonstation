/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { useState } from 'react';
import { LabeledList, Tabs } from 'tgui-core/components';

import {
  AccessibilitySettings,
  AudioSettings,
  ControlsSettings,
  GeneralSettings,
  GraphicsSettings,
  InterfaceSettings,
} from './Sections';

enum GameSettingsSubTab {
  General = 'General',
  Interface = 'Interface',
  Controls = 'Controls',
  Graphics = 'Graphics',
  Audio = 'Audio',
  Accessibility = 'Accessibility',
}

export const GameSettingsTab = () => {
  const [subTab, setSubTab] = useState(GameSettingsSubTab.General);

  return (
    <>
      <Tabs>
        {Object.values(GameSettingsSubTab).map((tab) => (
          <Tabs.Tab
            key={tab}
            selected={subTab === tab}
            onClick={() => setSubTab(tab)}
          >
            {tab}
          </Tabs.Tab>
        ))}
      </Tabs>
      <LabeledList>
        {subTab === GameSettingsSubTab.General && <GeneralSettings />}
        {subTab === GameSettingsSubTab.Interface && <InterfaceSettings />}
        {subTab === GameSettingsSubTab.Controls && <ControlsSettings />}
        {subTab === GameSettingsSubTab.Graphics && <GraphicsSettings />}
        {subTab === GameSettingsSubTab.Audio && <AudioSettings />}
        {subTab === GameSettingsSubTab.Accessibility && (
          <AccessibilitySettings />
        )}
      </LabeledList>
    </>
  );
};
