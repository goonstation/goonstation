#define itemblock_tooltip_entry(img, desc) "<br><img src=\"[resource("images/tooltips/[img]")]\" class='icon' /> [desc]"
// A dummy parent type used for easily making components that are active when blocking with an item

/datum/component/itemblock
	var/list/signals = list()			//signals to register the blocking mob to
	var/proctype // = PROC_REF(pass		//proc) to be called by when we receive a signal in 'signals()'
	var/mobtype = /mob/living			//what type of mobs should we register above stuff to?
	var/bonus = 0						//do we want to show a line in the tooltip to "resist for more info"?
	var/showTooltip = 0					//are we currently showing extra tooltip stuff? check this in getTooltipDesc


/datum/component/itemblock/Initialize()
	..()
	SHOULD_CALL_PARENT(1)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_BLOCK_BEGIN, PROC_REF(on_block_begin))
	RegisterSignal(parent, COMSIG_ITEM_BLOCK_END, PROC_REF(on_block_end))
	var/obj/item/I = src.parent
	if(bonus)
		I.c_flags |= BLOCK_TOOLTIP

/datum/component/itemblock/proc/on_block_begin(obj/item/I, var/obj/item/grab/block/B)
	SHOULD_CALL_PARENT(1)
	if(istype(B.assailant, mobtype)) //make sure only things that we want are getting signals registered for them
		RegisterSignal(B.assailant, signals, proctype, TRUE) //start listening for signals from the user
	else
		UnregisterSignal(B.assailant, signals)
	showTooltip = 1 //show any custom tooltip stuff

/datum/component/itemblock/proc/on_block_end(obj/item/I, var/obj/item/grab/block/B)
	SHOULD_CALL_PARENT(1)
	UnregisterSignal(B.assailant, signals) //block over, quit listening
	showTooltip = 0 //hide our tooltips, if any
