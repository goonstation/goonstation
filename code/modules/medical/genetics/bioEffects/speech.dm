/datum/bioEffect/speech
	name = "Frontal Gyrus Alteration Type-N"
	desc = "Hinders nerve transmission to and from the speech center of the brain, resulting in faltering speech."
	id = "stutter"
	probability = 40
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "Y-you f.. feel a.. a bit n-n-nervous."
	msgLose = "You don't feel nervous anymore."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3
	icon_state = "speech"

	proc/OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = stutter(message)
		return message

/datum/bioEffect/speech/smile
	name = "Frontal Gyrus Alteration Type-S"
	desc = "Causes the speech center of the subject's brain to produce large amounts of seratonin when engaged."
	id = "accent_smiling"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "You feel like you want to smile and smile and smile forever :)"
	msgLose = "You don't feel like smiling anymore. :("
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3
	icon_state = "speech_smile"

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = smilify(message)
		return message

/datum/bioEffect/speech/elvis
	name = "Frontal Gyrus Alteration Type-E"
	desc = "Forces the language center of the subject's brain to drawl out sentences in a funky manner."
	id = "accent_elvis"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "You feel funky."
	msgLose = "You feel a little less conversation would be great."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = elvisfy(message)
		return message

/datum/bioEffect/speech/chav
	name = "Frontal Gyrus Alteration Type-C"
	desc = "Forces the language center of the subject's brain to construct sentences in a more rudimentary manner."
	id = "accent_chav"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "Ye feel like a reet prat like, innit?"
	msgLose = "You no longer feel like being rude and sassy."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = chavify(message)
		return message

/datum/bioEffect/speech/scots
	name = "Frontal Gyrus Alteration Type-F"
	desc = "Forces the language center of the subject's brain to construct sentences in the manner of a highlander."
	id = "accent_scots"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "Och aye! You feel like a true Scot!"
	msgLose = "You weren't a true Scot after all."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3
	var/danny_index = 0

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = scotify(message)
		return message

/datum/bioEffect/speech/swedish
	name = "Frontal Gyrus Alteration Type-B"
	desc = "Forces the language center of the subject's brain to construct sentences in a vaguely norse manner."
	id = "accent_swedish"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "You feel Swedish, however that works."
	msgLose = "The feeling of Swedishness passes."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = borkborkbork(message)
		return message

/datum/bioEffect/speech/finnish
	name = "Frontal Gyrus Alteration Type-FI"
	desc = "Forces the language center of the subject's brain to construct sentences in a manner not conclusively proven to exist by scientists."
	id = "accent_finnish"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "Sauna and birch beatings! Hyvä!"
	msgLose = "The lure of the sauna subsides..."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = finnishify(message)
		return message

/datum/bioEffect/speech/tommy // DO NOT MAKE THIS APPEAR IN GENEPOOLS OR INTO A TRAIT OR ANY OF THAT, PLEASE, THANK YOU IN ADVANCE - with love, haine
	name = "Frontal Gyrus Alteration Type-T"
	desc = "Forces the langua.... what!? What the fuck is this? What happened here!? Gods have mercy on our souls."
	id = "accent_tommy"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "You feel torn apart!"
	msgLose = "You pull yourself together."
	reclaim_fail = 10
	probability = 0 // NO
	occur_in_genepools = 0 // NO ALSO
	can_make_injector = 0
	can_copy = 0

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = tommify(message)
		return message

/*
/datum/bioEffect/speech/wonk // DO NOT MAKE THIS APPEAR IN GENEPOOLS OR INTO A TRAIT OR ANY OF THAT, PLEASE, THANK YOU IN ADVANCE - with love, haine
	name = "Frontal Gyrus Alteration Type-W"
	desc = "unfunny"
	id = "accent_wonk"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "Fuckable owwwwwwwls!"
	msgLose = "More like honk."
	reclaim_fail = 10
	probability = 0 // NO
	occur_in_genepools = 0 // NO ALSO
	can_make_injector = 0
	can_copy = 0

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = wonkify(message)
		return message
*/ //Actually, let's not have this appear fucking anywhere at all! ~warc


/datum/bioEffect/speech/comic
	name = "Frontal Gyrus Alteration Type-CS"
	desc = "Causes the speech center of the subject's brain to become, uh. Well, SOMETHING happens to it."
	id = "accent_comic"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "<font face='Comic Sans MS'>You feel great!!</font>"
	msgLose = "You feel okay."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("T","A")
	lockedTries = 3
	icon_state = "speech_clown"

	OnAdd()
		var/mob/living/L = owner
		if (istype(L))
			L.speechpopupstyle = "font-family: 'Comic Sans MS'; font-size: 8px;"

	OnRemove()
		var/mob/living/L = owner
		if (istype(L))
			L.speechpopupstyle = ""

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		return message
		// just let this one handle itself for now

/datum/bioEffect/speech/badmin
	name = "Frontal Gyrus Alteration Type-Badmin"
	desc = "Spooky. Red."
	id = "accent_badmin"
	effectType = EFFECT_TYPE_POWER
	isBad = 0
	msgGain = "You now speak with black and red text."
	msgLose = "Back to normal text."
	probability = 0 // NO
	occur_in_genepools = 0 // NO ALSO
	can_make_injector = 0
	can_copy = 0

	OnAdd()
		var/mob/living/L = owner
		if (istype(L))
			L.speechpopupstyle = "font-family: 'XFont 6x9'; font-size: 6px; color: red !important; text-shadow: 1px 1px 0 black; -dm-text-outline: 1px black;"

	OnRemove()
		var/mob/living/L = owner
		if (istype(L))
			L.speechpopupstyle = ""

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		return message
		// just let this one handle itself for now

	goodmin
		name = "Frontal Gyrus Alteration Type-Goodmin"
		desc = "Wow!"
		id = "accent_goodmin"
		msgGain = "You now speak with white, glowing text."
		msgLose = "Back to normal text."

		OnAdd()
			var/mob/living/L = owner
			if (istype(L))
				L.speechpopupstyle = "color: white !important; text-shadow: 0px 0px 3px white; -dm-text-outline: 1px black;"

	rainbow
		name = "Frontal Gyrus Alteration Type-Radmin"
		desc = "Colors!"
		id = "accent_radmin"
		msgGain = "You now speak with color-cycling text."
		msgLose = "Back to normal text."

		OnAdd()
			var/mob/living/L = owner
			if (istype(L))
				L.speechpopupstyle = "color: white !important; text-shadow: 0px 0px 3px white; -dm-text-outline: 1px black;"
				animate_rainbow_glow(L.chat_text)

		OnRemove()
			var/mob/living/L = owner
			if (istype(L))
				L.speechpopupstyle = ""
				L.chat_text.color = null
				animate(L.chat_text)

		rainglow
			name = "Frontal Gyrus Alteration Type-Fabmin"
			desc = "Glowy colors!"
			id = "accent_fabmin"
			msgGain = "You now speak with glowing, color-cycling text."
			msgLose = "Back to normal text."

			OnAdd()
				var/mob/living/L = owner
				if (istype(L))
					L.speechpopupstyle = "color: black !important; text-shadow: 0px 0px 3px white; -dm-text-outline: 1px white;"
					animate_rainbow_glow(L.chat_text)

/datum/bioEffect/speech/slurring
	name = "Frontal Gyrus Alteration Type-D"
	desc = "Causes the subject to have impaired control over their oral muscles, resulting in malformed speech."
	id = "slurring"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "You feel like your tongue's made out of lead."
	msgLose = "You feel less tongue-tied."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("T","A")
	lockedTries = 3
	icon_state = "speech_bad"

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = say_drunk(message)
		return message

/datum/bioEffect/speech/unintelligable
	name = "Frontal Gyrus Alteration Type-X"
	desc = "Heavily corrupts the part of the brain responsible for forming spoken sentences."
	id = "unintelligable"
	isBad = 1
	effectType = EFFECT_TYPE_DISABILITY
	blockCount = 4
	blockGaps = 4
	msgGain = "You can't seem to form any coherent thoughts!"
	msgLose = "Your mind feels more clear."
	reclaim_fail = 10
	stability_loss = -10
	lockProb = 75
	lockedGaps = 4
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3
	icon_state = "speech_bad"

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = say_superdrunk(message)
		return message

/datum/bioEffect/speech/vowelitis
	name = "Frontal Gyrus Alteration Type-O"
	desc = "Causes the language center of the brain to have difficulty processing vowels."
	id = "vowelitis"
	effectType = EFFECT_TYPE_POWER
	msgGain = "You feel a bit tongue-tied."
	msgLose = "You no longer feel tongue-tied."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3
	icon_state = "speech_bad"
	var/vowel_lower = "a"
	var/vowel_upper = "A"

	New()
		..()
		var/picker = rand(1,5)
		switch(picker)
			if(1)
				vowel_lower = "a"
				vowel_upper = "A"
			if(2)
				vowel_lower = "e"
				vowel_upper = "E"
			if(3)
				vowel_lower = "i"
				vowel_upper = "I"
			if(4)
				vowel_lower = "o"
				vowel_upper = "O"
			if(5)
				vowel_lower = "u"
				vowel_upper = "U"
			else
				vowel_lower = ""
				vowel_upper = ""

	OnSpeak(var/message)
		if (!istext(message))
			return ""

		message = replacetext(message, "a", vowel_lower)
		message = replacetext(message, "e", vowel_lower)
		message = replacetext(message, "i", vowel_lower)
		message = replacetext(message, "o", vowel_lower)
		message = replacetext(message, "u", vowel_lower)
		message = replacetext(message, "A", vowel_upper)
		message = replacetext(message, "E", vowel_upper)
		message = replacetext(message, "I", vowel_upper)
		message = replacetext(message, "O", vowel_upper)
		message = replacetext(message, "U", vowel_upper)

		return message

/datum/bioEffect/speech/loud_voice
	name = "High-Pressure Larynx"
	desc = "Vastly increases airflow speed and capacity through the subject's larynx."
	id = "loud_voice"
	effectType = EFFECT_TYPE_POWER
	msgGain = "YOU SUDDENLY FEEL LIKE SHOUTING A WHOLE LOT!!!"
	msgLose = "You no longer feel the need to raise your voice."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3
	icon_state = "speech_loud"

	OnSpeak(var/message)
		if (!istext(message))
			return ""

		message = replacetext(message, "!", "!!!")
		message = replacetext(message, ".", "!!!")
		message = replacetext(message, "?", "???")
		message = uppertext(message)
		message += "!!!"

		return message

/datum/bioEffect/speech/reversed_speech
	name = "Frontal Gyrus Alteration Type-R"
	desc = "Causes the language center of the brain to process speech in reverse."
	id = "reversed_speech"
	effectType = EFFECT_TYPE_POWER
	msgGain = ".sdrawkcab tib a leef uoY"
	msgLose = "You feel the right way around."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3

	OnSpeak(var/message)
		if (!istext(message))
			return ""

		message = reverse_text(message)

		return message

/datum/bioEffect/speech/quiet_voice
	name = "Constricted Larynx"
	desc = "Decreases airflow speed and capacity through the subject's larynx."
	id = "quiet_voice"
	effectType = EFFECT_TYPE_POWER
	msgGain = "...you feel like being quiet..."
	msgLose = "You no longer feel the need to keep your voice down."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3
	icon_state = "speech_mime"

	OnSpeak(var/message)
		if (!istext(message))
			return ""

		message = replacetext(message, "!", "...")
		message = replacetext(message, "?", "..?")
		message = lowertext(message)
		message += "..."

		return message

/datum/bioEffect/monkey_speak
	name = "Monkey Speak"
	desc = "Causes the subject to understand monkeys."
	id = "monkey_speak"
	probability = 0
	msgGain = "You feel one with the jungle!"
	msgLose = "You feel less primal."

/datum/bioEffect/speech/zalgo
	name = "Eldritch Speech"
	desc = "The subject's larynx is channeling a chaotic dimension of elder beings."
	id = "accent_zalgo"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "HE COMES"
	msgLose = "You feel sane again."
	probability = 0
	occur_in_genepools = 0 // Probably shouldn't look like this? http://f.666kb.com/i/d2iqlzm1qa2gk6dqs.png
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0

	New()
		src.msgGain = zalgoify(src.msgGain, rand(0,8), rand(0, 2), rand(0, 8))
		..()

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = zalgoify(message, rand(0,2), rand(0, 1), rand(0, 2))
		return message


/datum/bioEffect/speech/void
	name = "Void"
	desc = "The subject's speech appears to come from multiple, shunted locations."
	id = "accent_void"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "Ah, friend! It's so good to be able to speak again!"
	msgLose = "Your voice is only yours again."
	probability = 0
	occur_in_genepools = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0

	New()
		src.msgGain = voidSpeak(src.msgGain)
		..()

	OnAdd()
		var/mob/living/L = owner
		L.speech_void = 1

	OnRemove()
		var/mob/living/L = owner
		L.speech_void = 0



/datum/bioEffect/speech/yee // DO NOT MAKE THIS APPEAR IN GENEPOOLS OR INTO A TRAIT OR ANY OF THAT, PLEASE, THANK YOU IN ADVANCE - with love, haine
	name = "yee"
	desc = "yee"
	id = "accent_yee"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "yee"
	msgLose = "nee"
	probability = 0 // noo
	occur_in_genepools = 0 // not for human consumption
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = yee_text(message)
		return message

/proc/yee_text(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for(var/i = 0, i < length(string), i=i)
		var/datum/parse_result/P = yee_parse(T)
		modded += P.string
		i += P.chars_used
		T.curr_char_pos = T.curr_char_pos + P.chars_used
		T.update()

	return modded

/proc/yee_parse(var/datum/text_roamer/R)
	var/new_string = ""
	var/used = 0

	switch(R.curr_char)
		if ("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Z") // all but Y
			if (R.prev_char == " " || R.curr_char_pos == 1) // start of a word or start of the string
				new_string = "Y"
				used = 1
			else
				new_string = "E"
				used = 1
		if ("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z") // all but e
			if (R.prev_char == " " || R.curr_char_pos == 1) // start of a word or start of the string
				new_string = "y"
				used = 1
			else
				new_string = "e"
				used = 1

	if (new_string == "")
		new_string = R.curr_char
		used = 1

	var/datum/parse_result/P = new/datum/parse_result
	P.string = new_string
	P.chars_used = used
	return P

/datum/bioEffect/speech/butt
	name = "Frontal Gyrus Alteration Type-BT"
	desc = "Causes the language center of the brain to be connected to the subject's butt."
	id = "accent_butt"
	msgGain = "Your breath smells like a fart."
	msgLose = "Your breath no longer smells like a fart."
	reclaim_fail = 10
	stability_loss = -10
	lockProb = 75
	lockedGaps = 4
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3
	icon_state = "speech_bad"
	OnSpeak(var/message)
		if (!istext(message))
			return ""

		var/list/speech_list = splittext(message, " ")
		if(!speech_list || !length(speech_list))
			return ""

		var/num_butts = rand(1,4)
		var/counter = 0
		while(num_butts)
			counter++
			num_butts--
			speech_list[rand(1,speech_list.len)] = "butt"
			if(counter >= (speech_list.len / 2) )
				num_butts = 0

		return jointext(speech_list, " ")


/datum/bioEffect/speech/uwuwhatsthis //God is Dead
	// okay this one is less creepy/weird than the owo one because it
	// doesn't have the awkward prefix/suffixes. It's more like an actual accent.
	// And also horrible.
	name = "Frontal Gyrus Alteration Type-U"
	desc = "Reconstructs the language center of the subject's brain to create less threatening speech patterns."
	id = "accent_uwu"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 0 // heh
	msgGain = "Oh nyo. uwu"
	msgLose = "Nyo more funny talking."
	occur_in_genepools = 0
	acceptable_in_mutini = 0
	probability = 0 // Should not be player accessible
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = uwutalk(message)
		return message

/datum/bioEffect/speech/literalowotalk
	name = "Frontal Gyrus Alteration Type-OWO"
	desc = "Reconstructs the language center of the subject's brain, shutting most of it down and allowing for a very limited functionality."
	id = "accent_literalowo"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "Owo wowo wowow owow!"
	msgLose = "You feel like your vocabulary has expanded!"
	probability = 0
	occur_in_genepools = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	acceptable_in_mutini = 0

	OnSpeak(var/message)
		if (!istext(message))
			return ""

		var/list/speech_list = splittext(message, " ")
		if(!speech_list || !length(speech_list))
			return ""

		var/o = 1

		for (var/i = 1 to length(speech_list))
			o = 1
			var/text = speech_list[i]
			var/newtext = ""
			for (var/j = 1 to length(text))
				if (o)
					newtext += "o"
				else
					newtext += "w"
				o = !o
			speech_list[i] = newtext

		return jointext(speech_list, " ")

/datum/bioEffect/speech/french
	name = "Frontal Gyrus Alteration Type-Q"
	desc = "Forces the language center of the subject's brain to construct rude and vaguely-canadian sentences."
	id = "accent_french"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "You feel like your province is a nation, however that works."
	msgLose = "The feeling of Independence passes."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = tabarnak(message)
		return message

/datum/bioEffect/speech/tyke
	name = "Frontal Gyrus Alteration Type-Y"
	desc = "Forces the language center of the subject's brain to construct sentences in the manner of a northerner."
	id = "accent_tyke"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "You feel like you're on Ilkley Moor without a hat."
	msgLose = "You never want to hear a brass band again."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = yorkify(message)
		return message

/datum/bioEffect/speech/scoob
	name = "Frontal Gyrus Alteration Type-SD"
	desc = "Forces the language center of the subject's brain to bark out sentences like a dog."
	id = "accent_scoob"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "You feel like you've got some work to do now."
	msgLose = "You feel like you've found yourself."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = scoobify(message)
		return message

/datum/bioEffect/speech/scoob/less_dog
	name = "Frontal Gyrus Alteration Type-BD" // bad dog 3=
	desc = "Influences select language centers of the subject's brain to bark out sentences like a dog."
	id = "accent_scoob_nerf"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "You feel like you're talking through a dog's snout."
	msgLose = "You feel less vocally canine."
	probability = 0
	occur_in_genepools = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	acceptable_in_mutini = 0

	OnSpeak(var/message)
		if (!istext(message))
			return ""
		message = scoobify(message, 1)
		return message

/datum/bioEffect/speech/thrall
	name = "Frontal Gyrus Alteration Type-V"
	desc = "Forces the language center of the subject's brain to emit gurgling, raspy speech."
	id = "accent_thrall"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "Your throat gurgles with blood."
	msgLose = "You feel your throat clear."
	probability = 0
	occur_in_genepools = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	acceptable_in_mutini = 1

	OnSpeak(message)
		if (!istext(message))
			return ""
		return thrall_parse(message)
