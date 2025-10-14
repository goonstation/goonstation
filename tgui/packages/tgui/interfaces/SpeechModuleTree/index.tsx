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
  LabeledList,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ModuleProps, ModuleSectionProps, SpeechModuleTreeProps } from './type';
import { Variable } from './Variable';

export const SpeechModuleTree = () => {
  const { data } = useBackend<SpeechModuleTreeProps>();

  return (
    <Window title={data.title} width={661} height={740}>
      <Window.Content scrollable className="SpeechModuleTree">
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
    <Box>
      <Collapsible title={props.title} open fontSize={1.2} bold>
        <Section mt={-1}>
          <Stack wrap m="-3px">
            <AddModuleButton add_action={props.add_action} />
            {sortedModules?.map((module, index) => (
              <Module key={index} {...module} />
            ))}
          </Stack>
        </Section>
      </Collapsible>
    </Box>
  );
};

const Module = (props: ModuleProps) => {
  return (
    <Stack.Item width="17em">
      <Section
        title={
          <Stack align="center">
            <Stack.Item grow>
              <Tooltip content={props.id}>
                <Box
                  pb="1px"
                  maxWidth="10em"
                  overflow="hidden"
                  style={{ textOverflow: 'ellipsis' }}
                >
                  {props.id}
                </Box>
              </Tooltip>
            </Stack.Item>
            <Stack.Item>
              {props.auxiliary ? (
                <GoToAuxillaryButton aux_ref={props.aux_ref} />
              ) : (
                <RemoveModuleButton
                  remove_action={props.remove_action}
                  id={props.id}
                  tooltip="Remove Module Subscription"
                />
              )}
            </Stack.Item>
            {!!props.atom_ref && (
              <Stack.Item>
                <ViewVariablesButton atom_ref={props.atom_ref} />
              </Stack.Item>
            )}
          </Stack>
        }
        m="1px"
        className={props.auxiliary ? 'module--auxiliary' : 'module'}
      >
        <LabeledList>
          {props.module_variables?.map((variable, index) => (
            <Variable key={index} {...variable} />
          ))}
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const AddModuleButton = (props) => {
  const { add_action } = props;
  const { act } = useBackend<SpeechModuleTreeProps>();

  return (
    <Stack.Item width="100%" mr="0.3em">
      <Button
        onClick={() => act(add_action)}
        tooltip="Add Module"
        fontSize={1.1}
        style={{ float: 'right' }}
      >
        + Add
      </Button>
    </Stack.Item>
  );
};

const RemoveModuleButton = (props) => {
  const { remove_action, id, tooltip } = props;
  const { act } = useBackend<SpeechModuleTreeProps>();

  return (
    <Button
      onClick={() => act(remove_action, { module_id: id })}
      tooltip={tooltip}
      icon="minus"
    />
  );
};

const GoToAuxillaryButton = (props) => {
  const { aux_ref } = props;
  const { act } = useBackend<SpeechModuleTreeProps>();

  return (
    <Button
      onClick={() => act('view_module_tree', { ref: aux_ref })}
      tooltip="Go To Auxiliary Tree"
      icon="arrow-up-right-from-square"
    />
  );
};

const ViewVariablesButton = (props) => {
  const { atom_ref } = props;
  const { act } = useBackend<SpeechModuleTreeProps>();

  return (
    <Button
      onClick={() => act('view_variables', { ref: atom_ref })}
      tooltip="View Variables"
      icon="gear"
    />
  );
};
