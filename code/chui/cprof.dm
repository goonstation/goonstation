//#ifdef DEBUG



datum/cprofiler
	var
		global/list/CPROF_STKN = list()
		global/list/CPROF_STKT = list()
		global/list/CPROF_L   = list()

		global/list/CPROF_ACTV = list()
		global/list/CPROF_STACK= list()
	proc/begin( var/name )
		CPROF_STACK += list()
		//CPROF_ACTV  =

//TODO; #ifdef BTIME
#define CPROF_GTIME (world.timeofday)
#define CPROF_PRECISION 10//10 GTIME/s

#define CPROF(name) CPROFILER.begin(name)
