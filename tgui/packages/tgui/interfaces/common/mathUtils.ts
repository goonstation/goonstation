export const randInt = (a: number, b: number) => {
  const min = b > a ? a : b;
  const max = b > a ? b : a;
  return Math.floor(Math.random() * (max - min + 1)) + min;
};
