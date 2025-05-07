/**
 * @file
 * @copyright 2025
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import {
  Box,
  Button,
  Collapsible,
  Flex,
  LabeledList,
  Section,
  Table,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ModuleProps, ModuleSectionProps, ModuleTreeProps } from './type';
import { Variable } from './Variable';

export const ModuleTree = () => {
  const { data } = useBackend<ModuleTreeProps>();

  return (
    <Window title={data.title} width={670} height={750}>
      <Window.Content scrollable>
        <Section>
          <Table>
            <Table.Cell textAlign="justify">{data.info}</Table.Cell>
            <Table.Cell pl={1} collapsing>
              <ViewVariablesButton atom_ref={data.atom_ref} />
            </Table.Cell>
          </Table>
        </Section>
        <Section>
          <LabeledList>
            {data.variables?.map((variable, index) => (
              <Variable key={index} {...variable} />
            ))}
          </LabeledList>
        </Section>
        {data.module_sections?.map((section, index) => (
          <ModuleSection key={index} {...section} />
        ))}
      </Window.Content>
    </Window>
  );
};

const ModuleSection = (props: ModuleSectionProps) => {
  const sortedModules =
    props.modules.sort((a, b) => {
      if (a.auxiliary === b.auxiliary) {
        return a.id.localeCompare(b.id);
      } else {
        return a.auxiliary ? 1 : -1;
      }
    }) || [];

  return (
    <Box my={2}>
      <Collapsible title={props.title} open fontSize={1.2} bold>
        <Section mt={-1.1}>
          <Flex wrap m="-3px">
            <AddModuleButton add_action={props.add_action} />
            {sortedModules?.map((module, index) => (
              <Module key={index} {...module} />
            ))}
          </Flex>
        </Section>
      </Collapsible>
    </Box>
  );
};

const Module = (props: ModuleProps) => {
  return (
    <Flex.Item width="200px" m="5px">
      <Section
        title={
          <Flex align="center">
            <Flex.Item grow>
              <Tooltip content={props.id}>
                <Box
                  pb="1px"
                  style={{ overflow: 'hidden', textOverflow: 'ellipsis' }}
                >
                  {props.id}
                </Box>
              </Tooltip>
            </Flex.Item>
            <Flex.Item>
              <RemoveModuleButton
                disabled={props.auxiliary}
                remove_action={props.remove_action}
                id={props.id}
                tooltip={
                  props.auxiliary
                    ? 'Cannot Remove Module: All subscriptions to this module come from an auxiliary tree. Please remove the module there instead.'
                    : 'Remove Module Subscription'
                }
              />
            </Flex.Item>
            {!!props.atom_ref && (
              <Flex.Item ml="2px">
                <ViewVariablesButton atom_ref={props.atom_ref} />
              </Flex.Item>
            )}
          </Flex>
        }
        m="1px"
        className={
          props.auxiliary ? 'ModuleSection__Disabled' : 'ModuleSection'
        }
      >
        <LabeledList>
          {props.module_variables?.map((variable, index) => (
            <Variable key={index} {...variable} />
          ))}
        </LabeledList>
      </Section>
    </Flex.Item>
  );
};

const ViewVariablesButton = (props) => {
  const { atom_ref } = props;
  const { act } = useBackend<ModuleTreeProps>();

  return (
    <Button
      onClick={() => act('view_variables', { ref: atom_ref })}
      tooltip="View Variables"
      icon="gear"
      textAlign="center"
      width={2}
      p="0px"
    />
  );
};

const AddModuleButton = (props) => {
  const { add_action } = props;
  const { act } = useBackend<ModuleTreeProps>();

  return (
    <Flex.Item width="100%" mr="6px">
      <Button
        onClick={() => act(add_action)}
        tooltip="Add Module"
        fontSize={1.1}
        style={{ float: 'right' }}
      >
        + Add
      </Button>
    </Flex.Item>
  );
};

const RemoveModuleButton = (props) => {
  const { disabled, remove_action, id, tooltip } = props;
  const { act } = useBackend<ModuleTreeProps>();

  return (
    <Button
      disabled={disabled}
      onClick={() => act(remove_action, { module_id: id })}
      tooltip={tooltip}
      icon="minus"
      textAlign="center"
      width={2}
      p="0px"
    />
  );
};
