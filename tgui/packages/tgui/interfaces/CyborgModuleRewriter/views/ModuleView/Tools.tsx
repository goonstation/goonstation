/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { PropsWithChildren, useCallback } from 'react';
import { Tabs } from 'tgui-core/components';

import { EmptyPlaceholder } from '../../EmptyPlaceholder';
import type { ToolData } from '../../type/data';

interface ToolProps {
  itemRef: string;
  onClick: (itemRef: string) => void;
  selected: boolean;
}

const Tool = (props: PropsWithChildren<ToolProps>) => {
  const { children, itemRef, onClick, selected } = props;
  const handleClick = useCallback(() => onClick(itemRef), [itemRef, onClick]);
  return (
    <Tabs.Tab onClick={handleClick} selected={selected}>
      {children}
    </Tabs.Tab>
  );
};

interface ToolsProps {
  onSelectTool: (itemRef: string) => void;
  selectedToolRef: string | undefined;
  tools: ToolData[] | undefined;
}

export const Tools = (props: ToolsProps) => {
  const { onSelectTool, selectedToolRef, tools = [] } = props;
  if (tools.length === 0) {
    return <EmptyPlaceholder>Module has no tools</EmptyPlaceholder>;
  }
  return (
    <Tabs vertical>
      {tools.map((tool) => {
        const { name, item_ref: itemRef } = tool;
        return (
          <Tool
            key={itemRef}
            itemRef={itemRef}
            onClick={onSelectTool}
            selected={itemRef === selectedToolRef}
          >
            {name}
          </Tool>
        );
      })}
    </Tabs>
  );
};
