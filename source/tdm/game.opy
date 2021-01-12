#!mainFile "../shared/settings.opy"

rule "Skip Assembling Heroes":
    @Condition isAssemblingHeroes()

    setMatchTime(0)
    unpauseMatchTime()
    pauseMatchTime()