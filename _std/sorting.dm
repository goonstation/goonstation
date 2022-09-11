
/* Note about this file:
 * A portion of this code was written by Carnie over at /tg/, back in 2014.
 * We are using the code under the terms of our license, as Carnie can't be
 * contacted, and with this code being algorithims, any original work would
 * be almost identical. The tg project maintainers have also given their OK.
 */

/**
 * sortList - To sort lists via TimSort (in place)
 *
 * If you want to not affect the original list, see [/proc/sortListCopy]
 *
 * Arguments:
 * * L - Given list to sort in place (Pass a copy if you want a copy)
 * * cmp - procpath to compare elements in the list
 * * associative - whether we are sorting list keys (0: L[i]) or associated values (1: L[L[i]])
 * * from/toIndex - indexes of the list you want to sort from and to
 */
/proc/sortList(list/L, cmp=/proc/cmp_numeric_asc, associative, fromIndex=1, toIndex=0)
	RETURN_TYPE(/list)
	if(L && (length(L) >= 2))
		fromIndex = fromIndex % length(L)
		toIndex = toIndex % (length(L) + 1)
		if(fromIndex <= 0)
			fromIndex += length(L)
		if(toIndex <= 0)
			toIndex += length(L) + 1

		var/datum/sort_instance/SI = global.sortInstance
		if(!SI)
			SI = new

		SI.L = L
		SI.cmp = cmp
		SI.associative = associative

		SI.timSort(fromIndex, toIndex)
	return L

/// Just like [/proc/sortList], but return a sorted copy of the given list
/proc/sortListCopy(list/L, cmp=/proc/cmp_numeric_asc, associative, fromIndex=1, toIndex=0)
	RETURN_TYPE(/list)
	return sortList(L.Copy(), cmp, associative, fromIndex, toIndex)

//These are macros used to reduce on proc calls
#define fetchElement(L, i) (associative) ? L[L[i]] : L[i]

/// Minimum sized sequence that will be merged. Anything smaller than this will use binary-insertion sort.
/// Should be a power of 2
#define MIN_MERGE 32

/// When we get into galloping mode, we stay there until both runs win less often than MIN_GALLOP consecutive times.
#define MIN_GALLOP 7

/// This is a global instance to allow much of this code to be reused. The interfaces are kept separately
var/global/datum/sort_instance/sortInstance = new()

/datum/sort_instance
	/// The array being sorted.
	var/list/L

	/// The comparator proc-reference
	var/cmp = /proc/cmp_numeric_asc

	/// whether we are sorting list keys (0: L[i]) or associated values (1: L[L[i]])
	var/associative = 0

	/// This controls when we get *into* galloping mode.  It is initialized to MIN_GALLOP.
	/// The mergeLo and mergeHi methods nudge it higher for random data, and lower for highly structured data.
	var/minGallop = MIN_GALLOP

	// Stores information regarding runs yet to be merged.
	// Run i starts at runBase[i] and extends for runLen[i] elements.
	// runBase[i] + runLen[i] == runBase[i+1]
	var/list/runBases = list()
	var/list/runLens = list()


/datum/sort_instance/proc/timSort(start, end)
	runBases.Cut()
	runLens.Cut()

	var/remaining = end - start

	// If array is small, do a 'mini-TimSort' with no merges
	if(remaining < MIN_MERGE)
		var/initRunLen = countRunAndMakeAscending(start, end)
		binarySort(start, end, start+initRunLen)
		return

	// March over the array finding natural runs
	// Extend any short natural runs to runs of length minRun
	var/minRun = minRunLength(remaining)

	do
		// identify next run
		var/runLen = countRunAndMakeAscending(start, end)

		// if run is short, extend to min(minRun, remaining)
		if(runLen < minRun)
			var/force = (remaining <= minRun) ? remaining : minRun

			binarySort(start, start+force, start+runLen)
			runLen = force

		// add data about run to queue
		runBases.Add(start)
		runLens.Add(runLen)

		// maybe merge
		mergeCollapse()

		// Advance to find next run
		start += runLen
		remaining -= runLen

	while(remaining > 0)

	// Merge all remaining runs to complete sort
	mergeForceCollapse();

	// reset minGallop, for successive calls
	minGallop = MIN_GALLOP

	return L

/**
 * Sorts the specified portion of the specified array using a binary insertion sort.
 * This is the best method for sorting small numbers of elements.
 *
 * It requires O(n log n) compares, but O(n^2) data movement (worst case).
 *
 * If the initial part of the specified range is already sorted,
 * this method can take advantage of it: the method assumes that the
 * elements in range [lo,start) are already sorted
 *
 * lo the index of the first element in the range to be sorted
 *
 * hi the index after the last element in the range to be sorted
 *
 * start the index of the first element in the range that is not already known to be sorted
 */
/datum/sort_instance/proc/binarySort(lo, hi, start)
	if(start <= lo)
		start = lo + 1

	for( , start < hi, ++start)
		var/pivot = fetchElement(L,start)

		//set left and right to the index where pivot belongs
		var/left = lo
		var/right = start

		//[lo, left) elements <= pivot < [right, start) elements
		//in other words, find where the pivot element should go using bisection search
		while(left < right)
			var/mid = (left + right) >> 1
			if(call(cmp)(fetchElement(L,mid), pivot) > 0)
				right = mid
			else
				left = mid+1

		move_element(L, start, left) //move pivot element to correct location in the sorted range

/**
 * Returns the length of the run beginning at the specified position and reverses the run if it is back-to-front
 *
 * A run is the longest ascending sequence with:
 *  a[lo] <= a[lo + 1] <= a[lo + 2] <= ...
 *
 * or the longest descending sequence with:
 *  a[lo] >  a[lo + 1] >  a[lo + 2] >  ...
 *
 * For its intended use in a stable mergesort, the strictness of the
 * definition of "descending" is needed so that the call can safely
 * reverse a descending sequence without violating stability.
 */
/datum/sort_instance/proc/countRunAndMakeAscending(lo, hi)
	var/runHi = lo + 1
	if(runHi >= hi)
		return 1

	var/last = fetchElement(L,lo)
	var/current = fetchElement(L,runHi++)

	if(call(cmp)(current, last) < 0)
		while(runHi < hi)
			last = current
			current = fetchElement(L,runHi)
			if(call(cmp)(current, last) >= 0)
				break
			++runHi
		reverse_list_range(L, lo, runHi)
	else
		while(runHi < hi)
			last = current
			current = fetchElement(L,runHi)
			if(call(cmp)(current, last) < 0)
				break
			++runHi

	return runHi - lo

/// Returns the minimum acceptable run length for an array of the specified length.
/// Natural runs shorter than this will be extended with binarySort
/datum/sort_instance/proc/minRunLength(n)
	var/r = 0 //becomes 1 if any bits are shifted off
	while(n >= MIN_MERGE)
		r |= (n & 1)
		n >>= 1
	return n + r


/**
 * Examines the stack of runs waiting to be merged and merges adjacent runs until the stack invariants are reestablished:
 *
 * runLen[i-3] > runLen[i-2] + runLen[i-1]
 *
 * runLen[i-2] > runLen[i-1]
 *
 * This method is called each time a new run is pushed onto the stack.
 * So, the invariants are guaranteed to hold for i<stackSize upon entry to the method
 */
/datum/sort_instance/proc/mergeCollapse()
	while(length(runBases) >= 2)
		var/n = length(runBases) - 1
		if(n > 1 && runLens[n-1] <= runLens[n] + runLens[n+1])
			if(runLens[n-1] < runLens[n+1])
				--n
			mergeAt(n)
		else if(runLens[n] <= runLens[n+1])
			mergeAt(n)
		else
			break //Invariant is established


/// Merges all runs on the stack until only one remains.
/// Called only once, to finalise the sort
/datum/sort_instance/proc/mergeForceCollapse()
	while(length(runBases) >= 2)
		var/n = length(runBases) - 1
		if(n > 1 && runLens[n-1] < runLens[n+1])
			--n
		mergeAt(n)

/// Merges the two consecutive runs at stack indices i and i+1.
/// Run i must be the penultimate or antepenultimate run on the stack.
/// In other words, i must be equal to stackSize-2 or stackSize-3.
/datum/sort_instance/proc/mergeAt(i)
	var/base1 = runBases[i]
	var/base2 = runBases[i+1]
	var/len1 = runLens[i]
	var/len2 = runLens[i+1]

	// Record the legth of the combined runs. If i is the 3rd last run now, also slide over the last run
	// (which isn't involved in this merge). The current run (i+1) goes away in any case.
	runLens[i] += runLens[i+1]
	runLens.Cut(i+1, i+2)
	runBases.Cut(i+1, i+2)

	// Find where the first element of run2 goes in run1.
	// Prior elements in run1 can be ignored (because they're already in place)
	var/k = gallopRight(fetchElement(L,base2), base1, len1, 0)
	base1 += k
	len1 -= k
	if(len1 == 0)
		return

	// Find where the last element of run1 goes in run2.
	// Subsequent elements in run2 can be ignored (because they're already in place)
	len2 = gallopLeft(fetchElement(L,base1 + len1 - 1), base2, len2, len2-1)
	if(len2 == 0)
		return

	// Merge remaining runs, using tmp array with min(len1, len2) elements
	if(len1 <= len2)
		mergeLo(base1, len1, base2, len2)
	else
		mergeHi(base1, len1, base2, len2)

/**
 * Locates the position to insert key within the specified sorted range.
 * If the range contains elements equal to key, this will return the index of the LEFTMOST of those elements.
 *
 * key the element to be inserted into the sorted range
 *
 * base the index of the first element of the sorted range
 *
 * len the length of the sorted range, must be greater than 0
 *
 * hint the offset from base at which to begin the search, such that 0 <= hint < len; i.e. base <= hint < base+hint
 *
 * Returns the index at which to insert element 'key'
 */
/datum/sort_instance/proc/gallopLeft(key, base, len, hint)
	var/lastOffset = 0
	var/offset = 1
	if(call(cmp)(key, fetchElement(L,base+hint)) > 0)
		var/maxOffset = len - hint
		while(offset < maxOffset && call(cmp)(key, fetchElement(L,base+hint+offset)) > 0)
			lastOffset = offset
			offset = (offset << 1) + 1

		if(offset > maxOffset)
			offset = maxOffset

		lastOffset += hint
		offset += hint

	else
		var/maxOffset = hint + 1
		while(offset < maxOffset && call(cmp)(key, fetchElement(L,base+hint-offset)) <= 0)
			lastOffset = offset
			offset = (offset << 1) + 1

		if(offset > maxOffset)
			offset = maxOffset

		var/temp = lastOffset
		lastOffset = hint - offset
		offset = hint - temp

	// Now L[base+lastOffset] < key <= L[base+offset], so key belongs somewhere to the right of lastOffset but no farther than
	// offset. Do a binary search with invariant L[base+lastOffset-1] < key <= L[base+offset]
	++lastOffset
	while(lastOffset < offset)
		var/m = lastOffset + ((offset - lastOffset) >> 1)

		if(call(cmp)(key, fetchElement(L,base+m)) > 0)
			lastOffset = m + 1
		else
			offset = m

	return offset

/**
 * Like gallopLeft, except that if the range contains an element equal to
 * key, gallopRight returns the index after the rightmost equal element.
 *
 * @param key the key whose insertion point to search for
 *
 * @param a the array in which to search
 *
 * @param base the index of the first element in the range
 *
 * @param len the length of the range; must be > 0
 *
 * @param hint the index at which to begin the search, 0 <= hint < n.
 *  The closer hint is to the result, the faster this method will run.
 *
 * @param c the comparator used to order the range, and to search
 *
 * @return the int k,  0 <= k <= n such that `a[b + k - 1] <= key < a[b + k]`
 */
/datum/sort_instance/proc/gallopRight(key, base, len, hint)
	var/offset = 1
	var/lastOffset = 0
	if(call(cmp)(key, fetchElement(L,base+hint)) < 0) //key <= L[base+hint]
		var/maxOffset = hint + 1 //therefore we want to insert somewhere in the range [base,base+hint] = [base+,base+(hint+1))
		while(offset < maxOffset && call(cmp)(key, fetchElement(L,base+hint-offset)) < 0) //we are iterating backwards
			lastOffset = offset
			offset = (offset << 1) + 1 //1 3 7 15

		if(offset > maxOffset)
			offset = maxOffset

		var/temp = lastOffset
		lastOffset = hint - offset
		offset = hint - temp

	else //key > L[base+hint]
		var/maxOffset = len - hint //therefore we want to insert somewhere in the range (base+hint,base+len) = [base+hint+1, base+hint+(len-hint))
		while(offset < maxOffset && call(cmp)(key, fetchElement(L,base+hint+offset)) >= 0)
			lastOffset = offset
			offset = (offset << 1) + 1

		if(offset > maxOffset)
			offset = maxOffset

		lastOffset += hint
		offset += hint

	++lastOffset
	while(lastOffset < offset)
		var/m = lastOffset + ((offset - lastOffset) >> 1)

		if(call(cmp)(key, fetchElement(L,base+m)) < 0) //key <= L[base+m]
			offset = m
		else //key > L[base+m]
			lastOffset = m + 1

	return offset


/// Merges two adjacent runs in-place in a stable fashion.
/// For performance this method should only be called when len1 <= len2!
/datum/sort_instance/proc/mergeLo(base1, len1, base2, len2)
	var/cursor1 = base1
	var/cursor2 = base2

	// degenerate cases
	if(len2 == 1)
		move_element(L, cursor2, cursor1)
		return

	if(len1 == 1)
		move_element(L, cursor1, cursor2+len2)
		return

	// Move first element of second run
	move_element(L, cursor2++, cursor1++)
	--len2

	outer:
		while(1)
			var/count1 = 0 //# of times in a row that first run won
			var/count2 = 0 // " " " " " "  second run won

			//do the straightfoward thin until one run starts winning consistently
			do
				if(call(cmp)(fetchElement(L,cursor2), fetchElement(L,cursor1)) < 0)
					move_element(L, cursor2++, cursor1++)
					--len2

					++count2
					count1 = 0

					if(len2 == 0)
						break outer
				else
					++cursor1

					++count1
					count2 = 0

					if(--len1 == 1)
						break outer

			while((count1 | count2) < minGallop)

			//one run is winning consistently so galloping may provide huge benifits
			//so try galloping, until such time as the run is no longer consistently winning
			do
				count1 = gallopRight(fetchElement(L,cursor2), cursor1, len1, 0)
				if(count1)
					cursor1 += count1
					len1 -= count1

					if(len1 <= 1)
						break outer

				move_element(L, cursor2, cursor1)
				++cursor2
				++cursor1
				if(--len2 == 0)
					break outer

				count2 = gallopLeft(fetchElement(L,cursor1), cursor2, len2, 0)
				if(count2)
					move_range(L, cursor2, cursor1, count2)

					cursor2 += count2
					cursor1 += count2
					len2 -= count2

					if(len2 == 0)
						break outer

				++cursor1
				if(--len1 == 1)
					break outer

				--minGallop

			while((count1|count2) > MIN_GALLOP)

			if(minGallop < 0)
				minGallop = 0
			minGallop += 2;  // Penalize for leaving gallop mode


	if(len1 == 1)
		move_element(L, cursor1, cursor2+len2)

/datum/sort_instance/proc/mergeHi(base1, len1, base2, len2)
	var/cursor1 = base1 + len1 - 1 //start at end of sublists
	var/cursor2 = base2 + len2 - 1

	// degenerate cases
	if(len2 == 1)
		move_element(L, base2, base1)
		return

	if(len1 == 1)
		move_element(L, base1, cursor2+1)
		return

	move_element(L, cursor1--, cursor2-- + 1)
	--len1

	outer:
		while(1)
			var/count1 = 0 //# of times in a row that first run won
			var/count2 = 0 // " " " " " "  second run won

			// do the straightfoward thing until one run starts winning consistently
			do
				if(call(cmp)(fetchElement(L,cursor2), fetchElement(L,cursor1)) < 0)
					move_element(L, cursor1--, cursor2-- + 1)
					--len1

					++count1
					count2 = 0

					if(len1 == 0)
						break outer
				else
					--cursor2
					--len2

					++count2
					count1 = 0

					if(len2 == 1)
						break outer
			while((count1 | count2) < minGallop)

			// one run is winning consistently so galloping may provide huge benifits
			// so try galloping, until such time as the run is no longer consistently winning
			do
				count1 = len1 - gallopRight(fetchElement(L,cursor2), base1, len1, len1-1) //should cursor1 be base1?
				if(count1)
					cursor1 -= count1

					move_range(L, cursor1+1, cursor2+1, count1) //cursor1+1 == cursor2 by definition

					cursor2 -= count1
					len1 -= count1

					if(len1 == 0)
						break outer

				--cursor2

				if(--len2 == 1)
					break outer

				count2 = len2 - gallopLeft(fetchElement(L,cursor1), cursor1+1, len2, len2-1)
				if(count2)
					cursor2 -= count2
					len2 -= count2

					if(len2 <= 1)
						break outer

				move_element(L, cursor1--, cursor2-- + 1)
				--len1

				if(len1 == 0)
					break outer

				--minGallop
			while((count1|count2) > MIN_GALLOP)

			if(minGallop < 0)
				minGallop = 0
			minGallop += 2 // Penalize for leaving gallop mode

	if(len2 == 1)
		cursor1 -= len1
		move_range(L, cursor1+1, cursor2+1, len1)

#undef MIN_GALLOP
#undef MIN_MERGE

#undef fetchElement

//
//
// Code from this point onwards is no longer from TG
//
//
