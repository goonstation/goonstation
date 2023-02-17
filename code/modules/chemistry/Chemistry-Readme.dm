/*
NOTE: IF YOU UPDATE THE REAGENT-SYSTEM, ALSO UPDATE THIS README.

Structure: ///////////////////          //////////////////////////
		   // Mob or object // -------> // Reagents var (datum) // 	    Is a reference to the datum that holds the reagents.
		   ///////////////////          //////////////////////////
		   			|				    			 |
    The object that holds everything.   			 V
		   							      reagent_list var (list)   	An Associative List of datums:
																			reagent_list[reagent_id] = [reagent datum]
		   							      |          |          |
		   							      V          V          V

		   							         reagents (datums)	    	Reagents. I.e. Water , antitoxins or mercury.


Random important notes:

	An objects on_reagent_change will be called every time the objects reagents change.
	Useful if you want to update the objects icon etc.

About the Holder:

	The holder (reagents datum) is the datum that holds a list of all reagents
	currently in the object.It also has all the procs needed to manipulate reagents

		remove_any(var/amount)
			This proc removes reagents from the holder until the passed amount
			is matched. It'll try to remove some of ALL reagents contained.

		remove_any_except(var/amount, var/exception)
			Functions identically to remove_any, except it does not remove reagents of a specified id

		trans_to_direct(var/datum/reagents/target_reagents, var/amount=1, var/multiplier=1)
			Transfers one reagent to another holder.
			Pass it the holder, not the object, unlike the standard trans_to below.

		trans_to(var/obj/target, var/amount)
			This proc equally transfers the contents of the holder to another
			objects holder. You need to pass it the object (not the holder) you want
			to transfer to and the amount you want to transfer. Its return value is the
			actual amount transfered (if one of the objects is full/empty)

		metabolize(var/mob/M)
			This proc is called by the mobs life proc. It simply calls on_mob_life for
			all contained reagents. You shouldnt have to use this one directly.

		handle_reactions()
			This proc check all recipes and, on a match, uses them.
			It will also call the recipe's on_reaction proc (for explosions or w/e).
			Currently, this proc is automatically called by trans_to.

		isolate_reagent(var/reagent)
			Pass it a reagent id and it will remove all reagents but that one.
			It's that simple.

		del_reagent(var/reagent)
			Completely remove the reagent with the matching id.

		temperature_react()
			Simply calls the temperature_react procs of all contained reagents.

		update_total()
			This one simply updates the total volume of the holder.
			(the volume of all reagents added together)

		clear_reagents()
			This proc removes ALL reagents from the holder.

		reaction(var/atom/A, var/method=TOUCH, var/volume_modifier=0)
			This proc calls the appropriate reaction procs of the reagents.
			I.e. if A is an object, it will call the reagents reaction_obj
			proc. The method var is used for reaction on mobs. It simply tells
			us if the mob TOUCHed the reagent or if it INGESTed the reagent.
			Since the volume can be checked in a reagents proc, you might want to
			use the volume_modifier var to modifiy the passed value without actually
			changing the volume of the reagents.
			If you're not sure if you need to use this the answer is very most likely 'No'.
			You'll want to use this proc whenever an atom first comes in
			contact with the reagents of a holder. (in the 'splash' part of a beaker i.e.)
			More on the reaction in the reagent part of this readme.

		add_reagent(var/reagent, var/amount)
			Attempts to add X of the matching reagent to the holder.
			You wont use this much. Mostly in new procs for pre-filled
			objects.

		remove_reagent(var/reagent, var/amount)
			The exact opposite of the add_reagent proc.

		has_reagent(var/reagent, var/amount)
			Returns 1 if the holder contains this reagent.
			Or 0 if not.
			If you pass it an amount it will additionally check
			if the amount is matched. This is optional.

		get_reagent_amount(var/reagent)
			Returns the amount of the matching reagent inside the
			holder. Returns 0 if the reagent is missing.

		get_reagent(var/reagent_id)
			Returns the reagent matching the specified ID if in the holder, null otherwise.

		reagents_changed()
			Internally called whenever the reagents change - this calls my_atom.on_reagent_change()
			and also clears the description text (for refreshing whenever it is next needed)

		get_description(var/user, var/rc_flags)
			Returns the text description of the reagents. Usually the inexact description,
			but also the exact reagents in some cases depending on the container flags


		get_exact_description(var/user)
			Returns the amount and type of each reagent present, if the user should be able to see them

		get_inexact_description(var/rc_flags)
			Returns the inexact text description of the reagents.
			e.g. "It is half full of an opaque, brown liquid."
			Refreshes the description if necessary. Container flags show whether to report fullness, color, etc.

		get_average_color()
			Returns the average color of the reagents, weighted according to their transparency and concentration
			as a /datum/color

		get_state_description()
			returns "solid", "liquid", "gas", or "mixture".

		get_master_reagent()
			Examines the reagents and returns the ID of the one with the largest volume.

		get_master_reagent_name()
			Examines the reagents and returns the name of the one with the largest volume.
			IE, this will return "methamphetamine" vs get_master_reagent returning "methamphetamine".

		get_master_color(var/ignore_smokepowder = 0)
			Examines the reagents and returns the RGBA value of the one with the largest volume.

		Important variables:

			total_volume
				This variable contains the total volume of all reagents in this holder.

			reagent_list
				This is a list of all contained reagents. More specifically, references
				to the reagent datums.

			maximum_volume
				This is the maximum volume of the holder.

			my_atom
				This is the atom the holder is 'in'. Useful if you need to find the location.
				(i.e. for explosions)

			desc
				This is the inexact text description of the reagents. If null, will be refreshed
				when get_inexact_description() is called.

About Reagents:

	Reagents are all the things you can mix and fille in bottles etc. This can be anything from
	rejuvs over water to ... iron. Each reagent also has a few procs - i'll explain those below.

		reaction_mob(var/mob/M, var/method=TOUCH)
			This is called by the holder's reation proc.
			This version is only called when the reagent
			reacts with a mob. The method var can be either
			TOUCH or INGEST. You'll want to put stuff like
			acid-facemelting in here.

		reaction_obj(var/obj/O)
			This is called by the holder's reation proc.
			This version is called when the reagents reacts
			with an object. You'll want to put stuff like
			object melting in here ... or something. i dunno.

		reaction_turf(var/turf/T)
			This is called by the holder's reation proc.
			This version is called when the reagents reacts
			with a turf. You'll want to put stuff like extra
			slippery floors for lube or something in here.

		on_mob_life(var/mob/M, var/mult = 1)
			This proc is called everytime the mobs life proc executes.
			This is the place where you put damage for toxins ,
			drowsyness for sleep toxins etc etc.
			You'll want to call the parents proc by using ..() .
			If you dont, the chemical will stay in the mob forever -
			unless you write your own piece of code to slowly remove it.
			(Should be pretty easy, 1 line of code)

			mbc : mult is for realtime stuff. It is 1 when the life loop
			is hitting its speed of 1 tick per 2 seconds, it increases if we go slower


		pooled()
			This is called when the reagent is pooled pending reuse elsewhere.
			In case you introduce any extra vars to your reagent that'll track its effects
			make sure you reset them to their initial value in this proc.
			Also remember to call the parent when doing so.

	Important variables:

		holder
			This variable contains a reference to the holder the chemical is 'in'

		volume
			This is the volume of the reagent.

		id
			The id of the reagent

		name
			The name of the reagent.

		data
			This var can be used for whatever the fuck you want. I used it for the sleep
			toxins to make them work slowly instead of instantly. You could also use this
			for DNA in a blood reagent or ... well whatever you want.


About Recipes:

	Recipes are simple datums that contain a list of required reagents and a result.
	They also have a proc that is called when the recipe is matched.

		on_reaction(var/datum/reagents/holder, var/created_volume)
			This proc is called when the recipe is matched.
			You'll want to add explosions etc here.
			To find the location you'll have to do something
			like get_turf(holder.my_atom)

		name & id
			Should be pretty obvious.

		result
			This var contains the id of the resulting reagent.

		required_reagents
			This is a list of ids of the required reagents.
			Each id also needs an associated value that gives us the minimum required amount
			of that reagent. The handle_reaction proc can detect mutiples of the same recipes
			so for most cases you want to set the required amount to 1.

		result_amount
			This is the amount of the resulting reagent this recipe will produce.
			I recommend you set this to the total volume of all required reagent.


About the Tools:

	By default, all atom have a reagents var - but its empty. if you want to use an object for the chem.
	system you'll need to add something like this in its new proc:

		var/datum/reagents/R = new/datum/reagents(100) <<<<< create a new datum , 100 is the maximum_volume of the new holder datum.
		reagents = R <<<<< assign the new datum to the objects reagents var
		R.my_atom = src <<<<< set the holders my_atom to src so that we know where we are.

		This can also be done by calling a convenience proc:
		atom/proc/create_reagents(var/max_volume)

	Other important stuff:

		amount_per_transfer_from_this var
			This var is mostly used by beakers and bottles.
			It simply tells us how much to transfer when
			'pouring' our reagents into something else.

		atom/proc/is_open_container()
			Checks atom/var/flags & OPENCONTAINER.
			If this returns 1 , you can use syringes, beakers etc
			to manipulate the contents of this object.
			If it's 0, you'll need to write your own custom reagent
			transfer code since you will not be able to use the standard
			tools to manipulate it.

*/
