#define shuffle_list(x) do { var/listlen = length(x); for(var/i in 1 to listlen) x.Swap(i, rand(i, listlen)) } while (0)
