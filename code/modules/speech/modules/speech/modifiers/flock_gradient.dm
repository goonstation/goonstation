/datum/speech_module/modifier/flock_gradient
	id = SPEECH_MODIFIER_FLOCK_GRADIENT

/datum/speech_module/modifier/flock_gradient/process(datum/say_message/message)
	. = message

	message.flags &= ~SAYFLAG_HAS_QUOTATION_MARKS
	message.content = "[MAKE_CONTENT_MUTABLE("\"")][message.content][MAKE_CONTENT_MUTABLE("\"")]"
	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(immutable_gradientText), "#3cb5a3", "#124e43"))


/// A copy of `gradientText` that ensures that the HTML content is immutable.
/proc/immutable_gradientText(message, color_1, color_2)
	var/list/color_list_1 = rgb2num(color_1)
	var/list/color_list_2 = rgb2num(color_2)

	var/r1 = color_list_1[1]
	var/g1 = color_list_1[2]
	var/b1 = color_list_1[3]

	// The difference in value between each color part
	var/delta_r = color_list_2[1] - r1
	var/delta_g = color_list_2[2] - g1
	var/delta_b = color_list_2[3] - b1

	var/list/result = list()

	// Start at a random point between the two, in increments of 0.1
	var/coeff = rand(0,10) / 10.0
	var/dir = prob(50) ? -1 : 1

	for(var/i in 1 to length(message) step 3)
		coeff += dir * 0.2
		// 20% chance to start going in the opposite direction
		if(prob(20))
			dir = -dir

		// Wrap back around
		if(coeff < 0)
			coeff = 0
			dir = 1

		else if(coeff > 1)
			coeff = 1
			dir = -1

		var/col = rgb(r1 + delta_r*coeff, g1 + delta_g*coeff, b1 + delta_b*coeff)
		result += MAKE_CONTENT_IMMUTABLE("<span style='color:[col]'>")
		result += copytext(message, i, i + 3)
		result += MAKE_CONTENT_IMMUTABLE("</span>")

	. = jointext(result, "")
