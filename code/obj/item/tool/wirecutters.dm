/obj/item/wirecutters
	name = "wirecutters"
	desc = "A tool used to cut wires and bars of metal."
	icon = 'icons/obj/items/tools/wirecutters.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/wirecutters.dmi'
	icon_state = "wirecutters"

	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	tool_flags = TOOL_SNIPPING
	w_class = 2.0

	force = 6.0
	throw_speed = 2
	throw_range = 9
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
	m_amt = 80
	stamina_damage = 15
	stamina_cost = 10
	stamina_crit_chance = 30
	module_research = list("tools" = 4, "metals" = 1)
	rand_pos = 1

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)

	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if (!src.remove_bandage(M, user) && !snip_surgery(M, user))
			return ..()

	attack_self(mob/user as mob)
		var/fail_chance = 8
		if (!iscarbon(user))
			return
		if (user.bioHolder.HasEffect("clumsy"))
			fail_chance = 33
		if (iscluwne(user))
			fail_chance = 100
		if (prob(fail_chance))
			user.visible_message("<span class='alert'><b>[user.name]</b> accidentally cuts [himself_or_herself(user)] while fooling around with [src] and drops them!</span>")
			playsound(src.loc, "sound/impact_sounds/Flesh_Stab_1.ogg", 50, 1, -6)
			user.TakeDamage(user.zone_sel.selecting, 3, 0)
			take_bleeding_damage(user, user, 3, DAMAGE_CUT)
			user.drop_item()
			return
		else
			user.visible_message("<b>[user.name]</b> snips [src].")
			playsound(src.loc, "sound/items/Wirecutter.ogg", 50, 1, -6)
			sleep(0.3 SECONDS)
			playsound(src.loc, "sound/items/Wirecutter.ogg", 50, 1, -6)
		return

/obj/item/wirecutters/vr
	icon = 'icons/obj/items/tools/wirecutters.dmi'
	icon_state = "wirecutters-vr"
	item_state = "wirecutters"
