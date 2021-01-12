#!mainFile "../shared/settings.opy"

rule "Player Setup":
    @Event eachPlayer
    @Condition getCurrentGamemode() == Gamemode.TDM
    
    waitUntil(eventPlayer.hasSpawned(), 9999)
    RestrictAbilities()