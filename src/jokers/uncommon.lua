-- Uncommon Jokers

-- Shareholder Joker
SMODS.Joker {
    key = 'shareholder_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Shareholder Joker',
        text = {
            "Stock value starts at {C:money}$#1#{}.",
            "Increases by {C:money}$1{}-{C:money}$5{} if Blind is defeated in {C:attention}1 hand{}.",
            "Decreases by {C:money}$1{}-{C:money}$5{} on subsequent hands played.",
            "Defeating {C:attention}Boss Blind{} pays {C:money}$#1#{} and resets to {C:money}$#3#{}.",
            "{C:inactive}(Currently gives {C:mult}+#2#{C:inactive} Mult){}"
        }
    },
    unlock = {
        "Have at least",
        "{C:money}$100{} at once"
    },
    config = { extra = { current_price = 5, initial_price = 5 } },
    rarity = 2,
    pos = { x = 0, y = 1 },
    cost = 6,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local price = (ex and ex.current_price) or 5
        return { vars = { price, price * 2, 5 } }
    end,
    check_for_unlock = function(self, args)
        local cur_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
        if cur_dollars >= 100 then
            return true
        end
    end,
    calculate = function(self, card, context)
        -- Playing subsequent hands decreases price
        if context.before and not context.blueprint and not context.individual and not context.repetition then
            if G.GAME.current_round and (G.GAME.current_round.hands_played or 0) >= 1 then
                local drop = pseudorandom('shareholder_drop', 1, 5)
                card.ability.extra.current_price = math.max(0, (card.ability.extra.current_price or 5) - drop)
                return {
                    message = '-$' .. drop .. ' (' .. card.ability.extra.current_price .. '$)',
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        -- Joker Mult scoring
        if context.joker_main then
            local p = (card.ability and card.ability.extra and card.ability.extra.current_price) or 5
            if p > 0 then
                return {
                    mult = p * 2
                }
            end
        end

        -- Round end: increase if 1st hand won, and cash out if Boss Blind
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local gained = 0
            if G.GAME.current_round and G.GAME.current_round.hands_played == 1 then
                local gain = pseudorandom('shareholder_gain', 1, 5)
                card.ability.extra.current_price = (card.ability.extra.current_price or 5) + gain
                gained = gain
            end

            if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                local final_val = card.ability.extra.current_price or 5
                if final_val > 0 then
                    ease_dollars(final_val)
                end
                card.ability.extra.current_price = 5
                return {
                    message = 'Payout: +$' .. final_val,
                    colour = G.C.MONEY
                }
            elseif gained > 0 then
                return {
                    message = '+$' .. gained .. ' Stock Up!',
                    colour = G.C.GREEN
                }
            end
        end
    end
}

-- Builder Joker
SMODS.Joker {
    key = 'builder_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Builder Joker',
        text = {
            "If scoring cards are in {C:attention}ascending rank order{}:",
            "gives {X:mult,C:white}X#1#{} Mult per card scored.",
            "{C:attention}4+ cards{} in order adds permanent {C:chips}+#2#{} Chips to highest card"
        }
    },
    unlock = {
        "Play a {C:attention}Three of a Kind{},",
        "{C:attention}Four of a Kind{}, and {C:attention}Five of a Kind{}",
        "consecutively in one run"
    },
    config = { extra = { xmult_per_card = 0.5, bonus_chips = 20 } },
    rarity = 2,
    pos = { x = 1, y = 1 },
    blueprint_compat = true,
    cost = 6,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { 1 + (ex.xmult_per_card or 0.5), ex.bonus_chips or 20 } }
    end,
    check_for_unlock = function(self, args)
        if (args.type == 'hand' or args.type == 'play_hand') and args.handname then
            G.GAME.builder_streak = G.GAME.builder_streak or 0
            if args.handname == 'Three of a Kind' then
                G.GAME.builder_streak = 1
            elseif args.handname == 'Four of a Kind' and G.GAME.builder_streak == 1 then
                G.GAME.builder_streak = 2
            elseif (args.handname == 'Five of a Kind' or args.handname == 'Flush Five') and G.GAME.builder_streak == 2 then
                G.GAME.builder_streak = 3
                return true
            else
                G.GAME.builder_streak = (args.handname == 'Three of a Kind' and 1 or 0)
            end
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main and context.scoring_hand and #context.scoring_hand >= 2 then
            local is_ascending = true
            for i = 1, #context.scoring_hand - 1 do
                local cur_id = context.scoring_hand[i]:get_id() or 0
                local next_id = context.scoring_hand[i + 1]:get_id() or 0
                if cur_id >= next_id then
                    is_ascending = false
                    break
                end
            end

            if is_ascending then
                local multiplier = 1 + (#context.scoring_hand * card.ability.extra.xmult_per_card)
                if #context.scoring_hand >= 4 and not context.blueprint then
                    local top_card = context.scoring_hand[#context.scoring_hand]
                    top_card.ability = top_card.ability or {}
                    top_card.ability.perma_bonus = (top_card.ability.perma_bonus or 0) + card.ability.extra.bonus_chips
                end
                return {
                    Xmult = multiplier,
                    message = 'Stable Pyramid! X' .. multiplier,
                    colour = G.C.MULT
                }
            else
                return {
                    chips = 10,
                    message = 'Unstable Structure',
                    colour = G.C.GREY
                }
            end
        end
    end
}

-- Banquet
SMODS.Joker {
    key = 'banquet_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Banquet',
        text = {
            "Cards held in hand gain permanent {C:chips}+#1#{} Chips each score.",
            "{X:mult,C:white}X#3#{} Mult if holding {C:attention}#2#+ cards{}.",
            "When sold, earn {C:money}$#4#{} and create a {C:dark_edition}Negative{} Food Joker"
        }
    },
    config = { extra = { perma_chips = 2, hand_threshold = 7, xmult = 2.5, sell_cash = 15 } },
    rarity = 2,
    pos = { x = 2, y = 1 },
    cost = 6,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.perma_chips or 2, ex.hand_threshold or 7, ex.xmult or 2.5, ex.sell_cash or 15 } }
    end,
    calculate = function(self, card, context)
        -- Cards remaining in hand dine at the banquet
        if context.individual and context.cardarea == G.hand and not context.end_of_round and not context.blueprint then
            context.other_card.ability = context.other_card.ability or {}
            context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + card.ability.extra.perma_chips
            return {
                chips = card.ability.extra.perma_chips,
                card = card
            }
        end

        -- Full banquet table bonus
        if context.joker_main then
            local held_count = (G.hand and G.hand.cards) and #G.hand.cards or 0
            if held_count >= (card.ability.extra.hand_threshold or 7) then
                return {
                    Xmult = card.ability.extra.xmult,
                    message = 'Full Feast! X' .. card.ability.extra.xmult,
                    colour = G.C.XMULT
                }
            end
        end

        -- Selling reward
        if context.selling_self and not context.blueprint then
            ease_dollars(card.ability.extra.sell_cash)
            G.E_MANAGER:add_event(Event({
                func = function()
                    local food_keys = { 'j_ice_cream', 'j_popcorn', 'j_ramen', 'j_turtle_bean', 'j_diet_cola', 'j_selzer' }
                    local chosen_food = pseudorandom_element(food_keys, 'banquet_food')
                    local new_food = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_food, nil)
                    new_food:set_edition({ negative = true }, true)
                    new_food:add_to_deck()
                    G.jokers:emplace(new_food)
                    new_food:juice_up(0.6, 0.6)
                    return true
                end
            }))
        end
    end
}

-- Appraiser
SMODS.Joker {
    key = 'appraiser_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Appraiser',
        text = {
            "Earn {C:money}$#1#{} at end of round for each",
            "card with an {C:dark_edition}Edition{} in your deck"
        }
    },
    config = { extra = { dollars_per_edition = 1 } },
    rarity = 2,
    pos = { x = 3, y = 1 },
    cost = 6,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        return { vars = { (card and card.ability and card.ability.extra and card.ability.extra.dollars_per_edition) or 1 } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local count = 0
            if G.playing_cards then
                for _, pcard in ipairs(G.playing_cards) do
                    if pcard.edition and (pcard.edition.foil or pcard.edition.holo or pcard.edition.polychrome) then
                        count = count + 1
                    end
                end
            end
            if count > 0 then
                local total_money = count * card.ability.extra.dollars_per_edition
                return {
                    dollars = total_money,
                    message = '+$' .. total_money,
                    colour = G.C.MONEY
                }
            end
        end
    end
}

-- Runway
SMODS.Joker {
    key = 'runway_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Runway',
        text = {
            "Gains {X:mult,C:white}+X#2#{} Mult whenever",
            "a card is {C:attention}Enhanced{}",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult){}"
        }
    },
    unlock = {
        "Have 5 cards with",
        "{C:attention}Editions{} in your deck"
    },
    config = { extra = { xmult = 1.0, xmult_gain = 0.1 } },
    rarity = 3,
    pos = { x = 4, y = 1 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.xmult or 1.0, ex.xmult_gain or 0.1 } }
    end,
    check_for_unlock = function(self, args)
        if G.playing_cards then
            local ed_count = 0
            for _, c in ipairs(G.playing_cards) do
                if c.edition and (c.edition.foil or c.edition.holo or c.edition.polychrome) then
                    ed_count = ed_count + 1
                end
            end
            if ed_count >= 5 then
                return true
            end
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra and card.ability.extra.xmult and card.ability.extra.xmult > 1 then
            return {
                Xmult = card.ability.extra.xmult
            }
        end
    end
}

-- Slot Machine
local SLOT_CHALLENGES = {
    { id = 'flush', desc = "Play a Flush", check = function(ctx) return ctx.poker_hands and ctx.poker_hands['Flush'] and next(ctx.poker_hands['Flush']) end },
    { id = 'straight', desc = "Play a Straight", check = function(ctx) return ctx.poker_hands and ctx.poker_hands['Straight'] and next(ctx.poker_hands['Straight']) end },
    { id = 'full_house', desc = "Play a Full House", check = function(ctx) return ctx.poker_hands and ctx.poker_hands['Full House'] and next(ctx.poker_hands['Full House']) end },
    { id = 'three_kind', desc = "Play a Three of a Kind", check = function(ctx) return ctx.poker_hands and ctx.poker_hands['Three of a Kind'] and next(ctx.poker_hands['Three of a Kind']) end },
    { id = 'enhanced', desc = "Play an Enhanced card", check = function(ctx)
        if ctx.scoring_hand then
            for _, sc in ipairs(ctx.scoring_hand) do
                if sc.config and sc.config.center and sc.config.center ~= G.P_CENTERS.c_base then return true end
            end
        end
        return false
    end },
    { id = 'seven_or_lucky', desc = "Play a 7 or Lucky Card", check = function(ctx)
        if ctx.scoring_hand then
            for _, sc in ipairs(ctx.scoring_hand) do
                if (sc:get_id() == 7) or (sc.ability and (sc.ability.name == 'Lucky Card' or sc.ability.effect == 'Lucky Card')) then return true end
            end
        end
        return false
    end }
}

local function get_slot_challenge(card)
    local ex = (card and card.ability and card.ability.extra) or {}
    local idx = ex.challenge_idx or 1
    if idx < 1 or idx > #SLOT_CHALLENGES then idx = 1 end
    return SLOT_CHALLENGES[idx]
end

local function get_slot_machine_pos(r1, r2, r3)
    local sym_map = { Cherry = 0, Lemon = 1, Bell = 2, ['7'] = 3 }
    local c1 = sym_map[r1] or 0
    local c2 = sym_map[r2] or 0
    local c3 = sym_map[r3] or 0
    local combo_num = c1 * 16 + c2 * 4 + c3
    return { x = combo_num % 8, y = 1 + math.floor(combo_num / 8) }
end

SMODS.Atlas {
    key = "witch_brew_slot_machine",
    path = "slot_machine.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'slot_machine_joker',
    atlas = 'witch_brew_slot_machine',
    unlocked = false,
    loc_txt = {
        name = 'Slot Machine',
        text = {
            "Spins 3 reels on each hand played.",
            "{C:attention}Pair match{}: {C:money}+$#1#{} and {C:mult}+#2#{} Mult.",
            "{C:attention}Three of a kind{}: {C:money}+$#3#{} and {X:mult,C:white}X#4#{} Mult.",
            "{C:attention}Triple 7 Jackpot{}: {C:money}+$#5#{}, {X:mult,C:white}X#6#{} Mult, and a {C:spectral}Spectral{} card.",
            "{C:green}Round Challenge{}: {C:attention}#7#{} {C:inactive}(#8#){}.",
            "Use the {C:money}Bet{} button to win {C:money}X1.5{} your wager upon completion",
            "{C:inactive}(Last Spin: [ {C:attention}#9#{C:inactive} ])"
        }
    },
    unlock = {
        "Trigger both {C:mult}+20 Mult{} and",
        "{C:money}$20{} from a single",
        "{C:attention}Lucky Card{}"
    },
    config = { extra = { pair_cash = 3, pair_mult = 15, triple_cash = 12, triple_xmult = 2.5, jackpot_cash = 35, jackpot_xmult = 4.0, challenge_idx = 1, bet_placed = false, bet_amount = 0, challenge_completed = false, last_payout_text = "", sprite_pos = { x = 0, y = 0 }, spinning = false } },
    rarity = 2,
    pos = { x = 0, y = 0 },
    cost = 6,
    blueprint_compat = true,
    set_sprites = function(self, card, _front)
        if card and card.ability and card.ability.extra and card.children and card.children.center then
            local sp = card.ability.extra.sprite_pos
            if not sp and card.ability.extra.last_spin and #card.ability.extra.last_spin == 3 then
                sp = get_slot_machine_pos(card.ability.extra.last_spin[1], card.ability.extra.last_spin[2], card.ability.extra.last_spin[3])
                card.ability.extra.sprite_pos = sp
            end
            card.children.center:set_sprite_pos(sp or { x = 0, y = 0 })
        end
    end,
    update = function(self, card, dt)
        if card and card.ability and card.ability.extra and card.ability.extra.spinning then
            card.ability.extra.spin_timer = (card.ability.extra.spin_timer or 0) + (dt or 0.016)
            if card.ability.extra.spin_timer >= 0.07 then
                card.ability.extra.spin_timer = 0
                local next_f = ((card.ability.extra.spin_frame or 1) % 6) + 1
                card.ability.extra.spin_frame = next_f
                if card.children and card.children.center then
                    card.children.center:set_sprite_pos({ x = next_f, y = 0 })
                end
            end
        end
    end,
    draw = function(self, card, layer)
        if card and card.ability and card.ability.extra and card.children and card.children.center and not card.greyed then
            -- Shimmer de giro activo mientras los carretes rotan
            if card.ability.extra.spinning then
                card.children.center:draw_shader('voucher', nil, card.ARGS.send_to_shader)
            -- Resplandor legendario al conseguir Jackpot 777
            elseif card.ability.extra.last_spin and card.ability.extra.last_spin[1] == '7' and card.ability.extra.last_spin[2] == '7' and card.ability.extra.last_spin[3] == '7' then
                card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
            end
        end
    end,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local ch = get_slot_challenge(card or self)
        local bet_str = (ex and ex.bet_placed) and ("Bet: $" .. (ex.bet_amount or 5)) or "No bet"
        local spin_str = "None"
        if ex and ex.last_spin and #ex.last_spin == 3 then
            spin_str = tostring(ex.last_spin[1]) .. " | " ..
                       tostring(ex.last_spin[2]) .. " | " ..
                       tostring(ex.last_spin[3])
        end
        return { vars = { ex.pair_cash, ex.pair_mult, ex.triple_cash, ex.triple_xmult, ex.jackpot_cash, ex.jackpot_xmult, ch.desc, bet_str, spin_str } }
    end,
    check_for_unlock = function(self, args)
        if args.type == 'lucky_both' or (G.GAME and G.GAME.lucky_hit_both) then
            return true
        end
    end,
    calculate = function(self, card, context)
        card.ability.extra = card.ability.extra or {}

        if (context.setting_blind or context.first_hand_drawn) and not context.blueprint and not card.ability.extra.rotated_this_round then
            card.ability.extra.rotated_this_round = true
            card.ability.extra.challenge_idx = pseudorandom('slot_ch_' .. ((G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 1) .. '_' .. ((G.GAME and G.GAME.current_round and G.GAME.current_round.hands_played) or 0), 1, #SLOT_CHALLENGES)
            card.ability.extra.bet_placed = false
            card.ability.extra.challenge_completed = false
            card.ability.extra.bet_amount = 0
            card.ability.extra.last_payout_text = ""
        end

        if context.before and context.scoring_hand then
            local symbols = { 'Cherry', 'Lemon', 'Bell', '7' }
            local has_lucky = false
            for _, sc in ipairs(context.scoring_hand) do
                if sc.ability and (sc.ability.name == 'Lucky Card' or sc.ability.effect == 'Lucky Card') then
                    has_lucky = true
                    break
                end
            end

            local r1 = has_lucky and '7' or pseudorandom_element(symbols, 'slot_r1')
            local r2 = pseudorandom_element(symbols, 'slot_r2')
            local r3 = pseudorandom_element(symbols, 'slot_r3')
            card.ability.extra.last_spin = { r1, r2, r3 }
            card.ability.extra.spinning = true
            card.ability.extra.spin_frame = 1
            card.ability.extra.spin_timer = 0
            if card.children and card.children.center then
                card.children.center:set_sprite_pos({ x = 1, y = 0 })
            end

            card:juice_up(0.6, 0.6)
            play_sound('tarot2', 1.2, 0.5)
        end

        if context.joker_main and card.ability.extra.last_spin then
            local r = card.ability.extra.last_spin
            local r1, r2, r3 = r[1], r[2], r[3]
            local ex = card.ability.extra
            card.ability.extra.spinning = false
            local final_pos = get_slot_machine_pos(r1, r2, r3)
            card.ability.extra.sprite_pos = final_pos
            if card.children and card.children.center then
                card.children.center:set_sprite_pos(final_pos)
            end
            card:juice_up(0.7, 0.5)
            play_sound('coin1', 1.0, 0.6)

            local ret = {}

            if r1 == '7' and r2 == '7' and r3 == '7' then
                card.ability.extra.last_payout_text = "777 Jackpot! X" .. ex.jackpot_xmult .. " / +$" .. ex.jackpot_cash
                if not context.blueprint then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local sc = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'slot_jackpot')
                            sc:add_to_deck()
                            G.consumeables:emplace(sc)
                            sc:juice_up(0.6, 0.6)
                            return true
                        end
                    }))
                end
                ret = {
                    Xmult = ex.jackpot_xmult,
                    dollars = ex.jackpot_cash,
                    message = '[ 7 7 7 ] 777 JACKPOT! +$' .. ex.jackpot_cash,
                    colour = G.C.GOLD
                }
            elseif r1 == r2 and r2 == r3 then
                local sym_name = r1:upper()
                local win_msg = 'TRIPLE ' .. sym_name .. '!'
                card.ability.extra.last_payout_text = "Triple Match! X" .. ex.triple_xmult .. " / +$" .. ex.triple_cash
                ret = {
                    Xmult = ex.triple_xmult,
                    dollars = ex.triple_cash,
                    message = win_msg .. ' +$' .. ex.triple_cash,
                    colour = G.C.MONEY
                }
            elseif r1 == r2 or r2 == r3 or r1 == r3 then
                local pair_sym = (r1 == r2 and r1) or (r2 == r3 and r2) or r1
                local sym_name = pair_sym:upper()
                local win_msg = 'PAIR ' .. sym_name .. '!'
                card.ability.extra.last_payout_text = "Pair Match! +" .. ex.pair_mult .. " Mult / +$" .. ex.pair_cash
                ret = {
                    mult = ex.pair_mult,
                    dollars = ex.pair_cash,
                    message = win_msg .. ' +$' .. ex.pair_cash,
                    colour = G.C.MULT
                }
            else
                card.ability.extra.last_payout_text = "Miss"
                local d1 = r1
                local d2 = r2
                local d3 = r3
                ret = {
                    message = '[ ' .. d1 .. ' ' .. d2 .. ' ' .. d3 .. ' ] MISS',
                    colour = G.C.UI.TEXT_INACTIVE
                }
            end

            return ret
        end

        if context.after and not context.blueprint then
            if card.ability and card.ability.extra and card.ability.extra.spinning then
                card.ability.extra.spinning = false
                if card.ability.extra.last_spin and #card.ability.extra.last_spin == 3 then
                    local final_pos = get_slot_machine_pos(card.ability.extra.last_spin[1], card.ability.extra.last_spin[2], card.ability.extra.last_spin[3])
                    card.ability.extra.sprite_pos = final_pos
                    if card.children and card.children.center then
                        card.children.center:set_sprite_pos(final_pos)
                    end
                end
            end
        end

        -- Check Challenge completion for the active bet
        if context.after and not context.blueprint and card.ability.extra.bet_placed and not card.ability.extra.challenge_completed then
            local ch = get_slot_challenge(card)
            if ch and ch.check(context) then
                card.ability.extra.challenge_completed = true
                card.ability.extra.bet_placed = false
                local payout = math.ceil((card.ability.extra.bet_amount or 5) * 1.5)
                ease_dollars(payout)
                local msg_txt = 'Challenge Completed! +$' .. payout
                card.ability.extra.last_payout_text = (card.ability.extra.last_payout_text or "") .. " | " .. msg_txt
                return {
                    message = msg_txt,
                    colour = G.C.MONEY
                }
            end
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.rotated_this_round = nil
            card.ability.extra.bet_placed = false
            card.ability.extra.challenge_completed = false
            card.ability.extra.bet_amount = 0
        end
    end
}

-- Duel of Value
SMODS.Joker {
    key = 'duel_of_value_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Duel of Value',
        text = {
            "{X:mult,C:white}X#1#{} Mult if played {C:attention}Two Pair{}",
            "contains exactly 2 even and 2 odd cards"
        },
        unlock = {
            "Reach {C:attention}Ante 8{} holding both",
            "{C:attention}Odd Todd{} and {C:attention}Even Steven{}"
        }
    },
    config = { extra = { xmult = 3.0 } },
    rarity = 2,
    pos = { x = 6, y = 1 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,
    check_for_unlock = function(self, args)
        if G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante and G.GAME.round_resets.ante >= 8 then
            local has_odd = false
            local has_even = false
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    if card_has_key(j, 'odd_todd') then has_odd = true end
                    if card_has_key(j, 'even_steven') then has_even = true end
                end
            end
            if has_odd and has_even then
                return true
            end
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main and context.poker_hands and context.poker_hands['Two Pair'] and next(context.poker_hands['Two Pair']) then
            local evens = 0
            local odds = 0
            if context.scoring_hand then
                for _, scard in ipairs(context.scoring_hand) do
                    local id = scard:get_id()
                    if id and id > 0 then
                        if id == 14 or id % 2 ~= 0 then
                            odds = odds + 1
                        else
                            evens = evens + 1
                        end
                    end
                end
            end
            if evens == 2 and odds == 2 then
                return {
                    Xmult = card.ability.extra.xmult
                }
            end
        end
    end
}

-- Falta de Lectura
SMODS.Joker {
    key = 'reading_deficiency_joker',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Reading Deficiency',
        text = {
            "{X:mult,C:white}X#1#{} Mult if played hand",
            "activates {C:attention}no other Jokers{}"
        },
        unlock = {
            "Play a scoring hand that",
            "activates {C:attention}no Jokers{}"
        }
    },
    config = { extra = { xmult = 5.0 } },
    rarity = 2,
    pos = { x = 0, y = 2 },
    cost = 6,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,
    check_for_unlock = function(self, args)
        if args.type == 'no_jokers_activated' or (G.GAME and G.GAME.no_jokers_activated_hand) then
            return true
        end
    end,
    calculate = function(self, card, context)
        if context.before then
            G.GAME.falta_de_lectura_other_activated = false
        end

        if context.joker_main then
            if G.GAME.falta_de_lectura_other_activated then
                return nil
            end

            local other_will_activate = false
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    local is_self = card_has_key(j, 'reading_deficiency_joker')
                    local is_copier = (j.ability and (j.ability.name == 'Blueprint' or j.ability.name == 'Brainstorm' or j.ability.name == 'Chameleon'))
                    if not is_self and not is_copier and not j.debuff and j.calculate_joker then
                        local check_ctx = {}
                        for k, v in pairs(context) do check_ctx[k] = v end
                        check_ctx.falta_de_lectura_check = true
                        local res = j:calculate_joker(check_ctx)
                        if res and type(res) == 'table' and next(res) then
                            if res.mult or res.chips or res.Xmult or res.x_mult or res.dollars or res.x_chips or res.p_dollars or res.message or res.swap then
                                other_will_activate = true
                                break
                            end
                        end
                    end
                end
            end

            if not other_will_activate then
                check_for_unlock({ type = 'no_jokers_activated' })
                return {
                    Xmult = card.ability.extra.xmult,
                    message = 'Please Read!',
                    colour = G.C.XMULT
                }
            end
        end
    end
}

-- Chameleon Joker
local function get_available_deck_ranks()
    local ranks = {}
    local seen = {}
    if G.playing_cards then
        for _, pcard in ipairs(G.playing_cards) do
            local val = pcard.base and pcard.base.value
            if val and not seen[val] then
                seen[val] = true
                table.insert(ranks, val)
            end
        end
    end
    return ranks
end

local function ensure_chameleon_rank(card)
    card.ability = card.ability or {}
    card.ability.extra = card.ability.extra or {}
    local ranks = get_available_deck_ranks()
    if #ranks > 0 then
        local current = card.ability.extra.required_rank
        local found = false
        if current then
            for _, r in ipairs(ranks) do
                if r == current then found = true; break end
            end
        end
        if not found or not current then
            card.ability.extra.required_rank = pseudorandom_element(ranks, 'chameleon_rank')
        end
    else
        card.ability.extra.required_rank = card.ability.extra.required_rank or 'Ace'
    end
end

SMODS.Joker {
    key = 'chameleon_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Chameleon',
        text = {
            "Copies ability of the {C:attention}Joker to the left{}",
            "if played hand contains at least one {C:attention}#1#{}",
            "{C:inactive}(Rank changes every round from full deck){}"
        }
    },
    config = { extra = { required_rank = 'Ace' } },
    rarity = 2,
    pos = { x = 1, y = 2 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        ensure_chameleon_rank(card)
        return { vars = { card.ability.extra.required_rank or 'Ace' } }
    end,
    calculate = function(self, card, context)
        ensure_chameleon_rank(card)

        if context.setting_blind and not context.blueprint then
            local ranks = get_available_deck_ranks()
            if #ranks > 0 then
                card.ability.extra.required_rank = pseudorandom_element(ranks, 'chameleon_rank_round')
            end
        end

        local rank_played = false
        local target_rank = card.ability.extra.required_rank
        local cards_to_check = context.full_hand or context.scoring_hand or (G.play and G.play.cards)

        if cards_to_check then
            for _, c in ipairs(cards_to_check) do
                if c.base and c.base.value == target_rank then
                    rank_played = true
                    break
                end
            end
        end

        if rank_played and G.jokers and G.jokers.cards then
            local my_idx = nil
            for idx, j in ipairs(G.jokers.cards) do
                if j == card then my_idx = idx; break end
            end

            if my_idx and my_idx > 1 then
                local left_joker = G.jokers.cards[my_idx - 1]
                if left_joker and left_joker ~= card and is_joker_copiable(left_joker) then
                    local ret = SMODS.blueprint_effect(card, left_joker, context)
                    if ret then
                        return ret
                    end
                end
            end
        end
    end
}

-- Motorized Joker (Joker Motorizado)
SMODS.Joker {
    key = 'motorized_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Motorized Joker',
        text = {
            "Gains {C:mult}+#2#{} Mult whenever",
            "a card is {C:attention}retriggered{}",
            "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}"
        }
    },
    config = { extra = { mult = 0, mult_gain = 2 } },
    rarity = 2,
    pos = { x = 2, y = 2 },
    cost = 6,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local mult = (card and card.ability and card.ability.extra and card.ability.extra.mult) or 0
        local mult_gain = (card and card.ability and card.ability.extra and card.ability.extra.mult_gain) or 2
        return { vars = { mult, mult_gain } }
    end,
    calculate = function(self, card, context)
        if context.before then
            G.GAME.motorizado_scored_cards = {}
        end

        if context.individual and (context.cardarea == G.play or context.cardarea == G.hand) and not context.blueprint then
            local pcard = context.other_card
            G.GAME.motorizado_scored_cards = G.GAME.motorizado_scored_cards or {}
            if pcard then
                if G.GAME.motorizado_scored_cards[pcard] then
                    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                    return {
                        message = '+' .. card.ability.extra.mult_gain .. ' Mult!',
                        colour = G.C.MULT,
                        card = card
                    }
                else
                    G.GAME.motorizado_scored_cards[pcard] = true
                end
            end
        end

        if context.joker_main and card.ability.extra.mult > 0 then
            return {
                mult = card.ability.extra.mult
            }
        end

        if context.after or context.end_of_round then
            G.GAME.motorizado_scored_cards = nil
        end
    end
}

-- Hired Joker (Joker Contratado)
SMODS.Joker {
    key = 'hired_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Hired Joker',
        text = {
            "{C:green}#1# in #2#{} chance per played hand",
            "to create a random {C:attention}Job Card{}",
            "{C:inactive}(Must have room){}"
        }
    },
    config = { extra = { odds = 3 } },
    rarity = 2,
    pos = { x = 3, y = 2 },
    cost = 6,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        return { vars = { (G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if pseudorandom('contratado') < (G.GAME and G.GAME.probabilities.normal or 1) / card.ability.extra.odds then
                if G.consumeables and #G.consumeables.cards + (G.GAME.consumeable_buffer or 0) < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = (G.GAME.consumeable_buffer or 0) + 1
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        func = function()
                            play_sound('tarot1')
                            local job_keys = {
                                'c_Witch_brew_miner_job', 'c_Witch_brew_gardener_job', 'c_Witch_brew_banker_job',
                                'c_Witch_brew_surgeon_job', 'c_Witch_brew_alchemist_job', 'c_Witch_brew_butcher_job',
                                'c_Witch_brew_detective_job', 'c_Witch_brew_chef_job', 'c_Witch_brew_archaeologist_job',
                                'c_Witch_brew_jeweler_job'
                            }
                            local chosen_job = pseudorandom_element(job_keys, pseudoseed('contratado_spawn'))
                            local new_card = create_card('Job', G.consumeables, nil, nil, nil, nil, chosen_job, 'contratado')
                            new_card:add_to_deck()
                            G.consumeables:emplace(new_card)
                            G.GAME.consumeable_buffer = math.max(0, (G.GAME.consumeable_buffer or 1) - 1)
                            new_card:juice_up(0.4, 0.4)
                            card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Job Offered!', colour = HEX('5c1e11') })
                            return true
                        end
                    }))
                end
            end
        end
    end
}

-- Seal of Approval (Sello de Aprobación)
SMODS.Joker {
    key = 'seal_of_approval_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Seal of Approval',
        text = {
            "If played hand contains only {C:attention}1 card{},",
            "adds a random {C:attention}Seal{} to it"
        }
    },
    config = {},
    rarity = 2,
    pos = { x = 4, y = 2 },
    cost = 7,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local play_count = (context.full_hand and #context.full_hand) or (context.scoring_hand and #context.scoring_hand) or (G.play and G.play.cards and #G.play.cards) or 0
            if play_count == 1 and context.scoring_hand and #context.scoring_hand == 1 then
                local target_card = context.scoring_hand[1]
                local seals = { 'Gold', 'Blue', 'Red', 'Purple', 'Witch_brew_dark_green', 'Witch_brew_silver', 'Witch_brew_white' }
                local chosen_seal = pseudorandom_element(seals, pseudoseed('sello_aprobacion'))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        play_sound('gold_seal')
                        target_card:set_seal(chosen_seal, nil, true)
                        target_card:juice_up(0.5, 0.5)
                        card:juice_up(0.4, 0.5)
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Approved!', colour = G.C.GOLD })
                        return true
                    end
                }))
            end
        end
    end
}

-- Paint Puddle (Charco de Pintura)
local function ensure_charco_suit(card)
    card.ability = card.ability or {}
    card.ability.extra = card.ability.extra or {}
    if not card.ability.extra.suit then
        local suits = {'Hearts', 'Diamonds', 'Spades', 'Clubs'}
        card.ability.extra.suit = pseudorandom_element(suits, 'charco_init_suit') or 'Hearts'
    end
end

SMODS.Joker {
    key = 'paint_puddle_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Paint Puddle',
        text = {
            "Scored {C:attention}#1#{} give {C:mult}+#2#{} Mult.",
            "Scored {C:attention}Wild Cards{} give {C:mult}+#3#{} Mult instead.",
            "{C:inactive}(Suit changes each round){}"
        }
    },
    config = { extra = { mult_suit = 7, mult_wild = 15, suit = 'Hearts' } },
    rarity = 2,
    pos = { x = 5, y = 2 },
    cost = 6,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        ensure_charco_suit(card)
        local suit = card.ability.extra.suit or 'Hearts'
        local mult_suit = card.ability.extra.mult_suit or 7
        local mult_wild = card.ability.extra.mult_wild or 15
        return { vars = { suit, mult_suit, mult_wild } }
    end,
    calculate = function(self, card, context)
        ensure_charco_suit(card)

        if context.setting_blind and not context.blueprint then
            local current_suit = card.ability.extra.suit
            local available_suits = {}
            local suits = {'Hearts', 'Diamonds', 'Spades', 'Clubs'}
            for _, s in ipairs(suits) do
                if s ~= current_suit then
                    table.insert(available_suits, s)
                end
            end
            card.ability.extra.suit = pseudorandom_element(available_suits, pseudoseed('charco_round_suit'))
            card_eval_status_text(card, 'extra', nil, nil, nil, { message = card.ability.extra.suit .. '!', colour = G.C.ATTENTION })
            card:juice_up(0.3, 0.3)
        end

        if context.individual and context.cardarea == G.play then
            if is_wild_card(context.other_card) then
                return {
                    mult = card.ability.extra.mult_wild,
                    card = card
                }
            elseif context.other_card:is_suit(card.ability.extra.suit) then
                return {
                    mult = card.ability.extra.mult_suit,
                    card = card
                }
            end
        end
    end
}

-- Injured Joker (Joker Lesionado)
SMODS.Joker {
    key = 'injured_joker',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Injured Joker',
        text = {
            "{C:green}#1# in #2#{} chance at the end of round",
            "to transform into another Joker.",
            "{C:inactive}(Use button above to view options){}"
        }
    },
    config = { extra = { odds = 5 } },
    rarity = 2,
    pos = { x = 6, y = 2 },
    cost = 6,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local odds = (card and card.ability and card.ability.extra and card.ability.extra.odds) or 5
        local prob = (G.GAME and G.GAME.probabilities.normal) or 1
        return { vars = { prob, odds } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 5
            local prob = (G.GAME and G.GAME.probabilities.normal) or 1
            if pseudorandom('injured_joker') < (prob / odds) then
                local motorized_key = (G.P_CENTERS and G.P_CENTERS['j_Witch_brew_motorized_joker']) and 'j_Witch_brew_motorized_joker' or (G.P_CENTERS and G.P_CENTERS['j_Witch_brew_motorizado_joker']) and 'j_Witch_brew_motorizado_joker' or 'j_motorized_joker'
                local msg_rock = "Let's rock!"
                local msg_cursed = 'Cursed!'
                local transform_options = {
                    { key = motorized_key, message = msg_rock, colour = G.C.ORANGE },
                    { key = 'j_stuntman', message = msg_rock, colour = G.C.ORANGE },
                    { key = 'j_invisible', message = msg_cursed, colour = G.C.RED },
                    { key = 'j_mr_bones', message = msg_cursed, colour = G.C.RED },
                    { key = 'j_vampire', message = msg_cursed, colour = G.C.RED },
                    { key = 'j_stencil', message = '?', colour = G.C.PURPLE }
                }
                local chosen = pseudorandom_element(transform_options, pseudoseed('injured_transform'))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        play_sound('tarot2')
                        local ed = card.edition
                        card:start_dissolve()
                        local new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen.key, 'injured_morph')
                        if ed then
                            new_joker:set_edition(ed, true)
                        end
                        new_joker:add_to_deck()
                        G.jokers:emplace(new_joker)
                        new_joker:juice_up(0.6, 0.6)
                        card_eval_status_text(new_joker, 'extra', nil, nil, nil, { message = chosen.message, colour = chosen.colour })
                        return true
                    end
                }))
                return {
                    message = chosen.message,
                    colour = chosen.colour
                }
            end
        end
    end
}

-- Extended Hand
SMODS.Joker {
    key = 'extended_hand',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Extended Hand',
        text = {
            "Gains {X:mult,C:white}+X#1#{} Mult when played hand",
            "contains {C:attention}4 or fewer{} cards and {C:attention}no discards{}",
            "have been used this round",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_gain = 0.2, xmult = 1.0 } },
    rarity = 2,
    pos = { x = 5, y = 1 },
    cost = 6,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.xmult_gain or 0.2, ex.xmult or 1.0 } }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local discards_used = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_used) or 0
            if context.full_hand and #context.full_hand <= 4 and discards_used == 0 then
                card.ability.extra.xmult = (card.ability.extra.xmult or 1.0) + (card.ability.extra.xmult_gain or 0.2)
                return {
                    message = 'X' .. tostring(card.ability.extra.xmult) .. ' Mult!',
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
        if context.joker_main then
            local xmult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 1.0
            if xmult > 1 then
                return {
                    x_mult = xmult,
                    card = card
                }
            end
        end
    end
}

-- Bonfire
SMODS.Joker {
    key = 'bonfire',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Bonfire',
        text = {
            "When a {C:attention}face card{} is discarded, permanently",
            "adds {X:mult,C:white}+X#1#{} Mult to this Joker.",
            "{C:green}#2# in #3#{} chance to destroy the discarded face card.",
            "{C:inactive}(Currently {X:mult,C:white}X#4#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_gain = 0.1, xmult = 1.0, odds = 6 } },
    rarity = 2,
    pos = { x = 6, y = 4 },
    cost = 6,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local prob = (G.GAME and G.GAME.probabilities.normal) or 1
        return { vars = { ex.xmult_gain or 0.1, prob, ex.odds or 6, ex.xmult or 1.0 } }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            if context.other_card and context.other_card:is_face() then
                card.ability.extra.xmult = (card.ability.extra.xmult or 1.0) + (card.ability.extra.xmult_gain or 0.1)
                local prob = (G.GAME and G.GAME.probabilities.normal) or 1
                local will_destroy = pseudorandom('bonfire_destroy') < (prob / (card.ability.extra.odds or 6))
                if will_destroy then
                    return {
                        remove = true,
                        message = 'Burned!',
                        colour = G.C.RED,
                        card = card
                    }
                else
                    return {
                        message = '+X' .. tostring(card.ability.extra.xmult_gain or 0.05) .. ' Mult!',
                        colour = G.C.MULT,
                        card = card
                    }
                end
            end
        end
        if context.joker_main then
            local xmult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 1.0
            if xmult > 1 then
                return {
                    x_mult = xmult,
                    card = card
                }
            end
        end
    end
}

-- Billie Jean
SMODS.Joker {
    key = 'billie_jean',
    atlas = 'witch_brew_jokers',
    pos = { x = 1, y = 5 },
    rarity = 'Witch_brew_song',
    cost = 7,
    blueprint_compat = true,
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge('Song', HEX('d4af37'), G.C.WHITE, 1.2)
    end,
    set_badges = function(self, card, badges)
        if badges and #badges > 0 then
            badges[1] = create_badge('Song', HEX('d4af37'), G.C.WHITE, 1.2)
        end
    end,
    config = {},
    loc_txt = {
        name = 'Billie Jean',
        text = {
            "If played hand contains both a",
            "{C:attention}King{} and a {C:attention}Queen{}, create a",
            "{C:dark_edition}Polychrome{} {C:attention}Wild Jack{} in hand",
            "{C:inactive}('The kid is not my son'){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
            info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
        end
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.before then
            local has_king = false
            local has_queen = false
            local cards_to_check = context.scoring_hand or (G.play and G.play.cards) or {}
            for _, sc in ipairs(cards_to_check) do
                if sc:get_id() == 13 then has_king = true end
                if sc:get_id() == 12 then has_queen = true end
            end
            if has_king and has_queen then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        local suits = {'Hearts', 'Diamonds', 'Spades', 'Clubs'}
                        local chosen_suit = pseudorandom_element(suits, pseudoseed('billie_suit'))
                        local suit_prefix = string.sub(chosen_suit, 1, 1)
                        local _card = create_playing_card({
                            front = G.P_CARDS[suit_prefix .. '_J'],
                            center = G.P_CENTERS.m_wild
                        }, G.hand, nil, nil, { G.C.SECONDARY_SET.Enhanced })
                        _card:set_edition({ polychrome = true }, true)
                        G.hand:sort()
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = localize('k_plus_card') })
                        return true
                    end
                }))
                return {
                    message = "Not My Son!",
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
}




-- Uncommon Jokers, Additional definitions

-- Temporal Rift, Uncommon Joker
SMODS.Joker {
    key = 'temporal_rift',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Temporal Rift',
        text = {
            "If you {C:red}fail{} a blind on your final hand,",
            "gain {C:blue}+1 Hand{} and reduce the blind",
            "score requirement by {C:attention}15%{}.",
            "{C:inactive}(Once per blind){}"
        }
    },
    config = { extra = { used = false } },
    rarity = 2,
    pos = { x = 0, y = 8 },
    cost = 6,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.used = false
        end
        if context.after and not context.blueprint and G.GAME and G.GAME.chips and G.GAME.blind and G.GAME.chips < G.GAME.blind.chips then
            if G.GAME.current_round and G.GAME.current_round.hands_left == 0 and not card.ability.extra.used then
                card.ability.extra.used = true
                ease_hands_played(1)
                if G.GAME.blind then
                    G.GAME.blind.chips = math.floor(G.GAME.blind.chips * 0.85)
                    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                end
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Time Rift! +1 Hand', colour = G.C.BLUE })
                return { message = 'Rewound!' }
            end
        end
    end
}

-- Polarity Inversion, Uncommon Joker
SMODS.Joker {
    key = 'polarity_inversion',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    unlock = { "Defeat a {C:attention}Boss Blind{}", "without using any discards" },
    loc_txt = {
        name = 'Polarity Inversion',
        text = {
            "Negates Boss Blind debuffs on played cards.",
            "Each inverted card gives {C:mult}+#1#{} Mult",
            "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult bonus){}"
        }
    },
    config = { extra = { bonus_mult = 10, inverted_count = 0 } },
    rarity = 2,
    pos = { x = 1, y = 8 },
    cost = 6,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local bm = (card and card.ability and card.ability.extra and card.ability.extra.bonus_mult) or 10
        return { vars = { bm, bm } }
    end,
    check_for_unlock = function(self, args)
        if G.GAME and G.GAME.witch_brew_boss_nodiscard then
            return true
        end
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                local disc_used = (G.GAME.current_round and G.GAME.current_round.discards_used) or 0
                if disc_used == 0 then
                    G.GAME.witch_brew_boss_nodiscard = true
                end
            end
            card.ability.extra.inverted_count = 0
        end
        -- Invert debuffs on played cards
        if context.before and not context.blueprint then
            card.ability.extra.inverted_count = 0
            if context.scoring_hand then
                for _, c in ipairs(context.scoring_hand) do
                    if c.debuff then
                        c.debuff = false
                        card.ability.extra.inverted_count = (card.ability.extra.inverted_count or 0) + 1
                    end
                end
            end
        end
        if context.cardarea == G.jokers and context.joker_main then
            local inv = (card.ability and card.ability.extra and card.ability.extra.inverted_count) or 0
            if inv > 0 then
                local bonus = inv * ((card.ability and card.ability.extra and card.ability.extra.bonus_mult) or 10)
                card.ability.extra.inverted_count = 0
                return {
                    mult = bonus,
                    card = card,
                    message = '+' .. bonus .. ' Inverted Mult'
                }
            end
        end
    end
}

-- Inheritance, Uncommon Joker
SMODS.Joker {
    key = 'inheritance',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Inheritance',
        text = {
            "When a Joker is {C:attention}sold{},",
            "permanently gain {C:mult}+Mult{} equal to {C:attention}2X{} its {C:money}sell value{}",
            "{C:inactive}(Currently {C:mult}+#1#{} Mult){}"
        }
    },
    config = { extra = { mult = 2 } },
    rarity = 2,
    pos = { x = 2, y = 8 },
    cost = 6,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { (card and card.ability.extra.mult) or 2 } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return { mult = card.ability.extra.mult, card = card }
        end
        -- Absorb on sell (use sell_joker context)
        if context.selling_card and not context.blueprint then
            local sold = context.card
            if sold and sold ~= card then
                local sell_val = math.max(1, math.floor((sold.cost or 4) / 2))
                local gain = sell_val * 2
                card.ability.extra.mult = (card.ability.extra.mult or 2) + gain
                return { message = '+' .. gain .. ' Mult!', colour = G.C.MULT, card = card }
            end
        end
    end
}

-- Ecosystem, Uncommon Joker
SMODS.Joker {
    key = 'ecosystem',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Ecosystem',
        text = {
            "The {C:attention}dominant suit{} in deck",
            "gives {X:mult,C:white}X#1#{} Mult per card scored.",
            "The {C:attention}rarest suit{} in deck",
            "gives {C:chips}+#2#{} Chips per card scored."
        }
    },
    config = { extra = { dominant = '', rarest = '', x_mult = 1.5, chips = 80 } },
    rarity = 2,
    pos = { x = 3, y = 8 },
    cost = 6,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.x_mult or 1.5, ex.chips or 80 } }
    end,
    calculate = function(self, card, context)
        -- Recalculate dominant/rarest at hand start
        if context.before and not context.blueprint then
            local counts = { Spades = 0, Hearts = 0, Clubs = 0, Diamonds = 0 }
            if G.playing_cards then
                for _, c in ipairs(G.playing_cards) do
                    local s = c.base and c.base.suit
                    if s and counts[s] then counts[s] = counts[s] + 1 end
                end
            end
            local dom, dom_n = '', -1
            local rare, rare_n = '', math.huge
            for s, n in pairs(counts) do
                if n > dom_n then dom_n = n; dom = s end
                if n < rare_n then rare_n = n; rare = s end
            end
            card.ability.extra.dominant = dom
            card.ability.extra.rarest = rare
        end

        if context.individual and context.cardarea == G.play and not context.blueprint then
            local c = context.other_card
            local suit = c and c.base and c.base.suit
            if suit == card.ability.extra.dominant then
                return { x_mult = card.ability.extra.x_mult or 1.5, card = card }
            elseif suit == card.ability.extra.rarest then
                return { chips = card.ability.extra.chips or 80, card = card }
            end
        end
    end
}

-- Auctioneer, Uncommon Joker
SMODS.Joker {
    key = 'auctioneer',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Auctioneer',
        text = {
            "Click {C:attention}Auction{} to put a Joker",
            "up for sale to {C:attention}5 random buyers{}.",
            "Starting bid is {C:money}half sell value{}.",
            "Offer more: each has a {C:green}1 in 5{} chance to raise.",
            "Sold for accumulated cash when no one raises!"
        }
    },
    config = { extra = {} },
    rarity = 2,
    pos = { x = 4, y = 8 },
    cost = 6,
    blueprint_compat = false,
    calculate = function(self, card, context)
        return nil
    end
}

-- Auctioneer UI & Bidding System
local function clean_auction_temp_areas()
    if G.auction_temp_areas then
        for _, area in ipairs(G.auction_temp_areas) do
            if area.cards then
                for i = #area.cards, 1, -1 do
                    local c = area.cards[i]
                    if c and c.remove then c:remove() end
                end
            end
            if area.remove then area:remove() end
        end
        G.auction_temp_areas = nil
    end
end

if G.FUNCS and G.FUNCS.exit_overlay_menu then
    local orig_auction_exit_overlay_menu = G.FUNCS.exit_overlay_menu
    G.FUNCS.exit_overlay_menu = function()
        clean_auction_temp_areas()
        orig_auction_exit_overlay_menu()
    end
end

local auction_raise_dialogues = {
    "\"Do I hear another offer? Yes! We have a raise!\"",
    "\"The stakes are rising! A generous offer from the floor!\"",
    "\"A fierce bidding war begins! The price has gone up!\"",
    "\"Look at that enthusiasm! The bid is climbing fast!\"",
    "\"Stepping up to the plate! That's another great raise!\"",
    "\"A bold wager! The buyers are eager for this Joker!\"",
    "\"Someone knows real value when they see it! Bid increased!\"",
    "\"No hesitation! We have a fresh bid on the table!\"",
    "\"The room is heating up! Who will take this prize home?\"",
    "\"An aggressive move! The price keeps jumping higher!\"",
    "\"Going once, going twice... and a late bid comes in!\"",
    "\"Now we're talking! The previous offer has been outbid!\"",
    "\"A true connoisseur of Jokers raises the stakes!\"",
    "\"Incredible momentum! Another buyer steps into the ring!\"",
    "\"Can anyone top that? The bid pushes even higher!\"",
    "\"Money on the table! We have an increased offer!\"",
    "\"The gavel was about to fall, but another paddle goes up!\"",
    "\"Sensational bid! This Joker is quite the hot commodity!\"",
    "\"The competition is relentless! The price surges forward!\"",
    "\"High roller territory! The bids just keep rolling in!\""
}

local function get_auction_bidders()
    local pool = {}
    if G.P_CENTERS then
        for k, v in pairs(G.P_CENTERS) do
            if v.set == 'Joker' and not v.no_pool_flag and k ~= 'j_Witch_brew_auctioneer' and k ~= 'j_auctioneer' then
                pool[#pool + 1] = k
            end
        end
    end
    if #pool < 5 then
        pool = { 'j_joker', 'j_greedy_joker', 'j_lusty_joker', 'j_wrathful_joker', 'j_gluttenous_joker' }
    end
    pseudoshuffle(pool, pseudoseed('auction_bidders_' .. (G.GAME and G.GAME.round or 1)))
    local bidders = {}
    for i = 1, 5 do
        local k = pool[i] or 'j_joker'
        local c = G.P_CENTERS[k]
        bidders[i] = {
            key = k,
            name = (c and c.name) or ("Buyer #" .. i),
            center = c,
            bid_count = 0,
            last_action = "Interested"
        }
    end
    return bidders
end

local function open_auction_bidding_menu()
    if not (create_UIBox_generic_options and G.FUNCS.overlay_menu and G.AUCTIONEER_STATE and G.AUCTIONEER_STATE.target) then return end
    clean_auction_temp_areas()
    G.auction_temp_areas = {}

    local target = G.AUCTIONEER_STATE.target
    local t_scale = 0.65
    local t_area = CardArea(
        0, 0,
        G.CARD_W * t_scale,
        G.CARD_H * t_scale,
        { card_limit = 1, type = 'title', highlight_limit = 0, card_w = G.CARD_W * t_scale }
    )
    table.insert(G.auction_temp_areas, t_area)
    local target_copy = copy_card(target, nil, t_scale)
    t_area:emplace(target_copy)

    local b_scale = 0.45
    local bidder_cols = {}
    for i, b in ipairs(G.AUCTIONEER_STATE.bidders or {}) do
        local b_area = CardArea(
            0, 0,
            G.CARD_W * b_scale,
            G.CARD_H * b_scale,
            { card_limit = 1, type = 'title', highlight_limit = 0, card_w = G.CARD_W * b_scale }
        )
        table.insert(G.auction_temp_areas, b_area)
        local b_card = Card(0, 0, G.CARD_W * b_scale, G.CARD_H * b_scale, G.P_CARDS.empty, b.center or G.P_CENTERS.j_joker)
        if b.center then b_card:set_ability(b.center) end
        b_area:emplace(b_card)

        local status_col = G.C.WHITE
        local status_bg = { 0.15, 0.25, 0.35, 0.8 }
        if b.last_action and string.find(b.last_action, "+", 1, true) then
            status_bg = { 0.1, 0.5, 0.15, 0.9 }
        elseif b.last_action == "Passed" then
            status_col = G.C.RED
            status_bg = { 0.35, 0.1, 0.1, 0.8 }
        end

        table.insert(bidder_cols, {
            n = G.UIT.C,
            config = {
                align = "cm",
                padding = 0.05,
                minw = 1.6,
                r = 0.1,
                colour = { 0.06, 0.06, 0.06, 0.8 },
                outline = 0.02,
                outline_colour = { 0.3, 0.3, 0.3, 0.5 }
            },
            nodes = {
                {
                    n = G.UIT.R, config = { align = "cm", padding = 0.02 },
                    nodes = { { n = G.UIT.O, config = { object = b_area } } }
                },
                {
                    n = G.UIT.R, config = { align = "cm", maxw = 1.5 },
                    nodes = {
                        { n = G.UIT.T, config = { text = b.name or ("Buyer " .. i), scale = 0.26, colour = G.C.WHITE, shadow = true } }
                    }
                },
                {
                    n = G.UIT.R, config = {
                        align = "cm",
                        padding = 0.04,
                        minw = 1.4,
                        r = 0.08,
                        colour = status_bg
                    },
                    nodes = {
                        { n = G.UIT.T, config = { text = b.last_action or "Waiting", scale = 0.28, colour = status_col, shadow = true } }
                    }
                }
            }
        })
    end

    local target_name = (target.ability and target.ability.name) or (target.config and target.config.center and target.config.center.name) or "Joker"
    local t = create_UIBox_generic_options({
        back_func = 'auctioneer_sell_now',
        back_label = "Sell Now ($" .. G.AUCTIONEER_STATE.current_bid .. ")",
        contents = {
            {
                n = G.UIT.R, config = { align = "cm", padding = 0.1 },
                nodes = {
                    { n = G.UIT.T, config = { text = "🔨 LIVE AUCTION", scale = 0.65, colour = G.C.GOLD, shadow = true } }
                }
            },
            {
                n = G.UIT.R, config = { align = "cm", padding = 0.08 },
                nodes = {
                    {
                        n = G.UIT.C, config = { align = "cm", padding = 0.08, colour = G.C.L_BLACK, r = 0.12, outline = 0.03, outline_colour = G.C.GOLD },
                        nodes = {
                            { n = G.UIT.R, config = { align = "cm", padding = 0.02 }, nodes = { { n = G.UIT.O, config = { object = t_area } } } },
                            { n = G.UIT.R, config = { align = "cm" }, nodes = { { n = G.UIT.T, config = { text = target_name, scale = 0.32, colour = G.C.WHITE } } } }
                        }
                    },
                    {
                        n = G.UIT.C, config = { align = "cm", padding = 0.12, minw = 5.2, colour = G.C.BLACK, r = 0.12, outline = 0.04, outline_colour = G.C.GOLD },
                        nodes = {
                            { n = G.UIT.R, config = { align = "cm", padding = 0.02 }, nodes = {
                                { n = G.UIT.T, config = { text = "CURRENT HIGHEST BID", scale = 0.32, colour = G.C.GOLD } }
                            }},
                            { n = G.UIT.R, config = { align = "cm", padding = 0.04 }, nodes = {
                                { n = G.UIT.T, config = { text = "$" .. G.AUCTIONEER_STATE.current_bid, scale = 0.9, colour = G.C.WHITE, shadow = true } }
                            }},
                            { n = G.UIT.R, config = { align = "cm", padding = 0.02 }, nodes = {
                                { n = G.UIT.T, config = { text = "(Started at $" .. G.AUCTIONEER_STATE.start_bid .. ")", scale = 0.28, colour = G.C.UI.TEXT_INACTIVE } }
                            }},
                            { n = G.UIT.R, config = { align = "cm", padding = 0.06, colour = G.C.L_BLACK, r = 0.08, minw = 5.0, maxw = 6.0 }, nodes = {
                                { n = G.UIT.T, config = { text = G.AUCTIONEER_STATE.status_msg or "", scale = 0.30, maxw = 5.5, colour = G.C.GOLD, shadow = true } }
                            }}
                        }
                    }
                }
            },
            {
                n = G.UIT.R, config = { align = "cm", padding = 0.04 },
                nodes = {
                    { n = G.UIT.T, config = { text = "5 POTENTIAL BUYERS (1 in 5 chance each to raise the bid):", scale = 0.3, colour = G.C.WHITE } }
                }
            },
            {
                n = G.UIT.R, config = { align = "cm", padding = 0.08, colour = G.C.L_BLACK, r = 0.12 },
                nodes = bidder_cols
            },
            {
                n = G.UIT.R, config = { align = "cm", padding = 0.1 },
                nodes = {
                    {
                        n = G.UIT.C, config = {
                            align = "cm",
                            padding = 0.1,
                            minw = 3.6,
                            minh = 0.65,
                            r = 0.12,
                            hover = true,
                            colour = G.C.GREEN,
                            button = 'auctioneer_offer_more',
                            shadow = true
                        },
                        nodes = {
                            { n = G.UIT.T, config = { text = "📢 OFFER MORE", scale = 0.48, colour = G.C.WHITE, shadow = true } }
                        }
                    },
                    { n = G.UIT.B, config = { w = 0.4, h = 0.1 } },
                    {
                        n = G.UIT.C, config = {
                            align = "cm",
                            padding = 0.1,
                            minw = 3.2,
                            minh = 0.65,
                            r = 0.12,
                            hover = true,
                            colour = G.C.GOLD,
                            button = 'auctioneer_sell_now',
                            shadow = true
                        },
                        nodes = {
                            { n = G.UIT.T, config = { text = "💰 SELL NOW ($" .. G.AUCTIONEER_STATE.current_bid .. ")", scale = 0.42, colour = G.C.BLACK, shadow = false } }
                        }
                    }
                }
            }
        }
    })
    G.FUNCS.overlay_menu{ definition = t }
end

local function open_auction_select_menu(auctioneer_card)
    if not (create_UIBox_generic_options and G.FUNCS.overlay_menu) then return end
    clean_auction_temp_areas()
    G.auction_temp_areas = {}
    G.AUCTIONEER_STATE = {
        auctioneer = auctioneer_card,
        target = nil,
        current_bid = 0,
        start_bid = 0,
        round = 1,
        bidders = {},
        status_msg = ""
    }

    local total_jokers = (G.jokers and G.jokers.cards) or {}
    local candidates = {}
    for _, j in ipairs(total_jokers) do
        if j ~= auctioneer_card and not (j.ability and j.ability.eternal) then
            candidates[#candidates + 1] = j
        end
    end

    local card_scale = (#total_jokers > 5) and 0.52 or 0.65
    local joker_cols = {}

    for _, j in ipairs(total_jokers) do
        local is_auctioneer = (j == auctioneer_card)
        local is_eternal = (j.ability and j.ability.eternal)
        local can_auction = not is_auctioneer and not is_eternal

        local c_area = CardArea(
            0, 0,
            G.CARD_W * card_scale,
            G.CARD_H * card_scale,
            { card_limit = 1, type = 'title', highlight_limit = 0, card_w = G.CARD_W * card_scale }
        )
        table.insert(G.auction_temp_areas, c_area)
        local copy = copy_card(j, nil, card_scale)
        c_area:emplace(copy)

        local sell_val = j.sell_cost or 1
        local start_val = math.max(1, math.floor(sell_val / 2))

        local action_btn = nil
        if can_auction then
            action_btn = {
                n = G.UIT.R, config = {
                    align = "cm",
                    minw = 1.4,
                    minh = 0.45,
                    r = 0.1,
                    hover = true,
                    colour = G.C.GREEN,
                    button = 'auctioneer_choose_target',
                    ref_table = { card = j, auctioneer = auctioneer_card },
                    shadow = true
                },
                nodes = {
                    { n = G.UIT.T, config = { text = "🔨 AUCTION", scale = 0.36, colour = G.C.WHITE, shadow = true } }
                }
            }
        elseif is_auctioneer then
            action_btn = {
                n = G.UIT.R, config = {
                    align = "cm",
                    minw = 1.4,
                    minh = 0.45,
                    r = 0.1,
                    colour = G.C.UI.BACKGROUND_INACTIVE
                },
                nodes = {
                    { n = G.UIT.T, config = { text = "AUCTIONEER", scale = 0.28, colour = G.C.UI.TEXT_INACTIVE } }
                }
            }
        else
            action_btn = {
                n = G.UIT.R, config = {
                    align = "cm",
                    minw = 1.4,
                    minh = 0.45,
                    r = 0.1,
                    colour = G.C.UI.BACKGROUND_INACTIVE
                },
                nodes = {
                    { n = G.UIT.T, config = { text = "🔒 ETERNAL", scale = 0.28, colour = G.C.RED } }
                }
            }
        end

        table.insert(joker_cols, {
            n = G.UIT.C,
            config = {
                align = "cm",
                padding = 0.08,
                r = 0.12,
                colour = can_auction and { 0.08, 0.14, 0.08, 0.85 } or { 0.08, 0.08, 0.08, 0.8 },
                outline = can_auction and 0.04 or 0.02,
                outline_colour = can_auction and G.C.GREEN or { 0.3, 0.3, 0.3, 0.5 }
            },
            nodes = {
                {
                    n = G.UIT.R, config = { align = "cm", padding = 0.04 },
                    nodes = { { n = G.UIT.O, config = { object = c_area } } }
                },
                {
                    n = G.UIT.R, config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "Sell: $" .. sell_val, scale = 0.28, colour = G.C.WHITE } }
                    }
                },
                {
                    n = G.UIT.R, config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "Start: $" .. start_val, scale = 0.32, colour = can_auction and G.C.GOLD or G.C.UI.TEXT_INACTIVE, shadow = true } }
                    }
                },
                action_btn
            }
        })
    end

    local subtitle_text = (#candidates > 0)
        and "Select which Joker to put up for auction (Starting Bid = 50% sell value):"
        or "No eligible Jokers available to auction! (Auctioneer and Eternal Jokers cannot be auctioned)"

    local contents = {
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.12 },
            nodes = {
                { n = G.UIT.T, config = { text = "🔨 AUCTION HOUSE - SELECT A JOKER", scale = 0.62, colour = G.C.GOLD, shadow = true } }
            }
        },
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.04 },
            nodes = {
                { n = G.UIT.T, config = { text = subtitle_text, scale = 0.35, colour = (#candidates > 0) and G.C.WHITE or G.C.RED } }
            }
        },
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.1, colour = G.C.L_BLACK, r = 0.15, outline = 0.03, outline_colour = G.C.GOLD },
            nodes = joker_cols
        }
    }

    local t = create_UIBox_generic_options({
        back_func = 'exit_overlay_menu',
        back_label = "Cancel",
        contents = contents
    })
    G.FUNCS.overlay_menu{ definition = t }
end

-- Auctioneer Button Hook & Callbacks
if G and G.UIDEF and G.UIDEF.use_and_sell_buttons then
    local orig_auctioneer_use_and_sell = G.UIDEF.use_and_sell_buttons
    G.UIDEF.use_and_sell_buttons = function(card)
        local base_background = orig_auctioneer_use_and_sell(card)
        if not card or card.area ~= G.jokers or G.STATE == G.STATES.TUTORIAL then
            return base_background
        end
        if not base_background or not base_background.nodes or not base_background.nodes[1] or not base_background.nodes[1].nodes then
            return base_background
        end

        if card_has_key(card, 'auctioneer') or card_has_key(card, 'subastador') then
            local auction_btn_node = {
                n = G.UIT.R,
                config = { align = "cl" },
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
                                    one_press = true,
                                    button = 'auctioneer_open_select',
                                    func = 'can_auctioneer_open'
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
                                                    { n = G.UIT.T, config = { text = "AUCTION", colour = G.C.WHITE, scale = 0.38, shadow = true } }
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
            table.insert(base_background.nodes[1].nodes, auction_btn_node)
        end

        return base_background
    end
end

if G and G.FUNCS then
    G.FUNCS.can_auctioneer_open = function(e)
        local card = e.config.ref_table
        if not (card and card.debuff) and not (G.STATE == G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND) then
            e.config.colour = G.C.GOLD
            e.config.button = 'auctioneer_open_select'
        else
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        end
    end

    G.FUNCS.auctioneer_open_select = function(e)
        local card = (e and e.config and e.config.ref_table)
        if not card and G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if card_has_key(j, 'auctioneer') or card_has_key(j, 'subastador') then
                    card = j
                    break
                end
            end
        end
        open_auction_select_menu(card)
    end

    G.FUNCS.auctioneer_choose_target = function(e)
        if not e or not e.config or not e.config.ref_table or not e.config.ref_table.card then return end
        local target = e.config.ref_table.card
        local auctioneer = e.config.ref_table.auctioneer or (G.AUCTIONEER_STATE and G.AUCTIONEER_STATE.auctioneer)
        if not G.AUCTIONEER_STATE then G.AUCTIONEER_STATE = {} end
        G.AUCTIONEER_STATE.target = target
        G.AUCTIONEER_STATE.auctioneer = auctioneer
        local sell_val = target.sell_cost or 1
        local start_price = math.max(1, math.floor(sell_val / 2))
        G.AUCTIONEER_STATE.start_bid = start_price
        G.AUCTIONEER_STATE.current_bid = start_price
        G.AUCTIONEER_STATE.round = 1
        local target_name = (target.ability and target.ability.name) or (target.config and target.config.center and target.config.center.name) or "Joker"
        G.AUCTIONEER_STATE.status_msg = "\"Welcome! Bidding opens at $" .. start_price .. " for " .. target_name .. "!\""
        G.AUCTIONEER_STATE.bidders = get_auction_bidders()
        open_auction_bidding_menu()
    end

    G.FUNCS.auctioneer_offer_more = function(e)
        if not G.AUCTIONEER_STATE or not G.AUCTIONEER_STATE.target then return end

        local raised_count = 0
        local total_increase = 0
        local round = G.AUCTIONEER_STATE.round or 1

        for i, b in ipairs(G.AUCTIONEER_STATE.bidders or {}) do
            local roll = pseudorandom('auction_bid_' .. round .. '_' .. i)
            if roll < 0.20 then
                local raise_amt = pseudorandom('auction_amt_' .. round .. '_' .. i, 1, 3)
                b.bid_count = (b.bid_count or 0) + 1
                b.last_action = "+$" .. raise_amt .. "!"
                raised_count = raised_count + 1
                total_increase = total_increase + raise_amt
            else
                b.last_action = "Passed"
            end
        end

        if raised_count > 0 then
            G.AUCTIONEER_STATE.current_bid = G.AUCTIONEER_STATE.current_bid + total_increase
            G.AUCTIONEER_STATE.round = round + 1
            local quote = pseudorandom_element(auction_raise_dialogues, pseudoseed('auction_quote_' .. round))
            G.AUCTIONEER_STATE.status_msg = quote .. " (+$" .. total_increase .. "!)"
            play_sound('coin2', 1, 0.8)
            open_auction_bidding_menu()
        else
            G.FUNCS.auctioneer_finalize_sale()
        end
    end

    G.FUNCS.auctioneer_sell_now = function(e)
        G.FUNCS.auctioneer_finalize_sale()
    end

    G.FUNCS.auctioneer_finalize_sale = function()
        if not G.AUCTIONEER_STATE then return end
        local final_payout = G.AUCTIONEER_STATE.current_bid or 0
        local target = G.AUCTIONEER_STATE.target
        local auctioneer_card = G.AUCTIONEER_STATE.auctioneer

        clean_auction_temp_areas()
        G.AUCTIONEER_STATE = nil
        G.FUNCS.exit_overlay_menu()

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                ease_dollars(final_payout)
                if target and target.area then
                    target:start_dissolve()
                end
                play_sound('gold_seal')
                play_sound('coin1')

                attention_text({
                    text = "Sold! ($" .. final_payout .. ")",
                    scale = 1.0,
                    hold = 1.6,
                    major = auctioneer_card or G.jokers,
                    backdrop_colour = G.C.GOLD,
                    align = 'cm',
                    silent = true
                })

                if auctioneer_card then
                    card_eval_status_text(auctioneer_card, 'extra', nil, nil, nil, {
                        message = "Sold! +$" .. final_payout,
                        colour = G.C.GOLD
                    })
                    auctioneer_card:juice_up(0.6, 0.6)
                end
                return true
            end
        }))
    end
end

-- Parasitic, Uncommon Joker
SMODS.Joker {
    key = 'parasitic',
    atlas = 'witch_brew_jokers',
    loc_txt = {
        name = 'Parasitic',
        text = {
            "Attaches to a random Joker,",
            "giving {X:mult,C:white}X#1#{} Mult while host is owned.",
            "Migrates every {C:attention}3 rounds{}.",
            "Self-destructs if alone.",
            "{C:inactive}(Host: {C:attention}#2#{C:inactive}, migrates in: {C:attention}#3#{C:inactive} rnd){}"
        }
    },
    config = { extra = { host_key = '', rounds_since_migrate = 0, x_mult = 1.75 } },
    rarity = 2,
    pos = { x = 5, y = 8 },
    cost = 7,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local host_name = "None"
        if ex.host_key and ex.host_key ~= '' and G.P_CENTERS and G.P_CENTERS[ex.host_key] then
            host_name = localize{type = 'name_text', set = 'Joker', key = ex.host_key}
        end
        return { vars = { ex.x_mult or 1.75, host_name, math.max(0, 3 - (ex.rounds_since_migrate or 0)) } }
    end,
    calculate = function(self, card, context)
        -- Attach to host on first blind or migration
        if context.setting_blind and not context.blueprint then
            local others = {}
            if G.jokers and G.jokers.cards then
                for _, jk in ipairs(G.jokers.cards) do
                    if jk ~= card then others[#others + 1] = jk end
                end
            end
            if #others == 0 then
                -- Self-destruct
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card:start_dissolve()
                        return true
                    end
                }))
                return { message = 'No Host!', colour = G.C.RED, card = card }
            end
            card.ability.extra.rounds_since_migrate = (card.ability.extra.rounds_since_migrate or 0) + 1
            if card.ability.extra.host_key == '' or card.ability.extra.rounds_since_migrate >= 3 then
                local new_host = pseudorandom_element(others, pseudoseed('parasitic_host'))
                card.ability.extra.host_key = new_host.config and new_host.config.center and new_host.config.center.key or ''
                card.ability.extra.rounds_since_migrate = 0
                return { message = 'Migrated!', colour = G.C.ATTENTION, card = card }
            end
        end

        -- Double host Joker effect via x_mult when host activates
        if context.joker_main and not context.blueprint then
            -- Find host joker
            local host = nil
            if G.jokers and G.jokers.cards and card.ability.extra.host_key ~= '' then
                for _, jk in ipairs(G.jokers.cards) do
                    local k = jk.config and jk.config.center and jk.config.center.key or ''
                    if k == card.ability.extra.host_key then host = jk; break end
                end
            end
            if host then
                return {
                    x_mult = card.ability.extra.x_mult or 1.75,
                    card = card,
                    message = 'Parasite!'
                }
            end
        end
    end
}

-- Mercenary, Uncommon Joker
SMODS.Joker {
    key = 'mercenary',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    unlock = { "Defeat {C:attention}5 Boss Blinds{}", "in a single run" },
    loc_txt = {
        name = 'Mercenary',
        text = {
            "No passive effect. Has up to {C:attention}5 contracts{}.",
            "Complete one to earn a reward",
            "and get a harder contract.",
            "{C:inactive}(Active: #1#/#2# — #3#){}"
        }
    },
    config = { extra = {
        contracts = {},
        max_contracts = 5,
        active_count = 0,
        boss_defeats = 0
    }},
    rarity = 2,
    pos = { x = 6, y = 8 },
    cost = 7,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        local first = (ex.contracts and ex.contracts[1] and ex.contracts[1].name) or 'None'
        return { vars = {
            ex.active_count or 0,
            ex.max_contracts or 5,
            first
        }}
    end,
    calculate = function(self, card, context)
        local ex = card.ability.extra
        -- Contract pool
        local contract_pool = {
            { name = 'Play 3 Straights',    type = 'hand', target = 'Straight', needed = 3 },
            { name = 'Play 2 Flushes',      type = 'hand', target = 'Flush', needed = 2 },
            { name = 'Earn $20',            type = 'money', needed = 20 },
            { name = 'Play 5 Pairs',        type = 'hand', target = 'Pair', needed = 5 },
            { name = 'Play 1 Full House',   type = 'hand', target = 'Full House', needed = 1 },
            { name = 'Earn $35',            type = 'money', needed = 35 },
            { name = 'Play 3 Two Pairs',    type = 'hand', target = 'Two Pair', needed = 3 },
            { name = 'Play 1 Four of a Kind', type = 'hand', target = 'Four of a Kind', needed = 1 },
        }

        local function new_contract()
            local c = pseudorandom_element(contract_pool, pseudoseed('mercenary_contract'))
            return { name = c.name, type = c.type, target = c.target, needed = c.needed, progress = 0 }
        end

        -- Init contracts at game start
        if context.setting_blind and not context.blueprint then
            if #ex.contracts == 0 then
                for i = 1, 3 do ex.contracts[i] = new_contract() end
                ex.active_count = 3
            end
            -- Track boss defeats for unlock
            if G.GAME.blind and G.GAME.blind.boss then
                ex.boss_defeats = (ex.boss_defeats or 0) + 1
            end
        end

        if context.joker_main and not context.blueprint then
            local hand_name = context.scoring_name or ''
            local completed = false
            for i, con in ipairs(ex.contracts) do
                if con.type == 'hand' and con.target == hand_name then
                    con.progress = (con.progress or 0) + 1
                    if con.progress >= con.needed then
                        -- Complete!
                        ease_dollars(8)
                        table.remove(ex.contracts, i)
                        if #ex.contracts < ex.max_contracts then
                            ex.contracts[#ex.contracts + 1] = new_contract()
                        end
                        ex.active_count = #ex.contracts
                        return { message = 'Contract Done! +$8', colour = G.C.MONEY, card = card }
                    end
                end
            end
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            -- Check money contracts
            local dollars = tonumber(G.GAME and G.GAME.dollars) or 0
            for i, con in ipairs(ex.contracts) do
                if con.type == 'money' and dollars >= con.needed then
                    ease_dollars(10)
                    table.remove(ex.contracts, i)
                    ex.contracts[#ex.contracts + 1] = new_contract()
                    ex.active_count = #ex.contracts
                    return { message = 'Contract Done! +$10', colour = G.C.MONEY, card = card }
                end
            end
        end

        -- Unlock check
        if ex.boss_defeats and ex.boss_defeats >= 5 then
            G.GAME.witch_brew_merc_unlocked = true
        end
    end
}

-- Cascade, Uncommon Joker
SMODS.Joker {
    key = 'cascade',
    atlas = 'witch_brew_jokers',
    unlocked = false,
    unlock = { "Score {C:attention}double{} or more", "of a blind's requirement" },
    loc_txt = {
        name = 'Cascade',
        text = {
            "If total round score is {C:attention}2X+{} blind requirement,",
            "store {C:attention}25%{} of excess {C:chips}Chips{} to add",
            "to your {C:attention}first hand{} of next blind.",
            "{C:inactive}(Stored: {C:chips}+#1#{C:inactive} Chips){}"
        }
    },
    config = { extra = { stored_chips = 0 } },
    rarity = 2,
    pos = { x = 0, y = 9 },
    cost = 6,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { (card and card.ability.extra.stored_chips) or 0 } }
    end,
    check_for_unlock = function(self, args)
        if G.GAME and (G.GAME.witch_brew_cascade_double or G.GAME.witch_brew_cascada_double) then
            return true
        end
    end,
    calculate = function(self, card, context)
        -- Apply stored chips on first hand of new blind
        if context.joker_main then
            if (card.ability.extra.stored_chips or 0) > 0 then
                local bonus = card.ability.extra.stored_chips
                if not context.blueprint then
                    card.ability.extra.stored_chips = 0
                end
                return { chips = bonus, card = card, message = 'Cascade! +'..bonus..' Chips' }
            end
        end

        -- Store excess on round end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local blind_req = (G.GAME and G.GAME.blind and G.GAME.blind.chips) or 0
            local scored = (G.GAME and G.GAME.chips) or (G.GAME and G.GAME.current_round and G.GAME.current_round.current_hand and G.GAME.current_round.current_hand.chips) or 0
            if scored >= blind_req * 2 then
                local excess = math.floor((scored - blind_req) * 0.25)
                if excess > 0 then
                    card.ability.extra.stored_chips = (card.ability.extra.stored_chips or 0) + excess
                    G.GAME.witch_brew_cascade_double = true
                    G.GAME.witch_brew_cascada_double = true
                    return { message = 'Stored '..excess..' Chips!', colour = G.C.CHIPS, card = card }
                end
            end
        end
    end
}
