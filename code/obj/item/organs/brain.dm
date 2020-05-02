/*=========================*/
/*----------Brain----------*/
/*=========================*/

/obj/item/organ/brain
	name = "brain"
	organ_name = "brain"
	desc = "A human brain, gross."
	organ_holder_name = "brain"
	organ_holder_location = "head"
	icon_state = "brain2"
	item_state = "brain"
	var/datum/mind/owner = null
	edible = 0
	module_research = list("medicine" = 1, "efficiency" = 10)
	module_research_type = /obj/item/organ/brain
	FAIL_DAMAGE = 120
	MAX_DAMAGE = 120

	disposing()
		if (owner && owner.brain == src)
			owner.brain = null
		else if (donor && donor.mind && donor.mind.brain == src)
			donor.mind.brain = null
		owner = null
		if (holder)
			holder.brain = null
		..()

	get_desc()
		if (usr && (usr.job == "Roboticist" || usr.job == "Medical Doctor" || usr.job == "Geneticist" || usr.job == "Medical Director"))
			if (src.owner && src.owner.current)
				. += "<br><span style='color:blue'>This brain is still warm.</span>"
			else
				. += "<br><span style='color:red'>This brain has gone cold.</span>"

	attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Overrides parent function to handle special case for brains. */
		var/mob/living/carbon/human/H = M
		if (!src.can_attach_organ(H, user))
			return 0

		var/obj/item/organ/organ_location = H.organHolder.get_organ("head")

		if (!organ_location)
			boutput(user, "<span style=\"color:blue\">Where are you putting that again? There's no head.</span>")
			return null

		if (!headSurgeryCheck(H))
			boutput(user, "<span style=\"color:blue\">You're going to need to remove that mask/helmet/glasses first.</span>")
			return null

		if (!H.organHolder.get_organ("brain") && H.organHolder.head.scalp_op_stage >= 4.0)
			if (!H.organHolder.get_organ("skull"))
				boutput(user, "<span style=\"color:blue\">There's no skull in there to hold the brain in place.</span>")
				return null

			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

			H.tri_message("<span style=\"color:red\"><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] head!</span>",\
			user, "<span style=\"color:red\">You [fluff] [src] into [user == H ? "your" : "[H]'s"] head!</span>",\
			H, "<span style=\"color:red\">[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your head!</span>")

			if (user.find_in_hand(src))
				user.u_equip(src)
			H.organHolder.receive_organ(src, "brain", 3.0)
			H.organHolder.head.scalp_op_stage = 3.0
			return 1

		return 0

	proc/setOwner(var/datum/mind/mind)
		if (!mind)
			return
		if(inafterlifebar(mind.current)) // No changing owners af this is happening in the afterlife
			return
		if (mind.brain)
			var/obj/item/organ/brain/brain = mind.brain
			brain.owner = null
		mind.brain = src
		owner = mind

/obj/item/organ/brain/synth
	name = "synthbrain"
	item_state = "plant"
	desc = "An artificial mass of grey matter. Not actually, as one might assume, very good at thinking."
	made_from = "pharosium"

	New()
		..()
		src.icon_state = pick("plant_brain", "plant_brain_bloom")

/obj/item/organ/brain/latejoin
	name = "Intelligence Formation Chip"
	icon_state = "late_brain"
	item_state = "late_brain"
	desc = "A mess of wires and sillicon that can spontaniously create artifical intelligence."
	created_decal = /obj/decal/cleanable/oil
	var/activated = 0

/obj/item/organ/brain/ai
	name = "neural net processor"
	desc = "A heavily augmented human brain, upgraded to deal with the large amount of information an AI unit must process."
	icon_state = "ai_brain"
	item_state = "ai_brain"
	created_decal = /obj/decal/cleanable/oil
	made_from = "pharosium"

/obj/item/organ/brain/martian
	name = "squishy lump"
	desc = "A martian brain. At least, it seems like a brain. It could be a heart for all you know."
	icon_state = "martian_brain"
	item_state = "martian_brain"
	created_decal = /obj/decal/cleanable/martian_viscera/fluid
	made_from = "viscerite"

/obj/item/organ/brain/flockdrone
	name = "odd crystal"
	desc = "Flickers of energy still trace around inside it. It feels oddly warm to the touch."
	icon_state = "flockdrone_brain"
	item_state = "flockdrone_brain"
	created_decal = /obj/decal/cleanable/flockdrone_debris/fluid
	made_from = "gnesis"

	on_life()
		var/mob/living/M = holder.donor
		if(!M || !ishuman(M)) // flockdrones shouldn't have these problems
			return
		if(M.client && (isnull(M.client.color) || M.client.color == "#FFFFFF"))
			animate(M.client, color=fuckedUpFlockVisionColorMatrix, time=900, easing=SINE_EASING) // ~ 1.5 minutes to complete
		if(prob(3))
			var/list/sounds = list("sound/machines/ArtifactFea1.ogg", "sound/machines/ArtifactFea2.ogg", "sound/machines/ArtifactFea3.ogg",
				"sound/misc/flockmind/flockmind_cast.ogg", "sound/misc/flockmind/flockmind_caw.ogg",
				"sound/misc/flockmind/flockdrone_beep1.ogg", "sound/misc/flockmind/flockdrone_beep2.ogg", "sound/misc/flockmind/flockdrone_beep3.ogg", "sound/misc/flockmind/flockdrone_beep4.ogg",
				"sound/misc/flockmind/flockdrone_grump1.ogg", "sound/misc/flockmind/flockdrone_grump2.ogg", "sound/misc/flockmind/flockdrone_grump3.ogg",
				"sound/effects/radio_sweep1.ogg", "sound/effects/radio_sweep2.ogg", "sound/effects/radio_sweep3.ogg", "sound/effects/radio_sweep4.ogg", "sound/effects/radio_sweep5.ogg")
			M.playsound_local(get_turf(M), pick(sounds), 20, 1)
			boutput(M, "<span class='flocksay italics'><i>... [pick_string("flockmind.txt", "brain")] ...</i></span>")
