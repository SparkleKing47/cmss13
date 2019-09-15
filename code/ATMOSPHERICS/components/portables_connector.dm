/obj/structure/machinery/atmospherics/portables_connector
	icon = 'icons/obj/pipes/connector.dmi'
	icon_state = "map_connector"

	name = "Connector Port"
	desc = "For connecting portables devices related to atmospherics control."

	dir = SOUTH
	initialize_directions = SOUTH

	var/obj/structure/machinery/portable_atmospherics/connected_device

	var/obj/structure/machinery/atmospherics/node

	var/datum/pipe_network/network

	var/on = 0
	use_power = 0
	level = 1


/obj/structure/machinery/atmospherics/portables_connector/New()
	initialize_directions = dir
	..()

/obj/structure/machinery/atmospherics/portables_connector/update_icon()
	icon_state = "connector"

/obj/structure/machinery/atmospherics/portables_connector/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node, dir)

/obj/structure/machinery/atmospherics/portables_connector/hide(var/i)
	update_underlays()

/obj/structure/machinery/atmospherics/portables_connector/process()
	..()
	if(!on)
		return
	if(!connected_device)
		on = 0
		return
	return 1

// Housekeeping and pipe network stuff below
/obj/structure/machinery/atmospherics/portables_connector/network_expand(datum/pipe_network/new_network, obj/structure/machinery/atmospherics/pipe/reference)
	if(reference == node)
		network = new_network

	if(new_network.normal_members.Find(src))
		return 0

	new_network.normal_members += src

	return null

/obj/structure/machinery/atmospherics/portables_connector/Dispose()
	if(connected_device)
		connected_device.disconnect()
	if(node)
		node.disconnect(src)
		del(network)
	node = null
	. = ..()

/obj/structure/machinery/atmospherics/portables_connector/initialize()
	if(node) return

	var/node_connect = dir

	for(var/obj/structure/machinery/atmospherics/target in get_step(src,node_connect))
		if(target.initialize_directions & get_dir(target,src))
			var/c = check_connect_types(target,src)
			if (c)
				target.connected_to = c
				src.connected_to = c
				node = target
				break

	update_icon()
	update_underlays()

/obj/structure/machinery/atmospherics/portables_connector/build_network()
	if(!network && node)
		network = new /datum/pipe_network()
		network.normal_members += src
		network.build_network(node, src)


/obj/structure/machinery/atmospherics/portables_connector/return_network(obj/structure/machinery/atmospherics/reference)
	build_network()

	if(reference==node)
		return network

	if(reference==connected_device)
		return network

	return null

/obj/structure/machinery/atmospherics/portables_connector/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network == old_network)
		network = new_network

	return 1

/obj/structure/machinery/atmospherics/portables_connector/return_network_air(datum/pipe_network/reference)
	var/list/results = list()
	return results

/obj/structure/machinery/atmospherics/portables_connector/disconnect(obj/structure/machinery/atmospherics/reference)
	if(reference==node)
		del(network)
		node = null

	update_underlays()
	start_processing()
	return null


/obj/structure/machinery/atmospherics/portables_connector/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(!iswrench(W))
		return ..()
	if(connected_device)
		to_chat(user, SPAN_WARNING("You cannot unwrench [src], dettach [connected_device] first."))
		return 1
	if(locate(/obj/structure/machinery/portable_atmospherics, loc))
		return 1

	playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
	user.visible_message(SPAN_NOTICE("[user] begins unfastening [src]."),
	SPAN_NOTICE("You begin unfastening [src]."))
	if(do_after(user, 40, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
		playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
		user.visible_message(SPAN_NOTICE("[user] unfastens [src]."),
		SPAN_NOTICE("You unfasten [src]."))
		new /obj/item/pipe(loc, make_from = src)
		qdel(src)
