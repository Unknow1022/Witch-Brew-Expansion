--[[
    JokerDisplay Integration for Witch_Brew
    Full Native Display Suite for all 44 Jokers
    Minimalist & Clean Numbers-Only Edition
    Compatible with JokerDisplay >= 1.8.0 & SMODS
--]]

if not JokerDisplay then return end

local jd_def = JokerDisplay.Definitions

-- Helpers for compact card formatting
local function format_short_card(c)
    if not c or not c.base then return "?" end
    local val = c.base.value or '?'
    local short_val = (val == '10' and '10') or string.sub(tostring(val), 1, 1)
    local suit_sym = (c.base.suit == 'Hearts' and 'H') or
                     (c.base.suit == 'Diamonds' and 'D') or
                     (c.base.suit == 'Spades' and 'S') or
                     (c.base.suit == 'Clubs' and 'C') or ''
    return short_val .. suit_sym
end

local function has_charles_and_mochi_jd()
    return (type(has_charles_and_mochi) == 'function' and has_charles_and_mochi()) or false
end

-- Common Jokers, JokerDisplay definitions

-- 1. Masterful Joker
jd_def["j_Witch_brew_masterful_joker"] = {
    text = {
        { text = "+1 Tarot" }
    },
    text_config = { colour = G.C.PURPLE },
    reminder_text = {
        { text = "(4 of a Kind)" }
    },
    calc_function = function(card)
        local text, poker_hands = JokerDisplay.evaluate_hand()
        local is_four = (poker_hands and poker_hands['Four of a Kind'] and next(poker_hands['Four of a Kind']))
        card.joker_display_values.active = (text ~= 'Unknown' and is_four)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.PURPLE or G.C.UI.TEXT_INACTIVE
        end
    end
}


-- 2. Outstanding Joker
jd_def["j_Witch_brew_outstanding_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "retrigger_str" }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "card_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local triggers = JokerDisplay.calculate_joker_triggers(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand and #scoring_hand > 0 then
            local highest_rank = -1
            local highest_card = nil
            for _, c in ipairs(scoring_hand) do
                local r = (c.get_id and c:get_id()) or (c.base and c.base.id) or 0
                if r > highest_rank then
                    highest_rank = r
                    highest_card = c
                end
            end
            if highest_card then
                card.joker_display_values.retrigger_str = (1 * triggers) .. "x"
                card.joker_display_values.card_str = format_short_card(highest_card)
                card.joker_display_values.active = true
            else
                card.joker_display_values.retrigger_str = (1 * triggers) .. "x"
                card.joker_display_values.card_str = "-"
                card.joker_display_values.active = false
            end
        else
            card.joker_display_values.retrigger_str = (1 * triggers) .. "x"
            card.joker_display_values.card_str = "-"
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.GREEN or G.C.UI.TEXT_INACTIVE
        end
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand or not scoring_hand or #scoring_hand == 0 then return 0 end
        if not JokerDisplay.in_scoring(playing_card, scoring_hand) then return 0 end
        local highest_rank = -1
        local highest_card = nil
        for _, c in ipairs(scoring_hand) do
            local r = (c.get_id and c:get_id()) or (c.base and c.base.id) or 0
            if r > highest_rank then
                highest_rank = r
                highest_card = c
            end
        end
        if playing_card == highest_card then
            return 1 * JokerDisplay.calculate_joker_triggers(joker_card)
        end
        return 0
    end
}

-- 3. Blueberry
jd_def["j_Witch_brew_blueberry_joker"] = {
    text = {
        { text = "+1 Hand", colour = G.C.BLUE }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rounds_left" },
        { text = ")" }
    },
    calc_function = function(card)
        local r = (card.ability and card.ability.extra and card.ability.extra.rounds_left) or 3
        card.joker_display_values.rounds_left = r .. "/3"
    end
}

-- 4. DJ Joker
jd_def["j_Witch_brew_dj_joker"] = {
    text = {
        { text = "Remix", colour = G.C.SECONDARY_SET.Enhanced }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local used = card.ability and card.ability.extra and card.ability.extra.used
        card.joker_display_values.rem = used and "0/1" or "1/1"
        card.joker_display_values.active = not used
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.SECONDARY_SET.Enhanced or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- 5. Designer Joker
jd_def["j_Witch_brew_disenador_joker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MONEY },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local dollars = 0
        local wild_count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                if is_wild_card(c) then
                    local triggers = JokerDisplay.calculate_card_triggers(c, scoring_hand)
                    dollars = dollars + (card.ability.extra.dollars or 1) * triggers
                    wild_count = wild_count + 1
                end
            end
        end
        card.joker_display_values.dollars = dollars
        card.joker_display_values.rem = wild_count .. " Wild"
    end
}

-- 6. TTS Joker
jd_def["j_Witch_brew_tts_joker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS, retrigger_type = "mult" },
        { text = " / +" },
        { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT, retrigger_type = "mult" }
    },
    calc_function = function(card)
        local letter_counts = {
            ['2'] = 3, ['3'] = 5, ['4'] = 4, ['5'] = 4, ['6'] = 3,
            ['7'] = 5, ['8'] = 5, ['9'] = 4, ['10'] = 3,
            ['Jack'] = 4, ['Queen'] = 5, ['King'] = 4, ['Ace'] = 3
        }
        local total_chips = 0
        local total_mult = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                local val = c.base and c.base.value
                local l = letter_counts[val] or 4
                local triggers = JokerDisplay.calculate_card_triggers(c, scoring_hand)
                total_chips = total_chips + (l * (card.ability.extra.chips_per_letter or 4)) * triggers
                total_mult = total_mult + (l * (card.ability.extra.mult_per_letter or 1)) * triggers
            end
        end
        card.joker_display_values.chips = total_chips
        card.joker_display_values.mult = total_mult
    end
}

-- Joker Descartador
jd_def["j_Witch_brew_joker_descartador"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS },
        { text = " / +" },
        { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "discards" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = (card.ability and card.ability.extra) or {}
        local discards = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        card.joker_display_values.chips = ex.chips or 0
        card.joker_display_values.mult = ex.mult or 0
        card.joker_display_values.discards = discards .. " disc."
    end
}

-- Uncommon Jokers, JokerDisplay definitions

-- 7. Shareholder Joker
jd_def["j_Witch_brew_shareholder_joker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "reminder_str" }
    },
    calc_function = function(card)
        local price = (card.ability and card.ability.extra and card.ability.extra.current_price) or 5
        card.joker_display_values.mult = price * 2
        local is_boss = G.GAME and G.GAME.blind and G.GAME.blind.boss
        if is_boss then
            card.joker_display_values.reminder_str = "(Cash Out: +$" .. price .. ")"
            card.joker_display_values.active = true
        else
            card.joker_display_values.reminder_str = "(+$" .. price .. ")"
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children and reminder_text.children[1] then
            reminder_text.children[1].config.colour = card.joker_display_values.active and G.C.GOLD or G.C.MONEY
        end
    end
}

-- 8. Builder Joker
jd_def["j_Witch_brew_builder_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand and #scoring_hand >= 2 then
            local is_ascending = true
            for i = 1, #scoring_hand - 1 do
                local cur_id = scoring_hand[i]:get_id() or 0
                local next_id = scoring_hand[i + 1]:get_id() or 0
                if cur_id >= next_id then
                    is_ascending = false
                    break
                end
            end
            if is_ascending then
                card.joker_display_values.x_mult = 1 + (#scoring_hand * (card.ability.extra.xmult_per_card or 0.5))
                card.joker_display_values.rem = #scoring_hand .. " cards"
                card.joker_display_values.active = true
            else
                card.joker_display_values.x_mult = 1
                card.joker_display_values.rem = "0"
                card.joker_display_values.active = false
            end
        else
            card.joker_display_values.x_mult = 1
            card.joker_display_values.rem = "0"
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- 9. Banquet
jd_def["j_Witch_brew_banquet_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "held_count" },
        { text = "/7)" }
    },
    calc_function = function(card)
        local in_hand = (G.hand and G.hand.cards and #G.hand.cards) or 0
        local highlighted = (G.hand and G.hand.highlighted and #G.hand.highlighted) or 0
        local held = math.max(0, in_hand - highlighted)
        local thresh = (card.ability and card.ability.extra and card.ability.extra.hand_threshold) or 7
        card.joker_display_values.held_count = held
        if held >= thresh then
            card.joker_display_values.x_mult = card.ability.extra.xmult or 2.5
            card.joker_display_values.active = true
        else
            card.joker_display_values.x_mult = 1
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- 10. Appraiser
jd_def["j_Witch_brew_appraiser_joker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" }
    },
    text_config = { colour = G.C.MONEY },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "count" },
        { text = ")" }
    },
    calc_function = function(card)
        local count = 0
        if G.playing_cards then
            for _, pcard in ipairs(G.playing_cards) do
                if pcard.edition and (pcard.edition.foil or pcard.edition.holo or pcard.edition.polychrome) then
                    count = count + 1
                end
            end
        end
        local per = (card.ability and card.ability.extra and card.ability.extra.dollars_per_edition) or 1
        card.joker_display_values.count = count
        card.joker_display_values.dollars = count * per
    end
}

-- 11. Runway
jd_def["j_Witch_brew_runway_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(+X0.1/Enh)" }
    },
    calc_function = function(card)
        local xmult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 1
        card.joker_display_values.x_mult = xmult
    end
}

-- 12. Slot Machine
jd_def["j_Witch_brew_slot_machine_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "score_text" }
    },
    text_config = { colour = G.C.GOLD },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "sub_text" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = (card.ability and card.ability.extra) or {}
        if ex.last_spin and #ex.last_spin == 3 then
            local r1, r2, r3 = ex.last_spin[1], ex.last_spin[2], ex.last_spin[3]
            local spin_str = "[ " .. tostring(r1) .. " | " .. tostring(r2) .. " | " .. tostring(r3) .. " ]"
            if r1 == '7' and r2 == '7' and r3 == '7' then
                card.joker_display_values.score_text = "X" .. (ex.jackpot_xmult or 4) .. " / +$" .. (ex.jackpot_cash or 35)
            elseif r1 == r2 and r2 == r3 then
                card.joker_display_values.score_text = "X" .. (ex.triple_xmult or 2.5) .. " / +$" .. (ex.triple_cash or 12)
            elseif r1 == r2 or r2 == r3 or r1 == r3 then
                card.joker_display_values.score_text = "+" .. (ex.pair_mult or 15) .. " / +$" .. (ex.pair_cash or 3)
            else
                card.joker_display_values.score_text = "No Match"
            end
            card.joker_display_values.sub_text = spin_str
        else
            local has_lucky = false
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' and scoring_hand then
                for _, sc in ipairs(scoring_hand) do
                    if sc.ability and (sc.ability.name == 'Lucky Card' or sc.ability.effect == 'Lucky Card') then
                        has_lucky = true
                        break
                    end
                end
            end
            card.joker_display_values.score_text = has_lucky and "[ 7 | ? | ? ]" or "[ ? | ? | ? ]"
            card.joker_display_values.sub_text = ex.bet_placed and "Bet $5" or "Bet"
        end
    end
}

-- 13. Duel of Value
jd_def["j_Witch_brew_duel_of_value_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local text, poker_hands, scoring_hand = JokerDisplay.evaluate_hand()
        local is_two_pair = (poker_hands and poker_hands['Two Pair'] and next(poker_hands['Two Pair']))
        if text ~= 'Unknown' and is_two_pair and scoring_hand and #scoring_hand == 4 then
            local evens, odds = 0, 0
            for _, c in ipairs(scoring_hand) do
                local id = c:get_id() or 0
                if id > 0 then
                    if id == 14 or id % 2 ~= 0 then odds = odds + 1 else evens = evens + 1 end
                end
            end
            if evens == 2 and odds == 2 then
                card.joker_display_values.x_mult = card.ability.extra.xmult or 3.0
                card.joker_display_values.rem = "2/2"
                card.joker_display_values.active = true
                return
            end
        end
        card.joker_display_values.x_mult = 1.0
        card.joker_display_values.rem = "0/2"
        card.joker_display_values.active = false
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- 14. Reading Deficiency (Falta de Lectura)
jd_def["j_Witch_brew_falta_de_lectura_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    calc_function = function(card)
        local other_jokers = false
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and not j.debuff and (not j.ability or j.ability.name ~= 'Reading Deficiency') then
                    other_jokers = true
                    break
                end
            end
        end
        if not other_jokers then
            card.joker_display_values.x_mult = card.ability.extra.xmult or 5.0
            card.joker_display_values.active = true
        else
            card.joker_display_values.x_mult = 1.0
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- 15. Chameleon Joker
jd_def["j_Witch_brew_chameleon_joker"] = {
    text = {
        { text = "Copy Blind Tag", colour = G.C.PURPLE }
    },
    reminder_text = {
        { text = "(50% 2x)" }
    }
}

-- 16. Motorized Joker
jd_def["j_Witch_brew_motorized_joker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT }
}
jd_def["j_Witch_brew_motorizado_joker"] = jd_def["j_Witch_brew_motorized_joker"]

-- 17. Hired Joker (Joker Contratado)
jd_def["j_Witch_brew_hired_joker"] = {
    text = {
        { text = "Job Card", colour = HEX('5c1e11') }
    },
    reminder_text = {
        { text = "(1/3)" }
    }
}
jd_def["j_Witch_brew_contratado_joker"] = jd_def["j_Witch_brew_hired_joker"]

-- 18. Seal of Approval (Sello de Aprobación)
jd_def["j_Witch_brew_seal_of_approval_joker"] = {
    text = {
        { text = "+Seal", colour = G.C.GOLD }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand and #scoring_hand == 1 then
            card.joker_display_values.rem = "1/1"
            card.joker_display_values.active = true
        else
            card.joker_display_values.rem = "0/1"
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.GOLD or G.C.UI.TEXT_INACTIVE
        end
    end
}
jd_def["j_Witch_brew_sello_aprobacion_joker"] = jd_def["j_Witch_brew_seal_of_approval_joker"]

-- 19. Paint Puddle (Charco de Pintura)
jd_def["j_Witch_brew_paint_puddle_joker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "suit" },
        { text = ")" }
    },
    calc_function = function(card)
        local suit = (card.ability and card.ability.extra and card.ability.extra.suit) or 'Hearts'
        local total_mult = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                local triggers = JokerDisplay.calculate_card_triggers(c, scoring_hand)
                if is_wild_card(c) then
                    total_mult = total_mult + (card.ability.extra.mult_wild or 15) * triggers
                elseif c:is_suit(suit) then
                    total_mult = total_mult + (card.ability.extra.mult_suit or 7) * triggers
                end
            end
        end
        card.joker_display_values.mult = total_mult
    end
}
jd_def["j_Witch_brew_charco_pintura_joker"] = jd_def["j_Witch_brew_paint_puddle_joker"]

-- 20. Injured Joker (Joker Lesionado)
jd_def["j_Witch_brew_injured_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "prob_text" }
    },
    text_config = { colour = G.C.GREEN },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "rem_text" }
    },
    calc_function = function(card)
        local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 5
        local prob = (G.GAME and G.GAME.probabilities.normal) or 1
        card.joker_display_values.prob_text = "" .. prob .. " in " .. odds
        card.joker_display_values.rem_text = "(End of round)"
    end
}
jd_def["j_Witch_brew_lesionado_joker"] = jd_def["j_Witch_brew_injured_joker"]

-- Extended Hand
jd_def["j_Witch_brew_extended_hand"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(<=4 cards)" }
    },
    calc_function = function(card)
        local ex = (card.ability and card.ability.extra) or {}
        card.joker_display_values.x_mult = ex.xmult or 1.0
        card.joker_display_values.active = (ex.xmult and ex.xmult > 1.0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}
jd_def["j_Witch_brew_mano_extendida"] = jd_def["j_Witch_brew_extended_hand"]

-- Bonfire
jd_def["j_Witch_brew_bonfire"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Face Discard)" }
    },
    calc_function = function(card)
        local ex = (card.ability and card.ability.extra) or {}
        card.joker_display_values.x_mult = ex.xmult or 1.0
        card.joker_display_values.active = (ex.xmult and ex.xmult > 1.0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}
jd_def["j_Witch_brew_hoguera"] = jd_def["j_Witch_brew_bonfire"]

-- Rare Jokers, JokerDisplay definitions

-- 21. Doctor Jo.
jd_def["j_Witch_brew_doctor_jo_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "status" }
    },
    text_config = { colour = G.C.BLUE },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local hands_left = (G.GAME and G.GAME.current_round and G.GAME.current_round.hands_left) or 0
        local used = card.ability and card.ability.extra and card.ability.extra.defibrillator_used
        if used then
            card.joker_display_values.status = "Used"
            card.joker_display_values.rem = "0/1"
        elseif hands_left <= 1 then
            card.joker_display_values.status = "+1 Hand"
            card.joker_display_values.rem = "Ready"
        else
            card.joker_display_values.status = "+1 Hand"
            card.joker_display_values.rem = "Final hand"
        end
    end
}

-- 22. Symmetrical Joker
jd_def["j_Witch_brew_symmetrical_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Flush 4+)" }
    },
    calc_function = function(card)
        local text, poker_hands, scoring_hand = JokerDisplay.evaluate_hand()
        local is_poker = poker_hands and ((poker_hands['Four of a Kind'] and next(poker_hands['Four of a Kind'])) or
                                          (poker_hands['Five of a Kind'] and next(poker_hands['Five of a Kind'])) or
                                          (poker_hands['Flush Five'] and next(poker_hands['Flush Five'])))
        if text ~= 'Unknown' and is_poker and scoring_hand and #scoring_hand >= 4 then
            local first_suit = scoring_hand[1] and scoring_hand[1].base and scoring_hand[1].base.suit
            local same = true
            for _, c in ipairs(scoring_hand) do
                if not c.base or c.base.suit ~= first_suit then
                    same = false
                    break
                end
            end
            if same then
                card.joker_display_values.x_mult = card.ability.extra.xmult or 4.0
                card.joker_display_values.active = true
                return
            end
        end
        card.joker_display_values.x_mult = 1.0
        card.joker_display_values.active = false
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- 23. Balance
jd_def["j_Witch_brew_balance_joker"] = {
    text = {
        { text = "+2 Spectrals", colour = G.C.SECONDARY_SET.Spectral }
    },
    reminder_text = {
        { text = "(Flush 4)" }
    },
    calc_function = function(card)
        local text, poker_hands, scoring_hand = JokerDisplay.evaluate_hand()
        local is_four = poker_hands and poker_hands['Four of a Kind'] and next(poker_hands['Four of a Kind'])
        if text ~= 'Unknown' and is_four and scoring_hand and #scoring_hand == 4 then
            local first_suit = scoring_hand[1] and scoring_hand[1].base and scoring_hand[1].base.suit
            local same = true
            for _, c in ipairs(scoring_hand) do
                if not c.base or c.base.suit ~= first_suit then
                    same = false
                    break
                end
            end
            if same then
                card.joker_display_values.active = true
                return
            end
        end
        card.joker_display_values.active = false
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.SECONDARY_SET.Spectral or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- 24. Merchant
jd_def["j_Witch_brew_merchant_joker"] = {
    text = {
        { text = "-$" },
        { ref_table = "card.ability.extra", ref_value = "cost_per_shop" }
    },
    text_config = { colour = G.C.RED }
}

-- 25. Lover (Soulmates)
jd_def["j_Witch_brew_lover_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "main_text" }
    },
    text_config = { colour = G.C.HEARTS },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local sm1, sm2 = (type(get_or_pick_soulmates) == 'function' and get_or_pick_soulmates()) or nil, nil
        local s1 = format_short_card(sm1)
        local s2 = format_short_card(sm2)
        local has_sm1, has_sm2 = false, false
        local heart_count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                if c == sm1 then has_sm1 = true end
                if c == sm2 then has_sm2 = true end
                if c:is_suit('Hearts') then
                    heart_count = heart_count + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end

        if has_sm1 and has_sm2 then
            card.joker_display_values.main_text = "X3 Mult +$6"
            card.joker_display_values.rem = s1 .. " & " .. s2
            card.joker_display_values.active = true
        elseif heart_count > 0 then
            card.joker_display_values.main_text = "+" .. (heart_count * 10) .. " Mult"
            card.joker_display_values.rem = s1 .. " & " .. s2
            card.joker_display_values.active = true
        else
            card.joker_display_values.main_text = "X3 +$6"
            card.joker_display_values.rem = s1 .. " & " .. s2
            card.joker_display_values.active = false
        end
    end
}

-- 26. Blacksmith
jd_def["j_Witch_brew_blacksmith_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "heat_status" }
    },
    text_config = { colour = G.C.ORANGE },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local cur = (card.ability and card.ability.extra and card.ability.extra.temp) or 0
        local max_t = (card.ability and card.ability.extra and card.ability.extra.max_temp) or 100
        local per_card = (card.ability and card.ability.extra and card.ability.extra.heat_per_card) or 10
        local projected = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            projected = #scoring_hand * per_card
        end
        local total = cur + projected
        if total >= max_t then
            card.joker_display_values.heat_status = "READY!"
            card.joker_display_values.rem = max_t .. "/" .. max_t
            card.joker_display_values.active = true
        else
            card.joker_display_values.heat_status = cur .. "/" .. max_t
            card.joker_display_values.rem = projected > 0 and ("+" .. projected) or ("+" .. per_card .. "/card")
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.GOLD or G.C.ORANGE
        end
    end
}

-- 27. Lucky One
jd_def["j_Witch_brew_lucky_one_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "clubs_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra
        local clubs = (ex and ex.clubs_scored) or 0
        local is_guar = (ex and ex.guaranteed) or (G.GAME and G.GAME.lucky_one_guaranteed)
        card.joker_display_values.x_mult = (ex and ex.xmult) or 1.5
        card.joker_display_values.clubs_str = is_guar and "Guaranteed!" or (clubs .. "/5 ♣")
        card.joker_display_values.active = is_guar
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = G.C.XMULT
        end
        if reminder_text and reminder_text.children and reminder_text.children[2] then
            reminder_text.children[2].config.colour = card.joker_display_values.active and G.C.GREEN or G.C.CLUBS
        end
    end
}

-- 28. Miner
jd_def["j_Witch_brew_miner_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "bonus_str" }
    },
    text_config = { colour = G.C.DIAMONDS },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "depth_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local d = (card.ability and card.ability.extra and card.ability.extra.depth) or 0
        card.joker_display_values.depth_str = d .. "/1000m"
        if d >= 300 then
            card.joker_display_values.bonus_str = "X1.5 + Retrigger"
            card.joker_display_values.active = true
        elseif d >= 120 then
            card.joker_display_values.bonus_str = "X1.35 Mult"
            card.joker_display_values.active = true
        elseif d >= 50 then
            card.joker_display_values.bonus_str = "+$2"
            card.joker_display_values.active = true
        else
            card.joker_display_values.bonus_str = "+25 Chips"
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.GOLD or G.C.CHIPS
        end
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand or not scoring_hand then return 0 end
        local d = (joker_card.ability and joker_card.ability.extra and joker_card.ability.extra.depth) or 0
        if d >= 300 and playing_card:is_suit('Diamonds') and JokerDisplay.in_scoring(playing_card, scoring_hand) then
            return 1 * JokerDisplay.calculate_joker_triggers(joker_card)
        end
        return 0
    end
}

-- 29. Joke Joker
jd_def["j_Witch_brew_joke_joker"] = {
    text = {
        { text = "+1 Slot", colour = G.C.SECONDARY_SET.Voucher }
    }
}

-- 30. Perfectionism
jd_def["j_Witch_brew_perfectionism_joker"] = {
    text = {
        { text = "+Polychrome", colour = G.C.DARK_EDITION }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local is_big_or_boss = false
        if G.GAME and G.GAME.blind then
            if G.GAME.blind.boss or G.GAME.blind.name == 'Big Blind' or G.GAME.blind.key == 'b_big' or (G.GAME.blind.get_type and G.GAME.blind:get_type() == 'Big') then
                is_big_or_boss = true
            end
        end
        card.joker_display_values.rem = is_big_or_boss and "Active" or "Inactive"
        card.joker_display_values.active = is_big_or_boss
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.DARK_EDITION or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- 31. Reaper Joker (Parca)
jd_def["j_Witch_brew_reaper_joker"] = {
    text = {
        { text = "+Invisible", colour = G.C.PURPLE }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local used = card.ability and card.ability.extra and card.ability.extra.used
        card.joker_display_values.rem = used and "0/1" or "1/1"
        card.joker_display_values.active = not used
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.PURPLE or G.C.UI.TEXT_INACTIVE
        end
    end
}
jd_def["j_Witch_brew_parca_joker"] = jd_def["j_Witch_brew_reaper_joker"]

-- 32. Infostealer Joker
jd_def["j_Witch_brew_infostealer_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            }
        }
    }
}

-- 33. Supersaturated Joker (Sobresaturado)
jd_def["j_Witch_brew_oversaturated_joker"] = {
    text = {
        { text = "+Enh / Seal / Ed", colour = G.C.SECONDARY_SET.Enhanced }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local used = card.ability and card.ability.extra and card.ability.extra.used
        card.joker_display_values.rem = used and "Used" or "1 card"
        card.joker_display_values.active = not used
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.SECONDARY_SET.Enhanced or G.C.UI.TEXT_INACTIVE
        end
    end
}
jd_def["j_Witch_brew_sobresaturado_joker"] = jd_def["j_Witch_brew_oversaturated_joker"]

-- Radiation
jd_def["j_Witch_brew_radiation"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "debuff_risk" },
        { text = ")" }
    },
    calc_function = function(card)
        local prob = (G.GAME and G.GAME.probabilities.normal) or 1
        local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 5
        card.joker_display_values.debuff_risk = "" .. prob .. " in " .. odds .. " debuff"
    end
}
jd_def["j_Witch_brew_radiacion"] = jd_def["j_Witch_brew_radiation"]

-- Secret Jokers, JokerDisplay definitions

-- 34. Esteban
jd_def["j_Witch_brew_esteban"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(♠ / ♣)" }
    },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                if c:is_suit('Spades') or c:is_suit('Clubs') then
                    count = count + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end
        local per = (card.ability and card.ability.extra and card.ability.extra.xmult) or 2.5
        card.joker_display_values.x_mult = count > 0 and (per ^ count) or 1.0
        card.joker_display_values.active = (count > 0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- 35. Thiago
jd_def["j_Witch_brew_thiago"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Per 20 Chips)" }
    },
    calc_function = function(card)
        local current_chips = (hand_chips and hand_chips > 0 and hand_chips) or 0
        if current_chips == 0 then
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' and G.GAME and G.GAME.hands and G.GAME.hands[text] then
                current_chips = G.GAME.hands[text].chips or 0
                if scoring_hand then
                    for _, c in ipairs(scoring_hand) do
                        current_chips = current_chips + (c.base and c.base.nominal or 0)
                    end
                end
            end
        end
        local req = (card.ability and card.ability.extra and card.ability.extra.chips_per_xmult) or 20
        local x = math.floor(current_chips / req)
        card.joker_display_values.x_mult = math.max(1, x)
        card.joker_display_values.active = (x > 1)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- 36. Black Hole
jd_def["j_Witch_brew_black_hole_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "^" },
                { ref_table = "card.ability.extra", ref_value = "pow" }
            },
            border_colour = G.C.DARK_EDITION
        }
    }
}

-- 37. Squele
jd_def["j_Witch_brew_squele"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT, retrigger_type = "mult" },
        { text = " " },
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(♥)" }
    },
    calc_function = function(card)
        local hearts = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                if c:is_suit('Hearts') then
                    hearts = hearts + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end
        card.joker_display_values.mult = hearts * (card.ability.extra.mult or 10)
        card.joker_display_values.x_mult = hearts > 0 and ((card.ability.extra.xmult or 1.5) ^ hearts) or 1.0
        card.joker_display_values.active = (hearts > 0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[4] then
            text.children[4].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- 38. Bluxdir
jd_def["j_Witch_brew_bluxdir"] = {
    text = {
        { text = "+1 Level", colour = G.C.ATTENTION }
    },
    reminder_text = {
        { text = "(Discard)" }
    }
}

-- 39. Charles
jd_def["j_Witch_brew_charles"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        },
        { text = " +$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars", colour = G.C.MONEY, retrigger_type = "mult" }
    },
    reminder_text = {
        { text = "(♠ / ♥)" }
    },
    calc_function = function(card)
        local has_mochi = has_charles_and_mochi_jd()
        local suit_count = 0
        local card_count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            card_count = #scoring_hand
            for _, c in ipairs(scoring_hand) do
                local triggers = JokerDisplay.calculate_card_triggers(c, scoring_hand)
                if c:is_suit('Spades') or c:is_suit('Hearts') then
                    suit_count = suit_count + triggers
                end
            end
        end
        local dollars_per = (card.ability.extra.dollars or 5) * (has_mochi and 2 or 1)
        card.joker_display_values.dollars = card_count * dollars_per
        card.joker_display_values.x_mult = suit_count > 0 and ((card.ability.extra.xmult or 2) ^ suit_count) or 1.0
        card.joker_display_values.active = (suit_count > 0 or card_count > 0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand or not scoring_hand then return 0 end
        if has_charles_and_mochi_jd() and JokerDisplay.in_scoring(playing_card, scoring_hand) then
            return 1 * JokerDisplay.calculate_joker_triggers(joker_card)
        end
        return 0
    end
}

-- 40. Mochi
jd_def["j_Witch_brew_mochi"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "wild_count" },
        { text = " Wild)" }
    },
    calc_function = function(card)
        local wild_count = 0
        if G.playing_cards then
            for _, pcard in ipairs(G.playing_cards) do
                if is_wild_card(pcard) then wild_count = wild_count + 1 end
            end
        end
        local gain = (card.ability and card.ability.extra and card.ability.extra.xmult_gain) or 0.25
        card.joker_display_values.wild_count = wild_count
        card.joker_display_values.x_mult = 1.0 + (wild_count * gain)
    end
}

-- 41. Helin
jd_def["j_Witch_brew_helin"] = {
    text = {
        {
            border_nodes = {
                { text = "^" },
                { ref_table = "card.ability.extra", ref_value = "power" }
            },
            border_colour = G.C.DARK_EDITION
        }
    },
    reminder_text = {
        { text = "(End of Scoring)" }
    }
}

-- 42. RayTracing
jd_def["j_Witch_brew_raytracing"] = {
    text = {
        { text = "+2 Spectrals", colour = G.C.DARK_EDITION }
    },
    reminder_text = {
        { text = "(Negative)" }
    }
}

-- 43. Paco
jd_def["j_Witch_brew_paco"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "discards" },
        { text = " Discards)" }
    },
    calc_function = function(card)
        local discards = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        local per = (card.ability and card.ability.extra and card.ability.extra.xmult_per_discard) or 2
        card.joker_display_values.discards = discards
        card.joker_display_values.x_mult = math.max(1, discards * per)
        card.joker_display_values.active = (discards > 0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- 44. Yairo
jd_def["j_Witch_brew_yairo"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            },
            border_colour = G.C.MULT
        },
        { text = " " },
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_chips", retrigger_type = "exp" }
            },
            border_colour = G.C.CHIPS
        }
    },
    reminder_text = {
        { text = "(6 & 7)" }
    },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                local id = (c.get_id and c:get_id()) or (c.base and c.base.id)
                local val = c.base and c.base.value
                if id == 6 or id == 7 or val == '6' or val == '7' then
                    count = count + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end
        local mult_per = (card.ability and card.ability.extra and card.ability.extra.xmult) or 3
        local chips_per = (card.ability and card.ability.extra and card.ability.extra.xchips) or 1.5
        card.joker_display_values.x_mult = count > 0 and (mult_per ^ count) or 1.0
        card.joker_display_values.x_chips = count > 0 and (chips_per ^ count) or 1.0
        card.joker_display_values.active = (count > 0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.MULT or G.C.UI.TEXT_INACTIVE
        end
        if text and text.children and text.children[3] then
            text.children[3].config.colour = card.joker_display_values.active and G.C.CHIPS or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- Kyra (Secret)
jd_def["j_Witch_brew_kyra"] = {
    text = {
        { text = "Brew Potion", colour = G.C.GREEN }
    },
    reminder_text = {
        { text = "($2)" }
    },
    calc_function = function(card)
        local cur_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
        local has_room = G.consumeables and (#G.consumeables.cards + (G.GAME.consumeable_buffer or 0) < G.consumeables.config.card_limit)
        card.joker_display_values.active = (cur_dollars >= 2 and has_room)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.GREEN or G.C.UI.TEXT_INACTIVE
        end
    end
}


-- Additional Jokers, JokerDisplay definitions

-- Discard Accumulator
jd_def["j_Witch_brew_discard_accumulator"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "chips" },
        { text = " / +" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "discards_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.chips = ex.chips or 0
        card.joker_display_values.mult = ex.mult or 0
        local disc = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        card.joker_display_values.discards_str = disc .. " disc."
    end
}

-- Beat It
jd_def["j_Witch_brew_beat_it"] = {
    text = {
        { text = "-50% Blind", colour = G.C.FILTER }
    },
    reminder_text = {
        { text = "(+1 Disc.)" }
    }
}

-- Puppet Joker
jd_def["j_Witch_brew_puppet_joker"] = {
    text = {
        { text = "Puppet Active", colour = G.C.PURPLE }
    },
    reminder_text = {
        { text = "(Blind Start)" }
    }
}

-- Amnesia Joker
jd_def["j_Witch_brew_amnesia_joker"] = {
    text = {
        { text = "Amnesia", colour = G.C.SECONDARY_SET.Enhanced }
    },
    reminder_text = {
        { text = "(Level Swap)" }
    }
}

-- Photographer Joker
jd_def["j_Witch_brew_photographer_joker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(Snap 1st)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.mult = ex.mult or 10
    end
}

-- Countdown Joker
jd_def["j_Witch_brew_countdown_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "count_str" }
    },
    reminder_text = {
        { text = "(Countdown)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local cnt = ex.counter or 10
        card.joker_display_values.count_str = cnt .. "/10"
        card.joker_display_values.active = (cnt == 0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.RED or G.C.FILTER
        end
    end
}

-- Smuggler Joker
jd_def["j_Witch_brew_smuggler_joker"] = {
    text = {
        { text = "+1 Enhance", colour = G.C.GREEN }
    },
    reminder_text = {
        { text = "(Blind Start)" }
    }
}

-- Sheet Music Joker
jd_def["j_Witch_brew_sheet_music_joker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "chips" },
        { text = " / +" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS },
    reminder_text = {
        { text = "(Straight / Str. Flush)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.chips = ex.chips or 80
        card.joker_display_values.mult = ex.mult or 40
    end
}

-- Blood Pact Joker
jd_def["j_Witch_brew_blood_pact_joker"] = {
    text = {
        { text = "+1 Edition", colour = G.C.DARK_EDITION }
    },
    reminder_text = {
        { text = "(-$2 / Blind)", colour = G.C.RED }
    }
}

-- Saboteur Joker
jd_def["j_Witch_brew_saboteur_joker"] = {
    text = {
        { text = "Debt " },
        { ref_table = "card.joker_display_values", ref_value = "debt_str" }
    },
    reminder_text = {
        { text = "(Multi-Hand)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.debt_str = "$" .. (ex.debt or 0)
    end
}

-- Boomerang Joker
jd_def["j_Witch_brew_boomerang_joker"] = {
    text = {
        { text = "Boomerang", colour = G.C.BLUE }
    },
    reminder_text = {
        { text = "(Returns Cards)" }
    }
}

-- Spy Joker
jd_def["j_Witch_brew_spy_joker"] = {
    text = {
        { text = "Spy 3 Cards", colour = G.C.SECONDARY_SET.Enhanced }
    },
    reminder_text = {
        { text = "(Blind Start)" }
    }
}

-- Apprentice Joker
jd_def["j_Witch_brew_apprentice_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "cast_str" }
    },
    reminder_text = {
        { text = "(Right Joker)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.cast_str = (ex.count or 0) .. " Casts"
    end
}

-- Upgrade Roulette Joker
jd_def["j_Witch_brew_upgrade_roulette_joker"] = {
    text = {
        { text = "Roulette Upgrade", colour = G.C.PURPLE }
    },
    reminder_text = {
        { text = "(Round End)" }
    }
}

-- Reversed Hermit Joker
jd_def["j_Witch_brew_reversed_hermit_joker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" }
    },
    text_config = { colour = G.C.MONEY },
    reminder_text = {
        { text = "(Remaining Discards)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local disc = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        local rate = ex.dollars_per_discard or 2
        card.joker_display_values.dollars = disc * rate
    end
}

-- Script Joker
jd_def["j_Witch_brew_script_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "step_str" }
    },
    reminder_text = {
        { text = "(Script: +$12)", colour = G.C.MONEY }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local prog = ex.progress or 0
        local script = ex.script or {}
        if ex.completed then
            card.joker_display_values.step_str = "Complete! (+$12)"
        elseif prog < 3 and script[prog + 1] then
            card.joker_display_values.step_str = (prog) .. "/3: " .. tostring(script[prog + 1])
        else
            card.joker_display_values.step_str = (prog) .. "/3 Script"
        end
    end
}

-- Reading Deficiency Joker (English / Legacy alias)
jd_def["j_Witch_brew_reading_deficiency_joker"] = jd_def["j_Witch_brew_falta_de_lectura_joker"] or {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Solo Joker)" }
    },
    calc_function = function(card)
        local count = (G.jokers and G.jokers.cards and #G.jokers.cards) or 1
        card.joker_display_values.x_mult = (count == 1) and 5.0 or 1.0
        card.joker_display_values.active = (count == 1)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- Billie Jean
jd_def["j_Witch_brew_billie_jean"] = {
    text = {
        { text = "1/8 Polychrome", colour = G.C.DARK_EDITION }
    },
    reminder_text = {
        { text = "(Scored Cards)" }
    }
}

-- Temporal Rift
jd_def["j_Witch_brew_temporal_rift"] = {
    text = {
        { text = "Rewind Defeat", colour = G.C.ORANGE }
    },
    reminder_text = {
        { text = "(Single Use)" }
    }
}

-- Polarity Inversion
jd_def["j_Witch_brew_polarity_inversion"] = {
    text = {
        { text = "+10 Mult Invert", colour = G.C.MULT }
    },
    reminder_text = {
        { text = "(Debuffed Cards)" }
    }
}

-- Inheritance
jd_def["j_Witch_brew_inheritance"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(Inheritance)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.mult = ex.mult or 2
    end
}

-- Ecosystem
jd_def["j_Witch_brew_ecosystem"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "eco_str" }
    },
    reminder_text = {
        { text = "(Dom X1.5 / Rare +80)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local dom = ex.dominant and ex.dominant ~= '' and ex.dominant or '?'
        local rare = ex.rarest and ex.rarest ~= '' and ex.rarest or '?'
        card.joker_display_values.eco_str = dom .. " / " .. rare
    end
}

-- Auctioneer
jd_def["j_Witch_brew_auctioneer"] = {
    text = {
        { text = "Auction", colour = G.C.GOLD }
    },
    reminder_text = {
        { text = "(5 Bidders, 1 in 5 Chance)" }
    }
}

-- Parasitic
jd_def["j_Witch_brew_parasitic"] = {
    text = {
        { text = "X1.75 Host Joker", colour = G.C.XMULT }
    },
    reminder_text = {
        { text = "(Migrates 3 Rnds)" }
    }
}

-- Mercenary
jd_def["j_Witch_brew_mercenary"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "contract_str" }
    },
    reminder_text = {
        { text = "(Complete Contracts)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local contracts = ex.contracts or {}
        if #contracts > 0 and contracts[1] then
            card.joker_display_values.contract_str = "Contract: " .. tostring(contracts[1].name or 'Active')
        else
            card.joker_display_values.contract_str = "No Contracts"
        end
    end
}

-- Cascade
jd_def["j_Witch_brew_cascade"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "chips" }
    },
    text_config = { colour = G.C.CHIPS },
    reminder_text = {
        { text = "(First Hand of Blind)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.chips = ex.stored_chips or 0
    end
}

-- 24K Magic
jd_def["j_Witch_brew_24k_magic"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Gold Cards)" }
    },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        local count = 0
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                if SMODS.has_enhancement(c, 'm_gold') then
                    count = count + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end
        card.joker_display_values.x_mult = count > 0 and (2.0 ^ count) or 1.0
        card.joker_display_values.active = count > 0
    end
}

-- Orchestra Director
jd_def["j_Witch_brew_orchestra_director"] = {
    text = {
        { text = "Free Shop Joker", colour = G.C.MONEY }
    },
    reminder_text = {
        { text = "(1 in 4 Chance)" }
    }
}

-- Meteorologist
jd_def["j_Witch_brew_meteorologist"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "weather_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local w = ex.weather or 'None'
        local xm = 3.0
        if w == 'Storm' then xm = 3.5
        elseif w == 'Sun' then xm = 2.5 end
        card.joker_display_values.x_mult = xm
        card.joker_display_values.weather_str = (w ~= '' and w) or "Weather"
    end
}

-- Mad Clockmaker
jd_def["j_Witch_brew_mad_clockmaker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(Remaining Discards)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local disc = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        local mult_per = ex.mult_per_discard or 14
        card.joker_display_values.mult = disc * mult_per
    end
}

-- Catalyst
jd_def["j_Witch_brew_catalyst"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            },
            border_colour = G.C.XMULT
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "odds" },
        { text = " Retrigger)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.x_mult = ex.x_mult or 2.5
        local prob = (G.GAME and G.GAME.probabilities.normal) or 1
        card.joker_display_values.odds = "" .. prob .. "/" .. (ex.odds or 3)
    end
}

-- Graffiti Artist
jd_def["j_Witch_brew_graffiti_artist"] = {
    text = {
        { text = "X1.5", colour = G.C.XMULT }
    },
    reminder_text = {
        { text = "(Paints Card)" }
    }
}

-- Hypnotist
jd_def["j_Witch_brew_hypnotist"] = {
    text = {
        { text = "Disable Boss Blind", colour = G.C.PURPLE }
    },
    reminder_text = {
        { text = "(1 in 3 Chance)" }
    }
}

-- Hand Alchemist
jd_def["j_Witch_brew_hand_alchemist"] = {
    text = {
        { text = "+1 Planet", colour = G.C.PLANET }
    },
    reminder_text = {
        { text = "(Round End)" }
    }
}

-- Entomologist
jd_def["j_Witch_brew_entomologist"] = {
    text = {
        { text = "Insect Tokens", colour = G.C.GREEN }
    },
    reminder_text = {
        { text = "(Tokens on Cards)" }
    }
}

-- World Devourer (Legendary)
jd_def["j_Witch_brew_world_devourer"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "blinds_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.x_mult = ex.xmult or 1
        card.joker_display_values.blinds_str = (ex.blinds_defeated or 0) .. " Blinds"
    end
}

-- Living Paradox (Legendary)
jd_def["j_Witch_brew_living_paradox"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "next_str", colour = G.C.DARK_EDITION }
    },
    reminder_text = {
        { text = "(Next Boss Negative)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local name = "Random"
        if ex.next_joker and G.P_CENTERS and G.P_CENTERS[ex.next_joker] then
            local center = G.P_CENTERS[ex.next_joker]
            name = (localize and localize{type = 'name_text', key = center.key, set = 'Joker'}) or center.name or ex.next_joker
        end
        card.joker_display_values.next_str = name
    end
}

-- Star Chronicler (Legendary)
jd_def["j_Witch_brew_star_chronicler"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult" }
            }
        }
    },
    reminder_text = {
        { text = "(Planets & Black Holes)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local planet_count = 0
        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Planet then
            for _, p in ipairs(G.P_CENTER_POOLS.Planet) do
                if p.discovered then planet_count = planet_count + 1 end
            end
        end
        local base_xm = 1 + planet_count * (ex.xmult_per_planet or 0.5)
        local total_xm = base_xm * (ex.black_hole_mult or 1)
        card.joker_display_values.x_mult = string.format('%.1f', total_xm)
    end
}

-- Secrets and Amalgams, JokerDisplay definitions

-- Astra
jd_def["j_Witch_brew_astra"] = {
    text = {
        { text = "2X Planets", colour = G.C.SECONDARY_SET.Planet }
    },
    reminder_text = {
        { text = "(Black Hole +3)" }
    }
}

-- Marie
jd_def["j_Witch_brew_marie"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Enhanced Cards)" }
    },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        local count = 0
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                local c_enh = (c.config and c.config.center and c.config.center ~= G.P_CENTERS.c_base and c.config.center.set == 'Enhanced') or (c.ability and c.ability.set == 'Enhanced')
                if c_enh then
                    local base_triggers = JokerDisplay.calculate_card_triggers(c, scoring_hand)
                    local has_seal = (c.seal ~= nil and c.seal ~= '')
                    local has_ed = (c.edition ~= nil and not c.edition.base)
                    local extra_reps = (has_seal and 1 or 0) + (has_ed and 1 or 0)
                    count = count + base_triggers + extra_reps
                end
            end
        end
        local ex = card.ability and card.ability.extra or {}
        local mult_per = ex.x_mult or 2
        card.joker_display_values.x_mult = count > 0 and (mult_per ^ count) or 1.0
        card.joker_display_values.active = count > 0
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand or not scoring_hand then return 0 end
        if not JokerDisplay.in_scoring(playing_card, scoring_hand) then return 0 end
        local has_seal = (playing_card.seal ~= nil and playing_card.seal ~= '')
        local has_ed = (playing_card.edition ~= nil and not playing_card.edition.base)
        local reps = (has_seal and 1 or 0) + (has_ed and 1 or 0)
        return reps * JokerDisplay.calculate_joker_triggers(joker_card)
    end
}

-- Callie
jd_def["j_Witch_brew_callie"] = {
    text = {
        { text = "Random Upgrade", colour = G.C.GOLD }
    },
    reminder_text = {
        { text = "(1x per card)" }
    }
}

-- Sally
jd_def["j_Witch_brew_sally"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "quest_str" }
    },
    reminder_text = {
        { text = "(Reward: +$10)", colour = G.C.MONEY }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local prog = ex.progress or 0
        local need = ex.needed or 3
        local quest = ex.quest or "Play 3 Hands"
        if ex.completed then
            card.joker_display_values.quest_str = "Completed!"
        else
            card.joker_display_values.quest_str = quest .. " (" .. prog .. "/" .. need .. ")"
        end
    end
}

-- Brainprint (Brainstorm + Blueprint)
jd_def["j_Witch_brew_brainprint"] = {
    text = {
        { text = "Copies Left & Right", colour = G.C.BLUE }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "copy_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local left_name = "None"
        local right_name = "None"
        if G.jokers and G.jokers.cards then
            local my_idx = nil
            for idx, j in ipairs(G.jokers.cards) do
                if j == card then my_idx = idx; break end
            end
            if my_idx then
                local lj = (my_idx > 1) and G.jokers.cards[my_idx - 1]
                local rj = (my_idx < #G.jokers.cards) and G.jokers.cards[my_idx + 1]
                if lj and lj.config and lj.config.center then
                    left_name = (localize and localize{type = 'name_text', key = lj.config.center.key, set = 'Joker'}) or lj.ability.name or "Left"
                end
                if rj and rj.config and rj.config.center then
                    right_name = (localize and localize{type = 'name_text', key = rj.config.center.key, set = 'Joker'}) or rj.ability.name or "Right"
                end
            end
        end
        card.joker_display_values.copy_str = left_name .. " + " .. right_name
    end
}

-- Vampiric Midas (Vampire + Midas)
jd_def["j_Witch_brew_vampiric_midas"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Gold Drain)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.x_mult = ex.xmult or 1.0
    end
}

-- Certified Programming (Certificate + Coding)
jd_def["j_Witch_brew_certified_programming"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(+2 Cards w/ Seal)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.x_mult = ex.xmult or 1.0
    end
}

-- Galactic Traveler (Astronomer + Satellite)
jd_def["j_Witch_brew_galactic_traveler"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Free Planets)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.x_mult = ex.xmult or 1.0
    end
}

-- Colorful Street (Four Fingers + Shortcut + Smeared)
jd_def["j_Witch_brew_colorful_street"] = {
    text = {
        { text = "4-Card Straights & Flushes", colour = G.C.ATTENTION }
    },
    reminder_text = {
        { text = "(Shortcut + Smeared)" }
    }
}

-- Mime King (Baron + Mime)
jd_def["j_Witch_brew_mime_king"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Held Kings 2X, Reps +2)" }
    },
    calc_function = function(card)
        local count = 0
        if G.hand and G.hand.cards then
            for _, c in ipairs(G.hand.cards) do
                if not c.highlighted then
                    local id = (c.get_id and c:get_id()) or (c.base and c.base.id)
                    if id == 13 then
                        count = count + 3
                    end
                end
            end
        end
        local ex = card.ability and card.ability.extra or {}
        local mult_per = ex.x_mult or 2
        card.joker_display_values.x_mult = count > 0 and (mult_per ^ count) or 1.0
        card.joker_display_values.active = count > 0
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if not held_in_hand then return 0 end
        return 2 * JokerDisplay.calculate_joker_triggers(joker_card)
    end
}

-- Photo Album (Photograph + Hanging Chad)
jd_def["j_Witch_brew_photo_album"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            },
            border_colour = G.C.XMULT
        }
    },
    reminder_text = {
        { text = "(1st Card +3, Face +1)" }
    },
    calc_function = function(card)
        local _, _, scoring_hand = JokerDisplay.evaluate_hand()
        local has_face = false
        if scoring_hand then
            for _, c in ipairs(scoring_hand) do
                if c.is_face and c:is_face() then
                    has_face = true
                    break
                end
            end
        end
        local xm = (card.ability and card.ability.extra and card.ability.extra.x_mult) or 2.5
        card.joker_display_values.x_mult = has_face and xm or 1.0
        card.joker_display_values.active = has_face
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand or not scoring_hand then return 0 end
        local reps = 0
        if playing_card == scoring_hand[1] then
            reps = reps + 3
        end
        if playing_card.is_face and playing_card:is_face() then
            reps = reps + 1
        end
        return reps * JokerDisplay.calculate_joker_triggers(joker_card)
    end
}

-- Pirate Egg (Egg + Swashbuckler)
jd_def["j_Witch_brew_pirate_egg"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(+$" },
        { ref_table = "card.joker_display_values", ref_value = "val" },
        { text = " Value)" }
    },
    reminder_text_config = { colour = G.C.MONEY },
    calc_function = function(card)
        local total_sell = 0
        if G.jokers and G.jokers.cards then
            for _, jk in ipairs(G.jokers.cards) do
                total_sell = total_sell + (jk.sell_cost or 1)
            end
        end
        local xm = 1 + total_sell * 0.1
        card.joker_display_values.x_mult = string.format('%.1f', xm)
        card.joker_display_values.val = card.sell_cost or 1
    end
}

-- Reinforced Boots (Bootstraps + Bull)
jd_def["j_Witch_brew_reinforced_boots"] = {
    text = {
        { text = "+", colour = G.C.CHIPS },
        { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS, retrigger_type = "chips" },
        { text = " +", colour = G.C.MULT },
        { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT, retrigger_type = "mult" }
    },
    reminder_text = {
        { text = "(Per $1)" }
    },
    calc_function = function(card)
        local dollars = math.max(0, (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0)
        card.joker_display_values.chips = dollars * 5
        card.joker_display_values.mult = dollars * 10
    end
}

-- Wee Comedian (Wee Joker + Comedian)
jd_def["j_Witch_brew_wee_comedian"] = {
    text = {
        { text = "+", colour = G.C.CHIPS },
        { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS, retrigger_type = "chips" },
        { text = " +", colour = G.C.MULT },
        { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT, retrigger_type = "mult" }
    },
    reminder_text = {
        { text = "(Fibonacci + 2s)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.chips = ex.chips or 0
        local fib_mult = 0
        local _, _, scoring_hand = JokerDisplay.evaluate_hand()
        if scoring_hand then
            for _, c in ipairs(scoring_hand) do
                local id = c:get_id()
                if id == 14 or id == 2 or id == 3 or id == 5 or id == 8 then
                    fib_mult = fib_mult + 16 * JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end
        card.joker_display_values.mult = fib_mult
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand or not scoring_hand then return 0 end
        if playing_card:get_id() == 2 and JokerDisplay.in_scoring(playing_card, scoring_hand) then
            return 2 * JokerDisplay.calculate_joker_triggers(joker_card)
        end
        return 0
    end
}

-- Golden Lucky Cat (Lucky Cat + Golden Joker)
jd_def["j_Witch_brew_golden_lucky_cat"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(+2 Probabilities)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.x_mult = ex.x_mult or 1.0
    end
}

-- Unrecognizable Antique (Ancient Joker + Smeared Joker)
jd_def["j_Witch_brew_unrecognizable_antique"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            },
            border_colour = G.C.XMULT
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "group_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local group = ex.suit_group or "Red"
        card.joker_display_values.group_str = (group == 'Red') and "♥ / ♦" or "♠ / ♣"
        local count = 0
        local _, _, scoring_hand = JokerDisplay.evaluate_hand()
        if scoring_hand then
            for _, c in ipairs(scoring_hand) do
                local match = false
                if group == 'Red' then
                    match = c:is_suit('Hearts') or c:is_suit('Diamonds')
                else
                    match = c:is_suit('Spades') or c:is_suit('Clubs')
                end
                if match then
                    count = count + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end
        card.joker_display_values.x_mult = count > 0 and (2 ^ count) or 1.0
        card.joker_display_values.active = (count > 0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- Macabre Emoji (Scary Face + Smiley Face)
jd_def["j_Witch_brew_macabre_emoji"] = {
    text = {
        { text = "+", colour = G.C.CHIPS },
        { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS, retrigger_type = "chips" },
        { text = " +", colour = G.C.MULT },
        { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT, retrigger_type = "mult" }
    },
    reminder_text = {
        { text = "(Face Cards)" }
    },
    calc_function = function(card)
        local count = 0
        local _, _, scoring_hand = JokerDisplay.evaluate_hand()
        if scoring_hand then
            for _, c in ipairs(scoring_hand) do
                if c.is_face and c:is_face() then
                    count = count + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end
        card.joker_display_values.chips = count * 100
        card.joker_display_values.mult = count * 20
        card.joker_display_values.active = count > 0
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children then
            local col = card.joker_display_values.active and G.C.CHIPS or G.C.UI.TEXT_INACTIVE
            local mcol = card.joker_display_values.active and G.C.MULT or G.C.UI.TEXT_INACTIVE
            if text.children[1] then text.children[1].config.colour = col end
            if text.children[2] then text.children[2].config.colour = col end
            if text.children[3] then text.children[3].config.colour = mcol end
            if text.children[4] then text.children[4].config.colour = mcol end
        end
    end
}

-- Universal Aliasing, Key resolver
local cross_aliases = {
    ['disenador_joker'] = 'designer_joker',
    ['designer_joker'] = 'disenador_joker',
    ['falta_de_lectura_joker'] = 'reading_deficiency_joker',
    ['reading_deficiency_joker'] = 'falta_de_lectura_joker',
    ['duelo_de_valores_joker'] = 'duel_of_value_joker',
    ['duel_of_value_joker'] = 'duelo_de_valores_joker',
    ['midas_vampirico'] = 'vampiric_midas',
    ['vampiric_midas'] = 'midas_vampirico',
    ['programacion_certificacion'] = 'certified_programming',
    ['certified_programming'] = 'programacion_certificacion',
    ['viajero_galactico'] = 'galactic_traveler',
    ['galactic_traveler'] = 'viajero_galactico',
    ['calle_colorida'] = 'colorful_street',
    ['colorful_street'] = 'calle_colorida',
    ['rey_de_mimos'] = 'mime_king',
    ['mime_king'] = 'rey_de_mimos',
    ['album_de_fotos'] = 'photo_album',
    ['photo_album'] = 'album_de_fotos',
    ['huevo_pirata'] = 'pirate_egg',
    ['pirate_egg'] = 'huevo_pirata',
    ['botas_reforzadas'] = 'reinforced_boots',
    ['reinforced_boots'] = 'botas_reforzadas',
    ['gato_dorado_suerte'] = 'golden_lucky_cat',
    ['golden_lucky_cat'] = 'gato_dorado_suerte',
    ['antiguedad_irreconocible'] = 'unrecognizable_antique',
    ['unrecognizable_antique'] = 'antiguedad_irreconocible',
    ['emoji_macabro'] = 'macabre_emoji',
    ['macabre_emoji'] = 'emoji_macabro',
}

local new_entries = {}
for k, v in pairs(jd_def) do
    if string.sub(k, 1, 15) == "j_Witch_brew_" then
        local raw = string.sub(k, 16)
        new_entries["j_" .. raw] = v
        new_entries["j_witch_brew_" .. raw] = v
        new_entries[raw] = v
        if cross_aliases[raw] then
            local target = cross_aliases[raw]
            new_entries["j_Witch_brew_" .. target] = v
            new_entries["j_witch_brew_" .. target] = v
            new_entries["j_" .. target] = v
            new_entries[target] = v
        end
    end
end
for k, v in pairs(new_entries) do
    if not jd_def[k] then
        jd_def[k] = v
    end
end

