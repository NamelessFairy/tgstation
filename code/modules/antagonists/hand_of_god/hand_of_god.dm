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
	if(T)
		place_toilet(T)

/mob/camera/godhand/proc/place_toilet(turf/tile)
//	var/obj/structure/toilet/toilet = new(tile)
//	toilet.SpinAnimation()
	new /obj/structure/blueprint(tile)

/mob/camera/godhand/proc/RightClickOn(atom/A)
	if(istype(A, /mob/living/carbon))
		blow_mind(A)

/mob/camera/godhand/proc/blow_mind(mob/living/carbon/victim)
	victim.gib()
