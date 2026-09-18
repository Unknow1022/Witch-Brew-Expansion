--[[
    Witch Brew Expansion
    Localization & Mod Configuration System (English Only)
--]]

function get_witch_brew_mod()
    if SMODS and SMODS.Mods and SMODS.Mods['Witch_brew'] then
        return SMODS.Mods['Witch_brew']
    end
    if SMODS and SMODS.findMod then
        local found = SMODS.findMod('Witch_brew')
        if found and found[1] then return found[1] end
    end
    if Witch_brew_MOD then
        return Witch_brew_MOD
    end
    if SMODS and SMODS.current_mod then
        return SMODS.current_mod
    end
    return nil
end

function get_witch_brew_config()
    local mod = get_witch_brew_mod()
    if mod and mod.config then
        return mod.config
    end
    if SMODS and SMODS.Mods and SMODS.Mods['Witch_brew'] and SMODS.Mods['Witch_brew'].config then
        return SMODS.Mods['Witch_brew'].config
    end
    return {}
end

function save_witch_brew_config()
    local mod = get_witch_brew_mod()
    if SMODS and SMODS.save_mod_config and mod then
        pcall(function() SMODS.save_mod_config(mod) end)
    end
    local cfg = get_witch_brew_config()
    local new_runs = cfg.new_runs == true
    local new_challenges = cfg.new_challenges ~= false
    local new_spectrals_and_jobs = cfg.new_spectrals_and_jobs ~= false
    local new_boss_blinds = cfg.new_boss_blinds ~= false
    local fast_animations = cfg.fast_animations == true
    local secret_power_theme = cfg.secret_power_theme ~= false
    local config_str = "return {\n" ..
        "    [\"new_runs\"] = " .. tostring(new_runs) .. ",\n" ..
        "    [\"new_challenges\"] = " .. tostring(new_challenges) .. ",\n" ..
        "    [\"new_spectrals_and_jobs\"] = " .. tostring(new_spectrals_and_jobs) .. ",\n" ..
        "    [\"new_boss_blinds\"] = " .. tostring(new_boss_blinds) .. ",\n" ..
        "    [\"fast_animations\"] = " .. tostring(fast_animations) .. ",\n" ..
        "    [\"secret_power_theme\"] = " .. tostring(secret_power_theme) .. ",\n" ..
        "}\n"
    local mod_path = (mod and mod.path) or ""
    if SMODS and SMODS.NFS and SMODS.NFS.write and mod_path ~= "" then
        pcall(function() SMODS.NFS.write(mod_path .. "config.lua", config_str) end)
    elseif NFS and NFS.write and mod_path ~= "" then
        pcall(function() NFS.write(mod_path .. "config.lua", config_str) end)
    elseif love and love.filesystem and love.filesystem.write then
        pcall(function() love.filesystem.write("config.lua", config_str) end)
    end
end

-- =========================================================================
-- ENGLISH CHALLENGE NAMES
-- =========================================================================

local ENGLISH_CHALLENGE_NAMES = {
    ['c_witch_brew_casino_roller'] = "High Roller's Casino",
    ['casino_roller'] = "High Roller's Casino",
    ['c_witch_brew_silencio_absoluto'] = 'Absolute Silence',
    ['silencio_absoluto'] = 'Absolute Silence',
    ['c_witch_brew_geometria_sagrada'] = 'Sacred Symmetry',
    ['geometria_sagrada'] = 'Sacred Symmetry',
    ['c_witch_brew_deuda_extrema'] = 'Predatory Loan',
    ['deuda_extrema'] = 'Predatory Loan',
    ['c_witch_brew_forja_y_mina'] = 'The Forge & The Mine',
    ['forja_y_mina'] = 'The Forge & The Mine',
    ['c_witch_brew_duelo_numerico'] = 'Parity Duel',
    ['duelo_numerico'] = 'Parity Duel',
    ['c_witch_brew_lienzo_vivo'] = 'The Living Canvas',
    ['lienzo_vivo'] = 'The Living Canvas',
    ['c_Witch_brew_coleccionista_brillos'] = 'Edition Tycoon',
    ['coleccionista_brillos'] = 'Edition Tycoon',
    ['c_Witch_brew_urgencias_medicas'] = 'Code Red ER',
    ['urgencias_medicas'] = 'Code Red ER',
    ['c_Witch_brew_sobresaturacion'] = 'Singular Saturation',
    ['sobresaturacion'] = 'Singular Saturation',

    ['c_omelette_1'] = 'The Omelette',
    ['c_city_1'] = '15 Minute City',
    ['c_rich_1'] = 'Rich get Richer',
    ['c_knife_1'] = "On a Knife's Edge",
    ['c_xray_1'] = 'X-ray Vision',
    ['c_mad_world_1'] = 'Mad World',
    ['c_luxury_1'] = 'Luxury Tax',
    ['c_non_perishable_1'] = 'Non-Perishable',
    ['c_medusa_1'] = 'Medusa',
    ['c_double_nothing_1'] = 'Double or Nothing',
    ['c_typecast_1'] = 'Typecast',
    ['c_inflation_1'] = 'Inflation',
    ['c_bram_poker_1'] = 'Bram Poker',
    ['c_fragile_1'] = 'Fragile',
    ['c_monolith_1'] = 'Monolith',
    ['c_blast_off_1'] = 'Blast Off',
    ['c_five_card_1'] = 'Five-Card Draw',
    ['c_golden_needle_1'] = 'Golden Needle',
    ['c_cruelty_1'] = 'Cruelty',
    ['c_jokerless_1'] = 'Jokerless',
}

-- Helper to parse localization strings
local function reparse_localization_entry(entry)
    if not entry then return end
    if loc_parse_string then
        if entry.text then
            entry.text_parsed = {}
            for _, line in ipairs(entry.text) do
                entry.text_parsed[#entry.text_parsed + 1] = loc_parse_string(line)
            end
        else
            entry.text_parsed = entry.text_parsed or {}
        end
        if entry.name then
            entry.name_parsed = {}
            local names = (type(entry.name) == 'table') and entry.name or { entry.name }
            for _, line in ipairs(names) do
                entry.name_parsed[#entry.name_parsed + 1] = loc_parse_string(line)
            end
        else
            entry.name_parsed = entry.name_parsed or {}
        end
    else
        entry.text_parsed = entry.text_parsed or {}
        entry.name_parsed = entry.name_parsed or {}
    end
end

-- =========================================================================
-- INITIALIZATION & REGISTRATION
-- =========================================================================

function apply_witch_brew_language()
    G.Witch_brew_SPANISH = false
end

local function init_witch_brew_localization()
    if not G.localization then return end

    -- Safeguard Sleeve and Back entries
    if G.localization.descriptions then
        if G.localization.descriptions.Sleeve then
            for _, s_entry in pairs(G.localization.descriptions.Sleeve) do
                if type(s_entry) == 'table' and not s_entry.text_parsed then
                    reparse_localization_entry(s_entry)
                end
            end
        end
        if G.localization.descriptions.Back then
            for _, b_entry in pairs(G.localization.descriptions.Back) do
                if type(b_entry) == 'table' and not b_entry.text_parsed then
                    reparse_localization_entry(b_entry)
                end
            end
        end

        -- Bull Market & Bear Market Tooltips
        G.localization.descriptions.Other = G.localization.descriptions.Other or {}
        G.localization.descriptions.Other['bull_market'] = {
            name = 'Bull Market',
            text = {
                "High market optimism!",
                "Next round's stock price rises",
                "sharply to {C:money}$12-$18{}.",
                "{C:inactive}(Triggered by beating Blind in 1 hand){}"
            }
        }
        G.localization.descriptions.Other['bear_market'] = {
            name = 'Bear Market',
            text = {
                "Market downturn and crash!",
                "Next round's stock price falls",
                "sharply to {C:money}$2-$5{}.",
                "{C:inactive}(Triggered by using all hands in a round){}"
            }
        }
        reparse_localization_entry(G.localization.descriptions.Other['bull_market'])
        reparse_localization_entry(G.localization.descriptions.Other['bear_market'])
    end

    -- Challenge Names & Dictionary Entries
    if G.localization.misc then
        if not G.localization.misc.challenge_names then
            G.localization.misc.challenge_names = {}
        end
        for k, v in pairs(ENGLISH_CHALLENGE_NAMES) do
            G.localization.misc.challenge_names[k] = v
        end

        if G.localization.misc.v_dictionary then
            G.localization.misc.v_dictionary['ch_c_single_random_suit'] = 'Deck consists of a single random suit'
            G.localization.misc.v_dictionary['ch_c_all_perishable'] = 'All Jokers are perishable'
        end
        if G.localization.misc.dictionary then
            G.localization.misc.dictionary['ch_c_single_random_suit'] = 'Deck consists of a single random suit'
            G.localization.misc.dictionary['ch_c_all_perishable'] = 'All Jokers are perishable'
            G.localization.misc.dictionary['k_job'] = 'Job'
            G.localization.misc.dictionary['b_job_cards'] = 'Job Cards'
            G.localization.misc.dictionary['k_job_pack'] = 'Job Application'
        end
    end

    if G.CHALLENGES then
        for _, ch in ipairs(G.CHALLENGES) do
            if ch and ch.id and ENGLISH_CHALLENGE_NAMES[ch.id] then
                ch.name = ENGLISH_CHALLENGE_NAMES[ch.id]
            end
        end
    end

    if alias_all_witch_brew_centers then
        alias_all_witch_brew_centers()
    end
end

local original_init_loc = init_localization
function init_localization()
    if original_init_loc then original_init_loc() end
    init_witch_brew_localization()
end

-- =========================================================================
-- SMODS MOD CONFIG TAB REGISTRATION
-- =========================================================================

local function build_witch_brew_config_tab()
    local cfg = get_witch_brew_config()

    local title_sub = "Control Panel & Customization"
    local quote_text = "Reading is recommended... and if you dislike reading, too bad XD"
    local saved_text = "● Settings saved in real-time"

    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            padding = 0.05,
            colour = G.C.CLEAR
        },
        nodes = {
            {
                n = G.UIT.R,
                config = {
                    align = "cm",
                    padding = 0.1,
                    r = 0.12,
                    colour = {0.05, 0.05, 0.08, 0.65},
                    emboss = 0.05
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.02 },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = "Witch Brew Expansion",
                                    scale = 0.44,
                                    colour = G.C.GOLD,
                                    shadow = true
                                }
                            }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.02 },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = { align = "cm", padding = 0.04, r = 0.08, colour = {0.45, 0.08, 0.72, 0.6} },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = "v1.1.1",
                                            scale = 0.22,
                                            colour = G.C.WHITE
                                        }
                                    }
                                }
                            },
                            {
                                n = G.UIT.C,
                                config = { align = "cm", padding = 0.04, r = 0.08, colour = {0.15, 0.15, 0.2, 0.6} },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = "By Unknow102",
                                            scale = 0.22,
                                            colour = G.C.UI.TEXT_LIGHT
                                        }
                                    }
                                }
                            }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.01 },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = title_sub,
                                    scale = 0.26,
                                    colour = G.C.UI.TEXT_LIGHT
                                }
                            }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.02 },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = "\"" .. quote_text .. "\"",
                                    scale = 0.21,
                                    colour = G.C.GOLD
                                }
                            }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.04 },
                        nodes = {
                            -- Left Column (Gameplay)
                            {
                                n = G.UIT.C,
                                config = { align = "tm", padding = 0.06 },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = { align = "cm", padding = 0.02 },
                                        nodes = {
                                            {
                                                n = G.UIT.T,
                                                config = {
                                                    text = "— GAMEPLAY —",
                                                    scale = 0.25,
                                                    colour = G.C.BLUE
                                                }
                                            }
                                        }
                                    },
                                    create_toggle({
                                        label = "New Runs",
                                        w = 2.4,
                                        scale = 0.75,
                                        label_scale = 0.30,
                                        ref_table = cfg,
                                        ref_value = "new_runs",
                                        callback = function(val)
                                            save_witch_brew_config()
                                        end,
                                        info = {
                                            "Optional. Seeds generate divergent",
                                            "variations from vanilla Balatro."
                                        }
                                    }),
                                    create_toggle({
                                        label = "New Challenges",
                                        w = 2.4,
                                        scale = 0.75,
                                        label_scale = 0.30,
                                        ref_table = cfg,
                                        ref_value = "new_challenges",
                                        callback = function(val)
                                            save_witch_brew_config()
                                            if witch_brew_sync_challenges then
                                                witch_brew_sync_challenges(cfg.new_challenges)
                                            end
                                        end,
                                        info = {
                                            "Toggles the 10 synergy challenges",
                                            "added by this mod in real-time."
                                        }
                                    }),
                                    create_toggle({
                                        label = "New Spectrals & Jobs",
                                        w = 2.4,
                                        scale = 0.75,
                                        label_scale = 0.30,
                                        ref_table = cfg,
                                        ref_value = "new_spectrals_and_jobs",
                                        callback = function(val)
                                            save_witch_brew_config()
                                        end,
                                        info = {
                                            "Toggles custom Job cards and new",
                                            "Spectrals in the consumable pool."
                                        }
                                    }),
                                    create_toggle({
                                        label = "New Boss Blinds",
                                        w = 2.4,
                                        scale = 0.75,
                                        label_scale = 0.30,
                                        ref_table = cfg,
                                        ref_value = "new_boss_blinds",
                                        callback = function(val)
                                            save_witch_brew_config()
                                        end,
                                        info = {
                                            "Enables Witch Brew Expansion's 11 Boss Blinds",
                                            "(The Pole, The Rod, The Door, etc)."
                                        }
                                    })
                                }
                            },
                            -- Right Column (Visuals & Settings)
                            {
                                n = G.UIT.C,
                                config = { align = "tm", padding = 0.06 },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = { align = "cm", padding = 0.02 },
                                        nodes = {
                                            {
                                                n = G.UIT.T,
                                                config = {
                                                    text = "— VISUALS & SETTINGS —",
                                                    scale = 0.25,
                                                    colour = G.C.PURPLE
                                                }
                                            }
                                        }
                                    },
                                    create_toggle({
                                        label = "Purple/Red Menu BG",
                                        w = 2.4,
                                        scale = 0.75,
                                        label_scale = 0.28,
                                        ref_table = cfg,
                                        ref_value = "custom_menu_bg",
                                        callback = function(val)
                                            save_witch_brew_config()
                                            if apply_witch_brew_menu_bg then
                                                apply_witch_brew_menu_bg(val)
                                            end
                                        end,
                                        info = {
                                            "Changes main menu vortex background",
                                            "to mystic purple and red ambient tones."
                                        }
                                    }),
                                    create_toggle({
                                        label = "Fast Animations",
                                        w = 2.4,
                                        scale = 0.75,
                                        label_scale = 0.30,
                                        ref_table = cfg,
                                        ref_value = "fast_animations",
                                        callback = function(val)
                                            save_witch_brew_config()
                                        end,
                                        info = {
                                            "Reduces delays on custom mechanics",
                                            "(Slot spins, transforms) for speed."
                                        }
                                    }),
                                    create_toggle({
                                        label = "Secret Power Theme",
                                        w = 2.4,
                                        scale = 0.75,
                                        label_scale = 0.26,
                                        ref_table = cfg,
                                        ref_value = "secret_power_theme",
                                        callback = function(val)
                                            save_witch_brew_config()
                                        end,
                                        info = {
                                            "Secret Power Discovered",
                                            "(All in One Theme mix)",
                                            "(Original By LouisF, Mix by Unknow102)",
                                            "Dynamic theme for Secret Jokers",
                                            "(Except: Tarot, Planets, Shop)."
                                        }
                                    })
                                }
                            }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.02 },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = saved_text,
                                    scale = 0.22,
                                    colour = G.C.GREEN
                                }
                            }
                        }
                    }
                }
            }
        }
    }
end

local mod_init = get_witch_brew_mod()
if mod_init then
    mod_init.config = mod_init.config or {}
    if mod_init.config.new_runs == nil then mod_init.config.new_runs = false end
    if mod_init.config.new_challenges == nil then mod_init.config.new_challenges = true end
    if mod_init.config.new_spectrals_and_jobs == nil then mod_init.config.new_spectrals_and_jobs = true end
    if mod_init.config.new_boss_blinds == nil then mod_init.config.new_boss_blinds = true end
    if mod_init.config.fast_animations == nil then mod_init.config.fast_animations = false end
    if mod_init.config.custom_menu_bg == nil then mod_init.config.custom_menu_bg = true end
    if mod_init.config.secret_power_theme == nil then mod_init.config.secret_power_theme = true end
    mod_init.config_tab = build_witch_brew_config_tab
end
if SMODS and SMODS.current_mod then
    SMODS.current_mod.config_tab = build_witch_brew_config_tab
end
