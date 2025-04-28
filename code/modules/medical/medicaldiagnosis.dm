/obj/item/medicaldiagnosis
	name = "UM EXCUSE ME WHY ARE YOU SEEING THIS PLEASE MAKE AN ISSUE AAAAA"
	desc = "*scream"
	icon_state = "stethoscope" // todo
	inhand_image_icon = "stethoscope" // todo
	icon = 'icons/obj/medicaldiagnosis.dmi'

/obj/item/medicaldiagnosis/stethoscope
	name = "stethoscope"
	desc = "a disc-shaped resonator attached to two earpieces for figuring out if someone has consumption or is simply suffering from the vapors."
	icon = 'icons/obj/medicaldiagnosis.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "stethoscope"
	icon_state = "stethoscope"
	stamina_damage = 3
	stamina_cost = 3
	stamina_crit_chance = 3
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 20

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(ishuman(target) && can_act(user))
			var/mob/living/carbon/human/H = target
			if(user.a_intent == "help")
				if ((user.bioHolder.HasEffect("clumsy") || user.get_brain_damage() >= 60) && prob(50) || (!user.traitHolder.hasTrait("training_medical") && prob(2)))
					user.visible_message(SPAN_ALERT("<b>[user]</b> stabs themselves in the ears with [src]!"), SPAN_ALERT("You stab yourself in the ears with [src]!"))
					user.apply_sonic_stun(0, 0, 0, 0, 0, 12, 6)
					take_bleeding_damage(user, user, 15)
				else
					/* Order for this stuff:
					Lung failure
					Saxitoxin/Strychnine
					Severe Oxygen Loss
					Lung damage
					Other Poisons
					Drugs
					Light oxygen loss
					Anything else
					*/
					user.tri_message(H, SPAN_NOTICE("<b>[user]</b> puts [src] to [(user != H) ? "[H]'s" : "their"] chest."),
						SPAN_NOTICE("You put [src] to [(user != H) ? "[H]'s" : "your"] chest and begin listening."),
						SPAN_NOTICE("[user] puts [src] to your chest and begins listening intently."))
					if(do_after(user, (user.traitHolder.hasTrait("training_medical") ? 2 SECONDS : 4 SECONDS)))
						if(!user.traitHolder.hasTrait("training_medical") && prob(15))
							boutput(user, SPAN_ALERT("You attempt to listen to [(user != H) ? "[H]'s" : "your"] lungs before realizing after a few attempts that you've been listening to [(user != H) ? "[H]'s" : "your"] [pick("liver", "kidneys", "spleen", "leg", "PDA", "eyes")], a shameful [user]"))
						else
							if(!isalive(H))
								boutput(user, SPAN_ALERT("You hear nothing inside [(user != H) ? "[H]'s" : "your (Please report this on github asap)"] lungs."))
							else
								if(H.organHolder && (!H.organHolder.left_lung || !H.organHolder.right_lung))
									if(!H.organHolder.left_lung && !H.organHolder.right_lung)
										boutput(user, SPAN_ALERT("You hear nothing in either of [(user != H) ? "[H]'s" : "your"] lungs, other than a faint lub-dub from the heart."))
									else if(!H.organHolder.left_lung)
										boutput(user, SPAN_ALERT("You hear nothing on the left of [(user != H) ? "[H]'s" : "your"] lungs."))
									else if(!H.organHolder.right_lung)
										boutput(user, SPAN_ALERT("You hear nothing on the right of [(user != H) ? "[H]'s" : "your"] lungs."))
								if(H.organHolder && (H.organHolder.left_lung.robotic || H.organHolder.right_lung.robotic))
									if(H.organHolder.left_lung.robotic && H.organHolder.right_lung.robotic)
										boutput(user, SPAN_ALERT("You hear the pronounced whirr of two airpumps in your [(user != H) ? "[H]'s" : "your"] lungs."))
									else if(H.organHolder.left_lung.robotic)
										boutput(user, SPAN_ALERT("You hear the faint whirr of an airpump on the left of [(user != H) ? "[H]'s" : "your"] lungs."))
									else if(H.organHolder.right_lung.robotic)
										boutput(user, SPAN_ALERT("You hear the faint whirr of an airpump on the right of [(user != H) ? "[H]'s" : "your"] lungs."))
								if(H.find_ailment_by_type(/datum/ailment/disease/respiratory_failure))
									boutput(user, SPAN_ALERT("You hear fluid sloughing around inside [(user != H) ? "[H]'s" : "your"] lungs, interspersed with crackling noises."))
									user.playsound_local(user, 'sound/effects/cracklesstethoscope.ogg', 40, 0, -6)
								else if(H.reagents.has_reagent("saxitoxin") || H.reagents.has_reagent("strychnine") ||  H.reagents.has_reagent("coniine"))
									boutput(user, SPAN_ALERT("You hear what sounds like a distorted, high-pitched wheeze inside [(user != H) ? "[H]'s" : "your"] lungs."))
									user.playsound_local(user, 'sound/effects/hyperventstethoscope.ogg', 40, 0, -6)
								else if(H.get_oxygen_deprivation() > 80)
									boutput(user, SPAN_ALERT("You hear what sounds like twitchy, labored breathing interspersed with short gasps inside [(user != H) ? "[H]'s" : "your"] lungs.")) // OH BOY THIS IS BAD
									user.playsound_local(user, 'sound/effects/distortedfasthyperstethoscope.ogg', 40, 0, -6)
								else if(H.organHolder && ((H.organHolder.left_lung && H.organHolder.left_lung.get_damage() > 50) || (H.organHolder.right_lung && H.organHolder.right_lung.get_damage() > 50)))
									boutput(user, SPAN_ALERT("You hear coarse crackling noises inside [(user != H) ? "[H]'s" : "your"] lungs."))
									user.playsound_local(user, 'sound/effects/cracklesstethoscope.ogg', 40, 0, -6)
								else if(H.reagents.has_reagent("histamine"))
									boutput(user, SPAN_ALERT("You hear what sounds like low-pitched wheezing inside [(user != H) ? "[H]'s" : "your"] lungs."))
									user.playsound_local(user, 'sound/effects/stridorstethoscope.ogg', 40, 0, -6)
								else if(H.reagents.has_reagent("krokodil") || H.reagents.has_reagent("morphine") || H.reagents.has_reagent("haloperidol") || H.reagents.has_reagent("ether") || (H.reagents.has_reagent("ethanol") && H.reagents.get_reagent_amount("ethanol") > 25))
									boutput(user, SPAN_NOTICE("You hear very slow, shallow breathing inside [(user != H) ? "[H]'s" : "your"] lungs."))
									user.playsound_local(user, 'sound/effects/sleepstethoscope.ogg', 40, 0, -6) // reusing because the sounds are similar
								else if(H.reagents.has_reagent("cannabidiol") || H.reagents.has_reagent("antihistamine") || (H.reagents.has_reagent("ethanol") && H.reagents.get_reagent_amount("ethanol") < 25))
									boutput(user, SPAN_NOTICE("You hear slightly slow breathing inside [(user != H) ? "[H]'s" : "your"] lungs."))
									user.playsound_local(user, 'sound/effects/sleepstethoscope.ogg', 40, 0, -6) // reusing because the sounds are similar
								else if(H.reagents.has_reagent("epinephrine") || H.reagents.has_reagent("methamphetamine") || H.reagents.has_reagent("crank") || H.hasStatus("stimulants") || H.reagents.has_reagent("energydrink") )
									boutput(user, SPAN_NOTICE("You hear fast breathing inside [(user != H) ? "[H]'s" : "your"] lungs."))
									user.playsound_local(user, 'sound/effects/hyperventstethoscope.ogg', 40, 0, -6) // reusing because the sounds are similar
								else if((20 < H.get_oxygen_deprivation()) && (H.get_oxygen_deprivation() < 80))
									boutput(user, SPAN_NOTICE("You hear what sounds like hyperventilation [H.get_oxygen_deprivation() > 60 ? "with an irregular pattern" : ""] inside [(user != H) ? "[H]'s" : "your"] lungs.")) // oxygen low but they can still recover
									if(H.get_oxygen_deprivation() < 60)
										user.playsound_local(user, 'sound/effects/hyperventstethoscope.ogg', 40, 0, -6)
									else
										user.playsound_local(user, 'sound/effects/hyperventstethoscope2.ogg', 40, 0, -6)
								else if(H.get_oxygen_deprivation() < 20)
									boutput(user, SPAN_NOTICE("You hear normal breathing inside [(user != H) ? "[H]'s" : "your"] lungs."))
									user.playsound_local(user, 'sound/effects/normstethoscope.ogg', 40, 0, -6)
								else if(H.sleeping == 1)
									boutput(user, SPAN_NOTICE("You hear extremely slow breathing interspersed with what sounds like light snoring inside [(user != H) ? "[H]'s" : "your (Please report this on github asap)"] lungs."))
									user.playsound_local(user, 'sound/effects/sleepstethoscope.ogg', 40, 0, -6)
								else
									boutput(user, "Something has gone wrong, don't worry, it's not your fault! Report this on github and please include what you were doing when the bug occurred and if possible the health analyzer scan for [H]")
					user.visible_message(SPAN_NOTICE("<b>[user]</b> stops listening to [(user != H) ? "[H]'s" : "their"] chest."), SPAN_NOTICE("You stop listening to [(user != H) ? "[H]'s" : "your"] chest."))
			else
				return ..()
		else
			return ..()
