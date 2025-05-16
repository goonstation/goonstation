/datum/bioEffect/speech
	name = "Frontal Gyrus Alteration Type-N"
	desc = "Hinders nerve transmission to and from the speech center of the brain, resulting in faltering speech."
	id = "stutter"
	probability = 40
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "Y-you f.. feel a.. a bit n-n-nervous."
	msgLose = "You don't feel nervous anymore."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3
	icon_state = "speech"
	var/mixingdesk_allowed = TRUE

	OnAdd()
		src.owner.ensure_speech_tree().AddSpeechModifier(src.id)
		. = ..()

	OnRemove()
		src.owner.ensure_speech_tree().RemoveSpeechModifier(src.id)
		. = ..()


/datum/bioEffect/speech/smile
	name = "Frontal Gyrus Alteration Type-S"
	desc = "Causes the speech center of the subject's brain to produce large amounts of serotonin when engaged."
	id = "accent_smiling"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "You feel like you want to smile and smile and smile forever :)"
	msgLose = "You don't feel like smiling anymore. :("
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3
	icon_state = "speech_smile"


/datum/bioEffect/speech/elvis
	name = "Frontal Gyrus Alteration Type-E"
	desc = "Forces the language center of the subject's brain to drawl out sentences in a funky manner."
	id = "accent_elvis"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "You feel funky."
	msgLose = "You feel a little less conversation would be great."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3


/datum/bioEffect/speech/chav
	name = "Frontal Gyrus Alteration Type-C"
	desc = "Forces the language center of the subject's brain to construct sentences in a more rudimentary manner."
	id = "accent_chav"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "Ye feel like a reet prat like, innit?"
	msgLose = "You no longer feel like being rude and sassy."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3


/datum/bioEffect/speech/scots
	name = "Frontal Gyrus Alteration Type-F"
	desc = "Forces the language center of the subject's brain to construct sentences in the manner of a highlander."
	id = "accent_scots"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "Och aye! You feel like a true Scot!"
	msgLose = "You weren't a true Scot after all."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3
	var/danny_index = 0


/datum/bioEffect/speech/swedish
	name = "Frontal Gyrus Alteration Type-B"
	desc = "Forces the language center of the subject's brain to construct sentences in a vaguely norse manner."
	id = "accent_swedish"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "You feel Swedish, however that works."
	msgLose = "The feeling of Swedishness passes."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3


/datum/bioEffect/speech/finnish
	name = "Frontal Gyrus Alteration Type-FI"
	desc = "Forces the language center of the subject's brain to construct sentences in a manner not conclusively proven to exist by scientists."
	id = "accent_finnish"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "Sauna and birch beatings! Hyvä!"
	msgLose = "The lure of the sauna subsides..."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3


/datum/bioEffect/speech/german
	name = "Frontal Gyrus Alteration Type-DE"
	desc = "Forces the language center of the subject's brain to construct sentences in a German manner."
	id = "accent_german"
	effectType =  EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "You can no longer pronounce th for ze life of you!"
	msgLose = "You can now pronounce thoughtful, and thatch, and that!"
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3


/datum/bioEffect/speech/tommy // DO NOT MAKE THIS APPEAR IN GENEPOOLS OR INTO A TRAIT OR ANY OF THAT, PLEASE, THANK YOU IN ADVANCE - with love, haine
	name = "Frontal Gyrus Alteration Type-T"
	desc = "Forces the langua.... what!? What the fuck is this? What happened here!? Gods have mercy on our souls."
	id = "accent_tommy"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "You feel torn apart!"
	msgLose = "You pull yourself together."
	reclaim_fail = 10
	probability = 0 // NO
	occur_in_genepools = FALSE // NO ALSO
	can_make_injector = FALSE
	can_copy = FALSE


/datum/bioEffect/speech/comic
	name = "Frontal Gyrus Alteration Type-CS"
	desc = "Causes the speech center of the subject's brain to become, uh. Well, SOMETHING happens to it."
	id = "accent_comic"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "<font face='Comic Sans MS'>You feel great!!</font>"
	msgLose = "You feel okay."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("T","A")
	lockedTries = 3
	icon_state = "speech_clown"


/datum/bioEffect/speech/badmin
	name = "Frontal Gyrus Alteration Type-Badmin"
	desc = "Spooky. Red."
	id = "accent_badmin"
	effectType = EFFECT_TYPE_POWER
	isBad = FALSE
	msgGain = "You now speak with black and red text."
	msgLose = "Back to normal text."
	probability = 0 // NO
	occur_in_genepools = FALSE // NO ALSO
	can_make_injector = FALSE
	can_copy = FALSE

	goodmin
		name = "Frontal Gyrus Alteration Type-Goodmin"
		desc = "Wow!"
		id = "accent_goodmin"
		msgGain = "You now speak with white, glowing text."
		msgLose = "Back to normal text."

	rainbow
		name = "Frontal Gyrus Alteration Type-Radmin"
		desc = "Colors!"
		id = "accent_radmin"
		msgGain = "You now speak with color-cycling text."
		msgLose = "Back to normal text."

	rainglow
		name = "Frontal Gyrus Alteration Type-Fabmin"
		desc = "Glowy colors!"
		id = "accent_fabmin"
		msgGain = "You now speak with glowing, color-cycling text."
		msgLose = "Back to normal text."

/datum/bioEffect/speech/slurring
	name = "Frontal Gyrus Alteration Type-D"
	desc = "Causes the subject to have impaired control over their oral muscles, resulting in malformed speech."
	id = "slurring"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "You feel like your tongue's made out of lead."
	msgLose = "You feel less tongue-tied."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("T","A")
	lockedTries = 3
	icon_state = "speech_bad"


/datum/bioEffect/speech/unintelligable
	name = "Frontal Gyrus Alteration Type-X"
	desc = "Heavily corrupts the part of the brain responsible for forming spoken sentences."
	id = "unintelligable"
	isBad = TRUE
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


/datum/bioEffect/monkey_speak
	name = "Monkey Speak"
	desc = "Causes the subject to understand monkeys."
	id = "monkey_speak"
	probability = 0
	msgGain = "You feel one with the jungle!"
	msgLose = "You feel less primal."

	OnAdd()
		src.owner.listen_tree.AddKnownLanguage(LANGUAGE_MONKEY)
		. = ..()

	OnRemove()
		src.owner.listen_tree.RemoveKnownLanguage(LANGUAGE_MONKEY)
		. = ..()


/datum/bioEffect/speech/zalgo
	name = "Eldritch Speech"
	desc = "The subject's larynx is channeling a chaotic dimension of elder beings."
	id = "accent_zalgo"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "HE COMES"
	msgLose = "You feel sane again."
	probability = 0
	occur_in_genepools = FALSE // Probably shouldn't look like this? http://f.666kb.com/i/d2iqlzm1qa2gk6dqs.png
	scanner_visibility = FALSE
	can_research = FALSE
	can_make_injector = FALSE
	can_copy = FALSE
	can_reclaim = FALSE
	can_scramble = FALSE
	curable_by_mutadone = FALSE

	New()
		src.msgGain = zalgoify(src.msgGain, rand(0,8), rand(0, 2), rand(0, 8))
		..()


/datum/bioEffect/speech/void
	name = "Void"
	desc = "The subject's speech appears to come from multiple, shunted locations."
	id = "accent_void"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "Ah, friend! It's so good to be able to speak again!"
	msgLose = "Your voice is only yours again."
	probability = 0
	occur_in_genepools = FALSE
	scanner_visibility = FALSE
	can_research = FALSE
	can_make_injector = FALSE
	can_copy = FALSE
	can_reclaim = FALSE
	can_scramble = FALSE
	curable_by_mutadone = FALSE

	New()
		src.msgGain = voidSpeak(src.msgGain)
		..()


/datum/bioEffect/speech/yee // DO NOT MAKE THIS APPEAR IN GENEPOOLS OR INTO A TRAIT OR ANY OF THAT, PLEASE, THANK YOU IN ADVANCE - with love, haine
	name = "yee"
	desc = "yee"
	id = "accent_yee"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "yee"
	msgLose = "nee"
	probability = 0 // noo
	occur_in_genepools = FALSE // not for human consumption
	scanner_visibility = FALSE
	can_research = FALSE
	can_make_injector = FALSE
	can_copy = FALSE
	can_reclaim = FALSE
	can_scramble = FALSE
	curable_by_mutadone = FALSE


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
	var/used = FALSE

	switch(R.curr_char)
		if ("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Z") // all but Y
			if (R.prev_char == " " || R.curr_char_pos == 1) // start of a word or start of the string
				new_string = "Y"
				used = TRUE
			else
				new_string = "E"
				used = TRUE
		if ("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z") // all but e
			if (R.prev_char == " " || R.curr_char_pos == 1) // start of a word or start of the string
				new_string = "y"
				used = TRUE
			else
				new_string = "e"
				used = TRUE

	if (new_string == "")
		new_string = R.curr_char
		used = TRUE

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


/datum/bioEffect/speech/uwuwhatsthis //God is Dead
	// okay this one is less creepy/weird than the owo one because it
	// doesn't have the awkward prefix/suffixes. It's more like an actual accent.
	// And also horrible.
	name = "Frontal Gyrus Alteration Type-U"
	desc = "Reconstructs the language center of the subject's brain to create less threatening speech patterns."
	id = "accent_uwu"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = FALSE // heh
	msgGain = "Oh nyo. uwu"
	msgLose = "Nyo more funny talking."
	occur_in_genepools = FALSE
	acceptable_in_mutini = FALSE
	probability = 0 // Should not be player accessible
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3


/datum/bioEffect/speech/literalowotalk
	name = "Frontal Gyrus Alteration Type-OWO"
	desc = "Reconstructs the language center of the subject's brain, shutting most of it down and allowing for a very limited functionality."
	id = "accent_literalowo"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "Owo wowo wowow owow!"
	msgLose = "You feel like your vocabulary has expanded!"
	probability = 0
	occur_in_genepools = FALSE
	scanner_visibility = FALSE
	can_research = FALSE
	can_make_injector = FALSE
	can_copy = FALSE
	can_reclaim = FALSE
	can_scramble = FALSE
	curable_by_mutadone = FALSE
	acceptable_in_mutini = FALSE


/datum/bioEffect/speech/french
	name = "Frontal Gyrus Alteration Type-Q"
	desc = "Forces the language center of the subject's brain to construct rude and vaguely-canadian sentences."
	id = "accent_french"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "You feel like your province is a nation, however that works."
	msgLose = "The feeling of Independence passes."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3


/datum/bioEffect/speech/tyke
	name = "Frontal Gyrus Alteration Type-Y"
	desc = "Forces the language center of the subject's brain to construct sentences in the manner of a northerner."
	id = "accent_tyke"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "You feel like you're on Ilkley Moor without a hat."
	msgLose = "You never want to hear a brass band again."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3


/datum/bioEffect/speech/scoob
	name = "Frontal Gyrus Alteration Type-SD"
	desc = "Forces the language center of the subject's brain to bark out sentences like a dog."
	id = "accent_scoob"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "You feel like you've got some work to do now."
	msgLose = "You feel like you've found yourself."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3


/datum/bioEffect/speech/scoob/less_dog
	name = "Frontal Gyrus Alteration Type-BD" // bad dog 3=
	desc = "Influences select language centers of the subject's brain to bark out sentences like a dog."
	id = "accent_scoob_nerf"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "You feel like you're talking through a dog's snout."
	msgLose = "You feel less vocally canine."
	probability = 0
	occur_in_genepools = FALSE
	scanner_visibility = FALSE
	can_research = FALSE
	can_make_injector = FALSE
	can_copy = FALSE
	can_reclaim = FALSE
	can_scramble = FALSE
	curable_by_mutadone = FALSE
	acceptable_in_mutini = FALSE


/datum/bioEffect/speech/thrall
	name = "Frontal Gyrus Alteration Type-V"
	desc = "Forces the language center of the subject's brain to emit gurgling, raspy speech."
	id = "accent_thrall"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "Your throat gurgles with blood."
	msgLose = "You feel your throat clear."
	probability = 0
	occur_in_genepools = FALSE
	scanner_visibility = FALSE
	can_research = FALSE
	can_make_injector = FALSE
	can_copy = FALSE
	can_reclaim = FALSE
	can_scramble = FALSE
	curable_by_mutadone = FALSE
	acceptable_in_mutini = TRUE


/datum/bioEffect/speech/emoji
	name = "Frontal Gyrus Alteration Type-😃"
	desc = "Makes the 💬 center of the 🧑's 🧠 to use pictograms in 🗣."
	id = "emoji"
	probability = 1
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "Y-you feel a bit 🤪."
	msgLose = "You don't feel like talking in pictograms anymore."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 3
	mixingdesk_allowed = FALSE


/datum/bioEffect/speech/emoji/only
	name = "Frontal Gyrus Alteration Type-🤪"
	desc = "💬🧑🧠🗣"
	id = "emojionly"
	probability = 0.2
	msgGain = "🧑⬅🗨🤪"
	msgLose = "You don't feel like talking only in pictograms anymore."


/datum/bioEffect/speech/lol
	name = "Frontal Gyrus Alteration Type-LOL"
	desc = "Reconstructs the language center of the subject's brain with memetic patterns."
	id = "accent_lolcat"
	effectType = EFFECT_TYPE_DISABILITY
	msgGain = "YOU CAN HAZ LULZ SPEAKS!"
	msgLose = "You don't feel like talking in memetic patterns anymore."
	occur_in_genepools = FALSE
	probability = 0 // Should not be player accessible


/datum/bioEffect/speech/pirate
	name = "Frontal Gyrus Alteration Type-AR"
	desc = "Forces the language center of the subject's brain to construct sentences as sailing on the Seven Seas."
	id = "accent_pirate"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "Ye feel like a swashbucklin' pirate!"
	msgLose = "You stop feeling like sailing the Seven Seas."


/datum/bioEffect/speech/scrambled
	name = "Fonratl Guyrs Alrtateion Tpye-SC"
	desc = "Mkaes the lgnauage cnetre of the sbuejct's vicoe to eimt cuirous sntecenes."
	id = "accent_scrambled"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "Yuo feel lkie yuor vicoe is sramlcbing."
	msgLose = "Yuo feel yuor vicoe is no lnoger sramlcbing."


/datum/bioEffect/speech/word_scrambled
	name = "Alteration Type Frontal Gyrus-WSC"
	desc = "The to subject's emit the sentences brain language center curious of makes."
	id = "accent_word_scrambled"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "Words your scrambled out come."
	msgLose = "Scrambled no longer are your words."


/datum/bioEffect/speech/mocking
	name = "FrOnTaL gYrUs AlTeRaTiOn TyPe-Mc"
	desc = "mAkEs ThE lAnGuAgE cEnTeR oF tHe SuBjEcT's BrAiN tO cOnStRuCt SeNtEnCeS aS mOcKiNg ThE sUbJeCt."
	id = "accent_mocking"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	occur_in_genepools = FALSE
	probability = 0
	msgGain = "YoU fEeL lIkE mOcKiNg pEoPlE."
	msgLose = "YoU dOn'T fEeL lIkE mOcKiNg pEoPlE aNyMoRe."


/datum/bioEffect/speech/leetspeak
	name = "Fr0nT4l Gyrus 4lt3r4t10n TYP3-1337"
	desc = "Makes you speak the secret language of hackers."
	id = "accent_hacker"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "Y0u f33l l1k3 4 h4ck3r."
	msgLose = "You don't feel like a hacker anymore."
	probability = 15


/datum/bioEffect/speech/piglatin
	name = "Frontal Gyrus Alteration Type-Igpay-Atinlay"
	desc = "Makes you speak like an 8-year-old with something to hide."
	id = "accent_piglatin"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = TRUE
	msgGain = "ouYay artstay eakingspay inay igpay atinlay."
	msgLose = "You stop speaking in pig latin."
	probability = 15

/datum/bioEffect/speech/bingus
	name = "Frontal Gyrus Alteration Type-bingus"
	desc = "Reconstructs the language center of the subject's brain to love bingus."
	id = "accent_bingus"
	effectType = EFFECT_TYPE_DISABILITY
	msgGain = "Bingus my beloved :)"
	msgLose = "Bingus my beloved :("
	occur_in_genepools = FALSE
	probability = 0 // Should not be player accessible
