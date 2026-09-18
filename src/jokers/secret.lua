-- Secret Jokers (Secret Rarity)
SMODS.Atlas {
    key = "secret_jokers",
    path = "secret_jokers.png",
    px = 71,
    py = 95
}
-- Helper to register secret jokers with standard attributes and badges
local function register_secret_joker(def)
    def.rarity = def.rarity or 4
    def.is_secret = true
    def.soul_pos = def.soul_pos or { x = 1, y = (def.pos and def.pos.y) or 0 }
    def.cost = def.cost or 20
    def.in_pool = def.in_pool or function(self, args)
        return false, { allow_duplicates = false }
    end
    def.set_card_type_badge = def.set_card_type_badge or function(self, card, badges)
        badges[1] = create_badge('Secret', HEX('000000'), G.C.WHITE, 1.2)
    end
    def.set_badges = def.set_badges or function(self, card, badges)
        if badges and #badges > 0 then
            badges[1] = create_badge('Secret', HEX('000000'), G.C.WHITE, 1.2)
        end
    end
    return SMODS.Joker(def)
end

-- 1. Esteban
register_secret_joker {
    key = 'esteban',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    loc_txt = {
        name = 'Esteban',
        text = {
            "Scored {C:spades}Spades{} and {C:clubs}Clubs{}",
            "cards give {X:mult,C:white}X#1#{} Mult",
            "{C:inactive}(\"*Ignores the kid*\")"
        }
    },
    config = { extra = { xmult = 2.5 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local xmult = (card and card.ability and card.ability.extra and card.ability.extra.xmult) or (self.config and self.config.extra and self.config.extra.xmult) or 2.5
        return { vars = { xmult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Spades') or context.other_card:is_suit('Clubs') then
                return {
                    x_mult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 2.5,
                    card = card
                }
            end
        end
    end
}

-- 2. Thiago
register_secret_joker {
    key = 'thiago',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 1 },
    soul_pos = { x = 1, y = 1 },
    loc_txt = {
        name = 'Thiago',
        text = {
            "Gives {X:mult,C:white}X1{} Mult for every",
            "{C:chips}#1# Chips{} in final hand chips",
            "{C:inactive}(\"Son, Brochacho\")"
        }
    },
    config = { extra = { chips_per_xmult = 20 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local chips_req = (card and card.ability and card.ability.extra and card.ability.extra.chips_per_xmult) or (self.config and self.config.extra and self.config.extra.chips_per_xmult) or 20
        return { vars = { chips_req } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local current_chips = (hand_chips and hand_chips > 0 and hand_chips) or (context.chips and context.chips > 0 and context.chips) or 0
            local chips_req = (card.ability and card.ability.extra and card.ability.extra.chips_per_xmult) or 20
            local xmult = math.floor(current_chips / chips_req)
            if xmult > 1 then
                return {
                    Xmult = xmult,
                    card = card
                }
            end
        end
    end
}

-- 3. Black Hole
register_secret_joker {
    key = 'black_hole_joker',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 2 },
    soul_pos = { x = 1, y = 2 },
    loc_txt = {
        name = 'Black Hole',
        text = {
            "Elevates final {C:chips}Chips{} to the power of {C:chips}^#1#{}",
            "and final {C:mult}Mult{} to the power of {C:mult}^#1#{}"
        }
    },
    config = { extra = { pow = 1.5 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local pow = (card and card.ability and card.ability.extra and card.ability.extra.pow) or (self.config and self.config.extra and self.config.extra.pow) or 1.5
        return { vars = { pow } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local pow = (card.ability and card.ability.extra and card.ability.extra.pow) or 1.5

            if hand_chips and hand_chips > 1 then
                hand_chips = math.floor(hand_chips ^ pow)
            end
            if mult and mult > 1 then
                mult = math.floor(mult ^ pow)
            end

            update_hand_text({ sound = 'chips2', modded = true }, { chips = hand_chips, mult = mult })

            return {
                message = '^' .. tostring(pow) .. '!',
                colour = G.C.DARK_EDITION,
                card = card
            }
        end
    end
}

-- 4. Squele
register_secret_joker {
    key = 'squele',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 3 },
    soul_pos = { x = 1, y = 3 },
    loc_txt = {
        name = 'Squele',
        text = {
            "Scored {C:hearts}Hearts{} cards give {C:mult}+#1#{} Mult",
            "and {X:mult,C:white}X#2#{} Mult.",
            "{C:green}#3# in #4#{} chance to {C:attention}Project{} and create",
            "a {C:dark_edition}Negative{} {C:attention}Bloodstone{}",
            "{C:inactive}(\"I project myself\")"
        }
    },
    config = { extra = { mult = 10, xmult = 1.5, odds = 10 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local mult = (card and card.ability and card.ability.extra and card.ability.extra.mult) or (self.config and self.config.extra and self.config.extra.mult) or 10
        local xmult = (card and card.ability and card.ability.extra and card.ability.extra.xmult) or (self.config and self.config.extra and self.config.extra.xmult) or 1.5
        local odds = (card and card.ability and card.ability.extra and card.ability.extra.odds) or (self.config and self.config.extra and self.config.extra.odds) or 10
        return { vars = { mult, xmult, (G.GAME and G.GAME.probabilities.normal or 1), odds } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit('Hearts') then
            local norm = (G.GAME and G.GAME.probabilities.normal or 1)
            local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 10
            local does_project = pseudorandom('squele_project') < (norm / odds)

            if does_project and not context.blueprint and G.jokers then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local new_j = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_bloodstone', 'squele')
                        new_j:set_edition({ negative = true }, true)
                        new_j:add_to_deck()
                        G.jokers:emplace(new_j)
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Negative Bloodstone!', colour = G.C.DARK_EDITION })
                        return true
                    end
                }))
            end

            return {
                mult = card.ability.extra.mult,
                x_mult = card.ability.extra.xmult,
                card = card
            }
        end
    end
}

-- 5. Bluxdir
register_secret_joker {
    key = 'bluxdir',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 4 },
    soul_pos = { x = 1, y = 4 },
    loc_txt = {
        name = 'Bluxdir',
        text = {
            "When a hand is {C:attention}discarded{},",
            "levels up the discarded {C:attention}poker hand{}",
            "{C:inactive}(\"*Starts farming aura*\")"
        }
    },
    config = {},
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.pre_discard and not context.hook and context.full_hand and #context.full_hand > 0 then
            local text, loc_disp_text, poker_hands, scoring_hand, disp_text = G.FUNCS.get_poker_hand_info(context.full_hand)
            if text and text ~= 'NULL' and G.GAME and G.GAME.hands and G.GAME.hands[text] then
                level_up_hand(card, text, false, 1)
            end
        end
    end
}

-- 6. Charles
register_secret_joker {
    key = 'charles',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 5 },
    soul_pos = { x = 1, y = 5 },
    loc_txt = {
        name = 'Charles',
        text = {
            "Scored {C:spades}Spades{} and {C:hearts}Hearts{} cards",
            "give {X:mult,C:white}X#1#{} Mult.",
            "Earn {C:money}$#2#{} for {C:attention}each scored card{}.",
            "{C:inactive}(\"Homie\")"
        }
    },
    config = { extra = { xmult = 2, dollars = 5 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local xmult = (card and card.ability and card.ability.extra and card.ability.extra.xmult) or (self.config and self.config.extra and self.config.extra.xmult) or 2
        local dollars = (card and card.ability and card.ability.extra and card.ability.extra.dollars) or (self.config and self.config.extra and self.config.extra.dollars) or 5
        return { vars = { xmult, dollars } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if has_charles_and_mochi() then
                return {
                    repetitions = 1,
                    card = card
                }
            end
        end

        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            if has_charles_and_mochi() then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Best Friends!', colour = HEX('ff69b4') })
                        card:juice_up(0.8, 0.8)
                        return true
                    end
                }))
            end
        end

        if context.individual and context.cardarea == G.play then
            local dollars = (card.ability and card.ability.extra and card.ability.extra.dollars) or 5
            local gives_xmult = context.other_card:is_suit('Spades') or context.other_card:is_suit('Hearts')
            local xmult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 2

            if gives_xmult then
                return {
                    x_mult = xmult,
                    dollars = dollars,
                    card = card
                }
            else
                return {
                    dollars = dollars,
                    card = card
                }
            end
        end
    end
}

-- 7. Mochi
register_secret_joker {
    key = 'mochi',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 6 },
    soul_pos = { x = 1, y = 6 },
    loc_txt = {
        name = 'Mochi',
        text = {
            "Scored cards become {C:attention}Wild Cards{}.",
            "Gives {X:mult,C:white}+X#1#{} Mult for each",
            "{C:attention}Wild Card{} in your full deck",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
            "{C:inactive}(\"A drawing for you! :3\")"
        }
    },
    config = { extra = { xmult_gain = 0.25 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local xmult_gain = (card and card.ability and card.ability.extra and card.ability.extra.xmult_gain) or (self.config and self.config.extra and self.config.extra.xmult_gain) or 0.25
        local wild_count = 0
        if G.playing_cards then
            for _, pcard in ipairs(G.playing_cards) do
                if is_wild_card(pcard) then
                    wild_count = wild_count + 1
                end
            end
        end
        local current_xmult = 1.0 + (wild_count * xmult_gain)
        return { vars = { xmult_gain, current_xmult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config and context.other_card.config.center ~= G.P_CENTERS.m_wild then
                context.other_card:set_ability(G.P_CENTERS.m_wild)
                context.other_card:juice_up()
            end
        end

        if context.joker_main then
            local wild_count = 0
            if G.playing_cards then
                for _, pcard in ipairs(G.playing_cards) do
                    if is_wild_card(pcard) then
                        wild_count = wild_count + 1
                    end
                end
            end
            local xmult_gain = (card.ability and card.ability.extra and card.ability.extra.xmult_gain) or 0.25
            local total_xmult = 1.0 + (wild_count * xmult_gain)
            if total_xmult > 1 then
                return {
                    Xmult = total_xmult
                }
            end
        end
    end
}

-- 8. Helin
register_secret_joker {
    key = 'helin',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 7 },
    soul_pos = { x = 1, y = 7 },
    loc_txt = {
        name = 'Helin',
        text = {
            "On {C:attention}first hand{} of round,",
            "elevates final {C:mult}Mult{} to the power of {X:mult,C:white}^#1#{}",
            "{C:inactive}(\"What is the chat sending?\")"
        }
    },
    config = { extra = { power = 2 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local power = (card and card.ability and card.ability.extra and card.ability.extra.power) or (self.config and self.config.extra and self.config.extra.power) or 2
        return { vars = { power } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and G.GAME and G.GAME.current_round and G.GAME.current_round.hands_played == 0 then
            local pow = (card.ability and card.ability.extra and card.ability.extra.power) or 2
            if to_big or type(mult) == 'table' then
                return {
                    e_mult = pow,
                    card = card
                }
            elseif mult and mult > 1 then
                mult = math.floor(mult ^ pow)
                update_hand_text({ sound = 'multhit2', modded = true }, { mult = mult })
                return {
                    message = '^' .. tostring(pow) .. ' Mult!',
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
}

-- 9. RayTracing
register_secret_joker {
    key = 'raytracing',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 8 },
    soul_pos = { x = 1, y = 8 },
    loc_txt = {
        name = 'RayTracing',
        text = {
            "Creates {C:attention}2{} random {C:dark_edition}Negative{}",
            "{C:spectral}Spectral{} cards at end of round",
            "{C:inactive}(Except La Muchachada){}",
            "{C:inactive}(\"Depradosini Negrini\")"
        }
    },
    config = {},
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    local spectral_cards = {}
                    if G.P_CENTER_POOLS and G.P_CENTER_POOLS['Spectral'] then
                        for _, center in ipairs(G.P_CENTER_POOLS['Spectral']) do
                            if center.key ~= 'c_Witch_brew_la_muchachada' and center.key ~= 'c_la_muchachada' and center.key ~= 'la_muchachada' then
                                table.insert(spectral_cards, center.key)
                            end
                        end
                    end
                    for i = 1, 2 do
                        local chosen_spectral = (#spectral_cards > 0) and pseudorandom_element(spectral_cards, 'raytracing_spectral') or 'c_ankh'
                        local new_card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, chosen_spectral, 'raytracing')
                        new_card:set_edition({ negative = true }, true)
                        new_card:add_to_deck()
                        G.consumeables:emplace(new_card)
                    end
                    card_eval_status_text(card, 'extra', nil, nil, nil, { message = '+2 Negative Spectrals!', colour = G.C.DARK_EDITION })
                    card:juice_up(0.6, 0.6)
                    return true
                end
            }))
        end
    end
}

-- 10. Paco
register_secret_joker {
    key = 'paco',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 9 },
    soul_pos = { x = 1, y = 9 },
    loc_txt = {
        name = 'Paco',
        text = {
            "Gives {X:mult,C:white}X#1#{} Mult for each",
            "remaining {C:attention}discard{} you currently have",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}",
            "{C:inactive}(\"No need to discard, every card is useful\")"
        }
    },
    config = { extra = { xmult_per_discard = 2 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local discards = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        local xmult_per_discard = (card and card.ability and card.ability.extra and card.ability.extra.xmult_per_discard) or (self.config and self.config.extra and self.config.extra.xmult_per_discard) or 2
        local total_xmult = math.max(1, discards * xmult_per_discard)
        return { vars = { xmult_per_discard, total_xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local discards = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
            local xmult_per_discard = (card.ability and card.ability.extra and card.ability.extra.xmult_per_discard) or 2
            local total_xmult = discards * xmult_per_discard
            if total_xmult > 1 then
                return {
                    Xmult = total_xmult
                }
            end
        end
    end
}

-- 11. Yairo
register_secret_joker {
    key = 'yairo',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 10 },
    soul_pos = { x = 1, y = 10 },
    loc_txt = {
        name = 'Yairo',
        text = {
            "Scored {C:attention}6s{} and {C:attention}7s{} give {X:mult,C:white}X#1#{} Mult and {X:chips,C:white}X#2#{} Chips.",
            "{C:inactive}(\"67!!!!\")"
        }
    },
    config = { extra = { xmult = 3, xchips = 1.5 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.xmult or 3, ex.xchips or 1.5 } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local id = (context.other_card.get_id and context.other_card:get_id()) or (context.other_card.base and context.other_card.base.id)
            local val = context.other_card.base and context.other_card.base.value
            if id == 6 or id == 7 or val == '6' or val == '7' then
                return {
                    x_mult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 3,
                    x_chips = (card.ability and card.ability.extra and card.ability.extra.xchips) or 1.5,
                    card = card
                }
            end
        end
    end
}

-- 12. Kyra
register_secret_joker {
    key = 'kyra',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 11 },
    soul_pos = { x = 1, y = 11 },
    loc_txt = {
        name = 'Kyra',
        text = {
            "{C:attention}Potions{} take no consumable space.",
            "Pay {C:money}$#1#{} via card button to",
            "brew a random {C:attention}Potion{} card",
            "{C:inactive}(\"I only Help you because you paid me...\")"
        }
    },
    config = { extra = { cost = 2 } },
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local cost = (card and card.ability and card.ability.extra and card.ability.extra.cost) or (self.config and self.config.extra and self.config.extra.cost) or 2
        return { vars = { cost } }
    end,
    calculate = function(self, card, context)
        -- Visual feedback when triggering round end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card:juice_up(0.3, 0.4)
        end
    end
}

-- Spanish localization override for Kyra if game is in Spanish
local orig_init_loc_kyra = init_localization
function init_localization()
    if orig_init_loc_kyra then orig_init_loc_kyra() end
    if G.localization and G.localization.descriptions and G.localization.descriptions.Joker and G.localization.descriptions.Joker.j_Witch_brew_kyra then
        local is_es = (G.SETTINGS and (G.SETTINGS.language == 'es' or G.SETTINGS.language == 'es_419' or G.SETTINGS.language == 'es_ES')) or (G.Witch_brew_SPANISH == true)
        if is_es then
            G.localization.descriptions.Joker.j_Witch_brew_kyra.text = {
                "Las {C:attention}Pociones{} no ocupan espacio.",
                "Paga {C:money}$#1#{} con el botÃ³n para",
                "crear una {C:attention}PociÃ³n{} aleatoria",
                "{C:inactive}(\"I only Help you because you paid me...\")"
            }
            if reparse_localization_entry then
                reparse_localization_entry(G.localization.descriptions.Joker.j_Witch_brew_kyra)
            end
        end
    end
end

-- Kyra Interaction Callbacks & Button Injection
G.FUNCS = G.FUNCS or {}

G.FUNCS.can_pay_kyra = function(e)
    local card = e.config.ref_table
    local cur_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
    -- Kyra allows potions to bypass consumable capacity limits
    if cur_dollars >= 2 and not (card and card.debuff) and not (G.STATE == G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND or G.STATE == G.STATES.PLAY_TAROT) then
        e.config.colour = G.C.GOLD
        e.config.button = 'pay_kyra'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.pay_kyra = function(e)
    local card = e.config.ref_table
    local cur_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
    if cur_dollars >= 2 and G.consumeables then
        ease_dollars(-2)
        play_sound('coin3')
        if card then card:juice_up(0.6, 0.6) end
        G.GAME.consumeable_buffer = (G.GAME.consumeable_buffer or 0) + 1
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.25,
            func = function()
                local new_potion = (create_potion_card_safe and create_potion_card_safe(G.consumeables, 'kyra_brew')) or create_card('Potion', G.consumeables, nil, nil, nil, nil, nil, 'kyra')
                if not new_potion or not new_potion.config then
                    new_potion = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'kyra_fallback')
                end
                new_potion:add_to_deck()
                G.consumeables:emplace(new_potion)
                G.GAME.consumeable_buffer = math.max(0, (G.GAME.consumeable_buffer or 1) - 1)
                new_potion:juice_up(0.6, 0.6)
                card_eval_status_text(card or new_potion, 'extra', nil, nil, nil, { message = 'Potion Ready!', colour = G.C.GREEN })
                return true
            end
        }))
    end
end

local orig_use_and_sell_buttons = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
    local t = orig_use_and_sell_buttons(card)
    if card and card.area and card.area.config and card.area.config.type == 'joker' and card_has_key(card, 'kyra') and not card.debuff then
        local pay_button = {
            n = G.UIT.R,
            config = { align = 'cl' },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { align = "cr" },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                ref_table = card,
                                align = "cr",
                                padding = 0.1,
                                r = 0.08,
                                minw = 1.25,
                                hover = true,
                                shadow = true,
                                colour = G.C.GOLD,
                                one_press = false,
                                button = 'pay_kyra',
                                func = 'can_pay_kyra'
                            },
                            nodes = {
                                { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                                {
                                    n = G.UIT.C,
                                    config = { align = "tm" },
                                    nodes = {
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm", maxw = 1.25 },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "POCIÃ“N", colour = G.C.WHITE, scale = 0.38, shadow = true } }
                                            }
                                        },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm" },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "$2", colour = G.C.WHITE, scale = 0.52, shadow = true } }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if t and t.nodes and t.nodes[1] and t.nodes[1].nodes then
            table.insert(t.nodes[1].nodes, pay_button)
        end
    end
    return t
end

-- Helper to register Amalgam Tier Jokers with Amalgama badge
function register_amalgam_joker(def)
    def.rarity = def.rarity or 4
    def.is_amalgam = true
    def.soul_pos = def.soul_pos or { x = 1, y = (def.pos and def.pos.y) or 0 }
    def.cost = def.cost or 25
    def.in_pool = def.in_pool or function(self, args)
        return false, { allow_duplicates = false }
    end
    def.set_card_type_badge = def.set_card_type_badge or function(self, card, badges)
        badges[1] = create_badge('Amalgam', HEX('8a2be2'), G.C.WHITE, 1.2)
    end
    def.set_badges = def.set_badges or function(self, card, badges)
        if badges and #badges > 0 then
            badges[1] = create_badge('Amalgam', HEX('8a2be2'), G.C.WHITE, 1.2)
        end
    end
    return SMODS.Joker(def)
end

-- Amalgam Joker: Brainprint (Brainstorm + Blueprint)
register_amalgam_joker {
    key = 'brainprint',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 12 },
    soul_pos = { x = 1, y = 12 },
    loc_txt = {
        name = 'Brainprint',
        text = {
            "Copies abilities of both {C:attention}left Joker{}",
            "and {C:attention}right Joker{}",
            "{C:inactive}(\"Two minds, one blueprint\"){}"
        }
    },
    config = {},
    blueprint_compat = false,
    calculate = function(self, card, context)
        if not G.jokers or not G.jokers.cards then return end
        local my_idx = nil
        for idx, j in ipairs(G.jokers.cards) do
            if j == card then my_idx = idx; break end
        end
        if not my_idx then return end

        local left_joker = (my_idx > 1) and G.jokers.cards[my_idx - 1] or nil
        local right_joker = (my_idx < #G.jokers.cards) and G.jokers.cards[my_idx + 1] or nil

        local left_ret = nil
        local right_ret = nil

        -- Copiar Joker Izquierdo
        if left_joker and left_joker ~= card and is_joker_copiable(left_joker) then
            context.blueprint = (context.blueprint or 0) + 1
            context.blueprint_card = card
            left_ret = left_joker:calculate_joker(context)
            context.blueprint = context.blueprint - 1
        end

        -- Copiar Joker Derecho
        if right_joker and right_joker ~= card and is_joker_copiable(right_joker) then
            context.blueprint = (context.blueprint or 0) + 1
            context.blueprint_card = card
            right_ret = right_joker:calculate_joker(context)
            context.blueprint = context.blueprint - 1
        end

        if left_ret and right_ret then
            if type(left_ret) == 'table' and type(right_ret) == 'table' then
                local merged = {}
                for k, v in pairs(left_ret) do merged[k] = v end
                if right_ret.chips then merged.chips = (merged.chips or 0) + right_ret.chips end
                if right_ret.mult then merged.mult = (merged.mult or 0) + right_ret.mult end
                if right_ret.x_mult or right_ret.Xmult then
                    local xm1 = merged.x_mult or merged.Xmult or 1
                    local xm2 = right_ret.x_mult or right_ret.Xmult or 1
                    merged.x_mult = xm1 * xm2
                end
                if right_ret.dollars then merged.dollars = (merged.dollars or 0) + right_ret.dollars end
                merged.card = card
                return merged
            else
                return left_ret
            end
        elseif left_ret then
            if type(left_ret) == 'table' then left_ret.card = card end
            return left_ret
        elseif right_ret then
            if type(right_ret) == 'table' then right_ret.card = card end
            return right_ret
        end
    end
}


-- Amalgam Joker: Vampiric Midas (Midas Mask + Vampire)
register_amalgam_joker {
    key = 'midas_vampirico',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 0 },
    soul_pos = { x = 3, y = 0 },
    loc_txt = {
        name = 'Vampiric Midas',
        text = {
            "When hand is played, converts scored cards",
            "to {C:attention}Gold Cards{}, then absorbs all card enhancements,",
            "gaining {X:mult,C:white}+X#1#{} Mult per enhancement absorbed",
            "{C:inactive}(Preserves seals and editions){}",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_gain = 0.25, xmult = 1.0 } },
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.xmult_gain or 0.25, extra.xmult or 1.0 } }
    end,
    calculate = function(self, card, context)
        if context.blueprint then return nil end

        -- Al jugar la mano: primero convierte a Oro, luego absorbe mejoras (sin tocar sellos ni ediciones)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local cards_to_process = context.scoring_hand or context.full_hand or {}

            -- 1. Coloca el efecto de Oro
            for _, c in ipairs(cards_to_process) do
                if not c.debuff and c.config.center ~= G.P_CENTERS.m_gold then
                    c:set_ability(G.P_CENTERS.m_gold, nil, true)
                    local target = c
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if target then target:juice_up() end
                            return true
                        end
                    }))
                end
            end

            -- 2. Absorbe mejoras (Oro o cualquier otra mejora, preservando sellos y ediciones)
            local absorbed_count = 0
            for _, c in ipairs(cards_to_process) do
                if not c.debuff and c.config.center ~= G.P_CENTERS.c_base then
                    absorbed_count = absorbed_count + 1
                    c:set_ability(G.P_CENTERS.c_base, nil, true)
                    local target = c
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if target then target:juice_up() end
                            return true
                        end
                    }))
                end
            end

            if absorbed_count > 0 then
                card.ability.extra.xmult = (card.ability.extra.xmult or 1.0) + absorbed_count * (card.ability.extra.xmult_gain or 0.25)
                return {
                    message = localize{type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult }},
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        -- Otorga XMult en joker_main al jugarse las cartas
        if context.joker_main and not context.blueprint and (card.ability.extra.xmult or 1.0) > 1 then
            return {
                Xmult = card.ability.extra.xmult,
                card = card
            }
        end
    end
}

-- Amalgam Joker: Certified Programming (Hologram + Certificate)
register_amalgam_joker {
    key = 'programacion_certificacion',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 1 },
    soul_pos = {
        x = 3,
        y = 1,
        draw = function(card, scale_mod, rotate_mod)
            if card.children.floating_sprite then
                scale_mod = scale_mod or (0.07 + 0.02 * math.sin(1.8 * G.TIMERS.REAL))
                rotate_mod = rotate_mod or (0.05 * math.sin(1.219 * G.TIMERS.REAL))
                card.hover_tilt = (card.hover_tilt or 1) * 1.5
                card.children.floating_sprite:draw_shader('hologram', nil, card.ARGS and card.ARGS.send_to_shader, nil, card.children.center, 2 * scale_mod, 2 * rotate_mod)
                card.hover_tilt = (card.hover_tilt or 1.5) / 1.5
            end
        end
    },
    loc_txt = {
        name = 'Certified Programming',
        text = {
            "At start of round, adds {C:attention}2{} random cards with a random",
            "{C:attention}Seal{} and {C:attention}Enhancement{} to hand.",
            "Gains {X:mult,C:white}+X#1#{} Mult whenever any card is added to deck",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_gain = 0.25, xmult = 1.0 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.xmult_gain or 0.25, extra.xmult or 1.0 } }
    end,
    calculate = function(self, card, context)
        -- Añade 2 cartas con sello y mejora al inicio de ronda
        if context.first_hand_drawn then
            local target_card = context.blueprint_card or card
            G.E_MANAGER:add_event(Event({
                func = function()
                    local created_cards = {}
                    for i = 1, 2 do
                        local _card = create_playing_card({
                            front = pseudorandom_element(G.P_CARDS, pseudoseed('cert_fr' .. i)),
                            center = G.P_CENTERS.c_base
                        }, G.hand, nil, i ~= 1, { G.C.SECONDARY_SET.Enhanced })
                        local seals = { 'Red', 'Blue', 'Gold', 'Purple' }
                        local chosen_seal = pseudorandom_element(seals, pseudoseed('cert_seal' .. i))
                        _card:set_seal(chosen_seal, true)
                        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Enhanced then
                            local chosen_enh = pseudorandom_element(G.P_CENTER_POOLS.Enhanced, pseudoseed('cert_enh' .. i))
                            if chosen_enh then _card:set_ability(chosen_enh) end
                        end
                        created_cards[#created_cards + 1] = _card
                    end
                    G.hand:sort()
                    card_eval_status_text(target_card, 'extra', nil, nil, nil, { message = localize('k_plus_card') })
                    if playing_card_joker_effects then
                        playing_card_joker_effects(created_cards)
                    elseif SMODS and SMODS.calculate_context then
                        SMODS.calculate_context({ playing_card_added = true, cards = created_cards })
                    end
                    return true
                end
            }))
        end
        -- Gana +XMult cuando se añade cualquier carta a la baraja
        if context.playing_card_added and not context.blueprint and context.cards and #context.cards > 0 then
            card.ability.extra.xmult = (card.ability.extra.xmult or 1.0) + #context.cards * (card.ability.extra.xmult_gain or 0.25)
            return {
                message = localize{type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult }},
                colour = G.C.RED,
                card = card
            }
        end
        -- Otorga XMult en joker_main
        if context.joker_main and (card.ability.extra.xmult or 1.0) > 1 then
            return {
                Xmult = card.ability.extra.xmult,
                card = card
            }
        end
    end
}

-- Amalgam Joker: Galactic Traveler (Constellation + Astronomer)
register_amalgam_joker {
    key = 'viajero_galactico',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 2 },
    soul_pos = { x = 3, y = 2 },
    loc_txt = {
        name = 'Galactic Traveler',
        text = {
            "Gains {X:mult,C:white}+X#1#{} Mult per {C:planet}Planet{} card used.",
            "All {C:planet}Planet{} cards and {C:planet}Celestial Packs{}",
            "in the shop are {C:attention}free{}.",
            "Doubles sell value of {C:planet}Planet{} cards {C:inactive}($1 -> $2){}",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_gain = 0.25, xmult = 1.0 } },
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.xmult_gain or 0.25, extra.xmult or 1.0 } }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.I and G.I.CARD then
                    for _, v in pairs(G.I.CARD) do
                        if v.set_cost then v:set_cost() end
                    end
                end
                return true
            end
        }))
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.I and G.I.CARD then
                    for _, v in pairs(G.I.CARD) do
                        if v.set_cost then v:set_cost() end
                    end
                end
                return true
            end
        }))
    end,
    calculate = function(self, card, context)
        if context.blueprint then return nil end
        -- Gana +XMult cuando se consume un Planeta
        if context.using_consumeable and not context.blueprint then
            if context.consumeable and context.consumeable.ability and context.consumeable.ability.set == 'Planet' then
                card.ability.extra.xmult = (card.ability.extra.xmult or 1.0) + (card.ability.extra.xmult_gain or 0.25)
                return {
                    message = localize{type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult }},
                    colour = G.C.RED,
                    card = card
                }
            end
        end
        -- Otorga XMult en joker_main
        if context.joker_main and (card.ability.extra.xmult or 1.0) > 1 then
            return {
                Xmult = card.ability.extra.xmult,
                card = card
            }
        end
    end
}

-- Amalgam Joker: Colorful Street (Four Fingers + Shortcut)
register_amalgam_joker {
    key = 'calle_colorida',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 3 },
    soul_pos = { x = 3, y = 3 },
    loc_txt = {
        name = 'Colorful Street',
        text = {
            "All {C:attention}Flushes{} and {C:attention}Straights{} can be made with {C:attention}4 cards{}.",
            "{C:attention}Straights{} may skip {C:attention}1 rank{} {C:inactive}(e.g. 2, 4, 6, 8){}"
        }
    },
    config = {},
    blueprint_compat = false
}

-- Hook find_joker for Galactic Traveler (Astronomer) and Colorful Street (Four Fingers & Shortcut)
local orig_find_joker = find_joker
function find_joker(name, non_debuff)
    local jokers = orig_find_joker and orig_find_joker(name, non_debuff) or {}
    if name == 'Astronomer' then
        if G.jokers and G.jokers.cards then
            for _, v in ipairs(G.jokers.cards) do
                if v and card_has_key(v, 'viajero_galactico') and (non_debuff or not v.debuff) then
                    table.insert(jokers, v)
                end
            end
        end
    elseif name == 'Four Fingers' or name == 'Shortcut' then
        if G.jokers and G.jokers.cards then
            for _, v in ipairs(G.jokers.cards) do
                if v and card_has_key(v, 'calle_colorida') and (non_debuff or not v.debuff) then
                    table.insert(jokers, v)
                end
            end
        end
    end
    return jokers
end

-- Helper & hook Card:set_cost to double sell value of Planet cards for Galactic Traveler
local function has_viajero_galactico()
    if not (G and G.jokers and G.jokers.cards) then return false end
    for _, j in ipairs(G.jokers.cards) do
        if not j.debuff and card_has_key(j, 'viajero_galactico') then
            return true
        end
    end
    return false
end

local orig_card_set_cost = Card.set_cost
function Card:set_cost()
    orig_card_set_cost(self)
    if self.ability and self.ability.set == 'Planet' and has_viajero_galactico() then
        self.sell_cost = math.max(2, (self.sell_cost or 1) * 2)
        self.sell_cost_label = self.sell_cost
    end
end
