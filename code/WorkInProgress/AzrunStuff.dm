/datum/digital_filter
	var/list/a_coefficients //feedback
	var/list/b_coefficients //feedforward
	var/z_a[1]
	var/z_b[1]

	proc/init(list/a_coeff, list/b_coeff)
		a_coefficients = a_coeff
		b_coefficients = b_coeff
		z_a.len = length(a_coeff)
		z_b.len = length(b_coeff)

	proc/process(input)
		var/feedback_sum
		var/input_sum
		z_b[1] = input

		// Sum previous outputs
		for(var/i in 1 to length(src.a_coefficients))
			feedback_sum -= src.a_coefficients[i]*z_a[i]
			if(i>1) src.z_a[i] = src.z_a[i-1]

		// Sum inputs
		for(var/i in 1 to length(src.b_coefficients))
			input_sum += src.b_coefficients[i]*z_b[i]
			if(i>1) src.z_b[i] = src.z_b[i-1]
		. = feedback_sum + input_sum
		if(length(src.z_a)) src.z_a[1] = .

	window_average
		init(window_size)
			var/list/coeff_list = new()
			for(var/i in 1 to window_size)
				coeff_list += 1/window_size
			..(null, coeff_list)

	// Rename to Exponential Smoothing?
	exponential_moving_average
		init(current_weight)
			var/input_weight[1]
			var/prev_output_weight[1]
			input_weight[1] = current_weight
			prev_output_weight[1] = -(1-current_weight)
			..(prev_output_weight,input_weight)



