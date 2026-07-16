/datum/targetable/critter/ouija_speak
	name = "Ouija Speak"
	desc = "Let the spirits decide what to say."
	targeted = 0
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "corruption"
	var/words_min = 7
	var/words_max = 10
	var/list/maptext_style = list(
		"font-style" = "italic",
		"font-family" = "'XFont 6x9'",
		"font-size" = "7px",
	)
	var/list/maptext_colors = null

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
		if (prob(20))
			src.maptext_colors = list("#FF2E00", "#b33418")
		else
			src.maptext_colors = null
		src.holder.owner.say(selected, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))

		return 0
