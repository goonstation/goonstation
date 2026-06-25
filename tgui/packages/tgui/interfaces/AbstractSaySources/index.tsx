/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import {
  Button,
  Collapsible,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { VariableList } from '../../components/goonstation/VariableList';
import { Window } from '../../layouts';
import { AbstractSaySourceProps, AbstractSaySourcesProps } from './type';

export const AbstractSaySources = () => {
  const { act, data } = useBackend<AbstractSaySourcesProps>();

  return (
    <Window title="Abstract Say Sources" width={660} height={740}>
      <Window.Content scrollable>
        <Section>
          <Table>
            <Table.Cell textAlign="justify">{data.info}</Table.Cell>
            <Table.Cell pl={1} collapsing>
              <Button
                onClick={() => act('add_say_source')}
                tooltip="Create Abstract Say Source"
                icon="plus"
              />
            </Table.Cell>
          </Table>
        </Section>
        {data.say_sources.reverse().map((say_source, index) => (
          <AbstractSaySource key={index} {...say_source} />
        ))}
      </Window.Content>
    </Window>
  );
};

const AbstractSaySource = (props: AbstractSaySourceProps) => {
  const { act } = useBackend<AbstractSaySourcesProps>();
  return (
    <Collapsible
      title={props.internal_name}
      fontSize={1.2}
      open
      bold
      buttons={
        <Stack>
          {!!props.admin_created && <RenameButton atom_ref={props.atom_ref} />}
          <ForceSayButton atom_ref={props.atom_ref} />
          <ViewVariablesButton atom_ref={props.atom_ref} />
          {!!props.admin_created && <RemoveButton atom_ref={props.atom_ref} />}
        </Stack>
      }
    >
      <Section mt={-1}>
        <Stack wrap vertical>
          <Stack.Item>
            <VariableList
              className="candystripe"
              act={act}
              variables={props.atom_variables}
            />
          </Stack.Item>
          <Stack.Divider my={1} />
          <Stack.Item>
            <VariableList
              className="two_columns candystripe"
              act={act}
              variables={props.verb_variables}
            />
          </Stack.Item>
        </Stack>
      </Section>
    </Collapsible>
  );
};

const RenameButton = (props) => {
  const { atom_ref } = props;
  const { act } = useBackend<AbstractSaySourcesProps>();

  return (
    <Button
      fontSize={1.2}
      bold
      onClick={() => act('rename_say_source', { ref: atom_ref })}
      tooltip="Edit the internal name of this say source."
      icon="pen"
    />
  );
};

const ForceSayButton = (props) => {
  const { atom_ref } = props;
  const { act } = useBackend<AbstractSaySourcesProps>();

  return (
    <Button
      fontSize={1.2}
      bold
      onClick={() => act('force_say', { ref: atom_ref })}
      tooltip="Force this say source to say something."
    >
      Say
    </Button>
  );
};

const ViewVariablesButton = (props) => {
  const { atom_ref } = props;
  const { act } = useBackend<AbstractSaySourcesProps>();

  return (
    <Button
      fontSize={1.2}
      onClick={() => act('view_variables', { ref: atom_ref })}
      tooltip="View Variables"
      icon="gear"
    />
  );
};

const RemoveButton = (props) => {
  const { atom_ref } = props;
  const { act } = useBackend<AbstractSaySourcesProps>();

  return (
    <Button
      color="red"
      fontSize={1.2}
      bold
      onClick={() => act('remove_say_source', { ref: atom_ref })}
      tooltip="Delete this say source."
      icon="minus"
    />
  );
};
