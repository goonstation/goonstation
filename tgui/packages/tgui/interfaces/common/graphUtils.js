/**
 * Helper function to transform the data into something displayable
 * Lovingly made by Mordent and adapted
 * @param {*} rawData - [ { foo: v, bar: v2, ... }, { foo: v3, bar: v4, ... }, ... ]
 * @returns - { foo: [[i, v], [i+1, v2], ...], bar: [[i, v3], [i+1, v4], ...], ... }
 */
export const processStatsData = rawData => {
  if ((rawData ?? []).length === 0) {
    return null;
  }
  // intialize our data structure
  const keys = Object.keys(rawData[0]);

  const resolvedData = keys.reduce((acc, curr) => {
    acc[curr] = [];
    return acc;
  }, {});

  for (let statsDataIndex = 0; statsDataIndex < rawData.length; statsDataIndex++) {
    const tegValues = rawData[statsDataIndex];
    for (let keyIndex = 0; keyIndex < keys.length; keyIndex++) {
      const key = keys[keyIndex];
      // x, y coords for graph (y defaults to 0)
      resolvedData[key].push([statsDataIndex, tegValues[key] ?? 0]); // 0 but "None" later
    }
  }
  return resolvedData;
};

/**
 * Helper function to get the maximum value of our stats information for display
 * @param {*} stats - { [i, value], [i+1, value2], ...}
 * @returns float maximum value
 */
export const getStatsMax = stats => {
  let found_maximum = 0; // Chart always starts at 0
  for (const index in stats) {
    const stat = stats[index][1]; // get the value
    if (stat > found_maximum) {
      found_maximum = stat;
    }
  }
  return found_maximum;
};
