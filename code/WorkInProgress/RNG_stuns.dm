/*
██████╗ ███╗   ██╗ ██████╗     ███████╗████████╗██╗   ██╗███╗   ██╗███████╗
██╔══██╗████╗  ██║██╔════╝     ██╔════╝╚══██╔══╝██║   ██║████╗  ██║██╔════╝
██████╔╝██╔██╗ ██║██║  ███╗    ███████╗   ██║   ██║   ██║██╔██╗ ██║███████╗
██╔══██╗██║╚██╗██║██║   ██║    ╚════██║   ██║   ██║   ██║██║╚██╗██║╚════██║
██║  ██║██║ ╚████║╚██████╔╝    ███████║   ██║   ╚██████╔╝██║ ╚████║███████║
╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚══════╝

FRIEND WARCRIMES is amassing all the weapons with simplified RNG stun right here,
such that it might become easier to compare them to others, and do massive batch
balancing in a way that is not painful. Eventually perhaps these will return to
their respective object definitions, but for now they are cozy and warm. love u.

	var/rng_stun_rate = 0 // % chance to old-stun
	var/rng_stun_time = 0 // how many ticks to old-stun
	var/rng_stun_weak = 0 // how many ticks to weaken on an old-stun
	var/rng_stun_diso = 0 // how many ticks to disorient on an old-stun


 */
/obj/item/storage/toolbox
	//warcrimes - rng stuns - toolboxes disorient and stun but won't down
	rng_stun_rate = 3 //%
	rng_stun_time = 1 SECOND
	rng_stun_diso = 2 SECONDS
	rng_stun_weak = 0 SECONDS

/obj/item/extinguisher
	//warc - rng stuns - down and disorient without full stun
	rng_stun_rate = 2 // %
	rng_stun_time = 0 SECONDS
	rng_stun_weak = 2 SECONDS
	rng_stun_diso = 4 SECONDS

/obj/item/saw/syndie
	rng_stun_rate = 5 //%
	rng_stun_time = 2 SECOND
	rng_stun_diso = 10 SECONDS
	rng_stun_weak = 2 SECONDS

/obj/item/sword
	rng_stun_rate = 5 //%
	rng_stun_time = 2 SECONDS
	rng_stun_diso = 0 SECONDS
	rng_stun_weak = 3 SECONDS

/obj/item/bat
	rng_stun_rate = 3 //%
	rng_stun_time = 1 SECOND
	rng_stun_diso = 3 SECONDS
	rng_stun_weak = 2 SECONDS
