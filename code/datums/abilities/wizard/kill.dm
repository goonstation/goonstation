/datum/targetable/spell/kill
	name = "Shocking Grasp"
	desc = "Kills the victim with electrical power. Takes a few seconds to cast."
	icon_state = "grasp"
	targeted = 1
	max_range = 1
	cooldown = 600
	requires_robes = 1
	offensive = 1
	sticky = 1
	voice_grim = "sound/voice/wizard/ShockingGraspGrim.ogg"
	voice_fem = "sound/voice/wizard/ShockingGraspFem.ogg"
	voice_other = "sound/voice/wizard/ShockingGraspLoud.ogg"

	cast(mob/target)
		if(!holder)
			return
		holder.owner.visible_message("<span class='alert'><b>[holder.owner] begins to cast a spell on [target]!</b></span>")
		playsound(holder.owner.loc, "sound/effects/elec_bzzz.ogg", 25, 1, -1)
		if (do_mob(holder.owner, target, 20))
			holder.owner.say("EI NATH")
			..()

			if (ishuman(target))
				if (target.traitHolder.hasTrait("training_chaplain"))
					boutput(holder.owner, "<span class='alert'>[target] has divine protection from magic.</span>")
					target.visible_message("<span class='alert'>The electric charge courses through [target] harmlessly!</span>")
					JOB_XP(target, "Chaplain", 2)
					return
				else if (iswizard(target))
					target.visible_message("<span class='alert'>The electric charge somehow completely misses [target]!</span>")
					return
				else if(check_target_immunity( target ))
					boutput(holder.owner, "<span class='alert'>[target] seems to be warded from the effects!</span>")
					return 1

			if (holder.owner.wizard_spellpower(src))
				elecflash(holder.owner,power = 3)
			else
				elecflash(holder.owner,power = 2)
				boutput(holder.owner, "<span class='alert'>Your spell is weak without a staff to focus it!</span>")
				target.visible_message("<span class='alert'>[target] is severely burned by an electrical charge!</span>")
				target.lastattacker = holder.owner
				target.lastattackertime = world.time
				target.TakeDamage("chest", 0, 80, 0, DAMAGE_BURN)
				target.changeStatus("stunned", 10 SECONDS)
				target.changeStatus("weakened", 10 SECONDS)
				target.stuttering += 15
		else
			return 1 // no cooldown if it fails
