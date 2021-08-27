/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { Fragment } from "inferno";
import { useBackend, useSharedState } from "../../../backend";
import { Button, Section } from "../../../components";
import { BioEffect } from "../BioEffect";

export const MutationsTab = (props, context) => {
  const { data } = useBackend(context);
  const [sortMode, setSortMode] = useSharedState(context, "mutsortmode", "time");
  const [showSequence, toggleShowSequence] = useSharedState(context, 'showSequence', false);
  const bioEffects = (data.bioEffects || []).slice(0);

  if (sortMode === "time") {
    bioEffects.sort((a, b) => a.time - b.time);
  } else if (sortMode === "alpha") {
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
    <Fragment>
      <Section>
        <Button
          icon={sortMode === "time" ? "clock" : "sort-alpha-down"}
          onClick={() => setSortMode(sortMode === "time" ? "alpha" : "time")}>
          Sort Mode
        </Button>
        <Button.Checkbox
          inline
          content="Show Sequence"
          checked={showSequence}
          onClick={() => toggleShowSequence(!showSequence)}
        />
      </Section>
      {bioEffects.map(be => (
        <BioEffect
          key={be.ref}
          gene={be}
          showSequence={showSequence} />
      ))}
    </Fragment>
  );
};
