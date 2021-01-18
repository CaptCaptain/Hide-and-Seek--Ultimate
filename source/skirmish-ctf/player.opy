#!mainFile "../shared/settings.opy"

rule "Title Hud":
    @Condition getCurrentGamemode() == Gamemode.SKIRMISH
    
    createInWorldText(getAllPlayers(), STR_GAME_TITLE, getObjectivePosition(getCurrentObjective()) + vect(0, 4, 0),5, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.BLUE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createInWorldText(getAllPlayers(), STR_GAME_SUBTITLE, getObjectivePosition(getCurrentObjective()) + vect(0, 3.5, 0),2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.SKY_BLUE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createInWorldText(getAllPlayers(), "{}: {}".format(STR_GAME_STYLE, StyleString), getObjectivePosition(getCurrentObjective()) + vect(0, 3, 0),1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.ROSE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createInWorldText(getAllPlayers(), STR_GAME_WAITING_FOR_PLAYERS, getObjectivePosition(getCurrentObjective()) + vect(0, 2.25, 0),1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createEffect(getAllPlayers(), Effect.RING, Color.TURQUOISE, getObjectivePosition(getCurrentObjective()), 10, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    Hud_GameTitle.append(getLastCreatedEntity())

    waitUntil(CurrentGameState != GAME_STATE.WAITING, 9999)

    for globalHudIndex in range(0, len(Hud_GameTitle)):
        destroyInWorldText(Hud_GameTitle[globalHudIndex])
        destroyEffect(Hud_GameTitle[globalHudIndex])
    Hud_GameTitle = null

rule "Player Setup":
    @Event eachPlayer
    @Condition getCurrentGamemode() == Gamemode.SKIRMISH or getCurrentGamemode() == Gamemode.CTF

    # Teleport to Objective
    waitUntil(eventPlayer.hasSpawned(), 9999)
    eventPlayer.DvaMechPosition = eventPlayer.getPosition()
    RestrictAbilities()
    if getCurrentGamemode() == Gamemode.CTF:
        eventPlayer.disableGamemodeInWorldUi()
        return
    if CurrentGameState == GAME_STATE.WAITING:
        eventPlayer.teleport(nearestWalkablePosition(getObjectivePosition(getCurrentObjective()) + vect(random.randint(-10, 10), 0, random.randint(-10, 10))))
        wait()
        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), getObjectivePosition(getCurrentObjective())) + vect(0, 0.5, 0), Relativity.TO_WORLD)

rule "Disable Abilities In Spawn":
    @Event eachPlayer
    @Condition getCurrentGamemode() == Gamemode.SKIRMISH or getCurrentGamemode() == Gamemode.CTF
    @Condition eventPlayer.isInSpawnRoom()

    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.cancelPrimaryAction()

    waitUntil(not eventPlayer.isInSpawnRoom(), 9999)

    RestrictAbilities()

rule "Prevent Flag Capture":
    @Event eachPlayer
    @Condition getCurrentGamemode() == Gamemode.CTF
    @Condition distance(eventPlayer.getPosition(), [getFlagPosition(Team.2), getFlagPosition(Team.1)][[Team.1, Team.2].index(eventPlayer.getTeam())]) < 3

    eventPlayer.applyImpulse(directionTowards([getFlagPosition(Team.2), getFlagPosition(Team.1)][[Team.1, Team.2].index(eventPlayer.getTeam())], eventPlayer.getPosition()), 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait()
    if RULE_CONDITION: goto RULE_START

# Accessibility Rules
rule "D.va: TP to Mech Position (Hider)":
    @Event eachPlayer
    @Team 1
    @Hero dva
    @Condition getCurrentGamemode() == Gamemode.SKIRMISH or getCurrentGamemode() == Gamemode.CTF
    @Condition CurrentGameState == GAME_STATE.HIDING
    @Condition eventPlayer.DvaHasTeleported == false

    eventPlayer.DvaHasTeleported = true
    
    eventPlayer.teleport(eventPlayer.DvaMechPosition)

rule "D.va: TP to Mech Position (Seeker)":
    @Event eachPlayer
    @Team 2
    @Hero dva
    @Condition getCurrentGamemode() == Gamemode.SKIRMISH or getCurrentGamemode() == Gamemode.CTF
    @Condition CurrentGameState == GAME_STATE.HIDING
    @Condition not eventPlayer.isInSpawnRoom()
    
    wait(0.25, Wait.ABORT_WHEN_FALSE)
    eventPlayer.teleport(eventPlayer.DvaMechPosition)