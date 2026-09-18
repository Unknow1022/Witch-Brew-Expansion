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

-- =========================================================================
-- COMMON JOKERS (6)
-- =========================================================================

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
        card.joker_display_values.discards = G.Witch_brew_SPANISH and (discards .. " desc.") or (discards .. " disc.")
    end
}

-- =========================================================================
-- UNCOMMON JOKERS (14)
-- =========================================================================

-- 7. Shareholder Joker
jd_def["j_Witch_brew_shareholder_joker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(+$" },
        { ref_table = "card.ability.extra", ref_value = "current_price" },
        { text = ")" }
    },
    reminder_text_config = { colour = G.C.MONEY },
    calc_function = function(card)
        local price = (card.ability and card.ability.extra and card.ability.extra.current_price) or 8
        card.joker_display_values.mult = price * 2
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
                card.joker_display_values.score_text = G.Witch_brew_SPANISH and "Sin premio" or "No Match"
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
            card.joker_display_values.sub_text = ex.bet_placed and (G.Witch_brew_SPANISH and "Apostado $5" or "Bet $5") or (G.Witch_brew_SPANISH and "Apostar" or "Bet")
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
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "required_rank", colour = G.C.ATTENTION },
        { text = ")" }
    },
    calc_function = function(card)
        local req = card.ability and card.ability.extra and card.ability.extra.required_rank or 'Ace'
        local has_rank = false
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        local pool = (text ~= 'Unknown' and scoring_hand) or (G.hand and G.hand.highlighted) or {}
        for _, c in ipairs(pool) do
            local val = c.base and c.base.value
            if val == req or tostring(c:get_id()) == tostring(req) then
                has_rank = true
                break
            end
        end

        if has_rank then
            local copied_joker, copied_debuff = JokerDisplay.calculate_blueprint_copy(card)
            JokerDisplay.copy_display(card, copied_joker, copied_debuff)
        else
            JokerDisplay.copy_display(card, nil)
        end
    end,
    get_blueprint_joker = function(card)
        if not G.jokers or not G.jokers.cards then return nil end
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                return G.jokers.cards[i - 1]
            end
        end
        return nil
    end
}

-- 16. Motorized Joker
jd_def["j_Witch_brew_motorizado_joker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT }
}

-- 17. Hired Joker (Joker Contratado)
jd_def["j_Witch_brew_contratado_joker"] = {
    text = {
        { text = "Job Card", colour = HEX('5c1e11') }
    },
    reminder_text = {
        { text = "(1/3)" }
    }
}

-- 18. Seal of Approval (Sello de Aprobación)
jd_def["j_Witch_brew_sello_aprobacion_joker"] = {
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

-- 19. Paint Puddle (Charco de Pintura)
jd_def["j_Witch_brew_charco_pintura_joker"] = {
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

-- 20. Injured Joker (Joker Lesionado)
jd_def["j_Witch_brew_lesionado_joker"] = {
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
        card.joker_display_values.prob_text = "" .. prob .. (G.Witch_brew_SPANISH and " en " or " in ") .. odds
        card.joker_display_values.rem_text = G.Witch_brew_SPANISH and "(Fin de ronda)" or "(End of round)"
    end
}

-- Mano Extendida
jd_def["j_Witch_brew_mano_extendida"] = {
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

-- Hoguera
jd_def["j_Witch_brew_hoguera"] = {
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

-- =========================================================================
-- RARE JOKERS (13)
-- =========================================================================

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
            card.joker_display_values.status = G.Witch_brew_SPANISH and "Usado" or "Used"
            card.joker_display_values.rem = "0/1"
        elseif hands_left <= 1 then
            card.joker_display_values.status = G.Witch_brew_SPANISH and "+1 Mano" or "+1 Hand"
            card.joker_display_values.rem = G.Witch_brew_SPANISH and "Listo" or "Ready"
        else
            card.joker_display_values.status = G.Witch_brew_SPANISH and "+1 Mano" or "+1 Hand"
            card.joker_display_values.rem = G.Witch_brew_SPANISH and "Última mano" or "Final hand"
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
        local projected = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            projected = #scoring_hand * (card.ability.extra.heat_per_card or 5)
        end
        local total = cur + projected
        if total >= 300 then
            card.joker_display_values.heat_status = "READY!"
            card.joker_display_values.rem = "300/300"
            card.joker_display_values.active = true
        else
            card.joker_display_values.heat_status = cur .. "/300"
            card.joker_display_values.rem = projected > 0 and ("+" .. projected) or "+5/card"
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
        card.joker_display_values.clubs_str = is_guar and (G.Witch_brew_SPANISH and "¡Garantizado!" or "Guaranteed!") or (clubs .. "/5 ♣")
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
jd_def["j_Witch_brew_parca_joker"] = {
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
jd_def["j_Witch_brew_sobresaturado_joker"] = {
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
        card.joker_display_values.rem = used and (G.Witch_brew_SPANISH and "Usado" or "Used") or (G.Witch_brew_SPANISH and "1 carta" or "1 card")
        card.joker_display_values.active = not used
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.SECONDARY_SET.Enhanced or G.C.UI.TEXT_INACTIVE
        end
    end
}

-- Radiación
jd_def["j_Witch_brew_radiacion"] = {
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
        card.joker_display_values.debuff_risk = "" .. prob .. (G.Witch_brew_SPANISH and " en " or " in ") .. odds .. (G.Witch_brew_SPANISH and " debuff" or " debuff")
    end
}

-- =========================================================================
-- SECRET JOKERS (11)
-- =========================================================================

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
        { text = "(/20 Chips)" }
    },
    calc_function = function(card)
        local current_chips = (hand_chips and hand_chips > 0 and hand_chips) or 0
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
        { text = "(1st Hand)" }
    },
    calc_function = function(card)
        local is_first = G.GAME and G.GAME.current_round and G.GAME.current_round.hands_played == 0
        card.joker_display_values.active = is_first
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.DARK_EDITION or G.C.UI.TEXT_INACTIVE
        end
    end
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
        { text = "Poción", colour = G.C.GREEN }
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

-- Automatic key aliasing for universal compatibility (with and without prefix)
for k, v in pairs(jd_def) do
    if string.sub(k, 1, 15) == "j_Witch_brew_" then
        local short_k = "j_" .. string.sub(k, 16)
        if not jd_def[short_k] then
            jd_def[short_k] = v
        end
    end
end
