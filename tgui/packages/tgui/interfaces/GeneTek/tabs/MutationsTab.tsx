/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { Button, Section } from 'tgui-core/components';

import { useBackend, useSharedState } from '../../../backend';
import { BioEffect } from '../BioEffect';
import type { GeneTekData } from '../type';

export const MutationsTab = () => {
  const { data } = useBackend<GeneTekData>();
  const [sortMode, setSortMode] = useSharedState('mutsortmode', 'time');
  const [showSequence, toggleShowSequence] = useSharedState(
    'showSequence',
    false,
  );
  const bioEffects = (data.bioEffects || []).slice(0);

  if (sortMode === 'time') {
    bioEffects.sort((a, b) => a.time - b.time);
  } else if (sortMode === 'alpha') {
    bioEffects.sort((a, b) => {
      if (a.name > b.name) {
        return 1;
      }

      if (a.name < b.name) {
        return -1;
      }

      return 0;
    });
  }

  return (
    <>
      <Section>
        <Button
          icon={sortMode === 'time' ? 'clock' : 'sort-alpha-down'}
          onClick={() => setSortMode(sortMode === 'time' ? 'alpha' : 'time')}
        >
          Sort Mode
        </Button>
        <Button.Checkbox
          inline
          checked={showSequence}
          onClick={() => toggleShowSequence(!showSequence)}
        >
          Show Sequence
        </Button.Checkbox>
      </Section>
      {bioEffects.map((be) => (
        <BioEffect key={be.ref} gene={be} showSequence={showSequence} />
      ))}
    </>
  );
};
