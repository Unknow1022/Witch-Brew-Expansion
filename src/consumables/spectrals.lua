-- Spectral Cards
SMODS.Atlas {
    key = "c_spectrals",
    path = "c_spectrals.png",
    px = 71,
    py = 95
}
-- 1. Hierarchy
SMODS.Consumable {
    key = 'hierarchy',
    set = 'Spectral',
    atlas = 'c_spectrals',
    pos = { x = 0, y = 0 },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    loc_txt = {
        name = 'Hierarchy',
        text = {
            "Destroy {C:attention}all cards in hand{},",
            "create {C:attention}3 Steel Kings{} with {C:red}Red Seal{},",
            "{C:blue}-1 Hand{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
            if G.P_SEALS and G.P_SEALS.Red then
                info_queue[#info_queue + 1] = G.P_SEALS.Red
            else
                info_queue[#info_queue + 1] = { key = 'red_seal', set = 'Other' }
            end
        end
        return { vars = {} }
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end,
    use = function(self, card, area, copier)
        local destroyed_cards = {}
        for i = 1, #G.hand.cards do
            destroyed_cards[#destroyed_cards + 1] = G.hand.cards[i]
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot2')
                card:juice_up(0.4, 0.6)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                for i = #destroyed_cards, 1, -1 do
                    local d_card = destroyed_cards[i]
                    if d_card.ability and d_card.ability.name == 'Glass Card' then
                        d_card:shatter()
                    else
                        d_card:start_dissolve(nil, i == #destroyed_cards)
                    end
                end
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                local cards = {}
                play_sound('tarot1')
                for i = 1, 3 do
                    local suits = {'Hearts', 'Diamonds', 'Spades', 'Clubs'}
                    local chosen_suit = pseudorandom_element(suits, 'hierarchy_suit')
                    local suit_prefix = string.sub(chosen_suit, 1, 1)

                    cards[i] = create_playing_card({
                        front = G.P_CARDS[suit_prefix .. '_K'],
                        center = G.P_CENTERS.m_steel
                    }, G.hand, nil, i ~= 1, {G.C.SECONDARY_SET.Spectral})
                    cards[i]:set_seal('Red', nil, true)
                    cards[i]:juice_up(0.4, 0.4)
                end
                playing_card_joker_effects(cards)
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Hierarchy Created!', colour = G.C.SECONDARY_SET.Spectral })
                return true
            end
        }))
        ease_hands_played(-1)
    end
}

-- 2. Order
SMODS.Consumable {
    key = 'order',
    set = 'Spectral',
    atlas = 'c_spectrals',
    pos = { x = 1, y = 0 },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    loc_txt = {
        name = 'Order',
        text = {
            "Add a {C:green}Dark Green Seal{}",
            "to {C:attention}1 selected card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            local dark_green_seal = (G.P_SEALS and (G.P_SEALS['Witch_brew_dark_green'] or G.P_SEALS['dark_green'])) or { set = 'Seal', key = 'Witch_brew_dark_green' }
            info_queue[#info_queue + 1] = dark_green_seal
        end
        return { vars = {} }
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                local seal_key = (G.P_SEALS and (G.P_SEALS['Witch_brew_dark_green'] and 'Witch_brew_dark_green' or G.P_SEALS['Witch brew_dark_green'] and 'Witch brew_dark_green' or G.P_SEALS['dark_green'] and 'dark_green')) or 'Witch_brew_dark_green'
                target:set_seal(seal_key, nil, true)
                target:juice_up(0.5, 0.5)
                card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Dark Green Seal!', colour = HEX('1b4d2e') })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

-- 3. Rot
SMODS.Consumable {
    key = 'rot',
    set = 'Spectral',
    atlas = 'c_spectrals',
    pos = { x = 2, y = 0 },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    loc_txt = {
        name = 'Rot',
        text = {
            "Destroy {C:attention}all current Jokers{}",
            "{C:inactive}(including Eternal){},",
            "create {C:red}2 random Rare Eternal Jokers{},",
            "{C:red}-1 Discard{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = { key = 'eternal', set = 'Other' }
        end
        return { vars = {} }
    end,
    can_use = function(self, card)
        return G.jokers and #G.jokers.cards > 0
    end,
    use = function(self, card, area, copier)
        ease_discard(-1)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot2')
                card:juice_up(0.4, 0.6)
                for i = #G.jokers.cards, 1, -1 do
                    local j = G.jokers.cards[i]
                    if j.ability then
                        j.ability.eternal = nil
                    end
                    j:start_dissolve()
                end
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                play_sound('foil1')
                for i = 1, 2 do
                    local new_joker = create_card('Joker', G.jokers, nil, 3, nil, nil, nil, 'rot')
                    new_joker:set_eternal(true)
                    new_joker:add_to_deck()
                    G.jokers:emplace(new_joker)
                    new_joker:juice_up(0.5, 0.5)
                end
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Rot Harvest!', colour = G.C.RED })
                return true
            end
        }))
    end
}

-- 4. Catastrophic
local function get_most_played_hands()
    local hands_by_count = {}
    local counts = {}
    if G.GAME and G.GAME.hands then
        for hand_name, hand_data in pairs(G.GAME.hands) do
            if hand_data.visible then
                local played = hand_data.played or 0
                if not hands_by_count[played] then
                    hands_by_count[played] = {}
                    table.insert(counts, played)
                end
                table.insert(hands_by_count[played], hand_name)
            end
        end
    end
    table.sort(counts, function(a, b)
        if to_big then
            return to_big(a) > to_big(b)
        else
            return (a or 0) > (b or 0)
        end
    end)

    local most_played = nil
    local second_played = nil

    if #counts > 0 then
        local top_count = counts[1]
        local top_group = hands_by_count[top_count]
        most_played = pseudorandom_element(top_group, 'catastrophic_top')

        local remaining_top = {}
        for _, h in ipairs(top_group) do
            if h ~= most_played then table.insert(remaining_top, h) end
        end

        if #remaining_top > 0 then
            second_played = pseudorandom_element(remaining_top, 'catastrophic_second')
        elseif #counts > 1 then
            local second_count = counts[2]
            second_played = pseudorandom_element(hands_by_count[second_count], 'catastrophic_second')
        else
            second_played = most_played
        end
    end

    return most_played or 'High Card', second_played or 'Pair'
end

local hand_to_planet = {
    ['High Card'] = 'c_pluto',
    ['Pair'] = 'c_mercury',
    ['Two Pair'] = 'c_uranus',
    ['Three of a Kind'] = 'c_venus',
    ['Straight'] = 'c_saturn',
    ['Flush'] = 'c_jupiter',
    ['Full House'] = 'c_earth',
    ['Four of a Kind'] = 'c_mars',
    ['Straight Flush'] = 'c_neptune',
    ['Five of a Kind'] = 'c_planet_x',
    ['Flush House'] = 'c_ceres',
    ['Flush Five'] = 'c_eris'
}

SMODS.Consumable {
    key = 'catastrophic',
    set = 'Spectral',
    atlas = 'c_spectrals',
    pos = { x = 3, y = 0 },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    loc_txt = {
        name = 'Catastrophic',
        text = {
            "{C:attention}+4 levels{} to your most played hand,",
            "{C:red}-2 levels{} to all other hands"
        }
    },
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        local most_played = get_most_played_hands()

        play_sound('tarot2')
        card:juice_up(0.4, 0.6)
        local new_level = to_big and (to_big(G.GAME.hands[most_played].level) + to_big(4)) or (G.GAME.hands[most_played].level + 4)
        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname = most_played, level = new_level})
        level_up_hand(card, most_played, false, 4)

        for hand_name, hand_data in pairs(G.GAME.hands) do
            if hand_name ~= most_played then
                local current_lvl = hand_data.level
                local num_lvl = (type(current_lvl) == 'table' and to_number and to_number(current_lvl)) or tonumber(current_lvl) or 1
                if num_lvl > 1 then
                    local deduction = (num_lvl > 2) and -2 or -1
                    level_up_hand(card, hand_name, true, deduction)
                end
            end
        end

        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Catastrophic!', colour = G.C.DARK_EDITION })
    end
}

-- 5. Intensity
SMODS.Consumable {
    key = 'intensity',
    set = 'Spectral',
    atlas = 'c_spectrals',
    pos = { x = 0, y = 1 },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    loc_txt = {
        name = 'Intensity',
        text = {
            "Destroy {C:attention}5 selected cards{},",
            "create {C:attention}1 Polychrome Wild Card{}",
            "with {C:red}Red Seal{}",
            "of random rank and suit"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
            info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
            if G.P_SEALS and G.P_SEALS.Red then
                info_queue[#info_queue + 1] = G.P_SEALS.Red
            else
                info_queue[#info_queue + 1] = { key = 'red_seal', set = 'Other' }
            end
        end
        return { vars = {} }
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 5
    end,
    use = function(self, card, area, copier)
        local destroyed_cards = {}
        for _, c in ipairs(G.hand.highlighted) do
            table.insert(destroyed_cards, c)
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot2')
                card:juice_up(0.4, 0.6)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                for i = #destroyed_cards, 1, -1 do
                    local d_card = destroyed_cards[i]
                    if d_card.ability and d_card.ability.name == 'Glass Card' then
                        d_card:shatter()
                    else
                        d_card:start_dissolve(nil, i == #destroyed_cards)
                    end
                end
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                local suits = {'Hearts', 'Diamonds', 'Spades', 'Clubs'}
                local ranks = {'2','3','4','5','6','7','8','9','10','J','Q','K','A'}
                local chosen_suit = pseudorandom_element(suits, 'intensity_suit')
                local chosen_rank = pseudorandom_element(ranks, 'intensity_rank')
                local suit_prefix = string.sub(chosen_suit, 1, 1)

                play_sound('polychrome1')
                local new_card = create_playing_card({
                    front = G.P_CARDS[suit_prefix .. '_' .. chosen_rank],
                    center = G.P_CENTERS.m_wild
                }, G.hand, nil, nil, {G.C.SECONDARY_SET.Spectral})

                new_card:set_edition('e_polychrome', true)
                new_card:set_seal('Red', nil, true)
                new_card:juice_up(0.6, 0.6)
                playing_card_joker_effects({new_card})
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Intense Genesis!', colour = G.C.SECONDARY_SET.Spectral })
                return true
            end
        }))
    end
}

-- 6. La Muchachada
SMODS.Consumable {
    key = 'la_muchachada',
    set = 'Spectral',
    atlas = 'c_spectrals',
    pos = { x = 1, y = 1 },
    loc_txt = {
        name = 'La Muchachada',
        text = {
            "Creates a random {C:attention}Secret Joker{}",
            "{C:inactive}(Must have room){}",
            "{C:inactive}(\"LLEGO UN MIEMBRO DE LA MUCHACHADA!!\"){}"
        }
    },
    in_pool = function(self, args)
        return false, { allow_duplicates = false }
    end,
    can_use = function(self, card)
        return G.jokers and #G.jokers.cards < G.jokers.config.card_limit
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot2')
                card:juice_up(0.5, 0.8)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                local secret_keys = {
                    'j_Witch_brew_esteban', 'j_Witch_brew_thiago', 'j_Witch_brew_black_hole_joker',
                    'j_Witch_brew_squele', 'j_Witch_brew_bluxdir', 'j_Witch_brew_charles', 'j_Witch_brew_mochi',
                    'j_Witch_brew_helin', 'j_Witch_brew_raytracing', 'j_Witch_brew_paco', 'j_Witch_brew_yairo',
                    'j_Witch_brew_kyra'
                }
                local valid_secret_keys = {}
                for _, k in ipairs(secret_keys) do
                    if G.P_CENTERS and G.P_CENTERS[k] then
                        table.insert(valid_secret_keys, k)
                    end
                end
                local chosen_key = (#valid_secret_keys > 0) and pseudorandom_element(valid_secret_keys, 'la_muchachada_secret') or pseudorandom_element(secret_keys, 'la_muchachada_secret')
                play_sound('foil1')
                local new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_key, 'la_muchachada')
                new_joker:add_to_deck()
                G.jokers:emplace(new_joker)
                new_joker:juice_up(0.8, 0.8)
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = "LLEGO UN MIEMBRO DE LA MUCHACHADA!!", colour = G.C.DARK_EDITION })
                return true
            end
        }))
    end
}

-- 7. Refuerzo
SMODS.Consumable {
    key = 'refuerzo',
    set = 'Spectral',
    atlas = 'c_spectrals',
    pos = { x = 2, y = 1 },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    loc_txt = {
        name = 'Reinforcement',
        text = {
            "Add a {C:chips}Silver Seal{}",
            "to {C:attention}1 selected card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            local silver_seal = (G.P_SEALS and (G.P_SEALS['Witch_brew_silver'] or G.P_SEALS['silver'])) or { set = 'Seal', key = 'Witch_brew_silver' }
            info_queue[#info_queue + 1] = silver_seal
        end
        return { vars = {} }
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                local seal_key = (G.P_SEALS and (G.P_SEALS['Witch_brew_silver'] and 'Witch_brew_silver' or G.P_SEALS['Witch brew_silver'] and 'Witch brew_silver' or G.P_SEALS['silver'] and 'silver')) or 'Witch_brew_silver'
                play_sound('gold_seal')
                target:set_seal(seal_key, nil, true)
                target:juice_up(0.5, 0.5)
                card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Silver Seal!', colour = HEX('bdc3c7') })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

-- 8. Supernova
SMODS.Consumable {
    key = 'supernova',
    set = 'Spectral',
    atlas = 'c_spectrals',
    pos = { x = 3, y = 1 },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    loc_txt = {
        name = 'Supernova',
        text = {
            "Add a {C:planet}White Seal{}",
            "to {C:attention}1 selected card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            local white_seal = (G.P_SEALS and (G.P_SEALS['Witch_brew_white'] or G.P_SEALS['white'])) or { set = 'Seal', key = 'Witch_brew_white' }
            info_queue[#info_queue + 1] = white_seal
        end
        return { vars = {} }
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                local seal_key = (G.P_SEALS and (G.P_SEALS['Witch_brew_white'] and 'Witch_brew_white' or G.P_SEALS['Witch brew_white'] and 'Witch brew_white' or G.P_SEALS['white'] and 'white')) or 'Witch_brew_white'
                play_sound('tarot2')
                target:set_seal(seal_key, nil, true)
                target:juice_up(0.5, 0.5)
                card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'White Seal!', colour = G.C.WHITE })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

-- Track last sold or destroyed joker for Nigromancia
if Card and Card.sell_card then
    local orig_sell_card = Card.sell_card
    function Card:sell_card()
        if self.ability and self.ability.set == 'Joker' and G.GAME then
            local j_key = (self.config and self.config.center and self.config.center.key) or self.ability.name
            if j_key and j_key ~= '' then
                G.GAME.witch_brew_last_destroyed_joker = {
                    key = j_key,
                    edition = self.edition and copy_table(self.edition) or nil
                }
            end
        end
        return orig_sell_card(self)
    end
end

if Card and Card.start_dissolve then
    local orig_start_dissolve = Card.start_dissolve
    function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice)
        if self.ability and self.ability.set == 'Joker' and G.GAME and not self.getting_sliced_from_sell then
            local j_key = (self.config and self.config.center and self.config.center.key) or self.ability.name
            if j_key and j_key ~= '' then
                G.GAME.witch_brew_last_destroyed_joker = {
                    key = j_key,
                    edition = self.edition and copy_table(self.edition) or nil
                }
            end
        end
        return orig_start_dissolve(self, dissolve_colours, silent, dissolve_time_fac, no_juice)
    end
end

-- 9. Nigromancia
SMODS.Consumable {
    key = 'nigromancia',
    set = 'Spectral',
    atlas = 'c_spectrals',
    pos = { x = 0, y = 2 },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    loc_txt = {
        name = 'Necromancy',
        text = {
            "Create a copy of the {C:attention}last Joker{}",
            "sold or destroyed {C:inactive}(#1#){}",
            "with {C:attention}Perishable{},",
            "set money to {C:money}$0{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            local p_rounds = (G.GAME and G.GAME.perishable_rounds) or 5
            info_queue[#info_queue + 1] = { key = 'perishable', set = 'Other', vars = { p_rounds, p_rounds } }
        end
        local target_name = "None"
        if G.GAME and G.GAME.witch_brew_last_destroyed_joker then
            local k = G.GAME.witch_brew_last_destroyed_joker.key
            if G.P_CENTERS and G.P_CENTERS[k] then
                target_name = localize{type = 'name_text', key = k, set = 'Joker'}
            else
                target_name = tostring(k)
            end
        end
        return { vars = { target_name } }
    end,
    can_use = function(self, card)
        return G.jokers and #G.jokers.cards < G.jokers.config.card_limit and G.GAME and G.GAME.witch_brew_last_destroyed_joker ~= nil
    end,
    use = function(self, card, area, copier)
        local target_data = G.GAME and G.GAME.witch_brew_last_destroyed_joker
        if not target_data then return end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot2')
                card:juice_up(0.4, 0.6)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            func = function()
                play_sound('foil1')
                local new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, target_data.key, 'nigromancia')
                new_joker:set_perishable(true)
                if target_data.edition then
                    new_joker:set_edition(target_data.edition, true)
                end
                new_joker:add_to_deck()
                G.jokers:emplace(new_joker)
                new_joker:juice_up(0.6, 0.6)
                card_eval_status_text(new_joker, 'extra', nil, nil, nil, { message = 'Nigromancia!', colour = G.C.SECONDARY_SET.Spectral })
                return true
            end
        }))
        if G.GAME.dollars and G.GAME.dollars ~= 0 then
            ease_dollars(-G.GAME.dollars, true)
        end
    end
}

-- 10. Exorcism
SMODS.Consumable {
    key = 'exorcism',
    set = 'Spectral',
    atlas = 'c_spectrals',
    pos = { x = 1, y = 2 },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    loc_txt = {
        name = 'Exorcism',
        text = {
            "Removes {C:attention}Eternal{}, {C:attention}Perishable{},",
            "{C:attention}Rental{} and {C:attention}Debuff{} from a",
            "{C:attention}random Joker{} {C:inactive}(or selected){}"
        }
    },
    can_use = function(self, card)
        if G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
            for _, j in ipairs(G.jokers.cards) do
                if j.ability and (j.ability.eternal or j.ability.perishable or j.ability.rental or j.debuff or j.pinned) then
                    return true
                end
            end
        end
        return false
    end,
    use = function(self, card, area, copier)
        local candidates = {}
        for _, j in ipairs(G.jokers.cards) do
            if j.ability and (j.ability.eternal or j.ability.perishable or j.ability.rental or j.debuff or j.pinned) then
                table.insert(candidates, j)
            end
        end
        local target = (G.jokers.highlighted and #G.jokers.highlighted == 1 and G.jokers.highlighted[1])
            or (#candidates > 0 and pseudorandom_element(candidates, 'exorcism'))
            or (G.jokers.cards and pseudorandom_element(G.jokers.cards, 'exorcism'))

        if target then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.3,
                func = function()
                    play_sound('tarot2')
                    card:juice_up(0.4, 0.6)
                    if target.ability then
                        target.ability.eternal = nil
                        target.ability.perishable = nil
                        target.ability.perish_tally = nil
                        target.ability.rental = nil
                    end
                    target.pinned = nil
                    if target.set_cost then target:set_cost() end
                    if target.debuff and target.set_debuff then target:set_debuff(false) end
                    target:juice_up(0.5, 0.5)
                    card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Exorcised!', colour = G.C.PURPLE })
                    if G.jokers and G.jokers.unhighlight_all then G.jokers:unhighlight_all() end
                    return true
                end
            }))
        end
    end
}

-- 11. Erradicación
SMODS.Consumable {
    key = 'erradicacion',
    set = 'Spectral',
    atlas = 'c_spectrals',
    pos = { x = 2, y = 2 },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    loc_txt = {
        name = 'Eradication',
        text = {
            "Destroy up to {C:attention}4 selected cards{},",
            "{C:red}-$5{}"
        }
    },
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted >= 1 and #G.hand.highlighted <= 4
    end,
    use = function(self, card, area, copier)
        local destroyed = {}
        for _, c in ipairs(G.hand.highlighted) do table.insert(destroyed, c) end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                for i = #destroyed, 1, -1 do
                    local d = destroyed[i]
                    if d.ability and d.ability.name == 'Glass Card' then
                        d:shatter()
                    else
                        d:start_dissolve(nil, i == #destroyed)
                    end
                end
                return true
            end
        }))
        if G.GAME.dollars then ease_dollars(-5) end
    end
}

-- 12. Transmutación
SMODS.Consumable {
    key = 'transmutacion',
    set = 'Spectral',
    atlas = 'c_spectrals',
    pos = { x = 3, y = 2 },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    loc_txt = {
        name = 'Transmutation',
        text = {
            "Converts {C:attention}3 selected cards{}",
            "into the {C:attention}rank and suit{} of the",
            "{C:attention}leftmost{} selected card"
        }
    },
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 3
    end,
    use = function(self, card, area, copier)
        local cards = G.hand.highlighted
        local leftmost = cards[1]
        for i = 1, #cards do
            if cards[i].T.x < leftmost.T.x then leftmost = cards[i] end
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            func = function()
                play_sound('tarot2')
                card:juice_up(0.4, 0.6)
                for i = 1, #cards do
                    if cards[i] ~= leftmost then
                        copy_card(leftmost, cards[i])
                        cards[i]:juice_up(0.4, 0.4)
                    end
                end
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

local orig_init_loc_spectrals = init_localization
function init_localization()
    if orig_init_loc_spectrals then orig_init_loc_spectrals() end
    if G.localization and G.localization.descriptions and G.localization.descriptions.Spectral then
        local is_es = (G.SETTINGS and (G.SETTINGS.language == 'es' or G.SETTINGS.language == 'es_419' or G.SETTINGS.language == 'es_ES')) or (G.Witch_brew_SPANISH == true)
        if is_es then
            local c_nigr = G.localization.descriptions.Spectral.c_Witch_brew_nigromancia or G.localization.descriptions.Spectral.c_nigromancia
            if c_nigr then
                c_nigr.name = "Nigromancia"
                c_nigr.text = {
                    "Crea una copia del {C:attention}último Joker{}",
                    "vendido o destruido {C:inactive}(#1#){}",
                    "con {C:attention}Perecedero{},",
                    "establece el dinero a {C:money}$0{}"
                }
                if reparse_localization_entry then reparse_localization_entry(c_nigr) end
            end
            local c_exor = G.localization.descriptions.Spectral.c_Witch_brew_exorcism or G.localization.descriptions.Spectral.c_exorcism
            if c_exor then
                c_exor.name = "Exorcismo"
                c_exor.text = {
                    "Elimina {C:attention}Eterno{}, {C:attention}Perecedero{},",
                    "{C:attention}Alquiler{} y {C:attention}Debuff{} de un",
                    "{C:attention}Joker aleatorio{} {C:inactive}(o seleccionado){}"
                }
                if reparse_localization_entry then reparse_localization_entry(c_exor) end
            end
            local c_errad = G.localization.descriptions.Spectral.c_Witch_brew_erradicacion or G.localization.descriptions.Spectral.c_erradicacion
            if c_errad then
                c_errad.name = "Erradicación"
                c_errad.text = {
                    "Destruye hasta {C:attention}4 cartas seleccionadas{},",
                    "{C:red}-$5{}"
                }
                if reparse_localization_entry then reparse_localization_entry(c_errad) end
            end
            local c_trans = G.localization.descriptions.Spectral.c_Witch_brew_transmutacion or G.localization.descriptions.Spectral.c_transmutacion
            if c_trans then
                c_trans.name = "Transmutación"
                c_trans.text = {
                    "Convierte {C:attention}3 cartas seleccionadas{}",
                    "en el {C:attention}rango y palo{} de la carta",
                    "seleccionada más a la {C:attention}izquierda{}"
                }
                if reparse_localization_entry then reparse_localization_entry(c_trans) end
            end
        end
    end
end


