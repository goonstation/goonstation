/obj/item/medical/medicaldiagnosis
	name = "UM EXCUSE ME WHY ARE YOU SEEING THIS PLEASE MAKE AN ISSUE AAAAA"
	desc = "*scream"
	icon_state = "stethoscope" // todo
	inhand_image_icon = "stethoscope" // todo
	icon = 'icons/obj/medicaldiagnosis.dmi'

/obj/item/medical/medicaldiagnosis/stethoscope
	name = "stethoscope"
	desc = "a disc-shaped resonator attached to two earpieces for figuring out if someone has consumption or is simply suffering from the vapors."
	attack(mob/M as mob, mob/user as mob)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(user.a_intent == "help")
				if ((user.bioHolder.HasEffect("clumsy") || user.get_brain_damage() >= 60) && prob(50) || (!user.traitHolder.hasTrait("training_medical") && prob(2)))
					user.visible_message("<span style=\"color:red\"><b>[user]</b> stabs themselves in the ears with [src]!</span>", "<span style=\"color:red\">You stab yourself in the ears with [src]!</span>")
					user.apply_sonic_stun(0, 0, 0, 0, 0, 12, 6)
					take_bleeding_damage(user, user, 15)
				else
					/* Order for this stuff:
					Lung failure
					Sarin/Strychnine
					Severe Oxygen Loss
					Lung damage
					Other Poisons
					Drugs
					Light oxygen loss
					Anything else
					*/
					user.tri_message("<span style=\"color:blue\"><b>[user]</b> puts [src] to [(user != H) ? "[H]'s" : "their"] chest.</span>", user, "<span style=\"color:blue\">You put [src] to [(user != H) ? "[H]'s" : "your"] chest and begin listening.</span>", H, "<span style=\"color:blue\">[user] puts [src] to your chest and begins listening intently.</span>")
					if(do_after(user, (user.traitHolder.hasTrait("training_medical") ? 2 SECONDS : 4 SECONDS)) && !(user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || user.getStatusDuration("paralysis") > 0 || !isalive(user) || user.restrained()))
						if(!user.traitHolder.hasTrait("training_medical") && prob(15))
							boutput(user, "<span style=\"color:red\">You attempt to listen to [(user != H) ? "[H]'s" : "your"] lungs before realizing after a few attempts that you've been listening to [(user != H) ? "[H]'s" : "your"] [pick("liver", "kidneys", "spleen", "leg", "PDA", "eyes")], a shameful [user]</span>")
						else
							if(isalive(H) == false)
								boutput(user, "<span style=\"color:red\">You hear nothing inside [(user != H) ? "[H]'s" : "your (Please report this on github asap)"] lungs.</span>")
							else
								if(H.organHolder && (!H.organHolder.left_lung || !H.organHolder.right_lung))
									if(!H.organHolder.left_lung && !H.organHolder.right_lung)
										boutput(user, "<span style=\"color:red\">You hear nothing in either of [(user != H) ? "[H]'s" : "your"] lungs, other than a faint lub-dub from the heart.</span>")
									else if(!H.organHolder.left_lung)
										boutput(user, "<span style=\"color:red\">You hear nothing on the left of [(user != H) ? "[H]'s" : "your"] lungs.</span>")
									else if(!H.organHolder.right_lung)
										boutput(user, "<span style=\"color:red\">You hear nothing on the right of [(user != H) ? "[H]'s" : "your"] lungs.</span>")
								if(H.organHolder && (H.organHolder.left_lung.robotic || H.organHolder.right_lung.robotic))
									if(H.organHolder.left_lung.robotic && H.organHolder.right_lung.robotic)
										boutput(user, "<span style=\"color:red\">You hear the pronounced whirr of two airpumps in your [(user != H) ? "[H]'s" : "your"] lungs.</span>")
									else if(H.organHolder.left_lung.robotic)
										boutput(user, "<span style=\"color:red\">You hear the faint whirr of an airpump on the left of [(user != H) ? "[H]'s" : "your"] lungs.</span>")
									else if(H.organHolder.right_lung.robotic)
										boutput(user, "<span style=\"color:red\">You hear the faint whirr of an airpump on the right of [(user != H) ? "[H]'s" : "your"] lungs.</span>")
								if(H.find_ailment_by_type(/datum/ailment/disease/respiratory_failure))
									boutput(user, "<span style=\"color:red\">You hear fluid sloughing around inside [(user != H) ? "[H]'s" : "your"] lungs, interspersed with crackling noises.</span>")
									playsound(user, "sound/effects/cracklesstethoscope.ogg", 40, 0, -6)
								else if(H.reagents.has_reagent("sarin") || H.reagents.has_reagent("strychnine") ||  H.reagents.has_reagent("coniine"))
									boutput(user, "<span style=\"color:red\">You hear what sounds like a distorted, high-pitched wheeze inside [(user != H) ? "[H]'s" : "your"] lungs.</span>")
									playsound(user, "sound/effects/hyperventstethoscope.ogg", 40, 0, -6)
								else if(H.get_oxygen_deprivation() > 80)
									boutput(user, "<span style=\"color:red\">You hear what sounds like twitchy, labored breathing interspersed with short gasps inside [(user != H) ? "[H]'s" : "your"] lungs.</span>") // OH BOY THIS IS BAD
									playsound(user, "sound/effects/distortedfasthyperstethoscope.ogg", 40, 0, -6)
								else if(H.organHolder && ((H.organHolder.left_lung && H.organHolder.left_lung.get_damage() > 50) || (H.organHolder.right_lung && H.organHolder.right_lung.get_damage() > 50)))
									boutput(user, "<span style=\"color:red\">You hear coarse crackling noises inside [(user != H) ? "[H]'s" : "your"] lungs.</span>")
									playsound(user, "sound/effects/cracklesstethoscope.ogg", 40, 0, -6)
								else if(H.reagents.has_reagent("histamine"))
									boutput(user, "<span style=\"color:red\">You hear what sounds like low-pitched wheezing inside [(user != H) ? "[H]'s" : "your"] lungs.</span>")
									playsound(user, "sound/effects/stridorstethoscope.ogg", 40, 0, -6)
								else if(H.reagents.has_reagent("krokodil") || H.reagents.has_reagent("morphine") || H.reagents.has_reagent("haloperidol") || H.reagents.has_reagent("ether") || (H.reagents.has_reagent("ethanol") && H.reagents.get_reagent_amount("ethanol") > 25))
									boutput(user, "<span style=\"color:blue\">You hear very slow, shallow breathing inside [(user != H) ? "[H]'s" : "your"] lungs.</span>")
									playsound(user, "sound/effects/sleepstethoscope.ogg", 40, 0, -6) // reusing because the sounds are similar
								else if(H.reagents.has_reagent("cannabidiol") || H.reagents.has_reagent("antihistamine") || (H.reagents.has_reagent("ethanol") && H.reagents.get_reagent_amount("ethanol") < 25))
									boutput(user, "<span style=\"color:blue\">You hear slightly slow breathing inside [(user != H) ? "[H]'s" : "your"] lungs.</span>")
									playsound(user, "sound/effects/sleepstethoscope.ogg", 40, 0, -6) // reusing because the sounds are similar
								else if(H.reagents.has_reagent("epinephrine") || H.reagents.has_reagent("methamphetamine") || H.reagents.has_reagent("crank") || H.hasStatus("stimulants") || H.reagents.has_reagent("energydrink") )
									boutput(user, "<span style=\"color:blue\">You hear fast breathing inside [(user != H) ? "[H]'s" : "your"] lungs.</span>")
									playsound(user, "sound/effects/hyperventstethoscope.ogg", 40, 0, -6) // reusing because the sounds are similar
								else if((20 < H.get_oxygen_deprivation()) && (H.get_oxygen_deprivation() < 80))
									boutput(user, "<span style=\"color:blue\">You hear what sounds like hyperventilation [H.get_oxygen_deprivation() > 60 ? "with an irregular pattern" : ""] inside [(user != H) ? "[H]'s" : "your"] lungs.</span>") // oxygen low but they can still recover
									if(H.get_oxygen_deprivation() < 60)
										playsound(user, "sound/effects/hyperventstethoscope.ogg", 40, 0, -6)
									else
										playsound(user, "sound/effects/hyperventstethoscope2.ogg", 40, 0, -6)
								else if(H.get_oxygen_deprivation() < 20)
									boutput(user, "<span style=\"color:blue\">You hear normal breathing inside [(user != H) ? "[H]'s" : "your"] lungs.</span>")
									playsound(user, "sound/effects/normstethoscope.ogg", 40, 0, -6)
								else if(H.sleeping == 1)
									boutput(user, "<span style=\"color:blue\">You hear extremely slow breathing interspersed with what sounds like light snoring inside [(user != H) ? "[H]'s" : "your (Please report this on github asap)"] lungs.</span>")
									playsound(user, "sound/effects/sleepstethoscope.ogg", 40, 0, -6)
								else
									boutput(user, "Something has gone wrong, don't worry, it's not your fault! Report this on github and please include what you were doing when the bug occurred and if possible the health analyzer scan for [H]")
					user.visible_message("<span style=\"color:blue\"><b>[user]</b> stops listening to [(user != H) ? "[H]'s" : "their"] chest.</span>", "<span style=\"color:blue\">You stop listening to [(user != H) ? "[H]'s" : "your"] chest.</span>")
			else
				return ..()
		else
			return ..()
