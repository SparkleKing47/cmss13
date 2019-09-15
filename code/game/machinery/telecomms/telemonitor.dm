//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32


/*
	Telecomms monitor tracks the overall trafficing of a telecommunications network
	and displays a heirarchy of linked machines.
*/


/obj/structure/machinery/computer/telecomms/monitor
	name = "Telecommunications Monitor"
	icon_state = "comm_monitor"

	var/screen = 0				// the screen number:
	var/list/machinelist = list()	// the machines located by the computer
	var/obj/structure/machinery/telecomms/SelectedMachine

	var/network = "NULL"		// the network to probe

	var/temp = ""				// temporary feedback messages

	attack_hand(mob/user as mob)
		if(stat & (BROKEN|NOPOWER))
			return
		user.set_interaction(src)
		var/dat = "<TITLE>Telecommunications Monitor</TITLE><center><b>Telecommunications Monitor</b></center>"

		switch(screen)


		  // --- Main Menu ---

			if(0)
				dat += "<br>[temp]<br><br>"
				dat += "<br>Current Network: <a href='?src=\ref[src];network=1'>[network]</a><br>"
				if(machinelist.len)
					dat += "<br>Detected Network Entities:<ul>"
					for(var/obj/structure/machinery/telecomms/T in machinelist)
						dat += "<li><a href='?src=\ref[src];viewmachine=[T.id]'>\ref[T] [T.name]</a> ([T.id])</li>"
					dat += "</ul>"
					dat += "<br><a href='?src=\ref[src];operation=release'>\[Flush Buffer\]</a>"
				else
					dat += "<a href='?src=\ref[src];operation=probe'>\[Probe Network\]</a>"


		  // --- Viewing Machine ---

			if(1)
				dat += "<br>[temp]<br>"
				dat += "<center><a href='?src=\ref[src];operation=mainmenu'>\[Main Menu\]</a></center>"
				dat += "<br>Current Network: [network]<br>"
				dat += "Selected Network Entity: [SelectedMachine.name] ([SelectedMachine.id])<br>"
				dat += "Linked Entities: <ol>"
				for(var/obj/structure/machinery/telecomms/T in SelectedMachine.links)
					if(!T.hide)
						dat += "<li><a href='?src=\ref[src];viewmachine=[T.id]'>\ref[T.id] [T.name]</a> ([T.id])</li>"
				dat += "</ol>"



		user << browse(dat, "window=comm_monitor;size=575x400")
		onclose(user, "server_control")

		temp = ""
		return


	Topic(href, href_list)
		if(..())
			return


		add_fingerprint(usr)
		usr.set_interaction(src)

		if(href_list["viewmachine"])
			screen = 1
			for(var/obj/structure/machinery/telecomms/T in machinelist)
				if(T.id == href_list["viewmachine"])
					SelectedMachine = T
					break

		if(href_list["operation"])
			switch(href_list["operation"])

				if("release")
					machinelist = list()
					screen = 0

				if("mainmenu")
					screen = 0

				if("probe")
					if(machinelist.len > 0)
						temp = "<font color = #D70B00>- FAILED: CANNOT PROBE WHEN BUFFER FULL -</font color>"

					else
						for(var/obj/structure/machinery/telecomms/T in range(25, src))
							if(T.network == network)
								machinelist.Add(T)

						if(!machinelist.len)
							temp = "<font color = #D70B00>- FAILED: UNABLE TO LOCATE NETWORK ENTITIES IN \[[network]\] -</font color>"
						else
							temp = "<font color = #336699>- [machinelist.len] ENTITIES LOCATED & BUFFERED -</font color>"

						screen = 0


		if(href_list["network"])

			var/newnet = stripped_input(usr, "Which network do you want to view?", "Comm Monitor", network)
			if(newnet && ((usr in range(1, src) || ishighersilicon(usr))))
				if(length(newnet) > 15)
					temp = "<font color = #D70B00>- FAILED: NETWORK TAG STRING TOO LENGHTLY -</font color>"

				else
					network = newnet
					screen = 0
					machinelist = list()
					temp = "<font color = #336699>- NEW NETWORK TAG SET IN ADDRESS \[[network]\] -</font color>"

		updateUsrDialog()
		return

	attackby(var/obj/item/D as obj, var/mob/user as mob)
		if(istype(D, /obj/item/tool/screwdriver))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
			if(do_after(user, 20, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
				if (src.stat & BROKEN)
					to_chat(user, SPAN_NOTICE(" The broken glass falls out."))
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					new /obj/item/shard( src.loc )
					var/obj/item/circuitboard/computer/comm_monitor/M = new( A )
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 3
					A.icon_state = "3"
					A.anchored = 1
					qdel(src)
				else
					to_chat(user, SPAN_NOTICE(" You disconnect the monitor."))
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					var/obj/item/circuitboard/computer/comm_monitor/M = new( A )
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 4
					A.icon_state = "4"
					A.anchored = 1
					qdel(src)
		src.updateUsrDialog()
		return
