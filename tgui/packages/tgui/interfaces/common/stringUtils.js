export const pluralize = (word, n) => (n !== 1 ? word + 's' : word);

export const capitalize = (word) => word.replace(/(^\w{1})|(\s+\w{1})/g, letter => letter.toUpperCase());
