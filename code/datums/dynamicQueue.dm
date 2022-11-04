// Queue bins -- sizing
#define QUEUE_BIN_SIZE 100

/datum/dynamicQueue
	var/list/queue = new /list()
	var/binSize

	New(var/BinSize = QUEUE_BIN_SIZE)
		..()
		src.binSize = BinSize

	proc
		ensureNonEmptyQueue()
			// Make sure there is always at least one bin available in the queue
			if(queue.len == 0)
				queue.len++
				queue[1] = new /list()

		getLastBin()
			ensureNonEmptyQueue()

			// Get the bin at the end of the queue
			return queue[queue.len]

		getFirstBin()
			ensureNonEmptyQueue()
			return queue[1]

		isEmpty()
			if(queue.len == 0)
				return 1
			if(queue.len > 1)
				return 0
			var/list/bin = queue[1]
			if(bin.len > 0)
				return 0

		enqueue(var/D)
			//Get the last bin in the queue
			var/list/bin = getLastBin()

			// If the bin has grown too large, throw it back and build a new one
			if(bin.len >= binSize)
				bin = new /list()
				queue.len++
				queue[queue.len] = bin

			// Take special care of lists...
			if(islist(D))
				bin.len++
				bin[bin.len] = D
			else
				bin.Add(D)

		first(var/list/l)
			if(l.len > 0)
				. = l[1]
				l.Cut(1,2)
			else
				. = null

		last(var/list/l)
			if(l.len > 0)
				. = l[l.len]
				l.len--
			else
				. = null

		dequeue()
			if(!isEmpty())
				var/list/bin = getFirstBin()
				. = first(bin)
				if(bin.len == 0)
					queue.Cut(1,2)
			else
				. = null

		dequeueMany(var/num)
			var/list/ret = new /list()
			var/dequeued
			for(var/i = 0,i < num,i++)
				if(isEmpty())
					break
				dequeued = dequeue()
				if(isnull(dequeued))
					continue

				ret.len++
				ret[ret.len] = dequeued
			return ret

		count()
			var/count = 0
			var/list/bin
			for(var/i=1,i<=queue.len,i++)
				bin = queue[i]
				count += length(bin)
			return count
