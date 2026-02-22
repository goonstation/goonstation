
# Clothing Booth

The clothing booth is a machine that allows users to purchase clothing items by interacting with a sophisticated front-end interface. The interface supports various forms of tagging, filtering, and sorting with the goal of enabling the ease of exploration of the full catalogue and searching for the exact type of item desired quickly with minimal friction.

## Adding items to the booth

Create a new `/datum/clothingbooth_item` in an appropriate file in the `./items` directory and populate it with the information desired. `swatch_background_color`, `swatch_foreground_color`, and `swatch_foreground_shape` don't need to be filled if this `clothingbooth_item` isn't slated to be grouped with other similar items. Otherwise, please at least override `swatch_background_color` and `swatch_foreground_color` as their default values are obvious placeholders.

Next, if this item isn't part of an existing grouping, create a new `/datum/clothingbooth_grouping` in an appropriate file in the `./groupings` directory. For every entry that you want to have appear on the list to purchase from, there must be a `clothingbooth_grouping`, even if that `clothingbooth_grouping` only contains a single `clothingbooth_item`.

> :information: `clothingbooth_grouping`s are designed to only contain items that would fit in the same inventory slot. If you would like to create a set of items that work together in the same outfit, consider making a new `clothingbooth_grouping_tag` instead.

> :caution: The `slot`, `clothingbooth_items`, and `clothingbooth_grouping_tags` variables in `/datum/clothingbooth_grouping` are protected. Do not override these yourself to prevent runtime errors!

To help users find the `clothingbooth_grouping` in the greater catalogue, each `clothingbooth_grouping` is given a number of `/datum/clothingbooth_grouping_tag`s to help identify what contexts this particular set of items would fit within. These are mostly subjective rulings, so please add what you think would work best for identifying the `clothingbooth_grouping` to others.

> :information: Feel free to add any new applicable `/datum/clothingbooth_grouping_tag`s that are appropriate to `./clothingbooth_grouping_tags.dm`.
