/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { PropsWithChildren } from 'react';
import { Tabs } from 'tgui-core/components';

import type { NestedPartial } from '../../../../backend';
import { EmptyPlaceholder } from '../../EmptyPlaceholder';
import type { ToolData } from '../../type/data';

interface ToolProps {
  selected: boolean;
  onClick: () => void;
}

const Tool = (props: PropsWithChildren<ToolProps>) => {
  const { children, onClick, selected } = props;
  return (
    <Tabs.Tab onClick={onClick} selected={selected}>
      {children}
    </Tabs.Tab>
  );
};

interface ToolsProps {
  onSelectTool: (itemRef: string) => void;
  selectedToolRef: string | null;
  tools: NestedPartial<ToolData>[] | null;
}

export const Tools = (props: ToolsProps) => {
  const { onSelectTool, selectedToolRef, tools } = props;
  if (!tools || tools.length === 0) {
    return <EmptyPlaceholder>Module has no tools</EmptyPlaceholder>;
  }
  return (
    <Tabs vertical>
      {tools.map((tool) => {
        const { name, item_ref: itemRef } = tool;
        return (
          <Tool
            key={itemRef}
            onClick={() => itemRef && onSelectTool(itemRef)}
            selected={itemRef === selectedToolRef}
          >
            {name}
          </Tool>
        );
      })}
    </Tabs>
  );
};
