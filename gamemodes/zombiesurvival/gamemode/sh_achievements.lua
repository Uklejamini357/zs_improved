--local translate = translate.Get

GM.Achievements = {
    ["sigil_uncorruptor"] = {
        Name = "Sigil Uncorruptor I",
        Desc = "Uncorrupt 5 sigils.",
        Reward = 135,
        Goal = 5,
        Diff = 3
    },

    ["round_winner_1"] = {
        Name = "First win",
        Desc = "Win 1 round in normal mode",
        Reward = 475,
        Diff = 3
    },

    ["round_winner_2"] = {
        Name = "Round winner",
        Desc = "Win 5 rounds in normal mode",
        Reward = 700,
        Goal = 5,
        Diff = 4
    },

    ["round_winner_3"] = {
        Name = "Master of ZS",
        Desc = "Win 15 rounds in normal mode",
        Reward = 1000,
        Goal = 15,
        Diff = 5
    },

    ["zombie_killer_1"] = {
        Name = "Zombie killer",
        Desc = "Kill 75 zombies",
        Reward = 60,
        Goal = 75,
        Diff = 2
    },
    
    ["zombie_killer_2"] = {
        Name = "Zombie eliminator",
        Desc = "Kill 250 zombies",
        Reward = 175,
        Goal = 250,
        Diff = 3
    },
    
    ["zombie_killer_3"] = {
        Name = "Zombie annihilator",
        Desc = "Kill 650 zombies",
        Reward = 400,
        Goal = 650,
        Diff = 3
    },
    
    ["zombie_killer_4"] = {
        Name = "True Zombie annihilator",
        Desc = "Kill 2000 zombies",
        Reward = 850,
        Goal = 2000,
        Diff = 4
    },

    ["boss_slayer_1"] = {
        Name = "Boss slayer",
        Desc = "Kill 3 boss zombies.",
        Reward = 50,
        Goal = 3,
        Diff = 3
    },

    ["boss_slayer_2"] = {
        Name = "Boss hunter",
        Desc = "Kill 10 boss zombies.",
        Reward = 175,
        Goal = 10,
        Diff = 4
    },

    ["ze_win"] = {
        Name = "Escaped from Zombies",
        Desc = "Win 1 round in zombie escape mode",
        Reward = 175,
        Diff = 3
    },

    ["zs_obj_win"] = {
        Name = "Objective complete",
        Desc = "Win 1 round in objective map",
        Reward = 325,
        Diff = 4
    },

    ["classicmode_win"] = {
        Name = "Classic Survivor",
        Desc = "Win 1 round in classic mode",
        Reward = 370,
        Diff = 4
    },

    ["zmainer"] = {
        Name = "Zmainer",
        Desc = "Kill 15 humans as zombie!",
        Reward = 420,
        Goal = 15,
        Diff = 4
    },

    ["truezmainer"] = {
        Name = "True Zmainer",
        Desc = "Kill 100 humans as zombie",
        Reward = 3150,
        Goal = 100,
        Diff = 6
    },

    ["survivor_1"] = {
        Name = "Survivor I",
        Desc = "Survive 8 waves in endless mode",
        Reward = 1100,
        Diff = 6
    },

    ["survivor_2"] = {
        Name = "Survivor II",
        Desc = "Survive 11 waves in endless mode",
        Reward = 1950,
        Diff = 7
    },

    ["survivor_3"] = {
        Name = "Survivor III",
        Desc = "Survive 14 waves in endless mode",
        Reward = 3125,
        Diff = 8
    },

    ["difficult_survival"] = {
        Name = "Difficult Survival",
        Desc = "Win 5 rounds with 25%+ additional difficulty",
        Reward = 2250,
        Goal = 5,
        Diff = 7
    },

    ["hardmode"] = {
        Name = "Hard mode!",
        Desc = "Win 6 rounds with 50%+ additional difficulty",
        Reward = 5950,
        Goal = 6,
        Diff = 8
    },

    ["tormented_victory"] = {
        Name = "Torment",
        Desc = "Win 3 rounds with Torment I-X skills and no Anti-Torment skills active",
        Reward = 2950,
        Goal = 3,
        Diff = 8
    },

    ["true_victory"] = {
        Name = "Endless Torment",
        Desc = "Win 2 rounds with all Torment skills and no Anti-Torment skills active",
        Reward = 8550,
        Goal = 2,
        Diff = 9
    },

    ["pointfarmer_1"] = {
        Name = "Pointfarmer I",
        Desc = "Gain 5000 points in total",
        Reward = 350,
        Goal = 5000,
        Diff = 4
    },

    ["pointfarmer_2"] = {
        Name = "Pointfarmer II",
        Desc = "Gain 15000 points in total",
        Reward = 600,
        Goal = 15000,
        Diff = 5
    },

    ["pointfarmer_3"] = {
        Name = "Pointfarmer III",
        Desc = "Gain 50000 points in total",
        Reward = 1285,
        Goal = 50000,
        Diff = 6
    },

    ["repair_man_1"] = {
        Name = "Repairman I",
        Desc = "Repair 15000 barricade points in total.",
        Reward = 485,
        Goal = 15000,
        Diff = 4
    },

    ["repair_man_2"] = {
        Name = "Repairman II",
        Desc = "Repair 100,000 barricade points in total",
        Reward = 1675,
        Goal = 100000,
        Diff = 5
    },

}

-- As to not call the table.Count function again
GM.AchievementsCount = table.Count(GM.Achievements)
