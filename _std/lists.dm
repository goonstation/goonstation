
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
/proc/reverse_list_range(list/inserted_list, start = 1, end = 0)
	RETURN_TYPE(/list)
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
	RETURN_TYPE(/list)
	if(!islist(key_list))
		return null
	. = list()
	for(var/key in key_list)
		. |= key_list[key]

///Make a normal list an associative one
/proc/make_associative(list/flat_list)
	RETURN_TYPE(/list)
	. = list()
	for(var/thing in flat_list)
		.[thing] = TRUE

//
//
// Code from this point onwards is no longer from TG
//
//

/**
 * Picks a random element from a list based on a weighting system.
 *
 * For example, given the following list:
 * A = 6, B = 3, C = 1, D = 0,
 * A would have a 60% chance of being picked,
 * B would have a 30% chance of being picked,
 * C would have a 10% chance of being picked,
 * and D would have a 0% chance of being picked.
 *
 * You should only pass integers in.
 */
proc/weighted_pick(list/L)
	var/total = 0
	var/item
	for(item in L)
		if(isnull(L[item]))
			stack_trace("weighted_pick given null weight: [json_encode(L)]")
		total += L[item]
	total = rand() * total
	for(item in L)
		total -= L[item]
		if(total <= 0)
			return item
	return null

proc/keep_truthy(some_list)
	RETURN_TYPE(/list)
	. = list()
	for(var/x in some_list)
		if(x)
			. += x

/proc/sortNames(var/list/L)
	RETURN_TYPE(/list)
	var/list/Q = new()
	for(var/atom/x in L)
		Q[x.name] = x
	. = sortList(Q, /proc/cmp_text_asc)

/proc/assoc_list_to_list(var/list/l)
	RETURN_TYPE(/list)
	var/list/keys = list()
	var/list/vals = list()
	for(var/key in l)
		keys += key
		vals += l[key]
	return list(keys,vals)

/proc/list_to_assoc_list(list/first, list/second)
	RETURN_TYPE(/list)
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

/proc/next_in_list(var/thing, var/list)
	if (thing == list[length(list)])
		return list[1]
	for (var/v in 1 to length(list))
		if (v > 1 && list[v-1] == thing)
			return list[v]
	return list[1]

proc/list_pop(list/L)
	. = L[length(L)]
	L.Cut(length(L))

//Based on code from Popisfizzy: http://www.byond.com/forum/?post=134331#comment750984
proc/params2complexlist(params)
	RETURN_TYPE(/list)
	//This is a replacement for params2list that allows grouping with parentheses, to enable
	//storing a list in a list.
	//Example input: "name1=val1&name2=(name3=val3&name4=val4)&name5=val5"
	//Example output list:
	//name1 = val1
	//name2 = name3=val3&name4=val4
	//name5 = val5
	if(!istext(params)) return
	. = list()
	var/len = length(params)
	var/element = null
	var/a = 1,p_count = 1
	while(a < len)
		a++
		//Found a separator for a parameter-value pair. Store it
		if(findtext(params,"&",a,a+1))
			. += params2list(copytext(params,1,a))
			params = copytext(params,a+1)
			len = length(params)
			a = 1
		//Found a parameter with a complex value.
		else if(findtext(params,"(",a,a+1))
			//Store the element name
			element = copytext(params,1,a-1)
			params = copytext(params,a+1)
			len = length(params)
			a = 0

			//Check for the matching parenthesis
			p_count = 1
			while(p_count)
				a++
				if(findtext(params,"(",a,a+1)) p_count++
				if(findtext(params,")",a,a+1)) p_count--
				if(a >= len && p_count)
					//Didn't find matching parenthesis and at end of string
					//Invalid params list
					return

			//Found a matching parenthesis. Store it and the value in the list
			.[element] = copytext(params,1,a)

			//Check if we need to parse more
			if(a >= len)
				return
			else
				params = copytext(params,a+2)
				len = length(params)
				a = 1

	//Parse the remaining param string for the last list element
	. += params2list(copytext(params,1))

/proc/list_keys(var/list/L)
	RETURN_TYPE(/list)
	. = list()
	for (var/K in L)
		. += K

/proc/uniquelist(var/list/L)
	RETURN_TYPE(/list)
	. = list()
	for(var/item in L)
		. |= item

#define shuffle_list(x) \
	do { \
	var/listlen = length(x); \
	for(var/i in 1 to listlen - 1) \
		x.Swap(i, rand(i, listlen)) \
	} while (0)
