/// XORSHIFT Pseudorandom number generator
/datum/xor_rand_generator
	var/seed
	var/mangled_rand

	New(seed)
		..()
		if(seed)
			src.seed = seed
		else
			src.seed = rand(3, 50000)
			//Munge away!
			for(var/i in 5)
				xor_rand()

	/// Random float from (L,H)
	proc/xor_randf(L, H)
		if(!src.mangled_rand)
			mangled_rand = seed
		mangled_rand ^= mangled_rand << 13
		mangled_rand ^= mangled_rand >> 7
		mangled_rand ^= mangled_rand << 17

		. = mangled_rand / 0xFFFFFF
		if(!isnull(L) && !isnull(H))
			. = L + ( (H-L) * (.) )

	/// Random Integer from (L,H) otherwise 0-1
	proc/xor_rand(L, H)
		if(L && isnull(H))
			H = L
			L = 0
		if(!isnull(L) && !isnull(H))
			. = round(xor_randf(L, H+0.99))
		else
			. = xor_randf()

	proc/xor_prob(P)
		. = xor_rand() < (P/100)

	proc/xor_pick(list/L)
		var/index = round( xor_rand() * length(L) ) + 1
		. = L[index]

	proc/xor_weighted_pick(list/L)
		var/total = 0
		var/item
		for(item in L)
			if(isnull(L[item]))
				stack_trace("weighted_pick given null weight: [json_encode(L)]")
			total += L[item]
		total = xor_rand() * total
		for(item in L)
			total -= L[item]
			if(total <= 0)
				. = item
