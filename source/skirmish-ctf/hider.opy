#!mainFile "../shared/settings.opy"

rule "Kill Hider in Spawn Room":
    @Event eachPlayer
    @Team 1
    @Condition getCurrentGamemode() == Gamemode.SKIRMISH or getCurrentGamemode() == Gamemode.CTF
    @Condition CurrentGameState == GAME_STATE.SEEKING
    @Condition eventPlayer.isInSpawnRoom()
    @Condition eventPlayer.JoinedLate == false

    do:
        eventPlayer.ResurrectBlocked = true
        kill(eventPlayer, null)
        wait()
    while RULE_CONDITION