/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button, Section } from '../../../components';
import Tools from './Tools';

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

const Module = props => {
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
                title={name}>
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

export default Module;
