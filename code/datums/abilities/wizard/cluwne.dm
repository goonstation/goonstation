/datum/targetable/spell/cluwne
	name = "Clown's Revenge"
	desc = "Turns the target into a cursed clown."
	icon_state = "clownrevenge"
	targeted = 1
	max_range = 1
	cooldown = 1350
	requires_robes = 1
	offensive = 1
	sticky = 1
	voice_grim = "sound/voice/wizard/CluwneGrim.ogg"
	voice_fem = "sound/voice/wizard/CluwneFem.ogg"
	voice_other = "sound/voice/wizard/CluwneLoud.ogg"

	cast(mob/target)
		if(!holder)
			return
		var/mob/living/carbon/human/T = target
		if (!istype(T))
			boutput(holder.owner, "Your target must be human!")
			return 1
		holder.owner.visible_message("<span class='alert'><b>[holder.owner] begins to cast a spell on [target]!</b></span>")
		actions.start(new/datum/action/bar/icon/cluwne_spell(target, src), holder.owner)

/datum/action/bar/icon/cluwne_spell
	duration = 1.5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "cluwne_spell"
	icon = 'icons/ui/actions.dmi'
	icon_state = "cluwne"

	var/datum/targetable/spell/cluwne/spell
	var/mob/living/carbon/human/target

	New(Target, Spell)
		target = Target
		spell = Spell
		..()

	onStart()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/A = spell.holder
		var/mob/living/carbon/human/T = target

		if (!A || get_dist(M, T) > spell.max_range || !T || !M || !ishuman(T) || !A || !istype(A) || !M.wizard_castcheck(spell))
			interrupt(INTERRUPT_ALWAYS)

	onUpdate()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/A = spell.holder
		var/mob/living/carbon/human/T = target

		if (!A || get_dist(M, T) > spell.max_range || !T || !M || !ishuman(T) || !A || !istype(A) || !M.wizard_castcheck(spell))
			interrupt(INTERRUPT_ALWAYS)

	onEnd()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/A = spell.holder
		var/mob/living/carbon/human/T = target

		if(!istype(get_area(M), /area/sim/gunsim))
			M.say("NWOLC EGNEVER")
			..()

		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(5, 0, T.loc)
		smoke.attach(T)
		smoke.start()

		if (T.traitHolder.hasTrait("training_chaplain"))
			boutput(A, "<span class='alert'>[T] has divine protection from magic.</span>")
			T.visible_message("<span class='alert'>The spell has no effect on [T]!</span>")
			JOB_XP(T, "Chaplain", 2)
			return

		if (iswizard(T))
			T.visible_message("<span class='alert'>The spell has no effect on [T]!</span>")
			return

		if(check_target_immunity( T ))
			T.visible_message("<span class='alert'>[T] seems to be warded from the effects!</span>")
			return 1

		if (T.job != "Cluwne")
			boutput(T, "<span class='alert'><B>You HONK painfully!</B></span>")
			T.take_brain_damage(50)
			T.stuttering = 120
			T.job = "Cluwne"
			T.contract_disease(/datum/ailment/disability/clumsy/cluwne,null,null,1)
			T.contract_disease(/datum/ailment/disease/cluwneing_around/cluwne,null,null,1)
			playsound(T, pick("sound/voice/cluwnelaugh1.ogg","sound/voice/cluwnelaugh2.ogg","sound/voice/cluwnelaugh3.ogg"), 35, 0, 0, max(0.7, min(1.4, 1.0 + (30 - T.bioHolder.age)/50)))
			T.change_misstep_chance(60)

			animate_clownspell(T)
			//T.unequip_all()
			T.drop_from_slot(T.w_uniform)
			T.drop_from_slot(T.shoes)
			T.drop_from_slot(T.wear_mask)
			T.drop_from_slot(T.gloves)
			T.equip_if_possible(new /obj/item/clothing/under/gimmick/cursedclown(T), T.slot_w_uniform)
			T.equip_if_possible(new /obj/item/clothing/shoes/cursedclown_shoes(T), T.slot_shoes)
			T.equip_if_possible(new /obj/item/clothing/mask/cursedclown_hat(T), T.slot_wear_mask)
			T.equip_if_possible(new /obj/item/clothing/gloves/cursedclown_gloves(T), T.slot_gloves)
			T.real_name = "cluwne"
			SPAWN_DBG(2.5 SECONDS) // Don't remove.
				if (T) T.assign_gimmick_skull() // The mask IS your new face, my friend (Convair880).
		else
			boutput(T, "<span class='alert'><b>You don't feel very funny.</b></span>")
			T.take_brain_damage(-120)
			T.stuttering = 0
			if (T.mind)
				T.mind.assigned_role = "Lawyer"
			T.change_misstep_chance(-INFINITY)

			animate_clownspell(T)
			for(var/datum/ailment_data/AD in T.ailments)
				if(istype(AD.master,/datum/ailment/disability/clumsy))
					T.cure_disease(AD)
			var/obj/old_uniform = T.w_uniform
			var/obj/item/the_id = T.wear_id

			if(T.w_uniform && findtext("[T.w_uniform.type]","clown"))
				T.w_uniform = new /obj/item/clothing/under/suit(T)
				qdel(old_uniform)

			if(T.shoes && findtext("[T.shoes.type]","clown"))
				qdel(T.shoes)
				T.shoes = new /obj/item/clothing/shoes/black(T)

			if(the_id && the_id:registered == T.real_name)
				if (istype(the_id, /obj/item/card/id))
					the_id:assignment = "Lawyer"
					the_id:name = "[T.real_name]'s ID Card (Lawyer)"
				else if (istype(the_id, /obj/item/device/pda2))
					the_id:assignment = "Lawyer"
					the_id:ID_card:assignment = "Lawyer"
					the_id:ID_card:name = "[T.real_name]'s ID Card (Lawyer)"
				T.wear_id = the_id

			for(var/obj/item/W in T)
				if (findtext("[W.type]","clown"))
					T.u_equip(W)
					if (W)
						W.set_loc(T.loc)
						W.dropped(T)
						W.layer = initial(W.layer)
