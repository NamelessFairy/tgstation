/obj/effect/immovablerod/ctf


/obj/effect/immovablerod/ctf/New(atom/start, atom/end, aimed_at, force_looping)
    RegisterSignal(src, COMSIG_ATOM_ENTERING, .proc/on_entering_atom)
    walk_in_direction(direction)
    return
