const pad = (number) => `0${number}`.slice(-2);

export default function getDateStr(dataObj) {
  return (
    dataObj.getUTCFullYear() +
    '-' +
    pad(dataObj.getUTCMonth() + 1) +
    '-' +
    pad(dataObj.getUTCDate()) +
    'T' +
    pad(dataObj.getUTCHours()) +
    '-' +
    pad(dataObj.getUTCMinutes()) +
    '-' +
    pad(dataObj.getUTCSeconds()) +
    '.' +
    (dataObj.getUTCMilliseconds() / 1000).toFixed(3).slice(2, 5) +
    'Z'
  );
}
