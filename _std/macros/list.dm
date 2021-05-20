#define shuffle_list(x) do { var/listlen = length(x); for(var/i in 1 to listlen) x.Swap(i, rand(i, listlen)) } while (0)

#define LAZYLISTINIT(L) \
	if (!L) \
		L = list() \

#define LAZYLISTADD(L, X) \
	if(!L) { L = list(); } \
	L += X; \

#define LAZYLISTREMOVE(L, I) \
	if(L) { \
		L -= I; \
		if(!length(L)) { \
			L = null; \
		} \
	} \

#define REMOVE_FROM_UNSORTED(L, INDEX) \
	{ \
		L[INDEX] = L[length(L)]; \
		L.len-- \
	}

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

/proc/reverse_list(var/list/the_list)
	RETURN_TYPE(/list)
	. = list()
	for(var/i = length(the_list), i > 0, i--)
		. += the_list[i]

proc/keep_truthy(some_list)
	. = list()
	for(var/x in some_list)
		if(x)
			. += x

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

/proc/next_in_list(var/thing, var/list)
	if (thing == list[length(list)])
		return list[1]
	for (var/v in 1 to length(list))
		if (v > 1 && list[v-1] == thing)
			return list[v]
	return list[1]
