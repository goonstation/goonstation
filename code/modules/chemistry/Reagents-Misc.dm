//Contains exotic or special reagents.

ABSTRACT_TYPE(/datum/reagent/cement)
ABSTRACT_TYPE(/datum/reagent/concrete)

datum
	reagent
		nitroglycerin // Yes, this is a bad idea.
			name = "nitroglycerin"
			id = "nitroglycerin"
			description = "A miracle worker in treating cardiac failure. Very, very volatile and sensitive compound. Do not run while handling this. Do not throw this. Do not splash this."
			reagent_state = LIQUID
			fluid_r = 220
			fluid_g = 220
			fluid_b = 255
			transparency = 128
			volatility = 3
			minimum_reaction_temperature = -INFINITY
			random_chem_blacklisted = 1

			// These figures are for new nitro explosions
			// brisance = 0.4

			// power = (12.5V)^(2/3)
			// 0.1 -> 1
			// 1 -> 5
			// 10 -> 25
			// 100 -> 116
			// 1000 -> 538

			// explosive properties
			// relatively inert as a solid (T <= 14°C)
			// rather explosive as a liquid (14 °C < T <= 50 °C)
			// explodes instantly as a gas (50 °C < T)

			proc/explode(var/list/covered_turf, expl_reason)
				var/turf/T = pick(covered_turf)
				message_admins("Nitroglycerin explosion (volume = [volume]) due to [expl_reason] at [log_loc(T)].")
				var/context = "???"
				if(holder?.my_atom) // Erik: Fix for Cannot read null.fingerprints_full
					var/list/fh = holder.my_atom.fingerprints_full

					if (length(fh)) //Wire: Fix for: bad text or out of bounds
						context = "Fingerprints: [jointext(fh, "")]"

				logTheThing(LOG_COMBAT, usr, "is associated with a nitroglycerin explosion (volume = [volume]) due to [expl_reason] at [log_loc(T)]. Context: [context].")
				explosion_new(usr, T, (12.5 * min(volume, 1000))**(2/3), 0.4) // Because people were being shit // okay its back but harder to handle // okay sci can have a little radius, as a treat
				holder.del_reagent("nitroglycerin")

			reaction_temperature(exposed_temperature, exposed_volume)
				if (exposed_temperature <= T0C + 14)
					reagent_state = SOLID
				else if (exposed_temperature <= T0C + 50)
					if (reagent_state == SOLID)
						var/delta = exposed_temperature - holder.last_temp
						if (delta > 5 && prob(delta * 5))
							explode(holder.covered_turf(), "rapid thawing")
							return
					reagent_state = LIQUID
				else
					explode(holder.covered_turf(), "temperature change to gaseous form")

			reaction_turf(var/turf/T, var/volume)
				if(reagent_state == LIQUID || prob(2 * volume - min(14 + T0C - holder.total_temperature, 100) * 0.1))
					explode(list(T), "splash on turf")

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume, var/paramslist = 0, var/raw_volume)
				. = ..()
				if(reagent_state == LIQUID || prob(2 * raw_volume - min(14 + T0C - holder.total_temperature, 100) * 0.1))
					explode(list(get_turf(M)), "splash on [key_name(M)]")

			reaction_obj(var/obj/O, var/volume)
				return_if_overlay_or_effect(O)
				if(reagent_state == LIQUID || prob(2 * volume - min(14 + T0C - holder.total_temperature, 100) * 0.1))
					explode(list(get_turf(O)), "splash on [key_name(O)]")

			physical_shock(var/force)
				if (reagent_state == SOLID && force >= 4 && prob(force - min(14 + T0C - holder.total_temperature, 100) * 0.1))
					explode(list(get_turf(holder.my_atom)), "physical trauma (force [force], usr: [key_name(usr)]) in solid state")
				else if (reagent_state == LIQUID && prob(force * 6))
					explode(list(get_turf(holder.my_atom)), "physical trauma (force [force], usr: [key_name(usr)]) in liquid state")

			on_transfer(var/datum/reagents/source, var/datum/reagents/target, var/trans_volume)
				var/datum/reagent/nitroglycerin/target_ng = target.get_reagent("nitroglycerin")
				logTheThing(LOG_COMBAT, usr, "caused physical shock to nitroglycerin by transferring [trans_volume]u from [source.my_atom] to [target.my_atom].")
				// mechanical dropper transfer (1u): solid at 14°C: 0%, liquid: 0%
				// classic dropper transfer (5u): solid at 14°C: 0% (due to min force cap), liquid: 15%
				// beaker transfer (10u): solid at -36°C: 0%, solid: 5%, liquid: 30%
				// the only safe way to transfer nitroglycerin is by freezing it
				// thenagain, it may explode when being thawed unless heated *very* slowly
				target_ng.physical_shock(0.5 * trans_volume)

		copper_nitrate
			name = "copper nitrate"
			id = "copper_nitrate"
			description = "An intermediary which sublimates at 180 °C."
			reagent_state = SOLID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 255
			transparency = 255

		silver_nitrate
			name = "silver nitrate"
			id = "silver_nitrate"
			description = "A versatile precursor with some minor caustic applications."
			reagent_state = SOLID
			fluid_r = 220
			fluid_g = 220
			fluid_b = 220
			transparency = 255
			// silver salts are toxic
			overdose = 10

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				. = ..()
				if (!volume_passed)
					return
				if (!isliving(M))
					return
				if (method == TOUCH)
					var/mob/living/H = M
					var/cauterised
					if (volume_passed >= 10)
						// reduce bleeding
						if (H.bleeding)
							H.bleeding--
							cauterised = 1
						// minor burning
						if (volume_passed >= 50)
							H.TakeDamage("chest", 0, 5, 0, DAMAGE_BURN)
						else
							H.TakeDamage("chest", 0, 2, 0, DAMAGE_BURN)
						if (cauterised)
							boutput(H, SPAN_NOTICE("The silver nitrate burns like hell as it cauterises some of your wounds."))
						else
							boutput(H, SPAN_NOTICE("The silver nitrate burns like hell."))

		silver_fulminate
			name = "silver fulminate"
			id = "silver_fulminate"
			description = "A very volatile mixture that can react given the slightest stimulus."
			reagent_state = SOLID
			fluid_r = 128
			fluid_g = 128
			fluid_b = 128
			minimum_reaction_temperature = -INFINITY

			proc/pop(var/turf/T, var/amount=5)
				playsound(T, 'sound/weapons/Gunshot.ogg', rand(1, min(amount*10, 50)), 1)

			proc/explode()
				var/list/covered = holder.covered_turf()
				for(var/turf/t in covered)
					pop(t, (volume/covered.len))
				// can act as primary explosive
				var/datum/reagents/silver_fulminate_holder = holder
				var/silver_fulminate_volume = volume
				silver_fulminate_holder.del_reagent("silver_fulminate")
				silver_fulminate_holder.temperature_reagents(silver_fulminate_holder.total_temperature + silver_fulminate_volume*20,400,3500,500, 1)

			reaction_temperature(var/exposed_temperature, var/exposed_volume)
				if (exposed_temperature >= T0C + 30)
					explode()
				else
					var/delta = exposed_temperature - holder.last_temp
					if (delta > 5 && prob(delta*5))
						explode()

			reaction_turf(var/turf/T, var/amount)
				// adding a slight delay solely to make silver fulminate foam way more fun
				spawn(rand(0, 5))
					if (src && T)
						pop(T, amount)

			reaction_mob(var/mob/M, var/method=TOUCH, var/amount_passed)
				. = ..()
				if (method == TOUCH)
					pop(get_turf(M), max(amount_passed,0.01))

			reaction_obj(var/obj/O, var/amount)
				pop(get_turf(O), amount)

			physical_shock(var/force)
				if (volume <= holder.total_volume/4) //be somewhat stable to shock if prepared like bang snaps
					if (prob(max(0,force-12)*12)) //safe to run with, but not sprint. 24% chance to pop on your face when thrown
						explode()
				else
					if (prob(force*5))
						explode()

			on_transfer(var/datum/reagents/source, var/datum/reagents/target, var/transferred_volume)
				var/datum/reagent/silver_fulminate/target_silver_fulminate = target.get_reagent("silver_fulminate")
				if (target_silver_fulminate)
					// 10 or more units in one place explode
					if (target_silver_fulminate.volume >= 10)
						target_silver_fulminate.explode()
					else
						// transferring single units is safe, anything more has a decent chance of reacting
						target_silver_fulminate.physical_shock(round(0.45 * transferred_volume))

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (probmult(volume))
					explode()
				..()
				return

		aranesp
			name = "aranesp"
			id = "aranesp"
			description = "An illegal performance enhancing drug. Side effects might include chest pain, seizures, swelling, headache, fever... ... ..."
			fluid_r = 120
			fluid_g = 255
			fluid_b = 240
			transparency = 215
			value = 41 // 17 18 6
			viscosity = 0.4
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "aranesp", 15)
					M.add_stam_mod_max("aranesp", 25)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "aranesp")
					M.remove_stam_mod_max("aranesp")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (prob(90))
					M.take_toxin_damage(1 * mult)
				if (probmult(5)) M.emote(pick("twitch", "shake", "tremble","quiver", "twitch_v"))
				if (probmult(8)) boutput(M, SPAN_NOTICE("You feel [pick("really buff", "on top of the world","like you're made of steel", "energized", "invigorated", "full of energy")]!"))
				if (prob(5))
					boutput(M, SPAN_ALERT("You cannot breathe!"))
					M.setStatusMin("stunned", 2 SECONDS * mult)
					M.take_oxygen_deprivation(15 * mult)
					M.losebreath += (1 * mult)
				..()
				return

		anti_fart
			name = "simethicone"
			id = "anti_fart"
			description = "This strange liquid seems to have no bubbles on the surface."
			reagent_state = LIQUID

		honk_fart
			name = "honkfartium"
			id = "honk_fart"
			description = "This always-bubbling liquid looks pretty funny."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 182
			fluid_b = 193
			transparency = 200

		//new name for old stimulants
		omegazine
			name = "omegazine"
			id = "omegazine"
			description = "A dangerous chemical that allows for seemingly superhuman feats for a short time ..."
			random_chem_blacklisted = 1
			reagent_state = LIQUID
			fluid_r = 120
			fluid_g = 0
			fluid_b = 140
			transparency = 200
			value = 66 // vOv
			//addiction_prob = 25
			stun_resist = 100
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "omegazine", 500)
					M.add_stam_mod_max("omegazine", 500)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "omegazine")
					M.remove_stam_mod_max("omegazine")
				..()

			on_mob_life(var/mob/living/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (src.volume > 5)
					if (M.get_oxygen_deprivation())
						M.take_oxygen_deprivation(-5 * mult)
					if (M.get_toxin_damage())
						M.take_toxin_damage(-5 * mult)
					M.delStatus("slowed")
					M.delStatus("disorient")
					if (M.misstep_chance)
						M.change_misstep_chance(-INFINITY)
					M.HealDamage("All", 10 * mult, 10 * mult)
					M.dizziness = max(0,M.dizziness-10)
					M.changeStatus("drowsy", -20 SECONDS)
					M.sleeping = 0
				else
					M.take_toxin_damage(2 * mult)
					random_brute_damage(M, 1 * mult)
					if (probmult(10))
						M.setStatusMin("stunned", 4 SECONDS)
				..()
				return

		hairgrownium //It..grows hair.  Not to be confused with the previous hair growth reagent, "wacky monkey cheeseonium"
			name = "hairgrownium"
			id = "hairgrownium"
			description = "A mysterious chemical purported to help grow hair. Often found on late-night TV infomercials."
			fluid_r = 100
			fluid_b = 100
			fluid_g = 255
			transparency = 205
			penetrates_skin = 1 // why wouldn't it, really
			value = 20 // 2 9 9
			viscosity = 0.2

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				if (probmult(10) && ishuman(M))
					var/mob/living/carbon/human/H = M
					var/list/hair_styles = pick(get_available_custom_style_types(M.client, no_gimmick_hair=TRUE))
					var/hair_type = pick(hair_styles)
					H.bioHolder.mobAppearance.customizations["hair_bottom"].style =  new hair_type
					hair_type = pick(hair_styles)
					H.bioHolder.mobAppearance.customizations["hair_middle"].style =  new hair_type
					hair_type = pick(hair_styles)
					H.bioHolder.mobAppearance.customizations["hair_top"].style =  new hair_type
					H.update_colorful_parts()
					boutput(H, SPAN_NOTICE("Your scalp feels itchy!"))
				..()
				return

		super_hairgrownium //moustache madness
			name = "super hairgrownium"
			id = "super_hairgrownium"
			description = "A mysterious and powerful chemical purported to cause rapid hair growth."
			fluid_r = 100
			fluid_b = 100
			fluid_g = 255
			transparency = 205
			penetrates_skin = 1 // why wouldn't it, really
			value = 34 // 20 13 1
			viscosity = 0.3

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				if (ishuman(M))
					var/somethingchanged = 0
					var/mob/living/carbon/human/H = M
					if (H.bioHolder.mobAppearance.customizations["hair_bottom"].style.id != "80s")
						H.bioHolder.mobAppearance.customizations["hair_bottom"].style =  new /datum/customization_style/hair/long/eighties
						somethingchanged = 1
					if (H.gender == MALE && H.bioHolder.mobAppearance.customizations["hair_middle"].style.id != "longbeard")
						H.bioHolder.mobAppearance.customizations["hair_middle"].style =  new /datum/customization_style/beard/longbeard
						somethingchanged = 1
					if (!(H.wear_mask && istype(H.wear_mask, /obj/item/clothing/mask/moustache)) && volume >= 3)
						somethingchanged = 1
						for (var/obj/item/clothing/O in H)
							if (istype(O,/obj/item/clothing/mask))
								H.u_equip(O)
								if (O)
									O.set_loc(H.loc)
									O.dropped(H)
									O.layer = initial(O.layer)

						var/obj/item/clothing/mask/moustache/moustache = new /obj/item/clothing/mask/moustache(H)
						H.equip_if_possible(moustache, SLOT_WEAR_MASK)
						H.set_clothing_icon_dirty()
						holder?.remove_reagent(src.id, 3)
					if (somethingchanged) boutput(H, SPAN_ALERT("Hair bursts forth from every follicle on your head!"))
					H.update_colorful_parts()
				..()
				return

		unstable_omega_hairgrownium
			name = "unstable omega hairgrownium"
			id = "unstable_omega_hairgrownium"
			description = "An unstable variation of a mysterious extremely powerful chemical purported to help grow unusual hair. This one is bubbling intensely."
			fluid_r = 40
			fluid_b = 40
			fluid_g = 255
			transparency = 205
			penetrates_skin = 1
			value = 61 // 20 34 3 1 3
			viscosity = 0.2

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				if (probmult(35) && ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.reagents && H.reagents.has_reagent("stable_omega_hairgrownium"))
						omega_hairgrownium_drop_hair(H)
					else
						omega_hairgrownium_grow_hair(H, all_hairs=TRUE)
				..()
				return

		stable_omega_hairgrownium
			name = "stable omega hairgrownium"
			id = "stable_omega_hairgrownium"
			description = "A mysterious extremely powerful chemical purported to help grow unusual hair."
			fluid_r = 140
			fluid_b = 140
			fluid_g = 255
			transparency = 205
			penetrates_skin = 1
			value = 59 // 20 34 3 1 1
			viscosity = 0.2

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				if (probmult(35) && ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.reagents && H.reagents.has_reagent("unstable_omega_hairgrownium"))
						omega_hairgrownium_drop_hair(H)
					else
						omega_hairgrownium_grow_hair(H, 0)
				..()
				return

		anima //This stuff is not done. Don't use it. Don't spoil it.
			name = "anima"
			id = "anima"
			description = "Anima ... The animating force of the universe."
			reagent_state = LIQUID
			fluid_r = 120
			fluid_g = 10
			fluid_b = 190
			transparency = 255
			depletion_rate = 0.05
			value = 539 // 2 3 28 6 500
			viscosity = 0.4
			// last number: for 50u you take 100 points of health (assuming this is the first time it's been made by those people) so 2 points per 1u
			// that number is the value of those 2 points

			on_add()
				// Marq fix for cannot read null.my_atom
				if (!holder)
					return
				var/atom/A = holder.my_atom
				if (A)
					animate_flash_color_fill(A,"#5C0E80",-1, 10)

				if (hascall(holder.my_atom,"addOverlayComposition"))
					holder.my_atom:addOverlayComposition(/datum/overlayComposition/anima)

				if (ismob(A))
					if (!particleMaster.CheckSystemExists(/datum/particleSystem/swoosh, A))
						particleMaster.SpawnSystem(new /datum/particleSystem/swoosh/endless(A))
				return

			on_remove()
				var/atom/A = holder.my_atom
				if (A)
					animate_flash_color_fill(A,"#5C0E80", 1, 10)

				if (hascall(holder.my_atom,"removeOverlayComposition"))
					holder.my_atom:removeOverlayComposition(/datum/overlayComposition/anima)

				if (ismob(A))
					particleMaster.RemoveSystem(/datum/particleSystem/swoosh, A)

				return

			reaction_obj(var/obj/O, var/volume)
				if (volume < 5 || istype(O, /obj/critter) || istype(O, /obj/machinery/bot) || istype(O, /obj/decal) || O.anchored || O.invisibility) return
				return_if_overlay_or_effect(O)
				O.visible_message(SPAN_ALERT("The [O] comes to life!"))
				new /mob/living/object/ai_controlled(get_turf(O), O)

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (probmult(8))
					boutput(M, SPAN_ALERT("The voices ..."))
					M.playsound_local(M, pick(ghostly_sounds), 100, 1)
				..()

		strange_reagent
			name = "strange reagent"
			id = "strange_reagent"
			description = "A glowing green fluid highly reminiscent of nuclear waste."
			reagent_state = LIQUID
			fluid_r = 160
			fluid_g = 232
			fluid_b = 94
			transparency = 255
			depletion_rate = 0.2
			value = 28 // 3 3 22
			viscosity = 0.5
			on_add()
				..()
				if(ismob(src.holder?.my_atom))
					RegisterSignal(holder.my_atom, COMSIG_MOB_SHOCKED_DEFIB, PROC_REF(revive))

			on_remove()
				..()
				UnregisterSignal(holder.my_atom, COMSIG_MOB_SHOCKED_DEFIB)

			proc/revive(source)
				var/mob/living/M = source
				var/volume_passed = holder.get_reagent_amount("strange_reagent")
				if (!iscarbon(M) && !ismobcritter(M))
					return
				if (!volume_passed)
					return
				if (volume_passed < 1)
					return
				if (isdead(M) || istype(get_area(M),/area/afterlife/bar))
					var/came_back_wrong = 0
					if (M.get_brute_damage() + M.get_burn_damage() >= 150)
						came_back_wrong = 1
					if (ismobcritter(M))
						M.full_heal() // same as with objcritters basically
					else
						M.take_oxygen_deprivation(-INFINITY)
						M.take_toxin_damage(rand(0,15))
						M.TakeDamage("chest", rand(0,15), rand(0,15), 0, DAMAGE_CRUSH)
						setalive(M)
					var/mob/G
					if (ishuman(M)) // if they're human, let's get whoever owns the brain
						var/mob/living/carbon/human/H = M
						var/obj/item/organ/brain/B = H.organHolder?.get_organ("brain")
						G = find_ghost_by_key(B?.owner?.key)
						var/is_puritan = 0
						if(ismob(G))
							for (var/trait as anything in G?.client.preferences.traitPreferences.traits_selected)
								if(trait == "puritan")
									is_puritan = 1
						if(H.traitHolder.hasTrait("puritan"))
							is_puritan = 1
						if (came_back_wrong || H.decomp_stage || G?.mind?.get_player()?.dnr || is_puritan) //Wire: added the dnr condition here
							H.visible_message(SPAN_ALERT("<B>[H]</B> starts convulsing violently!"))
							if (G?.mind?.get_player()?.dnr)
								H.visible_message(SPAN_ALERT("<b>[H]</b> seems to prefer the afterlife!"))
							H.make_jittery(1000)
							SPAWN(rand(20, 100))
								logTheThing(LOG_COMBAT, H, "is gibbed by puritan when resuscitated with strange reagent at [log_loc(H)].")
								H.gib()
							return
					else // else just get whoever's the mind
						G = find_ghost_by_key(M.mind?.key)
					logTheThing(LOG_COMBAT, M, "is resuscitated with strange reagent at [log_loc(M)].")
					if (G)
						if (!isdead(G)) // so if they're in VR, the afterlife bar, or a ghostcritter
							G.show_text(SPAN_NOTICE("You feel yourself being pulled out of your current plane of existence!"))
							G.ghostize()?.mind?.transfer_to(M)
						else
							G.show_text(SPAN_ALERT("You feel yourself being dragged out of the afterlife!"))
							G.mind?.transfer_to(M)
						qdel(G)
						M.visible_message(SPAN_ALERT("<b>[M]</b> seems to rise from the dead!"),SPAN_ALERT("You feel hungry..."))
					else
						M.visible_message(SPAN_ALERT("<b>[M]</b> shudders and stares vacantly."))
				return

			reaction_obj(var/obj/O, var/volume)
				if (istype(O, /obj/critter))
					var/obj/critter/critter = O
					if (!critter.alive && critter.can_revive) //I should probably check for organic critters, but most robotic ones just blow up on death
						critter.health = initial(critter.health)
						critter.alive = 1
						critter.icon_state = initial(critter.icon_state)
						critter.set_density(initial(critter.density))
						critter.on_revive()
						critter.visible_message(SPAN_ALERT("[critter] seems to rise from the dead!"))

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				if (prob(10))
					M.take_toxin_damage(2 * mult)
					random_brute_damage(M, 2 * mult)

				..()
				return

		fffoam
			name = "firefighting foam"
			id = "ff-foam"
			description = "Carbon tetrachloride is used for fire suppression."
			reagent_state = LIQUID
			fluid_r = 195
			fluid_g = 195
			fluid_b = 175
			transparency = 200
			value = 3 // 1 1 1
			viscosity = 0.14

			reaction_turf(var/turf/target, var/volume)
				var/list/hotspots = list()
				for (var/atom/movable/hotspot/hotspot in target)
					hotspots += hotspot
				if (length(hotspots))
					if (istype(target, /turf/simulated))
						var/turf/simulated/T = target
						if (T.air)
							var/datum/gas_mixture/lowertemp = T.remove_air( TOTAL_MOLES(T.air) )
							if (lowertemp)
								lowertemp.temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST - 200 //T0C - 100
								lowertemp.toxins = max(lowertemp.toxins-50,0)
								lowertemp.react()
								T.assume_air(lowertemp)
					for (var/atom/movable/hotspot/hotspot as anything in hotspots)
						qdel(hotspot)

				var/obj/fire_foam/F = (locate(/obj/fire_foam) in target)
				if (!F)
					F = new /obj/fire_foam
					F.set_loc(target)
					SPAWN(20 SECONDS)
						if (F && !F.disposed)
							qdel(F)
				return

			reaction_obj(var/obj/item/O, var/volume)
				if (istype(O))
					if (O.burning)
						O.combust_ended()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if (method == TOUCH)
					var/mob/living/L = M
					if (istype(L) && L.getStatusDuration("burning"))
						L.changeStatus("burning", -30 SECONDS)
						playsound(L, 'sound/impact_sounds/burn_sizzle.ogg', 50, TRUE, pitch = 0.8)
					if (istype(L,/mob/living/critter/fire_elemental) && !ON_COOLDOWN(L, "fire_elemental_fffoam", 5 SECONDS))
						L.emote("scream")
						for(var/mob/O in AIviewers(M, null))
							O.show_message(SPAN_ALERT("<b>[M] sputters and begins to dim!</b>"), 1)
							boutput(L, SPAN_ALERT("The foam starts to smother your flames!"))
						L.changeStatus("knockdown", 2 SECONDS)
						L.force_laydown_standup()
						var/brutedmg = volume * 1.5 //elementals take 1.15x damage, 65 is 74.75. 2 maxcap pitchers goes to .50 brute under death.
						brutedmg = min(brutedmg, 65) //Ideally acts like vampire with holy water, capping it so they don't instadie.
						L.TakeDamage("chest", brutedmg, 0, 0, DAMAGE_BLUNT) //120u pitcher of fffoam instantly killed elementals, lol.
						playsound(L, 'sound/impact_sounds/burn_sizzle.ogg', 50, TRUE, pitch = 0.5)
				return

			grenade_effects(var/obj/grenade, var/atom/A)
				if (isliving(A))
					var/mob/living/M = A
					if (M.hasStatus("burning"))
						M.delStatus("burning")

		silicate
			name = "silicate"
			id = "silicate"
			description = "A compound that can be used to reinforce glass."
			reagent_state = LIQUID
			fluid_r = 38
			fluid_g = 128
			fluid_b = 191
			value = 3 // 1 1 1
			viscosity = 0.4

			reaction_obj(var/obj/O, var/volume)
				if (istype(O, /obj/window))
					var/obj/window/W = O

					// Silicate was broken. I fixed it (Convair880).
					var/static/max_reinforce = 500
					if (W.health >= max_reinforce)
						return
					var/do_reinforce = W.health * 2
					if ((W.health + do_reinforce) > max_reinforce)
						do_reinforce = max(0, (max_reinforce - W.health))
					W.health += do_reinforce
					W.health_max = W.health

					var/icon/I = icon(W.icon)
					I.ColorTone( rgb(165,242,243) )
					W.icon = I
					src.holder.remove_reagent(src.id, src.holder.get_reagent_amount(src.id))

		graphene
			name = "graphene"
			id = "graphene"
			description = "A miniscule honeycomb lattice."
			reagent_state = SOLID
			fluid_r = 20
			fluid_g = 20
			fluid_b = 20
			value = 5

		graphene_compound
			name = "Graphene Hardening Compound"
			id = "graphene_compound"
			description = "A thick industrial compound used to reinforce things."
			reagent_state = LIQUID
			fluid_r = 10
			fluid_g = 10
			fluid_b = 10
			transparency = 180
			viscosity = 0.8
			value = 9

			reaction_obj(var/obj/O, var/volume)
				if (volume < 1)
					return

				var/colorize
				if (istype(O,/obj/machinery/atmospherics/pipe/simple))
					var/obj/machinery/atmospherics/pipe/simple/P = O

					if(P.can_rupture)
						var/max_reinforcement = 1e9
						if(P.fatigue_pressure >= max_reinforcement)
							return

						P.fatigue_pressure = clamp(P.fatigue_pressure * (2**volume), initial(P.fatigue_pressure), max_reinforcement)
						colorize = TRUE

				else if (istype(O,/obj/window))
					var/obj/window/W = O
					var/initial_resistance = initial(W.explosion_resistance)
					W.explosion_resistance = clamp(W.explosion_resistance + volume, initial_resistance, initial_resistance + 3)
					colorize = TRUE

				if(colorize)
					var/icon/I = icon(O.icon)
					I.ColorTone( rgb(20, 30, 30) )
					O.icon = I
					O.setTexture("hex_lattice", BLEND_ADD, "hex_lattice")
					O.visible_message(SPAN_ALERT("[O] is reinforced by the compound."))
				return

			reaction_turf(var/turf/target, var/volume)
				var/list/covered = holder.covered_turf()
				var/turf/simulated/wall/T = target
				var/volume_mult = 1

				if (length(covered))
					if (volume/length(covered) < 2) //reduce effect based on dilution
						volume_mult = min(volume / 9, 1)

				if(istype(T))
					var/initial_resistance = initial(T.explosion_resistance)
					T.explosion_resistance = clamp(T.explosion_resistance + (volume_mult*volume), initial_resistance, initial_resistance + 5)
					var/icon/I = icon(T.icon)
					I.ColorTone( rgb(20, 30, 30) )
					T.icon = I
					T.setTexture("hex_lattice", BLEND_ADD, "hex_lattice")
					T.visible_message(SPAN_ALERT("[T] is reinforced by the compound."))


//foam precursor

		fluorosurfactant
			name = "fluorosurfactant"
			id = "fluorosurfactant"
			description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 255
			fluid_b = 255
			transparency = 30
			value = 5 // 3 1 1

		lube
			name = "space lube"
			id = "lube"
			description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_b = 245
			fluid_g = 255
			value = 3 // 1 1 1
			hygiene_value = 0.25
			block_slippy = -1

			reaction_turf(var/turf/target, var/volume)
				if (istype(target, /turf/simulated))
					var/turf/simulated/simulated_target = target
					simulated_target.wetify(2, 60 SECONDS)

		superlube
			name = "organic superlubricant"
			id = "superlube"
			description = "Organic superlube is great stuff, but it'll try and slide away from you the first chance it gets."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_b = 245
			fluid_g = 255
			value = 4 // 1 1 1
			hygiene_value = 0.25
			block_slippy = -2
			var/visible = 1

			reaction_turf(var/turf/target, var/volume)
				if (istype(target, /turf/simulated))
					var/turf/simulated/simulated_target = target
					if (visible)
						simulated_target.wetify(3, 60 SECONDS)
					else
						simulated_target.wetify(3, 60 SECONDS, null, TRUE)

			invisible
				name = "invisible organic superlubricant"
				id = "invislube"
				visible = 0

		slime
			name = "slug slime"
			id = "slime"
			description = "Gross goop that sticks to everything it touches."
			reagent_state = LIQUID
			depletion_rate = 0.6
			fluid_r = 116
			fluid_b = 73
			fluid_g = 226
			transparency = 180
			viscosity = 0.8
			block_slippy = 1

			reaction_turf(var/turf/target, var/volume)
				if (istype(target, /turf/simulated))
					var/turf/simulated/simulated_target = target
					simulated_target.wetify(-1, 60 SECONDS, rgb(116,226,73))

		glue
			name = "space glue"
			id = "spaceglue"
			description = "Industrial superglue that is sure to stick to everything."
			reagent_state = LIQUID
			depletion_rate = 0.6
			fluid_r = 230
			fluid_b = 60
			fluid_g = 230
			transparency = 180
			viscosity = 0.8
			block_slippy = 1
			var/counter

			reaction_turf(var/turf/target, var/volume)
				if (istype(target, /turf/simulated))
					var/turf/simulated/simulated_target = target
					simulated_target.wetify(-2, 60 SECONDS)

			on_mob_life(var/mob/M, var/mult = 1, var/method, var/volume_passed)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				switch(counter += (1 * mult))
					if(20 to INFINITY)
						M.druggy = max(M.druggy, 15)
						if (M.canmove && prob(20))
							M.change_misstep_chance(5 * mult)
						if(probmult(5)) M.emote(pick("twitch","drool","moan"))

				..()
				return

			reaction_obj(obj/O, volume)
				if(volume < 5)
					return
				if(isgrab(O))
					return
				if(O.GetComponent(/datum/component/glued) || O.GetComponent(/datum/component/glue_ready))
					return
				if(O.invisibility >= INVIS_ALWAYS_ISH)
					return
				var/silent = FALSE
				var/list/covered = holder.covered_turf()
				if (length(covered) > 5)
					silent = TRUE
				volume /= max(length(covered), 1)
				if(istype(holder, /datum/reagents/fluid_group))
					volume = min(volume, src.volume / (2 + 3 / length(covered)))
				if(volume < 5)
					return
				O.AddComponent(/datum/component/glue_ready, volume * 20 SECONDS, 5 SECONDS)
				var/turf/T = get_turf(O)
				if(!silent)
					T.visible_message(SPAN_NOTICE("\The [O] is coated in a layer of glue!"))
				if(istype(holder, /datum/reagents/fluid_group))
					holder.remove_reagent(src.id, min(volume, src.volume - 4))

// metal foaming agent
// this is lithium hydride. Add other recipies (e.g. MiH + H2O -> MiOH + H2) eventually

// two different foaming agents is overly complicated imo - IM

		/*foaming_agent
			name = "foaming agent"
			id = "foaming_agent"
			description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
			reagent_state = SOLID
			fluid_r = 100
			fluid_g = 90
			fluid_b = 90
			transparency = 255*/

		ammonia
			name = "ammonia"
			id = "ammonia"
			description = "A caustic substance commonly used in fertilizer or household cleaners."
			reagent_state = GAS
			fluid_r = 255
			fluid_g = 255
			fluid_b = 180
			transparency = 75
			value = 2 // 1c + 1c
			hygiene_value = 0.25

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.growth_rate += 4
				growth_tick.health_change += 0.66
				growth_tick.water_consumption += 4

		diethylamine
			name = "diethylamine"
			id = "diethylamine"
			description = "A secondary amine, useful as a plant nutrient and as building block for other compounds."
			reagent_state = LIQUID
			fluid_r = 60
			fluid_g = 50
			fluid_b = 0
			transparency = 255
			value = 4 // 2c + 1c + heat

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.growth_rate += 1.23

		acetone
			name = "acetone"
			id = "acetone"
			description = "Pure 100% nail polish remover, also works as an industrial solvent."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 200
			transparency = 20
			value = 5 // 3c + 1c + 1c
			hygiene_value = 0.75

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_toxin_damage(1.5 * mult)
				..()
				return

			proc/unglue_attached_to(atom/A)
				var/atom/Aloc = isturf(A) ? A : A.loc
				for(var/atom/movable/AM in Aloc)
					var/datum/component/glued/glued_comp = AM.GetComponent(/datum/component/glued)
					// possible idea for a future change: instead of direct deletion just decrease dries_up_time and only delete if <= current time
					if(glued_comp?.glued_to == A && !isnull(glued_comp.glue_removal_time))
						qdel(glued_comp)

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume, var/paramslist = 0, var/raw_volume)
				. = ..()
				if (method == TOUCH)
					remove_stickers(M, raw_volume)
				unglue_attached_to(M)

			reaction_obj(var/obj/O, var/volume)
				remove_stickers(O, volume)
				var/datum/component/glued/glued_comp = O.GetComponent(/datum/component/glued)
				if(glued_comp)
					qdel(glued_comp)
				var/datum/component/glue_ready/glue_ready_comp = O.GetComponent(/datum/component/glue_ready)
				if(glue_ready_comp)
					qdel(glue_ready_comp)
				unglue_attached_to(O)

			reaction_turf(var/turf/T, var/volume)
				remove_stickers(T, volume)
				unglue_attached_to(T)

			proc/remove_stickers(var/atom/target, var/volume)
				var/can_remove_amt = volume / 10
				var/removed_count = 0
				if ((istype(target, /turf/simulated/wall) || istype(target, /turf/unsimulated/wall)))
					target = locate_sticker_wall(target)
					if (!target)
						return

				for (var/atom/A as anything in target)
					if (A.event_handler_flags & HANDLE_STICKER)
						if (A:active)
							target.visible_message(SPAN_ALERT("<b>[A]</b> dissolves completely!"))
							qdel(A)
							removed_count++
					if (removed_count > can_remove_amt)
						break

			//when a sticker is placed on a wall, its loc is actually set to the floor in front of the wall to prevent cameras seeing through walls. use this proc to find it!
			proc/locate_sticker_wall(var/turf/T)
				for (var/turf/turf in range(1,T))
					for (var/obj/item/sticker/S in turf)
						if (S.attached == T || S.attached.loc == T)
							return T
				return 0

		stabiliser
			name = "stabilising agent"
			id = "stabiliser"
			description = "A chemical that stabilises normally volatile compounds, preventing them from reacting immediately."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 0
			transparency = 255
			value = 3 // 1c + 1c + 1c

		ectoplasm
			name = "ectoplasm"
			id = "ectoplasm"
			description = "A bizarre gelatinous substance supposedly derived from ghosts."
			reagent_state = LIQUID
			fluid_r = 179
			fluid_g = 225
			fluid_b = 151
			transparency = 175
			value = 3
			viscosity = 0.4

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				if ((holder.get_reagent_amount(src.id) >= 10) && probmult(8))
					var/Message = rand(1,6)
					switch(Message)
						if (1)
							boutput(M, SPAN_ALERT("You shudder as if cold..."))
							M.emote("shiver")
						if (2)
							boutput(M, SPAN_ALERT("You feel something gliding across your back..."))
						if (3)
							boutput(M, SPAN_ALERT("Your eyes twitch, you feel like something you can't see is here..."))
						if (4)
							boutput(M, SPAN_ALERT("You notice something moving out of the corner of your eye, but nothing is there..."))
						if (5)
							boutput(M, SPAN_ALERT("You feel uneasy."))
						if (6)
							boutput(M, SPAN_ALERT("You've got the heebie-jeebies."))

					if (probmult(1))
						for (var/obj/W in orange(5,M))
							if (prob(25) && !W.anchored)
								step_rand(W)
				..()

			reaction_turf(var/turf/T, var/volume)
				if (volume >= 10)
					if (locate(/obj/item/reagent_containers/food/snacks/ectoplasm) in T) return
					new /obj/item/reagent_containers/food/snacks/ectoplasm(T)

		space_fungus
			name = "space fungus"
			id = "space_fungus"
			description = "Scrapings of some unknown fungus found growing on the station walls."
			reagent_state = SOLID
			fluid_r = 200
			fluid_g = 125
			fluid_b = 40
			transparency = 255
			value = 2
			hygiene_value = -0.5
			viscosity = 0.55


			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.endurance_bonus += 0.5

		cryostylane
			name = "cryostylane"
			id = "cryostylane"
			description = "An incredibly cold substance.  Used in many high-demand cooling systems."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 220
			transparency = 200
			value = 3 // 1 1 1
			viscosity = 0.35
			heat_capacity = 600

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed,var/list/paramslist = 0)
				. = ..()
				if (isobserver(M))
					return

				var/silent = 0
				if (length(paramslist))
					if ("silent" in paramslist)
						silent = 1

				var/list/covered = holder.covered_turf()
				if (length(covered) > 3)
					silent = 1

				if (method == TOUCH)
					var/mob/living/L = M
					if (istype(L) && L.getStatusDuration("burning"))
						L.delStatus("burning")
					if(!M.is_cold_resistant() || ischangeling(M))
						M.bodytemperature=max(M.bodytemperature-volume_passed*2, 0)
						volume_passed *= 0.75 //1 quarter of the chilling is done immidiately on touch reactions
				if ((world.time > M.last_cubed + 5 SECONDS) && M.bioHolder)
					if ((!M.is_cold_resistant() || ischangeling(M)) && isturf(M.loc) )
						if (silent && volume_passed < 1)
							if (prob(volume_passed*100))
								cube_mob(M,volume_passed)
						else
							cube_mob(M,volume_passed)
				return

			proc/cube_mob(var/mob/M, var/volume_passed)
				var/obj/icecube/I = new/obj/icecube(get_turf(M), M)
				I.health = clamp(volume_passed/2, 1, 10)
				//M.bodytemperature = 0

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (M.bodytemperature > 0 && !M.hasStatus("burning"))
					M.bodytemperature = max(M.bodytemperature-(10 * mult),0)
				..()
				return

			reaction_turf(var/turf/target, var/volume)
				if (volume >= 3)
					if (locate(/obj/decal/icefloor) in target) return
					var/obj/decal/icefloor/B = new /obj/decal/icefloor(target)
					SPAWN(80 SECONDS)
						if (B)
							B.dispose()

				var/list/hotspots = list()
				for (var/atom/movable/hotspot/hotspot in target)
					hotspots += hotspot
				if (length(hotspots))
					if (istype(target, /turf/simulated))
						var/turf/simulated/T = target
						if (!T.air) return //ZeWaka: Fix for TOTAL_MOLES(null)
						var/datum/gas_mixture/lowertemp = T.remove_air( TOTAL_MOLES(T.air) )
						if (lowertemp) //ZeWaka: Fix for null.temperature
							lowertemp.temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST - 200 //T0C - 100
							lowertemp.toxins = max(lowertemp.toxins-50,0)
							lowertemp.react()
							T.assume_air(lowertemp)
					for (var/atom/movable/hotspot/hotspot as anything in hotspots)
						qdel(hotspot)

				return

		booster_enzyme
			name = "booster enzyme"
			id = "booster_enzyme"
			description = "This booster enzyme helps the body to replicate beneficial chemicals."
			reagent_state = LIQUID
			fluid_r = 127
			fluid_g = 160
			fluid_b = 192
			transparency = 255
			viscosity = 0.15
			depletion_rate = 1
			var/static/list/booster_enzyme_reagents_to_check = list("charcoal","synaptizine","styptic_powder","teporone","salbutamol","methamphetamine","omnizine","perfluorodecalin","penteticacid","oculine","epinephrine","mannitol","synthflesh", "saline", "anti_rad", "salicylic_acid", "menthol", "silver_sulfadiazine"/*,"coffee", "sugar", "espresso", "energydrink", "ephedrine", "crank"*/) //these last ones are probably an awful idea. Uncomment to buff booster a decent amount

			on_mob_life(var/mob/M, var/mult = 1)
				for (var/i = 1, i <= booster_enzyme_reagents_to_check.len, i++)
					var/check_amount = holder.get_reagent_amount(booster_enzyme_reagents_to_check[i])
					if (check_amount && check_amount < 18)
						var/amt = min(1 * src.calculate_depletion_rate(M, mult), 20-check_amount)
						holder.add_reagent(booster_enzyme_reagents_to_check[i], amt, temp_new = holder.total_temperature + 20)
						holder.add_reagent("enzymatic_leftovers", amt/2, temp_new = holder.total_temperature + 20)
				..()
				return

		space_cleaner // COGWERKS CHEM REVISION PROJECT. ethanol, ammonia + water - treat like a shitty version of windex
			name = "space cleaner"
			id = "cleaner"
			description = "A compound used to clean things. It has a sharp, unpleasant odor." // cogwerks- THIS IS NOT BLEACH ARGHHHH
			reagent_state = LIQUID
			fluid_r = 110
			fluid_g = 220
			fluid_b = 220
			transparency = 150
			overdose = 5
			value = 4 // 2 1 1
			hygiene_value = 3
			blob_damage = 1

			reaction_obj(var/obj/O, var/volume)
				if (!isnull(O))
					O.clean_forensic()

			reaction_turf(var/turf/T, var/volume)
				T.clean_forensic()

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				..()
				if(method == TOUCH)
					M.clean_forensic()
					M.delStatus("marker_painted")

		luminol // OOC. Weaseldood. oh that stuff from CSI, the glowy blue shit that they spray on blood
			name = "luminol"
			id = "luminol"
			description = "A chemical that can detect trace amounts of blood."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 204
			transparency = 150
			fluid_flags = FLUID_BANNED

			reaction_turf(var/turf/T, var/volume)
				for (var/obj/decal/bloodtrace/B in T)
					B.invisibility = INVIS_NONE
					SPAWN(30 SECONDS)
						B?.invisibility = INVIS_ALWAYS
				for (var/obj/item/I in T)
					if (I.get_forensic_trace("bDNA"))
						var/image/blood_overlay = image('icons/obj/decals/blood/blood.dmi', "itemblood")
						blood_overlay.appearance_flags = PIXEL_SCALE | RESET_COLOR
						blood_overlay.color = "#3399FF"
						blood_overlay.alpha = 100
						blood_overlay.blend_mode = BLEND_INSET_OVERLAY
						I.appearance_flags |= KEEP_TOGETHER
						I.UpdateOverlays(blood_overlay, "blood_traces")
						SPAWN(30 SECONDS)
							I?.appearance_flags &= ~KEEP_TOGETHER
							I?.UpdateOverlays(null, "blood_traces")

		oil
			name = "oil"
			id = "oil"
			description = "A decent lubricant for machines. High in benzene, naphtha and other hydrocarbons."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			transparency = 255
			hygiene_value = -1.5
			value = 3 // 1c + 1c + 1c
			viscosity = 0.13
			volatility = 1
			minimum_reaction_temperature = T0C + 200
			var/min_req_fluid = 0.25 //at least 1/4 of the fluid needs to be oil for it to ignite

			reaction_temperature(exposed_temperature, exposed_volume)
				if (!src.reacting && (holder && !holder.has_reagent("chlorine"))) // need this to be higher to make propylene possible
					src.reacting = 1
					var/list/covered = holder.covered_turf()
					if (length(covered) < 4 || (volume / holder.total_volume) > min_req_fluid)
						for(var/turf/location in covered)
							fireflash(location, clamp(volume/40, 0, 8), chemfire = CHEM_FIRE_RED)
							if (length(covered) < 4 || prob(10))
								location.visible_message("<b>The oil burns!</b>")
								var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
								smoke.set_up(1, 0, location)
								smoke.start()
					if (holder)
						holder.add_reagent("ash", round(src.volume/2), null)
						holder.del_reagent(id)

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if (volume)
					if (method == TOUCH)
						if (isrobot(M))
							var/mob/living/silicon/robot/R = M
							R.changeStatus("freshly_oiled", (volume * 5)) // You need at least 30u to get max duration
							boutput(R, SPAN_NOTICE("Your joints and servos begin to run more smoothly."))
						else if (ishuman(M))
							var/mob/living/carbon/human/H = M
							if (!H.mutantrace?.aquaphobic)
								boutput(M, "<span class='alert'>You feel greasy and gross.</span>")

				return

			reaction_turf(var/turf/target, var/volume)
				var/turf/simulated/T = target
				if (istype(T)) //Wire: fix for Undefined variable /turf/space/var/wet (&& T.wet)
					if (T.wet >= 2) return
					T.wetify(2, 20 SECONDS)
					if (!locate(/obj/decal/cleanable/oil) in T)
						playsound(T, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, TRUE)
						switch(volume)
							if (0 to 0.5)
								if (prob(volume * 10))
									make_cleanable(/obj/decal/cleanable/oil/streak,T)
							if (5 to 19)
								make_cleanable(/obj/decal/cleanable/oil/streak,T)
							if (20 to INFINITY)
								make_cleanable(/obj/decal/cleanable/oil,T)

		capulettium
			name = "capulettium"
			id = "capulettium"
			description = "A rare drug that causes the user to appear dead for some time." //dead appearance handled in human.dm
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 145
			fluid_b = 110
			value = 6 // 4c + 1c + 1c
			viscosity = 0.13
			var/counter = 1
			var/fakedeathed = 0


			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				switch(counter += (1 * mult))
					if (1 to 9)
						M.change_eye_blurry(10, 10)
					if (10 to 18)
						M.setStatus("drowsy", 20 SECONDS)
					if (19 to INFINITY)
						M.changeStatus("paralysis", 3 SECONDS * mult)
						M.changeStatus("muted", 3 SECONDS * mult)
				if (counter >= 19 && !fakedeathed)
					#ifdef COMSIG_MOB_FAKE_DEATH
					SEND_SIGNAL(M, COMSIG_MOB_FAKE_DEATH)
					#endif
					if (deathConfettiActive)
						M.deathConfetti()
					M.setStatusMin("paralysis", 3 SECONDS * mult)
					M.setStatusMin("muted", 3 SECONDS * mult)
					M.visible_message("<B>[M]</B> seizes up and falls limp, [his_or_her(M)] eyes dead and lifeless...")
					M.setStatus("resting", INFINITE_STATUS)
					playsound(M, "sound/voice/death_[pick(1,2)].ogg", 40, 0, 0, M.get_age_pitch())
					fakedeathed = 1
				..()

		capulettium_plus
			name = "capulettium plus"
			id = "capulettium_plus"
			description = "A rare and expensive drug that causes the user to appear dead for some time while they retain consciousness and vision." //dead appearance handled in human.dm
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 145
			fluid_b = 110
			value = 28 // 6c + 9c + 13c
			viscosity = 0.17
			var/counter = 1
			var/fakedeathed = 0

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				switch(counter += (1 * mult))
					if (1 to 9)
						M.change_eye_blurry(10, 10)
					if (10 to 18)
						M.setStatus("drowsy", 20 SECONDS)
				if (counter >= 19 && !fakedeathed)
					#ifdef COMSIG_MOB_FAKE_DEATH
					SEND_SIGNAL(M, COMSIG_MOB_FAKE_DEATH)
					#endif
					if (deathConfettiActive)
						M.deathConfetti()
					M.visible_message("<B>[M]</B> seizes up and falls limp, [his_or_her(M)] eyes dead and lifeless...")
					M.setStatus("resting", INFINITE_STATUS)
					playsound(M, "sound/voice/death_[pick(1,2)].ogg", 40, 0, 0, M.get_age_pitch())
					fakedeathed = 1
				..()

/*
		montaguone
			name = "montaguone"
			id = "montaguone"
			description = "A rare drug that causes the dead to appear alive but unconscious for some time." //handled in human.dm
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 145
			fluid_b = 110

		montaguone_extra
			name = "montaguone extra"
			id = "montaguone_extra"
			description = "A rare and exhorbitantly expensive drug that causes the dead to appear alive and well for some time." //live appearance handled in human.dm
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 145
			fluid_b = 110
			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (isdead(M))
					if (!data) data = 1
					switch(data)
						if (1 to 10)
							if (prob(20)) M.emote("gasp")
						if (11)
							M.lying = 0
						if (12 to INFINITY)
							SPAWN(5 SECONDS)
								if (!M.reagents.has_reagent("montaguone_extra"))
									M.lying = 1
									M.emote("deathgasp")
					data++
				..()
*/
		life
			name = "life"
			id = "life"
			description = "Just a placeholder thing, you shouldn't be seeing this!"

		ageinium
			name = "ageinium"
			id = "ageinium"
			description = "A crusty fluid that smells like old people."
			reagent_state = LIQUID
			fluid_r = 160
			fluid_g = 192
			fluid_b = 192
			transparency = 128
			viscosity = 0.6

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if(prob(30) && istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = M
					if (H.bioHolder.age < 140)
						H.bioHolder.age += 1 * mult
					if (probmult(10))
						boutput(H, SPAN_ALERT("You feel [pick("old", "strange", "frail", "peculiar", "odd")]."))
					if (probmult(4))
						H.emote("scream")
				..()
				return

		denatured_enzyme
			name = "denatured enzyme"
			id = "denatured_enzyme"
			description = "Heated beyond usefulness, this enzyme is now worthless."
			reagent_state = LIQUID
			fluid_r = 42
			fluid_g = 36
			fluid_b = 19
			transparency = 255

		enzymatic_leftovers
			name = "enzymatic leftovers"
			id = "enzymatic_leftovers"
			description = "Leftover chemical garbage produced as a byproduct of a beneficial enzyme."
			reagent_state = LIQUID
			fluid_r = 42
			fluid_g = 36
			fluid_b = 19
			transparency = 255
			depletion_rate = 0.01
			heat_capacity = 200

		// used to make fake initropidril
		eyeofnewt
			name = "eye of newt"
			id = "eyeofnewt"
			description = "A potent alchemic ingredient."
			reagent_state = LIQUID
			fluid_r = 10
			fluid_g = 10
			fluid_b = 50
			transparency = 50
		toeoffrog
			name = "toe of frog"
			id = "toeoffrog"
			description = "A potent alchemic ingredient."
			reagent_state = LIQUID
			fluid_r = 10
			fluid_g = 50
			fluid_b = 10
			transparency = 50
		woolofbat
			name = "wool of bat"
			id = "woolofbat"
			description = "A potent alchemic ingredient."
			reagent_state = LIQUID
			fluid_r = 10
			fluid_g = 10
			fluid_b = 10
			transparency = 50
		tongueofdog
			name = "tongue of dog"
			id = "tongueofdog"
			description = "A potent alchemic ingredient."
			reagent_state = LIQUID
			fluid_r = 50
			fluid_g = 10
			fluid_b = 10
			transparency = 50

		werewolf_serum_fake3
			name = "Werewolf Serum Precursor Gamma"
			id = "werewolf_part3"
			description = "A direct precursor to a special, targeted mutagen."
			reagent_state = LIQUID
			fluid_r = 143
			fluid_g = 35
			fluid_b = 103
			transparency = 10

		werewolf_serum_fake4
			name = "Imperfect Werewolf Serum"
			id = "werewolf_part4"
			description = "A flawed isomer of a special, targeted mutagen.  If only it were perfected..."
			reagent_state = LIQUID
			fluid_r = 240
			fluid_g = 255
			fluid_b = 240
			transparency = 200
			depletion_rate = 0.2

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				var/our_amt = holder.get_reagent_amount(src.id)
				if (prob(25))
					M.reagents.add_reagent("histamine", rand(25, 50) * src.calculate_depletion_rate(M, mult))
				if (our_amt < 5)
					M.take_toxin_damage(1 * mult)
					random_brute_damage(M, 1 * mult)
				else if (our_amt < 10)
					if (probmult(30))
						M.nauseate(1)
					M.take_toxin_damage(2 * mult)
					random_brute_damage(M, 2 * mult)

				else if (probmult(4))
					M.visible_message(SPAN_ALERT("<B>[M]</B> starts convulsing violently!"), "You feel as if your body is tearing itself apart!")
					M.setStatusMin("knockdown", 15 SECONDS * mult)
					M.make_jittery(1000)
					SPAWN(rand(20, 100))
						var/turf/Mturf = get_turf(M)
						if (ishuman(M))
							logTheThing(LOG_COMBAT, M, "was transformed into a dog by reagent [name] at [log_loc(M)].")
						M.gib()
						new /mob/living/critter/small_animal/dog/george (Mturf)
					return

				..()
				return

		hootagen_unstable
			name = "hootagen"
			id = "hootagen_unstable"
			description = "HOoT HoOT HOOT HOoT"
			reagent_state = LIQUID
			fluid_r = 139
			fluid_g = 69
			fluid_b = 19
			transparency = 205
			depletion_rate = 0.2

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				var/our_amt = holder.get_reagent_amount(src.id)
				if (prob(25))
					M.reagents.add_reagent("histamine", rand(25, 50) * src.calculate_depletion_rate(M, mult))
				if (our_amt < 5)
					M.take_toxin_damage(1 * mult)
					random_brute_damage(M, 1 * mult)
				else if (our_amt < 20)
					if (probmult(30))
						M.nauseate(1)
					M.take_toxin_damage(2 * mult)
					random_brute_damage(M, 2 * mult)
				else if (probmult(4))
					M.visible_message(SPAN_ALERT("<B>[M]</B> starts hooting violently!"), "You feel as if your body is hooting itself apart!")
					M.setStatusMin("knockdown", 15 SECONDS * mult)
					M.make_jittery(1000)
					SPAWN(rand(20, 100))
						if (ishuman(M))
							logTheThing(LOG_COMBAT, M, "was owlgibbed by reagent [name] at [log_loc(M)].")
						M.owlgib(control_chance = 100)
					return
				..()
				return

		hootagen_stable
			name = "hootagen"
			id = "hootagen_stable"
			description = "HOOT HOOT HOOT HOOT"
			fluid_r = 139
			fluid_g = 69
			fluid_b = 19
			transparency = 205
			depletion_rate = 0.2

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (ishuman(M))
					var/our_amt = holder.get_reagent_amount(src.id)
					if (our_amt >= 10)
						var/something_changed = 0
						var/mob/living/carbon/human/H = M
						// owl mask
						var/obj/item/clothing/mask/curr_mask = H.wear_mask
						if (curr_mask && !istype(curr_mask, /obj/item/clothing/mask/owl_mask))
							// drop old mask
							H.u_equip(curr_mask)
							curr_mask.set_loc(H.loc)
							curr_mask.dropped(H)
							curr_mask.layer = initial(curr_mask.layer)
						if (!H.wear_mask)
							// add new mask
							var/obj/item/clothing/mask/owl_mask/owl_mask = new /obj/item/clothing/mask/owl_mask(H)
							owl_mask.cant_self_remove = 1
							H.equip_if_possible(owl_mask, SLOT_WEAR_MASK)
							something_changed = 1
						// owl suit
						var/obj/item/clothing/under/curr_uniform = H.w_uniform
						if (curr_uniform && !istype(curr_uniform, /obj/item/clothing/under/gimmick/owl))
							// drop old uniform
							H.u_equip(curr_uniform)
							curr_uniform.set_loc(H.loc)
							curr_uniform.dropped(H)
							curr_uniform.layer = initial(curr_uniform.layer)
						if (!H.w_uniform)
							// add new uniform
							var/obj/item/clothing/under/gimmick/owl/owl_suit = new /obj/item/clothing/under/gimmick/owl(H)
							owl_suit.cant_self_remove = 1
							H.equip_if_possible(owl_suit, SLOT_W_UNIFORM)
							something_changed = 1
						if (something_changed)
							boutput(H, SPAN_ALERT("HOOT HOOT HOOT HOOT!"))
							playsound(H.loc, 'sound/voice/animal/hoot.ogg', 80, 1)
				..()
				return

		sewage
			name = "sewage"
			id = "sewage"
			description = "Oh, wonderful."
			reagent_state = LIQUID
			fluid_r = 102
			fluid_g = 102
			fluid_b = 0
			transparency = 255
			viscosity = 0.4
			hygiene_value = -3

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if (method == INGEST)
					boutput(M, SPAN_ALERT("Aaaagh! It tastes fucking horrendous!"))
					SPAWN(1 SECOND)
						if(!isdead(M) && volume >= 1)
							var/vomit_message = SPAN_ALERT("[M] pukes violently!")
							M.vomit(0, null, vomit_message)
				else
					boutput(M, SPAN_ALERT("Oh god! It smells horrific! What the fuck IS this?!"))
					if (prob(50))
						boutput(M, SPAN_ALERT("Ah fuck! Some got into your mouth!"))
						var/amt = min(volume/100,1)
						src.holder.remove_reagent("sewage",amt)
						M.reagents.add_reagent("sewage",amt)
						src.reaction_mob(M,INGEST,amt,null,amt)
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (prob(7))
					M.emote(pick("twitch","drool","moan"))
					M.take_toxin_damage(1 * mult)
					M.nauseate(2)
				..()
				return

		ants
			name = "ants"
			id = "ants"
			description = "A sample of a lost breed of Space Ants (formicidae bastardium tyrannus), they are well-known for ravaging the living shit out of pretty much anything."
			reagent_state = SOLID
			fluid_r = 153
			fluid_g = 51
			fluid_b = 51
			transparency = 255
			value = 2
			viscosity = 0.8

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(volume < 1)
					return
				if (method == TOUCH)
					. = 0 // for depleting fluid pools
				if (!ON_COOLDOWN(M, "ants_scream", 10 SECONDS)) //lets make it less spammy
					M.emote("scream")
					if (method == INGEST || method == INJECT)
						boutput(M, SPAN_ALERT("<b>OH SHIT, ANTS [pick("", "IN MY BLOOD", " IN MY VEINS")]![pick("", "!", "!!", "!!!", "!!!!")]</b>"))
					else
						boutput(M, SPAN_ALERT("<b>OH SHIT, ANTS![pick("", "!", "!!", "!!!", "!!!!")]</b>"))
				random_brute_damage(M, 4)

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				random_brute_damage(M, 2 * mult)
				..()

		spiders
			name = "spiders"
			id = "spiders"
			description = "A bunch of tiny little spiders, all crawling around in a big spidery blob."
			reagent_state = SOLID
			fluid_r = 22
			fluid_g = 5
			fluid_b = 5
			transparency = 255
			var/static/reaction_count = 0
			value = 13 // 11 2
			viscosity = 0.8

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(volume < 1 || istype(M, /mob/living/critter/spider))
					return
				if(method == TOUCH)
					. = 0 // for depleting fluid pools
				if (!ON_COOLDOWN(M, "spiders_scream", 3 SECONDS))
					M.emote("scream")
					if (method == INGEST || method == INJECT)
						boutput(M, SPAN_ALERT("<b>OH [pick("SHIT", "FUCK", "GOD")] SPIDERS[pick("", " IN MY BLOOD", " IN MY VEINS")]![pick("", "!", "!!", "!!!", "!!!!")]</b>"))
					else
						boutput(M, SPAN_ALERT("<b>OH [pick("SHIT", "FUCK", "GOD")] SPIDERS[pick("", " ON MY FACE", " EVERYWHERE")]![pick("", "!", "!!", "!!!", "!!!!")]</b>"))
				random_brute_damage(M, 2)
				if (ishuman(M))
					if (!M:spiders)
						M:spiders = 1
						M:update_body()
				return

			reaction_turf(var/turf/T, var/volume)
				CRITTER_REACTION_CHECK(reaction_count)
				var/turf/simulated/target = T
				if (istype(target) && volume >= 5)
					if (!locate(/obj/reagent_dispensers/cleanable/spiders) in target)
						new /obj/reagent_dispensers/cleanable/spiders(target)
						var/obj/critter/S
						if (prob(10))
							S = new /mob/living/critter/spider/baby/nice(target)
						else if (prob(2))
							S = new /mob/living/critter/spider/nice(target)
							S.name = "spider"
							S.set_density(0)
					else if ((locate(/obj/reagent_dispensers/cleanable/spiders) in target) && !(locate(/mob/living/critter/spider) in target))
						if (prob(25))
							if (prob(2))
								new /mob/living/critter/spider/baby(target)
							else
								new /mob/living/critter/spider/baby/nice(target)
						else if (prob(5))
							new /mob/living/critter/spider/nice(target)

				return

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if(istype(M, /mob/living/critter/spider))
					return
				if (prob(50))
					random_brute_damage(M, 1 * mult)
				else if (prob(10))
					random_brute_damage(M, 2 * mult)
					M.emote(pick("twitch", "twitch_s", "grumble"))
					M.visible_message(SPAN_ALERT("<b>[M]</b> [pick("scratches", "digs", "picks")] at [pick("something under [his_or_her(M)] skin", "[his_or_her(M)] skin")]!"),\
					SPAN_ALERT("<b>[pick("T", "It feels like t", "You feel like t", "Oh shit t", "Oh fuck t", "Oh god t")]here's something [pick("crawling", "wriggling", "scuttling", "skittering")] in your [pick("blood", "veins", "stomach")]!</b>"))
				else if (prob(10))
					random_brute_damage(M, 5 * mult)
					M.emote("twitch")
					M.setStatusMin("knockdown", 2 SECONDS * mult)
					M.visible_message(SPAN_ALERT("<b>[M.name]</b> tears at [his_or_her(M)] own skin!"),\
					SPAN_ALERT("<b>OH [pick("SHIT", "FUCK", "GOD")] GET THEM OUT![pick("", "!", "!!", "!!!", "!!!!")]"))

				if (prob(30))
					M.nauseate(2)

				..()
				return

			on_add()
				if (ismob(holder.my_atom))
					var/mob/mob = holder.my_atom
					mob.add_vomit_behavior(/datum/vomit_behavior/spider)

			on_remove()
				if (ismob(holder.my_atom))
					var/mob/mob = holder.my_atom
					mob.remove_vomit_behavior(/datum/vomit_behavior/spider)

		hugs
			name = "pure hugs"
			id = "hugs"
			description = "Hugs, in liquid form.  Yes, the concept of a hug.  As a liquid.  This makes sense in the future."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 151
			fluid_b = 185
			transparency = 250
			value = 11
			viscosity = 0.2

		love
			name = "pure love"
			id = "love"
			description = "What is this emotion you humans call \"love?\"  Oh, it's this?  This is it? Huh, well okay then, thanks."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 131
			fluid_b = 165
			transparency = 250
			value = 13 // 11 2
			viscosity = 0.3

			proc/no_harm(datum/source, intent)
				if(intent == INTENT_HARM)
					boutput(source, SPAN_NOTICE("You can't bring yourself to harm others!"))
					return TRUE
				return FALSE

			reaction_mob(var/mob/M)
				. = ..()
				boutput(M, SPAN_NOTICE("You feel loved!"))

			initial_metabolize(mob/M)
				RegisterSignal(M, COMSIG_MOB_SET_A_INTENT, PROC_REF(no_harm))

			on_mob_life_complete(mob/M)
				UnregisterSignal(M, COMSIG_MOB_SET_A_INTENT)

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom

				if (probmult(8))
					. = ""
					switch (rand(1, 9))
						if (1)
							. = "appreciated"
						if (2)
							. = "loved"
						if (3)
							. = "pretty good"
						if (4)
							. = "really nice"
						if (5)
							. = "cared for"
						if (6)
							. = "like you belong"
						if (7)
							. = "accepted for who you are"
						if (8)
							. = "like things will be okay"
						if (9)
							. = "pretty happy with yourself, even though things haven't always gone as well as they could"


					boutput(M, SPAN_NOTICE("You feel [.]."))

				else if (prob(50) && !M.restrained() && ishuman(M)) // only humans hug, I think?
					var/mob/living/carbon/human/H = M
					for (var/mob/living/carbon/human/hugTarget in orange(1,H))
						if (hugTarget == H)
							continue
						if (!hugTarget.stat)
							H.emote(prob(5)?"sidehug":"hug", emoteTarget="[hugTarget]")
							break

				..()

		colors
			name = "colorful reagent"
			id = "colors"
			description = "It's pure liquid colors. That's a thing now."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255
			hygiene_value = -0.5
			viscosity = 0.1

			reaction_mob(var/mob/M, var/method = TOUCH, var/volume)
				. = ..()
				if (method == INGEST)
					if (isliving(M))
						var/mob/living/L = M
						var/color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
						L.blood_color = color
						L.bioHolder?.bloodColor = color

			reaction_obj(var/obj/O, var/volume)
				O.color = rgb(rand(0,255),rand(0,255),rand(0,255))

			reaction_turf(var/turf/T, var/volume)
				T.color = rgb(rand(0,255),rand(0,255),rand(0,255))

		gypsum //gypsum, made with waste sulfur gas and calcium carbonate or calcium oxide (sulfur + oxygen(4) + water + calcium_carbonate)
			name = "calcium sulfate"
			id = "gypsum"
			description = "An inorganic chemical that has many uses in the industrial sector."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255

		calcium_carbonate //made from extracted sea shells OR just chemical synthesis
			name = "calcium carbonate"
			id = "calcium_carbonate"
			description = "A naturally occuring chemical found in seashells and certain rocks."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255

		chalk
			name = "chalk"
			id = "chalk"
			description = "A mixture of minerals and additives that is commonly used as a writing implement."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255
			var/chalk_color = null

			reaction_turf(var/turf/T, var/volume)
				if (volume >= 5 && !locate(/obj/item/pen/crayon/chalk) in T)
					if (holder.has_reagent("colors"))
						new /obj/item/pen/crayon/chalk/random(T)
						return
					var/obj/item/pen/crayon/chalk/W = new(T)
					chalk_color = holder.get_average_rgb()
					W.assign_color(chalk_color)

		shark_dna
			name = "space shark DNA"
			id = "shark_dna"
			description = "How this was obtained is anyone's guess."
			reagent_state = LIQUID
			fluid_r = 160
			fluid_g = 160
			fluid_b = 255
			transparency = 100
			value = 4

		packing_peanuts
			name = "packing peanuts"
			id = "packing_peanuts"
			description = "Those little white things you get when you order stuff in boxes. Not to be confused with ghost poop."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255
			value = 3

		wax
			name = "wax"
			id = "wax"
			description = "A lipid compound used in candles and for making haunted sculptures to terrorize Scooby Doo."
			reagent_state = SOLID
			fluid_r = 250
			fluid_g = 250
			fluid_b = 250
			transparency = 200
			value = 3
			viscosity = 0.5

		pollen
			name = "pollenium"
			id = "pollen"
			description = "A pollen-derivative with a number of proteins and other nutrients vital to space bee health. Not palatable for humans."
			reagent_state = SOLID
			fluid_r = 191
			fluid_g = 191
			fluid_b = 61
			transparency = 255
			value = 3

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume_passed)
				. = ..()
				if(!volume_passed)
					return
				if(!isliving(M))
					return

				if(method == INGEST)
					var/mob/living/H = M
					if (H.bioHolder && H.bioHolder.HasEffect("bee"))
						boutput(M, SPAN_NOTICE("That tasted amazing!"))
					else
						boutput(M, SPAN_ALERT("Ugh! Eating that was a terrible idea!"))
						M.setStatusMin("knockdown", 3 SECONDS)

		martian_flesh
			name = "martian flesh"
			id = "martian_flesh"
			description = "Uhhhh... it's still moving?"
			reagent_state = SOLID
			fluid_r = 180
			fluid_g = 225
			fluid_b = 175
			transparency = 230
			value = 5
			hunger_value = 0.8
			threshold = THRESHOLD_INIT
			fluid_flags = FLUID_BANNED

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					if (ismartian(M))
						APPLY_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST, "reagent_martian_flesh", 15)
						APPLY_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST_MAX, "reagent_martian_flesh", 15)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					if (ismartian(M))
						REMOVE_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST, "reagent_martian_flesh")
						REMOVE_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST_MAX, "reagent_martian_flesh")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(ismartian(M))
					M.HealDamage("All", 2 * mult, 0)
					M.take_oxygen_deprivation(-1 * mult)
					M.take_toxin_damage(-1 * mult)
					M.take_brain_damage(-1 * mult)
					if(prob(10))
						boutput(M, SPAN_NOTICE("A burst of vitality flows through you as the martian flesh assimilates into your body."))
						M.HealDamage("All", 4, 0)
						M.take_oxygen_deprivation(-4 * mult)
						M.take_brain_damage(-4 * mult)
				else
					M.take_toxin_damage(1 * mult)
					if(prob(10))
						boutput(M, SPAN_ALERT("[pick("You can feel your insides squirming, oh god!", "You feel horribly queasy.", "You can feel something climbing up and down your throat.", "Urgh, you feel really gross!", "It feels like something is crawling inside your skin!")]"))
						M.take_toxin_damage(4 * mult)
				M.UpdateDamageIcon()
				..()
				return

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume_passed)
				. = ..()
				if(!volume_passed)
					return
				if(ismartian(M))
					// no matter what the method is, it's just gonna start doing weird freaky alien melding so whatever
					boutput(M, SPAN_NOTICE("The martian flesh begins to merge into your body, repairing tissue damage as it does so."))
					M.HealDamage("All", 5, 0)
					M.UpdateDamageIcon()
				else
					if(method == INGEST)
						boutput(M, "<span class='alert bold'>OH FUCK [pick("IT'S MOVING IN YOUR INSIDES", "IT TASTES LIKE ANGRY MUTANT BROCCOLI", "IT HURTS IT HURTS", "THIS WAS A BAD IDEA", "IT'S LIKE ALIEN GENOCIDE IN YOUR MOUTH AND EVERYONE'S DEAD", "IT'S BITING BACK", "IT'S CRAWLING INTO YOUR THROAT", "IT'S PULLING AT YOUR TEETH")]!!</span>")
						M.setStatusMin("knockdown", 3 SECONDS)
						M.emote("scream")
					if(method == TOUCH)
						boutput(M, SPAN_ALERT("Well, that was gross."))

		viscerite_viscera
			name = "viscerite viscera"
			id = "viscerite_viscera"
			description = "Looking at this makes you feel queasy... ugh."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_g = 135
			fluid_b = 200
			hunger_value = 0.5

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M)
					M = holder.my_atom
				M.HealDamage("All", mult * 2, mult * 1.5)
				M.take_toxin_damage(0.5 * mult)
				if(prob(20))
					M.setStatusMin("knockdown", 3 SECONDS)
				if(prob(10))
					boutput(M, SPAN_ALERT("[pick("You feel your insides moving around and shifting", "Your body has never felt better, it has also never felt worse.", "The state of your insides make you feel like you're in a boat that got sucked up into a hurricane", "Urgh, you feel really gross!")]"))
				..()
				return

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume_passed)
				. = ..()
				if(!volume_passed)
					return
				if(method == TOUCH)
					boutput(M, SPAN_ALERT("The pink viscera partially hangs off of your clothes."))
				if(method == INGEST)
					boutput(M, "<span class='alert bold'>[pick("The viscera burns your mouth as it goes down", "The texture of the viscera feels like spaghetti made by someone nearly blacked out who also doesn't know what spaghetti is", "You feel the viscera slide down your throat")]!!</span>")
					M.setStatusMin("knockdown", 3 SECONDS)

		flockdrone_fluid
			name = "coagulated gnesis"
			id = "flockdrone_fluid"
			description = "A thick teal fluid of alien origin. It moves in ways that suggest it might be alive in some way."
			reagent_state = LIQUID
			fluid_r = 77
			fluid_g = 115
			fluid_b = 109
			transparency = 192
			viscosity = 0.3
			depletion_rate = 0.25
			flushing_multiplier = 2
			var/conversion_rate = 0.7
			var/gib_threshold = 200
			var/list/sounds = list('sound/machines/ArtifactFea1.ogg', 'sound/machines/ArtifactFea2.ogg', 'sound/machines/ArtifactFea3.ogg',
							'sound/misc/flockmind/flockmind_cast.ogg', 'sound/misc/flockmind/flockmind_caw.ogg',
							'sound/misc/flockmind/flockdrone_beep1.ogg', 'sound/misc/flockmind/flockdrone_beep2.ogg', 'sound/misc/flockmind/flockdrone_beep3.ogg', 'sound/misc/flockmind/flockdrone_beep4.ogg',
							'sound/misc/flockmind/flockdrone_grump1.ogg', 'sound/misc/flockmind/flockdrone_grump2.ogg', 'sound/misc/flockmind/flockdrone_grump3.ogg',
							'sound/effects/radio_sweep1.ogg', 'sound/effects/radio_sweep2.ogg', 'sound/effects/radio_sweep3.ogg', 'sound/effects/radio_sweep4.ogg', 'sound/effects/radio_sweep5.ogg')

			on_add()
				active_reagent_holders |= src

			on_remove()
				active_reagent_holders -= src
				var/mob/M = holder.my_atom
				if (istype(M) && !istype(M.loc, /obj/flock_structure/cage))
					M.removeOverlayComposition(/datum/overlayComposition/flockmindcircuit)

			proc/process_reactions()
				// consume fellow reagents
				if (istype(holder))
					var/list/otherReagents = holder.reagent_list.Copy()
					otherReagents -= src.id
					if(ishuman(holder?.my_atom))
						var/mob/living/carbon/human/H = holder.my_atom
						if(H.blood_volume >= conversion_rate)
							otherReagents += "blood_placeholder"

					if(length(otherReagents) > 0)
						var/targetReagent = pick(otherReagents) //pick one reagent and convert it
						//don't convert normal flushing chems in bloodstream, we're not THAT mean
						if(!ismob(holder.my_atom) || !(targetReagent in list("calomel", "hunchback", "penteticacid", "tealquila", "blood_placeholder"))) //blood is handled in on_mob_life
							holder.remove_reagent(targetReagent, conversion_rate)
							holder.add_reagent(id, conversion_rate)
					else
						// we ate them all, time to die
						if(holder?.my_atom?.material?.getID() in list("gnesis", "gnesisglass")) // gnesis material prevents coag. gnesis from evaporating
							return

						holder.remove_reagent(id, conversion_rate)

			// let's put more teeth into this.
			// this is the fluid of the assimilating bird robots. clearly it needs to also assimilate other things
			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (ishuman(M))
					// i'm sorry sir but your blood counts as raw materials
					var/mob/living/carbon/human/H = M
					var/amt = conversion_rate * mult
					if(H.blood_volume >= amt && holder.get_reagent_amount(src.id) > 40)
						H.blood_volume -= amt
						H.reagents.add_reagent(id, amt)
					if(holder.get_reagent_amount(src.id) > gib_threshold)
						//make it obvious that you are about to die horribly
						M.addOverlayComposition(/datum/overlayComposition/flockmindcircuit)
						// oh no
						if(probmult(max(2, (src.volume - gib_threshold)/5))) // i hate you more, players
							logTheThing(LOG_COMBAT, H, "was gibbed by reagent [name] at [log_loc(H)].")
							H.flockbit_gib()
							return
					else
						if (!istype(M.loc, /obj/flock_structure/cage))
							M.removeOverlayComposition(/datum/overlayComposition/flockmindcircuit)
					// DO SPOOKY THINGS
					if(holder.get_reagent_amount(src.id) < 100)
						if(probmult(2))
							M.playsound_local(get_turf(M), pick(sounds), 20, 1)
						if(probmult(6))
							boutput(M, "<span class='flocksay italics'>[pick_string("flockmind.txt", "flockjuice_low")]</span>")
					else
						if (probmult(5) && !ON_COOLDOWN(M, "flock_organ", 3 MINUTES))
							M.emote("scream")
							boutput(M, SPAN_ALERT("<b>You feel something hard and sharp crystallize inside you!</b>"))
							src.replace_organ(H)
						if(probmult(10))
							M.playsound_local(get_turf(M), pick(sounds), 40, 1)
							M.setStatus("gnesis_glow", 2 SECONDS)
						if(probmult(30))
							boutput(M, "<span class='flocksay italics'>[pick_string("flockmind.txt", "flockjuice_high")]</span>")

				..()
				return

			proc/replace_organ(var/mob/living/carbon/human/H)
				var/organ_name = pick(non_vital_organ_strings)
				var/obj/item/organ/organ = H.get_organ(organ_name)
				if (istype(organ, /obj/item/organ/flock_crystal))
					return
				H.drop_organ(organ_name, null)
				var/obj/item/organ/flock_crystal/new_organ = new()
				new_organ.organ_name = organ_name
				new_organ.name = "crystallized [organ.name]"
				H.receive_organ(new_organ, organ_name, FALSE, TRUE)
				qdel(organ)

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume_passed)
				. = ..()
				if(!volume_passed)
					return
				if(method == INGEST)
					boutput(M, SPAN_ALERT("Tastes oily and unpleasant, with a weird sweet aftertaste. It's like eating children's modelling clay."))
				if(method == TOUCH)
					if (!ON_COOLDOWN(M, "gnesis_tint_msg", 3 SECONDS))
						boutput(M, SPAN_NOTICE("It feels like you got smudged with oil paints."))
						SPAWN(3 SECONDS)
							boutput(M, SPAN_ALERT("Oh god it's not coming off!"))
					M.setStatus("gnesis_tint", 3 MINUTES)

			reaction_turf(var/turf/T, var/volume)
				if (!istype(T, /turf/space))
					if (volume >= 50 && (istype(T, /turf/simulated/floor) || istype(T, /turf/simulated/wall)))
						T.visible_message(SPAN_NOTICE("The substance flows out and sinks into [T], forming new shapes."))
						flock_convert_turf(T)
					if (volume >= 10)
						T.visible_message(SPAN_NOTICE("The substance flows out and takes a solid form."))
						if(prob(50))
							var/atom/movable/B = new /obj/item/raw_material/scrap_metal
							B.set_loc(T)
							B.setMaterial(getMaterial("gnesis"))
						else
							var/atom/movable/B = new /obj/item/raw_material/shard
							B.set_loc(T)
							B.setMaterial(getMaterial("gnesisglass"))
						return
				// otherwise we didn't have enough
				T.visible_message(SPAN_NOTICE("The substance flows out, spread too thinly."))

		black_goop
			name = "gross black goop"
			id = "black_goop"
			description = "You're not even sure what this is. It's pretty grody."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			transparency = 255
			viscosity = 0.6

		paper
			name = "paper"
			id = "paper"
			description = "Little flecks of paper, all torn up."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255
			fluid_flags = FLUID_BANNED

			reaction_turf(var/turf/T, var/volume)
				var/list/covered = holder.covered_turf()
				if (length(covered) > 9)
					volume = (volume/covered.len)

				if (!istype(T, /turf/space))
					if (volume >= 5)
						if (!locate(/obj/decal/cleanable/paper) in T)
							make_cleanable(/obj/decal/cleanable/paper,T)

		rubber
			name = "rubber"
			id = "rubber"
			description = "A somewhat durable material that someone managed to squeeze out of a tree."
			fluid_r = 50
			fluid_g = 50
			fluid_b = 50
			transparency = 255

			reaction_turf(var/turf/T, var/volume)
				if (!istype(T, /turf/space))
					if (volume >= 10 && holder.total_temperature < T0C + 180)
						if (!locate(/obj/item/material_piece/rubber/latex) in T)
							new /obj/item/material_piece/rubber/latex(T)
					else
						return TRUE

		flubber
			name = "Liquified space rubber"
			id = "flubber"
			description = "It seems to be vibrating and bouncing around its container rapidly"
			fluid_r = 0
			fluid_g = 255
			fluid_b = 0
			transparency = 127
			overdose = 25
			var/OD_ticks = 0

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M)
					M = holder.my_atom
				if (holder.get_reagent_amount(src.id) < src.overdose)
					//once we loose the OD treshold, we really stop turning into rubber
					src.OD_ticks = 0
				..()

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				if(!M)
					M = holder.my_atom
				switch (severity)
					if (1)
						if(prob(5))
							//while we are overdosing, we don't fully break down the OD-ticks. Gotta get under the OD-limit
							src.OD_ticks = max(0, src.OD_ticks - 1)
						if(prob(10) && !ON_COOLDOWN(M, "flubber_jiggling", 8 SECONDS))
							animate_flubber(M)
							boutput(M, SPAN_ALERT("You feel [pick("like you're bending out of shape", "a jiggling sensation", "like something is wrong")]."))
							//your body becoming rubber should hurt. We start at 6 damage and scale up to 8 damage before hitting the really dangerous OD-limit
							random_brute_damage(M, 8 * (holder.get_reagent_amount(src.id) / src.overdose)  * mult)
					if (2 to INFINITY)
						//now the real fun starts
						src.OD_ticks += 1
						if(src.OD_ticks > 8 && prob(10))
							boutput(M, SPAN_ALERT("<I>Your finger's feel rubbery!</I>"))
							if(istype(M, /mob/living))
								var/mob/living/rubber_finger_mob = M
								rubber_finger_mob.empty_hands()
						switch(src.OD_ticks)
							if (1 to 10)
								if (prob(25) && !ON_COOLDOWN(M, "flubber_jiggling", 8 SECONDS))
									animate_flubber(M)
									boutput(M, SPAN_ALERT(pick("Something feels seriously off.","You can swear you have seen your back just a second ago...", "It felt like your stomach shifted upwards for a second, odd...")))
									random_brute_damage(M, 8 * mult)
							if (11 to 22)
								if (prob(25) && !ON_COOLDOWN(M, "flubber_jiggling", 6 SECONDS))
									animate_flubber(M, 6, 10, 3, 2)
									boutput(M, SPAN_ALERT(pick("Your body cannot stop jiggling.","Your knees twist in an unsettling direction.", "Your eyes bounce inside your skull for a moment, holy fuck...")))
									random_brute_damage(M, 10 * mult)
							if (23 to INFINITY)
								if (prob(25) && !ON_COOLDOWN(M, "flubber_jiggling", 6 SECONDS))
									boutput(M, SPAN_ALERT("<B>[pick("Your body stretches to an unreasonable degree, FUCK!","You cannot control your form! MAKE. IT. STOP!", "You feel your organs jiggling into each other... IT HURTS!")]</B>"))
									M.setStatusMin("stunned", 2 SECONDS * mult)
									animate_flubber(M, 4, 8, 4, 2.5)
									random_brute_damage(M, 12 * mult)


		fliptonium
			name = "fliptonium"
			id = "fliptonium"
			description = "Do some flips!"
			reagent_state = LIQUID
			fluid_r = 209
			fluid_g = 31
			fluid_b = 117
			transparency = 175
			addiction_prob = 0.2
			addiction_min = 10
			overdose = 15
			depletion_rate = 0.2
			viscosity = 0.1
			var/direction = null
			var/dir_lock = 0
			var/anim_lock = 0
			var/speed = 3
			stun_resist = 9
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_flip", 2)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_flip")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom

				..()	//Rearranging to make it deplete as intended

				if (!isliving(M))
					return

				if (!data) data = 1
				else data++

				switch (data)
					if (1)
						anim_lock = 0
						speed = 3
					if (10)
						anim_lock = 0
						speed = 2.5
					if (20)
						anim_lock = 0
						speed = 2
					if (30)
						anim_lock = 0
						speed = 1.5
					if (40)
						anim_lock = 0
						speed = 1

				if (!dir_lock)
					direction = pick("L", "R")
					dir_lock = 1

				if (!anim_lock)
					animate_spin(M, direction, speed)
					anim_lock = 1

				M.make_jittery(2)
				M.changeStatus("drowsy", -12 SECONDS)
				if (M.sleeping) M.sleeping = 0
				return

			reaction_mob(var/mob/M)
				. = ..()
				var/dir_temp = pick("L", "R")
				var/speed_temp = text2num("[rand(1,6)].[rand(0,9)]")
				animate_spin(M, dir_temp, speed_temp)
				DEBUG_MESSAGE(SPAN_NOTICE("<b>Spun [M]: [dir_temp], [speed_temp]</b>")) // <- What's this?

/*			reaction_obj(var/obj/O, var/volume)
				if (volume >= 10)
					var/dir_temp = pick("L", "R")
					var/speed_temp = text2num("[rand(1,6)].[rand(0,9)]")
					animate_spin(O, dir_temp, speed_temp)
					DEBUG_MESSAGE(SPAN_NOTICE("<b>Spun [O]: [dir_temp], [speed_temp]</b>"))
*/

			on_remove()
				if (istype(holder) && istype(holder.my_atom))
					animate(holder.my_atom)
				..()

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> can't seem to control [his_or_her(M)] legs!"))
						M.change_misstep_chance(33 * mult)
						M.setStatusMin("knockdown", 3 SECONDS * mult)
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("<b>[M.name]'s</b> hands flip out and flail everywhere!"))
						M.drop_item()
						M.hand = !M.hand
						M.drop_item()
						M.hand = !M.hand
					else if (effect <= 7)
						M.emote("laugh")
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M.name]'s</b> hands flip out and flail everywhere!"))
						M.drop_item()
						M.hand = !M.hand
						M.drop_item()
						M.hand = !M.hand
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> falls to the floor and flails uncontrollably!"))
						M.make_jittery(5)
						M.setStatusMin("knockdown", 6 SECONDS * mult)
					else if (effect <= 7)
						M.emote("laugh")

		fliptonium/glowing_fliptonium
			name = "glowing fliptonium"
			id = "glowing_fliptonium"
			description = "There's something kinda weird about this stuff. Something off. Something... spooky."
			reagent_state = LIQUID
			fluid_r = 158
			fluid_g = 16
			fluid_b = 94
			transparency = 200
			addiction_prob = 1
			addiction_min = 5
			overdose = 11
			depletion_rate = 0.1
			viscosity = 0.15
			stun_resist = 60
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_glowing_flip", 4)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_glowing_flip")
				..()


			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom

				..()

				if (!isliving(M))
					return

				if (!data) data = 1
				else data++

				switch (data)
					if (1)
						anim_lock = 0
						speed = 3
					if (5)
						anim_lock = 0
						speed = 2.5
					if (10)
						anim_lock = 0
						speed = 2
					if (15)
						anim_lock = 0
						speed = 1.5
					if (20)
						anim_lock = 0
						speed = 1
					if (25)
						anim_lock = 0
						speed = 0.9
					if (30)
						anim_lock = 0
						speed = 0.8
					if (35)
						anim_lock = 0
						speed = 0.7
					if (40)
						anim_lock = 0
						speed = 0.6
					if (45)
						anim_lock = 0
						speed = 0.5

				if (!dir_lock)
					direction = pick("L", "R")
					dir_lock = 1

				if (!anim_lock)
					animate_spin(M, direction, speed)
					anim_lock = 1

				M.make_jittery(4)
				M.changeStatus("drowsy", -25 SECONDS)
				if (M.sleeping) M.sleeping = 0
				return

			reaction_mob(var/mob/M, var/method = TOUCH)
				. = ..()
				if (method != TOUCH)
					return
				var/dir_temp = pick("L", "R")
				var/speed_temp = text2num("[rand(0,10)].[rand(0,9)]")
				animate_spin(M, dir_temp, speed_temp)

			reaction_obj(var/obj/O)
				if(!O.mouse_opacity)
					return
				var/dir_temp = pick("L", "R")
				var/speed_temp = text2num("[rand(0,10)].[rand(0,9)]")
				animate_spin(O, dir_temp, speed_temp)


		diluted_fliptonium
			name = "diluted fliptonium"
			id = "diluted_fliptonium"
			description = "You're a rude dude with a rude 'tude."
			reagent_state = LIQUID
			fluid_r = 245
			fluid_g = 12
			fluid_b = 74
			transparency = 150
			addiction_prob = 0.01
			addiction_min = 15
			overdose = 30
			depletion_rate = 0.1

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (probmult(10))
					var/list/mob/nerds = list()
					for (var/mob/living/some_idiot in oviewers(M, 7))
						nerds.Add(some_idiot)
					if (length(nerds))
						var/mob/some_idiot = pick(nerds)
						if (prob(50))
							M.visible_message(SPAN_EMOTE("<B>[M]</B> flips off [some_idiot.name]!"))
						else
							M.visible_message(SPAN_EMOTE("<B>[M]</B> gives [some_idiot.name] the double deuce!"))
				..()
				return
		capsizin
			name = "capsizin"
			id = "capsizin"
			description = "This liquid doesn't seem to be self-righting..."
			reagent_state = LIQUID
			fluid_r = 23
			fluid_g = 46
			fluid_b = 111
			transparency = 150
			overdose = 30
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.Turn(180)
					boutput(M, "You capsize!")
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.Turn(180)
					boutput(M, "You manage to right yourself!")
				..()

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				M.reagents.add_reagent("water", severity * 2.5 * src.calculate_depletion_rate(M, mult))

		transparium
			name = "transparium"
			id = "transparium"
			description = "An exotic compound that intimidates nearby photons upon exiting the body, rendering the user invisible for a period of time proportional to how long it was present in their bloodstream."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 30
			addiction_prob = 3.75
			addiction_min = 15
			overdose = 30
			var/effect_length = 0

			on_mob_life(mob/M, mult = 1) // humans only! invisible critters would be awful...
				if (!ishuman(M))
					src.holder.remove_reagent(src.id)
					return
				if (src.effect_length < 100) // because 30/0.4 = 75; give them a little more time spent invisible, but don't allow them to try and beat the system too much
					src.effect_length += 1 * mult
				..()

			on_mob_life_complete(mob/M)
				if (src.effect_length > 75)
					M.take_brain_damage(10)
				M.setStatusMin("transparium", src.effect_length * 1 SECOND, 0)

			do_overdose(severity, mob/M, mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 4)
						M.setStatusMin("knockdown", 5 SECONDS * mult)
					else if (effect <= 8)
						M.change_misstep_chance(12 * mult)
						M.make_dizzy(5 * mult)
					else if (effect <= 20)
						M.emote("faint")
				else if (severity == 2)
					if (effect <= 6)
						M.setStatusMin("knockdown", 5 SECONDS * mult)
					else if (effect <= 12)
						M.change_misstep_chance(12 * mult)
						M.make_dizzy(5 * mult)
					else if (effect <= 24)
						M.emote("faint")

		transparium/dilute
			name = "diluted transparium"
			id = "diluted_transparium"
			description = "Transparium that has been diluted with water to weaken its effects."
			fluid_r = 10
			fluid_g = 254
			fluid_b = 254
			addiction_prob = 0
			overdose = 0

			on_mob_life_complete(mob/living/M)
				M.setStatusMin("transparium", src.effect_length * 1 SECOND, rand(80, 200))

		fartonium // :effort:
			name = "fartonium"
			id = "fartonium"
			description = "Oh god it never ends, IT NEVER STOPS!"
			reagent_state = GAS
			fluid_r = 247
			fluid_g = 122
			fluid_b = 32
			transparency = 200
			addiction_prob = 0.2
			addiction_min = 15

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				if (probmult(66))
					M.emote("fart")

				if (M?.reagents.has_reagent("anti_fart"))
					if (prob(25))
						boutput(M, SPAN_ALERT("[pick("Oh god, something doesn't feel right!", "<B>IT HURTS!</B>", "<B>FUCK!</B>", "Something is seriously wrong!", "<B>THE PAIN!</B>", "You feel like you're gunna die!")]"))
						random_brute_damage(M, 1 * mult)
					if (prob(10))
						M.emote("poo")
						random_brute_damage(M, 2 * mult)
					if (prob(5))
						M.emote("scream")
						random_brute_damage(M, 4 * mult)
				..()

// let us never forget the 3,267 parrot incident, the recipe for this just reacts instantly now
		flaptonium
			name = "flaptonium"
			id = "flaptonium"
			fluid_r = 100
			fluid_g = 200
			fluid_b = 255
			transparency = 255
			var/static/reaction_count = 0

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				var/turf/T = get_turf(M)
				createSomeBirds(T, volume)

			reaction_obj(var/obj/O, var/volume)
				var/turf/T = get_turf(O)
				createSomeBirds(T, volume)

			reaction_turf(var/turf/T, var/volume)
				createSomeBirds(T, volume)

			proc/createSomeBirds(var/turf/T as turf, var/volume)
				CRITTER_REACTION_CHECK(reaction_count)
				if (!T)
					return
				if (volume < 5)
					return
				if (!(locate(/obj/critter) in T) && prob(20))
					if (prob(1) && !already_a_dominic)
						new /obj/critter/parrot/eclectus/dominic(T)
					else
						new /obj/critter/parrot/random(T)

		diluted_flaptonium
			name = "diluted flaptonium"
			id = "diluted_flaptonium"
			description = "You're not a bird, cut that out."
			reagent_state = LIQUID
			fluid_r = 175
			fluid_g = 175
			fluid_b = 255
			transparency = 150
			addiction_prob = 0.01
			addiction_min = 15
			depletion_rate = 0.1

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (probmult(10))
					if (prob(50))
						M.visible_message(SPAN_EMOTE("<B>[M]</B> flaps [his_or_her(M)] arms!"))
					else
						M.visible_message(SPAN_EMOTE("<B>[M]</B> flaps [his_or_her(M)] arms ANGRILY!"))
					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						if (H.sound_list_flap && length(H.sound_list_flap))
							playsound(H, pick(H.sound_list_flap), 80, 0, 0, H.get_age_pitch())
				..()
				return

		glitter
			name = "glitter"
			id = "glitter"
			description = "Fabulous!"
			reagent_state = SOLID
			fluid_r = 230
			fluid_g = 230
			fluid_b = 240
			transparency = 245
			depletion_rate = 0.1
			penetrates_skin = 1

			on_add()
				var/atom/A = holder.my_atom
				if (ismob(A))
					if (!particleMaster.CheckSystemExists(/datum/particleSystem/glitter, A))
						particleMaster.SpawnSystem(new /datum/particleSystem/glitter(A))
				if (isobj(A))
					if (!particleMaster.CheckSystemExists(/datum/particleSystem/glitter, A))
						particleMaster.SpawnSystem(new /datum/particleSystem/glitter(A))

			reaction_turf(var/turf/T, var/volume)
				var/list/covered = holder.covered_turf()
				if (length(covered) > 9)
					volume = (volume/covered.len)

				if (!istype(T, /turf/space))
					if (volume >= 5)
						if (!locate(/obj/decal/cleanable/glitter) in T)
							make_cleanable(/obj/decal/cleanable/glitter,T)

			on_remove()
				if (!holder) return

				var/atom/A = holder.my_atom
				if (ismob(A))
					if (particleMaster.CheckSystemExists(/datum/particleSystem/glitter, A))
						particleMaster.RemoveSystem(/datum/particleSystem/glitter, A)
				if (isobj(A))
					if (particleMaster.CheckSystemExists(/datum/particleSystem/glitter, A))
						particleMaster.RemoveSystem(/datum/particleSystem/glitter, A)

/* STOP FUCKING MURDERING THE SERVER YOU SHITASS
			reaction_turf(var/turf/T)
				if (isturf(T) && !istype(T, /turf/space))
					if (!particleMaster.CheckSystemExists(/datum/particleSystem/glitter, T))
						particleMaster.SpawnSystem(new /datum/particleSystem/glitter(T))

			reaction_obj(var/obj/O)
				if (isobj(O))
					if (!particleMaster.CheckSystemExists(/datum/particleSystem/glitter, O))
						particleMaster.SpawnSystem(new /datum/particleSystem/glitter(O))
*/
			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (prob(10))
					M.visible_message(SPAN_ALERT("<b>[M.name]</b> scratches at an itch."))
					random_brute_damage(M, 1 * mult)
					M.emote("grumble")
				if (prob(5))
					boutput(M, SPAN_ALERT("<b>So itchy!</b>"))
					random_brute_damage(M, 2 * mult)
				if (prob(1))
					M.reagents.add_reagent("histamine", 10 * src.calculate_depletion_rate(M, mult))
				..()
				return

		sparkles // doesn't do any damage
			name = "sparkles"
			id = "sparkles"
			description = "Fabulous! And harmless!"
			reagent_state = SOLID
			fluid_r = 230
			fluid_g = 230
			fluid_b = 240
			transparency = 245
			depletion_rate = 0.1
			penetrates_skin = 1

			on_add()
				var/atom/A = holder.my_atom
				if (ismob(A))
					if (!particleMaster.CheckSystemExists(/datum/particleSystem/glitter, A))
						particleMaster.SpawnSystem(new /datum/particleSystem/glitter(A))
				if (isobj(A))
					if (!particleMaster.CheckSystemExists(/datum/particleSystem/glitter, A))
						particleMaster.SpawnSystem(new /datum/particleSystem/glitter(A))

			reaction_turf(var/turf/T, var/volume)
				var/list/covered = holder.covered_turf()
				if (length(covered) > 9)
					volume = (volume/covered.len)
				if (!istype(T, /turf/space))
					if (volume >= 5)
						if (!locate(/obj/decal/cleanable/glitter/harmless) in T)
							make_cleanable(/obj/decal/cleanable/glitter/harmless,T)

			on_remove()
				var/atom/A = holder.my_atom
				if (ismob(A))
					if (particleMaster.CheckSystemExists(/datum/particleSystem/glitter, A))
						particleMaster.RemoveSystem(/datum/particleSystem/glitter, A)
				if (isobj(A))
					if (particleMaster.CheckSystemExists(/datum/particleSystem/glitter, A))
						particleMaster.RemoveSystem(/datum/particleSystem/glitter, A)

/* NO
			reaction_turf(var/turf/T)
				if (isturf(T) && !istype(T, /turf/space))
					if (!particleMaster.CheckSystemExists(/datum/particleSystem/glitter, T))
						particleMaster.SpawnSystem(new /datum/particleSystem/glitter(T))

			reaction_obj(var/obj/O)
				if (isobj(O))
					if (!particleMaster.CheckSystemExists(/datum/particleSystem/glitter, O))
						particleMaster.SpawnSystem(new /datum/particleSystem/glitter(O))
*/
		green_goop // lets you see ghosts while it's in you.  exists only for ectocooler to decay into atm
			name = "strange green goop"
			id = "green_goop"
			fluid_r = 11
			fluid_g =  255
			fluid_b = 1
			description = "A foul substance that seems to quiver oddly near certain spots."
			reagent_state = LIQUID
			depletion_rate = 0.8
			value = 3
			viscosity = 0.4
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_GHOSTVISION, src)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_GHOSTVISION, src)
				..()

		voltagen
			name = "voltagen"
			id = "voltagen"
			description = "Electricity in pure liquid form. However that works."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 128
			fluid_b = 255
			transparency = 230
			overdose = 20
			viscosity = 0.3
			minimum_reaction_temperature = T0C+100

			on_add()
				..()
				if(ismob(src.holder?.my_atom))
					RegisterSignal(holder.my_atom, COMSIG_ATTACKBY, PROC_REF(zap_dude))
					RegisterSignal(holder.my_atom, COMSIG_ATTACKHAND, PROC_REF(zap_dude_punching))

			on_remove()
				..()
				UnregisterSignal(holder.my_atom, COMSIG_ATTACKBY)
				UnregisterSignal(holder.my_atom, COMSIG_ATTACKHAND)

			grenade_effects(var/obj/grenade, var/atom/A)
				if (isliving(A))
					arcFlash(grenade, A, 1 MEGA WATT, 0.75)

			reaction_temperature(exposed_temperature, exposed_volume)
				if (reacting)
					return

				reacting = 1
				if(volume >= 5)
					var/count = 0
					for (var/mob/living/L in oview(round(min(volume/5, 5)), get_turf(holder.my_atom)))
						count++
					for (var/mob/living/L in oview(round(min(volume/5, 5)), get_turf(holder.my_atom)))
						arcFlash(holder.my_atom, L, min(75000 / count, volume * 1000 / count), stun_coeff = min(volume / 25, 1))
				else
					elecflash(holder.my_atom)
				holder.del_reagent(id)

			on_mob_life(mob/M, var/mult = 1)

				if (probmult(10))
					elecflash(M, 1, 4, 1)
				..()

			proc/zap_dude_punching(source, mob/attacker)
				src.zap_dude(source, null, attacker)
			proc/zap_dude(source, item, mob/attacker)
				if(volume >= 5 && prob(volume))
					arcFlash(holder?.my_atom, attacker,  min(75000, volume * 1000), 0.5)
					holder.remove_reagent(id, 5)

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				if (probmult(10))
					if (severity >= 2)
						M.shock(M, 100000, "chest", 1, 1)
						holder.remove_reagent(id, 20)
					else
						M.shock(M, 10000, "chest", 1, 1)
						holder.remove_reagent(id, 10)

		lumen
			name = "Lumen"
			id = "lumen"
			description = "A viscous liquid that seems to glow rather cheerfully. Perhaps applying this to things might brighten up someone's day."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 230

			proc/calculate_glow_color()
				if (holder)
					return holder.get_average_color()
				return new /datum/color(fluid_r, fluid_b, fluid_b, transparency)

			proc/light_it_up(atom/thing, var/volume)
				if(thing.RL_Attached)
					return
				if (volume < 5)
					return
				var/datum/color/mycolor = calculate_glow_color()
				var/lumen_brightness = min(1, volume / 25)
				var/datum/light/light = new /datum/light/point
				light.enable()
				light.set_color(mycolor.r / 255, mycolor.g / 255, mycolor.b / 255)
				light.set_brightness(lumen_brightness)
				light.attach(thing)
				var/life_length = rand(1 MINUTE, 3 MINUTES)
				SPAWN(life_length)
					qdel(light)

			proc/light_it_up_but_simple(atom/thing, var/volume, var/id="lumen", var/remove=1)
				if (volume < 5)
					return
				var/datum/color/mycolor = calculate_glow_color()
				var/alpha = mycolor.a * min(1, volume / 25)
				thing.add_simple_light(id, list(mycolor.r, mycolor.g, mycolor.b, alpha))
				var/life_length = rand(1 MINUTE, 3 MINUTES)
				if(remove)
					SPAWN(life_length)
						thing.remove_simple_light(id)

			on_add()
				..()
				if(src.holder && src.holder.my_atom)
					src.light_it_up_but_simple(src.holder.my_atom, src.volume, "lumen_internal", 0)

			on_remove()
				..()
				if(src.holder && src.holder.my_atom)
					src.holder.my_atom.remove_simple_light("lumen_internal")

			on_mob_life(var/mob/M, var/mult = 1)
				..()
				if(src.volume < 5)
					M.remove_simple_light("lumen_internal")
				else
					src.light_it_up_but_simple(M, src.volume, "lumen_internal", 0)

			// note that lumen light colour doesn't update when you add non-lumen reagents, I don't like that but I also don't want to change other code to make that work
			on_transfer(var/datum/reagents/source, var/datum/reagents/target, var/trans_amt)
				..()
				if(target.my_atom)
					var/target_amt = 0
					if(target.reagent_list["lumen"])
						target_amt += target.reagent_list["lumen"].volume
					src.light_it_up_but_simple(target.my_atom, target_amt, "lumen_internal", 0)
				if(source.my_atom)
					var/source_amt = src.volume - trans_amt
					if(source_amt < 5)
						source.my_atom.remove_simple_light("lumen_internal")
					else
						src.light_it_up_but_simple(source.my_atom, source_amt, "lumen_internal", 0)

			reaction_turf(var/turf/T, var/volume)
				src.light_it_up(T, volume)

			reaction_obj(var/obj/O, var/volume) // convert to new tiny lights?
				src.light_it_up_but_simple(O, volume)

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume) // convert to new tiny lights?
				. = ..()
				if (method != TOUCH)
					return
				src.light_it_up_but_simple(M, volume)


		///////////////////////////
		/// BOTANY REAGENTS ///////
		///////////////////////////

// stuff what's for plants and hydroponics

		weedkiller
			name = "atrazine"
			id = "weedkiller"
			description = "A herbicidal compound used for destroying unwanted plants."
			reagent_state = LIQUID
			fluid_r = 51
			fluid_g = 0
			fluid_b = 102
			transparency = 170
			hygiene_value = 0.3
			thirst_value = -0.098
			var/list/flushed_reagents = list("THC","CBD")

			on_mob_life(var/mob/M, var/mult = 1) // cogwerks note. making atrazine toxic
				if (!M) M = holder.my_atom
				if (istype(M, /mob/living/critter/plant))
					M.take_toxin_damage(3 * mult)
				else
					M.take_toxin_damage(2 * mult)
				flush(holder, 2 * mult, flushed_reagents)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				var/plant_touch_modifier = 0.3 //lets get some weedkiller on our plants
				if(method == TOUCH && istype(M, /mob/living/critter/plant))
					if(M.reagents)
						M.reagents.add_reagent(src.id,volume*plant_touch_modifier,src.data)
						. = 0

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				var/datum/plant/growing = P.current
				if (growing.growthmode == "weed")
					growth_tick.poison_damage += 2
					growth_tick.growth_rate -= 3

			reaction_obj(var/obj/O, var/volume)
				if (istype(O, /obj/spacevine))
					var/obj/spacevine/kudzu = O
					kudzu.herbicide(src)

		safrole
			name = "safrole"
			id = "safrole"
			description = "A common food additive with a distinctive 'candy shop' aroma."
			fluid_r = 100
			fluid_g = 100
			fluid_b = 0
			transparency = 200


		ash
			name = "ash"
			id = "ash"
			description = "Ashes to ashes, dust to dust."
			reagent_state = SOLID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			fluid_flags = FLUID_STACKING_BANNED

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.health_change += 1.6

		potash
			name = "potash"
			id = "potash"
			description = "A white crystalline compound, useful for boosting crop yields."
			reagent_state = SOLID
			fluid_r = 240
			fluid_g = 240
			fluid_b = 240

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				/*if (prob(80))
					P.growth+=2
				if (prob(80))
					P.health+=2
				*/
				var/datum/plant/growing = P.current
				var/datum/plantgenes/DNA = P.plantgenes
				growth_tick.cropsize_bonus += 0.24
				if (DNA.harvests > 1)
					growth_tick.harvests_bonus -= 0.24
				if (growing.isgrass && P.growth > 2)
					growth_tick.growth_rate -= 1.23
				growth_tick.growth_rate += 0.5
				growth_tick.health_change += 0.5

		plant_nutrients
			name = "saltpetre"
			id = "saltpetre"
			description = "Potassium nitrate, commonly used for fertilizer, cured meats and fireworks production."
			reagent_state = SOLID
			fluid_r = 240
			fluid_g = 240
			fluid_b = 240
			hunger_value = 0.048

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.growth_rate += 2.4
				growth_tick.potency_bonus += 0.5
				var/datum/plantgenes/DNA = P.plantgenes
				if (DNA.cropsize > 1)
					growth_tick.cropsize_bonus -= 0.24

		///////////////////////////
		/// BODILY FLUIDS /////////
		///////////////////////////

		blood
			name = "blood"
			id = "blood"
			description = "A substance found in many living creatures."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_b = 0
			fluid_g = 0
			transparency = 255
			value = 2
			var/congealed = FALSE //! if this blood came from a pill, stops vampires getting points from it
			hygiene_value = -2
			hunger_value = 0.068
			viscosity = 0.4
			depletion_rate = 0.4

/*			var
				blood_DNA = null
				blood_type = "O-"*/

			reaction_turf(var/turf/T, var/volume)
				var/list/covered = holder.covered_turf()
				if (length(covered) > 9)
					volume = (volume/covered.len)

				if (volume > 10)
					return 1
				if (volume >= 5)
					if (!locate(/obj/decal/cleanable/blood) in T)
						playsound(T, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, TRUE)
						var/obj/decal/cleanable/blood/blood = make_cleanable(/obj/decal/cleanable/blood,T)
						var/datum/bioHolder/bioHolder = src.data
						if(bioHolder)
							blood.blood_type = bioHolder.bloodType
							blood.blood_DNA = bioHolder.Uid
						blood.reagents.add_reagent(src.id, volume, src.data)

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed, paramslist = 0)
				. = ..()
				if (!volume_passed) return
				if (!ishuman(M)) return
				if (method == INGEST)
					if (M.mind)
						var/datum/abilityHolder/vampiric_thrall/thrallHolder = M.get_ability_holder(/datum/abilityHolder/vampiric_thrall)
						if (thrallHolder)
							var/bloodget = volume_passed / 4
							thrallHolder.points += bloodget
							holder.del_reagent(src.id)

						if (isvampire(M))
							var/datum/abilityHolder/vampire/V = M.get_ability_holder(/datum/abilityHolder/vampire)
							if (V && istype(V))
								// Blood as a reagent doesn't track DNA and blood type yet (or anymore).
								/*if (M.bioHolder && (src.blood_DNA == M.bioHolder.Uid))
									M.show_text("Injecting your own blood? Who are you kidding?", "red")
									return*/
								if (src.congealed)
									boutput(M, SPAN_ALERT("EUGH! This blood is totally congealed and worthless."))
									return 1
								if (prob(33))
									boutput(M, SPAN_ALERT("Fresh blood would be better..."))
								var/bloodget = volume_passed / 3
								var/datum/bioHolder/unlinked/bioHolder = src.data
								M.change_vampire_blood(bloodget, 0, victim = bioHolder?.weak_owner?.deref()) // vamp_blood_remaining
								V.check_for_unlocks()
								if("digestion" in paramslist)
									holder.del_reagent(src.id)
								return 0
				return 1

			// fluid todo : Hey we should have a reaction_obj that applies blood overlay

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				var/datum/plant/growing = P.current
				if (growing.growthmode == "carnivore")
					growth_tick.endurance_bonus += 0.8
					growth_tick.growth_rate += 3

			on_transfer(var/datum/reagents/source, var/datum/reagents/target, var/trans_amt)
				if (istype(target.my_atom, /obj/item/reagent_containers/pill))
					var/datum/reagent/blood/blood = target.get_reagent("blood")
					blood.congealed = TRUE

		blood/bloodc
			id = "bloodc"
			value = 3
			hygiene_value = -4
			minimum_reaction_temperature = T0C + 50

			reaction_temperature(exposed_temperature, exposed_volume)
				var/list/covered = holder.covered_turf()
				if(length(covered) < 9 || prob(2)) // no spam pls
					if (holder.my_atom)
						for (var/mob/O in AIviewers(get_turf(holder.my_atom), null))
							boutput(O, SPAN_ALERT("The blood tries to climb out of [holder.my_atom] before sizzling away!"))
						// Real world changeling tests should only happen in containers at a slow pace
						if (!ON_COOLDOWN(global, "bloodc_logging", 4 SECONDS))
							var/datum/bioHolder/bioHolder = src.data
							if(bioHolder && bioHolder.ownerName)
								logTheThing(LOG_COMBAT, bioHolder.ownerName, "Changeling blood reaction in [holder.my_atom] at [log_loc(holder.my_atom)]")
					else
						for(var/turf/t in covered)
							for (var/mob/O in AIviewers(t, null))
								boutput(O, SPAN_ALERT("The blood reacts, attempting to escape the heat before sizzling away!"))

				holder.del_reagent(id)
				holder.del_reagent("blood")

		blood/hemolymph
			name = "hemolymph"
			id = "hemolymph"
			//taste = "metallic yet slightly bitter"
			description = "Hemolymph is a blood-like bodily fluid found in many invertebrates that derives its blue-green color from the presence of copper proteins."
			reagent_state = LIQUID
			fluid_r = 4
			fluid_b = 165
			fluid_g = 144


		vomit
			name = "vomit"
			id = "vomit"
			description = "Looks like someone lost their lunch. And then collected it. Yuck."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_b = 80
			fluid_g = 255
			transparency = 255
			hygiene_value = -3
			viscosity = 0.4

			reaction_turf(var/turf/T, var/volume)
				var/list/covered = holder.covered_turf()
				if (length(covered) > 9)
					volume = (volume/covered.len)
				if (volume >= 5)
					if (!locate(/obj/decal/cleanable/vomit) in T)
						// no mob to vomit, so this gets to stay - cirr
						playsound(T, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, TRUE)
						make_cleanable( /obj/decal/cleanable/vomit,T)

		gvomit
			name = "green vomit"
			id = "gvomit"
			description = "Whoa, that can't be natural. That's horrible."
			reagent_state = LIQUID
			fluid_r = 120
			fluid_b = 120
			fluid_g = 255
			transparency = 255
			value = 2
			hygiene_value = -4
			viscosity = 0.4

			reaction_turf(var/turf/T, var/volume)
				var/list/covered = holder.covered_turf()
				if (length(covered) > 9)
					volume = (volume/covered.len)
				if (volume >= 5)
					if (!locate(/obj/decal/cleanable/greenpuke) in T)
						playsound(T, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, TRUE)
						make_cleanable( /obj/decal/cleanable/greenpuke,T)

		triplepissed
			name = "triplepissed"
			id = "triplepissed"
			description = "It's furious!"
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 50
			fluid_b = 50
			transparency = 255

			on_mob_life(var/mob/M, var/mult = 1)
				. = ..()
				if (probmult(10))
					M.set_a_intent(INTENT_HARM)
					if (ishuman(M))
						M.emote(pick("twitch", "shake", "tremble","quiver", "twitch_v"))
						if (prob(50))
							M.emote("scream")

		poo
			name = "compost"
			id = "poo"
			description = "Raw fertilizer used for gardening."
			reagent_state = SOLID
			fluid_r = 100
			fluid_g = 55
			fluid_b = 0
			transparency = 255
			hygiene_value = -5
			viscosity = 0.5
			fluid_flags = FLUID_STACKING_BANNED

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.health_change += 0.66

		big_bang_precursor
			name = "stable bose-einstein macro-condensate"
			id = "big_bang_precursor"
			description = "This is a strange viscous fluid that seems to have the properties of both a liquid and a gas."
			random_chem_blacklisted = 1
			reagent_state = LIQUID
			fluid_r = 200
			fluid_g = 190
			fluid_b = 230
			transparency = 160
			fluid_flags = FLUID_STACKING_BANNED

		big_bang
			name = "quark-gluon plasma"
			id = "big_bang"
			description = "Its... beautiful!"
			random_chem_blacklisted = 1
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 240
			fluid_b = 250
			transparency = 255
			viscosity = 0.7
			fluid_flags = FLUID_SMOKE_BANNED
			pierces_outerwear = 1//shoo, biofool

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(istype(M, /mob/dead))
					return
				#ifdef SECRETS_ENABLED
				one_with_everything(M)
				#else
				M.ex_act(1)
				#endif


			reaction_obj(var/obj/O, var/volume)
				//if (!istype(O, /obj/effects/foam)
				//	&& !istype(O, /obj/item/reagent_containers)
				//	&& !istype(O, /obj/item/chem_grenade))
				O.ex_act(1)

			on_mob_life(var/mob/M, var/mult = 1)
				..()
				#ifdef SECRETS_ENABLED
				one_with_everything(M)
				#else
				M.ex_act(1)
				if (ishuman(M))
					logTheThing(LOG_COMBAT, M, "was gibbed by reagent [name] at [log_loc(M)].")
				M.gib()
				#endif
				M.reagents.del_reagent(src.id)

		gib_juice
			// old qgp
			name = "gib juice"
			id = "gib_juice"
			description = "oof ouch owie my bones"
			random_chem_blacklisted = 1
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 0
			fluid_b = 0
			transparency = 255
			viscosity = 0.7

			pierces_outerwear = 1//shoo, biofool

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(istype(M, /mob/dead))
					return
				M.ex_act(1)


			reaction_obj(var/obj/O, var/volume)
				O.ex_act(1)

			on_mob_life(var/mob/M, var/mult = 1)
				..()
				M.ex_act(1)
				if (isliving(M))
					logTheThing(LOG_COMBAT, M, "was gibbed by reagent [name] at [log_loc(M)].")
				M.reagents.del_reagent(src.id)
				M.gib()

		cyclopentanol
			name = "cyclopentanol"
			id = "cyclopentanol"
			description = "A substance not particularly worth noting."
			reagent_state = LIQUID
			fluid_r = 10
			fluid_g = 254
			fluid_b = 254
			transparency = 50

		magnesium_chloride
			name = "magnesium chloride"
			id = "magnesium_chloride"
			description = "A white powder that's capable of binding a high amount of ammonia while on room temperature."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255

		mg_nh3_cl
			name = "magnesium-ammonium chloride"
			id = "mg_nh3_cl"
			description = "A white powder binding a high amount of ammonia. The ammonia is released when the mixture is heated above 150 degrees celsius."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255
			volatility = 2

		reversium
			name = "reversium"
			id = "reversium"
			description = "A chemical element."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 250
			fluid_b = 160
			transparency = 155
			data = null

			reaction_obj(var/obj/O)
				if (istype(O,/obj/item/clothing/gloves/yellow))
					var/obj/item/clothing/gloves/yellow/Y = O
					Y.unsulate()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				. = ..()
				M.bioHolder.AddEffect("reversed_speech", timeleft = 180)

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.bioHolder.AddEffect("reversed_speech", timeleft = 180)
				..()
				return

		butter
			name = "butter"
			id = "butter"
			description = "Closer inspection reveals that it is indeed butter." //its not
			reagent_state = LIQUID
			fluid_r = 255
			fluid_b = 0
			fluid_g = 255
			viscosity = 0.3

			reaction_turf(var/turf/target, var/volume)
				var/turf/simulated/T = target
				if (istype(T))
					if (T.wet >= 2) return
					T.wetify(2, 80 SECONDS)
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.reagents.add_reagent("cholesterol", 2.5 * src.calculate_depletion_rate(M, mult))
				..()
				return

		yee // 4 wonk
			name = "yee"
			id = "yee"
			description = "yee"
			fluid_r = 83
			fluid_g = 97
			fluid_b = 10
			transparency = 225
			penetrates_skin = 1
			var/the_bioeffect_you_had_before_it_was_affected_by_yee = null
			var/the_mutantrace_you_were_before_yee_overwrote_it = null

			on_add()
				var/atom/A = holder.my_atom
				if (ismob(A))
					var/mob/M = A
					if (!isliving(M))
						return
					M.playsound_local(M, 'sound/misc/yee_music.ogg', 50, 0) // why the fuck was this playing sound with << and to repeat forever? never do this
					if (M.bioHolder && ishuman(M))			// All mobs get the tunes, only "humans" get the scales
						var/mob/living/carbon/human/H = M
						src.the_bioeffect_you_had_before_it_was_affected_by_yee = H?.mutantrace?.name			// then write down what your whatsit was
						src.the_mutantrace_you_were_before_yee_overwrote_it = H?.mutantrace?.type		// write that down too
						if (src.the_bioeffect_you_had_before_it_was_affected_by_yee != "lizard")				// Dont make me a lizard if im already a lizard
							H.bioHolder.AddEffect("lizard", timeleft = 180)
						else
							boutput(H, "You have a strange feeling for a moment.")
						H.bioHolder.AddEffect("accent_yee", timeleft = 180)
						H.visible_message(SPAN_EMOTE("<b>[M]</b> yees."))
						playsound(H, 'sound/misc/yee.ogg', 50, TRUE)

			on_remove()
				var/atom/A = holder.my_atom
				if (ismob(A))
					var/mob/M = A
					if (M.bioHolder)
						if (src.the_bioeffect_you_had_before_it_was_affected_by_yee != "lizard")
							M.bioHolder.RemoveEffect("lizard")
						else	// I'm already a lizard!
							boutput(M, "You have a strange feeling for a moment, then it passes.")
						if (src.the_mutantrace_you_were_before_yee_overwrote_it)								// If you were a thing before...
							M.set_mutantrace(src.the_mutantrace_you_were_before_yee_overwrote_it)	// Be that thing you were
						if (src.the_bioeffect_you_had_before_it_was_affected_by_yee && src.the_bioeffect_you_had_before_it_was_affected_by_yee != "lizard")
							M.bioHolder.AddEffect(src.the_bioeffect_you_had_before_it_was_affected_by_yee)
						M.bioHolder.RemoveEffect("accent_yee")

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				M.playsound_local(M, 'sound/misc/yee_music.ogg', 50, 0)  // same comment as the other instance of this being played, yeesh
				if (M.bioHolder)
					if (src.the_bioeffect_you_had_before_it_was_affected_by_yee != "lizard")	// Just for consistency
						M.bioHolder.AddEffect("lizard", timeleft = 180)
					M.bioHolder.AddEffect("accent_yee", timeleft = 180)
				if (probmult(20))
					M.visible_message(SPAN_EMOTE("<b>[M]</b> yees."))
					playsound(M, 'sound/misc/yee.ogg', 50, TRUE)
				if (probmult(8))
					fake_attackEx(M, 'icons/effects/hallucinations.dmi', "bop-bop", "bop-bop")
				if (probmult(8))
					fake_attackEx(M, 'icons/effects/hallucinations.dmi', "yee", "yee")
				..()
				return

#define CONTENT_MULTIPLIER 5
		glucose_polymer
			name = "glucose polymer"
			id = "glucose_polymer"
			description = "A liquid polymer consisting of glucose, commonly used in extended release applications for pharmaceuticals."
			fluid_r = 200
			fluid_g = 200
			fluid_b = 200
			transparency = 225
			reagent_state = LIQUID
			depletion_rate = 1
			minimum_reaction_temperature = -INFINITY
			var/datum/reagents/contents = null
			var/hardened = 0

			disposing()
				..()
				contents = null
				hardened = 0
				reagent_state = LIQUID
				update_identifiers()

			on_add()
				..()
				if(hardened)
					update_content_max_volume()

			on_remove()
				..()
				if(hardened)
					update_content_max_volume()

			on_copy(var/datum/reagent/new_reagent)
				..()
				var/datum/reagent/glucose_polymer/GP = new_reagent
				if(!istype(GP)) return
				GP.hardened = src.hardened
				if(hardened)
					GP.create_contents()
					GP.update_content_max_volume()
					src.contents.copy_to(GP.contents)


			on_mob_life(var/mob/M, var/mult = 1)
				//TODO: transfer reagents out of the contents and into the mob
				if(hardened && contents && volume > 0)
					var/amount_to_transfer = contents.total_volume / (src.volume / (src.depletion_rate * mult))
					contents.trans_to(holder.my_atom, amount_to_transfer)
					if(contents.total_volume <= 0)
						contents = null
				..()


			reaction_temperature(exposed_temperature, exposed_volume)
				//TODO: if cold temperature, take up all the reagents in the holder into contents, calculate distribution amount based on volume
				if( exposed_temperature < (T0C - 50) && !hardened)
					// -50C, solidify polymer
					take_up_reagents()
				else if ( exposed_temperature > (T0C + 50) && hardened)
					// +50C, dissolve hardened polymer
					release_all_reagents()

			on_transfer(var/datum/reagents/source, var/datum/reagents/target, var/trans_amt)
				..()
				var/datum/reagent/glucose_polymer/receiver = target.get_reagent(src.id)
				//Already hardened polymer will harden the receiver - not the other way around (since it will only add extra volume of the reagent)
				receiver.hardened = src.hardened || receiver.hardened

				if(hardened)
					//No contents - we have created a new reagent, so it should have a new holder
					if(!receiver.contents)
						receiver.create_contents()

					DEBUG_MESSAGE("Transferring hardened polymer into [receiver.holder.my_atom]. volume: [src.volume], trans_amt: [trans_amt]")
					receiver.update_content_max_volume()

					distribute_reagents(receiver, src.volume - trans_amt, trans_amt)

					update_content_max_volume(src.volume - trans_amt)
					receiver.update_identifiers()

			proc/distribute_reagents(var/datum/reagent/glucose_polymer/other, var/my_volume, var/other_volume)
				//Ensures both glucose polymer instances have appropriate volumes
				if(!istype(other) || other_volume == 0 || !src.hardened || !other.hardened) return

				var/total = my_volume + other_volume
				var/other_multiplier = other_volume / total

				DEBUG_MESSAGE("Doing distribute_reagents, other: [other], my_volume: [my_volume], other_volume: [other_volume], other_multiplier: [other_multiplier]")

				src.contents.copy_to(other.contents, other_multiplier)
				src.contents.remove_any(src.contents.total_volume * other_multiplier)

				DEBUG_MESSAGE("After distribution: Deliver volume: [src.contents.total_volume] receiver volume: [other.contents.total_volume]")

			proc/create_contents()
				if(!contents)
					contents = new /datum/reagents(src.volume * CONTENT_MULTIPLIER)
					contents.my_atom = src.holder.my_atom

			proc/update_content_max_volume(var/volume_override = -1)
				if(src.contents)
					var/volume_to_use = volume_override > 0 ? volume_override : src.volume
					var/new_volume = volume_to_use * CONTENT_MULTIPLIER
					if(new_volume < contents.total_volume)
						contents.remove_any(contents.total_volume - new_volume)
						contents.update_total()
					contents.maximum_volume = new_volume


			proc/take_up_reagents()
				//Take in all reagents in the container
				if (hardened || (holder.total_volume - src.volume) == 0)
					//Cannot take up any further reagents when hardened or there are no other reagents in the holder
					return

				create_contents()

				//Transfer all other reagents in the holder into our contents
				var/transfer_ratio = contents.maximum_volume / (holder.total_volume - src.volume)

				for(var/reagent_id in holder.reagent_list)
					if (reagent_id != src.id)
						var/datum/reagent/current_reagent = holder.reagent_list[reagent_id]

						if (isnull(current_reagent) || current_reagent.volume == 0)
							continue

						var/transfer_amt = current_reagent.volume*transfer_ratio

						contents.add_reagent(reagent_id, transfer_amt, current_reagent.data, holder.total_temperature)
						holder.remove_reagent(reagent_id, transfer_amt)

				//Do all the holder updates
				contents.update_total()
				contents.reagents_changed()

				holder.update_total()
				holder.handle_reactions()
				holder.reagents_changed()

				//Set our state and descriptions accordingly
				hardened = 1
				update_identifiers()

			proc/release_all_reagents()
				if(contents && hardened)
					contents.trans_to_direct(src.holder, contents.total_volume)
					contents = null
					hardened = 0
					update_identifiers()

			proc/update_identifiers()
				if(hardened)
					reagent_state = SOLID
					transparency = 30

					name = "glucose polymer matrix"
					description = "A matrix composed of a glucose polymer. Commonly used in medical applications for extended release of medicine."
				else
					reagent_state = initial(reagent_state)
					transparency = initial(transparency)
					name = initial(name)
					description = initial(description)

#undef CONTENT_MULTIPLIER

		mimicillium
			name = "Mimicillium"
			id = "badmanjuice"
			description = "Just looking at this, you get the feeling that a vote for Death Badman is a vote for Death Badman."
			reagent_state = LIQUID
			penetrates_skin = 1
			depletion_rate = 2.5
			fluid_r = 0
			fluid_g = 0
			fluid_b = 255
			transparency = 255
			var/counter = 1
			value = 4

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				if (M.deathhunted)
					return
				switch(counter += (1 * mult))
					if (1 to 4)
						return ..()
					if (5 to INFINITY)
						counter = 1
						M.deathhunted = 1
						var/startx = 1
						var/starty = 1
						var/mob/badmantarget = M
						boutput(badmantarget, SPAN_NOTICE("<b>You feel a sense of dread and patriotism wash over you.</b>"))
						badmantarget.playsound_local(get_turf(badmantarget), 'sound/misc/american_patriot.ogg', 50)
						SPAWN(10 SECONDS)
							startx = badmantarget.x - rand(-11, 11)
							starty = badmantarget.y - rand(-11, 11)
							var/turf/pickedstart = locate(startx, starty, badmantarget.z)
							new /obj/badman(pickedstart, badmantarget)
				..()



		bubsium
			name = "Bubsium"
			id = "bubs"
			description = "The liquified and concentrated essence of the mysterious character Bubs."
			reagent_state = LIQUID
			penetrates_skin = 1
			depletion_rate = 2.5
			fluid_r = 255
			fluid_g = 215
			fluid_b = 0
			transparency = 255
			value = 4
			threshold = THRESHOLD_INIT
			threshold_volume = 2

			cross_threshold_over()
				if(holder?.my_atom && !istype(holder.my_atom, /turf))
					holder.my_atom.SafeScale(4,1.5)
				..()

			cross_threshold_under()
				if(holder?.my_atom && !istype(holder.my_atom, /turf))
					holder.my_atom.SafeScale(1/4,1/1.5)
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				var/our_amt = holder.get_reagent_amount(src.id)
				if(probmult(3) && ishuman(M))
					M.say("Hm!")
				if(M && our_amt > 20)
					if(M.bioHolder && !M.bioHolder.HasEffect("strong")) //was originally fat bioeffect, but that's been removed
						M.bioHolder.AddEffect("strong")
				for (var/obj/V in orange(clamp(our_amt / 5, 2,10),M))
					if (V.anchored)
						continue
					step_towards(V,M)

				for (var/mob/living/N in orange(clamp(our_amt / 5, 2,10),M))
					if (isintangible(N) || N.anchored)
						continue
					step_towards(N,M)
					if(ishuman(N) && probmult(1))
						N.say("[M.name] is an ocean of muscle.")
				..()

		toxic_fart
			name = "toxic fart"
			id = "toxic_fart"
			description = "A rancid, terrible fart."
			reagent_state = GAS
			fluid_r = 212
			fluid_g = 205
			fluid_b = 4
			transparency = 255
			data = null
			blocks_sight_gas = 1
			hygiene_value = -1
			smoke_spread_mod = 15

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				. = ..()
				if(!volume_passed)
					return
				if (M.bioHolder && M.bioHolder.HasEffect("toxic_farts"))
					return

				if (M?.reagents)
					if (prob(25))
						boutput(M, SPAN_ALERT("Oh god! The <i>smell</i>!!!"))
					M.reagents.add_reagent("poo",0.1 * volume_passed)

			very_toxic
				id = "very_toxic_fart"
				name = "very toxic fart"

				on_mob_life(var/mob/M, var/mult = 1)
					. =..()
					M.take_toxin_damage(2 * mult)
			//on_mob_life(var/mob/M, var/mult = 1)
			//	if(!M) M = holder.my_atom
			//	..()

		miasma
			name = "miasma"
			id = "miasma"
			description = "Gross miasma produced by corpse decay."
			reagent_state = GAS
			fluid_r = 160
			fluid_b = 160
			fluid_g = 25
			transparency = 95
			hygiene_value = -0.5
			smoke_spread_mod = 3


			on_add()
				if (holder && ismob(holder.my_atom))
					holder.my_atom.setStatus("miasma", duration = INFINITE_STATUS)
				if(holder.get_reagent_amount("lavender_essence") > 0)
					var/lavender_amount = src.holder.get_reagent_amount("lavender_essence")
					src.holder.remove_reagent("lavender_essence", (src.holder.get_reagent_amount("miasma")/2))
					src.holder.remove_reagent("miasma", lavender_amount*2)

			on_remove()
				if (ismob(holder.my_atom))
					holder.my_atom.delStatus("miasma")

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.poison_damage += 1

			syndicate
				name = "syndicate miasma"
				id = "miasma_s"
				description = "Gross miasma produced by unwashed nerd."
				fluid_r = 180
				fluid_b = 60
				fluid_g = 80

				on_add()
					..()
					if (holder && ismob(holder.my_atom))
						var/mob/bipbip = holder.my_atom
						bipbip.playsound_local(bipbip.loc, 'sound/musical_instruments/Vuvuzela_1.ogg', 50, 1)

		sakuride
			name = "sakuride"
			id = "sakuride"
			description = "A big pile of sakura petals!"
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 161
			fluid_b = 203
			transparency = 255

			reaction_turf(var/turf/T, var/volume)
				if (!(istype(T, /turf/space)) && (volume >= 1))
					if (!T.messy || !locate(/obj/decal/cleanable/sakura) in T)
						make_cleanable(/obj/decal/cleanable/sakura,T)

		grassgro
			name = "Grass Gro"
			id = "grassgro"
			description = "Concentrated liquid Spacegrass. Guaranteed to grow Spacegrass anywhere. "
			reagent_state = LIQUID
			fluid_r = 0
			fluid_b = 0
			fluid_g = 255
			value = 1 // Literally grass
			hygiene_value = 0.25

			reaction_turf(var/turf/target, var/volume)
				var/turf/simulated/floor/T = target

				if (istype(T))
					if (T.broken || T.burnt)
						return
					else if (T.icon_state in list("grass", "grass_eh"))
						return
					if (!T.icon_old)
						T.icon_old = T.icon_state
					//SPAWN(rand(5,12) * 10) //wait in some other fashion later
					T.grassify()
				return

		cloak_juice
			name = "cloaked panellus extract"
			id = "cloak_juice"
			description = SPAN_ALERT("ERR: SPECTROSCOPIC ANALYSIS OF THIS SUBSTANCE IS NOT POSSIBLE.")
			reagent_state = LIQUID
			fluid_r = 50
			fluid_g = 50
			fluid_b = 255
			transparency = 50
			value = 5
			hygiene_value = -3
			depletion_rate = 0.1


		fog
			name = "fog"
			id = "fog"
			description = "An inert gas that appears very thick in smoke."
			reagent_state = GAS
			fluid_r = 181
			fluid_b = 181
			fluid_g = 181
			transparency = 255
			blocks_sight_gas = 1

		iron_oxide
			name = "Iron Oxide"
			id = "iron_oxide"
			description = "Iron, artificially rusted under the effects of oxygen, acetic acid, salt and a high temperature environment."
			fluid_r = 112
			fluid_b = 40
			fluid_g = 9

		//=-=-=-=-=-=-=-=-=
		//|| C E M E N T ||
		//=-=-=-=-=-=-=-=-=

		calcium_carbonate //made from crushed/hammered/picked/reagent/extracted sea shells OR just chemical synthesis !!!ALREADY IN, DONT DOUBLE MERGE!!!
			name = "calcium carbonate"
			id = "calcium_carbonate"
			description = "A naturally occuring chemical found in seashells and certain rocks."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255

		lime //made from burnt calcium carbonate
			name = "calcium oxide"
			id = "lime"
			description = "A material made primarily of calcium oxides, with trace amounts of other minerals present. It can cause pretty severe skin irritation."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255

		gypsum //gypsum, made with waste sulfur gas and calcium carbonate or calcium oxide (sulfur + oxygen(4) + water + calcium_carbonate) !!!ALREADY IN, DONT DOUBLE MERGE!!!
			name = "calcium sulfate"
			id = "gypsum"
			description = "An inorganic chemical that has many uses in the industrial sector."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255

		silicon_dioxide //primary ingredient in sand, aside from other small rocks
			name = "silicon dioxide"
			id = "silicon_dioxide"
			description = "Also known as Silica, it is one of the main minerals found in sand."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255

		sodium_sulfate //useless right now, maybe for laundry detergent? just here so i dont have a really messy reaction
			name = "sodium sulfate"
			id = "sodium_sulfate"
			description = "A chemical compound that is used in dying textiles and manufacturing glass."
			reagent_state = SOLID
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255

		cement //parent to cut down on duplicate code
			name = "You shouldn't see this!"
			id = "cement_parent"
			description = "You shouldn't see this!"
			reagent_state = SOLID
			fluid_r = 124
			fluid_g = 124
			fluid_b = 124
			transparency = 255

		cement/perfect_cement
			name = "ultrahigh grade supercement"
			id = "perfect_cement"
			description = "A perfect mixture of different minerals and chemicals that binds with an aggregate to form a rock-solid... solid."

		cement/good_cement
			name = "high grade cement"
			id = "good_cement"
			description = "A great mixture of different minerals and chemicals that binds with an aggregate to form a rock-solid... solid."

		cement/ok_cement
			name = "cement"
			id = "okay_cement"
			description = "A mixture of different minerals and chemicals that binds with an aggregate to form a rock-solid... solid."

		cement/poor_cement
			name = "low grade cement"
			id = "poor_cement"
			description = "A poor mixture of different minerals and chemicals that binds with an aggregate to form a rock-solid... solid."

		concrete //concrete parent to cut down on duplicate code
			name = "You shouldn't see this!"
			id = "concrete_parent"
			description = "You shouldn't see this!"
			reagent_state = SOLID
			fluid_r = 124
			fluid_g = 124
			fluid_b = 124
			transparency = 255
			overdose = 70
			fluid_flags = FLUID_SMOKE_BANNED
			var/concrete_strength = 0

			reaction_turf(var/turf/T, var/volume)
				if (volume < 5)
					return
				if ((locate(/obj/concrete_wet) in T) || (locate(/obj/concrete_wall) in T))
					return
				var/obj/concrete_wet/C = new(T)
				C.c_quality = concrete_strength

		concrete/perfect_concrete
			name = "ultra high grade superconcrete"
			id = "perfect_concrete"
			description = "A perfectly formulated blend of chemical agents, water, an aggregate and cement."
			concrete_strength = 4

		concrete/good_concrete
			name = "high grade concrete"
			id = "good_concrete"
			description = "A well formulated blend of chemical agents, water, an aggregate and cement."
			concrete_strength = 3

		concrete/okay_concrete
			name = "concrete"
			id = "okay_concrete"
			description = "A blend of chemical agents, water, an aggregate and cement."
			concrete_strength = 2

		concrete/poor_concrete
			name = "low grade concrete"
			id = "poor_concrete"
			description = "A low quality blend of chemical agents, water, an aggregate and cement."
			concrete_strength = 1

		mirabilis
			name = "mirabilis"
			id = "mirabilis"
			fluid_r = 71
			fluid_g = 159
			fluid_b = 188

			on_add()
				src.RegisterSignal(src.holder, COMSIG_REAGENTS_ANALYZED, PROC_REF(analyzed))

			on_remove()
				src.UnregisterSignal(src.holder, COMSIG_REAGENTS_ANALYZED)

			proc/analyzed(source, mob/user)
				if (!issilicon(user) && !isAI(user) && !isintangible(user) && !isobserver(user)) //there's probably other things we should exclude here
					src.holder.trans_to(user, max(1, src.volume))


/obj/badman/ //I really don't know a good spot to put this guy so im putting him here, fuck you.
	name = "Senator Death Badman"
	desc = "Finally, a politician I can trust."
	icon = 'icons/misc/hydrogimmick.dmi'
	icon_state = "badman"
	layer = EFFECTS_LAYER_2
	density = 1
	anchored = UNANCHORED
	var/mob/deathtarget = null
	var/deathspeed = 3

	New(pickedstart, var/mob/badmantarget)
		deathtarget = badmantarget
		SPAWN(0) process()
		..()

	bump(atom/M as turf|obj|mob)
		if(M.density)
			M.density = 0
			SPAWN(0.4 SECONDS)
				M.density = 1 //Apparently this is a horrible stinky line of code by don't blame me, this is all the gibshark codes fault.
		SPAWN(0.1 SECONDS)
			var/turf/T = get_turf(M)
			src.x = T.x
			src.y = T.y

	proc/process()
		while (!disposed)
			if (BOUNDS_DIST(src, src.deathtarget) == 0)
				for(var/mob/O in AIviewers(src, null))
					O.show_message(SPAN_ALERT("<B>[src]</B> flips up, over and behind [deathtarget] and punches [him_or_her(deathtarget)] in the groin before rolling under the floortiles!"), 1)

				playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50,1,-1)
				animate_spin(src, prob(50) ? "L" : "R", 1, 0)
				sleep(1 SECOND)
				playsound(src.loc, pick(sounds_punch), 50, 1, -1)
				deathtarget.emote("scream")
				deathtarget.setStatusMin("stunned", 5 SECONDS)
				deathtarget.setStatusMin("knockdown", 5 SECONDS)
				deathtarget.unlock_medal("OW! MY BALLS!", 1)
				var/deathturf = get_turf(src)
				animate_slide(deathturf, 0, -24, 25)
				sleep(2 SECONDS)
				animate_slide(deathturf, 0, 0, 15)
				qdel(src)
				deathtarget.deathhunted = 0
				return
			else
				walk_towards(src, src.deathtarget, deathspeed)
				sleep(0.1 SECONDS)
