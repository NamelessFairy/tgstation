#define PRE_SPAWN_PHASE 1
#define POST_SPAWN_PHASE 2

/mob/camera/godhand
	name = "Hand of God"
	real_name = "Hand of God"
	desc = "tbc"
	icon = 'icons/mob/silicon/cameramob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = 1
	see_in_dark = NIGHTVISION_FOV_RANGE
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	see_invisible = SEE_INVISIBLE_LIVING
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	var/phase = PRE_SPAWN_PHASE
	var/nexus

/mob/camera/godhand/Move(NewLoc, Dir = 0)
	forceMove(NewLoc)

/mob/camera/godhand/ClickOn(atom/A, params)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
//		MiddleClickOn(A, params)
		return
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
//		ShiftClickOn(A)
		return
	if(LAZYACCESS(modifiers, ALT_CLICK))
//		AltClickOn(A)
		return
	if(LAZYACCESS(modifiers, CTRL_CLICK))
//		CtrlClickOn(A)
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		RightClickOn(A)
		return
	var/turf/T = get_turf(A)
	if(phase == PRE_SPAWN_PHASE)
		create_nexus(T)
	else
		if(T)
			place_toilet(T)

/mob/camera/godhand/proc/is_valid_spawn_turf(turf/tile)
	var/area/area = get_area(tile)
	if((area && !(area.area_flags & CULT_PERMITTED)) || !tile || !is_station_level(tile.z) || isgroundlessturf(tile))
		return FALSE
	return TRUE

/mob/camera/godhand/proc/is_valid_structure_turf(turf/tile)
	if(is_valid_spawn_turf(tile))
		for(var/obj/effect/god_influence/influence in tile)
			return TRUE
	return FALSE

/mob/camera/godhand/proc/create_nexus(turf/tile)
	if(tile.density)
		to_chat(src, span_warning("Don't use walls"))
		return
	if(!is_valid_spawn_turf(tile))
		to_chat(src, span_warning("Bad Location, idiot"))
		return
	nexus = new /obj/structure/conduit/nexus(tile)
	phase = POST_SPAWN_PHASE

/mob/camera/godhand/proc/place_toilet(turf/tile)
//	new /obj/structure/blueprint(tile)
	if(is_valid_structure_turf(tile))
		new /obj/structure/conduit(tile)
	else
		to_chat(src, span_warning("Stay in range, idiot"))

/mob/camera/godhand/proc/RightClickOn(atom/A)
	if(istype(A, /mob/living/carbon))
		blow_mind(A)

/mob/camera/godhand/proc/blow_mind(mob/living/carbon/victim)
	victim.gib()

#undef PRE_SPAWN_PHASE
#undef POST_SPAWN_PHASE
