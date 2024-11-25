/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useState } from 'react';
import { Button, Section, Stack } from 'tgui-core/components';

import type { NestedPartial } from '../../../../backend';
import type { ToolData } from '../../type/data';
import { Tools } from './Tools';

const resetOptions = [
  {
    id: 'brobocop',
    name: 'Brobocop',
  },
  {
    id: 'science',
    name: 'Science',
  },
  {
    id: 'civilian',
    name: 'Civilian',
  },
  {
    id: 'engineering',
    name: 'Engineering',
  },
  {
    id: 'medical',
    name: 'Medical',
  },
  {
    id: 'mining',
    name: 'Mining',
  },
];

interface ModuleProps {
  onMoveToolDown: (itemRef: string) => void;
  onMoveToolUp: (itemRef: string) => void;
  onRemoveTool: (itemRef: string) => void;
  onResetModule: (moduleId: string) => void;
  tools: NestedPartial<ToolData>[] | null;
}

export const ModuleDetail = (props: ModuleProps, context: unknown) => {
  const { onMoveToolDown, onMoveToolUp, onRemoveTool, onResetModule, tools } =
    props;
  const [selectedToolRef, setSelectedToolRef] = useState<string | null>(null);
  const handleRemoveTool = (itemRef: string) => {
    const toolIndex = (tools ?? []).findIndex(
      (tool) => tool.item_ref === itemRef,
    );
    setSelectedToolRef(tools?.[toolIndex + 1]?.item_ref ?? null);
    onRemoveTool(itemRef);
  };
  const resolvedSelectedToolRef =
    selectedToolRef &&
    ((tools ?? []).find((tool) => tool.item_ref === selectedToolRef)
      ?.item_ref ??
      null);
  if (selectedToolRef && !resolvedSelectedToolRef) {
    setSelectedToolRef(null);
  }
  const toolsButtons = (
    <OrganizeButtons
      itemRef={resolvedSelectedToolRef ?? undefined}
      onMoveDown={onMoveToolDown}
      onMoveUp={onMoveToolUp}
      onRemove={handleRemoveTool}
    />
  );
  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title="Reset">
          {resetOptions.map((resetOption) => {
            const { id, name } = resetOption;
            return (
              <Button key={id} onClick={() => onResetModule(id)} tooltip={name}>
                {name}
              </Button>
            );
          })}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Tools" buttons={toolsButtons}>
          <Tools
            tools={tools}
            selectedToolRef={resolvedSelectedToolRef}
            onSelectTool={setSelectedToolRef}
          />
        </Section>
      </Stack.Item>
    </Stack>
  );
};

interface OrganizeButtonsProps {
  onMoveDown: (itemRef: string) => void;
  onMoveUp: (itemRef: string) => void;
  onRemove: (itemRef: string) => void;
  itemRef: string | undefined;
}

const OrganizeButtons = (props: OrganizeButtonsProps) => {
  const { onMoveDown, onMoveUp, onRemove, itemRef } = props;
  const isItemSelected = !!itemRef;
  const handleMoveUpClick = () => itemRef && onMoveUp(itemRef);
  const handleMoveDownClick = () => itemRef && onMoveDown(itemRef);
  const handleRemoveClick = () => itemRef && onRemove(itemRef);
  return (
    <>
      <Button
        icon="arrow-up"
        disabled={!isItemSelected}
        onClick={handleMoveUpClick}
        tooltip="Move Up"
      />
      <Button
        icon="arrow-down"
        disabled={!isItemSelected}
        onClick={handleMoveDownClick}
        tooltip="Move Down"
      />
      <Button
        icon="trash"
        disabled={!isItemSelected}
        onClick={handleRemoveClick}
        tooltip="Remove"
      />
    </>
  );
};
