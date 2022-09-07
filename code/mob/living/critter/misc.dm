
/mob/living/critter/aberration
	name = "transposed particle field"
	real_name = "transposed particle field"
	desc = "A cloud of particles transposed by some manner of dangerous science, echoing some mannerisms of their previous configuration. In layman's terms, a goddamned science ghost."
	icon_state = "aberration"
	icon_state_dead = null
	speechverb_say = "moans"
	speechverb_exclaim = "wails"
	speechverb_ask = "grumps"
	speechverb_gasp = "laments"
	speechverb_stammer = "grumps"
	speech_void = 1
	death_text = "%src% dissipates!"
	add_abilities = list(/datum/targetable/critter/envelop)

	setup_healths()
		add_hh_flesh(8, 0.25)
		add_hh_flesh_burn(8, 0.01)

	death(var/gibbed)
		..(0) // go through the normal death stuff but don't gib them
		// then basically just run remove() but we can't actually just call remove() because it calls death(), and y'know infinite loops and all that shit
		src.transforming = 1
		src.canmove = 0
		src.icon = null
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

		if (src.mind || src.client)
			src.ghostize()

		qdel(src)

	TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss, no_brute_mult = 0, no_burn_mult = 0) // last two args used to ignore the health multipliers so that these things can still take damage from stun weapons
		hit_twitch(src)
		if (nodamage)
			return
		var/datum/healthHolder/Br = get_health_holder("brute")
		if (Br)
			Br.TakeDamage(brute, no_brute_mult)
		var/datum/healthHolder/Bu = get_health_holder("burn")
		if (Bu && (burn < 0 || !is_heat_resistant()))
			Bu.TakeDamage(burn, no_burn_mult)

	attack_hand(var/mob/user)
		if (src.stat != 2)
			boutput(user, "<span class='combat'><b>Your hand passes right through! It's so cold...</b></span>")
		return

	attackby(obj/item/W, mob/living/user)
		if (src.stat == 2)
			return
		else
			if (istype(W, /obj/item/baton))
				var/obj/item/baton/B = W
				if (B.can_stun(1, user) == 1)
					user.visible_message("<span class='combat'><b>[user] shocks [src] with [B]!</b></span>", "<span class='combat'><b>While your baton passes through, [src] appears damaged!</b></span>")
					B.process_charges(-1, user)

					src.TakeDamage(null, 4, 4, no_brute_mult = 1, no_burn_mult = 1)
					return

			boutput(user, "<span class='combat'><b>[W] passes right through!</b></span>")
			return

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round((P.power*(1-P.proj_data.ks_ratio)), 1.0)

		if (P.proj_data.damage_type == D_ENERGY)
			src.TakeDamage(null, damage, damage, no_brute_mult = 1, no_burn_mult = 1)
		else
			return
