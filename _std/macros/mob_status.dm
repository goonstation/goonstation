// because fuck remembering what stat means every single time
#define isalive(x) (ismob(x) && x.stat == 0)
#define isunconscious(x) (ismob(x) && x.stat == 1)
#define isdead(x) (ismob(x) && x.stat == 2)
#define setalive(x) if (ismob(x)) x.stat = 0
#define setunconscious(x) if (ismob(x)) x.stat = 1
#define setdead(x) if (ismob(x)) x.stat = 2

// status effect system stuff
#define ADD_STATUS_LIMIT(target, group, value)\
	do { \
		if (length(target.statusLimits)) { \
			target.statusLimits[group] = value; \
		} else { \
			target.statusLimits = list(group = value);\
		} \
	} while (0)

#define REMOVE_STATUS_LIMIT(target, group)\
	do { \
		target.statusLimits -= group;\
	} while (0)
