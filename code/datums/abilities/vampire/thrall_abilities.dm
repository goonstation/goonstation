/datum/targetable/vampiric_thrall/speak
	name = "Speak"
	desc = "Telepathically speak to your master and your fellow ghouls."
	icon_state = "thrallspeak"
	targeted = 0
	target_nodamage_check = 1
	max_range = 1
	cooldown = 0
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 0
	restricted_area_check = 0
	unlock_message = ""

	incapacitation_check()
		.= 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampiric_thrall/H = holder

		if (!M)
			return 1

		var/message = html_encode(input("Choose something to say:","Enter Message.","") as null|text)
		if (!message)
			return
		logTheThing("say", M, M.name, "[message]")

		if (!H.master)
			boutput(M, __red("Your link to your master has been severed!"))
			return 1

		.= H.msg_to_master(message)

		return 0

// borrows some pinpointer code so apologies for any garbage
/datum/abilityHolder/vampiric_thrall/proc/do_tracking()
	set waitfor = FALSE
	var/datum/targetable/vampiric_thrall/track_master/ability = src.getAbility(/datum/targetable/vampiric_thrall/track_master)
	var/active = ability.active
	var/atom/movable/hudarrow = ability.hudarrow
	var/mob/living/M = ability.holder.owner
	var/datum/abilityHolder/vampiric_thrall/H = ability.holder

	animate(hudarrow, alpha=127, time=1 SECOND)
	while(active)
		if(!active || !H.master)
			break
		var/turf/ST = get_turf(M)
		var/turf/T = get_turf(H.master.owner)
		if(!ST || !T || ST.z != T.z)
			boutput(M, "<span class='alert'>Your master is too far away to track!</span>")
			break
		var/ang = get_angle(get_turf(M), get_turf(H.master.owner))
		var/dist = GET_DIST(M, H.master.owner)
		var/hudarrow_dist = 16 + 32 / (1 + 3 ** (3 - dist / 10))
		var/matrix/MX = matrix()
		var/hudarrow_scale = 0.6 + 0.4 / (1 + 3 ** (3 - dist / 10))
		MX = MX.Scale(hudarrow_scale, hudarrow_scale)
		MX = MX.Turn(ang)
		if(dist == 0)
			hudarrow_dist += 9
			MX.Turn(180) // point at yourself :)
		MX = MX.Translate(hudarrow_dist * sin(ang), hudarrow_dist * cos(ang))
		animate(hudarrow, transform=MX, time=0.5 SECONDS, flags=ANIMATION_PARALLEL)
		sleep(0.5 SECONDS)
	ability.active = 0
	animate(hudarrow, alpha=0, time=1 SECOND)

/datum/targetable/vampiric_thrall/track_master
	name = "Locate Master"
	desc = "Toggles your innate sense for locating your master."
	icon_state = "locatevamp"
	targeted = 0
	target_nodamage_check = 1
	max_range = 1
	cooldown = 0
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 0
	restricted_area_check = 0
	unlock_message = ""
	var/active = 0
	var/atom/movable/hudarrow
	var/hudarrow_color = "#cc2828"

	incapacitation_check()
		.= 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampiric_thrall/H = holder

		if (!M)
			return 1

		if (!H.master)
			boutput(M, __red("You can't seem to sense your master's lifeforce!"))
			return 1

		if (!active)
			active = 1
		else
			active = 0
		H.do_tracking(M, H, hudarrow, active)
		boutput(M, "<span class='notice'>[active ? "Now" : "No longer"] tracking your master.</span>")
		return 0

	onAttach(datum/abilityHolder/H)
		var/mob/living/M = holder.owner
		if(!hasvar(M, "hud"))
			return
		var/datum/hud/hud = M:hud
		if(isnull(hudarrow))
			hudarrow = hud.create_screen("", "", 'icons/obj/items/pinpointers.dmi', "hudarrow", "CENTER, CENTER")
			hudarrow.mouse_opacity = 0
			hudarrow.appearance_flags = 0
			hudarrow.alpha = 0
			hudarrow.color = hudarrow_color
		else
			hud.add_object(hudarrow)
		return
