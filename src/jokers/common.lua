-- Common Jokers
SMODS.Atlas {
    key = "witch_brew_jokers",
    path = "jokers.png",
    px = 71,
    py = 95
}
-- Masterful Joker
SMODS.Joker {
    key = 'masterful_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Masterful Joker',
        text = {
            "If played hand contains a",
            "{C:attention}Four of a Kind{}, creates a",
            "random {C:tarot}Tarot{} card",
            "{C:inactive}(Must have room){}"
        }
    },
    config = { extra = {} },
    rarity = 1,
    pos = { x = 0, y = 0 },
    cost = 5,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.joker_main and context.poker_hands and context.poker_hands['Four of a Kind'] and next(context.poker_hands['Four of a Kind']) then
            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local new_card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'mas')
                        new_card:add_to_deck()
                        G.consumeables:emplace(new_card)
                        G.GAME.consumeable_buffer = 0
                        return true
                    end
                }))
                return {
                    message = 'Tarot!',
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
}

-- Outstanding Joker
SMODS.Joker {
    key = 'outstanding_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Outstanding Joker',
        text = {
            "Retrigger the {C:attention}highest{}",
            "value card in played",
            "hand {C:attention}1{} time"
        }
    },
    unlock = {
        "Play a",
        "{C:attention}Five of a Kind{}"
    },
    config = { extra = { repetitions = 1 } },
    rarity = 1,
    pos = { x = 1, y = 0 },
    cost = 5,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { (card and card.ability and card.ability.extra and card.ability.extra.repetitions) or 1 } }
    end,
    check_for_unlock = function(self, args)
        if (args.type == 'hand' or args.type == 'play_hand') and (args.handname == 'Five of a Kind' or args.handname == 'Flush Five') then
            return true
        end
        if G.GAME and G.GAME.hands and G.GAME.hands['Five of a Kind'] and (G.GAME.hands['Five of a Kind'].played or 0) > 0 then
            return true
        end
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.scoring_hand and #context.scoring_hand > 0 then
                local highest_card = nil
                local highest_rank = -1
                for _, c in ipairs(context.scoring_hand) do
                    local r = (c.get_id and c:get_id()) or (c.base and c.base.id) or 0
                    if r > highest_rank then
                        highest_rank = r
                        highest_card = c
                    end
                end
                if highest_card and context.other_card == highest_card then
                    return {
                        repetitions = (card.ability.extra and card.ability.extra.repetitions) or 1,
                        card = card
                    }
                end
            end
        end
    end
}

-- Blueberry
SMODS.Joker {
    key = 'blueberry_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Blueberry',
        text = {
            "{C:blue}+1{} Hand when {C:attention}Blind{} is selected.",
            "Self-destructs after {C:attention}#1#{} round#2#{}",
            "{C:inactive}(Art by kars_on_mars){}"
        }
    },
    config = { extra = { hands = 1, rounds_left = 3 } },
    rarity = 1,
    pos = { x = 2, y = 0 },
    cost = 4,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local r = (card and card.ability and card.ability.extra and card.ability.extra.rounds_left) or 3
        return { vars = { r, (r == 1 and '' or 's') } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            ease_hands_played(card.ability.extra.hands)
            return {
                message = '+1 Hand!',
                colour = G.C.BLUE
            }
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left <= 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card:start_dissolve()
                        return true
                    end
                }))
                return {
                    message = 'Expired!',
                    colour = G.C.RED
                }
            else
                return {
                    message = card.ability.extra.rounds_left .. ' left!',
                    colour = G.C.FILTER
                }
            end
        end
    end
}

-- DJ Joker
SMODS.Joker {
    key = 'dj_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'DJ Joker',
        text = {
            "If played hand contains only {C:attention}1 card{},",
            "converts it into a random {C:attention}Lucky{},",
            "{C:attention}Steel{}, {C:attention}Gold{}, or {C:attention}Glass{} card",
            "{C:inactive}(Once per round, #1#){}"
        }
    },
    config = { extra = { used = false } },
    rarity = 1,
    pos = { x = 3, y = 0 },
    cost = 5,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local used = (card and card.ability and card.ability.extra and card.ability.extra.used) or false
        local status_text = used and "Used this round" or "Available"
        return { vars = { status_text } }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.extra = card.ability.extra or {}
            if not card.ability.extra.used then
                local play_count = (context.full_hand and #context.full_hand) or (context.scoring_hand and #context.scoring_hand) or (G.play and G.play.cards and #G.play.cards) or 0
                if play_count == 1 and context.scoring_hand and #context.scoring_hand == 1 then
                    card.ability.extra.used = true
                    local target_card = context.scoring_hand[1]
                    local enhancements = { G.P_CENTERS.m_lucky, G.P_CENTERS.m_steel, G.P_CENTERS.m_gold, G.P_CENTERS.m_glass }
                    local chosen_enh = pseudorandom_element(enhancements, pseudoseed('dj_joker'))
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.2,
                        func = function()
                            play_sound('tarot1')
                            target_card:set_ability(chosen_enh)
                            target_card:juice_up(0.5, 0.5)
                            card:juice_up(0.3, 0.5)
                            card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Remixed!', colour = G.C.SECONDARY_SET.Enhanced })
                            return true
                        end
                    }))
                end
            end
        end

        if (context.end_of_round or context.setting_blind) and not context.individual and not context.repetition and not context.blueprint then
            card.ability.extra = card.ability.extra or {}
            card.ability.extra.used = false
        end
    end
}

-- Designer Joker (Joker Diseñador)
SMODS.Joker {
    key = 'disenador_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Designer Joker',
        text = {
            "Scored {C:attention}Wild Cards{} give {C:money}$#1#{}"
        }
    },
    config = { extra = { dollars = 1 } },
    rarity = 1,
    pos = { x = 4, y = 0 },
    cost = 4,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { (card and card.ability and card.ability.extra and card.ability.extra.dollars) or 1 } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if is_wild_card(context.other_card) then
                local d = (card.ability and card.ability.extra and card.ability.extra.dollars) or 1
                ease_dollars(d)
                return {
                    dollars = d,
                    card = card
                }
            end
        end
    end
}

-- TTS Joker
SMODS.Joker {
    key = 'tts_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'TTS',
        text = {
            "Scored cards give {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult",
            "per letter in their English rank name."
        }
    },
    config = { extra = { chips_per_letter = 4, mult_per_letter = 1 } },
    rarity = 1,
    pos = { x = 5, y = 0 },
    cost = 5,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.chips_per_letter or 4, ex.mult_per_letter or 1 } }
    end,
    calculate = function(self, card, context)
        local rank_names = {
            ['2'] = 'Two', ['3'] = 'Three', ['4'] = 'Four', ['5'] = 'Five', ['6'] = 'Six',
            ['7'] = 'Seven', ['8'] = 'Eight', ['9'] = 'Nine', ['10'] = 'Ten',
            ['Jack'] = 'Jack', ['Queen'] = 'Queen', ['King'] = 'King', ['Ace'] = 'Ace'
        }
        local letter_counts = {
            ['2'] = 3, ['3'] = 5, ['4'] = 4, ['5'] = 4, ['6'] = 3,
            ['7'] = 5, ['8'] = 5, ['9'] = 4, ['10'] = 3,
            ['Jack'] = 4, ['Queen'] = 5, ['King'] = 4, ['Ace'] = 3
        }

        if context.individual and context.cardarea == G.play then
            local val = context.other_card.base and context.other_card.base.value
            local name = rank_names[val] or tostring(val or 'Card')
            local letters = letter_counts[val] or #name
            return {
                chips = letters * (card.ability.extra.chips_per_letter or 4),
                mult = letters * (card.ability.extra.mult_per_letter or 1),
                message = name,
                colour = G.C.MULT,
                card = card
            }
        end
    end
}

-- Joker Descartador (Discarder Joker)
SMODS.Joker {
    key = 'joker_descartador',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Discarder Joker',
        text = {
            "Permanently gains {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult",
            "for each remaining discard",
            "when Blind is defeated.",
            "{C:inactive}(Currently {C:chips}+#3#{C:inactive} Chips, {C:mult}+#4#{C:inactive} Mult){}",
            "{C:inactive}(Resets after defeating a Boss Blind){}"
        }
    },
    config = { extra = { chips_per_discard = 15, mult_per_discard = 2, chips = 0, mult = 0 } },
    rarity = 1,
    pos = { x = 6, y = 0 },
    cost = 4,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.chips_per_discard or 15, ex.mult_per_discard or 2, ex.chips or 0, ex.mult or 0 } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local ex = card.ability.extra or {}
            local chips = ex.chips or 0
            local mult = ex.mult or 0
            if chips > 0 or mult > 0 then
                return {
                    chips = chips,
                    mult = mult,
                    card = card
                }
            end
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local discards = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
            if discards > 0 then
                card.ability.extra.chips = (card.ability.extra.chips or 0) + discards * (card.ability.extra.chips_per_discard or 15)
                card.ability.extra.mult = (card.ability.extra.mult or 0) + discards * (card.ability.extra.mult_per_discard or 2)
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = '+' .. tostring(discards * card.ability.extra.chips_per_discard) .. ' Chips, +' .. tostring(discards * card.ability.extra.mult_per_discard) .. ' Mult!',
                    colour = G.C.CHIPS
                })
            end
            if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                card.ability.extra.chips = 0
                card.ability.extra.mult = 0
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Reset!', colour = G.C.RED })
            end
        end
    end
}

-- Beat It
SMODS.Joker {
    key = 'beat_it',
    atlas = 'witch_brew_jokers',
    pos = { x = 2, y = 5 },
    rarity = 'Witch_brew_song',
    cost = 6,
    blueprint_compat = false,
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge('Song', HEX('d4af37'), G.C.WHITE, 1.2)
    end,
    set_badges = function(self, card, badges)
        if badges and #badges > 0 then
            badges[1] = create_badge('Song', HEX('d4af37'), G.C.WHITE, 1.2)
        end
    end,
    config = { extra = { reduction = 0.5, discards = 1 } },
    loc_txt = {
        name = 'Beat It',
        text = {
            "Reduces required {C:attention}Boss Blind{} score by {C:attention}50%{},",
            "{C:red}-1{} Discard during the Boss Blind",
            "{C:inactive}(\"No one wants to be defeated\"){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint and G.GAME and G.GAME.blind and G.GAME.blind.boss then
            G.GAME.blind.chips = math.floor(G.GAME.blind.chips * 0.5)
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            ease_discard(-1)
            return {
                message = '-50% Boss!',
                colour = G.C.RED,
                card = card
            }
        end
    end
}

