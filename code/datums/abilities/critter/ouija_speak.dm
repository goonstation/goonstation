/datum/targetable/critter/ouija_speak
	name = "Ouija Speak"
	desc = "Let the spirits decide what to say."
	targeted = 0
	var/words_min = 7
	var/words_max = 10

	cast(atom/target)
		if (..())
			return 1

		var/selected
		do
			var/list/words = list("*REFRESH*") + get_ouija_word_list(src, words_min, words_max,
				filename="plush_toy_words.txt", strings_category="plush_toy_words")
			selected = tgui_input_list(usr, "Select a word:", src.name, words, allowIllegal=FALSE, timeout=10 SECONDS)
		while(selected == "*REFRESH*")
		if(!selected)
			return
		if(!holder || !holder.owner)
			return
		playsound(holder.owner, 'sound/misc/automaton_scratch.ogg', 50, 1)
		selected = uppertext(selected)
		src.holder.owner.say(selected)
		return 0
