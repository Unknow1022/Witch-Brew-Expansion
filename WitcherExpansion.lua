--[[
    Witch Brew Expansion
    Version: 2.0.6
    Author: Unknow102
    Framework: Steamodded (SMODS)

    "This mod is designed not to be unfair, but not to hand out free wins either;
    it is focused on long runs and fun Jokers to play.
    Reading is recommended, and if you don't like to read, well too bad XD!"

    New Features:
    - CardSleeves compatibility with custom sleeves & deck fusions
    - 10 high-difficulty Synergy Challenges
    - In-game Settings: New Runs seed variance, Job & Spectral toggles
    - Full JokerDisplay Suite integration
--]]

Witch_brew_MOD = SMODS.current_mod

local files = {
    -- Core & Engine Hooks
    "src/core/utils.lua",
    "src/core/localization.lua",

    -- Jokers
    "src/jokers/common.lua",
    "src/jokers/uncommon.lua",
    "src/jokers/rare.lua",
    "src/jokers/legendary.lua",
    "src/jokers/secret.lua",


    -- Consumables, Enhancements & Seals
    "src/consumables/spectrals.lua",
    "src/consumables/enhancements.lua",
    "src/consumables/jobs.lua",
    "src/consumables/potions.lua",

    -- Blinds, Decks, Vouchers & Tags
    "src/blinds/boss_blinds.lua",
    "src/decks/decks.lua",
    "src/vouchers/vouchers.lua",
    "src/tags/tags.lua",

    -- Mod Compatibility
    "src/compat/jokerdisplay.lua",
    "src/compat/cardsleeves.lua",

    -- Challenges
    "src/challenges/challenges.lua"
}

for _, file in ipairs(files) do
    assert(SMODS.load_file(file))()
end

if alias_all_witch_brew_centers then
    alias_all_witch_brew_centers()
end
                                                        