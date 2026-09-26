-- Battle of Gods Game Mode (Post-Ante 8)
-- Enabled via config and requires Amulet mod

local function has_amulet_mod()
    if SMODS and SMODS.Mods then
        for k, v in pairs(SMODS.Mods) do
            local key_str = string.lower(tostring(k))
            local id_str = v.id and string.lower(tostring(v.id)) or ''
            local name_str = v.name and string.lower(tostring(v.name)) or ''
            if key_str == 'amulet' or id_str == 'amulet' or name_str == 'amulet' then
                return true
            end
        end
    end
    return false
end

function apply_battle_of_gods_bg()
    G.C.BOTG_BLACK = G.C.BOTG_BLACK or HEX('080808')
    G.C.BOTG_WHITE = G.C.BOTG_WHITE or HEX('f2f2f2')
    if G.SPLASH_BACK then
        G.SPLASH_BACK:define_draw_steps({{
            shader = 'splash',
            send = {
                {name = 'time', ref_table = G.TIMERS, ref_value = 'REAL_SHADER'},
                {name = 'vort_speed', val = 0.4},
                {name = 'colour_1', ref_table = G.C, ref_value = 'BOTG_BLACK'},
                {name = 'colour_2', ref_table = G.C, ref_value = 'BOTG_WHITE'},
                {name = 'mid_flash', ref_table = {mid_flash = 0}, ref_value = 'mid_flash'},
                {name = 'vort_offset', val = 0},
            }
        }})
    end
    if ease_background_colour then
        ease_background_colour{
            new_colour = G.C.BOTG_BLACK,
            special_colour = G.C.BOTG_WHITE,
            contrast = 3.5
        }
    end
end

if ease_background_colour_blind then
    local orig_ease_bg = ease_background_colour_blind
    function ease_background_colour_blind(state, blind_override)
        if G.GAME and G.GAME.battle_of_gods then
            apply_battle_of_gods_bg()
            return
        end
        return orig_ease_bg(state, blind_override)
    end
end

-- Colosseum, Olympic & Mod Mechanics Achievements
local botg_basic_achievements = {
    { key = 'apprentice_alchemist', name = 'Apprentice Alchemist', desc = 'Drink or use any Witcher Brew Potion.' },
    { key = 'witcher_amalgam', name = 'Master Brewer', desc = 'Synthesize or use an Amalgam Potion.' },
    { key = 'mutagenic_trial', name = 'Trial of the Grasses', desc = 'Use any Witcher Brew Spectral card.' },
    { key = 'first_contract', name = 'Witcher on the Path', desc = 'Accept or complete a Witcher Guild Job.' },
    { key = 'divine_familiar', name = 'Faithful Companion', desc = 'Summon or bond with a Familiar in the Colosseum.' },
    { key = 'royal_connoisseur', name = 'Royal Connoisseur', desc = 'Redeem the Taster or Critic voucher.' },
    { key = 'forbidden_craft', name = 'Esoteric Secrets', desc = 'Obtain or score with a Secret Joker.' },
    { key = 'herb_forager', name = 'Herbalist Satchel', desc = 'Open a Witcher Brew Booster Pack.' },
    { key = 'god_slayer', name = 'Colosseum Gladiator', desc = 'Defeat any Boss Blind in the Colosseum.' },
    { key = 'glitch_in_the_aegis', name = 'Temporal Anomaly', desc = 'Create or score with a Glitched Card.' },
}

if SMODS and SMODS.Achievement then
    SMODS.Achievement {
        key = 'campeon_del_coliseo',
        loc_txt = {
            name = 'Colosseum Champion',
            description = 'Reach Ante 24 in Battle of Gods mode.',
        },
        unlock_condition = function(self, args)
            return args.type == 'botg_ante_24' or args.type == 'campeon_del_coliseo' or args.type == 'ach_Witch_brew_campeon_del_coliseo'
        end
    }

    SMODS.Achievement {
        key = 'dios_olimpico',
        loc_txt = {
            name = 'Olympic God',
            description = 'Earn a Gold Sticker on all mod Jokers.',
        },
        unlock_condition = function(self, args)
            return args.type == 'dios_olimpico' or (check_olympic_god_status and check_olympic_god_status())
        end
    }

    SMODS.Achievement {
        key = 'dios_olimpico_plus_plus',
        loc_txt = {
            name = 'Olympic God++',
            description = 'Win on Gold Stake with all mod Decks and complete Battle of Gods on Gold Stake.',
        },
        unlock_condition = function(self, args)
            return args.type == 'dios_olimpico_plus_plus' or (check_olympic_god_plus_plus_status and check_olympic_god_plus_plus_status())
        end
    }

    for _, ach in ipairs(botg_basic_achievements) do
        SMODS.Achievement {
            key = ach.key,
            loc_txt = {
                name = ach.name,
                description = ach.desc,
            },
            unlock_condition = function(self, args)
                return args.type == ach.key or args.type == ('ach_Witch_brew_' .. ach.key)
            end
        }
    end
end

function register_achievement_loc(key, name, desc)
    local full_key = 'ach_Witch_brew_' .. key
    G.ACHIEVEMENTS = G.ACHIEVEMENTS or {}
    G.SETTINGS.ACHIEVEMENTS_EARNED = G.SETTINGS.ACHIEVEMENTS_EARNED or {}

    if G.localization and G.localization.misc then
        G.localization.misc.achievement_names = G.localization.misc.achievement_names or {}
        G.localization.misc.achievement_descriptions = G.localization.misc.achievement_descriptions or {}
        G.localization.misc.achievement_names[key] = name
        G.localization.misc.achievement_descriptions[key] = desc
        G.localization.misc.achievement_names[full_key] = name
        G.localization.misc.achievement_descriptions[full_key] = desc
    end

    if not G.ACHIEVEMENTS[key] then
        G.ACHIEVEMENTS[key] = { name = name, earned = true, steamid = "STEAMODDED_" .. string.upper(key) }
    end
    if not G.ACHIEVEMENTS[full_key] then
        G.ACHIEVEMENTS[full_key] = { name = name, earned = true, steamid = "STEAMODDED_" .. string.upper(key) }
    end
end

for _, ach in ipairs(botg_basic_achievements) do
    register_achievement_loc(ach.key, ach.name, ach.desc)
end

function botg_trigger_mod_achievement(key)
    local full_key = 'ach_Witch_brew_' .. key
    if check_for_unlock then
        pcall(function() check_for_unlock({ type = key }) end)
        pcall(function() check_for_unlock({ type = full_key }) end)
    end
    if unlock_achievement then
        pcall(function() unlock_achievement(key) end)
        pcall(function() unlock_achievement(full_key) end)
    else
        G.SETTINGS.ACHIEVEMENTS_EARNED = G.SETTINGS.ACHIEVEMENTS_EARNED or {}
        G.SETTINGS.ACHIEVEMENTS_EARNED[key] = true
        G.SETTINGS.ACHIEVEMENTS_EARNED[full_key] = true
        if notify_alert then pcall(function() notify_alert(key) end) end
    end
end

local function unlock_colosseum_champion()
    register_achievement_loc('campeon_del_coliseo', 'Colosseum Champion', 'Reach Ante 24 in Battle of Gods mode.')
    botg_trigger_mod_achievement('campeon_del_coliseo')
end

function check_olympic_god_status()
    local profile = G.PROFILES and G.PROFILES[G.SETTINGS.profile]
    if not profile or not profile.joker_usage then return false end
    local total_mod_jokers = 0
    local gold_jokers = 0

    for k, v in pairs(G.P_CENTERS) do
        if v.set == 'Joker' and not v.omit then
            local is_mod_joker = (v.mod and (v.mod.id == 'Witch_brew' or v.mod.id == 'witch_brew'))
                or string.find(k, 'Witch_brew') or string.find(k, 'witch_brew')
            if is_mod_joker then
                total_mod_jokers = total_mod_jokers + 1
                local win_stake = get_joker_win_sticker and get_joker_win_sticker(v, true) or 0
                if win_stake >= 8 then
                    gold_jokers = gold_jokers + 1
                end
            end
        end
    end
    return total_mod_jokers > 0 and gold_jokers >= total_mod_jokers
end

function check_olympic_god_plus_plus_status()
    local profile = G.PROFILES and G.PROFILES[G.SETTINGS.profile]
    if not profile or not profile.deck_usage then return false end
    if not profile.botg_gold_stake_win then return false end

    local total_decks = 0
    local gold_decks = 0
    for k, v in pairs(G.P_CENTERS) do
        if v.set == 'Back' and not v.omit then
            local is_mod_deck = (v.mod and (v.mod.id == 'Witch_brew' or v.mod.id == 'witch_brew'))
                or string.find(k, 'Witch_brew') or string.find(k, 'witch_brew')
            if is_mod_deck then
                total_decks = total_decks + 1
                local stake_win = get_deck_win_stake and get_deck_win_stake(v.key) or 0
                if stake_win >= 8 then
                    gold_decks = gold_decks + 1
                end
            end
        end
    end
    return total_decks > 0 and gold_decks >= total_decks
end

function check_and_unlock_olympic_achievements()
    if check_olympic_god_status() then
        register_achievement_loc('dios_olimpico', 'Olympic God', 'Earn a Gold Sticker on all mod Jokers.')
        trigger_achievement_unlock('dios_olimpico')
    end
    if check_olympic_god_plus_plus_status() then
        register_achievement_loc('dios_olimpico_plus_plus', 'Olympic God++', 'Win on Gold Stake with all mod Decks and complete Battle of Gods on Gold Stake.')
        trigger_achievement_unlock('dios_olimpico_plus_plus')
    end
end

if set_joker_win then
    local orig_set_joker_win = set_joker_win
    function set_joker_win()
        orig_set_joker_win()
        pcall(check_and_unlock_olympic_achievements)
    end
end

if set_deck_win then
    local orig_set_deck_win = set_deck_win
    function set_deck_win()
        orig_set_deck_win()
        pcall(check_and_unlock_olympic_achievements)
    end
end

-- Exclusive Pantheon Booster Pack (Mechanic 5)
SMODS.Booster {
    key = 'pantheon_pack',
    atlas = 'c_packs',
    pos = { x = 0, y = 1 },
    config = { extra = 3, choose = 1 },
    cost = 25,
    weight = 0.45,
    draw_hand = false,
    loc_txt = {
        name = 'Pantheon Pack',
        text = {
            'Choose {C:attention}#1#{} of up to',
            '{C:attention}#2#{} {C:spectral}Mythic Jokers{}',
            '{C:inactive}(Secret or Legendary){}'
        }
    },
    loc_vars = function(self, info_queue, card)
        local choose = (card and card.ability and card.ability.choose) or (self.config and self.config.choose) or 1
        local extra = (card and card.ability and card.ability.extra) or (self.config and self.config.extra) or 3
        return { vars = { choose, extra } }
    end,
    create_card = function(self, card, i)
        local roll = pseudorandom('pantheon_pack_roll_' .. (card.ID or '') .. i)
        if roll < 0.5 then
            return create_card('Joker', G.pack_cards, true, nil, nil, nil, nil, 'pantheon_leg')
        else
            local secret_keys = {}
            for k, v in pairs(G.P_CENTERS) do
                if v.set == 'Joker' and (v.is_secret or v.rarity == 'Secret' or (is_secret_card and is_secret_card({config = {center = v}}))) then
                    secret_keys[#secret_keys + 1] = k
                end
            end
            local key = pseudorandom_element(secret_keys, pseudoseed('pantheon_sec_' .. (card.ID or '') .. i))
            return create_card('Joker', G.pack_cards, nil, nil, nil, nil, key, 'pantheon_sec')
        end
    end,
    in_pool = function(self, args)
        return G.GAME and G.GAME.battle_of_gods == true
    end
}

function get_new_boss_filtered(showdown)
    local eligible_bosses = {}
    for k, v in pairs(G.P_BLINDS) do
        if v.boss then
            if showdown and v.boss.showdown then
                eligible_bosses[k] = true
            elseif not showdown and not v.boss.showdown then
                eligible_bosses[k] = true
            end
        end
    end
    for k, _ in pairs(G.GAME.banned_keys or {}) do
        if eligible_bosses[k] then eligible_bosses[k] = nil end
    end
    local min_use = 100
    G.GAME.bosses_used = G.GAME.bosses_used or {}
    for k, _ in pairs(eligible_bosses) do
        local use_count = G.GAME.bosses_used[k] or 0
        if use_count <= min_use then 
            min_use = use_count
        end
    end
    for k, _ in pairs(eligible_bosses) do
        local use_count = G.GAME.bosses_used[k] or 0
        if use_count > min_use then 
            eligible_bosses[k] = nil
        end
    end
    local keys_list = {}
    for k, _ in pairs(eligible_bosses) do
        keys_list[#keys_list + 1] = k
    end
    if #keys_list == 0 then
        local fallback = showdown and 'bl_cerulean_bell' or 'bl_hook'
        G.GAME.bosses_used[fallback] = (G.GAME.bosses_used[fallback] or 0) + 1
        return fallback
    end
    local choice, _ = pseudorandom_element(keys_list, pseudoseed(showdown and 'botg_showdown' or 'botg_boss'))
    local boss = (type(choice) == 'string' and choice) or keys_list[1] or (showdown and 'bl_cerulean_bell' or 'bl_hook')
    G.GAME.bosses_used[boss] = (G.GAME.bosses_used[boss] or 0) + 1
    return boss
end

local FUSED_BOSS_KEYS = {
    'bl_Witch_brew_obelisk',
    'bl_Witch_brew_minotaur',
    'bl_Witch_brew_fortress',
    'bl_Witch_brew_mind_flayer',
    'bl_Witch_brew_leviathan',
    'bl_Witch_brew_iron_maiden',
    'bl_Witch_brew_cyclops',
    'bl_Witch_brew_thorn_crown',
    'bl_Witch_brew_ouroboros',
    'bl_Witch_brew_nightshade',
    'bl_Witch_brew_black_diamond',
    'bl_Witch_brew_blood_moon'
}

function get_new_fused_boss()
    local eligible = {}
    for _, k in ipairs(FUSED_BOSS_KEYS) do
        if G.P_BLINDS and G.P_BLINDS[k] then eligible[#eligible + 1] = k end
    end
    if #eligible == 0 then return get_new_boss_filtered(false) end
    local choice, _ = pseudorandom_element(eligible, pseudoseed('botg_fused_boss'))
    local boss = (type(choice) == 'string' and choice) or eligible[1]
    return (G.P_BLINDS and G.P_BLINDS[boss] and boss) or eligible[1] or get_new_boss_filtered(false)
end

function get_botg_godly_hubris_multiplier()
    if not (G.GAME and G.GAME.battle_of_gods) then return 1, 0 end
    local god_count = 0
    if G.jokers and G.jokers.cards then
        for _, j in ipairs(G.jokers.cards) do
            local is_leg = j.config and j.config.center and (j.config.center.rarity == 4 or j.config.center.rarity == 'Legendary' or j.config.center.legendary)
            local is_sec = (is_secret_card and is_secret_card(j)) or (j.config and j.config.center and (j.config.center.is_secret or j.config.center.rarity == 'Secret'))
            if is_leg or is_sec then
                god_count = god_count + 1
            end
        end
    end
    return 1 + (god_count * 0.5), god_count
end

-- Sanitizer hook for create_UIBox_blind_choice to prevent nil config crashes
if create_UIBox_blind_choice then
    local orig_create_UIBox_blind_choice = create_UIBox_blind_choice
    function create_UIBox_blind_choice(type, run_info)
        if G.GAME and G.GAME.round_resets and G.GAME.round_resets.blind_choices then
            local current_blind = G.GAME.round_resets.blind_choices[type]
            if not current_blind or not (G.P_BLINDS and G.P_BLINDS[current_blind]) then
                if G.GAME.battle_of_gods then
                    if type == 'Boss' then
                        G.GAME.round_resets.blind_choices[type] = get_new_boss_filtered(true)
                    elseif G.GAME.round_resets.ante and G.GAME.round_resets.ante >= 12 then
                        G.GAME.round_resets.blind_choices[type] = get_new_fused_boss()
                    else
                        G.GAME.round_resets.blind_choices[type] = get_new_boss_filtered(false)
                    end
                else
                    if type == 'Small' then
                        G.GAME.round_resets.blind_choices[type] = 'bl_small'
                    elseif type == 'Big' then
                        G.GAME.round_resets.blind_choices[type] = 'bl_big'
                    else
                        G.GAME.round_resets.blind_choices[type] = (get_new_boss and get_new_boss()) or 'bl_hook'
                    end
                end
            end
        end
        if type == 'Boss' and G.GAME and G.GAME.battle_of_gods then
            G.GAME.botg_hubris_in_blind_choice = true
        end
        local ret = orig_create_UIBox_blind_choice(type, run_info)
        if G.GAME then G.GAME.botg_hubris_in_blind_choice = nil end
        return ret
    end
end

if reset_blinds then
    local orig_reset_blinds = reset_blinds
    function reset_blinds()
        orig_reset_blinds()
        if G.GAME and G.GAME.battle_of_gods then
            if G.GAME.round_resets and G.GAME.round_resets.ante and G.GAME.round_resets.ante >= 24 then
                unlock_colosseum_champion()
            end
            G.GAME.round_resets.divine_ward_free = true -- Mechanic 24: Divine Ward free reroll
            if init_botg_familiars_area then init_botg_familiars_area() end
            if G.GAME.round_resets and G.GAME.round_resets.blind_choices then
                -- Mechanic 3: 12 Dedicated Fused Boss Blinds (Ante 12+)
                if G.GAME.round_resets.ante >= 12 then
                    local f1 = get_new_fused_boss()
                    local f2 = get_new_fused_boss()
                    local attempts = 0
                    while f2 == f1 and attempts < 10 do
                        f2 = get_new_fused_boss()
                        attempts = attempts + 1
                    end
                    G.GAME.round_resets.blind_choices.Small = f1
                    G.GAME.round_resets.blind_choices.Big = f2
                else
                    G.GAME.round_resets.blind_choices.Small = get_new_boss_filtered(false)
                    G.GAME.round_resets.blind_choices.Big = get_new_boss_filtered(false)
                end
                G.GAME.round_resets.blind_choices.Boss = get_new_boss_filtered(true)
            end
        end
    end
end

-- Mechanic 24: Divine Ward free reroll hook
if G.FUNCS and G.FUNCS.reroll_boss then
    local orig_reroll_boss = G.FUNCS.reroll_boss
    G.FUNCS.reroll_boss = function(e)
        if G.GAME and G.GAME.battle_of_gods and G.GAME.round_resets.divine_ward_free then
            local current_dollars = G.GAME.dollars
            orig_reroll_boss(e)
            G.GAME.dollars = current_dollars
            G.GAME.round_resets.divine_ward_free = false
            attention_text({ text = 'Divine Ward: Free Reroll!', scale = 0.7, hold = 1.2, backdrop_colour = G.C.GOLD, align = 'cm', offset = {x = 0, y = -1} })
            return
        end
        orig_reroll_boss(e)
    end
end


if get_new_boss then
    local orig_get_new_boss = get_new_boss
    function get_new_boss()
        if G.GAME and G.GAME.battle_of_gods then
            return get_new_boss_filtered(true)
        end
        return orig_get_new_boss()
    end
end

if Blind and Blind.get_type then
    local orig_blind_get_type = Blind.get_type
    function Blind:get_type()
        if G.GAME and G.GAME.battle_of_gods and G.GAME.blind_on_deck then
            return G.GAME.blind_on_deck
        end
        return orig_blind_get_type(self)
    end
end



if Blind and Blind.defeat then
    local orig_blind_defeat = Blind.defeat
    function Blind:defeat(silent)
        if G.GAME and G.GAME.battle_of_gods then
            -- Mechanic 25: Track bosses slain
            G.GAME.botg_bosses_slain = (G.GAME.botg_bosses_slain or 0) + 1

            -- Mechanic 4: Overkill to Divine Grace
            if G.GAME.chips and self.chips and G.GAME.chips > self.chips then
                local excess = G.GAME.chips - self.chips
                local grace_earned = math.min(10, math.max(1, math.floor((excess / self.chips) * 5)))
                G.GAME.divine_grace = (G.GAME.divine_grace or 0) + grace_earned
                attention_text({
                    text = '+' .. tostring(grace_earned) .. ' Divine Grace',
                    scale = 0.7, hold = 1.3, backdrop_colour = G.C.GOLD,
                    align = 'cm', offset = {x = 0, y = -1.2}
                })
            end

            -- Mechanic 15: Thanatos Hourglass (Perishable & Rental Cleansing on Showdown)
            if G.GAME.blind_on_deck == 'Boss' and G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    local cleansed = false
                    if j.ability and j.ability.perishable then
                        j.ability.perish_tally = G.GAME.perishable_rounds or 5
                        j.debuff = false
                        cleansed = true
                    end
                    if j.ability and j.ability.rental then
                        j.ability.rental = nil
                        j.rental = nil
                        cleansed = true
                    end
                    if cleansed then
                        card_eval_status_text(j, 'extra', nil, nil, nil, { message = 'Thanatos Cleansed!', colour = G.C.GOLD })
                    end
                end
            end

            -- Idea 19: Mini-Boss Familiar drop chance (40%)
            if botg_offer_familiar and pseudorandom('botg_fam_drop') < 0.40 then
                botg_offer_familiar()
            end

            -- Boss Possession drop chance (30%)
            if possess_joker and pseudorandom('botg_possession_drop') < 0.30 and G.jokers and G.jokers.cards then
                local unpossessed = {}
                for _, j in ipairs(G.jokers.cards) do
                    if not (j.ability and j.ability.possessed) then unpossessed[#unpossessed + 1] = j end
                end
                if #unpossessed > 0 then
                    local target_joker = pseudorandom_element(unpossessed, pseudoseed('botg_possess_target'))
                    possess_joker(target_joker, self.config and self.config.blind and self.config.blind.key)
                end
            end

            -- Mechanic 19: Apotheosis check at Ante 20+
            if G.GAME.round_resets and G.GAME.round_resets.ante >= 20 and not G.GAME.apotheosis_done then
                if G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
                    local target = G.jokers.cards[1]
                    target.ability.deity_ascended = true
                    target:set_edition({ polychrome = true }, true)
                    target.debuff = false
                    G.GAME.apotheosis_done = true
                    attention_text({
                        text = 'APOTHEOSIS! Ascended to Deity',
                        scale = 0.85, hold = 2.0, backdrop_colour = G.C.PURPLE,
                        align = 'cm', offset = {x = 0, y = -1.5}
                    })
                end
            end

            if G.GAME.blind_on_deck == 'Small' then
                G.GAME.round_resets.blind = G.P_BLINDS.bl_small
            elseif G.GAME.blind_on_deck == 'Big' then
                G.GAME.round_resets.blind = G.P_BLINDS.bl_big
            end
        end
        return orig_blind_defeat(self, silent)
    end
end

-- Mechanic 19 & 23: Scoring hooks for Apotheosis & Hand Level Transcendence
local orig_calculate_joker = Card.calculate_joker
function Card:calculate_joker(context, ...)
    if G.GAME and G.GAME.battle_of_gods then
        -- Mechanic 19: Deity Ascended Joker protection & X2 Mult
        if self.ability and self.ability.deity_ascended then
            self.debuff = false
            if context and context.cardarea == G.jokers and context.joker_main then
                return {
                    message = 'Apotheosis! X2',
                    Xmult_mod = 2,
                    colour = G.C.PURPLE
                }
            end
        end

        -- Mechanic 23: Hand Level Transcendence (Level > 20 grants X1.25 Exalted Mult)
        if context and context.cardarea == G.jokers and context.joker_main and G.jokers and G.jokers.cards and self == G.jokers.cards[1] then
            local p_hand = context.scoring_name
            if p_hand and G.GAME.hands and G.GAME.hands[p_hand] and G.GAME.hands[p_hand].level > 20 then
                return {
                    message = 'Exalted! X1.25',
                    Xmult_mod = 1.25,
                    colour = G.C.GOLD
                }
            end
        end
    end
    return orig_calculate_joker(self, context, ...)
end

local botg_ante_bases = {
    25000,       -- Ante 1: 25k (Boss 50k)
    100000,      -- Ante 2: 100k (Boss 200k)
    500000,      -- Ante 3: 500k (Boss 1M)
    3000000,     -- Ante 4: 3M (Boss 6M)
    25000000,    -- Ante 5: 25M (Boss 50M)
    250000000,   -- Ante 6: 250M (Boss 500M)
    3500000000,  -- Ante 7: 3.5B (Boss 7B)
    60000000000, -- Ante 8: 60B (Boss 120B)
}

local function make_botg_big_amount(mantissa, exponent)
    if to_big then
        local str = string.format("%.4fe%d", mantissa, exponent)
        local ok, val = pcall(function() return to_big(str) end)
        if ok and val then return val end
        local ok2, val2 = pcall(function() return to_big(mantissa) * (to_big(10) ^ to_big(exponent)) end)
        if ok2 and val2 then return val2 end
    end
    if exponent < 308 then
        return math.floor(mantissa * (10 ^ exponent))
    end
    return 1e300
end

local function get_botg_base_blind(ante)
    local a = math.max(1, ante)
    if a <= 8 then
        return botg_ante_bases[a]
    end
    if a >= 24 then
        -- Final showdown Boss has mult 2, so base of 0.5e365 yields exactly 1e365 for the final blind
        return make_botg_big_amount(5.0, 364)
    end
    -- Rapid exponential curve in log-space from Ante 8 (log10 ~ 10.778) to Ante 24 (log10 ~ 364.699)
    local t = (a - 8) / 16
    local log_val = 10.77815 + 353.92082 * (t ^ 1.35)
    local exponent = math.floor(log_val)
    local mantissa = 10 ^ (log_val - exponent)
    return make_botg_big_amount(mantissa, exponent)
end

if get_blind_amount then
    local orig_get_blind_amount = get_blind_amount
    function get_blind_amount(ante)
        if G.GAME and G.GAME.battle_of_gods then
            local base = get_botg_base_blind(ante)
            if G.GAME.botg_hubris_in_blind_choice then
                local mult = get_botg_godly_hubris_multiplier()
                local scaled = base * mult
                if to_big then
                    local cap = to_big('1e365')
                    local ok, is_gt = pcall(function() return to_big(scaled) > cap end)
                    if ok and is_gt then scaled = cap end
                end
                return scaled
            end
            return base
        end
        return orig_get_blind_amount(ante)
    end
end

if Blind and Blind.set_blind then
    local orig_blind_set_blind = Blind.set_blind
    function Blind:set_blind(blind, reset, silent)
        local ret = orig_blind_set_blind(self, blind, reset, silent)
        if G.GAME and G.GAME.battle_of_gods and self.boss and not self.disabled then
            local mult, count = get_botg_godly_hubris_multiplier()
            if count > 0 then
                self.chips = math.floor(self.chips * mult)
            end
            if to_big then
                local cap = to_big('1e365')
                local ok, is_gt = pcall(function() return to_big(self.chips) > cap end)
                if ok and is_gt then self.chips = cap end
            end
            self.chip_text = number_format(self.chips)
            if not silent and count > 0 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        attention_text({
                            text = 'Godly Hubris: Boss Chips X' .. string.format('%.1f', mult) .. ' (' .. count .. ' Divine Joker' .. (count > 1 and 's' or '') .. ')',
                            scale = 0.55,
                            hold = 2.2,
                            backdrop_colour = G.C.RED,
                            align = 'cm',
                            offset = { x = 0, y = -1 }
                        })
                        play_sound('cancel', 0.9, 0.7)
                        return true
                    end
                }))
            end
        end
        return ret
    end
end

local function get_botg_regular_boss(seed_suffix)
    local eligible = {}
    for k, v in pairs(G.P_BLINDS) do
        if v.boss and not v.boss.showdown and k ~= 'bl_wall' and k ~= 'bl_vessel' then
            eligible[k] = true
        end
    end
    if G.GAME and G.GAME.banned_keys then
        for k, _ in pairs(G.GAME.banned_keys) do
            eligible[k] = nil
        end
    end
    local _, boss = pseudorandom_element(eligible, pseudoseed('botg_s1_boss' .. (seed_suffix or 1)))
    return boss or 'bl_hook'
end

local function get_botg_showdown_boss(seed_suffix, exclude_key)
    local eligible = {}
    for k, v in pairs(G.P_BLINDS) do
        if v.boss and v.boss.showdown and k ~= exclude_key then
            eligible[k] = true
        end
    end
    if G.GAME and G.GAME.banned_keys then
        for k, _ in pairs(G.GAME.banned_keys) do
            eligible[k] = nil
        end
    end
    local _, boss = pseudorandom_element(eligible, pseudoseed('botg_showdown' .. (seed_suffix or 1)))
    return boss or 'bl_vessel'
end

local function roll_botg_blinds(seed_suffix)
    seed_suffix = seed_suffix or (G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 1
    
    -- Slot 1: Big Blind, can be replaced by a Boss Blind (50% chance)
    local slot1 = 'bl_big'
    if pseudorandom('botg_s1_roll' .. seed_suffix) < 0.5 then
        slot1 = get_botg_regular_boss(seed_suffix)
    end
    
    -- Slot 2: The Wall, can be replaced by Violet Vessel (Showdown) (50% chance)
    local slot2 = 'bl_wall'
    if pseudorandom('botg_s2_roll' .. seed_suffix) < 0.5 then
        slot2 = 'bl_vessel'
    end
    
    -- Slot 3: Showdown Boss Blind
    local slot3 = get_botg_showdown_boss(seed_suffix, slot2 == 'bl_vessel' and 'bl_vessel' or nil)

    return {
        Small = slot1,
        Big = slot2,
        Boss = slot3
    }
end

if get_new_boss then
    local orig_get_new_boss = get_new_boss
    function get_new_boss()
        if G.GAME and G.GAME.battle_of_gods then
            return get_botg_showdown_boss(G.GAME.round_resets and G.GAME.round_resets.ante or 1)
        end
        return orig_get_new_boss()
    end
end

if reset_blinds then
    local orig_reset_blinds = reset_blinds
    function reset_blinds()
        local was_boss_defeated = G.GAME and G.GAME.round_resets and G.GAME.round_resets.blind_states and G.GAME.round_resets.blind_states.Boss == 'Defeated'
        orig_reset_blinds()
        if G.GAME and G.GAME.battle_of_gods and G.GAME.round_resets and G.GAME.round_resets.blind_choices then
            if was_boss_defeated then
                if botg_trigger_mod_achievement then
                    botg_trigger_mod_achievement('god_slayer')
                end
                local b = roll_botg_blinds()
                G.GAME.round_resets.blind_choices.Small = b.Small
                G.GAME.round_resets.blind_choices.Big = b.Big
                G.GAME.round_resets.blind_choices.Boss = b.Boss
            end
        end
    end
end

local orig_create_card = create_card
function create_card(type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if G.GAME and G.GAME.battle_of_gods and type == 'Joker' and not forced_key and not legendary then
        local is_shop = (area == G.shop_jokers or (key_append and string.find(key_append, 'sho')))
        if is_shop then
            local roll = pseudorandom(pseudoseed('botg_shop_rarity' .. (key_append or 'sho') .. (G.GAME.round_resets and G.GAME.round_resets.ante or 1)))
            if roll < 0.01 then
                legendary = true
            elseif roll < 0.011 then
                local secret_keys = {}
                for k, v in pairs(G.P_CENTERS) do
                    if v.set == 'Joker' and (v.is_secret or v.rarity == 'Secret' or (is_secret_card and is_secret_card({config = {center = v}}))) then
                        if not (G.GAME.used_jokers and G.GAME.used_jokers[k] and not (player_has_showman and player_has_showman())) then
                            secret_keys[#secret_keys + 1] = k
                        end
                    end
                end
                if #secret_keys > 0 then
                    forced_key = pseudorandom_element(secret_keys, pseudoseed('botg_secret'))
                end
            end
        end
    end
    return orig_create_card(type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
end

function create_UIBox_botg_warning()
    return create_UIBox_generic_options({
        back_func = 'cancel_battle_of_gods',
        back_label = 'CANCEL',
        back_colour = G.C.RED,
        contents = {
            {n=G.UIT.R, config={align = "cm", padding = 0.08}, nodes={
                {n=G.UIT.T, config={text = "BATTLE OF GODS", scale = 0.65, colour = G.C.GOLD, shadow = true}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.04}, nodes={
                {n=G.UIT.T, config={text = "WARNING", scale = 0.45, colour = G.C.RED, shadow = true}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.08, maxw = 6.2}, nodes={
                {n=G.UIT.T, config={text = "Entering will reset Antes to 1 with a starting score requirement of 2,500 base chips.", scale = 0.35, colour = G.C.WHITE, shadow = true}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.06, maxw = 6.2}, nodes={
                {n=G.UIT.T, config={text = "• All current Jokers will be destroyed.", scale = 0.33, colour = G.C.FILTER, shadow = true}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.06, maxw = 6.2}, nodes={
                {n=G.UIT.T, config={text = "• Enter directly into the Shop with 2X your current money.", scale = 0.33, colour = G.C.MONEY, shadow = true}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.06, maxw = 6.2}, nodes={
                {n=G.UIT.T, config={text = "• Hand levels, vouchers, and other stats are preserved.", scale = 0.33, colour = G.C.BLUE, shadow = true}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.06, maxw = 6.2}, nodes={
                {n=G.UIT.T, config={text = "• Permanently obtain Taster and Critic vouchers.", scale = 0.33, colour = G.C.GREEN, shadow = true}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.15}, nodes={
                UIBox_button({
                    button = 'confirm_battle_of_gods',
                    label = {'ENTER THE COLISEUM'},
                    minw = 4.2,
                    minh = 0.9,
                    scale = 0.5,
                    shadow = true,
                    colour = G.C.GOLD,
                    focus_args = {nav = 'wide', button = 'x', set_button_pip = true}
                })
            }}
        }
    })
end

G.FUNCS.start_battle_of_gods = function(e)
    G.FUNCS.overlay_menu{
        definition = create_UIBox_botg_warning(),
        config = {no_esc = false}
    }
end

G.FUNCS.cancel_battle_of_gods = function(e)
    G.FUNCS.overlay_menu{
        definition = create_UIBox_win(),
        config = {no_esc = true}
    }
end

G.FUNCS.confirm_battle_of_gods = function(e)
    if G.FUNCS.exit_overlay_menu then
        G.FUNCS.exit_overlay_menu()
    end
    if G.OVERLAY_MENU then
        G.OVERLAY_MENU:remove()
        G.OVERLAY_MENU = nil
    end
    G.SETTINGS.paused = false

    -- Clean up all existing Blind Select & Round Eval UI
    if G.blind_prompt_box then
        G.blind_prompt_box:remove()
        G.blind_prompt_box = nil
    end
    if G.blind_select_opts then
        for _, opt in pairs(G.blind_select_opts) do
            if opt and opt.remove then
                pcall(function() opt:remove() end)
            end
        end
        G.blind_select_opts = nil
    end
    if G.blind_select then
        G.blind_select:remove()
        G.blind_select = nil
    end
    if G.round_eval then
        G.round_eval:remove()
        G.round_eval = nil
    end

    -- Clean up any existing shop objects
    if G.SHOP_SIGN then
        G.SHOP_SIGN:remove()
        G.SHOP_SIGN = nil
    end
    if G.shop then
        G.shop:remove()
        G.shop = nil
    end
    if G.shop_jokers then
        if G.shop_jokers.cards then
            for i = #G.shop_jokers.cards, 1, -1 do
                G.shop_jokers.cards[i]:remove()
            end
        end
        G.shop_jokers:remove()
        G.shop_jokers = nil
    end
    if G.shop_vouchers then
        if G.shop_vouchers.cards then
            for i = #G.shop_vouchers.cards, 1, -1 do
                G.shop_vouchers.cards[i]:remove()
            end
        end
        G.shop_vouchers:remove()
        G.shop_vouchers = nil
    end
    if G.shop_booster then
        if G.shop_booster.cards then
            for i = #G.shop_booster.cards, 1, -1 do
                G.shop_booster.cards[i]:remove()
            end
        end
        G.shop_booster:remove()
        G.shop_booster = nil
    end

    -- Clear all current jokers while keeping levels, vouchers, consumables
    if G.jokers and G.jokers.cards then
        for i = #G.jokers.cards, 1, -1 do
            local j = G.jokers.cards[i]
            if j then
                if j.remove_from_deck then
                    pcall(function() j:remove_from_deck() end)
                end
                G.jokers:remove_card(j)
                j:remove()
            end
        end
        G.jokers.cards = {}
    end

    -- Reset Battle of Gods state & Antes to 1
    G.GAME.battle_of_gods = true
    G.GAME.won = false
    G.GAME.win_notified = false
    G.GAME.win_ante = 24
    G.GAME.round = 1
    G.GAME.round_resets.ante = 1
    G.GAME.round_resets.ante_disp = 1
    G.GAME.round_resets.blind_ante = 1
    local b = roll_botg_blinds(1)
    G.GAME.blind_on_deck = 'Small'
    G.GAME.round_resets.blind = G.P_BLINDS[b.Small] or G.P_BLINDS.bl_big
    G.GAME.facing_blind = nil
    G.GAME.round_resets.blind_states = {Small = 'Upcoming', Big = 'Upcoming', Boss = 'Upcoming'}
    G.GAME.round_resets.blind_choices = {
        Small = b.Small,
        Big = b.Big,
        Boss = b.Boss
    }
    G.GAME.round_resets.blind_tags = {
        Small = (get_next_tag_key and get_next_tag_key()) or 'tag_uncommon',
        Big = (get_next_tag_key and get_next_tag_key()) or 'tag_rare'
    }
    G.GAME.divine_grace = G.GAME.divine_grace or 0
    G.GAME.botg_bosses_slain = 0

    -- Double current money
    local cur_dollars = G.GAME.dollars or 0
    if cur_dollars > 0 then
        G.GAME.dollars = cur_dollars * 2
    end
    ease_chips(0)
    if G.HUD then
        G.HUD:recalculate()
    end

    -- Obtain Taster and Critic vouchers
    G.GAME.used_vouchers = G.GAME.used_vouchers or {}
    local v_keys = {
        'v_Witch_brew_catador', 'v_Witch brew_catador', 'v_catador', 'catador',
        'v_Witch_brew_critico', 'v_Witch brew_critico', 'v_critico', 'critico'
    }
    for _, k in ipairs(v_keys) do
        G.GAME.used_vouchers[k] = true
    end

    if G.P_CENTERS['v_Witch_brew_catador'] and G.P_CENTERS['v_Witch_brew_catador'].redeem then
        pcall(function() G.P_CENTERS['v_Witch_brew_catador']:redeem() end)
    end
    if G.P_CENTERS['v_Witch_brew_critico'] and G.P_CENTERS['v_Witch_brew_critico'].redeem then
        pcall(function() G.P_CENTERS['v_Witch_brew_critico']:redeem() end)
    end
    if botg_trigger_mod_achievement then
        botg_trigger_mod_achievement('royal_connoisseur')
    end

    -- Set up upcoming shop & stats
    if SMODS and SMODS.get_next_vouchers then
        G.GAME.current_round.voucher = SMODS.get_next_vouchers()
    elseif get_next_voucher_key then
        local v_key = get_next_voucher_key()
        G.GAME.current_round.voucher = { v_key, spawn = { [v_key] = true } }
    end
    G.GAME.current_round.jokers_purchased = 0
    G.GAME.current_round.used_packs = {}
    G.GAME.shop_free = nil
    G.GAME.shop_d6ed = nil
    G.GAME.current_round.discards_left = math.max(0, (G.GAME.round_resets.discards or 3) + (G.GAME.round_bonus and G.GAME.round_bonus.discards or 0))
    G.GAME.current_round.hands_left = math.max(1, (G.GAME.round_resets.hands or 4) + (G.GAME.round_bonus and G.GAME.round_bonus.next_hands or 0))

    apply_battle_of_gods_bg()

    -- Send directly to shop before starting to play
    G.STATE = G.STATES.SHOP
    G.STATE_COMPLETE = false
end

local function find_endless_node(node)
    if not node or type(node) ~= 'table' then return nil end
    if node.nodes then
        for i, child in ipairs(node.nodes) do
            if child.config and child.config.button == 'exit_overlay_menu' then
                return node, i
            end
            local found_parent, found_idx = find_endless_node(child)
            if found_parent then return found_parent, found_idx end
        end
    end
    return nil
end

-- Mechanic 25: Hall of Gods summary display & button integration
if create_UIBox_win then
    local orig_create_UIBox_win = create_UIBox_win
    function create_UIBox_win()
        local t = orig_create_UIBox_win()
        local cfg = (get_witch_brew_config and get_witch_brew_config())
            or (SMODS and SMODS.Mods and SMODS.Mods['Witch_brew'] and SMODS.Mods['Witch_brew'].config)
            or {}

        if G.GAME and G.GAME.battle_of_gods then
            unlock_colosseum_champion()
            if G.GAME.stake and G.GAME.stake >= 8 then
                if G.PROFILES and G.PROFILES[G.SETTINGS.profile] then
                    G.PROFILES[G.SETTINGS.profile].botg_gold_stake_win = true
                    G:save_settings()
                end
            end
            check_and_unlock_olympic_achievements()

            local function remove_unwanted_win_buttons(node)
                if not node or type(node) ~= 'table' then return end
                if node.nodes then
                    for i = #node.nodes, 1, -1 do
                        local child = node.nodes[i]
                        if child and type(child) == 'table' then
                            if child.config and child.config.button then
                                local b = child.config.button
                                if b == 'exit_overlay_menu' or b == 'notify_then_setup_run' or b == 'start_battle_of_gods' or b == 'show_main_cta' then
                                    table.remove(node.nodes, i)
                                else
                                    remove_unwanted_win_buttons(child)
                                end
                            else
                                remove_unwanted_win_buttons(child)
                            end
                        end
                    end
                end
            end
            remove_unwanted_win_buttons(t)

            table.insert(t.nodes, 1, {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0.12, r = 0.15, colour = {0.1, 0.08, 0, 0.9}, outline = 1.5, outline_colour = G.C.GOLD },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = "🏆 COLOSSEUM CHAMPION 🏆",
                                    scale = 0.48,
                                    colour = G.C.GOLD,
                                    shadow = true
                                }
                            }
                        }
                    }
                }
            })
            return t
        end

        if cfg.battle_of_gods ~= false and has_amulet_mod() then
            local parent, idx = find_endless_node(t)
            if parent and idx then
                parent.nodes[idx] = UIBox_button({
                    button = 'exit_overlay_menu',
                    label = {localize('b_endless')},
                    minw = 3.1,
                    maxw = 3.1,
                    minh = 1.1,
                    scale = 0.58,
                    shadow = true,
                    colour = G.C.BLUE,
                    focus_args = {nav = 'wide', button = 'x', set_button_pip = true}
                })
                table.insert(parent.nodes, idx + 1, UIBox_button({
                    button = 'start_battle_of_gods',
                    label = {'Battle of Gods'},
                    minw = 3.1,
                    maxw = 3.1,
                    minh = 1.1,
                    scale = 0.58,
                    shadow = true,
                    colour = G.C.BLACK,
                    focus_args = {nav = 'wide', button = 'y', set_button_pip = true}
                }))
            end
        end

        return t
    end
end
