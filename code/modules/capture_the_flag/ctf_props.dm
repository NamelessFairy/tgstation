/obj/effect/immovablerod/ctf
    var/direction = LEFT
    loopy_rod = TRUE

/obj/effect/immovablerod/ctf/New()
    . = ..()

/obj/effect/immovablerod/ctf/Initialize(mapload)
    . = ..()
    walk_in_direction(direction)
