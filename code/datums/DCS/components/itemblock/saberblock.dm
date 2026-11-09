// adds object properties to the sword while blocking with it.

ABSTRACT_TYPE(/datum/component/itemblock/reflect)
TYPEINFO(/datum/component/itemblock/reflect)
	initialization_args = list(
		ARG_INFO("can_block_proc", DATA_INPUT_NUM, "Whether the person using this item will be allowed to block (This should basically always be 1 since you can't \
		reference procs from varedit).", TRUE),
		ARG_INFO("block_color_proc", DATA_INPUT_COLOR, "Color to display on block.", "#FFFFFF")
	)
/datum/component/itemblock/reflect
	bonus = 1 //bonus is a flag that determines whether or not the item tooltip will include "⛨ Block+: RESIST with this item for more info" when not blocking
	var/can_block_check
	var/get_color_proc

/datum/component/itemblock/reflect/Initialize(var/can_block_proc, var/block_color_proc)
	. = ..()
	can_block_check = can_block_proc
	get_color_proc = block_color_proc

/datum/component/itemblock/reflect/proc/do_reflect_animation(mob/user)
	var/effect_color
	if (src.get_color_proc)
		if (istext(src.get_color_proc)) //txt, so prolly a color
			effect_color = src.get_color_proc
		else // guess it's a proc
			effect_color = call(parent, get_color_proc)()
	else
		effect_color = "#FFFFFF"

	if (effect_color == "RAND")
		effect_color = pick("#FF0000","#FF9A00","#FFFF00","#00FF78","#00FFFF","#0081DF","#CC00FF","#FFCCFF","#EBE6EB")

	var/obj/itemspecialeffect/clash/C = new /obj/itemspecialeffect/clash
	C.setup(user.loc)
	C.color = effect_color
	var/matrix/m = matrix()
	m.Turn(rand(0,360))
	C.transform = m
	var/matrix/m1 = C.transform
	m1.Scale(2,2)
	var/turf/target = get_step(user,user.dir)
	C.pixel_x = 32*(user.x - target.x)*0.2
	C.pixel_y = 32*(user.y - target.y)*0.2
	animate(C,transform=m1,time=8)

/datum/component/itemblock/reflect/saberblock

//proc that is called when the base item is used to block. The parent itemblock component has already registered this proc for the "COMSIG_ITEM_BLOCK_BEGIN" signal
/datum/component/itemblock/reflect/saberblock/on_block_begin(obj/item/I, var/obj/item/grab/block/B)
	. = ..()//Always call your parents
	if(!can_block_check || isnum(can_block_check) || (call(I, can_block_check)()))
		RegisterSignal(B.assailant, COMSIG_ATOM_PROJECTILE_REFLECTED, PROC_REF(do_reflect_animation))
		B.setProperty("reflection", 1)
		B.setProperty("disorient_resist", 75)

		var/blockplus = DEFAULT_BLOCK_PROTECTION_BONUS + 3
		if(I.c_flags & BLOCK_CUT)
			B.setProperty("I_block_cut", blockplus)
		if(I.c_flags & BLOCK_STAB)
			B.setProperty("I_block_stab", blockplus)
		if(I.c_flags & BLOCK_BURN)
			B.setProperty("I_block_burn", blockplus)
		if(I.c_flags & BLOCK_BLUNT)
			B.setProperty("I_block_blunt", blockplus)

//proc that is called when the block is ended. The parent itemblock component has already registered this proc for the "COMSIG_ITEM_BLOCK_END" signal
/datum/component/itemblock/reflect/saberblock/on_block_end(obj/item/I, var/obj/item/grab/block/B)
	. = ..()//always always
	UnregisterSignal(B.assailant, COMSIG_ATOM_PROJECTILE_REFLECTED)
	B.delProperty("reflection")
	B.delProperty("disorient_resist")

/datum/component/itemblock/reflect/toyswordblock
/datum/component/itemblock/reflect/toyswordblock/on_block_begin(obj/item/I, var/obj/item/grab/block/B)
	. = ..()
	if (istype(I, /obj/item/toy/sword))
		RegisterSignal(B.assailant, COMSIG_ATOM_PROJECTILE_REFLECTED, PROC_REF(do_reflect_animation))
		B.setProperty("toyreflection", 1)

/datum/component/itemblock/reflect/toyswordblock/on_block_end(obj/item/I, var/obj/item/grab/block/B)
	. = ..()
	UnregisterSignal(B.assailant, COMSIG_ATOM_PROJECTILE_REFLECTED)
	B.delProperty("toyreflection")
