/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license MIT
 */

const numericCompare = (a: number, b: number): number => {

  if (a === b) {
    return 0;
  } else if (a > b) {
    return 1;
  } else {
    return -1;
  }

};

const stringCompare = (a: string, b: string): number => {
  return a.localeCompare(b);
};

const selectComparator = (type: string): ((a:unknown, b:unknown) => (number)) => {
  switch (type) {
    case "number":
      return numericCompare;

    case "string":
      return stringCompare;

    default:
      return undefined;
  }
};


type RecordKey = (string | number | symbol)
const RecordTypes = ['string', 'number', 'symbol'] as const;

export const sortTypedArrayByIndex = <V extends Array<unknown>, Lk extends RecordKey = never, Lv = never>(
  objs: V[],
  index: number,
  lut?: Record<Lk, Lv>,
  allowDefault: boolean = true): (V[]) => {
  if (!objs || objs.length === 0) {
    throw new Error("empty or null array passed to function");
  }

  if (objs[0].length <= index) {
    throw new Error("invalid index passed");
  }

  if (lut && !(typeof objs[0][index] in RecordTypes)) {
    throw new Error(`passed in indexed array and LUT with field that cannot index records: ${typeof objs[0][index]}`);
  }

  let type: string;

  if (!lut) {
    type = typeof objs[0][index];
  } else {
    const lookUpKey = objs[0][index] as RecordKey;
    type = typeof lut[lookUpKey];
  }

  const comparator = selectComparator(type);

  if (comparator) {

    objs.sort((a, b) => {
      if (!lut) {
        return comparator(a[index], b[index]);
      } else {
        const aLookup = a[index] as RecordKey;
        const bLookup = b[index] as RecordKey;
        return comparator(lut[aLookup], lut[bLookup]);
      }
    });
  } else if (allowDefault) {
    objs.sort();
  } else {
    throw new Error(`Undefined comparator for: ${type}`);
  }

  return objs;
};
