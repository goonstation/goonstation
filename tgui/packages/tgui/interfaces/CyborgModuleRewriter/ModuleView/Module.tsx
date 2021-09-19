/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { SFC } from 'inferno';
import { Button, Section } from '../../../components';
import { Tools } from './Tools';
import { ToolData } from '../type';

const resetOptions = [
  {
    id: 'brobocop',
    name: 'Brobocop',
  }, {
    id: 'chemistry',
    name: 'Chemistry',
  }, {
    id: 'civilian',
    name: 'Civilian',
  }, {
    id: 'engineering',
    name: 'Engineering',
  }, {
    id: 'medical',
    name: 'Medical',
  }, {
    id: 'mining',
    name: 'Mining',
  },
];

interface ModuleProps {
  onMoveToolDown: (toolRef: string) => void,
  onMoveToolUp: (toolRef: string) => void,
  onRemoveTool: (toolRef: string) => void,
  onResetModule: (moduleId: string) => void,
  tools: Array<ToolData>,
}

export const Module: SFC<ModuleProps> = props => {
  const {
    onMoveToolDown,
    onMoveToolUp,
    onRemoveTool,
    onResetModule,
    tools,
  } = props;

  return (
    <>
      <Section title="Preset">
        {
          resetOptions.map(resetOption => {
            const {
              id,
              name,
            } = resetOption;
            return (
              <Button
                key={id}
                onClick={() => onResetModule(id)}
                title={name}
              >
                {name}
              </Button>
            );
          })
        }
      </Section>
      <Section title="Tools">
        <Tools
          onMoveToolDown={onMoveToolDown}
          onMoveToolUp={onMoveToolUp}
          onRemoveTool={onRemoveTool}
          tools={tools}
        />
      </Section>
    </>
  );
};
