#!mainFile "../shared/settings.opy"

rule "Kill Hider in Spawn Room":
    @Event eachPlayer
    @Team 1
    @Condition getCurrentGamemode() == Gamemode.SKIRMISH
    @Condition CurrentGameState == GAME_STATE.SEEKING
    @Condition eventPlayer.isInSpawnRoom()
    @Condition eventPlayer.JoinedLate == false

    do:
        kill(eventPlayer, null)
        wait()
    while RULE_CONDITION