//example component for itemblocks - heats up the user on life tick while blocking
/datum/component/itemblock/warmsup
	signals = list(COMSIG_HUMAN_LIFE_TICK) //signal that this component is listening for. COMSIG_HUMAN_LIFE_TICK is sent once per Life loop, as defined in Life.dm
	mobtype = /mob/living/carbon/human //Component will only register for the signal if the mob blocking is of this type, in this case, human
	bonus = 1 //bonus is a flag that determines whether or not the item tooltip will include "⛨ Block+: RESIST with this item for more info" when not blocking
	proctype = .proc/warmup //the proc to be called when this component recieves the signal it is listening for, in this case, COMSIG_HUMAN_LIFE_TICK

//arguments are sent from the the SendSignal() in Life.dm:140
//SEND_SIGNAL(src, COMSIG_HUMAN_LIFE_TICK, (life_time_passed / tick_spacing))
//first argument, src, is the atom to be sending the signal to, and is also the first argument of the proc triggered by the signal
//second argument, COMSIG_HUMAN_LIFE_TICK, is the type of signal that was send. This matches the signal we are registered to,
//(registering for the signal happened in /datum/component/itemblock/proc/on_block_begin()), so this triggers the proc below
//third argument, (life_time_passed / tick_spacing), is the tick spacing multiplier for the Life Loop. Signalled procs may have any number of additional arguments. This signal only sends this one additional argument, however
/datum/component/itemblock/warmsup/proc/warmup(mob/living/carbon/human/H, var/mult) 
	if(parent != H.equipped())
		return //do nothing if not in active hand
	if(parent in H.get_equipped_items() && H.bodytemperature < H.base_body_temp) // Shamelessly copy-pasted from coffee
		H.bodytemperature = min(H.base_body_temp, H.bodytemperature+(5 * mult))

//proc that is called when the base item is used to block. The parent itemblock component has already registered this proc for the "COMSIG_ITEM_BLOCK_BEGIN" signal 
datum/component/itemblock/warmsup/on_block_begin(obj/item/I, mob/user)
	. = ..()//Always call your parents
	if(I.c_flags & HAS_GRAB_EQUIP)
		for(var/obj/item/grab/block/B in I)
			B.setProperty("coldprot", 25)
			B.setProperty("custom1", "Warms you up over time")

//proc that is called when the block is ended. The parent itemblock component has already registered this proc for the "COMSIG_ITEM_BLOCK_END" signal
datum/component/itemblock/warmsup/on_block_end(obj/item/I, mob/user)
	. = ..()//always always
	if(I.c_flags & HAS_GRAB_EQUIP)
		for(var/obj/item/grab/block/B in I)
			B.delProperty("coldprot")
			B.delProperty("custom1")
