-- Rare Jokers

-- Doctor Jo.
SMODS.Joker {
    key = 'doctor_jo_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Doctor Jo.',
        text = {
            "Removes {C:attention}debuffs{} from all Jokers.",
            "Cures {C:attention}Perishable{} Jokers into clean copies.",
            "If round is not won on final hand: grants",
            "{C:blue}+1 Hand{} {C:inactive}(1 per Blind){}"
        }
    },
    config = { extra = { defibrillator_used = false } },
    rarity = 3,
    pos = { x = 0, y = 3 },
    cost = 8,
    blueprint_compat = false,
    calculate = function(self, card, context)
        card.ability.extra = card.ability.extra or {}

        -- Start of shop or round: heal debuffs and reset defib
        if (context.starting_shop or context.setting_blind) and not context.blueprint then
            card.ability.extra.defibrillator_used = false
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    if j.debuff then
                        j.debuff = false
                        j.debuffed_by_blind = nil
                        if j.set_debuff then j:set_debuff(false) end
                    end
                end
            end
        end

        -- Cure Perishable Jokers: replace perishable copy with 1 clean copy
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.defibrillator_used = false
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    if j ~= card and (j.perishable or (j.ability and j.ability.perishable)) and not j.cured_by_doctor_jo and not j.sold and not j.dissolving then
                        j.cured_by_doctor_jo = true
                        local target_j = j
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.3,
                            func = function()
                                if not target_j or target_j.sold or not target_j.area or target_j.area ~= G.jokers then
                                    return true
                                end
                                if not card or card.sold or not card.area or card.area ~= G.jokers then
                                    return true
                                end

                                play_sound('tarot1')
                                local j_key = (target_j.config and target_j.config.center and target_j.config.center.key) or (target_j.config and target_j.config.center_key)
                                local j_ed = target_j.edition
                                target_j:start_dissolve()
                                G.jokers:remove_card(target_j)

                                local clean_j = create_card('Joker', G.jokers, nil, nil, nil, nil, j_key, 'doctor_jo')
                                if clean_j.set_perishable then
                                    clean_j:set_perishable(false)
                                end
                                clean_j.perishable = nil
                                if clean_j.ability then
                                    clean_j.ability.perishable = nil
                                    clean_j.ability.perish_tally = nil
                                end
                                clean_j.cured_by_doctor_jo = true

                                if j_ed then clean_j:set_edition(j_ed, true) end
                                clean_j:add_to_deck()
                                G.jokers:emplace(clean_j)
                                clean_j:juice_up(0.6, 0.6)
                                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Perishable Cured!', colour = G.C.GREEN })
                                return true
                            end
                        }))
                    end
                end
            end
        end

        -- Emergency Defibrillator: Only grants +1 hand if not winning the round on final hand
        if context.after and not context.blueprint and G.GAME.chips < G.GAME.blind.chips then
            if G.GAME.current_round and G.GAME.current_round.hands_left == 0 and not card.ability.extra.defibrillator_used then
                card.ability.extra.defibrillator_used = true
                ease_hands_played(1)
                play_sound('tarot1')
                if G.jokers and G.jokers.cards then
                    for _, j in ipairs(G.jokers.cards) do
                        if j.debuff then
                            j.debuff = false
                            if j.set_debuff then j:set_debuff(false) end
                        end
                    end
                end
                return {
                    message = 'CLEAR! +1 Hand',
                    colour = G.C.RED
                }
            end
        end
    end
}

-- Symmetrical Joker
SMODS.Joker {
    key = 'symmetrical_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Symmetrical Joker',
        text = {
            "{X:mult,C:white}X#1#{} Mult if played {C:attention}Four or Five of a Kind{}",
            "shares the same suit across all scoring cards"
        }
    },
    config = { extra = { xmult = 4.0 } },
    rarity = 3,
    pos = { x = 1, y = 3 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and context.scoring_hand and context.poker_hands then
            local is_poker = (context.poker_hands['Four of a Kind'] and next(context.poker_hands['Four of a Kind'])) or
                             (context.poker_hands['Five of a Kind'] and next(context.poker_hands['Five of a Kind'])) or
                             (context.poker_hands['Flush Five'] and next(context.poker_hands['Flush Five']))
            if is_poker then
                local first_suit = context.scoring_hand[1] and context.scoring_hand[1].base and context.scoring_hand[1].base.suit
                local same_suit = true
                for _, pcard in ipairs(context.scoring_hand) do
                    if not pcard.base or pcard.base.suit ~= first_suit then
                        same_suit = false
                        break
                    end
                end
                if same_suit then
                    return {
                        Xmult = card.ability.extra.xmult
                    }
                end
            end
        end
    end
}

-- Balance
SMODS.Joker {
    key = 'balance_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Balance',
        text = {
            "Creates {C:spectral}#2# Spectral cards{} if played",
            "{C:attention}Four of a Kind{} has all cards of the same suit",
            "{C:inactive}(Must have room){}"
        }
    },
    config = { extra = { cards_needed = 4, spectral_count = 2 } },
    rarity = 3,
    pos = { x = 2, y = 3 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cards_needed, card.ability.extra.spectral_count } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and context.poker_hands and context.poker_hands['Four of a Kind'] and next(context.poker_hands['Four of a Kind']) then
            if context.scoring_hand and #context.scoring_hand == 4 then
                local same_suit = false
                local suits = {'Hearts', 'Diamonds', 'Spades', 'Clubs'}
                for _, suit in ipairs(suits) do
                    local matches_all = true
                    for _, pcard in ipairs(context.scoring_hand) do
                        if not pcard:is_suit(suit) then
                            matches_all = false
                            break
                        end
                    end
                    if matches_all then
                        same_suit = true
                        break
                    end
                end

                if same_suit then
                    local count = (card.ability and card.ability.extra and card.ability.extra.spectral_count) or 1
                    local free_slots = math.max(0, G.consumeables.config.card_limit - (#G.consumeables.cards + (G.GAME.consumeable_buffer or 0)))
                    local to_create = math.min(count, free_slots)
                    if to_create > 0 then
                        G.GAME.consumeable_buffer = (G.GAME.consumeable_buffer or 0) + to_create
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                for i = 1, to_create do
                                    local spectral_card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'balance')
                                    spectral_card:add_to_deck()
                                    G.consumeables:emplace(spectral_card)
                                    G.GAME.consumeable_buffer = math.max(0, (G.GAME.consumeable_buffer or 1) - 1)
                                end
                                return true
                            end
                        }))
                        return {
                            message = 'Balance!',
                            colour = G.C.SECONDARY_SET.Spectral
                        }
                    end
                end
            end
        end
    end
}

-- Merchant
SMODS.Joker {
    key = 'merchant_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Merchant',
        text = {
            "+1 card slot, +1 voucher, +1 pack, and 25% discount in shop.",
            "Lose {C:money}$#1#{} upon leaving shop"
        },
        unlock = {
            "Enter a shop with at least {C:money}$50{}",
            "and leave with {C:money}$10{} or less"
        }
    },
    config = { extra = { cost_per_shop = 5 } },
    rarity = 3,
    pos = { x = 3, y = 3 },
    cost = 6,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cost_per_shop } }
    end,
    check_for_unlock = function(self, args)
        if args.type == 'leave_shop' or args.type == 'ending_shop' then
            local entered = (to_number and to_number(G.GAME and G.GAME.entered_shop_dollars)) or tonumber(G.GAME and G.GAME.entered_shop_dollars) or 0
            local current = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
            if G.GAME and G.GAME.entered_shop_dollars and entered >= 50 and current <= 10 then
                return true
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.shop.joker_max = (G.GAME.shop.joker_max or 2) + 1
        G.GAME.modifiers.extra_vouchers = (G.GAME.modifiers.extra_vouchers or 0) + 1
        G.GAME.modifiers.extra_packs = (G.GAME.modifiers.extra_packs or 0) + 1
        G.GAME.discount_percent = (G.GAME.discount_percent or 0) + 25
        G.GAME.merchant_rare_boost = (G.GAME.merchant_rare_boost or 0) + 1
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.shop.joker_max = math.max(1, (G.GAME.shop.joker_max or 3) - 1)
        G.GAME.modifiers.extra_vouchers = math.max(0, (G.GAME.modifiers.extra_vouchers or 0) - 1)
        G.GAME.modifiers.extra_packs = math.max(0, (G.GAME.modifiers.extra_packs or 0) - 1)
        G.GAME.discount_percent = math.max(0, (G.GAME.discount_percent or 0) - 25)
        G.GAME.merchant_rare_boost = math.max(0, (G.GAME.merchant_rare_boost or 0) - 1)
    end,
    calculate = function(self, card, context)
        if context.ending_shop then
            ease_dollars(-card.ability.extra.cost_per_shop)
            return {
                message = '-$' .. card.ability.extra.cost_per_shop,
                colour = G.C.MONEY
            }
        end
    end
}

-- Lover
SMODS.Joker {
    key = 'lover_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Lover',
        text = {
            "Bonds 2 cards as {C:attention}Soulmates{}: drawing one draws partner.",
            "Scoring both gives {X:mult,C:white}X#1#{} Mult, {C:money}+$#2#{}, and permanent {C:chips}+#3#{} Chips.",
            "Scored {C:hearts}Hearts{} give {C:mult}+#4#{} Mult",
            "{C:inactive}(Soulmates: #5# and #6#){}"
        }
    },
    unlock = {
        "Play a {C:attention}Flush{} of all 4 suits",
        "{C:inactive}(Hearts, Spades, Clubs, Diamonds){}",
        "in a single run"
    },
    config = { extra = { xmult = 3.0, dollars = 6, perma_chips = 10, heart_mult = 10 } },
    rarity = 3,
    pos = { x = 4, y = 3 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local sm1, sm2 = get_or_pick_soulmates()
        local sm1_str = format_soulmate_card_name(sm1)
        local sm2_str = format_soulmate_card_name(sm2)
        return { vars = { ex.xmult, ex.dollars, ex.perma_chips, ex.heart_mult, sm1_str, sm2_str } }
    end,
    check_for_unlock = check_all_suits_flushed_unlock,
    add_to_deck = function(self, card, from_debuff)
        get_or_pick_soulmates()
    end,
    calculate = function(self, card, context)
        -- Ensure soulmates exist
        if (context.setting_blind or context.first_hand_drawn) and not context.blueprint then
            get_or_pick_soulmates()
        end

        -- Soulmate summon: If 1 in hand and 1 in deck, draw missing partner
        if (context.first_hand_drawn or context.before) and not context.blueprint then
            local in_hand = {}
            local in_deck = {}
            if G.hand and G.hand.cards then
                for _, c in ipairs(G.hand.cards) do
                    if c.ability and c.ability.is_soulmate then table.insert(in_hand, c) end
                end
            end
            if #in_hand == 1 and G.deck and G.deck.cards then
                for _, c in ipairs(G.deck.cards) do
                    if c.ability and c.ability.is_soulmate then table.insert(in_deck, c) end
                end
                if #in_deck >= 1 then
                    local partner = in_deck[1]
                    draw_card(G.deck, G.hand, 1, 'up', nil, partner)
                    return {
                        message = 'Soulmates Reunited!',
                        colour = G.C.HEARTS
                    }
                end
            end
        end

        -- Individual Hearts mult
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Hearts') then
                return {
                    mult = card.ability.extra.heart_mult,
                    card = card
                }
            end
        end

        -- Both soulmates score in the same hand!
        if context.joker_main and context.scoring_hand then
            local soulmates_scored = {}
            for _, sc in ipairs(context.scoring_hand) do
                if sc.ability and sc.ability.is_soulmate then
                    table.insert(soulmates_scored, sc)
                end
            end
            if #soulmates_scored >= 2 then
                if not context.blueprint then
                    for _, sm in ipairs(soulmates_scored) do
                        sm.ability = sm.ability or {}
                        sm.ability.perma_bonus = (sm.ability.perma_bonus or 0) + card.ability.extra.perma_chips
                    end
                end
                return {
                    Xmult = card.ability.extra.xmult,
                    dollars = card.ability.extra.dollars,
                    message = 'TRUE LOVE! X' .. card.ability.extra.xmult,
                    colour = G.C.HEARTS
                }
            end
        end
    end
}

-- Blacksmith
SMODS.Joker {
    key = 'blacksmith_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Blacksmith',
        text = {
            "Played cards add {C:attention}+#1#{} Heat to the forge.",
            "At {C:attention}#2# Heat{}, strikes the anvil: {C:green}#4# in #5#{} chance",
            "to apply a {C:attention}Silver Seal{} or {C:attention}Steel Card{} enhancement",
            "to the highest scored card and cools to 0 {C:inactive}(Current: #3#/#2# Heat){}"
        }
    },
    unlock = {
        "Play a {C:attention}Flush{} of all 4 suits",
        "{C:inactive}(Hearts, Spades, Clubs, Diamonds){}",
        "in a single run"
    },
    config = { extra = { temp = 0, heat_per_card = 10, max_temp = 100 } },
    rarity = 3,
    pos = { x = 5, y = 3 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        if info_queue then
            local silver_seal = (G.P_SEALS and (G.P_SEALS['Witch_brew_silver'] or G.P_SEALS['silver'])) or { set = 'Seal', key = 'silver' }
            info_queue[#info_queue + 1] = silver_seal
            info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
        end
        local current_temp = ex.temp or 0
        local max_temp = ex.max_temp or 100
        local heat_per_card = ex.heat_per_card or 10
        return { vars = { heat_per_card, max_temp, current_temp, (G.GAME and G.GAME.probabilities.normal or 1), 2 } }
    end,
    check_for_unlock = check_all_suits_flushed_unlock,
    calculate = function(self, card, context)
        if context.before and not context.blueprint and context.scoring_hand and #context.scoring_hand > 0 then
            local heat_gain = (card.ability and card.ability.extra and card.ability.extra.heat_per_card) or 10
            local total_gain = #context.scoring_hand * heat_gain
            card.ability.extra.temp = (card.ability.extra.temp or 0) + total_gain
            return {
                message = '+' .. total_gain .. ' Heat!',
                colour = G.C.ORANGE,
                card = card
            }
        end

        if context.joker_main and not context.blueprint then
            local current_temp = (card.ability and card.ability.extra and card.ability.extra.temp) or 0
            local max_temp = (card.ability and card.ability.extra and card.ability.extra.max_temp) or 100

            if current_temp >= max_temp and context.scoring_hand and #context.scoring_hand >= 1 then
                local highest_card = context.scoring_hand[1]
                local highest_rank = -1
                for _, sc in ipairs(context.scoring_hand) do
                    local r = sc:get_id() or 0
                    if r > highest_rank then
                        highest_rank = r
                        highest_card = sc
                    end
                end

                if highest_card then
                    play_sound('gold_seal')
                    card.ability.extra.temp = 0
                    local prob = (G.GAME and G.GAME.probabilities.normal or 1)
                    local is_seal = pseudorandom('blacksmith_reward') < (prob / 2)
                    if is_seal then
                        local silver_key = (G.P_SEALS and (G.P_SEALS['Witch_brew_silver'] and 'Witch_brew_silver' or G.P_SEALS['Witch brew_silver'] and 'Witch brew_silver' or G.P_SEALS['silver'] and 'silver')) or 'Witch_brew_silver'
                        highest_card:set_seal(silver_key, nil, true)
                        highest_card:juice_up(0.8, 0.8)
                        return {
                            message = 'Silver Seal Forged!',
                            colour = HEX('bdc3c7')
                        }
                    else
                        highest_card:set_ability(G.P_CENTERS.m_steel)
                        highest_card:juice_up(0.8, 0.8)
                        return {
                            message = 'Steel Card Forged!',
                            colour = G.C.GREY
                        }
                    end
                end
            end
        end
    end
}

-- Lucky One
SMODS.Joker {
    key = 'lucky_one_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Lucky One',
        text = {
            "Every {C:attention}5{} scored {C:clubs}Clubs{}, the next",
            "{C:green}probability{} is guaranteed {C:green}(1 in 1){}.",
            "{C:inactive}(#2#/5 Clubs, #3# - Resets at end of round){}",
            "Gains {X:mult,C:white}+X#1#{} Mult when any probability succeeds",
            "{C:inactive}(Currently {X:mult,C:white}X#4#{C:inactive} Mult){}"
        }
    },
    unlock = {
        "Play a {C:attention}Flush{} of all 4 suits",
        "{C:inactive}(Hearts, Spades, Clubs, Diamonds){}",
        "in a single run"
    },
    config = { extra = { xmult = 1.5, xmult_gain = 0.1, clubs_scored = 0, clubs_needed = 5, guaranteed = false } },
    rarity = 3,
    pos = { x = 6, y = 3 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local status = (ex and ex.guaranteed) and "Guaranteed!" or "Pending"
        return { vars = { ex.xmult_gain or 0.1, ex.clubs_scored or 0, status, ex.xmult or 1.5 } }
    end,
    check_for_unlock = check_all_suits_flushed_unlock,
    calculate = function(self, card, context)
        card.ability.extra = card.ability.extra or {}

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:is_suit('Clubs') then
                card.ability.extra.clubs_scored = (card.ability.extra.clubs_scored or 0) + 1
                if card.ability.extra.clubs_scored >= (card.ability.extra.clubs_needed or 5) then
                    card.ability.extra.clubs_scored = 0
                    card.ability.extra.guaranteed = true
                    if G.GAME then G.GAME.lucky_one_guaranteed = true end
                    return {
                        message = 'Guaranteed Next!',
                        colour = G.C.GREEN,
                        card = card
                    }
                else
                    return {
                        message = 'Club ' .. card.ability.extra.clubs_scored .. '/5',
                        colour = G.C.CLUBS,
                        card = card
                    }
                end
            end
        end

        if context.individual and context.other_card and context.other_card.lucky_trigger and not context.blueprint then
            card.ability.extra.xmult = (card.ability.extra.xmult or 1.5) + (card.ability.extra.xmult_gain or 0.1)
            return {
                extra = { focus = card, message = '+X' .. (card.ability.extra.xmult_gain or 0.1) .. ' Mult!', colour = G.C.MULT },
                card = card
            }
        end

        if context.joker_main then
            return {
                Xmult = card.ability.extra.xmult or 1.5
            }
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.clubs_scored = 0
            card.ability.extra.guaranteed = false
            if G.GAME then G.GAME.lucky_one_guaranteed = false end
        end
    end
}

-- Miner
SMODS.Joker {
    key = 'miner_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Miner',
        text = {
            "Scored {C:diamonds}Diamonds{} dig 1m deeper {C:inactive}(Max 1000m, Current: #2#m){}:",
            "0-50m: {C:chips}+25{} Chips | 50-120m: {C:money}+$2{} | 120-300m: {X:mult,C:white}X1.35{} Mult",
            "300m+: {X:mult,C:white}X1.5{} Mult, retriggers, and extracts a {C:spectral}Spectral{} card at round end"
        }
    },
    unlock = {
        "Play a {C:attention}Flush{} of all 4 suits",
        "{C:inactive}(Hearts, Spades, Clubs, Diamonds){}",
        "in a single run"
    },
    config = { extra = { depth = 0, depth_per_card = 1, max_depth = 1000 } },
    rarity = 3,
    pos = { x = 0, y = 4 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local d = ex.depth or 0
        return { vars = { ex.depth_per_card or 1, d } }
    end,
    check_for_unlock = check_all_suits_flushed_unlock,
    calculate = function(self, card, context)
        -- Depth retrigger in Magma Core
        if context.repetition and context.cardarea == G.play then
            if context.other_card:is_suit('Diamonds') and (card.ability.extra.depth or 0) >= 300 then
                return {
                    repetitions = 1,
                    card = card
                }
            end
        end

        -- Individual stratum bonuses
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Diamonds') then
                if not context.blueprint and not context.repetition then
                    card.ability.extra.depth = math.min(1000, (card.ability.extra.depth or 0) + (card.ability.extra.depth_per_card or 1))
                end
                local d = card.ability.extra.depth or 0
                if d < 50 then
                    return {
                        chips = 25,
                        card = card
                    }
                elseif d < 120 then
                    return {
                        dollars = 2,
                        card = card
                    }
                elseif d < 300 then
                    return {
                        x_mult = 1.35,
                        card = card
                    }
                else
                    return {
                        x_mult = 1.5,
                        card = card
                    }
                end
            end
        end

        -- Round end core extraction
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if (card.ability.extra.depth or 0) >= 300 then
                if #G.consumeables.cards + (G.GAME.consumeable_buffer or 0) < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = (G.GAME.consumeable_buffer or 0) + 1
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('tarot1')
                            local sc = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'miner_core')
                            sc:add_to_deck()
                            G.consumeables:emplace(sc)
                            G.GAME.consumeable_buffer = math.max(0, (G.GAME.consumeable_buffer or 1) - 1)
                            sc:juice_up(0.6, 0.6)
                            return true
                        end
                    }))
                    return {
                        message = 'Core Gem Extracted!',
                        colour = G.C.SECONDARY_SET.Spectral
                    }
                end
            end
        end
    end
}

-- Joke Joker?
SMODS.Joker {
    key = 'joke_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Joke Joker?',
        text = {
            "Does nothing... or does it?"
        },
        unlock = {
            "Redeem the {C:attention}Blank Voucher{}",
            "a total of {C:attention}2 times{}"
        }
    },
    config = { extra = {} },
    rarity = 3,
    pos = { x = 1, y = 4 },
    cost = 8,
    blueprint_compat = false,
    check_for_unlock = function(self, args)
        local count = (G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile] and G.PROFILES[G.SETTINGS.profile].blank_vouchers_bought) or 0
        if count >= 2 then
            return true
        end
    end,
    calculate = function(self, card, context)
        if G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers['v_blank'] then
            G.GAME.used_vouchers['v_blank'] = nil
            G.GAME.used_vouchers['v_antimatter'] = true
            G.jokers.config.card_limit = G.jokers.config.card_limit + 1
            return {
                message = 'Antimatter!',
                colour = G.C.SECONDARY_SET.Voucher
            }
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        if G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers['v_blank'] then
            G.GAME.used_vouchers['v_blank'] = nil
            G.GAME.used_vouchers['v_antimatter'] = true
            G.jokers.config.card_limit = G.jokers.config.card_limit + 1
        end
    end
}

-- Perfectionism
SMODS.Joker {
    key = 'perfectionism_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Perfectionism',
        text = {
            "Defeating Big or Boss Blind adds {C:dark_edition}Polychrome{}",
            "to a random Joker {C:inactive}({C:green}#1# in #2#{C:inactive} chance for Negative){}"
        },
        unlock = {
            "Have {C:attention}5 Jokers{} with an",
            "{C:dark_edition}Edition{} at the same time"
        }
    },
    config = { extra = { odds = 5 } },
    rarity = 3,
    pos = { x = 2, y = 4 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        return { vars = { (G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odds } }
    end,
    check_for_unlock = function(self, args)
        if G.jokers and G.jokers.cards then
            local count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j.edition then
                    count = count + 1
                end
            end
            if count >= 5 then
                return true
            end
        end
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and not context.individual and not context.repetition then
            local is_big_or_boss = false
            if G.GAME and G.GAME.blind then
                if G.GAME.blind.boss or G.GAME.blind.name == 'Big Blind' or G.GAME.blind.key == 'b_big' or (G.GAME.blind.get_type and G.GAME.blind:get_type() == 'Big') then
                    is_big_or_boss = true
                end
            end

            if is_big_or_boss then
                local candidates = {}
                if G.jokers and G.jokers.cards then
                    for _, j in ipairs(G.jokers.cards) do
                        local is_self = (j == card) or (context.blueprint_card and j == context.blueprint_card)
                        if not is_self and not (j.edition and j.edition.negative) then
                            table.insert(candidates, j)
                        end
                    end
                end

                if #candidates > 0 then
                    local uneditioned = {}
                    for _, j in ipairs(candidates) do
                        if not j.edition then
                            table.insert(uneditioned, j)
                        end
                    end

                    local target = nil
                    if #uneditioned > 0 then
                        target = pseudorandom_element(uneditioned, 'perfectionism_target')
                    else
                        target = pseudorandom_element(candidates, 'perfectionism_target')
                    end

                    if target then
                        local chosen_edition = 'e_polychrome'
                        local is_neg = pseudorandom('perfectionism_neg') < ((G.GAME and G.GAME.probabilities.normal or 1) / card.ability.extra.odds)
                        if is_neg then
                            chosen_edition = 'e_negative'
                        end

                        G.E_MANAGER:add_event(Event({
                            func = function()
                                target:set_edition(chosen_edition, true)
                                target:juice_up(0.5, 0.5)
                                return true
                            end
                        }))

                        local chosen_msg = is_neg and "Negative!" or pseudorandom_element({"Perfected!", "Refined!"}, 'perfectionism_msg')

                        return {
                            message = chosen_msg,
                            colour = G.C.DARK_EDITION
                        }
                    end
                end
            end
        end
    end
}

-- Reaper Joker
SMODS.Joker {
    key = 'reaper_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Reaper Joker',
        text = {
            "Selling another Joker creates an {C:attention}Invisible Joker{}",
            "{C:inactive}(Except Invisible Joker. Once per round, #1#){}"
        }
    },
    config = { extra = { used = false } },
    rarity = 3,
    pos = { x = 3, y = 4 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local used = (card and card.ability and card.ability.extra and card.ability.extra.used) or false
        local status_text = used and "Used this round" or "Available"
        return { vars = { status_text } }
    end,
    calculate = function(self, card, context)
        if context.selling_card and context.card and context.card.ability and context.card.ability.set == 'Joker' and context.card ~= card and not context.blueprint then
            local sold_card = context.card
            local sold_key = (sold_card.config and sold_card.config.center and sold_card.config.center.key) or (sold_card.config and sold_card.config.center_key) or ''
            local sold_name = (sold_card.ability and sold_card.ability.name) or ''
            if sold_key == 'j_invisible' or sold_name == 'Invisible Joker' then
                return
            end

            card.ability.extra = card.ability.extra or {}
            if not card.ability.extra.used then
                if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                    card.ability.extra.used = true
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        func = function()
                            play_sound('tarot2')
                            local invisible = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_invisible', 'parca')
                            invisible:add_to_deck()
                            G.jokers:emplace(invisible)
                            invisible:juice_up(0.6, 0.6)
                            card:juice_up(0.4, 0.5)
                            card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Spirited Away!', colour = G.C.PURPLE })
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

-- Infostealer Joker (Always Eternal)
SMODS.Joker {
    key = 'infostealer_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Infostealer Joker',
        text = {
            "{C:eternal}Always Eternal{}.",
            "Losing {C:money}$#2#{} upon leaving shop grants {X:mult,C:white}+X#3#{} Mult.",
            "If unable to pay, loses {X:mult,C:white}-X#3#{} Mult",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)"
        }
    },
    config = { extra = { xmult = 1.0, cost = 10, xmult_change = 0.5 } },
    rarity = 3,
    pos = { x = 4, y = 4 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local xmult = (card and card.ability and card.ability.extra and card.ability.extra.xmult) or 1.0
        local cost = (card and card.ability and card.ability.extra and card.ability.extra.cost) or 10
        local change = (card and card.ability and card.ability.extra and card.ability.extra.xmult_change) or 0.5
        return { vars = { xmult, cost, change } }
    end,
    add_to_deck = function(self, card, from_debuff)
        card:set_eternal(true)
        if card.ability then card.ability.eternal = true end
    end,
    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            card.ability.extra = card.ability.extra or {}
            local cost = card.ability.extra.cost or 10
            local change = card.ability.extra.xmult_change or 0.5
            local current_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0

            if current_dollars >= cost then
                ease_dollars(-cost)
                card.ability.extra.xmult = (card.ability.extra.xmult or 1.0) + change
                return {
                    message = '+X' .. change .. ' Mult',
                    colour = G.C.XMULT
                }
            else
                card.ability.extra.xmult = math.max(1.0, (card.ability.extra.xmult or 1.0) - change)
                return {
                    message = '-X' .. change .. ' Mult',
                    colour = G.C.RED
                }
            end
        end

        if context.joker_main and card.ability.extra and card.ability.extra.xmult and card.ability.extra.xmult > 1 then
            return {
                Xmult = card.ability.extra.xmult
            }
        end
    end
}

-- Oversaturated Joker
SMODS.Joker {
    key = 'oversaturated_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Oversaturated',
        text = {
            "If played hand contains only {C:attention}1 card{}, adds a",
            "random missing {C:enhanced}Enhancement{}, {C:gold}Seal{}, or {C:dark_edition}Edition{}.",
            "{C:inactive}(Does not overwrite existing traits. Once per round, #1#){}"
        }
    },
    config = { extra = { used = false } },
    rarity = 3,
    pos = { x = 5, y = 4 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local used = (card and card.ability and card.ability.extra and card.ability.extra.used) or false
        local status_text = used and "Used this round" or "Available"
        return { vars = { status_text } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            card.ability.extra = card.ability.extra or {}
            local play_count = (context.full_hand and #context.full_hand) or (context.scoring_hand and #context.scoring_hand) or (G.play and G.play.cards and #G.play.cards) or 0
            if play_count == 1 and not card.ability.extra.used then
                local pcard = context.other_card
                local has_enh = (pcard.config and pcard.config.center and pcard.config.center ~= G.P_CENTERS.c_base) or (pcard.ability and pcard.ability.effect and pcard.ability.effect ~= 'Base')
                local has_seal = (pcard.seal ~= nil)
                local has_edition = (pcard.edition ~= nil)

                local missing = {}
                if not has_enh then table.insert(missing, 'enhancement') end
                if not has_seal then table.insert(missing, 'seal') end
                if not has_edition then table.insert(missing, 'edition') end

                if #missing > 0 then
                    card.ability.extra.used = true
                    local chosen_type = pseudorandom_element(missing, pseudoseed('sobresaturado_type'))
                    if chosen_type == 'enhancement' then
                        local enhs = { G.P_CENTERS.m_bonus, G.P_CENTERS.m_mult, G.P_CENTERS.m_wild, G.P_CENTERS.m_glass, G.P_CENTERS.m_steel, G.P_CENTERS.m_stone, G.P_CENTERS.m_gold, G.P_CENTERS.m_lucky }
                        local chosen_enh = pseudorandom_element(enhs, pseudoseed('sobresaturado_enh'))
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.2,
                            func = function()
                                play_sound('tarot1')
                                pcard:set_ability(chosen_enh)
                                pcard:juice_up(0.4, 0.4)
                                card_eval_status_text(pcard, 'extra', nil, nil, nil, { message = 'Enhanced!', colour = G.C.SECONDARY_SET.Enhanced })
                                return true
                            end
                        }))
                    elseif chosen_type == 'seal' then
                        local seals = { 'Gold', 'Blue', 'Red', 'Purple', 'Witch_brew_dark_green', 'Witch_brew_silver', 'Witch_brew_white' }
                        local chosen_seal = pseudorandom_element(seals, pseudoseed('sobresaturado_seal'))
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.2,
                            func = function()
                                play_sound('gold_seal')
                                pcard:set_seal(chosen_seal, nil, true)
                                pcard:juice_up(0.4, 0.4)
                                card_eval_status_text(pcard, 'extra', nil, nil, nil, { message = 'Sealed!', colour = G.C.GOLD })
                                return true
                            end
                        }))
                    elseif chosen_type == 'edition' then
                        local eds = { 'e_foil', 'e_holo', 'e_polychrome' }
                        local chosen_ed = pseudorandom_element(eds, pseudoseed('sobresaturado_ed'))
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.2,
                            func = function()
                                play_sound('polychrome1')
                                pcard:set_edition(chosen_ed, true)
                                pcard:juice_up(0.4, 0.4)
                                card_eval_status_text(pcard, 'extra', nil, nil, nil, { message = 'Polished!', colour = G.C.DARK_EDITION })
                                return true
                            end
                        }))
                    end
                end
            end
        end

        if (context.end_of_round or context.setting_blind) and not context.individual and not context.repetition and not context.blueprint then
            card.ability.extra = card.ability.extra or {}
            card.ability.extra.used = false
        end
    end
}

-- Radiation
SMODS.Joker {
    key = 'radiation',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Radiation',
        text = {
            "Gives {X:mult,C:white}X#1#{} Mult.",
            "At end of round, {C:green}#2# in #3#{} chance",
            "per hand played to {C:red}debuff{} a random Joker"
        }
    },
    config = { extra = { xmult = 3.0, odds = 5 } },
    rarity = 3,
    pos = { x = 0, y = 5 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local prob = (G.GAME and G.GAME.probabilities.normal) or 1
        return { vars = { ex.xmult or 3.0, prob, ex.odds or 5 } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 3.0,
                card = card
            }
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local hands_played = (G.GAME and G.GAME.current_round and G.GAME.current_round.hands_played) or 1
            local prob = (G.GAME and G.GAME.probabilities.normal) or 1
            local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 5
            if G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
                for i = 1, hands_played do
                    if pseudorandom('radiation_debuff') < (prob / odds) then
                        local candidates = {}
                        for _, j in ipairs(G.jokers.cards) do
                            if not j.debuff then
                                table.insert(candidates, j)
                            end
                        end
                        local target = (#candidates > 0) and pseudorandom_element(candidates, pseudoseed('radiation_target')) or pseudorandom_element(G.jokers.cards, pseudoseed('radiation_target_all'))
                        if target then
                            target:set_debuff(true)
                            target:juice_up(0.5, 0.5)
                            card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Irradiated!', colour = G.C.RED })
                        end
                    end
                end
            end
        end
    end
}

-- 24K Magic
SMODS.Joker {
    key = '24k_magic',
    atlas = 'witch_brew_jokers',
    pos = { x = 3, y = 5 },
    rarity = 'Witch_brew_song',
    cost = 8,
    blueprint_compat = true,
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge('Song', HEX('d4af37'), G.C.WHITE, 1.2)
    end,
    set_badges = function(self, card, badges)
        if badges and #badges > 0 then
            badges[1] = create_badge('Song', HEX('d4af37'), G.C.WHITE, 1.2)
        end
    end,
    config = { extra = { xmult = 2.0 } },
    loc_txt = {
        name = '24K Magic',
        text = {
            "Each scored {C:attention}Gold Card{}",
            "gives {X:mult,C:white}X#1#{} Mult",
            "{C:inactive}('24 karat magic in the air'){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
        end
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.xmult or 2.0 } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local is_gold = false
            if context.other_card then
                if context.other_card.ability and (context.other_card.ability.name == 'Gold Card' or context.other_card.ability.effect == 'Gold Card') then
                    is_gold = true
                elseif context.other_card.config and context.other_card.config.center == G.P_CENTERS.m_gold then
                    is_gold = true
                end
            end
            if is_gold then
                return {
                    x_mult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 2.0,
                    card = card
                }
            end
        end
    end
}




-- Rare Jokers, Additional definitions

-- Orchestra Director, Rare Joker
SMODS.Joker {
    key = 'orchestra_director',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    unlock = { "Own {C:attention}5 Jokers{} at the same time" },
    loc_txt = {
        name = 'Orchestra Director',
        text = {
            "{C:green}#1# in #2#{} chance a random Joker in",
            "the shop appears for {C:money}free{}",
            "{C:inactive}(Each shop visit rolls once){}"
        }
    },
    config = { extra = { odds = 4 } },
    rarity = 3,
    pos = { x = 1, y = 9 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local prob = (G.GAME and G.GAME.probabilities.normal) or 1
        return { vars = { prob, (card and card.ability and card.ability.extra and card.ability.extra.odds) or 4 } }
    end,
    check_for_unlock = function(self, args)
        local n = G.jokers and G.jokers.cards and #G.jokers.cards or 0
        return n >= 5
    end,
    calculate = function(self, card, context)
        if (context.starting_shop or context.open_shop) and not context.blueprint then
            local prob = (G.GAME and G.GAME.probabilities.normal) or 1
            local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 4
            if pseudorandom('orchestra_director') < (prob / odds) then
                -- Find a joker in the shop and zero its cost
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        if G.shop_jokers and G.shop_jokers.cards and #G.shop_jokers.cards > 0 then
                            local free_card = pseudorandom_element(G.shop_jokers.cards, pseudoseed('director_free'))
                            if free_card then
                                free_card.cost = 0
                                free_card:juice_up(0.5, 0.5)
                                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Free Joker!', colour = G.C.MONEY })
                            end
                        end
                        return true
                    end
                }))
            end
        end
    end
}

-- Meteorologist, Rare Joker
SMODS.Joker {
    key = 'meteorologist',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    unlock = { "Defeat a blind under", "each of the 4 weather effects" },
    loc_txt = {
        name = 'Meteorologist',
        text = {
            "{X:mult,C:white}X#1#{} Mult. Each blind has a random",
            "{C:attention}Weather{}:",
            "Storm(+Mult,-1 hand), Sun(+1 hand,-Mult),",
            "Fog(hidden cards), Hail(random debuff)"
        }
    },
    config = { extra = { xmult = 3, weather = '', weathers_seen = {} } },
    rarity = 3,
    pos = { x = 2, y = 9 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        return { vars = { ex.xmult or 3, ex.weather or '?' } }
    end,
    check_for_unlock = function(self, args)
        if G.GAME and G.GAME.witch_brew_weathers_seen then
            local count = 0
            for _ in pairs(G.GAME.witch_brew_weathers_seen) do count = count + 1 end
            return count >= 4
        end
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local weathers = { 'Storm', 'Sun', 'Fog', 'Hail' }
            local w = pseudorandom_element(weathers, pseudoseed('meteorologist_'..tostring(G.GAME.round or 0)))
            card.ability.extra.weather = w
            -- Track for unlock
            G.GAME.witch_brew_weathers_seen = G.GAME.witch_brew_weathers_seen or {}
            G.GAME.witch_brew_weathers_seen[w] = true

            if w == 'Storm' then
                ease_hands_played(-1)
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Storm! -1 Hand', colour = G.C.RED })
            elseif w == 'Sun' then
                ease_hands_played(1)
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Sun! +1 Hand', colour = G.C.GOLD })
            elseif w == 'Fog' then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.8,
                    func = function()
                        if G.hand and G.hand.cards and #G.hand.cards > 0 then
                            local target = pseudorandom_element(G.hand.cards, pseudoseed('fog_hide'))
                            if target then
                                target.facing = 'back'
                                target.sprite_facing = 'back'
                                target:juice_up(0.3, 0.3)
                            end
                        end
                        return true
                    end
                }))
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Fog! Cards Hidden', colour = G.C.GREY })
            elseif w == 'Hail' then
                -- Debuff a random hand card after deal
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.8,
                    func = function()
                        if G.hand and G.hand.cards and #G.hand.cards > 0 then
                            local target = pseudorandom_element(G.hand.cards, pseudoseed('hail_debuff'))
                            if target then
                                target.debuff = true
                                target:juice_up(0.3, 0.3)
                            end
                        end
                        return true
                    end
                }))
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Hail! Debuff!', colour = G.C.RED })
            end
        end

        if context.joker_main and not context.blueprint then
            local w = card.ability.extra.weather or ''
            local base_xmult = 3
            if w == 'Storm' then
                return { x_mult = base_xmult + 0.5, card = card }
            elseif w == 'Sun' then
                return { x_mult = base_xmult - 0.5, card = card }
            else
                return { x_mult = base_xmult, card = card }
            end
        end
    end
}

-- Mad Clockmaker, Rare Joker
SMODS.Joker {
    key = 'mad_clockmaker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Mad Clockmaker',
        text = {
            "Gives {C:mult}+#1#{} Mult for each",
            "remaining {C:attention}discard{}",
            "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { mult_per_discard = 14 } },
    rarity = 3,
    pos = { x = 3, y = 9 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local rate = (card and card.ability and card.ability.extra and card.ability.extra.mult_per_discard) or 14
        local discards = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        return { vars = { rate, discards * rate } }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local discards_left = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
            if discards_left > 0 then
                local mult_val = discards_left * ((card.ability and card.ability.extra and card.ability.extra.mult_per_discard) or 14)
                return {
                    mult = mult_val,
                    card = card,
                    message = '+' .. mult_val .. ' Mult'
                }
            end
        end
    end
}

-- Catalyst, Rare Joker
SMODS.Joker {
    key = 'catalyst',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    unlock = { "Have a Joker with {C:mult}X3{} or", "higher base x_mult" },
    loc_txt = {
        name = 'Catalyst',
        text = {
            "{C:green}#1# in #2#{} chance to {C:attention}empower{}",
            "a random Joker, granting",
            "{X:mult,C:white}X#3#{} Mult this hand",
            "{C:inactive}(Empowered: #4#){}"
        }
    },
    config = { extra = { odds = 3, x_mult = 2.5, target_name = 'None' } },
    rarity = 3,
    pos = { x = 4, y = 9 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local prob = (G.GAME and G.GAME.probabilities.normal) or 1
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { prob, ex.odds or 3, ex.x_mult or 2.5, ex.target_name or 'None' } }
    end,
    check_for_unlock = function(self, args)
        if G.jokers and G.jokers.cards then
            for _, jk in ipairs(G.jokers.cards) do
                local xm = jk.ability and jk.ability.x_mult or 0
                if xm >= 3 then return true end
            end
        end
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local prob = (G.GAME and G.GAME.probabilities.normal) or 1
            local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 3
            if pseudorandom('catalyst') < (prob / odds) then
                local others = {}
                if G.jokers and G.jokers.cards then
                    for _, jk in ipairs(G.jokers.cards) do
                        if jk ~= card then others[#others + 1] = jk end
                    end
                end
                if #others > 0 then
                    local target = pseudorandom_element(others, pseudoseed('catalyst_target'))
                    card.ability.extra.target_name = target.config and target.config.center and target.config.center.name or 'Joker'
                    target:juice_up(0.5, 0.5)
                else
                    card.ability.extra.target_name = 'Self'
                end
                local xm = (card.ability and card.ability.extra and card.ability.extra.x_mult) or 2.5
                return {
                    x_mult = xm,
                    card = card,
                    message = 'Catalyzed! X' .. xm
                }
            end
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.target_name = 'None'
        end
    end
}

-- Graffiti Artist, Rare Joker
SMODS.Joker {
    key = 'graffiti_artist',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Graffiti Artist',
        text = {
            "Each hand played, a random deck card",
            "gets {C:attention}Mult{} or {C:attention}Wild{} enhancement.",
            "Gives {X:mult,C:white}X#1#{} Mult each hand"
        }
    },
    config = { extra = { x_mult = 1.5 } },
    rarity = 3,
    pos = { x = 5, y = 9 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { (card and card.ability and card.ability.extra and card.ability.extra.x_mult) or 1.5 } }
    end,
    calculate = function(self, card, context)
        -- Paint a card after each hand
        if context.after and not context.blueprint then
            local candidates = {}
            if G.playing_cards then
                for _, c in ipairs(G.playing_cards) do
                    local cur = c.config and c.config.center and c.config.center.key
                    if not cur or cur == '' or cur == 'c_base' then candidates[#candidates + 1] = c end
                end
            end
            if #candidates > 0 then
                local target = pseudorandom_element(candidates, pseudoseed('graffiti_artist_'..tostring(G.GAME.round or 0)))
                local enhs = { G.P_CENTERS.m_mult, G.P_CENTERS.m_wild }
                local enh = pseudorandom_element(enhs, pseudoseed('graffiti_artist_enh'))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after', delay = 0.2,
                    func = function()
                        if G.P_CENTERS[enh and enh.key or ''] then
                            target:set_ability(enh)
                        else
                            target:set_ability(enhs[1])
                        end
                        target:juice_up(0.4, 0.4)
                        return true
                    end
                }))
            end
        end

        -- Boost each hand
        if context.cardarea == G.jokers and context.joker_main then
            return {
                x_mult = (card.ability and card.ability.extra and card.ability.extra.x_mult) or 1.5,
                card = card
            }
        end
    end
}

-- Hypnotist, Rare Joker
SMODS.Joker {
    key = 'hypnotist',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    unlock = { "Defeat {C:attention}3 different{}", "Boss Blind types" },
    loc_txt = {
        name = 'Hypnotist',
        text = {
            "Boss Blind has {C:green}#1# in #2#{} chance to",
            "be {C:attention}hypnotized{}: its debuff effect is",
            "{C:attention}completely disabled{}"
        }
    },
    config = { extra = { odds = 3, hypnotized = false, bosses_defeated = {}, boss_count = 0 } },
    rarity = 3,
    pos = { x = 6, y = 9 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local prob = (G.GAME and G.GAME.probabilities.normal) or 1
        return { vars = { prob, (card and card.ability and card.ability.extra and card.ability.extra.odds) or 3 } }
    end,
    check_for_unlock = function(self, args)
        local ex = (args and args.card and args.card.ability and args.card.ability.extra)
        if ex then
            return (ex.boss_count or 0) >= 3
        end
        return false
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hypnotized = false
            if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                local prob = (G.GAME and G.GAME.probabilities.normal) or 1
                local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 3
                if pseudorandom('hypnotist') < (prob / odds) then
                    card.ability.extra.hypnotized = true
                    if G.GAME.blind.disable then
                        G.GAME.blind:disable()
                    end
                    for _, c in ipairs(G.playing_cards or {}) do
                        c.debuff = false
                    end
                    return { message = 'Hypnotized! Disabled', colour = G.C.PURPLE, card = card }
                end
            end
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                local key = G.GAME.blind.key or ''
                if key ~= '' and not card.ability.extra.bosses_defeated[key] then
                    card.ability.extra.bosses_defeated[key] = true
                    card.ability.extra.boss_count = (card.ability.extra.boss_count or 0) + 1
                end
            end
        end
    end
}

-- Hand Alchemist, Rare Joker
SMODS.Joker {
    key = 'hand_alchemist',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    unlock = { "Have any hand lose {C:attention}3+ levels{}", "via Negative Planets" },
    loc_txt = {
        name = 'Hand Alchemist',
        text = {
            "At end of each round,",
            "a random {C:blue}Planet card{} is added",
            "to your consumables.",
            "{C:inactive}({C:green}#1# in #2#{C:inactive} chance it is negative){}"
        }
    },
    config = { extra = { odds = 3, neg_levels_given = 0 } },
    rarity = 3,
    pos = { x = 0, y = 10 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local prob = (G.GAME and G.GAME.probabilities.normal) or 1
        return { vars = { prob, (card and card.ability and card.ability.extra and card.ability.extra.odds) or 3 } }
    end,
    check_for_unlock = function(self, args)
        local ex = args and args.card and args.card.ability and args.card.ability.extra
        return ex and (ex.neg_levels_given or 0) >= 3
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                local prob = (G.GAME and G.GAME.probabilities.normal) or 1
                local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 3
                local is_negative = pseudorandom('alquimista_neg') < (prob / odds)
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local planet = create_card('Planet', G.consumeables, nil, nil, nil, nil, nil, 'alq')
                        planet:add_to_deck()
                        G.consumeables:emplace(planet)
                        G.GAME.consumeable_buffer = math.max(0, (G.GAME.consumeable_buffer or 1) - 1)
                        planet:juice_up(0.5, 0.5)
                        card:juice_up(0.3, 0.3)
                        return true
                    end
                }))
                if is_negative then
                    -- Level down a random hand
                    local hand_list = {}
                    if G.GAME and G.GAME.hands then
                        for k, h in pairs(G.GAME.hands) do
                            if h.visible and (h.level or 1) > 1 then
                                hand_list[#hand_list + 1] = k
                            end
                        end
                    end
                    if #hand_list > 0 then
                        local target_hand = pseudorandom_element(hand_list, pseudoseed('alquimista_hand'))
                        if G.GAME.hands[target_hand] then
                            G.GAME.hands[target_hand].level = (G.GAME.hands[target_hand].level or 1) - 1
                            card.ability.extra.neg_levels_given = (card.ability.extra.neg_levels_given or 0) + 1
                        end
                        return { message = 'Negative Planet!', colour = G.C.RED, card = card }
                    end
                end
                return { message = 'Planet!', colour = G.C.BLUE, card = card }
            end
        end
    end
}

-- Entomologist, Rare Joker
SMODS.Joker {
    key = 'entomologist',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    unlock = { "Defeat {C:attention}10 blinds{}", "in a single run" },
    loc_txt = {
        name = 'Entomologist',
        text = {
            "Each hand played, a scored card",
            "gets a random {C:attention}Insect token{}:",
            "{C:attention}Beetle{}: {C:chips}+40{} Chips | {C:attention}Firefly{}: {C:mult}+10{} Mult",
            "{C:attention}Butterfly{}: {C:attention}retrigger 1x{} | {C:attention}Spider{}: {C:chips}+15{} Chips"
        }
    },
    config = { extra = { blinds_beaten = 0 } },
    rarity = 3,
    pos = { x = 1, y = 10 },
    cost = 9,
    blueprint_compat = false,
    check_for_unlock = function(self, args)
        local ex = args and args.card and args.card.ability and args.card.ability.extra
        return ex and (ex.blinds_beaten or 0) >= 10
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.blinds_beaten = (card.ability.extra.blinds_beaten or 0) + 1
        end

        -- Add insect token after each hand
        if context.after and not context.blueprint then
            local insects = { 'beetle', 'butterfly', 'firefly', 'spider' }
            local insect = pseudorandom_element(insects, pseudoseed('entomologist_'..tostring(G.GAME.round or 0)))
            local candidates = (context.scoring_hand and #context.scoring_hand > 0 and context.scoring_hand) or (G.hand and G.hand.cards and #G.hand.cards > 0 and G.hand.cards) or G.playing_cards or {}
            if #candidates > 0 then
                local target = pseudorandom_element(candidates, pseudoseed('entomologist_card'))
                target.witch_brew_insect = insect
                target:juice_up(0.4, 0.4)
            end
        end

        -- Apply insect effects on individual card scoring
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local c = context.other_card
            local insect = c and c.witch_brew_insect
            if insect == 'beetle' then
                return { chips = 40, card = card }
            elseif insect == 'firefly' then
                return { mult = 10, card = card }
            elseif insect == 'spider' then
                -- Bonus if same suit as a played card
                local suit = c.base and c.base.suit
                local bonus = 0
                if context.scoring_hand then
                    for _, sc in ipairs(context.scoring_hand) do
                        if sc ~= c and sc.base and sc.base.suit == suit then
                            bonus = bonus + 15
                        end
                    end
                end
                if bonus > 0 then return { chips = bonus, card = card } end
            end
        end

        -- Butterfly retrigger
        if context.repetition and context.cardarea == G.play and not context.blueprint then
            local c = context.other_card
            if c and c.witch_brew_insect == 'butterfly' then
                return { repetitions = 1, card = card }
            end
        end
    end
}

