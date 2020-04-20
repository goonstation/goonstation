/obj/item/medical/medicaldiagnosis
	name = "UM EXCUSE ME WHY ARE YOU SEEING THIS PLEASE MAKE AN ISSUE AAAAA"
	desc = "*scream"
	icon_state = "stethoscope" // todo
	inhand_image_icon = "stethoscope" // nuke this awful sprite later
	icon = 'icons/obj/medicaldiagnosis.dmi' // NOO YOU CAN'T JUST FILL YOUR CODE WITH TODO MARKERS YOU NEED TO ACTUALLY DO SPRITING AND NOT JUST MAKE CODERSPRITES NOO
// haha procrastination machine go brrr
/obj/item/medical/medicaldiagnosis/stethoscope
	name = "stethoscope"
	desc = "a disc-shaped resonator attached to two earpieces for figuring out if someone has consumption or is simply suffering from the vapors."
	attack(mob/living/carbon/human/M as mob, mob/user as mob)
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
				user.visible_message("<span style=\"color:blue\"><b>[user]</b> puts [src] to [(user != M) ? "[M]'s" : "their"] chest.</span>", "<span style=\"color:blue\">You put [src] to [(user != M) ? "[M]'s" : "your"] chest and begin listening.</span>")
				if(do_after(user, (user.traitHolder.hasTrait("training_medical") ? 2 SECONDS : 4 SECONDS)) && !(user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || user.getStatusDuration("paralysis") > 0 || !isalive(user) || user.restrained()))
					if(!user.traitHolder.hasTrait("training_medical") && prob(15))
						boutput(user, "<span style=\"color:red\">You attempt to listen to [(user != M) ? "[M]'s" : "your"] lungs before realizing after a few attempts that you've been listening to [(user != M) ? "[M]'s" : "your"] [pick("liver", "kidneys", "spleen", "leg", "PDA", "eyes")], a shameful [user]</span>")
					else if(isalive(M) == false)
						boutput(user, "<span style=\"color:red\">You hear nothing inside [(user != M) ? "[M]'s" : "your (Please report this on github asap)"] lungs.</span>")
						//playsound
					else if(M.organHolder && (!M.organHolder.left_lung || !M.organHolder.right_lung))
						if(!M.organHolder.left_lung)
							boutput(user, "<span style=\"color:red\">You hear nothing on the left of [(user != M) ? "[M]'s" : "your"] lungs.</span>")
						else if(!M.organHolder.right_lung)
							boutput(user, "<span style=\"color:red\">You hear nothing on the right of [(user != M) ? "[M]'s" : "your"] lungs.</span>")
						else
							boutput(user, "<span style=\"color:red\">You hear nothing in either of [(user != M) ? "[M]'s" : "your"] lungs, other than a faint lub-dub from the heart.</span>")
					else if(M.find_ailment_by_type(/datum/ailment/disease/respiratory_failure))
						boutput(user, "<span style=\"color:red\">You hear fluid sloughing around inside [(user != M) ? "[M]'s" : "your"] lungs, interspersed with crackling noises.</span>")
						//playsound
					else if(M.reagents.has_reagent("sarin") || M.reagents.has_reagent("strychnine")) // Are they poisoned with stuff that causes bronchospasm (ADD MORE THINGS YOU NERD)
						boutput(user, "<span style=\"color:red\">You hear what sounds like a distorted, high-pitched wheeze inside [(user != M) ? "[M]'s" : "your"] lungs.</span>")
						//playsound
					else if(M.get_oxygen_deprivation() > 80) // pick from 3 awful breath sounds when I feel like adding them
						boutput(user, "<span style=\"color:red\">You hear what sounds like twitchy, labored breathing interspersed with short gasps inside [(user != M) ? "[M]'s" : "your"] lungs.</span>") // OH BOY THIS IS BAD
						//playsound
					else if(M.organHolder && ((M.organHolder.left_lung && M.organHolder.left_lung.get_damage() > 50) || (M.organHolder.right_lung && M.organHolder.right_lung.get_damage() > 50)))
						boutput(user, "<span style=\"color:red\">You hear coarse crackling noises inside [(user != M) ? "[M]'s" : "your"] lungs.</span>")
						//playsound
					else if(M.reagents.has_reagent("histamine")) // Are they poisoned with stuff that causes swelling (ADD MORE THINGS YOU NERD)
						boutput(user, "<span style=\"color:red\">You hear what sounds like low-pitched wheezing inside [(user != M) ? "[M]'s" : "your"] lungs.</span>")
						//playsound
					else if(M.reagents.has_reagent("krokodil") || M.reagents.has_reagent("morphine") || M.reagents.has_reagent("haloperidol") || M.reagents.has_reagent("ether") || (M.reagents.has_reagent("ethanol") && M.reagents.get_reagent_amount("ethanol") > 25))
						boutput(user, "<span style=\"color:blue\">You hear very slow, shallow breathing inside [(user != M) ? "[M]'s" : "your"] lungs.</span>")
						//playsound
					else if(M.reagents.has_reagent("cannabidiol") || M.reagents.has_reagent("antihistamine") || (M.reagents.has_reagent("ethanol") && M.reagents.get_reagent_amount("ethanol") < 25))
						boutput(user, "<span style=\"color:blue\">You hear slightly slow breathing inside [(user != M) ? "[M]'s" : "your"] lungs.</span>")
						//playsound
					else if((20 < M.get_oxygen_deprivation()) && (M.get_oxygen_deprivation() < 80)) // pick from 3 stressed breath sounds when I feel like adding them
						boutput(user, "<span style=\"color:blue\">You hear what sounds like hyperventilation [M.get_oxygen_deprivation() > 60 ? "With an irregular pattern" : ""] inside [(user != M) ? "[M]'s" : "your"] lungs.</span>") // oxygen low but they can still recover
					else if(M.get_oxygen_deprivation() < 20) // pick from 3 normal breath sounds when I feel like adding them
						boutput(user, "<span style=\"color:blue\">You hear normal breathing inside [(user != M) ? "[M]'s" : "your (Please report this on github asap)"] lungs.</span>")
						//playsound
					else if(M.sleeping == 1)
						boutput(user, "<span style=\"color:blue\">You hear extremely slow breathing interspersed with what sounds like light snoring inside [(user != M) ? "[M]'s" : "your"] lungs.</span>")
						//playsound
					else
						boutput(user, "Please report this on github and include the following: [iscarbon()],[ishuman()],[M.get_oxygen_deprivation()],[M.sleeping],[M.organHolder.left_lung],[M.organHolder.right_lung]. Also please include what you were doing when the bug occurred and if possible the health analyzer scan for [M]")
				else
					user.visible_message("<span style=\"color:blue\"><b>[user]</b> stops listening to [(user != M) ? "[M]'s" : "their"] chest.</span>", "<span style=\"color:blue\">You stop listening to [(user != M) ? "[M]'s" : "your"] chest.</span>")
		else
			return ..()
