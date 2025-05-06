/datum/targetable/spell/kill
	name = "Shocking Grasp"
	desc = "Kills the victim with electrical power. Takes a few seconds to cast."
	icon_state = "grasp"
	targeted = 1
	max_range = 1
	cooldown = 600
	requires_robes = 1
	requires_being_on_turf = TRUE
	offensive = 1
	sticky = 1
	voice_grim = 'sound/voice/wizard/ShockingGraspGrim.ogg'
	voice_fem = 'sound/voice/wizard/ShockingGraspFem.ogg'
	voice_other = 'sound/voice/wizard/ShockingGraspLoud.ogg'
	maptext_colors = list("#ff0000", "#000000")

	cast(mob/target)
		if(!holder)
			return
		holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] begins to cast a spell on [target]!</b>"))
		playsound(holder.owner.loc, 'sound/effects/elec_bzzz.ogg', 25, 1, -1)
		if (do_mob(holder.owner, target, 20))
			if(!istype(get_area(holder.owner), /area/sim/gunsim))
				holder.owner.say("EI NATH", flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))
			..()

			if (ishuman(target))
				if (target.traitHolder.hasTrait("training_chaplain"))
					boutput(holder.owner, SPAN_ALERT("[target] has divine protection from magic."))
					target.visible_message(SPAN_ALERT("The electric charge courses through [target] harmlessly!"))
					JOB_XP(target, "Chaplain", 2)
					return
				else if (iswizard(target))
					target.visible_message(SPAN_ALERT("The electric charge somehow completely misses [target]!"))
					return
				else if(check_target_immunity( target ))
					boutput(holder.owner, SPAN_ALERT("[target] seems to be warded from the effects!"))
					return 1

			if (holder.owner.wizard_spellpower(src))
				elecflash(holder.owner,power = 3)
			else
				elecflash(holder.owner,power = 2)
				boutput(holder.owner, SPAN_ALERT("Your spell is weak without a staff to focus it!"))
				target.visible_message(SPAN_ALERT("[target] is severely burned by an electrical charge!"))
				target.lastattacker = get_weakref(holder.owner)
				target.lastattackertime = world.time
				target.TakeDamage("chest", 0, 80, 0, DAMAGE_BURN)
				target.changeStatus("stunned", 10 SECONDS)
				target.changeStatus("knockdown", 10 SECONDS)
				target.stuttering += 15
		else
			return 1 // no cooldown if it fails
