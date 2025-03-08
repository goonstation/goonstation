/proc/pick_crime(mob/owner, is_major = FALSE, targeted_override = FALSE, rand_targeted = TRUE)
	var/targeted = FALSE
	if (targeted_override)
		targeted = TRUE
	else
		targeted = (prob(33) && rand_targeted) ? TRUE : FALSE
	var/crime_buffer = pick(strings("crimes.txt", "[is_major ? "major" : "minor"][targeted ? "_targeted" : ""]"))
	. = crime_buffer
	if (!targeted)
		return

	var/list/mob/living/carbon/human/humans = list()
	var/list/mob/living/silicon/robot/robots = list()
	for (var/mob/mob in global.mobs)
		if (mob == owner)
			continue
		if (!mob.client)
			continue
		if (ishuman(mob))
			humans += mob
			continue
		if (isrobot(mob))
			robots += mob
			continue
	var/list/mob/living/targets = (humans + robots)

	var/crime_buffer_tokenised = splittext(crime_buffer, " ")
	crime_buffer = list()
	for (var/token in crime_buffer_tokenised)
		var/victim = null
		if (findtext(token, "$HUMAN"))
			victim = length(humans) ? pick(humans) : "[pick_string_autokey("names/first.txt")] [pick_string_autokey("names/last.txt")]"
			token = replacetext(token, "$HUMAN", victim)
		if (findtext(token, "$ROBOT"))
			victim = length(robots) ? pick(robots) : pick_string_autokey("names/ai.txt")
			token = replacetext(token, "$ROBOT", victim)
		if (findtext(token, "$MOB"))
			victim = length(targets) ? pick(targets) : (prob(50) ? [pick_string_autokey("names/first.txt")] [pick_string_autokey("names/last.txt")] : pick_string_autokey("names/ai.txt"))
			token = replacetext(token, "$MOB", victim)
		crime_buffer += token
	crime_buffer = jointext(crime_buffer, " ")
	. = crime_buffer
