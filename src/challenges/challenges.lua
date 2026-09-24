--[[
    Witch Brew Expansion
    10 Synergy Challenges with Full Deck, Joker, and Restriction Rules
--]]

local challenge_definitions = {
    -- 1. High Roller's Casino
    {
        key = 'high_roller_casino',
        loc_txt = {
            name = "High Roller's Casino"
        },
        rules = {
            custom = {
                { id = 'no_reward' },
                { id = 'no_extra_hand_money' },
                { id = 'no_interest' }
            },
            modifiers = {
                { id = 'dollars', value = 16 },
                { id = 'discards', value = 3 }
            }
        },
        jokers = {
            { id = 'j_Witch_brew_slot_machine_joker', eternal = true },
            { id = 'j_Witch_brew_shareholder_joker', eternal = true }
        },
        deck = {
            type = 'Challenge Deck'
        },
        restrictions = {
            banned_cards = {
                { id = 'j_golden' },
                { id = 'j_to_the_moon' },
                { id = 'j_rocket' },
                { id = 'j_satellite' },
                { id = 'v_seed_money' },
                { id = 'v_money_tree' }
            },
            banned_tags = {
                { id = 'tag_investment' },
                { id = 'tag_handy' },
                { id = 'tag_garbage' }
            },
            banned_other = {}
        }
    },

    -- 2. Absolute Silence
    {
        key = 'absolute_silence',
        loc_txt = {
            name = 'Absolute Silence'
        },
        rules = {
            custom = {
                { id = 'no_reward' }
            },
            modifiers = {
                { id = 'hands', value = 4 },
                { id = 'discards', value = 3 }
            }
        },
        jokers = {
            { id = 'j_Witch_brew_falta_de_lectura_joker', eternal = true }
        },
        deck = {
            type = 'Challenge Deck'
        },
        restrictions = {
            banned_cards = {
                -- Unconditional / auto-activating scoring Jokers that break Falta de Lectura
                { id = 'j_joker' },
                { id = 'j_misprint' },
                { id = 'j_popcorn' },
                { id = 'j_gros_michel' },
                { id = 'j_cavendish' },
                { id = 'j_ice_cream' },
                { id = 'j_blue_joker' },
                { id = 'j_abstract' },
                { id = 'j_half' },
                { id = 'j_banner' },
                { id = 'j_mystic_summit' },
                { id = 'j_supernova' },
                { id = 'j_green_joker' },
                { id = 'j_bull' },
                { id = 'j_bootstraps' },
                { id = 'j_swashbuckler' },
                { id = 'j_stone' },
                { id = 'j_stuntman' },
                { id = 'j_ceremonial' },
                { id = 'j_constellation' },
                { id = 'j_fortune_teller' },
                { id = 'j_ride_the_bus' },
                { id = 'j_red_card' },
                { id = 'j_flash' },
                { id = 'j_hologram' },
                { id = 'j_obelisk' },
                { id = 'j_erosion' },
                { id = 'j_madness' },
                { id = 'j_card_sharp' },
                -- Suit-based flat multi jokers
                { id = 'j_greedy_joker' },
                { id = 'j_lusty_joker' },
                { id = 'j_wrathful_joker' },
                { id = 'j_gluttenous_joker' },
                -- Simple unconditional hand jokers
                { id = 'j_droll' },
                { id = 'j_sly' },
                { id = 'j_clever' },
                { id = 'j_devious' },
                { id = 'j_wily' },
                { id = 'j_zany' },
                { id = 'j_mad' },
                { id = 'j_crazy' }
            },
            banned_tags = {},
            banned_other = {}
        }
    },

    -- 3. Sacred Symmetry
    {
        key = 'sacred_symmetry',
        loc_txt = {
            name = 'Sacred Symmetry'
        },
        rules = {
            custom = {
                { id = 'single_random_suit' }
            },
            modifiers = {
                { id = 'hands', value = 3 },
                { id = 'discards', value = 3 }
            }
        },
        jokers = {
            { id = 'j_Witch_brew_symmetrical_joker', eternal = true },
            { id = 'j_Witch_brew_balance_joker', eternal = true }
        },
        vouchers = {
            { id = 'v_directors_cut' }
        },
        deck = {
            type = 'Challenge Deck'
        },
        restrictions = {
            banned_cards = {
                -- Banned tarots that modify ranks (Death, Strength)
                { id = 'c_death' },
                { id = 'c_strength' },
                { id = 'j_four_fingers' },
                { id = 'j_shortcut' }
            },
            banned_tags = {},
            banned_other = {
                { id = 'bl_goad', type = 'blind' },
                { id = 'bl_window', type = 'blind' },
                { id = 'bl_club', type = 'blind' },
                { id = 'bl_head', type = 'blind' }
            }
        }
    },

    -- 4. Predatory Loan
    {
        key = 'predatory_loan',
        loc_txt = {
            name = 'Predatory Loan'
        },
        rules = {
            custom = {
                { id = 'inflation' }
            },
            modifiers = {
                { id = 'dollars', value = 26 },
                { id = 'discards', value = 3 }
            }
        },
        jokers = {
            { id = 'j_Witch_brew_infostealer_joker', eternal = true }
        },
        vouchers = {
            { id = 'v_seed_money' }
        },
        deck = {
            type = 'Challenge Deck'
        },
        restrictions = {
            banned_cards = {
                { id = 'j_credit_card' }
            },
            banned_tags = {},
            banned_other = {}
        }
    },

    -- 5. The Forge & The Mine
    {
        key = 'the_forge_and_mine',
        loc_txt = {
            name = 'The Forge & The Mine'
        },
        rules = {
            custom = {},
            modifiers = {
                { id = 'hand_size', value = 7 },
                { id = 'discards', value = 2 },
                { id = 'hands', value = 5 }
            }
        },
        jokers = {
            { id = 'j_Witch_brew_blacksmith_joker', eternal = true },
            { id = 'j_Witch_brew_builder_joker', eternal = true }
        },
        deck = {
            type = 'Challenge Deck',
            -- Exactly 16 Stone Cards, all are Aces (4 of each suit)
            cards = {
                {s='S',r='A',e='m_stone'},{s='S',r='A',e='m_stone'},{s='S',r='A',e='m_stone'},{s='S',r='A',e='m_stone'},
                {s='H',r='A',e='m_stone'},{s='H',r='A',e='m_stone'},{s='H',r='A',e='m_stone'},{s='H',r='A',e='m_stone'},
                {s='C',r='A',e='m_stone'},{s='C',r='A',e='m_stone'},{s='C',r='A',e='m_stone'},{s='C',r='A',e='m_stone'},
                {s='D',r='A',e='m_stone'},{s='D',r='A',e='m_stone'},{s='D',r='A',e='m_stone'},{s='D',r='A',e='m_stone'}
            }
        },
        restrictions = {
            banned_cards = {
                -- Tarots that grant enhancements
                { id = 'c_magician' },
                { id = 'c_empress' },
                { id = 'c_heirophant' },
                { id = 'c_lovers' },
                { id = 'c_chariot' },
                { id = 'c_justice' },
                { id = 'c_tower' },
                { id = 'c_devil' },
                -- Tarots that alter cards
                { id = 'c_death' },
                { id = 'c_strength' },
                -- Spectrals that alter cards, seals or enhancements
                { id = 'c_talisman' },
                { id = 'c_deja_vu' },
                { id = 'c_trance' },
                { id = 'c_medium' },
                { id = 'c_aura' },
                { id = 'c_immolate' },
                { id = 'c_grim' },
                { id = 'c_incantation' },
                { id = 'c_familiar' },
                { id = 'c_sigil' },
                { id = 'c_ouija' },
                { id = 'c_cryptid' },
                -- Jokers that alter cards or add enhancements
                { id = 'j_marble' },
                { id = 'j_midas_mask' },
                { id = 'j_vampire' },
                { id = 'j_certificate' },
                { id = 'j_dna' },
                { id = 'j_trading' }
            },
            banned_tags = {
                { id = 'tag_standard' }
            },
            banned_other = {}
        }
    },

    -- 6. Parity Duel
    {
        key = 'parity_duel',
        loc_txt = {
            name = 'Parity Duel'
        },
        rules = {
            custom = {},
            modifiers = {
                { id = 'hands', value = 3 },
                { id = 'discards', value = 3 }
            }
        },
        jokers = {
            { id = 'j_Witch_brew_duel_of_value_joker', eternal = true }
        },
        deck = {
            type = 'Challenge Deck',
            -- All Face cards (J, Q, K) banned; 40 numbered cards (2..T, A)
            cards = {
                {s='S',r='2'},{s='S',r='3'},{s='S',r='4'},{s='S',r='5'},{s='S',r='6'},{s='S',r='7'},{s='S',r='8'},{s='S',r='9'},{s='S',r='T'},{s='S',r='A'},
                {s='H',r='2'},{s='H',r='3'},{s='H',r='4'},{s='H',r='5'},{s='H',r='6'},{s='H',r='7'},{s='H',r='8'},{s='H',r='9'},{s='H',r='T'},{s='H',r='A'},
                {s='C',r='2'},{s='C',r='3'},{s='C',r='4'},{s='C',r='5'},{s='C',r='6'},{s='C',r='7'},{s='C',r='8'},{s='C',r='9'},{s='C',r='T'},{s='C',r='A'},
                {s='D',r='2'},{s='D',r='3'},{s='D',r='4'},{s='D',r='5'},{s='D',r='6'},{s='D',r='7'},{s='D',r='8'},{s='D',r='9'},{s='D',r='T'},{s='D',r='A'}
            }
        },
        restrictions = {
            banned_cards = {
                { id = 'j_even_steven' },
                { id = 'j_odd_todd' },
                -- Banned all Planets EXCEPT Double Pair, Pair, and Straight
                { id = 'c_venus' },
                { id = 'c_earth' },
                { id = 'c_mars' },
                { id = 'c_jupiter' },
                { id = 'c_neptune' },
                { id = 'c_pluto' },
                { id = 'c_planet_x' },
                { id = 'c_ceres' },
                { id = 'c_eris' }
            },
            banned_tags = {},
            banned_other = {}
        }
    },

    -- 7. The Living Canvas
    {
        key = 'living_canvas',
        loc_txt = {
            name = 'The Living Canvas'
        },
        rules = {
            custom = {},
            modifiers = {
                { id = 'hand_size', value = 8 }
            }
        },
        jokers = {
            { id = 'j_Witch_brew_paint_puddle_joker', eternal = true },
            { id = 'j_Witch_brew_disenador_joker', eternal = true }
        },
        deck = {
            type = 'Challenge Deck',
            -- Numbers (2..T) are Wild (36 cards), Figures (J, Q, K, A) are normal (16 cards)
            cards = {
                {s='S',r='2',e='m_wild'},{s='S',r='3',e='m_wild'},{s='S',r='4',e='m_wild'},{s='S',r='5',e='m_wild'},{s='S',r='6',e='m_wild'},{s='S',r='7',e='m_wild'},{s='S',r='8',e='m_wild'},{s='S',r='9',e='m_wild'},{s='S',r='T',e='m_wild'},
                {s='H',r='2',e='m_wild'},{s='H',r='3',e='m_wild'},{s='H',r='4',e='m_wild'},{s='H',r='5',e='m_wild'},{s='H',r='6',e='m_wild'},{s='H',r='7',e='m_wild'},{s='H',r='8',e='m_wild'},{s='H',r='9',e='m_wild'},{s='H',r='T',e='m_wild'},
                {s='C',r='2',e='m_wild'},{s='C',r='3',e='m_wild'},{s='C',r='4',e='m_wild'},{s='C',r='5',e='m_wild'},{s='C',r='6',e='m_wild'},{s='C',r='7',e='m_wild'},{s='C',r='8',e='m_wild'},{s='C',r='9',e='m_wild'},{s='C',r='T',e='m_wild'},
                {s='D',r='2',e='m_wild'},{s='D',r='3',e='m_wild'},{s='D',r='4',e='m_wild'},{s='D',r='5',e='m_wild'},{s='D',r='6',e='m_wild'},{s='D',r='7',e='m_wild'},{s='D',r='8',e='m_wild'},{s='D',r='9',e='m_wild'},{s='D',r='T',e='m_wild'},
                {s='S',r='J'},{s='S',r='Q'},{s='S',r='K'},{s='S',r='A'},
                {s='H',r='J'},{s='H',r='Q'},{s='H',r='K'},{s='H',r='A'},
                {s='C',r='J'},{s='C',r='Q'},{s='C',r='K'},{s='C',r='A'},
                {s='D',r='J'},{s='D',r='Q'},{s='D',r='K'},{s='D',r='A'}
            }
        },
        restrictions = {
            banned_cards = {
                -- Banned tarots that change enhancements
                { id = 'c_magician' },
                { id = 'c_empress' },
                { id = 'c_heirophant' },
                { id = 'c_lovers' },
                { id = 'c_chariot' },
                { id = 'c_justice' },
                { id = 'c_tower' },
                { id = 'c_devil' },
                -- Banned suit-benefiting jokers
                { id = 'j_ancient' },
                { id = 'j_bloodstone' },
                { id = 'j_arrowhead' },
                { id = 'j_onyx_agate' },
                { id = 'j_rough_gem' },
                { id = 'j_smeared' },
                { id = 'j_greedy_joker' },
                { id = 'j_lusty_joker' },
                { id = 'j_wrathful_joker' },
                { id = 'j_gluttenous_joker' },
                { id = 'j_idol' },
                { id = 'j_flower_pot' },
                { id = 'j_seeing_double' },
                { id = 'j_blackboard' },
                { id = 'j_castle' },
                { id = 'j_tribe' }
            },
            banned_tags = {},
            banned_other = {
                { id = 'bl_pillar', type = 'blind' },
                { id = 'bl_flint', type = 'blind' }
            }
        }
    },

    -- 8. Edition Tycoon
    {
        key = 'edition_tycoon',
        loc_txt = {
            name = 'Edition Tycoon'
        },
        rules = {
            custom = {
                { id = 'scaling', value = 2 }
            },
            modifiers = {
                -- Allows only 3 jokers in addition to the 2 starting ones (total 5 slots)
                { id = 'joker_slots', value = 5 },
                { id = 'reroll_cost', value = 5 }
            }
        },
        jokers = {
            { id = 'j_Witch_brew_perfectionism_joker', eternal = true },
            { id = 'j_Witch_brew_appraiser_joker', eternal = true }
        },
        vouchers = {
            { id = 'v_crystal_ball' },
            { id = 'v_omen_globe' },
            { id = 'v_magic_trick' },
            { id = 'v_illusion' },
            { id = 'v_hone' }
        },
        deck = {
            type = 'Challenge Deck'
        },
        restrictions = {
            banned_cards = {
                -- Banned jokers that add mult on played cards
                { id = 'j_scholar' },
                { id = 'j_shoot_the_moon' },
                { id = 'j_walkie_talkie' },
                { id = 'j_smiley' },
                { id = 'j_scary_face' },
                { id = 'j_even_steven' },
                { id = 'j_odd_todd' },
                { id = 'j_fibonacci' },
                { id = 'j_hack' },
                { id = 'j_photograph' },
                { id = 'j_triboulet' },
                { id = 'j_ancient' },
                { id = 'j_bloodstone' },
                { id = 'j_arrowhead' },
                { id = 'j_onyx_agate' },
                { id = 'v_glow_up' }
            },
            banned_tags = {},
            banned_other = {}
        }
    },

    -- 9. Code Red ER
    {
        key = 'code_red_er',
        loc_txt = {
            name = 'Code Red ER'
        },
        rules = {
            custom = {
                -- All jokers are perishable
                { id = 'all_perishable' }
            },
            modifiers = {
                { id = 'hands', value = 3 },
                { id = 'discards', value = 3 },
                { id = 'dollars', value = 15 }
            }
        },
        jokers = {
            -- Starts with 5 Doctor Jo Jokers, all perishable
            { id = 'j_Witch_brew_doctor_jo_joker', perishable = true },
            { id = 'j_Witch_brew_doctor_jo_joker', perishable = true },
            { id = 'j_Witch_brew_doctor_jo_joker', perishable = true },
            { id = 'j_Witch_brew_doctor_jo_joker', perishable = true },
            { id = 'j_Witch_brew_doctor_jo_joker', perishable = true }
        },
        deck = {
            type = 'Challenge Deck'
        },
        restrictions = {
            banned_cards = {
                { id = 'j_mr_bones' }
            },
            banned_tags = {},
            banned_other = {}
        }
    },

    -- 10. Singular Saturation
    {
        key = 'singular_saturation',
        loc_txt = {
            name = 'Singular Saturation'
        },
        rules = {
            custom = {},
            modifiers = {
                { id = 'hands', value = 4 },
                { id = 'discards', value = 2 },
                { id = 'dollars', value = 30 }
            }
        },
        jokers = {
            { id = 'j_Witch_brew_oversaturated_joker', eternal = true }
        },
        vouchers = {
            { id = 'v_telescope' }
        },
        deck = {
            type = 'Challenge Deck'
        },
        restrictions = {
            banned_cards = {
                -- Tarots that grant enhancements or editions
                { id = 'c_magician' },
                { id = 'c_empress' },
                { id = 'c_heirophant' },
                { id = 'c_lovers' },
                { id = 'c_chariot' },
                { id = 'c_justice' },
                { id = 'c_tower' },
                { id = 'c_devil' },
                { id = 'c_wheel_of_fortune' },
                -- Spectrals that grant seals, editions or alterations
                { id = 'c_talisman' },
                { id = 'c_deja_vu' },
                { id = 'c_trance' },
                { id = 'c_medium' },
                { id = 'c_aura' },
                -- Jokers that grant enhancements, seals or editions
                { id = 'j_marble' },
                { id = 'j_midas_mask' },
                { id = 'j_certificate' },
                -- Hand modifiers
                { id = 'j_burglar' },
                { id = 'v_grabber' },
                { id = 'v_nacho_tong' }
            },
            banned_tags = {
                { id = 'tag_standard' },
                { id = 'tag_foil' },
                { id = 'tag_holo' },
                { id = 'tag_polychrome' }
            },
            banned_other = {
                { id = 'bl_arm', type = 'blind' }
            }
        }
    }
}

-- Hook for Geometría Sagrada (single random suit deck) and all_perishable challenge mechanic
local orig_game_start_run = Game.start_run
function Game:start_run(args)
    if alias_all_witch_brew_centers then
        alias_all_witch_brew_centers()
    end
    local ret = orig_game_start_run(self, args)
    if not (args and args.savetable) and G.GAME then
        local ch_id = (G.GAME.challenge) or (args and args.challenge and (args.challenge.id or args.challenge.key)) or ""
        if ch_id == 'c_Witch_brew_sacred_symmetry' or ch_id == 'sacred_symmetry' or ch_id == 'c_Witch_brew_geometria_sagrada' or ch_id == 'geometria_sagrada' or (G.GAME.challenge_tab and (G.GAME.challenge_tab.id == 'c_Witch_brew_sacred_symmetry' or G.GAME.challenge_tab.id == 'c_Witch_brew_geometria_sagrada')) then
            if G.playing_cards and #G.playing_cards > 0 then
                local suits = { 'Spades', 'Hearts', 'Clubs', 'Diamonds' }
                local chosen_suit = pseudorandom_element(suits, pseudoseed('sacred_symmetry_suit'))
                for _, c in ipairs(G.playing_cards) do
                    c:change_suit(chosen_suit)
                end
            end
        end
        if ch_id == 'c_Witch_brew_code_red_er' or ch_id == 'code_red_er' or (G.GAME.challenge_tab and G.GAME.challenge_tab.id == 'c_Witch_brew_code_red_er') then
            if G.jokers and G.jokers.cards then
                local tallies = { 4, 4, 6, 6, 8 }
                for idx, jk in ipairs(G.jokers.cards) do
                    if tallies[idx] and jk.ability and jk.ability.perishable then
                        jk.ability.perish_tally = tallies[idx]
                    end
                end
            end
        end
    end
    return ret
end

-- Hook create_card for all_perishable custom rule
local orig_create_card = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    local card = orig_create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if _type == 'Joker' and card and G.GAME and G.GAME.modifiers and G.GAME.modifiers.all_perishable then
        if card.set_perishable then
            card:set_perishable(true)
        else
            card.ability.perishable = true
            card.ability.perish_tally = G.GAME.perishable_rounds or 5
        end
    end
    return card
end

-- Synchronize / dynamic toggle for challenges in G.CHALLENGES
function witch_brew_sync_challenges(enable)
    if not G.CHALLENGES then return end

    -- Remove any existing Witch_Brew challenges
    for i = #G.CHALLENGES, 1, -1 do
        local ch = G.CHALLENGES[i]
        if ch and ch.id and (string.find(ch.id, 'Witch_brew', 1, true) or string.find(ch.id, 'c_witch_brew_', 1, true)) then
            table.remove(G.CHALLENGES, i)
        end
    end

    -- If enabled, inject the 10 challenges into G.CHALLENGES
    if enable then
        for _, ch in ipairs(challenge_definitions) do
            local ch_id = 'c_Witch_brew_' .. ch.key
            local ch_name = (ch.loc_txt and ch.loc_txt.name) or ch.key
            table.insert(G.CHALLENGES, {
                name = ch_name,
                id = ch_id,
                rules = ch.rules or {},
                jokers = ch.jokers or {},
                consumeables = ch.consumeables or {},
                vouchers = ch.vouchers or {},
                deck = ch.deck or { type = 'Challenge Deck' },
                restrictions = ch.restrictions or {}
            })
            if G.localization and G.localization.misc and G.localization.misc.challenge_names then
                G.localization.misc.challenge_names[ch_id] = ch_name
                G.localization.misc.challenge_names[ch.key] = ch_name
            end
        end
    end
end

-- SMODS.Challenge Registration
for _, def in ipairs(challenge_definitions) do
    if SMODS and SMODS.Challenge then
        SMODS.Challenge {
            key = def.key,
            loc_txt = def.loc_txt,
            rules = def.rules,
            jokers = def.jokers,
            consumeables = def.consumeables,
            vouchers = def.vouchers,
            deck = def.deck,
            restrictions = def.restrictions
        }
    end
end

-- Ensure challenges are properly synced according to current mod config
local original_init_game_challenges = Game.init_game_object
if original_init_game_challenges then
    local cfg = (get_witch_brew_config and get_witch_brew_config())
        or (SMODS and SMODS.Mods and SMODS.Mods['Witch_brew'] and SMODS.Mods['Witch_brew'].config)
        or (SMODS and SMODS.current_mod and SMODS.current_mod.config)
        or {}
    if cfg.new_challenges == false then
        witch_brew_sync_challenges(false)
    end
end
