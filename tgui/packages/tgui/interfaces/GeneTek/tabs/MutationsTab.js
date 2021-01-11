/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { useBackend } from "../../../backend";
import { BioEffect } from "../BioEffect";

export const MutationsTab = (props, context) => {
  const { data } = useBackend(context);
  const {
    bioEffects,
  } = data;

  bioEffects.sort((a, b) => a.time - b.time);

  return bioEffects.map(be => (
    <BioEffect
      key={be.ref}
      gene={be} />
  ));
};
