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
	var/spooky = FALSE

	cast(atom/target)
		if (..())
			return 1

		var/selected
		do
			var/list/words = list("*REFRESH*") + get_ouija_word_list(src, words_min, words_max,
				filename="plush_toy_words.txt", strings_category="plush_toy_words")
			if (src.spooky)
				words.Insert(2, "*CALL WRAITH*")
			selected = tgui_input_list(usr, "Select a word:", src.name, words, allowIllegal=FALSE, timeout=10 SECONDS)
		while(selected == "*REFRESH*")
		if(!selected)
			return
		if(!holder || !holder.owner)
			return
		selected = uppertext(selected)
		if (prob(20))
			src.maptext_colors = list("#FF2E00", "#b33418")
		else
			src.maptext_colors = null
		if (selected == "*CALL WRAITH*")
			src.call_wraith(holder.owner)
		else
			playsound(holder.owner, 'sound/misc/automaton_scratch.ogg', 50, 1)
			src.holder.owner.say(selected, src.sayflag, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))

		return 0

	proc/call_wraith(var/mob/user)
		if (ON_COOLDOWN(user, "call_wraith", 8 SECONDS))
			boutput(user, "<i>You can't just yet...</i>")
			return
		var/mob/living/critter/wraith/demon_doll/doll
		if (istype(user, /mob/living/critter/wraith/demon_doll))
			doll = user
		else
			return

		if (!doll.master)
			boutput(doll, "<i>There was no response...</i>")
			return
		var/obj/itemspecialeffect/screech/screech = new /obj/itemspecialeffect/screech
		screech.color = "#AAAAFF"
		screech.setup(doll.loc)
		var/turf/T = get_turf(doll)
		var/direction = dir_to_dirname(get_dir(doll.master.loc, doll.loc))
		playsound(holder.owner, 'sound/voice/wraith/wraithwhisper1.ogg', 30, 1)
		boutput(doll, "<i>You cry out to your master...</i>")
		boutput(doll.master, SPAN_ALERT("<i>You feel a cry for attention coming from [T.loc] to the [direction]...</i>"))

	demon_doll
		name = "Ouija Song"
		desc = "Sing a word the spirits provide you, or call for help from your master."
		icon = 'icons/mob/critter_ui.dmi'
		icon_state = "song_speak"
		sayflag = SAYFLAG_LOUD_SINGING
		spooky = TRUE
		var/border_icon = 'icons/mob/wraith_ui.dmi'
		var/border_state = "trickster_frame"

		onAttach(datum/abilityHolder/holder)
			..()
			var/atom/movable/screen/ability/topBar/B = src.object
			B.UpdateOverlays(image(border_icon, border_state), "mob_type")

