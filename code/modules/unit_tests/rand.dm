/datum/unit_test/xor_rand
	var/datum/xor_rand_generator/R

/datum/unit_test/xor_rand/Run()
	R = new(0xBEEF)

	for(var/i in 1 to 5)
		distribution_check(/datum/xor_rand_generator/proc/xor_rand, list(0,100),1000)
		distribution_check(/datum/xor_rand_generator/proc/xor_rand, list(1,99),1000)
		distribution_check(/datum/xor_rand_generator/proc/xor_randf, list(1, 99),1000)
		distribution_check(/datum/xor_rand_generator/proc/xor_randf, list(0, 100),1000)
		distribution_check(/datum/xor_rand_generator/proc/xor_rand, list(),1000)
		distribution_check(/datum/xor_rand_generator/proc/xor_rand, list(),1000)

	for(var/i in 1 to 4)
		deterministic_check(/datum/xor_rand_generator/proc/xor_rand, list(0,100), 100, 3, 0xBEEF)
		deterministic_check(/datum/xor_rand_generator/proc/xor_randf, list(0,100), 100, 3, 0xB00)
		deterministic_check(/datum/xor_rand_generator/proc/xor_rand, list(0,100), 100, 3, 0xDEAD)

/datum/unit_test/xor_rand/proc/distribution_check(delegate, args, iterations)
	var/result
	var/sum
	var/list/distro = list()
	var/list/sub_distro = list()
	var/range = args
	if(!length(args))
		range = list(0,1)
	var/expected_mean = ((range[2]-range[1])/2)
	var/sum_sqrs

	for(var/i in 1 to iterations)
		if(delegate)
			result = call(R, delegate)(arglist(args))
		else
			if(length(args))
				result = rand(args[1],args[2])
			else
				result = rand()

		var/bucket_val = result
		if(!length(args))
			bucket_val *= 100
		sum += result
		sum_sqrs += (result-expected_mean)**2
		LAZYLISTINIT(distro["[round(bucket_val/10)]"])
		distro["[round(bucket_val/10)]"]["[result]"]++
		LAZYLISTINIT(sub_distro["[round(bucket_val%10)]"])
		sub_distro["[round(bucket_val%10)]"]["[result]"]++

	var/avg = sum / iterations
	var/std_dev = sqrt(sum_sqrs / iterations)
	var/cv = std_dev / avg

	var/SCALED_TOLERANCE = 0.1
	var/maxima = expected_mean * (1+SCALED_TOLERANCE)
	var/minima = expected_mean * (1-SCALED_TOLERANCE)
	TEST_ASSERT(avg >= minima, "Test average is within tolerance. [delegate] [avg] >= [minima]")
	TEST_ASSERT(avg <= maxima, "Test average is within tolerance. [delegate] [avg] <= [maxima]")

	// BYOND.rand() Coefficient of variation seemed to range from 0.56-0.606
	TEST_ASSERT(cv >= 0.51, "Test Coefficient of variation is within tolerance. [delegate] [cv] >= 0.51")
	TEST_ASSERT(cv <= 0.65, "Test Coefficient of variation is within tolerance. [delegate] [cv] <= 0.65")

/datum/unit_test/xor_rand/proc/deterministic_check(delegate, args, iterations, attempts, seed)
	var/list/first_iteration = list()
	var/list/this_result

	for(var/i in 1 to attempts)
		R.mangled_rand = null
		R.seed = seed
		for(var/j in 1 to iterations)
			if(i == 1)
				first_iteration += call(R, delegate)(arglist(args))
			else
				this_result = call(R, delegate)(arglist(args))
				TEST_ASSERT(first_iteration[j] == this_result, "Test calculations is the same. Index:[j] [first_iteration[j]] == [this_result]")


/datum/unit_test/rand_distributions
	var/list/buckets
	var/iterations = 10000
	var/sum

/datum/unit_test/rand_distributions/Run()
	rand_seed(0xFEED)
	for(var/repeat in 1 to 3)
		//Standard
		src.clear_buckets()
		for(var/i in 1 to iterations)
			add_point( rand(1, 99) )
		distribution_check("rand() #[repeat]", list(0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10), 0.03)

		//Pyrmaid
		src.clear_buckets()
		for(var/i in 1 to iterations)
			add_point( rand_pyramid(1, 99) )
		distribution_check("rand_pyramid() #[repeat]", list(0.02,0.06,0.10,0.14,0.18,0.18,0.14,0.10,0.06,0.02), 0.03)

		//Bell
		src.clear_buckets()
		for(var/i in 1 to iterations)
			add_point( rand_bell(1, 99) )
		distribution_check("rand_bell() #[repeat]", list(0.003,0.03,0.08,0.16,0.22,0.22,0.16,0.08,0.03,0.003), 0.03)

		//Half Pyramid
		src.clear_buckets()
		for(var/i in 1 to iterations)
			add_point( rand_half_pyramid(1, 99) )
		distribution_check("rand_half_pyramid() #[repeat]", list(0.02,0.06,0.10,0.15,0.15,0.15,0.15,0.10,0.06,0.02), 0.03)

/datum/unit_test/rand_distributions/proc/add_point(value)
		src.buckets[round(value/10)+1] += value
		src.sum += value

/datum/unit_test/rand_distributions/proc/clear_buckets()
	src.buckets = new/list(10)
	src.sum = 0
	for(var/i in 1 to 10)
		buckets[i] = list()

/datum/unit_test/rand_distributions/proc/distribution_check(type, list/expected, tolerance)
	var/average = src.sum / src.iterations
	var/distro

	var/maxima = 51
	var/minima = 49
	TEST_ASSERT(average >= minima, "Test average is within tolerance. [type] [average] >= [minima]")
	TEST_ASSERT(average <= maxima, "Test average is within tolerance. [type] [average] <= [maxima]")

	for(var/i in 1 to 10)
		minima = max(0,expected[i]-tolerance)
		maxima = max(0,expected[i]+tolerance)

		distro = length(src.buckets[i])/src.iterations

		TEST_ASSERT(distro >= minima, "Test distribution is within tolerance. [type]:([i]) [distro] >= [minima] (Expected:[expected[i]])")
		TEST_ASSERT(distro <= maxima, "Test distribution is within tolerance. [type]:([i]) [distro] <= [maxima] (Expected:[expected[i]])")
