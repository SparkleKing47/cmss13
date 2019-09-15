/obj/structure/machinery/atmospherics/unary/heat_exchanger

	name = "heat exchanger"
	desc = "Exchanges heat between two input gases. Setup for fast heat transfer"
	icon = 'icons/obj/pipes/heat_exchanger.dmi'
	icon_state = "intact"
	density = 1

	var/obj/structure/machinery/atmospherics/unary/heat_exchanger/partner = null
	var/update_cycle

/obj/structure/machinery/atmospherics/unary/heat_exchanger/update_icon()
	if(node)
		icon_state = "intact"
	else
		icon_state = "exposed"

/obj/structure/machinery/atmospherics/unary/heat_exchanger/initialize()
	if(!partner)
		var/partner_connect = turn(dir,180)

		for(var/obj/structure/machinery/atmospherics/unary/heat_exchanger/target in get_step(src, partner_connect))
			if(target.dir & get_dir(src, target))
				partner = target
				partner.partner = src
				break

	..()

/obj/structure/machinery/atmospherics/unary/heat_exchanger/process()
	..()
	if(!partner)
		return 0
	return 0

/obj/structure/machinery/atmospherics/unary/heat_exchanger/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(!iswrench(W))
		return ..()
	var/turf/T = loc
	if(level == 1 && isturf(T) && T.intact_tile)
		to_chat(user, SPAN_WARNING("You must remove the plating first."))
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
