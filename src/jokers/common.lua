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
    end,
}

-- Discard Accumulator
SMODS.Joker {
    key = 'discard_accumulator',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Discard Accumulator',
        text = {
            "Gains {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult",
            "for each discard remaining at end of round",
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
                return { chips = chips, mult = mult, card = card }
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
            "{C:inactive}('No one wants to be defeated'){}"
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

-- Common Jokers, Additional definitions

-- Puppet, Common Joker
SMODS.Joker {
    key = 'puppet_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Puppet',
        text = {
            "At the start of each blind,",
            "{C:attention}swap{} the leftmost card in hand",
            "with a {C:attention}random card{} in your deck"
        }
    },
    config = { extra = {} },
    rarity = 1,
    pos = { x = 0, y = 6 },
    cost = 4,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.drawn_triggered = false
        end
        if (context.first_hand_drawn or (context.setting_blind and not card.ability.extra.drawn_triggered)) and not context.blueprint then
            card.ability.extra.drawn_triggered = true
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.5,
                func = function()
                    if G.hand and G.hand.cards and #G.hand.cards >= 1 and G.deck and G.deck.cards and #G.deck.cards >= 1 then
                        local hand_card = G.hand.cards[1]
                        local swap_target = pseudorandom_element(G.deck.cards, pseudoseed('marioneta'))
                        G.hand:remove_card(hand_card)
                        G.deck:emplace(hand_card)
                        G.deck:remove_card(swap_target)
                        G.hand:emplace(swap_target)
                        hand_card:juice_up(0.3, 0.5)
                        swap_target:juice_up(0.3, 0.5)
                        card:juice_up(0.2, 0.3)
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Swapped!', colour = G.C.ATTENTION })
                    end
                    return true
                end
            }))
        end
    end
}

-- Amnesia, Common Joker
SMODS.Joker {
    key = 'amnesia_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Amnesia',
        text = {
            "During the {C:attention}first hand{} of each blind,",
            "your {C:attention}most played{} hand scores as",
            "your {C:attention}least played{} hand"
        }
    },
    config = { extra = { first_done = false, saved_level = 0, most_key = '', least_key = '' } },
    rarity = 1,
    pos = { x = 1, y = 6 },
    cost = 4,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.first_done = false
            card.ability.extra.saved_level = 0
            card.ability.extra.most_key = ''
            card.ability.extra.least_key = ''
            local most_key, most_count = '', -1
            local least_key, least_count = '', math.huge
            if G.GAME and G.GAME.hands then
                for k, h in pairs(G.GAME.hands) do
                    if h.visible then
                        local p = h.played or 0
                        if p > most_count then most_count = p; most_key = k end
                        if p < least_count then least_count = p; least_key = k end
                    end
                end
            end
            card.ability.extra.most_key = most_key
            card.ability.extra.least_key = least_key
        end
        if context.before and not context.blueprint and not card.ability.extra.first_done then
            local mk = card.ability.extra.most_key
            local lk = card.ability.extra.least_key
            if mk ~= '' and lk ~= '' and mk ~= lk and G.GAME.hands[mk] and G.GAME.hands[lk] then
                card.ability.extra.saved_level = G.GAME.hands[mk].level
                G.GAME.hands[mk].level = G.GAME.hands[lk].level
                card.ability.extra.first_done = true
            end
        end
        if context.after and not context.blueprint and card.ability.extra.first_done and card.ability.extra.saved_level > 0 then
            local mk = card.ability.extra.most_key
            if mk ~= '' and G.GAME.hands[mk] then
                G.GAME.hands[mk].level = card.ability.extra.saved_level
                card.ability.extra.saved_level = 0
            end
        end
    end
}

-- Photographer, Common Joker
SMODS.Joker {
    key = 'photographer_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Photographer',
        text = {
            "The {C:attention}first hand{} played each blind",
            "is captured. Playing the same",
            "hand type again gives {C:mult}+#1#{} Mult",
            "{C:inactive}(Captured: #2#){}"
        }
    },
    config = { extra = { mult = 10, captured = '', first_done = false } },
    rarity = 1,
    pos = { x = 2, y = 6 },
    cost = 4,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        return { vars = { ex.mult or 10, ex.captured ~= '' and ex.captured or 'None' } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.captured = ''
            card.ability.extra.first_done = false
        end
        if context.joker_main then
            local hand_name = context.scoring_name or ''
            if not card.ability.extra.first_done and hand_name ~= '' then
                card.ability.extra.captured = hand_name
                card.ability.extra.first_done = true
                return { message = 'Captured!', colour = G.C.ATTENTION, card = card }
            elseif card.ability.extra.first_done and hand_name == card.ability.extra.captured and hand_name ~= '' then
                return { mult = card.ability.extra.mult, card = card }
            end
        end
    end
}

-- Countdown, Common Joker
-- Unlock: Play exactly 10 cards in a single blind
SMODS.Joker {
    key = 'countdown_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    unlock = { "Play exactly {C:attention}10 cards", "total in a single blind" },
    loc_txt = {
        name = 'Countdown',
        text = {
            "Counter starts at {C:attention}#1#{}.",
            "Each card played reduces it by {C:attention}1{}.",
            "Hit exactly {C:attention}0{} → {X:mult,C:white}X#2#{} Mult.",
            "Exceed 0 → counter {C:attention}resets{}"
        }
    },
    config = { extra = { counter = 10, xmult = 3, cards_this_blind = 0, triggered = false } },
    rarity = 1,
    pos = { x = 3, y = 6 },
    cost = 5,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.counter or 10, ex.xmult or 3 } }
    end,
    check_for_unlock = function(self, args)
        if G.GAME and G.GAME.witch_brew_countdown_cards and G.GAME.witch_brew_countdown_cards >= 10 then
            return true
        end
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.counter = 10
            card.ability.extra.cards_this_blind = 0
            card.ability.extra.triggered = false
            G.GAME.witch_brew_countdown_cards = 0
        end
        if context.before and not context.blueprint then
            local played = (context.full_hand and #context.full_hand) or
                           (G.play and G.play.cards and #G.play.cards) or 0
            card.ability.extra.cards_this_blind = (card.ability.extra.cards_this_blind or 0) + played
            G.GAME.witch_brew_countdown_cards = card.ability.extra.cards_this_blind
            card.ability.extra.counter = card.ability.extra.counter - played
            if card.ability.extra.counter < 0 then
                card.ability.extra.counter = 10
                card.ability.extra.triggered = false
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Reset!', colour = G.C.RED })
            elseif card.ability.extra.counter == 0 then
                card.ability.extra.triggered = true
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'ZERO! X3!', colour = G.C.MULT })
            end
        end
        if context.cardarea == G.jokers and context.joker_main then
            if card.ability.extra.triggered then
                card.ability.extra.triggered = false
                card.ability.extra.counter = 10
                return {
                    x_mult = 3,
                    card = card,
                    message = 'X3 Mult!'
                }
            end
        end
    end
}

-- Smuggler, Common Joker
SMODS.Joker {
    key = 'smuggler_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Smuggler',
        text = {
            "At the start of each blind,",
            "a random card gets a",
            "{C:attention}random enhancement{} (Bonus or Mult)"
        }
    },
    config = { extra = { drawn_triggered = false } },
    rarity = 1,
    pos = { x = 4, y = 6 },
    cost = 4,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.drawn_triggered = false
        end
        if (context.first_hand_drawn or (context.setting_blind and not card.ability.extra.drawn_triggered)) and not context.blueprint then
            card.ability.extra.drawn_triggered = true
            local all_cards = {}
            if G.playing_cards then
                for _, c in ipairs(G.playing_cards) do all_cards[#all_cards + 1] = c end
            end
            if #all_cards > 0 then
                local target = pseudorandom_element(all_cards, pseudoseed('contrabandista'))
                local enhancements = { G.P_CENTERS.m_bonus, G.P_CENTERS.m_mult }
                local enh = pseudorandom_element(enhancements, pseudoseed('contrabandista_enh'))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.5,
                    func = function()
                        target:set_ability(enh)
                        target:juice_up(0.5, 0.5)
                        card:juice_up(0.3, 0.3)
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Smuggled!', colour = G.C.GREEN })
                        return true
                    end
                }))
            end
        end
    end
}

-- Sheet Music, Common Joker
SMODS.Joker {
    key = 'sheet_music_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Sheet Music',
        text = {
            "{C:attention}Straights{} give {C:chips}+#1#{} Chips.",
            "{C:attention}Straight Flushes{} also give {C:mult}+#2#{} Mult"
        }
    },
    config = { extra = { chips = 80, mult = 40 } },
    rarity = 1,
    pos = { x = 5, y = 6 },
    cost = 5,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        return { vars = { ex.chips or 80, ex.mult or 40 } }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main and context.poker_hands then
            local has_sf = (context.poker_hands['Straight Flush'] and next(context.poker_hands['Straight Flush'])) or
                           (context.poker_hands['Royal Flush'] and next(context.poker_hands['Royal Flush']))
            local has_st = context.poker_hands['Straight'] and next(context.poker_hands['Straight'])
            if has_sf then
                return { chips = card.ability.extra.chips or 80, mult = card.ability.extra.mult or 40, card = card }
            elseif has_st then
                return { chips = card.ability.extra.chips or 80, card = card }
            end
        end
    end
}

-- Blood Pact, Common Joker
-- Unlock: Have $50 or more at once
SMODS.Joker {
    key = 'blood_pact_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    unlock = { "Have {C:money}$50{} or more at once" },
    loc_txt = {
        name = 'Blood Pact',
        text = {
            "At the start of each blind,",
            "pay {C:money}$#1#{} to give a random card",
            "a random {C:attention}Edition{} (Foil/Holo/Poly)"
        }
    },
    config = { extra = { cost = 2, drawn_triggered = false } },
    rarity = 1,
    pos = { x = 6, y = 6 },
    cost = 5,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        return { vars = { (card and card.ability.extra.cost) or 2 } }
    end,
    check_for_unlock = function(self, args)
        local dollars = tonumber(G.GAME and G.GAME.dollars) or 0
        return dollars >= 50
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.drawn_triggered = false
        end
        if (context.first_hand_drawn or (context.setting_blind and not card.ability.extra.drawn_triggered)) and not context.blueprint then
            card.ability.extra.drawn_triggered = true
            local dollars = tonumber(G.GAME and G.GAME.dollars) or 0
            local cost = card.ability.extra.cost or 2
            if dollars >= cost then
                ease_dollars(-cost)
                local candidates = {}
                if G.playing_cards then
                    for _, c in ipairs(G.playing_cards) do candidates[#candidates + 1] = c end
                end
                if #candidates > 0 then
                    local target = pseudorandom_element(candidates, pseudoseed('pacto_sangre'))
                    local editions = { 'e_foil', 'e_holo', 'e_polychrome' }
                    local ed = pseudorandom_element(editions, pseudoseed('pacto_sangre_ed'))
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.5,
                        func = function()
                            target:set_edition({ [ed] = true }, true, true)
                            target:juice_up(0.5, 0.5)
                            card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Pact!', colour = G.C.RED })
                            return true
                        end
                    }))
                end
            end
        end
    end
}

-- Saboteur, Common Joker
SMODS.Joker {
    key = 'saboteur_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Saboteur',
        text = {
            "Each round not won in {C:attention}1 hand{},",
            "lose {C:money}$2{} {C:inactive}(cumulative: -$#1#{}){}.",
            "Win in exactly {C:attention}1 hand{} →",
            "recover all debt {C:attention}X1.5{}"
        }
    },
    config = { extra = { debt = 0, hands_played = 0 } },
    rarity = 1,
    pos = { x = 0, y = 7 },
    cost = 5,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        return { vars = { (card and card.ability.extra.debt) or 0 } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hands_played = 0
        end
        if context.before and not context.blueprint then
            card.ability.extra.hands_played = (card.ability.extra.hands_played or 0) + 1
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if (card.ability.extra.hands_played or 0) == 1 then
                local refund = math.floor((card.ability.extra.debt or 0) * 1.5)
                if refund > 0 then
                    ease_dollars(refund)
                    card.ability.extra.debt = 0
                    return { message = '+$'..refund..' Refund!', colour = G.C.MONEY, card = card }
                end
            else
                ease_dollars(-2)
                card.ability.extra.debt = (card.ability.extra.debt or 0) + 2
                return { message = '-$2 Debt', colour = G.C.RED, card = card }
            end
        end
    end
}

-- Boomerang, Common Joker
SMODS.Joker {
    key = 'boomerang_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Boomerang',
        text = {
            "Cards from your {C:attention}first discard{}",
            "of each blind return to hand",
            "on your {C:attention}last hand{}"
        }
    },
    config = { extra = { boomerang_cards = {}, first_discard_done = false, returned = false } },
    rarity = 1,
    pos = { x = 1, y = 7 },
    cost = 5,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.boomerang_cards = {}
            card.ability.extra.first_discard_done = false
            card.ability.extra.returned = false
        end
        if context.discard and not context.blueprint and not card.ability.extra.first_discard_done then
            card.ability.extra.first_discard_done = true
            if context.full_hand then
                for _, c in ipairs(context.full_hand) do
                    card.ability.extra.boomerang_cards[#card.ability.extra.boomerang_cards + 1] = c
                end
            end
            return { message = 'Captured!', colour = G.C.ATTENTION, card = card }
        end
        if (context.before or context.discard) and not context.blueprint then
            local hands_left = (G.GAME and G.GAME.current_round and G.GAME.current_round.hands_left) or 99
            if hands_left <= 1 and not card.ability.extra.returned and #card.ability.extra.boomerang_cards > 0 then
                card.ability.extra.returned = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        for _, bc in ipairs(card.ability.extra.boomerang_cards) do
                            if bc and bc.area and bc.area ~= G.hand then
                                bc.area:remove_card(bc)
                                G.hand:emplace(bc)
                                bc:juice_up(0.5, 0.5)
                            end
                        end
                        card.ability.extra.boomerang_cards = {}
                        card:juice_up(0.3, 0.3)
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Returned!', colour = G.C.BLUE })
                        return true
                    end
                }))
            end
        end
    end
}

-- Spy, Common Joker
SMODS.Joker {
    key = 'spy_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Spy',
        text = {
            "At the start of each blind,",
            "{C:attention}3 random cards{} from your deck",
            "are added directly to your hand"
        }
    },
    config = { extra = { count = 3, drawn_triggered = false } },
    rarity = 1,
    pos = { x = 2, y = 7 },
    cost = 5,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.drawn_triggered = false
        end
        if (context.first_hand_drawn or (context.setting_blind and not card.ability.extra.drawn_triggered)) and not context.blueprint then
            card.ability.extra.drawn_triggered = true
            local n = card.ability.extra.count or 3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.5,
                func = function()
                    local drawn = 0
                    if G.deck and G.deck.cards and G.hand then
                        local deck_copy = {}
                        for _, c in ipairs(G.deck.cards) do deck_copy[#deck_copy+1] = c end
                        for i = #deck_copy, math.max(1, #deck_copy - n + 1), -1 do
                            local c = deck_copy[i]
                            if c and drawn < n then
                                G.deck:remove_card(c)
                                G.hand:emplace(c)
                                c:juice_up(0.3, 0.3)
                                drawn = drawn + 1
                            end
                        end
                    end
                    if drawn > 0 then
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Scouted!', colour = G.C.ATTENTION })
                    end
                    return true
                end
            }))
        end
    end
}

-- Apprentice, Common Joker
-- Unlock: Tener 4 Jokers simultáneamente
SMODS.Joker {
    key = 'apprentice_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    unlock = { "Own {C:attention}4 Jokers{} at the same time" },
    loc_txt = {
        name = 'Apprentice',
        text = {
            "Counts activations of the",
            "{C:attention}adjacent Joker{} {C:inactive}(#1#/10){}.",
            "At {C:attention}10{}, becomes a copy",
            "of that Joker permanently"
        }
    },
    config = { extra = { count = 0, watching = '' } },
    rarity = 1,
    pos = { x = 3, y = 7 },
    cost = 5,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        return { vars = { (card and card.ability.extra.count) or 0 } }
    end,
    check_for_unlock = function(self, args)
        local n = G.jokers and G.jokers.cards and #G.jokers.cards or 0
        return n >= 4
    end,
    calculate = function(self, card, context)
        if context.joker_main and not context.blueprint then
            local my_pos = nil
            if G.jokers and G.jokers.cards then
                for i, jk in ipairs(G.jokers.cards) do
                    if jk == card then my_pos = i; break end
                end
            end
            local adjacent = nil
            if my_pos then
                adjacent = G.jokers.cards[my_pos - 1] or G.jokers.cards[my_pos + 1]
            end
            if adjacent and adjacent ~= card then
                local adj_key = adjacent.config and adjacent.config.center and adjacent.config.center.key or ''
                if adj_key ~= card.ability.extra.watching then
                    card.ability.extra.watching = adj_key
                    card.ability.extra.count = 0
                end
                card.ability.extra.count = (card.ability.extra.count or 0) + 1
                if card.ability.extra.count >= 10 then
                    local target_center = adjacent.config and adjacent.config.center
                    if target_center then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                play_sound('tarot1')
                                card:start_dissolve()
                                local new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, target_center.key, 'apr')
                                new_joker:add_to_deck()
                                G.jokers:emplace(new_joker)
                                return true
                            end
                        }))
                        return { message = 'Mastered!', colour = G.C.GOLD, card = card }
                    end
                end
                return { message = (card.ability.extra.count)..'/10', colour = G.C.ATTENTION, card = card }
            end
        end
    end
}

-- Upgrade Roulette, Common Joker
SMODS.Joker {
    key = 'upgrade_roulette_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Upgrade Roulette',
        text = {
            "End of each blind: a {C:attention}random card{}",
            "gains the next enhancement tier",
            "{C:inactive}(Base→Bonus→Mult→Wild→Lucky→Glass→Steel→Gold){}"
        }
    },
    config = { extra = {} },
    rarity = 1,
    pos = { x = 4, y = 7 },
    cost = 5,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local chain = { 'm_bonus', 'm_mult', 'm_wild', 'm_lucky', 'm_glass', 'm_steel', 'm_gold' }
            local function get_next(c)
                local cur = c.config and c.config.center and c.config.center.key
                if not cur or cur == 'c_base' then return 'm_bonus' end
                for i, k in ipairs(chain) do
                    if k == cur then return chain[i + 1] end
                end
                return nil
            end
            local candidates = {}
            if G.playing_cards then
                for _, c in ipairs(G.playing_cards) do
                    if get_next(c) then candidates[#candidates + 1] = c end
                end
            end
            if #candidates > 0 then
                local target = pseudorandom_element(candidates, pseudoseed('ruleta_mejoras'))
                local nxt = get_next(target)
                if nxt and G.P_CENTERS[nxt] then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target:set_ability(G.P_CENTERS[nxt])
                            target:juice_up(0.5, 0.5)
                            card:juice_up(0.3, 0.3)
                            return true
                        end
                    }))
                    return { message = 'Upgraded!', colour = G.C.SECONDARY_SET.Enhanced, card = card }
                end
            end
        end
    end
}

-- Reversed Hermit, Common Joker
-- Unlock: Ganar una ciega sin usar descarte
SMODS.Joker {
    key = 'reversed_hermit_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    unlock = { "Win a blind without", "using any {C:attention}discards{}" },
    loc_txt = {
        name = 'Reversed Hermit',
        text = {
            "At end of round, earn",
            "{C:money}$#1#{} for each remaining {C:attention}discard{}",
            "{C:inactive}(Currently {C:money}+$#2#{C:inactive}){}"
        }
    },
    config = { extra = { dollars_per_discard = 2 } },
    rarity = 1,
    pos = { x = 5, y = 7 },
    cost = 5,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local d_left = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        local rate = ex.dollars_per_discard or 2
        return { vars = { rate, d_left * rate } }
    end,
    check_for_unlock = function(self, args)
        if G.GAME and G.GAME.witch_brew_no_discard_win then
            return true
        end
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            G.GAME.witch_brew_no_discard_win = false
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local discards_used = 0
            if G.GAME and G.GAME.current_round then
                local max_d = G.GAME.current_round.discards_used or 0
                discards_used = max_d
            end
            local discards_left = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
            if discards_used == 0 then
                G.GAME.witch_brew_no_discard_win = true
            end
            if discards_left > 0 then
                local rate = (card.ability and card.ability.extra and card.ability.extra.dollars_per_discard) or 2
                local dollars = discards_left * rate
                if dollars > 0 then
                    ease_dollars(dollars)
                    return { message = '+$'..dollars, colour = G.C.MONEY, card = card }
                end
            end
        end
    end
}

-- Playbook, Common Joker
-- Unlock: Jugar 3 tipos diferentes de mano en la misma ciega
SMODS.Joker {
    key = 'script_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    unlock = { "Play {C:attention}3 different hand types{}", "in a single blind" },
    loc_txt = {
        name = 'Script',
        text = {
            "A script of {C:attention}3 hand types{} is set",
            "each blind. Play them in order",
            "to earn {C:money}+$#1#{} at round end.",
            "{C:inactive}(#2# -> #3# -> #4#){}"
        }
    },
    config = { extra = { reward = 12, script = {}, progress = 0, completed = false } },
    rarity = 1,
    pos = { x = 6, y = 7 },
    cost = 4,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        local s = ex.script or {}
        return { vars = { ex.reward or 12, s[1] or '?', s[2] or '?', s[3] or '?' } }
    end,
    check_for_unlock = function(self, args)
        if G.GAME and G.GAME.witch_brew_diff_hands and G.GAME.witch_brew_diff_hands >= 3 then
            return true
        end
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.progress = 0
            card.ability.extra.completed = false
            G.GAME.witch_brew_diff_hands = 0
            G.GAME.witch_brew_hands_seen = {}
            local hand_list = {}
            if G.GAME and G.GAME.hands then
                for k, h in pairs(G.GAME.hands) do
                    if h.visible then
                        hand_list[#hand_list+1] = { key = k, played = h.played or 0 }
                    end
                end
            end
            table.sort(hand_list, function(a, b) return a.played > b.played end)
            local script = {}
            for i = 1, math.min(3, #hand_list) do script[i] = hand_list[i].key end
            -- shuffle
            for i = #script, 2, -1 do
                local j = math.floor(pseudorandom('libreto_shuf') * i) + 1
                script[i], script[j] = script[j], script[i]
            end
            card.ability.extra.script = script
        end
        if context.joker_main and not context.blueprint then
            local hand_name = context.scoring_name or ''
            -- Unlock tracking
            if hand_name ~= '' then
                G.GAME.witch_brew_hands_seen = G.GAME.witch_brew_hands_seen or {}
                if not G.GAME.witch_brew_hands_seen[hand_name] then
                    G.GAME.witch_brew_hands_seen[hand_name] = true
                    G.GAME.witch_brew_diff_hands = (G.GAME.witch_brew_diff_hands or 0) + 1
                end
            end
            if not card.ability.extra.completed then
                local prog = card.ability.extra.progress or 0
                local script = card.ability.extra.script or {}
                if prog < 3 and script[prog + 1] == hand_name then
                    card.ability.extra.progress = prog + 1
                    if card.ability.extra.progress == 3 then
                        card.ability.extra.completed = true
                        return { message = 'Script Done!', colour = G.C.GOLD, card = card }
                    else
                        return { message = card.ability.extra.progress..'/3', colour = G.C.ATTENTION, card = card }
                    end
                elseif prog > 0 and (script[prog + 1] ~= hand_name) then
                    card.ability.extra.progress = 0
                end
            end
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if card.ability.extra.completed then
                local reward = card.ability.extra.reward or 12
                ease_dollars(reward)
                card.ability.extra.completed = false
                return { message = '+$'..reward..'!', colour = G.C.MONEY, card = card }
            end
        end
    end
}
