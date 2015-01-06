var/global/list/obj/item/device/thinktronic/thinktronic_devices = list()
var/global/thinktronic_device_count = 0

/obj/item/device/thinktronic/
	name = "\improper tablet"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/tablets.dmi'
	item_state = "tablet-clear"
	var/dat = null
	var/version = "ThinkTronic OS 2.4"
	var/ram = 128
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 3 //Luminosity for the flashlight function
	var/hasmessenger = 0 //Built in messenger?
	var/devicetype = "Tablet"
	var/loadeddata = null
	var/loadeddata_photo = null
	var/scanmode = null
	var/device_ID = 0
	var/candetonate = 1
	var/volume = 1
	var/shared = 0
	var/msgnotif = 0
	var/alertnotif = 0
	var/mounted = 0

	var/obj/item/weapon/card/id/id = null //Making it possible to slot an ID card into the tablet so it can function as both.
	var/obj/item/device/thinktronic_parts/HDD/HDD = null
	var/datum/browser/popup = null
	var/obj/item/device/thinktronic_parts/cartridge/cart = null

	New()
		thinktronic_devices += src
		thinktronic_device_count += 1
		device_ID = thinktronic_device_count + 1
		cart = new /obj/item/device/thinktronic_parts/cartridge(src)
		..()

	Destroy()
		thinktronic_devices -= src
		..()

	proc/create_message(var/mob/living/U = usr, var/obj/item/device/thinktronic/P)
 		// I know this looks very sloppy in terms of variable naming but i couldn't think of good names
		var/t = input(U, "Please enter message", name, null) as text
		t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
		if (!t || !istype(P))
			return
		if (!in_range(src, U) && loc != U)
			return
		if(!can_use(U))
			return
		if(network() && HDD.messengeron)
			var/obj/item/device/thinktronic_parts/HDD/MyHDD = HDD
			var/obj/item/device/thinktronic_parts/HDD/TheirHDD = P.HDD
			var/meexisting = 0
			var/themexisting = 0
			log_pda("[usr] (PDA: [MyHDD.name]) sent \"[t]\" to [TheirHDD.name]")
			//My HDD
			for(var/obj/item/device/thinktronic_parts/data/convo/C in MyHDD)
				if(C.device_ID == P.device_ID)
					meexisting = 1
					break
			if(meexisting)
				for(var/obj/item/device/thinktronic_parts/data/convo/C in MyHDD)
					if(C.device_ID == P.device_ID)
						C.mlog += "<i><b>[MyHDD.owner]([MyHDD.ownjob]):</b></i><br> [t]<br>"
						MyHDD.activechat = C
						break
			else
				var/obj/item/device/thinktronic_parts/data/convo/D = new /obj/item/device/thinktronic_parts/data/convo(MyHDD)
				D.mlogowner = TheirHDD.owner
				D.device_ID = P.device_ID
				for(var/obj/item/device/thinktronic_parts/data/convo/C in MyHDD)
					if(C.device_ID == P.device_ID)
						C.mlog += "<i><b>[MyHDD.owner]([MyHDD.ownjob]):</b></i><br> [t]<br>"
						MyHDD.activechat = C
						break
			//Their HDD
			for(var/obj/item/device/thinktronic_parts/data/convo/C in TheirHDD)
				if(C.device_ID == device_ID)
					themexisting = 1
					break
			if(themexisting)
				for(var/obj/item/device/thinktronic_parts/data/convo/C in TheirHDD)
					if(C.device_ID == device_ID)
						C.mlog += "<i><b>[MyHDD.owner]([MyHDD.ownjob]):</b></i><br> [t]<br>"
						var/mob/living/L = null
						if(P.loc && isliving(P.loc))
							L = P.loc
						if (P.volume == 1)
							playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)
						if (P.volume == 2)
							playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)
						for (var/mob/O in hearers(3, P.loc))
							if(P.volume)
								O.show_message(text("\icon[P] *[HDD.ttone]*"))
						for (var/mob/O in hearers(1, P.loc))
							if(P.volume == 2)
								O.show_message(text("\icon[P] <b>Message from [MyHDD.owner] ([MyHDD.ownjob]), </b>\"[t]\""))
						L << "\icon[P] <b>Message from [MyHDD.owner] ([MyHDD.ownjob]), </b>\"[t]\" (<a href='byond://?src=\ref[P];choice=QuikMessage;target=\ref[src]'>Reply</a>)"
						P.msgnotif = 1
						P.alerted()
						break
			else
				var/obj/item/device/thinktronic_parts/data/convo/D = new /obj/item/device/thinktronic_parts/data/convo(TheirHDD)
				D.mlogowner = MyHDD.owner
				D.device_ID = device_ID
				for(var/obj/item/device/thinktronic_parts/data/convo/C in TheirHDD)
					if(C.device_ID == device_ID)
						C.mlog += "<i><b>[MyHDD.owner]([MyHDD.ownjob]):</b></i><br> [t]<br>"
						var/mob/living/L = null
						if(P.loc && isliving(P.loc))
							L = P.loc
						if (P.volume == 1)
							playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)
						if (P.volume == 2)
							playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)
						for (var/mob/O in hearers(3, P.loc))
							if(P.volume)
								O.show_message(text("\icon[P] *[HDD.ttone]*"))
						for (var/mob/O in hearers(1, P.loc))
							if(P.volume == 2)
								O.show_message(text("\icon[P] <b>Message from [MyHDD.owner] ([MyHDD.ownjob]), </b>\"[t]\""))
						L << "\icon[P] <b>Message from [MyHDD.owner] ([MyHDD.ownjob]), </b>\"[t]\" (<a href='byond://?src=\ref[P];choice=QuikMessage;target=\ref[src]'>Reply</a>)"
						P.msgnotif = 1
						P.alerted()
						break
		else
			U << "<span class='notice'>ERROR: Server isn't responding.</span>"

	proc/explode() //This needs tuning.
		if(!src.candetonate) return
		if(!HDD) return
		var/turf/T = get_turf(src.loc)

		if (ismob(loc))
			var/mob/M = loc
			M.show_message("\red Your [src]'s Hard Drive ignites into flames!", 1)

		if(T)
			T.hotspot_expose(700,125)
			if(volume == 0)
				explosion(T, -1, -1, -1, -1, flame_range = 2)
			if(volume == 1)
				explosion(T, -1, -1, -1, -1, flame_range = 2)
			if(volume == 2)
				explosion(T, -1, 1, 2, 3, flame_range = 2)
				qdel(src)

		qdel(HDD)
		HDD = null
		return

	proc/create_file(var/mob/living/U = usr, var/obj/item/device/thinktronic/P)
 		// I know this looks very sloppy in terms of variable naming but i couldn't think of good names
		var/list/D = list()
		D["Cancel"] = "Cancel"
		for(var/obj/item/device/thinktronic_parts/program/PRG in HDD)
			if(PRG.DRM == 0)
				D["Program: [PRG.name]"] = PRG
		for(var/obj/item/device/thinktronic_parts/data/DATA in HDD)
			if(DATA.document || DATA.photo || DATA.convo)
				D["Data: [DATA.name]"] = DATA
		var/t = input(U, "Which file would you like to send?") as null|anything in D
		if (!in_range(src, U) && loc != U)
			return
		if(!can_use(U))
			return
		if(t == "Cancel")
			return 0

		var/obj/item/device/thinktronic_parts/data = D[t]

		if(network())
			if(P.network())
				if(data)
					if(data.app)
						var/obj/item/device/thinktronic_parts/program/Newdata = new data.type(P.cart)
						Newdata.sentby = "[HDD.owner]([HDD.ownjob])"
					if(data.photo)
						var/obj/item/device/thinktronic_parts/data/photo/Newdata = new data.type(P.cart)
						Newdata.sentby = "[HDD.owner]([HDD.ownjob])"
						Newdata.photoinfo = data.photoinfo
						Newdata.name = data.name
					if(data.document)
						var/obj/item/device/thinktronic_parts/data/document/Newdata = new data.type(P.cart)
						Newdata.sentby = "[HDD.owner]([HDD.ownjob])"
						Newdata.doc = data.doc
						Newdata.doc_links = data.doc_links
						Newdata.fields = data.fields
						Newdata.name = data.name
					if(data.convo)
						var/obj/item/device/thinktronic_parts/data/savedconvo/Newdata = new data.type(P.cart)
						Newdata.sentby = "[HDD.owner]([HDD.ownjob])"
						Newdata.mlog = data.mlog
						Newdata.name = data.name

				var/mob/living/L = null
				if(P.loc && isliving(P.loc))
					L = P.loc
				if (P.volume == 1)
					playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)
				if (P.volume == 2)
					playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)
				for (var/mob/O in hearers(3, P.loc))
					if(P.volume == 1)
						O.show_message(text("\icon[P] *[HDD.ttone]*"))
					if(P.volume == 2)
						O.show_message(text("\icon[P] *[HDD.ttone]*"))
				L << "\icon[P] <b>New download from [HDD.owner] ([HDD.ownjob]), </b>\"[data]\" (<a href='byond://?src=\ref[P];choice=downloads'>View Downloads</a>)"
				log_pda("[usr] (PDA: [HDD.name]) sent \"File: [data.name]\" to [P.HDD.name]")
				U << "File Sent!"
			else
				U << "<span class='notice'>ERROR: Client not found.</span>"
		else
			U << "<span class='notice'>ERROR: Server isn't responding.</span>"

/obj/item/device/thinktronic/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/device/thinktronic/GetID()
	return id

/obj/item/device/thinktronic/proc/remove_id()
	if (id)
		if (ismob(loc))
			var/mob/M = loc
			M.put_in_hands(id)
			usr << "<span class='notice'>You remove the ID from the [name].</span>"
		else
			id.loc = get_turf(src)
		id = null

/obj/item/device/thinktronic/proc/id_check(mob/user as mob, choice as num)//To check for IDs; 1 for in-pda use, 2 for out of pda use.
	if(choice == 1)
		if (id)
			remove_id()
		else
			var/obj/item/I = user.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id))
				user.drop_item()
				I.loc = src
				id = I
	else
		var/obj/item/weapon/card/I = user.get_active_hand()
		if (istype(I, /obj/item/weapon/card/id) && I:registered_name)
			var/obj/old_id = id
			user.drop_item()
			I.loc = src
			id = I
			user.put_in_hands(old_id)
	return

/obj/item/device/thinktronic/proc/network()
	var/turf/T = get_turf(loc)
	if (!T) return
	if (!HDD) return
	if (HDD.neton)
		for (var/list/obj/machinery/nanonet_server/MS in nanonet_servers)
			if(MS.active)
				if(MS.z == T.z)//on the same z-level?
					return 1
					break
				else
					for (var/list/obj/machinery/nanonet_router/router in nanonet_routers)
						if(router.z == T.z)//on the same z-level?
							if(router.active)
								return 1
								break

/obj/item/device/thinktronic/proc/can_use(mob/user)
	if(user && ismob(user))
		if(user.stat || user.restrained() || user.paralysis || user.stunned || user.weakened)
			return 0
		if(loc == user)
			return 1
		if(devicetype == "Laptop")
			return 1
	return 0

/obj/item/device/thinktronic/proc/alerted()
	if(devicetype == "Tablet")
		overlays.Cut()
		overlays += image('icons/obj/tablets.dmi', "tablet-r")
	if(devicetype == "Laptop")
		overlays.Cut()
		if(mounted)
			overlays += image('icons/obj/Laptop.dmi', "Laptop_open_r")
		if(!mounted)
			overlays += image('icons/obj/Laptop.dmi', "Laptop_closed_r")

/obj/item/device/thinktronic/proc/unalerted(var/alert,var/msg)
	if(devicetype == "Tablet")
		overlays.Cut()
		if(alert)
			alertnotif = 0
		if(msg)
			msgnotif = 0
		if(msgnotif || alertnotif)
			overlays += image('icons/obj/tablets.dmi', "tablet-r")
	if(devicetype == "Laptop")
		overlays.Cut()
		if(alert)
			alertnotif = 0
		if(msg)
			msgnotif = 0
		if(msgnotif || alertnotif)
			if(mounted)
				overlays += image('icons/obj/Laptop.dmi', "Laptop_open_r")
			if(!mounted)
				overlays += image('icons/obj/Laptop.dmi', "Laptop_closed_r")