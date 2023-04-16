/obj/item/chem_hint
	icon = 'icons/obj/dojo.dmi'
	icon_state = "scroll"
	name = "Clue scroll"
	desc = "A scroll containing a hint for a secret chemical recipe."
	var/hint_text = "heck, someone forgot to put a hint in this scroll! Call 1-800-IMCODER"
	var/chem_name = "1-800-CODER"
	var/has_been_read = 0
	var/only_on_production_no_file = 0

	get_desc()
		return " [chem_name] is carefully written on the outside of the scroll in fancy writing."

	attack_self(var/mob/U)
		if(has_been_read)
			boutput(U,"The writing is all smudged up. You cant read anything on this scroll.")
			return
		if(!U.literate)
			boutput(U,"You can't read. Bummer!")
			return
		if(!ishuman(U))
			return
		var/mob/living/carbon/human/user = U
		has_been_read = 1
		if(chem_name == "Quark Gluon Plasma") // YOU FOOL
			if(tgui_alert(user, "You've heard horrific stories about this chemical. Are you really sure you want to read this scroll? Reading this is probably very dangerous!", "Confirmation", list("Yes", "No")) != "Yes")
				has_been_read = 0
				return
			user.client.add_to_bank(3500)
			boutput(user,"You slowly unfurl the the scroll","red")
			icon_state = "scroll_open"
			SPAWN(1 SECOND)
				boutput(user,"<B>THE HORROR!</B>")
				user.emote("scream")
				sleep(1 SECOND)
				boutput(user,"The horrible secrets of the scroll burn your eyes before you can read them!</span>")
				user.flash(3 SECONDS)
				user.organHolder.get_organ("left_eye").combust()
				user.organHolder.get_organ("right_eye").combust()
				user.organHolder.drop_organ("left_eye")
				user.organHolder.drop_organ("right_eye")
				sleep(4 SECONDS)
				boutput(src.loc, "The chem hint scroll self-destructs!")
				playsound(src,'sound/effects/bamf.ogg')
				src.combust()
			return
		icon_state = "scroll_open"
		boutput(user, "You read the scroll:<br><div style='border: 3px solid #cf9f5f; font-size: 120%; color: #4f2f0f; text-align: center; background: #ffffdf;'><div style='font-size: 120%; color: #4f2f0f; text-align: center; background: #dfcf9f;padding:4px;'>[chem_name]</div><div style=' padding: 5px'>[hint_text]</div></div>", "blue")
		SPAWN(5 SECONDS)
			boutput(src.loc, "The chem hint scroll self-destructs!")
			playsound(src,'sound/effects/bamf.ogg')
			qdel(src)
