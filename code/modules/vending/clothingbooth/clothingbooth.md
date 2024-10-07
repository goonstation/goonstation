
# Clothing Booth

## Organisational hierarchy



## Adding items to the booth

On the back-end, a given entry on the stock list is an instance of `/datum/clothingbooth_grouping` containing types of `/datum/clothingbooth_item`.

For every entry that you want to have appear on the list to purchase from, there must be a `clothingbooth_grouping`, even if that `clothingbooth_grouping` only contains a single `clothingbooth_item`.
