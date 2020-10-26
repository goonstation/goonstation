/*
Costume Effects for:
-abomination costume
-hotdog costume
-clown mask
-godzilla
-mummy
-matehcto meanea
-werewolf
-vampire
-pumpkin head
-ghost
-angle
-debil
-bee
-monkey
-owl
-zombie
-cat ears
-robot costume
-guardbuddy
-spider
-bat
Need to add:




*/
#ifdef HALLOWEEN
/datum/random_event/major/spookycostumes
	name = "Spooktober Curse"
	centcom_headline = "Oh No!"
	centcom_message = {"Unfortunately, our station has crashed into a space witch. Beware of curses."}
	disabled = 1// press it though
	var/list/eligible_mobs = list()
	event_effect()
		..()
		eligible_mobs = list()

		for (var/mob/living/carbon/human/H in mobs)
			if (isdead(H))
				continue
			if (!H.bioHolder)
				continue
			if(H.w_uniform || H.wear_mask || H.head || H.wear_suit )
				eligible_mobs += H


		if (!eligible_mobs.len)
			message_admins("spooky random event could not find enough mobs to proceed")
			return


		sleep(5 SECONDS)

		for (var/mob/living/carbon/human/H in eligible_mobs)

			if ((H.head && findtext(H.head.name, "abomination")) || (H.w_uniform && findtext(H.w_uniform.name, "abomination")))
				H.set_mutantrace(/datum/mutantrace/abomination/admin/)
				boutput(H, "<span class='alert'><font  size='[1]'>for some reason, your costume feels a lot more rubbery</font></span>")


				return
			if (H.wear_suit && findtext(H.wear_suit.name,"hotdog"))
				var/obj/item/reagent_containers/food/snacks/hotdog/D = new /obj/item/reagent_containers/food/snacks/hotdog
				D.loc = get_turf(H)
				D.bun = 1
				D.update_icon()
				var/atom/movable/overlay/gibs/animation = null
				animation = new(H.loc)
				animation.master = H
				flick("implode", animation)
				boutput(H, "<span class='alert'><font  size='[10]'>NOOOOOOOOOOOO I DONT WANNA BE A WEENIE AAAAAAAAAAAAAAAAAAAA</font></span>")
				H.set_loc(D)
				H.bioHolder.AddEffect("telepathy",magical = 1)
				for (var/datum/targetable/A in H.abilityHolder.abilities)
					if(istype(A,/datum/targetable/geneticsAbility/telepathy))
						A.cooldown = 0
				if(!H.bioHolder.AddEffect("mute",magical = 1))
					boutput(H, "<span class='alert'><font  size='[5]'>something broke</font></span>")
				return
			if (H.wear_mask && findtext(H.wear_mask.name, "clown"))
				H.reagents.add_reagent("rainbow fluid", 300)
				return
			if ( H.wear_id && H.w_uniform && H.head && H.bioHolder.HasOneOfTheseEffects("lizard") && findtext(H.wear_id.name, "Discount Godzilla") && findtext(H.w_uniform.name,"green") && findtext(H.head.desc,"green"))

				H.reagents.add_reagent("bubs", INFINITY)//make big like godzilla and the gravity effect emulates them stomping around
				for(var/reagent in H.reagents.reagent_list)
					if(reagent == "bubs")
						var/datum/reagent/R = H.reagents.reagent_list[reagent]
						R.depletion_rate = 0
				H.bioHolder.AddEffect("hulk",magical = 1)
				return
			if (H.w_uniform && H.wear_mask && findtext(H.w_uniform.name,"linen") && findtext(H.wear_mask.name,"linen"))
				var/list/limbs = list("l_arm","r_arm","l_leg","r_leg","head","chest")
				for (var/target in limbs)
					if (!H.bandaged.Find(target))
						H.bandaged += target
						H.update_body()
				boutput(H, "<span class='alert'>You feel somewhat less susceptible to bleeding.</span>")
				return
			if(H.shoes && H.w_uniform && H.glasses && H.head && findtext(H.shoes.name,"wrestling") && findtext(H.w_uniform.name,"wrestling") && findtext(H.glasses.name,"yellow") && findtext(H.head.name,"macho"))
				H.machoize()
				return
			if((H.head && findtext(H.head.name, "werewolf")) || (H.wear_suit && findtext(H.wear_suit.name, "werewolf")))
				var/odd=0
				var/newcolor
				if (H.head && findtext(H.head.name, "odd"))
					newcolor = H.head.color
					odd = 1
				else if (H.wear_suit && findtext(H.wear_suit.name, "odd"))
					newcolor = H.w_uniform.color
					odd = 1
				H.werewolf_transform(1,0)
				if(odd)
					H.bioHolder.AddEffect("accent_uwu",magical = 1)
					H.bioHolder.AddEffect("accent_owo",magical = 1)//I couldn't choose so I decided both
					H.bioHolder.RemoveEffect("accent_scoob_nerf")
					H.color = newcolor
				return
			if(H.shoes && H.w_uniform && H.wear_suit && H.head && findtext(H.shoes.name,"military") && findtext(H.w_uniform.name,"absurdly") && findtext(H.wear_suit.name,"absurdly") && findtext(H.head.name,"Hat"))
				H.make_vampire()
				return
			if(H.head && findtext(H.head.name,"pumpkin"))
				H.head.cant_self_remove = 1
				H.head.cant_other_remove = 1
				H.head.acid_proof = 1
				H.head.w_class = 400
				boutput(H, "<span class='alert'>Your head feels mushy.</span>")
				return
			if(H.wear_suit && findtext(H.wear_suit.name,"bedsheet"))
				boutput(H, "<span class='alert'>Darn, just one more page and you would have finished that book.</span>")
				H.alpha = 100
				return
			if(H.shoes && H.w_uniform && H.head && findtext(H.shoes.name, "magic") && findtext(H.w_uniform.name, "birdman") && findtext(H.head.name, "laurels"))
				boutput(H, "<span class='alert'>A heavenly light engulfs you.</span>")
				for (var/mob/M in viewers(H, null))
					M.flash(10 SECONDS)
				H.overlays += image('icons/misc/32x64.dmi',"halo")
				return
			if(H.shoes && H.w_uniform && H.wear_mask && H.head && findtext(H.shoes.name,"magic") && findtext(H.w_uniform.name, "lawyer") && findtext(H.wear_mask.name, "fake") && findtext(H.head.name, "devil"))
				boutput(H, "<span class='alert'>You feel somewhat different.</span>")
				H.color = "#990000"

				return
			if(H.wear_suit && findtext(H.wear_suit.name,"bee"))
				if (H.mind && (H.mind.assigned_role != "Animal") || (!H.mind || !H.client))
					if (H.mind)
						H.mind.assigned_role = "Animal"
				particleMaster.SpawnSystem(new /datum/particleSystem/confetti(H.loc))
				H.unequip_all()
				H.make_critter(/mob/living/critter/small_animal/bee)
				return
			if(H.wear_suit && findtext(H.wear_suit.name,"monkey"))
				H.monkeyize()
				return
			if(H.w_uniform && H.wear_mask && findtext(H.w_uniform.name,"owl") && findtext(H.wear_mask.name,"owl"))
				H.owlgib(1,100)//easiest way to turn someone into an owl
				return
			if(H.head && findtext(H.head.name,"zombie"))
				H.zombify()
				return
			if((H.head && findtext(H.head.name,"cat")) || (H.ears && findtext(H.ears.name, "cat")))
				boutput(H, "<span class='alert'>You feel yourself begin to change into a... superior form.</span>")
				SPAWN_DBG(5 SECONDS)
					H.set_mutantrace(/datum/mutantrace/cat)
				return
			if(H.w_uniform && H.head && findtext(H.w_uniform.name,"mobile") && findtext(H.head.name,"mobile"))
				H.reagents.add_reagent("nanites", INFINITY)
				for(var/reagent in H.reagents.reagent_list)
					if(reagent == "nanites")
						var/datum/reagent/R = H.reagents.reagent_list[reagent]
						R.depletion_rate = 0
			if(H.wear_suit && findtext(H.wear_suit.name,"guardbuddy"))
				var/mob/living/silicon/robot/buddy/B = new /mob/living/silicon/robot/buddy/
				B.set_loc(H.loc)

				H.mind.transfer_to(B)
				H.implode()
				B.set_module(new /obj/item/robot_module/guardbot(B))
			if(H.w_uniform && H.wear_mask && findtext(H.w_uniform.name,"alien") && findtext(H.wear_mask.name,"alien"))
				if (H.mind && (H.mind.assigned_role != "Animal") || (!H.mind || !H.client))
					if (H.mind)
						H.mind.assigned_role = "Animal"
				H.unequip_all()
				H.make_critter(/mob/living/critter/spider/baby)
				return
			if((H.wear_suit && findtext(H.wear_suit.name,"bat")) || (H.wear_mask && findtext(H.wear_mask.name,"bat")) || (H.head && findtext(H.head.name,"bat")))
				if (H.mind && (H.mind.assigned_role != "Animal") || (!H.mind || !H.client))
					if (H.mind)
						H.mind.assigned_role = "Animal"
				H.unequip_all()
				H.make_critter(/mob/living/critter/small_animal/bat)
				return
//guardbuddy moduel for fun
/datum/robot/module_tool_creator/recursive/module/guardbot
	definitions = list(
		/obj/item/device/flash/cyborg,
		/obj/item/handcuffs/guardbot
	)

/obj/item/robot_module/guardbot
	name = "guardbot module"
	desc = "the good ol' flash and cuffs"
	mod_hudicon = "unknown"
	included_tools = /datum/robot/module_tool_creator/recursive/module/guardbot
	radio_type = /obj/item/device/radio/headset/security
#endif
