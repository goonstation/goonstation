/obj/item/wirecutters
	name = "wirecutters"
	desc = "A tool used to cut wires and bars of metal."
	icon = 'icons/obj/items/tools/wirecutters.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/wirecutters.dmi'
	icon_state = "wirecutters"

	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	tool_flags = TOOL_SNIPPING
	health = 5
	w_class = W_CLASS_SMALL

	force = 6
	throw_speed = 2
	throw_range = 9
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
	m_amt = 80
	stamina_damage = 15
	stamina_cost = 10
	stamina_crit_chance = 30
	rand_pos = 1

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (is_special)
			return ..()
		if (!src.remove_bandage(target, user) && !snip_surgery(target, user))
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
			user.visible_message(SPAN_ALERT("<b>[user.name]</b> accidentally cuts [himself_or_herself(user)] while fooling around with [src] and drops them!"))
			playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1, -6)
			user.TakeDamage(user.zone_sel.selecting, 3, 0)
			take_bleeding_damage(user, user, 3, DAMAGE_CUT)
			user.drop_item()
			return
		else
			user.visible_message("<b>[user.name]</b> snips [src].")
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1, -6)
			sleep(0.3 SECONDS)
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1, -6)
		return

/obj/item/wirecutters/vr
	icon = 'icons/obj/items/tools/wirecutters.dmi'
	icon_state = "wirecutters-vr"
	item_state = "wirecutters"

/obj/item/wirecutters/yellow
	desc = "A tool used to cut wires and bars of metal. This pair has a yellow handle."
	icon_state = "wirecutters-yellow"
	item_state = "wirecutters-yellow"

/obj/item/wirecutters/grey
	desc = "A tool used to cut wires and bars of metal. The handle is perturbingly grey."
	icon_state = "wirecutters-grey"
	item_state = "wirecutters-grey"

/obj/item/wirecutters/orange
	desc = "A tool used to cut wires and bars of metal. This pair bears a striking orange grip."
	icon_state = "wirecutters-orange"
	item_state = "wirecutters-orange"

/obj/item/wirecutters/green
	desc = "A tool used to cut wires and bars of metal. Its handle is a nice verdigris color."
	icon_state = "wirecutters-green"
	item_state = "wirecutters-green"
