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
