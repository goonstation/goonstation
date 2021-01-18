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
		var/mob/living/carbon/human/H = target
		if (!istype(H))
			boutput(holder.owner, "Your target must be human!")
			return 1
		holder.owner.visible_message("<span class='alert'><b>[holder.owner] begins to cast a spell on [target]!</b></span>")

		if (do_mob(holder.owner, target, 15))
			holder.owner.say("NWOLC EGNEVER")
			..()

			var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
			smoke.set_up(5, 0, H.loc)
			smoke.attach(H)
			smoke.start()

			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(holder.owner, "<span class='alert'>[H] has divine protection from magic.</span>")
				H.visible_message("<span class='alert'>The spell has no effect on [H]!</span>")
				JOB_XP(H, "Chaplain", 2)
				return

			if (iswizard(H))
				H.visible_message("<span class='alert'>The spell has no effect on [H]!</span>")
				return

			if(check_target_immunity( H ))
				H.visible_message("<span class='alert'>[H] seems to be warded from the effects!</span>")
				return 1

			if (H.job != "Cluwne")
				boutput(H, "<span class='alert'><B>You HONK painfully!</B></span>")
				H.take_brain_damage(50)
				H.stuttering = 120
				H.job = "Cluwne"
				H.contract_disease(/datum/ailment/disability/clumsy/cluwne,null,null,1)
				H.contract_disease(/datum/ailment/disease/cluwneing_around/cluwne,null,null,1)
				playsound(get_turf(H), pick("sound/voice/cluwnelaugh1.ogg","sound/voice/cluwnelaugh2.ogg","sound/voice/cluwnelaugh3.ogg"), 35, 0, 0, max(0.7, min(1.4, 1.0 + (30 - H.bioHolder.age)/50)))
				H.change_misstep_chance(60)

				animate_clownspell(H)
				//H.unequip_all()
				H.drop_from_slot(H.w_uniform)
				H.drop_from_slot(H.shoes)
				H.drop_from_slot(H.wear_mask)
				H.drop_from_slot(H.gloves)
				H.equip_if_possible(new /obj/item/clothing/under/gimmick/cursedclown(H), H.slot_w_uniform)
				H.equip_if_possible(new /obj/item/clothing/shoes/cursedclown_shoes(H), H.slot_shoes)
				H.equip_if_possible(new /obj/item/clothing/mask/cursedclown_hat(H), H.slot_wear_mask)
				H.equip_if_possible(new /obj/item/clothing/gloves/cursedclown_gloves(H), H.slot_gloves)
				H.real_name = "cluwne"
				SPAWN_DBG(2.5 SECONDS) // Don't remove.
					if (H) H.assign_gimmick_skull() // The mask IS your new face, my friend (Convair880).
			else
				boutput(H, "<span class='alert'><b>You don't feel very funny.</b></span>")
				H.take_brain_damage(-120)
				H.stuttering = 0
				if (H.mind)
					H.mind.assigned_role = "Lawyer"
				H.change_misstep_chance(-INFINITY)

				animate_clownspell(H)
				for(var/datum/ailment_data/A in H.ailments)
					if(istype(A.master,/datum/ailment/disability/clumsy))
						H.cure_disease(A)
				var/obj/old_uniform = H.w_uniform
				var/obj/item/the_id = H.wear_id

				if(H.w_uniform && findtext("[H.w_uniform.type]","clown"))
					H.w_uniform = new /obj/item/clothing/under/suit(H)
					qdel(old_uniform)

				if(H.shoes && findtext("[H.shoes.type]","clown"))
					qdel(H.shoes)
					H.shoes = new /obj/item/clothing/shoes/black(H)

				if(the_id && the_id:registered == H.real_name)
					if (istype(the_id, /obj/item/card/id))
						the_id:assignment = "Lawyer"
						the_id:name = "[H.real_name]'s ID Card (Lawyer)"
					else if (istype(the_id, /obj/item/device/pda2))
						the_id:assignment = "Lawyer"
						the_id:ID_card:assignment = "Lawyer"
						the_id:ID_card:name = "[H.real_name]'s ID Card (Lawyer)"
					H.wear_id = the_id

				for(var/obj/item/W in H)
					if (findtext("[W.type]","clown"))
						H.u_equip(W)
						if (W)
							W.set_loc(target.loc)
							W.dropped(H)
							W.layer = initial(W.layer)
		else
			return 1
