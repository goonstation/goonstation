// TRIGGERS

ABSTRACT_TYPE(/datum/artifact_trigger/)
/datum/artifact_trigger
	var/type_name = "bad artifact code"
	var/stimulus_required = null
	var/do_amount_check = 1
	var/stimulus_amount = null
	var/stimulus_type = ">="
	var/hint_range = 0
	var/hint_prob = 33
	var/used = 1

/datum/artifact_trigger/carbon_touch
	// touched by a carbon lifeform
	type_name = "Carbon Touch"
	stimulus_required = "carbtouch"
	do_amount_check = 0

/datum/artifact_trigger/silicon_touch
	// touched by a silicon lifeform
	type_name = "Silicon Touch"
	stimulus_required = "silitouch"
	do_amount_check = 0

/datum/artifact_trigger/force
	type_name = "Physical Force"
	stimulus_required = "force"
	hint_range = 20
	hint_prob = 75

	New()
		..()
		stimulus_amount = rand(3,30)

/datum/artifact_trigger/heat
	type_name = "Heat"
	stimulus_required = "heat"
	hint_range = 20

	New()
		..()
		stimulus_amount = rand(320,400)

/datum/artifact_trigger/cold
	type_name = "Cold"
	stimulus_required = "heat"
	stimulus_type = "<="
	hint_range = 20

	New()
		..()
		stimulus_amount = rand(200,300)

/datum/artifact_trigger/radiation
	type_name = "Radiation"
	stimulus_required = "radiate"
	hint_range = 2
	hint_prob = 75

	New()
		..()
		stimulus_type = pick(">=","<=")
		stimulus_amount = rand(1,10)

/datum/artifact_trigger/electric
	type_name = "Electricity"
	stimulus_required = "elec"
	hint_range = 500
	hint_prob = 66

	New()
		..()
		stimulus_type = pick(">=","<=")
		stimulus_amount = rand(5,5000)

/datum/artifact_trigger/reagent
	type_name = "Chemicals"
	stimulus_required = "reagent"
	// can just use the above var as the required reagent field really
	stimulus_type = ">="
	hint_range = 50
	hint_prob = 100
	used = 0

	New()
		..()
		stimulus_amount = rand(10,100)

/datum/artifact_trigger/reagent/blood
	type_name = "Blood"
	stimulus_required = "blood"
	used = 0

/datum/artifact_trigger/data
	// touched by something that contains data (circuit board, disks) etc.
	type_name = "Data"
	stimulus_required = "data"
	do_amount_check = 0

/datum/artifact_trigger/language
	type_name = "Language"
	stimulus_required = "language"
	hint_prob = 0 // uses custom way of giving hint
	do_amount_check = FALSE
	// number of vowels in picked word
	var/num_vowels = 0
	// positions of vowels in picked word
	var/list/positions = list()
	// list of all valid words
	var/static/word_dict = null
	var/static/list/vowels = list("a", "e", "i", "o", "u")

	New()
		..()
		if (!src.word_dict)
			// need to account for words with no vowels
			src.word_dict = dd_file2list("strings/letter_words_5.txt", " ")
		var/picked_word = pick(src.word_dict)
		for (var/i = 1 to 5)
			if (picked_word[i] in src.vowels)
				src.positions += "v" // vowel
				src.num_vowels += 1
			else
				src.positions += "c" // consonant

	proc/speech_act(text)
		if (!text)
			return
		text = ckey(text[1])
		if (length(text) != 5)
			return "hint"
		if (!(text in src.word_dict))
			return "error"
		var/input_vowels = 0
		var/correct_vowels = 0
		var/misplaced_vowels = 0
		for (var/i = 1 to 5)
			if (text[i] in src.vowels)
				input_vowels += 1
				if (src.positions[i] == "v")
					correct_vowels += 1

		if (input_vowels > src.num_vowels)
			return " emits a [SPAN_BOLD("grumpy")] chime."
		if (correct_vowels == src.num_vowels)
			return "correct"
		misplaced_vowels = input_vowels - correct_vowels

		var/correct_vowel_msg = "[correct_vowels == 1 ? "a <b>high</b> chime" : "a series of [correct_vowels] <b>high</b> chimes"]"
		var/misplaced_vowel_msg = "[misplaced_vowels == 1 ? "a <b>low</b> chime" : "a series of [misplaced_vowels] <b>low</b> chimes"]"

		if (correct_vowels > 0 && misplaced_vowels > 0)
			return " emits [correct_vowel_msg] and [misplaced_vowel_msg]."
		if (correct_vowels > 0)
			return " emits [correct_vowel_msg]."
		return " emits [misplaced_vowel_msg]."

/datum/artifact_trigger/repair
	type_name = "Repair"
	stimulus_required = "repair"
	hint_prob = 100
	do_amount_check = FALSE

	// list of tools to pull from
	var/list/possible_tools = list(TOOL_SNIPPING, TOOL_PRYING, TOOL_SCREWING, TOOL_WELDING, TOOL_WRENCHING, TOOL_PULSING)
	// list of tools that are required to repair this artifact
	var/list/tools_required = list()
	// the artifact this trigger is tied to
	var/datum/artifact/artifact = null
	// the current item we're working on based on origin
	var/current_thingy = null
	// the description for the tool we need
	var/tool_desc = ""

	New()
		..()
		if (length(src.tools_required) < 1)
			// add random amount of tools in an ordered list
			for (var/i in 1 to rand(4, 5))
				src.tools_required += pick(src.possible_tools)

	/// Returns advice on the next tool to be used to repair the artifact
	proc/get_desc()
		var/verby = src.get_current_tool_data("verb")

		if (length(src.tools_required) < 1)
			return "Looks like the artifact is fully repaired."

		src.current_thingy = src.current_thingy ? src.current_thingy : pick(src.artifact.artitype.nouns_small)
		var/list/action_list = list(
			"Seems like you need to [verby] the [current_thingy], it's completely busted.",
			"[capitalize(verby)]ing the [current_thingy] seems necessary, considering its state.",
			"Looks like you'll need to [verby] the [current_thingy] to get this thing running.",
			"That [current_thingy] looks broken. It's going to need some [verby]ing.",
			"Could be that the [current_thingy] needs some [verby]ing to proceed. Probably.",
			"Maybe [verby]ing the [current_thingy] will repair it?"
		)
		src.tool_desc = src.tool_desc ? src.tool_desc : pick(action_list)
		return src.tool_desc

	proc/remove_tool()
		src.current_thingy = null
		src.tool_desc = null
		src.tools_required.Remove(src.tools_required[1])
		src.artifact.examine_hint = src.get_desc()

	proc/get_current_tool_data(var/action = "verb")
		var/verby = ""
		var/soundy = 'sound/items/Crowbar.ogg'
		if(length(src.tools_required) == 0)
			return ""
		switch(src.tools_required[1])
			if(TOOL_SNIPPING)
				verby = "cut"
				soundy = 'sound/items/Wirecutter.ogg'
			if(TOOL_PRYING)
				verby = "pry"
				soundy = 'sound/items/Crowbar.ogg'
			if(TOOL_SCREWING)
				verby = "screw"
				soundy = 'sound/items/Screwdriver.ogg'
			if(TOOL_WELDING)
				verby = "weld"
				soundy = 'sound/items/Welder.ogg'
			if(TOOL_WRENCHING)
				verby = "wrench"
				soundy = 'sound/items/Ratchet.ogg'
			if(TOOL_PULSING)
				verby = "shock"
				soundy = 'sound/effects/electric_shock_short.ogg'
			else
				verby = "work"
				soundy = 'sound/items/Crowbar.ogg'
		if (action == "verb")
			return verby
		else if (action == "sound")
			return soundy

	proc/parse_tool(var/obj/item/I, var/mob/user)
		if(length(src.tools_required) == 0)
			return
		if(istool(I, src.tools_required[1]))
			var/soundy = src.get_current_tool_data("sound")
			playsound(src.artifact.holder.loc, soundy, 100, 1)
			// Using the artifact object here as a target instead of the /datum because of range checks, but we pass the trigger as a param
			SETUP_GENERIC_ACTIONBAR(user, src.artifact.holder, rand(1, 3) SECONDS, /datum/artifact_trigger/repair/proc/use_tool, list(src, user), I.icon, I.icon_state, null, INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)
		else
			var/verby = src.get_current_tool_data("verb")
			boutput(user, SPAN_ALERT("[I] ain't the right tool for the job. You need something that can [verby]."))

	proc/use_tool(var/datum/artifact_trigger/repair/trigger, var/mob/user)
		var/verby = trigger.get_current_tool_data("verb")
		trigger.current_thingy = trigger.current_thingy ? trigger.current_thingy : pick(trigger.artifact.artitype.nouns_small)
		user.visible_message(SPAN_ALERT("[user] works on [trigger.artifact]."), "You [verby] the [trigger.current_thingy] inside [src].")
		trigger.remove_tool()
		if(length(trigger.tools_required) == 0)
			var/obj/holder = src
			holder.ArtifactActivated()
