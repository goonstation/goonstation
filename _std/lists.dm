
/* Note about this file:
 * A portion of this code was written by Carnie over at /tg/, back in 2014.
 * We are using the code under the terms of our license, as Carnie can't be
 * contacted, and with this code being algorithims, any original work would
 * be almost identical. The tg project maintainers have also given their OK.
 */

/**
 * Move a single element from position from_index within a list, to position to_index
 *
 * All elements in the range [1,to_index) before the move will be before the pivot afterwards
 *
 * All elements in the range [to_index, L.len+1) before the move will be after the pivot afterwards
 *
 * In other words, it's as if the range [from_index,to_index) have been rotated using a <<< operation common to other languages.
 *
 * from_index and to_index must be in the range [1,L.len+1]
 * Preserves associations
 */
/proc/move_element(list/inserted_list, from_index, to_index)
	if(from_index == to_index || from_index + 1 == to_index) //no need to move
		return
	if(from_index > to_index)
		++from_index //since a null will be inserted before from_index, the index needs to be nudged right by one

	inserted_list.Insert(to_index, null)
	inserted_list.Swap(from_index, to_index)
	inserted_list.Cut(from_index, from_index + 1)

/**
 * Move elements [from_index,from_index+len) to [to_index-len, to_index)
 *
 * Same as [/proc/move_element] but for ranges of elements
 *
 * Preserves associations
 */
/proc/move_range(list/inserted_list, from_index, to_index, len = 1)
	var/distance = abs(to_index - from_index)
	if(len >= distance) //there are more elements to be moved than the distance to be moved. Therefore the same result can be achieved (with fewer operations) by moving elements between where we are and where we are going. The result being, our range we are moving is shifted left or right by dist elements
		if(from_index <= to_index)
			return //no need to move
		from_index += len //we want to shift left instead of right

		for(var/i in 1 to distance)
			inserted_list.Insert(from_index, null)
			inserted_list.Swap(from_index, to_index)
			inserted_list.Cut(to_index, to_index + 1)
	else
		if(from_index > to_index)
			from_index += len

		for(var/i in 1 to len)
			inserted_list.Insert(to_index, null)
			inserted_list.Swap(from_index, to_index)
			inserted_list.Cut(from_index, from_index + 1)

/**
 * Move elements from [from_index, from_index+len) to [to_index, to_index+len)
 *
 * Move any elements being overwritten by the move to the now-empty elements, preserving order
 *
 * Note: if the two ranges overlap, only the destination order will be preserved fully, since some elements will be within both ranges
 */
/proc/swap_range(list/inserted_list, from_index, to_index, len=1)
	var/distance = abs(to_index - from_index)
	if(len > distance) //there is an overlap, therefore swapping each element will require more swaps than inserting new elements
		if(from_index < to_index)
			to_index += len
		else
			from_index += len

		for(var/i in 1 to distance)
			inserted_list.Insert(from_index, null)
			inserted_list.Swap(from_index, to_index)
			inserted_list.Cut(to_index, to_index + 1)
	else
		if(to_index > from_index)
			var/a = to_index
			to_index = from_index
			from_index = a

		for(var/i in 1 to len)
			inserted_list.Swap(from_index++, to_index++)

//// Reverses a given list within the given range
/proc/reverse_range(list/inserted_list, start = 1, end = 0)
	if(length(inserted_list))
		start = start % length(inserted_list)
		end = end % (length(inserted_list) + 1)
		if(start <= 0)
			start += length(inserted_list)
		if(end <= 0)
			end += length(inserted_list) + 1

		--end
		while(start < end)
			inserted_list.Swap(start++, end--)

	return inserted_list

///Flattens a keyed list into a list of it's contents
/proc/flatten_list(list/key_list)
	if(!islist(key_list))
		return null
	. = list()
	for(var/key in key_list)
		. |= key_list[key]

///Make a normal list an associative one
/proc/make_associative(list/flat_list)
	. = list()
	for(var/thing in flat_list)
		.[thing] = TRUE

//
//
// Code from this point onwards is no longer from TG
//
//

/proc/sortNames(var/list/L)
	var/list/Q = new()
	for(var/atom/x in L)
		Q[x.name] = x
	. = sortList(Q)

/proc/assoc_list_to_list(var/list/l)
	var/list/keys = list()
	var/list/vals = list()
	for(var/key in l)
		keys += key
		vals += l[key]
	return list(keys,vals)

/proc/list_to_assoc_list(list/first, list/second)
	. = list()
	for(var/i = 1,i <= length(first), i++)
		.[first[i]] = second[i]

/// Returns a list in plain english as a string
/proc/english_list(list/input, nothing_text = "nothing", and_text = " and ", comma_text = ", ", final_comma_text = "" )
	var/total = length(input)
	switch(total)
		if (0)
			return "[nothing_text]"
		if (1)
			return "[input[1]]"
		if (2)
			return "[input[1]][and_text][input[2]]"
		else
			var/output = ""
			var/index = 1
			while (index < total)
				if (index == total - 1)
					comma_text = final_comma_text

				output += "[input[index]][comma_text]"
				index++

			return "[output][and_text][input[index]]"
