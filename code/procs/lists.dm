/proc/AuxSort(var/list/toSort, var/sortMethod, var/lower, var/upper)
	while( lower < upper )
		var/left = toSort[lower]
		var/right = toSort[upper]

		if(call(sortMethod)(right, left))
			toSort[upper] = left
			toSort[lower] = right
		if( (upper-lower) == 1) break//2 elements; fall out
		var/i = round((lower+upper)/2)//get the center

		var/nth = toSort[i]
		left = toSort[lower]
		if(call(sortMethod)(nth, left))
			toSort[i] = left
			toSort[lower] = nth
		else
			right = toSort[upper]
			if(call(sortMethod)(right, nth))
				toSort[i] = right
				toSort[upper] = nth
		if( (upper-lower) == 2) break//3 elements; fall out
		///////////pivot//////////
		right = toSort[upper-1]
		var/pivot = toSort[i]
		toSort[i] = right
		toSort[upper-1] = pivot

		i = lower
		var/j = upper - 1
		while(1)
			while(call(sortMethod)(toSort[++i], pivot))
				if(i >= upper) CRASH("nondeterministic table sort")

			while(call(sortMethod)(pivot, toSort[--j]))
				if(j <= lower) CRASH("nondeterministic table sort")
			if(j < i) break
			left = toSort[i]
			right = toSort[j]
			toSort[i] = right
			toSort[j] = left

		//swap pivot
		left = toSort[upper-1]
		right = toSort[i]
		toSort[upper-1] = right
		toSort[i] = left

		if( (i-lower) < (upper-i) )
			j = lower
			i = i - 1
			lower = i + 2
		else
			j = i + 1
			i = upper
			upper = j - 2
		AuxSort(toSort, sortMethod, j, i)
//duplicated code to avoid proc overhead
/proc/AuxSortLT(var/list/toSort, var/lower, var/upper)
	while( lower < upper )
		var/left = toSort[lower]
		var/right = toSort[upper]

		if(right < left)
			toSort[upper] = left
			toSort[lower] = right
		if( (upper-lower) == 1) break//2 elements; fall out
		var/i = round((lower+upper)/2)//get the center

		var/nth = toSort[i]
		left = toSort[lower]
		if(nth < left)
			toSort[i] = left
			toSort[lower] = nth
		else
			right = toSort[upper]
			if(right < nth)
				toSort[i] = right
				toSort[upper] = nth
		if( (upper-lower) == 2) break//3 elements; fall out
		///////////pivot//////////
		right = toSort[upper-1]
		var/pivot = toSort[i]
		toSort[i] = right
		toSort[upper-1] = pivot

		i = lower
		var/j = upper - 1
		while(1)
			while(toSort[++i] < pivot)
				if(i >= upper) CRASH("nondeterministic table sort")

			while(pivot < toSort[--j])
				if(j <= lower) CRASH("nondeterministic table sort")
			if(j < i) break
			left = toSort[i]
			right = toSort[j]
			toSort[i] = right
			toSort[j] = left

		//swap pivot
		left = toSort[upper-1]
		right = toSort[i]
		toSort[upper-1] = right
		toSort[i] = left

		if( (i-lower) < (upper-i) )
			j = lower
			i = i - 1
			lower = i + 2
		else
			j = i + 1
			i = upper
			upper = j - 2
		AuxSortLT(toSort, j, i)

/proc/SortList(var/list/toSort, var/sortMethod)
	sortMethod ? AuxSort(toSort, sortMethod, 1, toSort.len) : AuxSortLT(toSort, 1, toSort.len)

proc/compareName(atom/a, atom/b)
	return a.name < b.name
