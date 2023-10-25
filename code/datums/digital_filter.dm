/// Provide support for IIR filters to perform all your standard filtering needs!
/// Previous inputs and outputs of the function will be summed together and output
///
/// https://en.wikipedia.org/wiki/Infinite_impulse_response
/datum/digital_filter
	/// feedback (scalars for sumation of previous results)
	var/list/a_coefficients
	/// feedforward (scalars for sumation of previous inputs)
	var/list/b_coefficients
	var/z_a[1]
	var/z_b[1]

	proc/init(list/feedback, list/feedforward)
		a_coefficients = feedback
		b_coefficients = feedforward
		z_a.len = length(a_coefficients)
		z_b.len = length(b_coefficients)

	proc/process(input)
		var/feedback_sum
		var/input_sum
		z_b[1] = input

		// Sum previous outputs
		for(var/i in 1 to length(src.a_coefficients))
			feedback_sum -= src.a_coefficients[i]*src.z_a[i]
			if(i>1) src.z_a[i] = src.z_a[i-1]

		// Sum inputs
		for(var/i in 1 to length(src.b_coefficients))
			input_sum += src.b_coefficients[i]*src.z_b[i]
			if(i>1) src.z_b[i] = src.z_b[i-1]
		. = feedback_sum + input_sum
		if(length(src.z_a)) src.z_a[1] = .

	/// Sum equally weighted previous inputs of window_size
	window_average
		init(window_size)
			var/list/coeff_list = new()
			for(var/i in 1 to window_size)
				coeff_list += 1/window_size
			..(null, coeff_list)

	/// Sum weighted current input and weighted previous output to achieve output
	/// input weight will be ratio of weight assigned to input value while remaining goes to previous output
	///
	/// Exponential Smoothing
	/// Time constant will be the amount of time to achieve 63.2% of original sum
	/// NOTE: This should be performed by a scheduled process as this ensures constant sample interval
	/// https://en.wikipedia.org/wiki/Exponential_smoothing
	exponential_moving_average
		proc/init_basic(input_weight)
			var/input_weight_list[1]
			var/prev_output_weight_list[1]
			input_weight_list[1] = input_weight
			prev_output_weight_list[1] = -(1-input_weight)
			init(prev_output_weight_list,input_weight_list)

		proc/init_exponential_smoothing(sample_interval, time_const)
			init_basic(1.0 - ( eulers ** ( -sample_interval / time_const )))

	pid
		init(proportional_gain, integral_gain, derivative_gain, time_delta=1)
			var/coeff_list = list()
			coeff_list += proportional_gain + integral_gain*time_delta + derivative_gain/time_delta
			coeff_list += -proportional_gain - 2*derivative_gain/time_delta
			coeff_list += derivative_gain/time_delta
			..(null, coeff_list)


/// Provide support for basic PID Controller
/// Allows for dampening an approach to a target value
///
/// https://en.wikipedia.org/wiki/PID_controller

/datum/pid
	var/proportional_gain //Kp
	var/integral_gain // Ki
	var/derivative_gain //Kd

	var/target_value = 0
	var/integral = 0

	var/last_error = 0


	New(proportional_gain, integral_gain, derivative_gain)
		. = ..()
		src.proportional_gain = proportional_gain
		src.integral_gain = integral_gain
		src.derivative_gain = derivative_gain

	proc/calculate(input, setpoint)
		if(setpoint)
			src.target_value = setpoint

		var/error = src.target_value - input

		integral += error
		var/derivative = error - last_error
		last_error = error

		//                P                                  I                           D
		. = (src.proportional_gain * error) + (src.integral_gain * integral) + (src.derivative_gain * derivative)
