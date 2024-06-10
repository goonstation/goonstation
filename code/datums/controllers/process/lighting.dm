
/// List of items that want to be deleted
var/datum/circular_queue/light_update_queue = new /datum/circular_queue(500)

/// Controls the LIGHTS
datum/controller/process/lighting

	var/max_chunk_size = 6 //20 prev
	var/min_chunk_size = 2
	var/count = 0
	var/chunk_count = 0

	var/chunk_count_increase_rate = 0.12//0.06

	setup()
		name = "Lighting"
		schedule_interval = 0.1 SECONDS
		tick_allowance = 90

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/lighting/old_lighting = target
		src.tick_allowance = old_lighting.schedule_interval
		src.max_chunk_size = old_lighting.max_chunk_size
		src.min_chunk_size = old_lighting.min_chunk_size
		src.count = old_lighting.count
		src.chunk_count = old_lighting.chunk_count
		src.chunk_count_increase_rate = old_lighting.chunk_count_increase_rate

	enable()
		..()
		RL_Resume()

	disable()
		..()
		RL_Suspend()

	doWork()
		count = 0
		var/datum/light/L = 0

		if (!light_update_queue.cur_size)
			chunk_count = min_chunk_size

		while(light_update_queue.cur_size)

			L = light_update_queue.dequeue()

			if (L && L.dirty_flags != 0)

				if (L.dirty_flags & D_ENABLE)
					if (L.enabled)
						L.disable(queued_run = 1)
						L.dirty_flags &= ~D_ENABLE

				if (L.dirty_flags & D_BRIGHT)
					L.set_brightness(L.brightness_des, queued_run = 1)
				if (L.dirty_flags & D_COLOR)
					L.set_color(L.r_des,L.g_des,L.b_des, queued_run = 1)
				if (L.dirty_flags & D_HEIGHT)
					L.set_height(L.height_des, queued_run = 1)

				if (L.dirty_flags & D_MOVE)
					L.move(L.x_des,L.y_des,L.z_des,L.dir_des, queued_run = 1)


				if (L.dirty_flags & D_ENABLE)
					if (!L.enabled)
						L.enable(queued_run = 1)
						L.dirty_flags &= ~D_ENABLE

				L.dirty_flags = 0

				count++

			if (APPROX_TICK_USE > LIGHTING_MAX_TICKUSAGE && count >= chunk_count)
				chunk_count = min(max_chunk_size, chunk_count + chunk_count_increase_rate*2)
				break

		chunk_count = max(min_chunk_size, chunk_count - chunk_count_increase_rate)

/datum/circular_queue

	var/list/list = null

	var/read_index = 1
	var/write_index = 1
	var/cur_size = 0
	var/const/increase_size_amt = 100


	New(ListSize = 500)
		..()
		src.list = new/list(ListSize)

	proc/dequeue()
		.= 0
		if (cur_size > 0)
			.= list[read_index]

			list[read_index] = 0
			read_index ++

			if (read_index > list.len)
				read_index = 1

			update_size()

	proc/update_size()
		if (write_index >= read_index)
			cur_size = write_index - read_index
		else
			cur_size = (write_index + list.len) - read_index

	proc/queue(var/Q)
		if (!list)
			src.New()

		if (cur_size + 1 >= list.len)
			grow()

		list[write_index] = Q
		write_index ++

		if (write_index > list.len)
			write_index = 1

		update_size()

	proc/grow()
		list.len += increase_size_amt
		update_size()

	proc/shrink()//maybe todo, maybe not necessary idk
