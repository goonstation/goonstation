TYPEINFO(/obj/item/device/law_hacker)
	mats = list("crystal" = 1,
				"conductive_high" = 1)
/obj/item/device/law_hacker
	name = "AI law hacker"
	icon_state = "law_hacker"
	flags = TABLEPASS | CONDUCT
	force = 5
	w_class = W_CLASS_NORMAL
	desc = "A syndicate-made device for modifying AI law modules. "
	is_syndicate = TRUE
	rand_pos = FALSE
	var/obj/item/aiModule/module = null

	get_desc()
		if (src.module)
			. += "The inserted module reads, \"<em>[src.module.get_law_text()]</em>\""

	update_icon()
		var/image/circuit_image = null
		var/image/color_overlay = null
		if(src.module)
			circuit_image = image(src.icon, "hack_aimod")
			circuit_image.color = src.module.color
			color_overlay = image(src.icon, "hack_aimod_over")
			color_overlay.color = src.module.highlight_color
		src.UpdateOverlays(circuit_image,"module")
		src.UpdateOverlays(color_overlay,"module_overlay")
		..()

	attack_self(var/mob/user)
		if(src.module)
			var/lawTarget = tgui_input_text(user, "Enter whatever you want the AI to do.", "Law Hacking", src.module.lawText)
			if(lawTarget)
				lawTarget = copytext(adminscrub(lawTarget), 1, src.module.input_char_limit)
				var/replace = tgui_alert(user,"Completely overwrite law?", "Law Hacking", list("Yes", "No"))
				if(!(src in user.equipped_list()))
					boutput(user, SPAN_NOTICE("You must be holding [src] to use it."))
					return
				if (replace == "Yes")
					src.module.make_glitchy(lawTarget, TRUE)
				else
					src.module.make_glitchy(lawTarget, FALSE)
			return
		else
			boutput(user, "No law module inserted.")

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/aiModule))
			if (src.module)
				boutput(user, SPAN_ALERT("The [src] already has a module inserted!"))
				return
			else
				boutput(user, "You insert the module into the [src].")
				user.drop_item()
				W.set_loc(src)
				src.module = W
				src.UpdateIcon()
		..()

	attack_hand(mob/user)
		if(src.module)
			user.put_in_hand_or_drop(src.module)
			src.module = null
			src.UpdateIcon()
			return
		..()
