// Most of the code stolen from the omnitool
// Modes:
// - scalpel
// - saw
// - scissors
// - spoon
/obj/item/tool/surgery_omnitool
	name = "surgery omnitool"
	desc = "Multiple surgery tools in one. Important, will not make you better at surgery without the proper training."
	icon = 'icons/obj/items/tools/surgery_omnitool.dmi'
	icon_state = "omnitool-prying"
	inhand_image_icon = 'icons/mob/inhand/tools/surgery_omnitool.dmi'
	uses_multiple_icon_states = TRUE
	var/prefix = "omnitool"
	var/has_cutting = 0
	var/has_welding = 0
	var/welding = 0

	var/omni_mode = "scalpel"

	New()
		..()
		src.change_mode(omni_mode)

	attack(mob/living/carbon/M as mob, mob/user as mob)
		switch (src.omni_mode)
			if ("scalpel")
				if (!scalpel_surgery(M, user))
					return ..()

			if ("saw")
				if (!saw_surgery(M, user))
					return ..()

			if ("scissors")
				if (src.remove_bandage(M, user))
					return 1
				if (snip_surgery(M, user))
					return 1
				..()

			if ("spoon")
				if (!spoon_surgery(M, user))
					return ..()

	attack_self(var/mob/user as mob)
		// Cycle between modes
		var/new_mode
		switch (src.omni_mode)
			if ("scalpel") new_mode = "saw"
			if ("saw") new_mode = "scissors"
			if ("scissors") new_mode = "spoon"
			if ("spoon") new_mode = "scalpel"

		src.change_mode(new_mode, user)

	proc/change_mode(var/new_mode, var/mob/holder)
		tooltip_rebuild = TRUE

		switch(new_mode)
			if ("scalpel")
				src.omni_mode = new_mode
				set_icon_state("[prefix]-[omni_mode]")
				src.tool_flags = TOOL_CUTTING
				src.hit_type = DAMAGE_CUT
				src.hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
				src.force = 5
				src.w_class = 1.0
				src.throwforce = 5.0
				src.throw_speed = 3
				src.throw_range = 5
				src.stamina_damage = 5
				src.stamina_cost = 5
				src.stamina_crit_chance = 35

			if ("saw")
				src.omni_mode = new_mode
				set_icon_state("[prefix]-[omni_mode]")
				tool_flags = TOOL_SAWING
				src.hit_type = DAMAGE_CUT
				src.hitsound = 'sound/impact_sounds/circsaw.ogg'
				src.force = 8
				src.w_class = 1.0
				src.throwforce = 3.0
				src.throw_speed = 3
				src.throw_range = 5
				src.stamina_damage = 5
				src.stamina_cost = 5
				src.stamina_crit_chance = 35

			if ("scissors")
				src.omni_mode = new_mode
				set_icon_state("[prefix]-[omni_mode]")
				src.tool_flags = TOOL_SNIPPING
				src.hit_type = DAMAGE_STAB
				src.hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
				src.force = 8.0
				src.w_class = 1.0
				src.throwforce = 5.0
				src.throw_speed = 3
				src.throw_range = 5
				src.stamina_damage = 5
				src.stamina_cost = 5
				src.stamina_crit_chance = 35

			if ("spoon")
				src.omni_mode = new_mode
				set_icon_state("[prefix]-[omni_mode]")
				src.tool_flags = 0 // TOOL_SPOONING is a thing, but it seems unused?
				src.hit_type = DAMAGE_STAB
				src.hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
				src.force = 5.0
				src.w_class = 1.0
				src.throwforce = 5.0
				src.throw_speed = 3
				src.throw_range = 5
				src.stamina_damage = 5
				src.stamina_cost = 5
				src.stamina_crit_chance = 35

		if (holder)
			boutput(holder, "Switched to [omni_mode]")
			holder.update_inhands()
