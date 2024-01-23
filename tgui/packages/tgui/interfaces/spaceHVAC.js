/**
 * @file
 * @copyright 2024
 * @author IPingu (https://github.com/IPling)
 * @license ISC
 */

// To do:
// Powercell input and removal, maybe add powercell names to the inserted cell, or an image of it
// Power level of the powercell, preferably a progress bar
// Temperature setting, from -90 to 90, while emagged 120-400, in increments of 10 and 5, with a insert box for variable as well
// Fix being able to open the space heater while its on

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const spaceHVAC = (props, context) => {
  const {data} = useBackend(context);
  const {
    on,
    heating,
    open,
    name,
  } = data;
  return (
    <window
      title={name}
      width={600}
      height={600}>
    </window>
  );
};

