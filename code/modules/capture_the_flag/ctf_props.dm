/obj/effect/overlay/shadow
    icon = 'icons/turf/decals.dmi'
    name = "shadow"
    layer = WALL_OBJ_LAYER
    icon_state = "shadow"
    anchored = TRUE
    mouse_opacity = 0

/obj/effect/overlay/shadow/directional
    icon_state = "directional_shadow"

/turf/open/water/mirror
    initial_gas_mix = OPENTURF_DEFAULT_ATMOS
    slowdown = 0

    var/obj/effect/water_reflection/reflection_visuals

/turf/open/water/mirror/Initialize()
    . = ..()
    reflection_visuals = new
    vis_contents += reflection_visuals
    reflection_visuals.setup_visuals(get_turf(src))
    
/obj/effect/water_reflection
    appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE
    mouse_opacity = MOUSE_OPACITY_TRANSPARENT
    vis_flags = VIS_INHERIT_ID
    layer = BELOW_OBJ_LAYER
    alpha = 150
    var/turf/reflect_turf
    pixel_y = -32

/obj/effect/water_reflection/proc/setup_visuals(var/turf/home_turf)
//    reflect_turf = get_step(home_turf, NORTH)
    reflect_turf = home_turf
    transform = transform.Scale(1,-1)
    clear_filters()
    vis_contents = null

    add_filter("portal_blur", 1, list("type" = "blur", "size" = 0.5))
    add_filter("portal_ripple", 1, list("type" = "ripple", "size" = 2, "radius" = 1, "falloff" = 1))

    animate(get_filter("portal_ripple"), time = 1.3 SECONDS, loop = -1, easing = LINEAR_EASING, radius = 32)

    vis_contents += reflect_turf
//    vis_contents += block(locate(reflect_turf.x - 5, reflect_turf.y - 5, reflect_turf.z), locate(reflect_turf.x + 5, reflect_turf.y + 5, reflect_turf.z))
