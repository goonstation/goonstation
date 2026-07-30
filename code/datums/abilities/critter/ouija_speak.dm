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
	var/sayflag = null

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
		src.holder.owner.say(selected, src.sayflag, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))

		return 0

	demon_doll
		name = "Ouija Song"
		desc = "Sing a word the spirits provide you."
		icon = 'icons/mob/critter_ui.dmi'
		icon_state = "song_speak"
		sayflag = SAYFLAG_LOUD_SINGING
		var/border_icon = 'icons/mob/wraith_ui.dmi'
		var/border_state = "trickster_frame"

		onAttach(datum/abilityHolder/holder)
			..()
			var/atom/movable/screen/ability/topBar/B = src.object
			B.UpdateOverlays(image(border_icon, border_state), "mob_type")

