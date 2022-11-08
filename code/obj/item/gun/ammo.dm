//////////////////////////////// Parent ////////////////////////////

/obj/item/ammo
	name = "ammo"
	var/sname = "Generic Ammo"
	icon = 'icons/obj/items/ammo.dmi'
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "syringe_kit"
	m_amt = 40000
	g_amt = 0
	throwforce = 2
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 20
	var/datum/projectile/ammo_type
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 5
	inventory_counter_enabled = 1

	proc
		swap(var/obj/item/ammo/A)
			return

		use(var/amt = 0)
			return 0

/////////////////////////////// Bullets for kinetic firearms /////////////////////////////////

	// caliber list: update as needed
	// 0.223 - assault rifle
	// 0.308 - rifles
	// 0.355 - pistol (9mm)
	// 0.357 - revolver
	// 0.38 - detective
	// 0.40 - blowgun
	// 0.41 - derringer
	// 0.72 - shotgun shell, 12ga
	// 0.787 - 20mm cannon round
	// 1.57 - 40mm grenade shell
	// 1.58 - RPG-7 (Tube is 40mm too, though warheads are usually larger in diameter.)

/obj/item/ammo/bullets
	name = "Ammo box"
	sname = "Bullets"
	desc = "A box of ammo!"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 40000
	g_amt = 0
	var/amount_left = 0
	var/max_amount = 1000
	var/unusualCell
	/// TRUE if this ammo can be refilled from an ammo bag. Used to prevent duping
	var/refillable = TRUE
	ammo_type = new/datum/projectile/bullet

	var/ammo_cat = null
	var/icon_dynamic = 0 // For dynamic desc and/or icon updates (Convair880).
	var/icon_short = null // If dynamic = 1, the short icon_state has to be specified as well.
	var/icon_empty = null

	// This is needed to avoid duplicating empty magazines (Convair880).
	var/delete_on_reload = 0
	var/force_new_current_projectile = 0 //for custom grenade shells

	var/sound_load = 'sound/weapons/gunload_light.ogg'

	New()
		..()
		SPAWN(2 SECONDS)
			if (!src.disposed)
				src.UpdateIcon() // So we get dynamic updates right off the bat. Screw static descs.
		return

	use(var/amt = 0)
		if(amount_left >= amt)
			amount_left -= amt
			UpdateIcon()
			return 1
		else
			src.UpdateIcon()
			return 0

	attackby(obj/b, mob/user)
		if(istype(b, /obj/item/gun/kinetic) && b:allowReverseReload)
			b.Attackby(src, user)
		else if(b.type == src.type)
			var/obj/item/ammo/bullets/A = b
			if(A.amount_left<1)
				user.show_text("There's no ammo left in [A.name].", "red")
				return
			if(src.amount_left>=src.max_amount)
				user.show_text("[src] is full!", "red")
				return

			while ((A.amount_left > 0) && (src.amount_left < src.max_amount))
				A.amount_left--
				src.amount_left++
			if ((A.amount_left < 1) && (src.amount_left < src.max_amount))
				A.UpdateIcon()
				src.UpdateIcon()
				if (A.delete_on_reload)
					qdel(A) // No duplicating empty magazines, please (Convair880).
				user.visible_message("<span class='alert'>[user] refills [src].</span>", "<span class='alert'>There wasn't enough ammo left in [A.name] to fully refill [src]. It only has [src.amount_left] rounds remaining.</span>")
				return // Couldn't fully reload the gun.
			if ((A.amount_left >= 0) && (src.amount_left == src.max_amount))
				A.UpdateIcon()
				src.UpdateIcon()
				if (A.amount_left == 0)
					if (A.delete_on_reload)
						qdel(A) // No duplicating empty magazines, please (Convair880).
				user.visible_message("<span class='alert'>[user] refills [src].</span>", "<span class='alert'>You fully refill [src] with ammo from [A.name]. There are [A.amount_left] rounds left in [A.name].</span>")
				return // Full reload or ammo left over.
		else return ..()

	swap(var/obj/item/ammo/bullets/A, var/obj/item/gun/kinetic/K)
		// I tweaked this for improved user feedback and to support zip guns (Convair880).
		var/check = 0
		if (!A || !K)
			check = 0
		if (K.sanitycheck() == 0)
			check = 0
		if (A.ammo_cat in K.ammo_cats)
			check = 1
		else if (K.ammo_cats == null) //someone forgot to set ammo cats. scream
			check = 1
		if (!check)
			return 0
			//DEBUG_MESSAGE("Couldn't swap [K]'s ammo ([K.ammo.type]) with [A.type].")

		// The gun may have been fired; eject casings if so.
		K.ejectcasings()

		// We can't delete A here, because there's going to be ammo left over.
		if (K.max_ammo_capacity < A.amount_left)
			// Some ammo boxes have dynamic icon/desc updates we can't get otherwise.
			var/obj/item/ammo/bullets/ammoDrop = new K.ammo.type
			ammoDrop.amount_left = K.ammo.amount_left
			ammoDrop.name = K.ammo.name
			ammoDrop.icon = K.ammo.icon
			ammoDrop.icon_state = K.ammo.icon_state
			ammoDrop.ammo_type = K.ammo.ammo_type
			ammoDrop.delete_on_reload = 1 // No duplicating empty magazines, please.
			ammoDrop.UpdateIcon()
			usr.put_in_hand_or_drop(ammoDrop)
			ammoDrop.after_unload(usr)
			K.ammo.amount_left = 0 // Make room for the new ammo.
			K.ammo.loadammo(A, K) // Let the other proc do the work for us.
			//DEBUG_MESSAGE("Swapped [K]'s ammo with [A.type]. There are [A.amount_left] round left over.")
			return 2

		else

			usr.u_equip(A) // We need a free hand for ammoHand first.

			// Some ammo boxes have dynamic icon/desc updates we can't get otherwise.
			var/obj/item/ammo/bullets/ammoHand = new K.ammo.type
			ammoHand.amount_left = K.ammo.amount_left
			ammoHand.name = K.ammo.name
			ammoHand.icon = K.ammo.icon
			ammoHand.icon_state = K.ammo.icon_state
			ammoHand.ammo_type = K.ammo.ammo_type
			ammoHand.delete_on_reload = 1 // No duplicating empty magazines, please.
			ammoHand.UpdateIcon()
			usr.put_in_hand_or_drop(ammoHand)
			ammoHand.after_unload(usr)

			var/obj/item/ammo/bullets/ammoGun = new A.type // Ditto.
			ammoGun.amount_left = A.amount_left
			ammoGun.name = A.name
			ammoGun.icon = A.icon
			ammoGun.icon_state = A.icon_state
			ammoGun.ammo_type = A.ammo_type
			//DEBUG_MESSAGE("Swapped [K]'s ammo with [A.type].")
			qdel(K.ammo) // Make room for the new ammo.
			qdel(A) // We don't need you anymore.
			ammoGun.set_loc(K)
			K.ammo = ammoGun
			K.set_current_projectile(ammoGun.ammo_type)
			if(K.silenced)
				K.current_projectile.shot_sound = 'sound/machines/click.ogg'
			K.UpdateIcon()

			return 1

	proc/loadammo(var/obj/item/ammo/bullets/A, var/obj/item/gun/kinetic/K)
		// Also see attackby() in kinetic.dm.
		if (!A || !K)
			return 0 // Error message.
		if (K.sanitycheck() == 0)
			return 0
		var/check = 0
		if (A.ammo_cat in K.ammo_cats)
			check = 1
		else if (K.ammo_cats == null) //someone forgot to set ammo cats. scream
			check = 1
		if (!check)
			return 1

		K.add_fingerprint(usr)
		A.add_fingerprint(usr)
		if(K.sound_load_override)
			playsound(K, K.sound_load_override, 50, 1)
		else
			playsound(K, sound_load, 50, 1)

		if (K.ammo.amount_left < 0)
			K.ammo.amount_left = 0
		if (A.amount_left < 1)
			return 2 // Magazine's empty.
		if (K.ammo.amount_left >= K.max_ammo_capacity)
			if (K.ammo.ammo_type.type != A.ammo_type.type)
				return 6 // Call swap().
			return 3 // Gun's full.
		if (K.ammo.amount_left > 0 && K.ammo.ammo_type.type != A.ammo_type.type)
			return 6 // Call swap().

		else

			// The gun may have been fired; eject casings if so (Convair880).
			K.ejectcasings()

			// Required for swap() to work properly (Convair880).
			if (K.ammo.type != A.type || A.force_new_current_projectile)
				var/obj/item/ammo/bullets/ammoGun = new A.type
				ammoGun.amount_left = K.ammo.amount_left
				ammoGun.ammo_type = K.ammo.ammo_type
				qdel(K.ammo)
				ammoGun.set_loc(K)
				K.ammo = ammoGun
				K.set_current_projectile(A.ammo_type)
				if(K.silenced)
					K.current_projectile.shot_sound = 'sound/machines/click.ogg'

				//DEBUG_MESSAGE("Equalized [K]'s ammo type to [A.type]")

			var/move_amount = min(A.amount_left, K.max_ammo_capacity - K.ammo.amount_left)
			A.amount_left -= move_amount
			K.ammo.amount_left += move_amount
			K.ammo.ammo_type = A.ammo_type

			if ((A.amount_left < 1) && (K.ammo.amount_left < K.max_ammo_capacity))
				A.UpdateIcon()
				K.UpdateIcon()
				K.ammo.UpdateIcon()
				if (A.delete_on_reload)
					//DEBUG_MESSAGE("[K]: [A.type] (now empty) was deleted on partial reload.")
					qdel(A) // No duplicating empty magazines, please (Convair880).
				return 4 // Couldn't fully reload the gun.
			if ((A.amount_left >= 0) && (K.ammo.amount_left == K.max_ammo_capacity))
				A.UpdateIcon()
				K.UpdateIcon()
				K.ammo.UpdateIcon()
				if (A.amount_left == 0)
					if (A.delete_on_reload)
						//DEBUG_MESSAGE("[K]: [A.type] (now empty) was deleted on full reload.")
						qdel(A) // No duplicating empty magazines, please (Convair880).
				return 5 // Full reload or ammo left over.

	update_icon()

		if (src.amount_left < 0)
			src.amount_left = 0
		inventory_counter?.update_number(src.amount_left)
		src.tooltip_rebuild = 1
		if (src.amount_left > 0)
			if (src.icon_dynamic && src.icon_short)
				src.icon_state = text("[src.icon_short]-[src.amount_left]")
			else if(src.icon_empty)
				src.icon_state = initial(src.icon_state)
		else
			if (src.icon_empty)
				src.icon_state = src.icon_empty
		return

	proc/after_unload(mob/user)
		return

	get_desc()
		return . += "There [src.amount_left == 1 ? "is" : "are"] [src.amount_left][ammo_type.material && istype(ammo_type.material, /datum/material/metal/silver) ? " silver " : " "]bullet\s left!"

//no caliber:
/obj/item/ammo/bullets/vbullet
	sname = "VR bullets"
	name = "VR magazine"
	ammo_type = new/datum/projectile/bullet/vbullet
	icon_state = "ak47"
	amount_left = 200

//0.22
/obj/item/ammo/bullets/custom
	sname = ".22 LR Custom"
	name = "custom .22 ammo box"
	desc = "Custom made ammunition, in your favorite plinking caliber"
	icon_state = "custom-8"
	amount_left = 8
	max_amount = 8
	ammo_type = new/datum/projectile/bullet/custom
	ammo_cat = AMMO_PISTOL_22
	icon_dynamic = 1
	icon_short = "custom"
	icon_empty = "custom-0"

	onMaterialChanged()
		ammo_type.material = copyMaterial(src.material)

		if(src.material)
			ammo_type.power = round(material.getProperty("density") * 2 + material.getProperty("hard"))
			ammo_type.generate_inverse_stats()
			ammo_type.dissipation_delay = round(material.getProperty("density") / 2)

			if((src.material.material_flags & MATERIAL_CRYSTAL))
				ammo_type.damage_type = D_PIERCING
			if((src.material.material_flags & MATERIAL_METAL))
				ammo_type.damage_type = D_KINETIC
			if((src.material.material_flags & MATERIAL_ORGANIC))
				ammo_type.damage_type = D_TOXIC
			if((src.material.material_flags & MATERIAL_ENERGY))
				ammo_type.damage_type = D_ENERGY
			if((src.material.material_flags & MATERIAL_METAL) && (src.material.material_flags & MATERIAL_CRYSTAL))
				ammo_type.damage_type = D_SLASHING
			if((src.material.material_flags & MATERIAL_ENERGY) && (src.material.material_flags & MATERIAL_ORGANIC))
				ammo_type.damage_type = D_BURNING
			if((src.material.material_flags & MATERIAL_ENERGY) && (src.material.material_flags & MATERIAL_METAL))
				ammo_type.damage_type = D_RADIOACTIVE

		return ..()

/obj/item/ammo/bullets/bullet_22
	sname = ".22 LR"
	name = ".22 magazine"
	desc = "Despite being very small, these bullets are still lethal."
	icon_state = "pistol_magazine"
	amount_left = 10
	max_amount = 10
	ammo_type = new/datum/projectile/bullet/bullet_22
	ammo_cat = AMMO_PISTOL_22

/obj/item/ammo/bullets/bullet_22/smartgun
	name = ".22 smartgun magazine"
	desc = "A fancy, high-tech extended magazine of .22 bullets."
	icon_state = "pistol_magazine_smart"
	amount_left = 20
	max_amount = 20
	ammo_type = new/datum/projectile/bullet/bullet_22/smartgun
	sound_load = 'sound/weapons/gunload_hitek.ogg'

/obj/item/ammo/bullets/bullet_22/faith
	amount_left = 4

/obj/item/ammo/bullets/bullet_22HP
	sname = ".22 Hollow Point"
	name = ".22 HP magazine"
	desc = "Some JHP bullets. They expand as they penetrate, causing additional tissue damage at the cost of less armor penetration."
	icon_state = "pistol_magazine_hp"
	amount_left = 10
	max_amount = 10
	ammo_type = new/datum/projectile/bullet/bullet_22/HP
	ammo_cat = AMMO_PISTOL_22

//0.223
/obj/item/ammo/bullets/assault_rifle
	sname = "5.56x45mm NATO"
	name = "STENAG magazine" //heh
	desc = "A magazine of 5.56 rounds, an intermediate rifle cartridge."
	ammo_type = new/datum/projectile/bullet/assault_rifle
	icon_state = "stenag_mag"
	amount_left = 20
	max_amount = 20
	ammo_cat = AMMO_AUTO_556
	sound_load = 'sound/weapons/gunload_heavy.ogg'

	armor_piercing
		sname = "5.56x45mm NATO AP"
		name = "AP STENAG magazine"
		desc = "5.56 AP bullets. The iron core prevents deformation and causes rounds to pierce further, but reduces the overall force of the bullet."
		ammo_type = new/datum/projectile/bullet/assault_rifle/armor_piercing
		icon_state = "stenag_mag-AP"

//0.308
/obj/item/ammo/bullets/minigun
	sname = "7.62×51mm NATO"
	name = "Minigun cartridge"
	ammo_type = new/datum/projectile/bullet/minigun
	icon_state = "lmg_ammo-old" // reusing old sprites for variety
	icon_empty = "lmg_ammo-0-old"
	amount_left = 100
	max_amount = 100
	ammo_cat = AMMO_AUTO_308
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/akm
	sname = "7.62x39mm"
	name = "AKM magazine"
	desc = "A curved 30 round magazine, for the AKM assault rifle."
	ammo_type = new/datum/projectile/bullet/akm
	icon_state = "ak47"
	amount_left = 30
	max_amount = 30
	ammo_cat = AMMO_AUTO_762
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/rifle_3006
	sname = ".308 AP"
	name = ".308 rifle magazine"
	desc = "An old stripper clip of .308 bullets, ready to rip through whatever they hit."
	ammo_type = new/datum/projectile/bullet/rifle_3006
	icon_state = "rifle_clip-4"
	amount_left = 4
	max_amount = 4
	ammo_cat = AMMO_RIFLE_308
	icon_dynamic = 1
	icon_short = "rifle_clip"
	icon_empty = "rifle_clip_empty"

/obj/item/ammo/bullets/rifle_762_NATO
	sname = "7.62×51mm NATO"
	name = "7.62 NATO magazine"
	desc = "Some powerful 7.62 cartridges."
	ammo_type = new/datum/projectile/bullet/rifle_762_NATO
	icon_state = "rifle_box_mag" //todo
	amount_left = 6
	max_amount = 6
	ammo_cat = AMMO_RIFLE_308

/obj/item/ammo/bullets/tranq_darts
	sname = ".308 Tranquilizer"
	name = ".308 tranquilizer darts"
	desc = "A stripper clip of haloperidol darts. Although not lethal, you wouldn't want to be in a fight under the influence of these."
	ammo_type = new/datum/projectile/bullet/tranq_dart
	icon_state = "rifle_clip_dart-4"
	amount_left = 4
	max_amount = 4
	ammo_cat = AMMO_TRANQ_308
	icon_dynamic = 1
	icon_short = "rifle_clip_dart"
	icon_empty = "rifle_clip_empty"

	var/image/reagent_image

	New()
		..()
		src.update_icon()

	update_icon()
		..()
		if (!src.icon_dynamic || !src.ammo_type.reagent_payload)
			return

		src.underlays = null
		if (!src.reagent_image)
			src.reagent_image = image(src.icon, "rifle_clip_dart_underlay-[src.amount_left]", -1)
		else
			src.reagent_image.icon_state = "rifle_clip_dart_underlay-[src.amount_left]"


		var/datum/reagent/reagent = reagents_cache[src.ammo_type.reagent_payload]
		src.reagent_image.color = rgb(reagent.fluid_r, reagent.fluid_g, reagent.fluid_b, reagent.transparency)
		src.underlays += src.reagent_image

	syndicate
		sname = ".308 Tranquilizer Deluxe"
		ammo_type = new/datum/projectile/bullet/tranq_dart/syndicate

		pistol
			sname = ".355 Tranqilizer"
			name = ".355 tranquilizer pistol darts"
			desc = "A magazine of 10 sodium thiopentinal knockout darts."
			icon_state = "pistol_tranq"
			amount_left = 10
			max_amount = 15
			icon_dynamic = 0
			ammo_cat = AMMO_TRANQ_9MM//i prefer having tranqs grouped up- owari.
			ammo_type = new/datum/projectile/bullet/tranq_dart/syndicate/pistol

	anti_mutant
		sname = ".308 Mutadone"
		desc = "Some mutadone darts, for forcefully removing mutations without getting into melee range"
		name = ".308 mutadone darts"
		ammo_type = new/datum/projectile/bullet/tranq_dart/anti_mutant

/obj/item/ammo/bullets/lmg
	sname = "7.62×51mm NATO"
	name = "LMG belt"
	desc = "A belt of 7.62 LMG rounds. They have much less gunpowder in them to prevent overheating and cookoffs."
	ammo_type = new/datum/projectile/bullet/lmg
	icon_state = "lmg_ammo"
	icon_empty = "lmg_ammo-0"
	amount_left = 100
	max_amount = 100
	ammo_cat = AMMO_AUTO_308
	sound_load = 'sound/weapons/gunload_heavy.ogg'

	weak
		sname = "7.62×51mm NATO W"
		name = "discount LMG belt"
		desc = "A belt of really FISHY bullets."
		ammo_type = new/datum/projectile/bullet/lmg/weak
		amount_left = 25
		max_amount = 25

//9mm/0.355
/obj/item/ammo/bullets/bullet_9mm
	sname = "9×19mm Parabellum"
	name = "9mm magazine"
	desc = "A handgun magazine full of 9x19mm rounds, an intermediate pistol cartridge."
	icon_state = "pistol_magazine"
	amount_left = 15
	max_amount = 15
	ammo_type = new/datum/projectile/bullet/bullet_9mm
	ammo_cat = AMMO_PISTOL_9MM

	five_shots
		amount_left = 5

	smg
		name = "9mm SMG magazine"
		desc = "An extended 9mm magazine for a sub machine gun."
		icon_state = "smg_magazine"
		amount_left = 30
		max_amount = 30
		ammo_cat = AMMO_SMG_9MM
		ammo_type = new/datum/projectile/bullet/bullet_9mm/smg

/obj/item/ammo/bullets/nine_mm_NATO
	sname = "9mm frangible"
	name = "9mm frangible magazine"
	desc = "Some 9mm incapacitating bullets, made of plastic with rubber tips. Despite being sublethal, they can still do damage."
	icon_state = "pistol_clip"	//9mm_clip that exists already. Also, put this in hacked manufacturers cause these bullets are not good.
	amount_left = 18
	max_amount = 18
	ammo_type = new/datum/projectile/bullet/nine_mm_NATO
	ammo_cat = AMMO_PISTOL_9MM

/obj/item/ammo/bullets/nine_mm_NATO/boomerang //empty clip for the clock_188/boomerang
	amount_left = 0

/obj/item/ammo/bullets/nine_mm_soviet
	sname = "9x18mm Makarov"
	name = "9x18mm magazine"
	desc = "A standard 8 round magazine, for the PM pistol. It featuring an observation slot for checking remaining munitions."
	icon_state = "makarov_magazine"
	icon_empty = "makarov_magazine-empty"
	amount_left = 8
	max_amount = 8
	ammo_type = new/datum/projectile/bullet/nine_mm_soviet
	ammo_cat = AMMO_PISTOL_9MM_SOVIET

//medic primary
/obj/item/ammo/bullets/veritate
	sname = "6.5×20mm AP"
	name = "6.5×20mm magazine"
	desc = "High-velocity pistol cartridges, loaded with armor-piercing bullets."
	icon_state = "stenag_mag"
	amount_left = 21
	max_amount = 21
	ammo_type = new/datum/projectile/bullet/veritate
	ammo_cat = AMMO_FLECHETTE

//0.357
/obj/item/ammo/bullets/a357
	sname = ".357 Mag"
	name = ".357 speedloader"
	desc = "A speedloader of .357 magnum revolver bullets."
	icon_state = "38-7"
	amount_left = 7
	max_amount = 7
	ammo_type = new/datum/projectile/bullet/revolver_357
	ammo_cat = AMMO_REVOLVER_SYNDICATE
	icon_dynamic = 1
	icon_short = "38"
	icon_empty = "speedloader_empty"

/obj/item/ammo/bullets/a357/AP
	sname = ".357 Mag AP"
	name = ".357 AP speedloader"
	desc = "A speedloader of .357 magnum armor piercing bullets. The iron core increases penetration at the cost of stopping power."
	icon_state = "38A-7"
	ammo_type = new/datum/projectile/bullet/revolver_357/AP
	icon_dynamic = 1
	icon_short = "38A"
	icon_empty = "speedloader_empty"

/obj/item/ammo/bullets/a38
	sname = ".38 Spc"
	name = ".38 speedloader"
	desc = "A speedloader of .38 special, a popular police and detective cartridge."
	icon_state = "38-7"
	amount_left = 7
	max_amount = 7
	ammo_type = new/datum/projectile/bullet/revolver_38
	ammo_cat = AMMO_REVOLVER_DETECTIVE
	icon_dynamic = 1
	icon_short = "38"
	icon_empty = "speedloader_empty"

//0.38
/obj/item/ammo/bullets/a38/AP
	sname = ".38 Spc AP"
	name = ".38 AP speedloader"
	desc = "A speedloader of .38 special armor piercing bullets. The iron core increases penetration at the cost of stopping power."
	icon_state = "38A-7"
	amount_left = 7
	max_amount = 7
	ammo_type = new/datum/projectile/bullet/revolver_38/AP
	icon_dynamic = 1
	icon_short = "38A"
	icon_empty = "speedloader_empty"

/obj/item/ammo/bullets/a38/stun
	sname = ".38 Spc Stun"
	name = ".38 Stun speedloader"
	desc = "A speedloader of .38 stun bullets."
	icon_state = "38S-7"
	amount_left = 7
	max_amount = 7
	ammo_type = new/datum/projectile/bullet/revolver_38/stunners
	icon_dynamic = 1
	icon_short = "38S"
	icon_empty = "speedloader_empty"

//0.393
/obj/item/ammo/bullets/foamdarts
	sname = "foam darts"
	name = "foam darts"
	desc = "Reusable foam darts for shooting people in the eyes with."
	icon_state = "foamdarts-6"
	icon_empty = "foamdarts-0"
	icon_dynamic = 1
	icon_short = "foamdarts"
	amount_left = 6
	max_amount = 6
	ammo_cat = AMMO_FOAMDART
	ammo_type = new/datum/projectile/bullet/foamdart
	delete_on_reload = TRUE
	throwforce = 0

//0.40
/obj/item/ammo/bullets/blow_darts
	sname = "blowdart"
	name = "poison blowdarts"
	ammo_type = new/datum/projectile/bullet/blow_dart
	desc = "These darts are loaded with a dangerous paralytic toxin."
	icon_state = "tranq_clip"
	amount_left = 4
	max_amount = 4
	ammo_cat = AMMO_BLOWDART
	color = "green"

	single
		amount_left = 1
		max_amount = 1

	madness
		name = "madness blowdarts"
		desc = "These darts are loaded with a violently behavior-altering toxin."
		ammo_type = new/datum/projectile/bullet/blow_dart/madness
		color = "red"

	ls_bee
		name = "hallucinogenic blowdarts"
		desc = "These darts are loaded with a potent mind-altering drug. They smell like honey."
		ammo_type = new/datum/projectile/bullet/blow_dart/ls_bee
		color = "yellow"

//0.41
/obj/item/ammo/bullets/derringer
	sname = ".41 RF"
	name = ".41 ammo box"
	desc = "A pair of really small derringer bullets."
	icon_state = "357-2"
	amount_left = 2
	max_amount = 2
	ammo_type = new/datum/projectile/bullet/derringer
	ammo_cat = AMMO_PISTOL_41
	icon_dynamic = 1
	icon_short = "357"
	icon_empty = "357-0"

//0.45
/obj/item/ammo/bullets/c_45
	sname = "Cold .45"
	name = "Colt .45 speedloader"
	desc = "A speedloader of .45 caliber revolver bullets."
	icon_state = "38-7"
	amount_left = 7
	max_amount = 7
	ammo_type = new/datum/projectile/bullet/revolver_45
	ammo_cat = AMMO_REVOLVER_45
	icon_dynamic = 1
	icon_short = "38"
	icon_empty = "speedloader_empty"

//0.58
/obj/item/ammo/bullets/flintlock //Flintlock cant be reloaded so this is only for the initial bullet.
	sname = ".58 Flintlock"
	name = ".58 Flintlock"
	ammo_type = new/datum/projectile/bullet/flintlock
	icon_state = null
	amount_left = 1
	max_amount = 1
	ammo_cat = AMMO_FLINTLOCK

//0.72
/obj/item/ammo/bullets/a12
	sname = "12ga Buckshot"
	name = "12ga buckshot ammo box"
	desc = "A box of buckshot shells, capable of tearing through soft tissue."
	ammo_type = new/datum/projectile/bullet/a12
	icon_state = "12"
	amount_left = 8
	max_amount = 8
	ammo_cat = AMMO_SHOTGUN_HIGH
	icon_dynamic = 0
	icon_empty = "12-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

	weak //for nuke ops engineer
		ammo_type = new/datum/projectile/bullet/a12/weak

/obj/item/ammo/bullets/buckshot_burst // real spread shotgun ammo
	sname = "Buckshot"
	name = "buckshot ammo box"
	desc = "This buckshot looks a little old..."
	ammo_type = new/datum/projectile/special/spreader/buckshot_burst/
	icon_state = "12"
	amount_left = 8
	max_amount = 8
	ammo_cat = AMMO_SHOTGUN_HIGH
	icon_dynamic = 0
	icon_empty = "12-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

ABSTRACT_TYPE(/obj/item/ammo/bullets/pipeshot)
/obj/item/ammo/bullets/pipeshot
	sname = "pipeshot"
	name = "pipeshot"
	desc = "A parent item! If you see this contact a coder."
	ammo_type = new/datum/projectile/special/spreader/buckshot_burst
	icon_state = "makeshiftscrap"
	amount_left = 4
	max_amount = 4
	ammo_cat = AMMO_SHOTGUN_HIGH
	delete_on_reload = TRUE
	sound_load = 'sound/weapons/gunload_heavy.ogg'
	w_class = W_CLASS_NORMAL

/obj/item/ammo/bullets/pipeshot/plasglass // plasmaglass handmade shells
	sname = "plasmaglass load"
	desc = "Some mean-looking plasmaglass shards that are jammed into a few cut open pipe frames."
	ammo_type = new/datum/projectile/special/spreader/buckshot_burst/plasglass
	icon_state = "makeshiftplasglass"

/obj/item/ammo/bullets/pipeshot/glass // glass handmade shells
	sname = "glass load"
	desc = "This appears to be some glass shards haphazardly shoved into a few cut open pipe frames."
	ammo_type = new/datum/projectile/special/spreader/buckshot_burst/glass
	icon_state = "makeshiftglass"

/obj/item/ammo/bullets/pipeshot/scrap // scrap handmade shells
	sname = "scrap load"
	desc = "This appears to be some metal bits haphazardly shoved into a few cut open pipe frames."
	ammo_type = new/datum/projectile/special/spreader/buckshot_burst/scrap

/obj/item/ammo/bullets/pipeshot/scrap/five
	amount_left = 5
	max_amount = 5


/obj/item/ammo/bullets/nails // oh god oh fuck
	sname = "Nails"
	name = "nailshot ammo box"
	desc = "You're unsure about the effectiveness of these shells."
	ammo_type = new/datum/projectile/special/spreader/buckshot_burst/nails
	icon_state = "custom-8"
	icon_short = "custom"
	amount_left = 8
	max_amount = 8
	ammo_cat = AMMO_SHOTGUN_HIGH
	icon_dynamic = 1
	icon_empty = "custom-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/aex
	sname = "12ga AEX"
	name = "12ga AEX ammo box"
	desc = "Some really fancy HE shotgun shells. The smallish size limits the explosive potential, but it's nothing to scoff at."
	ammo_type = new/datum/projectile/bullet/aex
	icon_state = "AEX"
	amount_left = 8
	max_amount = 8
	ammo_cat = AMMO_SHOTGUN_LOW
	icon_dynamic = 0
	icon_empty = "AEX-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

/obj/item/ammo/bullets/abg
	sname = "12ga Rubber Slug"
	name = "12ga rubber slugs"
	desc = "A box of rubber slugs. Despite being nonlethal, they still pack a punch."
	ammo_type = new/datum/projectile/bullet/abg
	icon_state = "bg"
	amount_left = 8
	max_amount = 8
	ammo_cat = AMMO_SHOTGUN_LOW
	icon_dynamic = 0
	icon_empty = "bg-0"
	sound_load = 'sound/weapons/gunload_click.ogg'

/obj/item/ammo/bullets/abg/two //spawns in the break action
	amount_left = 2
	max_amount = 2

/obj/item/ammo/bullets/flare
	sname = "12ga Flare"
	name = "12ga flares"
	desc = "Some incendiary flares. Ironically enough, they don't burn long enough to be very good at illumination."
	amount_left = 8
	max_amount = 8
	icon_state = "flare"
	ammo_type = new/datum/projectile/bullet/flare
	ammo_cat = AMMO_SHOTGUN_LOW
	icon_dynamic = 0
	icon_empty = "flare-0"

	single
		amount_left = 1
		max_amount = 1

//0.787
/obj/item/ammo/bullets/cannon
	sname = "20mm APHE"
	name = "20mm APHE shells"
	amount_left = 5
	max_amount = 5
	icon_state = "40mm_lethal"
	ammo_type = new/datum/projectile/bullet/cannon
	ammo_cat = AMMO_CANNON_20MM
	w_class = W_CLASS_SMALL
	icon_dynamic = 1
	icon_empty = "40mm_lethal-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

	single
		amount_left = 1
		max_amount = 1

//1.0
/obj/item/ammo/bullets/rod
	sname = "metal rod"
	name = "metal rod"
	force = 4
	amount_left = 2
	max_amount = 2
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "rod_1"
	ammo_type = new/datum/projectile/bullet/rod
	ammo_cat = AMMO_COILGUN
	sound_load = 'sound/weapons/gunload_heavy.ogg'

//1.57
/obj/item/ammo/bullets/autocannon
	sname = "40mm HE"
	name = "40mm HE pod shells"
	desc = "Some high explosive grenades, for use in 40mm weapons."
	amount_left = 2
	max_amount = 2
	icon_state = "40mm_HE_pod"
	ammo_type = new/datum/projectile/bullet/autocannon
	ammo_cat = AMMO_CANNON_40MM
	w_class = W_CLASS_NORMAL
	icon_dynamic = 0
	icon_empty = "40mm_HE_pod-0"
	sound_load = 'sound/weapons/gunload_heavy.ogg'

	single
		amount_left = 1
		max_amount = 1

	seeker
		sname = "40mm HE Seeker"
		name = "40mm HE pod-seeking shells"
		desc = "Some fancy high explosive shells that really, really love pods."
		ammo_type = new/datum/projectile/bullet/autocannon/seeker/pod_seeking

	knocker
		sname = "40mm HE Knocker"
		name = "40mm HE airlock-breaching shells"
		desc = "Some explosive breaching shells."
		icon_state = "40mm_HE"
		ammo_type = new/datum/projectile/bullet/autocannon/knocker

/obj/item/ammo/bullets/grenade_round
	sname = "40mm"
	name = "40mm shells"
	desc = "A box of general utility 40mm grenades."
	amount_left = 8
	max_amount = 8
	icon_state = "40mm_lethal"
	ammo_type = new/datum/projectile/bullet/grenade_round/
	ammo_cat = AMMO_GRENADE_40MM
	w_class = W_CLASS_NORMAL
	icon_dynamic = 0
	icon_empty = "40mm_lethal-0"
	sound_load = 'sound/weapons/gunload_40mm.ogg'

	explosive
		sname = "40mm HEDP"
		name = "40mm HEDP shells"
		desc = "High Explosive Dual Purpose grenade rounds compatible with grenade launchers. Effective against infantry and armour."
		icon_state = "40mm_HE"
		icon_empty = "40mm_HE-0"
		ammo_type = new/datum/projectile/bullet/grenade_round/explosive

	high_explosive
		sname = "40mm HE"
		name = "40mm HE shells"
		desc = "High Explosive grenade rounds compatible with grenade launchers. Devastatingly effective against infantry targets."
		icon_state = "40mm_HE_conc"
		icon_empty = "40mm_HE_conc-0"
		ammo_type = new/datum/projectile/bullet/grenade_round/high_explosive

/obj/item/ammo/bullets/smoke
	sname = "40mm Smoke"
	name = "40mm smoke shells"
	desc = "Some smoke shells, for the 40mm platform."
	amount_left = 5
	max_amount = 5
	icon_state = "40mm_smoke"
	ammo_type = new/datum/projectile/bullet/smoke
	ammo_cat = AMMO_GRENADE_40MM
	w_class = W_CLASS_NORMAL
	icon_dynamic = 0
	icon_empty = "40mm_smoke-0"
	sound_load = 'sound/weapons/gunload_40mm.ogg'

	single
		amount_left = 1
		max_amount = 1

/obj/item/ammo/bullets/marker
	sname = "40mm Paint Marker Rounds"
	name = "40mm paint marker rounds"
	desc = "An experimental 40mm round that causes whoever is hit with it to leave a trail behind them."
	ammo_type = new/datum/projectile/bullet/marker
	amount_left = 5
	max_amount = 5
	icon_state = "40mm_paint"
	ammo_cat = AMMO_GRENADE_40MM
	w_class = W_CLASS_NORMAL
	icon_dynamic = 0
	icon_empty = "40mm_nonlethal-0"
	sound_load = 'sound/weapons/gunload_40mm.ogg'

/obj/item/ammo/bullets/pbr
	sname = "40mm Plastic Baton Rounds"
	name = "40mm plastic baton rounds"
	desc = "Some mean-looking plastic projectiles. Keep in mind non-lethal doesn't mean non-maiming."
	ammo_type = new/datum/projectile/bullet/pbr
	amount_left = 2
	max_amount = 2
	icon_state = "40mm_nonlethal"
	ammo_cat = AMMO_GRENADE_40MM
	w_class = W_CLASS_NORMAL
	icon_dynamic = 0
	icon_empty = "40mm_nonlethal-0"
	sound_load = 'sound/weapons/gunload_40mm.ogg'

/obj/item/ammo/bullets/breach_flashbang
	sname = "40mm Door-Breaching Rounds"
	name = "40mm door-breaching rounds"
	desc = "Some high-tech shells with an ID-chipped tip and a pyrotechnic payload."
	ammo_type = new/datum/projectile/bullet/breach_flashbang
	amount_left = 2
	max_amount = 2
	icon_state = "40mm_nonlethal"
	ammo_cat = AMMO_GRENADE_40MM
	w_class = W_CLASS_NORMAL
	icon_dynamic = 0
	icon_empty = "40mm_nonlethal-0"
	sound_load = 'sound/weapons/gunload_40mm.ogg'

//basically an internal object for converting hand-grenades into shells, but can be spawned independently.
/obj/item/ammo/bullets/grenade_shell
	sname = "40mm Custom Shell"
	name = "40mm hand grenade conversion chamber"
	desc = "A 40mm shell used for converting hand grenades into impact detonation explosive shells"
	amount_left = 1
	max_amount = 1
	icon_state = "paintballr-4"
	ammo_type = new/datum/projectile/bullet/grenade_shell
	ammo_cat = AMMO_GRENADE_40MM
	w_class = W_CLASS_NORMAL
	icon_dynamic = 0
	icon_empty = "paintballb-4"
	delete_on_reload = 0 //deleting it before the shell can be fired breaks things
	sound_load = 'sound/weapons/gunload_40mm.ogg'
	force_new_current_projectile = 1

	rigil
		max_amount = 4

	attackby(obj/item/W, mob/living/user)
		var/datum/projectile/bullet/grenade_shell/AMMO = src.ammo_type
		if(!W || !user)
			return
		if (istype(W, /obj/item/chem_grenade) || istype(W, /obj/item/old_grenade))
			if (AMMO.has_grenade == 0)
				AMMO.load_nade(W)
				user.u_equip(W)
				W.layer = initial(W.layer)
				W.set_loc(src)
				src.UpdateIcon()
				boutput(user, "You load [W] into the [src].")
				return
			else if(src.amount_left < src.max_amount && W.type == AMMO.get_nade()?.type)
				src.amount_left++
				boutput(user, "You load [W] into the [src].")
			else
				boutput(user, "<span class='alert'>For <i>some reason</i>, you are unable to place [W] into an already filled chamber.</span>")
				return
		else
			return ..()

	attack_hand(mob/user)
		var/datum/projectile/bullet/grenade_shell/AMMO = src.ammo_type
		if(!user)
			return
		if (src.loc == user && AMMO.has_grenade != 0)
			for(var/i in 1 to amount_left)
				user.put_in_hand_or_drop(SEMI_DEEP_COPY(AMMO.get_nade()))
			AMMO.unload_nade()
			boutput(user, "You pry the grenade[amount_left>1?"s":""] out of [src].")
			src.add_fingerprint(user)
			src.UpdateIcon()
			return
		return ..()

	update_icon()

		inventory_counter.update_number(src.amount_left)
		var/datum/projectile/bullet/grenade_shell/AMMO = src.ammo_type
		if (AMMO.has_grenade != 0)
			src.icon_state = "40mm_lethal"
		else
			src.icon_state = "40mm_lethal-0"

	after_unload(mob/user)
		var/datum/projectile/bullet/grenade_shell/AMMO = src.ammo_type
		if(AMMO.has_grenade && src.delete_on_reload)
			for(var/i in 1 to amount_left)
				user.put_in_hand_or_drop(SEMI_DEEP_COPY(AMMO.get_nade()))
			AMMO.unload_nade()
			qdel(src)

//1.58
// Ported from old, non-gun RPG-7 object class (Convair880).
/obj/item/ammo/bullets/rpg
	sname = "MPRT rocket"
	name = "MPRT rocket"
	desc = "A mean high-explosive rocket, guaranteed to cause destruction in a large radius."
	amount_left = 1
	max_amount = 1
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "rpg_rocket"
	ammo_type = new /datum/projectile/bullet/rpg
	ammo_cat = AMMO_ROCKET_RPG
	w_class = W_CLASS_NORMAL
	delete_on_reload = 1
	sound_load = 'sound/weapons/gunload_mprt.ogg'

/obj/item/ammo/bullets/mrl
	sname = "MRL rocket pack"
	name = "MRL rocket pack"
	amount_left = 6
	max_amount = 6
	icon_state = "mrl_rocketpack"
	ammo_type = new /datum/projectile/bullet/homing/mrl
	ammo_cat = AMMO_ROCKET_MRL
	w_class = W_CLASS_NORMAL
	delete_on_reload = 1
	sound_load = 'sound/weapons/gunload_mprt.ogg'

/obj/item/ammo/bullets/antisingularity
	sname = "Singularity buster rocket"
	name = "Singularity buster rocket"
	desc = "An experimental rocket containing an energy payload designed to collapse singularities. It's made mostly of electronics and seems pretty fragile."
	amount_left = 1
	max_amount = 1
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "regularrocket"
	ammo_type = new /datum/projectile/bullet/antisingularity
	ammo_cat = AMMO_ROCKET_SING
	w_class = W_CLASS_NORMAL
	delete_on_reload = 1
	sound_load = 'sound/weapons/gunload_mprt.ogg'

/obj/item/ammo/bullets/mininuke
	sname = "Miniature nuclear warhead"
	name = "Miniature nuclear warhead"
	desc = "I am become mini-death, the destroyer of mini-worlds."
	amount_left = 1
	max_amount = 1
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "mininuke"
	ammo_type = new /datum/projectile/bullet/mininuke
	ammo_cat = AMMO_ROCKET_SING
	w_class = W_CLASS_NORMAL
	delete_on_reload = 1
	sound_load = 'sound/weapons/gunload_mprt.ogg'

//3.0
/obj/item/ammo/bullets/gun
	name = "Briefcase of guns"
	desc = "A briefcase full of guns. It's locked tight..."
	sname = "Guns"
	amount_left = 6
	max_amount = 6
	icon_state = "gungun"
	throwforce = 2
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 20
	ammo_type = new /datum/projectile/special/spawner/gun
	ammo_cat = AMMO_DERRINGER_LITERAL
	delete_on_reload = 1

//4.6
/obj/item/ammo/bullets/airzooka
	name = "Airzooka Tactical Replacement Trashbag"
	sname = "air"
	desc = "A tactical trashbag for use in a Donk Co Airzooka."
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	icon_state = "trashbag"
	m_amt = 40000
	g_amt = 0
	amount_left = 10
	max_amount = 10
	ammo_type = new/datum/projectile/bullet/airzooka
	ammo_cat = AMMO_AIRZOOKA

/obj/item/ammo/bullets/airzooka/bad
	name = "Airzooka Tactical Replacement Trashbag: Xtreme Edition"
	sname = "air"
	desc = "A tactical trashbag for use in a Donk Co Airzooka, now with plasma lining."
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	icon_state = "biobag"
	m_amt = 40000
	g_amt = 0
	amount_left = 10
	max_amount = 10
	ammo_type = new/datum/projectile/bullet/airzooka/bad
	ammo_cat = AMMO_AIRZOOKA

//20.0
/obj/item/ammo/bullets/meowitzer
	sname = "meowitzer"
	name = "meowitzer"
	desc = "A box containg a single meowitzer. It's shaking violently and feels warm to the touch. You probably don't want to be anywhere near this when it goes off. Wait, is that a cat?"
	icon_state = "meow_ammo"
	icon_empty = "meow_ammo-0"
	amount_left = 1
	max_amount = 1
	ammo_type = new/datum/projectile/special/meowitzer
	ammo_cat = AMMO_HOWITZER
	w_class = W_CLASS_NORMAL

/obj/item/ammo/bullets/meowitzer/inert
	sname = "inert meowitzer"
	name = "inert meowitzer"
	desc = "A box containg a single meowitzer. It's softly purring and feels cool to the touch. Wait, is that a cat?"
	ammo_type = new/datum/projectile/special/meowitzer/inert

/obj/item/ammo/bullets/howitzer
	sname = "howitzer"
	name = "howitzer shell"
	desc = "A carton containing a single 120mm shell. It's huge."
	icon_state = "meow_ammo"
	icon_empty = "meow_ammo-0"
	amount_left = 1
	max_amount = 1
	ammo_type = new/datum/projectile/bullet/howitzer
	ammo_cat = AMMO_HOWITZER
	w_class = W_CLASS_NORMAL
//////////////////////////////////// Power cells for eguns //////////////////////////

/obj/item/ammo/power_cell
	name = "Power Cell"
	desc = "A power cell that holds a max of 100PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 10000
	g_amt = 20000
	var/charge = 100
	var/max_charge = 100
	var/recharge_rate = 0
	var/sound_load = 'sound/weapons/gunload_click.ogg'
	var/unusualCell = 0
	var/rechargable = TRUE

	New()
		..()
		AddComponent(/datum/component/power_cell, max_charge, charge, recharge_rate, rechargable)
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		desc = "A power cell that holds a max of [src.max_charge]PU. Can be inserted into any energy gun, even tasers!"
		UpdateIcon()

	disposing()
		processing_items -= src
		..()

	emp_act()
		SEND_SIGNAL(src, COMSIG_CELL_USE, INFINITY)
		return

	update_icon()
		if (src.artifact || src.unusualCell) return
		overlays = null
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"]) * 100
			ratio = round(ratio, 20)
			inventory_counter.update_percent(ret["charge"], ret["max_charge"])
			switch(ratio)
				if(20)
					overlays += "cell_1/5"
				if(40)
					overlays += "cell_2/5"
				if(60)
					overlays += "cell_3/5"
				if(80)
					overlays += "cell_4/5"
				if(100)
					overlays += "cell_5/5"
			return

	examine()
		if (src.artifact)
			return list("You have no idea what this thing is!")
		. = ..()
		if (src.unusualCell)
			return
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			. += "There are [ret["charge"]]/[ret["max_charge"]] PU left!"

	proc/get_charge()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			return clamp(ret["charge"], 0, src.max_charge)

/obj/item/ammo/power_cell/empty
	charge = 0

/obj/item/ammo/power_cell/med_minus_power
	name = "Power Cell - 150"
	desc = "A power cell that holds a max of 150PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 15000
	g_amt = 30000
	charge = 150
	max_charge = 150

/obj/item/ammo/power_cell/med_power
	name = "Power Cell - 200"
	desc = "A power cell that holds a max of 200PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 15000
	g_amt = 30000
	charge = 200
	max_charge = 200

/obj/item/ammo/power_cell/med_plus_power
	name = "Power Cell - 250"
	desc = "A power cell that holds a max of 250PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 17500
	g_amt = 35000
	charge = 250
	max_charge = 250

/obj/item/ammo/power_cell/high_power
	name = "Power Cell - 300"
	desc = "A power cell that holds a max of 300PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 20000
	g_amt = 40000
	charge = 300
	max_charge = 300

/obj/item/ammo/power_cell/higherish_power
	name = "Power Cell - 400"
	desc = "A power cell that holds a max of 400PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 20000
	g_amt = 40000
	charge = 400
	max_charge = 400

/obj/item/ammo/power_cell/self_charging
	name = "Power Cell - Atomic"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 40PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 40
	max_charge = 40
	recharge_rate = 5


/obj/item/ammo/power_cell/self_charging/custom
	name = "Power Cell"
	desc = "A custom-made power cell."

	onMaterialChanged()
		..()
		if(istype(src.material))

			max_charge = round((material.getProperty("electrical") ** 2) * 4, 25)

			recharge_rate = 0
			recharge_rate += material.getProperty("radioactive")/2
			recharge_rate += material.getProperty("n_radioactive")


		charge = max_charge

		AddComponent(/datum/component/power_cell, max_charge, charge, recharge_rate)
		return


	proc/set_custom_mats(datum/material/coreMat, datum/material/genMat = null)
		src.setMaterial(coreMat)
		if(genMat)
			src.name = "[genMat.name]-doped [src.name]"

			var/conductivity = (2 * coreMat.getProperty("electrical") + genMat.getProperty("electrical")) / 3 //if self-charging, use a weighted average of the conductivities
			max_charge = round((conductivity ** 2) * 4, 25)

			recharge_rate = (coreMat.getProperty("radioactive") / 2 + coreMat.getProperty("n_radioactive") \
			+ genMat.getProperty("radioactive")  + genMat.getProperty("n_radioactive") * 2) / 3 //weight this too

			AddComponent(/datum/component/power_cell, max_charge, max_charge, recharge_rate)

/obj/item/ammo/power_cell/self_charging/slowcharge
	name = "Power Cell - Atomic Slowcharge"
	desc = "A self-contained radioisotope power cell that very slowly recharges an internal capacitor. Holds 40PU."
	recharge_rate = 2.5 // cogwerks: raised from 1.0 because radbows were terrible!!!!!

/obj/item/ammo/power_cell/self_charging/disruptor
	name = "Power Cell - Disruptor Charger"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 100PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 100
	max_charge = 100

/obj/item/ammo/power_cell/self_charging/ntso_baton
	name = "Power Cell - NTSO Stun Baton"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 100PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 150
	max_charge = 150
	recharge_rate = 7.5

/obj/item/ammo/power_cell/self_charging/ntso_signifer
	name = "Power Cell - NTSO D49"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 250PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 250
	max_charge = 250
	recharge_rate = 9

/obj/item/ammo/power_cell/self_charging/ntso_signifer/bad
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 150PU."
	charge = 150
	max_charge = 150
	recharge_rate = 4

/obj/item/ammo/power_cell/self_charging/medium
	name = "Power Cell - Hicap RTG"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 200PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 200
	max_charge = 200
	recharge_rate = 7.5

/obj/item/ammo/power_cell/self_charging/mediumbig
	name = "Power Cell - Fission"
	desc = "Half the power of a Fusion model power cell with a tenth of the cost. Holds 200PU."
	max_charge = 200
	charge = 200
	recharge_rate = 20

/obj/item/ammo/power_cell/self_charging/big
	name = "Power Cell - Fusion"
	desc = "A self-contained cold fusion power cell that quickly recharges an internal capacitor. Holds 400PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 400
	max_charge = 400
	recharge_rate = 40

/obj/item/ammo/power_cell/self_charging/lawbringer
	name = "Power Cell - Lawbringer Charger"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 300PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 300
	max_charge = 300
	recharge_rate = 10

/obj/item/ammo/power_cell/self_charging/lawbringer/bad
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 175PU."
	max_charge = 175
	recharge_rate = 6

/obj/item/ammo/power_cell/self_charging/howitzer
	name = "Miniaturized SMES"
	desc = "This thing is huge! How did you even lift it put it into the gun?"
	charge = 2500
	max_charge = 2500

/obj/item/ammo/power_cell/self_charging/flockdrone
	name = "Flockdrone incapacitor cell"
	desc = "You should not be seeing this!"
	max_charge = 40
	recharge_rate = 10

/datum/action/bar/icon/powercellswap
	duration = 1 SECOND
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	id = "powercellswap"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	var/mob/living/user
	var/obj/item/ammo/power_cell/cell
	var/obj/item/gun/energy/gun

	New(User, Cell, Gun)
		user = User
		cell = Cell
		gun = Gun
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(user, gun) > 0 || user == null || cell == null || gun == null || get_turf(gun) != get_turf(cell) )
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(user, gun) > 0 || user == null || cell == null || gun == null || get_turf(gun) != get_turf(cell) )
			interrupt(INTERRUPT_ALWAYS)
			return
		return

	onEnd()
		..()
		if(BOUNDS_DIST(user, gun) > 0 || user == null || cell == null || gun == null || get_turf(gun) != get_turf(cell) )
			..()
			interrupt(INTERRUPT_ALWAYS)
			return
		cell.swap(gun,user)
