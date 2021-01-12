#!mainFile "../shared/settings.opy"

rule "Kill Hider":
    @Event playerJoined
    @Team 1
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition CurrentGameState == GAME_STATE.SEEKING

    waitUntil(eventPlayer.JoinedLate == true, 9999)
    waitUntil(eventPlayer.JoinedLate == false, 9999)
    kill(eventPlayer, null)