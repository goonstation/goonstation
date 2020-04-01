datum/atmos/pipeline
	var/datum/gas_mixture/Gasses = null
	var/list/obj/machinery/atmos/pipe/pipelist = new/list()
	var/list/obj/machinery/atmos/node/nodelist = new/list()

	var/Percent_Avail = 0
	var/Max = 0


	New()
		Gasses = new
		return

///MERGE
///Takes two pipelines and puts them together
	proc/merge(datum/atmos/pipeline/slave)
		if(slave == src)
			return
		for(var/obj/machinery/atmos/pipe/P in slave.pipelist)
			src.pipelist.Add(P)
			slave.pipelist.Remove(P)
		for(var/obj/machinery/atmos/node/N in slave.nodelist)
			src.nodelist.Add(N)
			slave.nodelist.Remove(N)


///SPLIT
///Takes this pipeline and turns it into two
	proc/split()
		return

///ADD_GAS
///Adds some gas into this pipeline's gas_mixture object
	proc/add_gas(var/plasma, var/oxy, var/co2, var/n2o, var/obj/Giver)
		return

///REMOVE_GAS
///Takes some gas from this pipeline's gas_mixture object
	proc/remove_gas(var/plasma, var/oxy, var/co2, var/n2o, var/obj/Taker)
		return

///ADD_PIPE
///Adds a pipe object to the line, will call MERGE if it has a parent other than this one
	proc/add_pipe(var/obj/machinery/atmos/pipe/P)
		if(P.parent)
			if(P.parent != src)
				src.merge(P.parent)
				return
		else
			pipelist.add(P)
			P.parent = src
			return

///ADD_PIPE
///Adds a node object to the line
	proc/add_node(var/obj/machinery/atmos/node/N)
		return



	/*

	datum/gas_mixture

			oxygen = 0
			carbon_dioxide = 0
			nitrogen = 0
			toxins = 0

			volume = CELL_VOLUME

			temperature = 0 //in Kelvin, use calculate_temperature() to modify

	*/
