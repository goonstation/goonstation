export const pluralize = (word: string, n: number) => (n !== 1 ? word + 's' : word);

export const capitalize = (word: string) => word.replace(/(^\w{1})|(\s+\w{1})/g, letter => letter.toUpperCase());
