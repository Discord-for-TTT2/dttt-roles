CreateConVar(
    "ttt2_mute_roles",
    1,
    {FCVAR_ARCHIVE, FCVAR_NOTIFY},
    "Which roles to reveal: 0: Team Traitor, 1: Team Innocent, 2: All",
    0,
    2
)

CreateConVar(
    "ttt2_mute_dmg_scale",
    0.1,
    {FCVAR_ARCHIVE, FCVAR_NOTIFY},
    "The damage scaling applied to the mute",
    0, -- min
    2 -- max
)