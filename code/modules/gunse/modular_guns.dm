/*
 ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄                 ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄  ▄▄        ▄  ▄▄▄▄▄▄▄▄▄▄▄
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌               ▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░▌      ▐░▌▐░░░░░░░░░░░▌
▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░▌               ▐░█▀▀▀▀▀▀▀▀▀ ▐░▌       ▐░▌▐░▌░▌     ▐░▌▐░█▀▀▀▀▀▀▀▀▀
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌          ▐░▌       ▐░▌▐░▌▐░▌    ▐░▌▐░▌
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌ ▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌▐░▌ ▐░▌   ▐░▌▐░█▄▄▄▄▄▄▄▄▄
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌▐░░░░░░░░▌▐░▌       ▐░▌▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌ ▀▀▀▀▀▀█░▌▐░▌       ▐░▌▐░▌   ▐░▌ ▐░▌ ▀▀▀▀▀▀▀▀▀█░▌
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌    ▐░▌▐░▌          ▐░▌
▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄      ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░▌     ▐░▐░▌ ▄▄▄▄▄▄▄▄▄█░▌
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌      ▐░░▌▐░░░░░░░░░░░▌
 ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀       ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀        ▀▀  ▀▀▀▀▀▀▀▀▀▀▀

a new modular gunning system
every /obj/item/gun/modular/ has some basic stats and some basic shooting behavior. Nothing super complex.
by default all children of /obj/item/gun/modular/ should populate their own barrel/stock/magazine/accessory as appropriate
with some ordinary basic parts. barrel and mag are necessary, the other two whatever.
additional custom parts can be created with stat bonuses, and other effects in their add_part_to_gun() proc

*/
#define GUN_NANO 1
#define GUN_FOSS 2
#define GUN_JUICE 4
#define GUN_SOVIET 8

ABSTRACT_TYPE(/obj/item/gun/modular)
/obj/item/gun/modular/ // PARENT TYPE TO ALL MODULER GUN'S
	var/gun_DRM = 0 // identify the gun model / type
	var/obj/item/gun_parts/barrel/barrel = null
	var/obj/item/gun_parts/stock/stock = null
	var/obj/item/gun_parts/magazine/magazine = null
	var/obj/item/gun_parts/accessory/accessory = null
	var/list/obj/item/gun_parts/parts = list()

	var/auto_eject = 0 // Do we eject casings on firing, or on reload?
	var/casings_to_eject = 0 // kee ptrack
	var/max_ammo_capacity = 1 // How much ammo can this gun hold? Don't make this null (Convair880).
	var/caliber = null // Can be a list too. The .357 Mag revolver can also chamber .38 Spc rounds, for instance (Convair880).


	New()
		..()
		build_gun()

ABSTRACT_TYPE(/obj/item/gun_parts)
/obj/item/gun_parts/
	var/part_DRM = 0 //which gun models is this part compatible with?
	var/obj/item/gun/modular/my_gun = null
	proc/add_part_to_gun(var/obj/item/gun/modular/gun)
		my_gun = gun
		return 1
	proc/remove_part_from_gun() // should safely un-do all of add_part_to_gun()
		my_gun = null
		return src

ABSTRACT_TYPE(/obj/item/gun_parts/barrel)
/obj/item/gun_parts/barrel/
	var/spread_angle = 0
	var/silenced = 0
	var/muzzle_flash = "muzzle_flash"

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.barrel = src
		my_gun.spread_angle += src.spread_angle
		my_gun.silenced = src.silenced
		my_gun.muzzle_flash = src.muzzle_flash

	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.barrel = null
		my_gun.spread_angle = initial(my_gun.spread_angle)
		my_gun.silenced = initial(my_gun.silenced)
		my_gun.muzzle_flash = initial(my_gun.muzzle_flash)
		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/stock)
/obj/item/gun_parts/stock/
	var/can_dual_wield = 1
	var/max_ammo_capacity = 0 //modifier

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.stock = src
		my_gun.can_dual_wield = src.can_dual_wield
		my_gun.max_ammo_capacity += src.max_ammo_capacity

	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.stock = null
		my_gun.can_dual_wield = initial(my_gun.can_dual_wield)
		my_gun.max_ammo_capacity = initial(my_gun.max_ammo_capacity)
		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/magazine)
/obj/item/gun_parts/magazine/
	var/rechargeable = 0
	var/datum/projectile/current_projectile = null
	var/list/projectiles = null
	var/max_ammo_capacity = 0 //modifier

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.magazine = src

		my_gun.current_projectile = src.current_projectile
		my_gun.projectiles = src.projectiles
		my_gun.max_ammo_capacity += src.max_ammo_capacity

	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.magazine = null

		my_gun.current_projectile = initial(my_gun.current_projectile)
		my_gun.projectiles = initial(my_gun.projectiles)
		my_gun.max_ammo_capacity = initial(my_gun.max_ammo_capacity)
		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/accessory)
/obj/item/gun_parts/accessory/
	var/alt_fire = 0 //does this accessory offer an alt-fire mode?
	var/call_on_fire = 0 // does the gun call this accessory's on_fire() proc?

	proc/alt_fire()
		return alt_fire

	proc/on_fire()
		return call_on_fire



/obj/item/gun/modular/proc/build_gun()
	parts = list()
	if(barrel)
		parts += barrel
	if(stock)
		parts += stock
	if(magazine)
		parts += magazine
	if(accessory)
		parts += accessory

	for(var/obj/item/gun_parts/part as anything in parts)
		if(src.gun_DRM & part.part_DRM)
			part.add_part_to_gun(src)

	//update the icon to match!!!!!


// THIS NEXT PART MIGHT B STUPID
ABSTRACT_TYPE(/obj/item/storage/gun_workbench/)
/obj/item/storage/gun_workbench/
	slots = 1
	var/part = null
	var/gun_DRM = 0
	var/partname = "nothing"
	max_wclass = 4

	barrel
		part = /obj/item/gun_parts/barrel/
		partname = "barrel"
	stock
		part = /obj/item/gun_parts/stock/
		partname = "stock"
	magazine
		part = /obj/item/gun_parts/magazine/
		partname = "magazine"
	accessory
		part = /obj/item/gun_parts/accessory/
		partname = "doodad"

	check_can_hold(obj/item/W)
		if(!istype(W,part))
			boutput(usr, "You can only place a [src.partname] here!")
			return
		else
			var/obj/item/gun_parts/new_part = W
			if(new_part.part_DRM & gun_DRM)
				..()
			else
				boutput(usr, "That part isn't compatible with your gun!")
				return

//told u
/obj/table/gun_workbench/
	name = "gunsmithing workbench"
	desc = "lay down a rifle and start swappin bits"

	var/list/obj/item/gun_parts/parts = list()
	var/obj/item/gun/modular/gun = null
	var/obj/item/storage/gun_workbench/barrel/barrel = null
	var/obj/item/storage/gun_workbench/stock/stock = null
	var/obj/item/storage/gun_workbench/magazine/magazine = null
	var/obj/item/storage/gun_workbench/accessory/accessory = null

	New()
		..()
		barrel = new()
		stock = new()
		magazine = new()
		accessory = new()


	attackby(obj/item/W as obj, mob/user as mob, params)
		if(gun)
			boutput(user, "<span class='notice'>There's already a gun on [src].</span>")
			return
		if(!istype(W,/obj/item/gun/modular/))
			boutput(user, "<span class='notice'>You should probably only use this for guns.</span>")
			return
		else
			boutput(user, "<span class='notice'>You secure [W] on [src].</span>")
			//ok its a modular gun!
			//open the gunsmithing menu (cross-shaped inventory thing) and let the user swap parts around in it
			// when they're done, put the parts back in the gun's slots and call gun.build_gun()
			load_gun(W)
			return

	attack_hand(mob/user)
		if(!gun)
			boutput(user, "<span class='notice'>You need to put a gun on [src] first.</span>")
			return
		else
			//open gunsmithing menu
			return

	proc/load_gun(var/obj/item/gun/modular/new_gun)
		src.gun = new_gun
		src.parts = new_gun.parts

		//update DRM for the storage slots.
		src.barrel.gun_DRM = new_gun.gun_DRM
		src.stock.gun_DRM = new_gun.gun_DRM
		src.magazine.gun_DRM = new_gun.gun_DRM
		src.accessory.gun_DRM = new_gun.gun_DRM

		//place parts in the storage slots
		if(new_gun.barrel)
			src.barrel.add_contents(new_gun.barrel.remove_part_from_gun())
		if(new_gun.stock)
			src.stock.add_contents(new_gun.stock.remove_part_from_gun())
		if(new_gun.magazine)
			src.magazine.add_contents(new_gun.magazine.remove_part_from_gun())
		if(new_gun.accessory)
			src.accessory.add_contents(new_gun.accessory.remove_part_from_gun())

		//update icon
//real stupid
	proc/open_gunsmithing_menu()
		//dear smart people please do
		return

	proc/remove_gun(mob/user as mob)
		//add parts to gun
		gun.barrel = src.barrel.get_contents()[1]
		gun.stock = src.stock.get_contents()[1]
		gun.magazine = src.magazine.get_contents()[1]
		gun.accessory = src.accessory.get_contents()[1]

		//dispense gun
		gun.build_gun()
		user.put_in_hand_or_drop(gun)

		//clear table
		gun = null
		barrel.contents = list()
		stock.contents = list()
		magazine.contents = list()
		accessory.contents = list()




/obj/item/gun/modular/foss // syndicate laser gun's!
	name = "Syndicate Laser Gun"
	desc = "An open-sourced and freely modifiable FOSS Inductive Flash Arc, Model 2k/19"
