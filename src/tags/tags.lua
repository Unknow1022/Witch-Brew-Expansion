-- Tags Atlas
SMODS.Atlas {
    key = "witch_brew_tags",
    path = "tags.png",
    px = 34,
    py = 34
}
-- Tags
-- Discord Tag
SMODS.Tag {
    key = 'discord',
    atlas = 'witch_brew_tags',
    pos = { x = 0, y = 0 },
    min_ante = 1,
    loc_txt = {
        name = 'Discord Tag',
        text = {
            "{C:green}#1# in 5{} chance to create",
            "{C:spectral}The Gang{}",
            "{C:inactive}(Must have room){}"
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = { (G.GAME and G.GAME.probabilities.normal or 1) } }
    end,
    apply = function(self, tag, context)
        if context.type == 'immediate' or context.type == 'round_start_bonus' or context.type == 'new_blind_choice' or context.type == 'tag_add' then
            tag:yep('+', G.C.SECONDARY_SET.Spectral, function()
                if pseudorandom('discord_tag') < ((G.GAME and G.GAME.probabilities.normal or 1) / 5) then
                    if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                        local tag_muchachada_key = (G.P_CENTERS and G.P_CENTERS['c_Witch_brew_the_gang'] and 'c_Witch_brew_the_gang') or (G.P_CENTERS and G.P_CENTERS['c_Witch_brew_la_muchachada'] and 'c_Witch_brew_la_muchachada') or 'c_the_gang'
                        local card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, tag_muchachada_key, 'discord_tag')
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                    end
                end
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- Witchcraft Tag (Tag de Brujería)
SMODS.Tag {
    key = 'brujeria',
    atlas = 'witch_brew_tags',
    pos = { x = 1, y = 0 },
    min_ante = 1,
    loc_txt = {
        name = 'Witchcraft Tag',
        text = {
            "Gives a free",
            "{C:spectral}Mega Spectral Pack{}"
        }
    },
    loc_vars = function(self, info_queue)
        local pack_center = G.P_CENTERS['p_spectral_mega_1'] or G.P_CENTERS['p_spectral_mega_2'] or { key = 'p_spectral_mega_1', set = 'Booster' }
        if pack_center then
            table.insert(info_queue, pack_center)
        end
        return { vars = {} }
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            tag:yep('+', G.C.SECONDARY_SET.Spectral, function()
                local pack_center = G.P_CENTERS['p_spectral_mega_1'] or G.P_CENTERS['p_spectral_mega_2'] or G.P_CENTERS['p_spectral_jumbo_1'] or G.P_CENTERS['p_spectral_normal_1']
                if pack_center then
                    local pack = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2, G.play.T.y + G.play.T.h/2 - G.CARD_H*1.27/2, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, pack_center, {bypass_discovery_center = true, bypass_discovery_ui = true})
                    pack.cost = 0
                    pack.from_tag = true
                    G.FUNCS.use_card({config = {ref_table = pack}})
                    pack:start_materialize()
                end
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- Sale Tag (Tag de Oferta)
SMODS.Tag {
    key = 'oferta',
    atlas = 'witch_brew_tags',
    pos = { x = 2, y = 0 },
    min_ante = 1,
    loc_txt = {
        name = 'Sale Tag',
        text = {
            "All shop items and rerolls",
            "are {C:attention}50% off{} in next shop"
        }
    },
    apply = function(self, tag, context)
        if (context.type == 'shop_final_pass' or context.type == 'shop_start') and not (G.GAME and G.GAME.sale_tag_active) then
            G.GAME.sale_tag_active = true
            tag:yep('+', G.C.MONEY, function()
                local base_reroll = (G.GAME.round_resets and G.GAME.round_resets.reroll_cost) or 5
                if G.GAME.round_resets then
                    G.GAME.round_resets.temp_reroll_cost = math.max(1, math.floor(base_reroll * 0.5))
                end
                if calculate_reroll_cost then
                    calculate_reroll_cost(true)
                end
                if G.shop_jokers and G.shop_jokers.cards then
                    for _, c in ipairs(G.shop_jokers.cards) do c:set_cost() end
                end
                if G.shop_booster and G.shop_booster.cards then
                    for _, c in ipairs(G.shop_booster.cards) do c:set_cost() end
                end
                if G.shop_vouchers and G.shop_vouchers.cards then
                    for _, c in ipairs(G.shop_vouchers.cards) do c:set_cost() end
                end
                return true
            end)
            tag.triggered = true
            return true
        elseif context.type == 'round_eval' or context.type == 'end_of_round' then
            if G.GAME then G.GAME.sale_tag_active = nil end
        end
    end
}

-- 4. Brew Tag
SMODS.Tag {
    key = 'brew',
    atlas = 'witch_brew_tags',
    pos = { x = 3, y = 0 },
    min_ante = 1,
    loc_txt = {
        name = 'Brew Tag',
        text = {
            "Gives {C:attention}2{} random",
            "{C:purple}Potions{}"
        }
    },
    apply = function(self, tag, context)
        if context.type == 'immediate' or context.type == 'tag_add' then
            tag:yep('+', G.C.PURPLE, function()
                for i = 1, 2 do
                    if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                        local card = create_card('Potion', G.consumeables, nil, nil, nil, nil, nil, 'brew_tag')
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                    end
                end
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- 5. Mutagen Tag
SMODS.Tag {
    key = 'mutagen',
    atlas = 'witch_brew_tags',
    pos = { x = 4, y = 0 },
    min_ante = 1,
    loc_txt = {
        name = 'Mutagen Tag',
        text = {
            "Adds a {C:attention}Seal{} or {C:attention}Enhancement{}",
            "to {C:attention}2{} cards in your deck"
        }
    },
    apply = function(self, tag, context)
        if context.type == 'immediate' or context.type == 'tag_add' then
            tag:yep('+', G.C.DARK_EDITION, function()
                if G.deck and G.deck.cards and #G.deck.cards > 0 then
                    local seals = {'Red', 'Blue', 'Gold', 'Purple'}
                    local enhancements = {'m_bonus', 'm_mult', 'm_wild', 'm_glass', 'm_steel', 'm_stone', 'm_gold', 'm_lucky'}
                    local c1 = pseudorandom_element(G.deck.cards, pseudoseed('mutagen_c1'))
                    local c2 = pseudorandom_element(G.deck.cards, pseudoseed('mutagen_c2'))
                    if c1 then
                        c1:set_seal(pseudorandom_element(seals, pseudoseed('mutagen_seal')), true, true)
                        c1:juice_up(0.6, 0.6)
                    end
                    if c2 then
                        local enh = pseudorandom_element(enhancements, pseudoseed('mutagen_enh'))
                        if G.P_CENTERS and G.P_CENTERS[enh] then
                            c2:set_ability(G.P_CENTERS[enh])
                        end
                        c2:juice_up(0.6, 0.6)
                    end
                end
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- 6. Silver Tag
SMODS.Tag {
    key = 'silver',
    atlas = 'witch_brew_tags',
    pos = { x = 5, y = 0 },
    min_ante = 2,
    loc_txt = {
        name = 'Silver Tag',
        text = {
            "{C:attention}Disables{} the Boss Blind",
            "for the {C:attention}current Ante{}"
        }
    },
    apply = function(self, tag, context)
        if context.type == 'immediate' or context.type == 'new_blind_choice' or context.type == 'round_start_bonus' then
            tag:yep('+', G.C.SECONDARY_SET.Spectral, function()
                if G.GAME and G.GAME.round_resets and G.GAME.round_resets.blind_choices and G.GAME.round_resets.blind_choices.Boss then
                    G.GAME.round_resets.blind_choices.Boss_disabled = true
                end
                if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                    G.GAME.blind:disable()
                end
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- 7. Bounty Tag
SMODS.Tag {
    key = 'bounty',
    atlas = 'witch_brew_tags',
    pos = { x = 6, y = 0 },
    min_ante = 1,
    loc_txt = {
        name = 'Bounty Tag',
        text = {
            "Gives {C:money}$10{} if you defeat",
            "the next Blind in {C:attention}1 hand{}"
        }
    },
    apply = function(self, tag, context)
        if context.type == 'eval' then
            if G.GAME and G.GAME.current_round and G.GAME.current_round.hands_played == 1 then
                tag.triggered = true
                return {
                    dollars = 10,
                    condition = '1 Hand',
                    pos = tag.pos,
                    tag = tag
                }
            else
                tag.triggered = true
            end
        end
    end
}

-- 8. Amalgam Tag
SMODS.Tag {
    key = 'amalgam',
    atlas = 'witch_brew_tags',
    pos = { x = 7, y = 0 },
    min_ante = 2,
    loc_txt = {
        name = 'Amalgam Tag',
        text = {
            "Next shop grants {C:attention}#1#{},",
            "{C:attention}#2#{}, and an",
            "{C:purple}Amalgam Potion{}"
        }
    },
    set_ability = function(self, tag)
        local recipes = G.AMALGAM_RECIPES or {
            { pair = { 'blueprint', 'brainstorm' }, key = 'brainprint', name = 'Brainprint' },
            { pair = { 'midas_mask', 'vampire' }, key = 'vampiric_midas', name = 'Vampiric Midas' },
            { pair = { 'hologram', 'certificate' }, key = 'certified_programming', name = 'Certified Programming' },
            { pair = { 'constellation', 'astronomer' }, key = 'galactic_traveler', name = 'Galactic Traveler' },
            { pair = { 'four_fingers', 'shortcut' }, key = 'colorful_street', name = 'Colorful Street' }
        }
        local used_keys = {}
        if G.GAME and G.GAME.tags then
            for _, t in ipairs(G.GAME.tags) do
                if t ~= tag and t.ability and t.ability.amalgam_recipe_key then
                    used_keys[t.ability.amalgam_recipe_key] = true
                end
            end
        end
        local available = {}
        for _, r in ipairs(recipes) do
            if not used_keys[r.key] then
                table.insert(available, r)
            end
        end
        if #available == 0 then available = recipes end

        local seed_str = 'amalgam_tag_' .. tostring(tag.ID or G.tagid or 0) .. '_' .. tostring(G.GAME and G.GAME.tag_tally or 0)
        local chosen = pseudorandom_element(available, pseudoseed(seed_str)) or available[1]
        tag.ability = tag.ability or {}
        tag.ability.amalgam_pair = chosen.pair
        tag.ability.amalgam_recipe_key = chosen.key
        tag.ability.amalgam_name = chosen.name
    end,
    loc_vars = function(self, info_queue, tag)
        if not (tag and tag.ability and tag.ability.amalgam_pair) then
            if tag then self:set_ability(tag) end
        end
        if tag and tag.ability and tag.ability.amalgam_pair then
            local j1 = tag.ability.amalgam_pair[1]
            local j2 = tag.ability.amalgam_pair[2]
            local k1 = string.find(j1, '^j_') and j1 or ('j_' .. j1)
            local k2 = string.find(j2, '^j_') and j2 or ('j_' .. j2)
            local name1 = (G.P_CENTERS and G.P_CENTERS[k1] and localize{type = 'name_text', set = 'Joker', key = k1}) or j1
            local name2 = (G.P_CENTERS and G.P_CENTERS[k2] and localize{type = 'name_text', set = 'Joker', key = k2}) or j2
            if info_queue and G.P_CENTERS then
                if G.P_CENTERS[k1] then table.insert(info_queue, G.P_CENTERS[k1]) end
                if G.P_CENTERS[k2] then table.insert(info_queue, G.P_CENTERS[k2]) end
                local pot_k = (G.P_CENTERS and G.P_CENTERS['c_Witch_brew_potion_amalgam'] and 'c_Witch_brew_potion_amalgam') or (G.P_CENTERS and G.P_CENTERS['c_Witch_brew_potion_amalgama'] and 'c_Witch_brew_potion_amalgama') or 'c_potion_amalgam'
                if G.P_CENTERS[pot_k] then table.insert(info_queue, G.P_CENTERS[pot_k]) end
            end
            return { vars = { name1, name2 } }
        end
        return { vars = { "Combination Joker 1", "Combination Joker 2" } }
    end,
    apply = function(self, tag, context)
        if context.type == 'shop_start' then
            local untriggered_amalgams = 0
            for _, t in ipairs(G.GAME.tags or {}) do
                if (t.key == 'tag_Witch_brew_amalgam' or t.key == 'amalgam') and not t.triggered then
                    untriggered_amalgams = untriggered_amalgams + 1
                end
            end
            local needed = untriggered_amalgams * 2
            if G.GAME and G.GAME.shop and G.GAME.shop.joker_max < needed then
                G.GAME.shop.joker_max = needed
            end
            if G.shop_jokers and G.shop_jokers.config and G.shop_jokers.config.card_limit < needed then
                G.shop_jokers.config.card_limit = needed
                G.shop_jokers.T.w = needed * 1.01 * G.CARD_W
                if G.shop then G.shop:recalculate() end
            end
        elseif context.type == 'store_joker_create' then
            if not (tag.ability and tag.ability.amalgam_pair) then
                self:set_ability(tag)
            end
            tag.ability.amalgam_idx = tag.ability.amalgam_idx or 1

            local jk = tag.ability.amalgam_pair[tag.ability.amalgam_idx or 1]
            local full_k = string.find(jk, '^j_') and jk or ('j_' .. jk)
            local card = create_card('Joker', context.area, nil, nil, nil, nil, full_k, 'amalgam_tag')
            create_shop_card_ui(card, 'Joker', context.area)
            card.ability.couponed = true
            card:set_cost()
            card.states.visible = false

            if tag.ability.amalgam_idx == 1 then
                tag.ability.card1 = card
                tag.ability.amalgam_idx = 2
                return card
            else
                local card1 = tag.ability.card1
                local card2 = card
                tag:yep('+', G.C.PURPLE, function()
                    if card1 then card1:start_materialize() end
                    if card2 then card2:start_materialize() end
                    local pot_key = (G.P_CENTERS and G.P_CENTERS['c_Witch_brew_potion_amalgam'] and 'c_Witch_brew_potion_amalgam') or (G.P_CENTERS and G.P_CENTERS['c_Witch_brew_potion_amalgama'] and 'c_Witch_brew_potion_amalgama') or 'c_potion_amalgam'
                    if G.consumeables then
                        if #G.consumeables.cards >= G.consumeables.config.card_limit then
                            G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
                        end
                        local pot = create_card('Potion', G.consumeables, nil, nil, nil, nil, pot_key, 'amalgam_tag')
                        pot:add_to_deck()
                        G.consumeables:emplace(pot)
                        pot:start_materialize()
                    end
                    return true
                end)
                tag.triggered = true
                return card2
            end
        elseif context.type == 'shop_final_pass' and tag.ability.amalgam_idx == 2 and not tag.triggered then
            local card1 = tag.ability.card1
            tag:yep('+', G.C.PURPLE, function()
                if card1 then card1:start_materialize() end
                local pot_key = (G.P_CENTERS and G.P_CENTERS['c_Witch_brew_potion_amalgam'] and 'c_Witch_brew_potion_amalgam') or (G.P_CENTERS and G.P_CENTERS['c_Witch_brew_potion_amalgama'] and 'c_Witch_brew_potion_amalgama') or 'c_potion_amalgam'
                if G.consumeables then
                    if #G.consumeables.cards >= G.consumeables.config.card_limit then
                        G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
                    end
                    local pot = create_card('Potion', G.consumeables, nil, nil, nil, nil, pot_key, 'amalgam_tag')
                    pot:add_to_deck()
                    G.consumeables:emplace(pot)
                    pot:start_materialize()
                end
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- 9. Dark Alchemy Tag
SMODS.Tag {
    key = 'alquimia_oscura',
    atlas = 'witch_brew_tags',
    pos = { x = 8, y = 0 },
    min_ante = 1,
    loc_txt = {
        name = 'Dark Alchemy Tag',
        text = {
            "Jokers in next shop and booster packs",
            "have {C:attention}10X{} chance to be {C:dark_edition}Negative{}",
            "{C:red}+$2{} scaling reroll cost"
        }
    },
    apply = function(self, tag, context)
        if (context.type == 'shop_final_pass' or context.type == 'shop_start') and not (G.GAME and G.GAME.dark_alchemy_tag_active) then
            G.GAME.dark_alchemy_tag_active = true
            tag:yep('+', G.C.DARK_EDITION, function()
                if G.GAME.round_resets then
                    local base_reroll = G.GAME.round_resets.temp_reroll_cost or G.GAME.round_resets.reroll_cost or 5
                    G.GAME.round_resets.temp_reroll_cost = base_reroll + 2
                end
                if calculate_reroll_cost then
                    calculate_reroll_cost(true)
                end
                return true
            end)
            tag.triggered = true
            return true
        elseif context.type == 'round_eval' or context.type == 'end_of_round' then
            if G.GAME then G.GAME.dark_alchemy_tag_active = nil end
        end
    end
}

-- 10. Contractor Tag
SMODS.Tag {
    key = 'contratista',
    atlas = 'witch_brew_tags',
    pos = { x = 9, y = 0 },
    min_ante = 2,
    in_pool = function(self) return is_witch_brew_spectrals_jobs_enabled() end,
    loc_txt = {
        name = 'Contractor Tag',
        text = {
            "Gives a free",
            "{C:attention}Mega Job Application{}"
        }
    },
    loc_vars = function(self, info_queue)
        local pack_center = G.P_CENTERS['p_Witch_brew_job_pack_4'] or G.P_CENTERS['job_pack_4'] or G.P_CENTERS['p_job_pack_4']
        if pack_center then
            table.insert(info_queue, pack_center)
        end
        return { vars = {} }
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            tag:yep('+', HEX('5c1e11'), function()
                local pack_center = G.P_CENTERS['p_Witch_brew_job_pack_4'] or G.P_CENTERS['job_pack_4'] or G.P_CENTERS['p_job_pack_4'] or G.P_CENTERS['p_Witch_brew_job_pack_3'] or G.P_CENTERS['job_pack_3']
                if pack_center then
                    local pack = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2, G.play.T.y + G.play.T.h/2 - G.CARD_H*1.27/2, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, pack_center, {bypass_discovery_center = true, bypass_discovery_ui = true})
                    pack.cost = 0
                    pack.from_tag = true
                    G.FUNCS.use_card({config = {ref_table = pack}})
                    pack:start_materialize()
                end
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- 11. DNA Tag (Tag ADN)
SMODS.Tag {
    key = 'dna',
    atlas = 'witch_brew_tags',
    pos = { x = 10, y = 0 },
    min_ante = 1,
    loc_txt = {
        name = 'DNA Tag',
        text = {
            "{C:attention}Click this Tag{} to copy",
            "the current Blind's Tag",
            "{C:inactive}(Currently: {C:attention}#1#{C:inactive}){}"
        }
    },
    loc_vars = function(self, info_queue, tag)
        local current_blind = (G.GAME and G.GAME.blind and G.GAME.blind.get_type and G.GAME.blind:get_type()) or (G.GAME and G.GAME.blind_on_deck) or 'Small'
        local b_tag_key = G.GAME and G.GAME.round_resets and G.GAME.round_resets.blind_tags and G.GAME.round_resets.blind_tags[current_blind]
        if not b_tag_key and G.GAME and G.GAME.round_resets and G.GAME.round_resets.blind_tags then
            b_tag_key = G.GAME.round_resets.blind_tags.Big or G.GAME.round_resets.blind_tags.Small
        end
        if info_queue and b_tag_key then
            table.insert(info_queue, { key = b_tag_key, set = 'Tag' })
        end
        local tag_name = (b_tag_key and G.P_TAGS and G.P_TAGS[b_tag_key] and localize{type = 'name_text', set = 'Tag', key = b_tag_key}) or "Blind's Tag"
        return { vars = { tag_name } }
    end,
    apply = function(self, tag, context)
        return false
    end
}

-- 12. Echo Tag
SMODS.Tag {
    key = 'echo',
    atlas = 'witch_brew_tags',
    pos = { x = 11, y = 0 },
    min_ante = 1,
    loc_txt = {
        name = 'Echo Tag',
        text = {
            "The next acquired Tag",
            "is duplicated {C:attention}2{} times"
        }
    },
    apply = function(self, tag, context)
        return false
    end
}

-- 13. Black Market Tag
SMODS.Tag {
    key = 'black_market',
    atlas = 'witch_brew_tags',
    pos = { x = 12, y = 0 },
    min_ante = 1,
    loc_txt = {
        name = 'Black Market Tag',
        text = {
            "Next shop contains {C:attention}2{} free",
            "{C:dark_edition}Negative{} consumables and",
            "rerolls cost {C:money}$0{}"
        }
    },
    apply = function(self, tag, context)
        if (context.type == 'shop_final_pass' or context.type == 'shop_start') and not (G.GAME and G.GAME.black_market_tag_active) then
            G.GAME.black_market_tag_active = true
            tag:yep('+', G.C.DARK_EDITION, function()
                if G.GAME.round_resets then
                    G.GAME.round_resets.temp_reroll_cost = 0
                end
                if calculate_reroll_cost then
                    calculate_reroll_cost(true)
                end
                if G.shop_jokers and G.shop_jokers.cards then
                    for i = 1, 2 do
                        local c = create_card('Consumeables', G.shop_jokers, nil, nil, nil, nil, nil, 'black_market')
                        c:set_edition({ negative = true }, true)
                        c.cost = 0
                        G.shop_jokers:emplace(c)
                    end
                end
                return true
            end)
            tag.triggered = true
            return true
        elseif context.type == 'round_eval' or context.type == 'end_of_round' then
            if G.GAME then G.GAME.black_market_tag_active = nil end
        end
    end
}

-- 14. Prismatic Tag
SMODS.Tag {
    key = 'prismatic',
    atlas = 'witch_brew_tags',
    pos = { x = 13, y = 0 },
    min_ante = 1,
    loc_txt = {
        name = 'Prismatic Tag',
        text = {
            "Next round, the first {C:attention}3{} cards",
            "drawn to hand gain a random {C:dark_edition}Edition{}"
        }
    },
    apply = function(self, tag, context)
        if context.type == 'round_start_bonus' or context.type == 'new_blind_choice' then
            G.GAME.prismatic_tag_count = 3
            tag:yep('+', G.C.DARK_EDITION, function()
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- 15. Adrenaline Tag
SMODS.Tag {
    key = 'adrenaline',
    atlas = 'witch_brew_tags',
    pos = { x = 14, y = 0 },
    min_ante = 1,
    loc_txt = {
        name = 'Adrenaline Tag',
        text = {
            "Next round starts with",
            "{C:blue}+2{} Hands and {C:red}+2{} Discards"
        }
    },
    apply = function(self, tag, context)
        if context.type == 'round_start_bonus' then
            tag:yep('+', G.C.RED, function()
                ease_hands_played(2)
                ease_discard(2)
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- 16. Catalyst Tag
SMODS.Tag {
    key = 'catalyst',
    atlas = 'witch_brew_tags',
    pos = { x = 15, y = 0 },
    min_ante = 1,
    loc_txt = {
        name = 'Catalyst Tag',
        text = {
            "Adds {C:dark_edition}Negative{} to {C:attention}1{} random",
            "held {C:purple}Potion{} and gives {C:money}+$5{}"
        }
    },
    apply = function(self, tag, context)
        if context.type == 'immediate' or context.type == 'tag_add' or context.type == 'new_blind_choice' then
            tag:yep('+', G.C.PURPLE, function()
                ease_dollars(5)
                if G.consumeables and G.consumeables.cards then
                    local potions = {}
                    for _, c in ipairs(G.consumeables.cards) do
                        if c.ability and c.ability.set == 'Potion' and not (c.edition and c.edition.negative) then
                            table.insert(potions, c)
                        end
                    end
                    if #potions > 0 then
                        local chosen = pseudorandom_element(potions, pseudoseed('catalyst_pot'))
                        if chosen then
                            chosen:set_edition({ negative = true }, true)
                            chosen:juice_up(0.5, 0.5)
                        end
                    end
                end
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- Echo Tag and Prismatic Tag Hooks
local orig_add_tag = add_tag
function add_tag(tag)
    orig_add_tag(tag)
    if G.GAME and G.GAME.tags and tag and tag.key ~= 'tag_Witch_brew_echo' and tag.key ~= 'echo' then
        for i = #G.GAME.tags, 1, -1 do
            local t = G.GAME.tags[i]
            if t and (t.key == 'tag_Witch_brew_echo' or t.key == 'echo') and not t.triggered then
                t:yep('+', G.C.CYAN, function()
                    orig_add_tag(Tag(tag.key))
                    orig_add_tag(Tag(tag.key))
                    return true
                end)
                t.triggered = true
                break
            end
        end
    end
end

local orig_draw_card = draw_card
if orig_draw_card then
    function draw_card(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only)
        local ret = orig_draw_card(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only)
        if G.GAME and G.GAME.prismatic_tag_count and G.GAME.prismatic_tag_count > 0 and to == G.hand then
            local drawn = card or (to and to.cards and to.cards[#to.cards])
            if drawn and not drawn.edition then
                local ed = poll_edition('prismatic_tag', nil, true, true)
                if ed then
                    drawn:set_edition(ed, true)
                    drawn:juice_up(0.4, 0.4)
                end
                G.GAME.prismatic_tag_count = G.GAME.prismatic_tag_count - 1
                if G.GAME.prismatic_tag_count <= 0 then
                    G.GAME.prismatic_tag_count = nil
                end
            end
        end
        return ret
    end
end

local orig_tag_generate_ui = Tag.generate_UI
function Tag:generate_UI(_size)
    local tab, sprite = orig_tag_generate_ui(self, _size)
    if self.key and (self.key == 'tag_Witch_brew_dna' or self.key == 'tag_witch_brew_dna' or self.key == 'dna' or self.key == 'tag_dna') then
        if sprite then
            sprite.states.click.can = true
            sprite.click = function(_self)
                if not self.HUD_tag or self.triggered then return end
                if G.CONTROLLER and G.CONTROLLER.dragging and G.CONTROLLER.dragging.target then return end
                self.triggered = true
                _self.states.click.can = false
                _self:juice_up(0.2, 0.2)
                play_sound('tarot1', 1.1, 0.6)

                local current_blind = (G.GAME and G.GAME.blind and G.GAME.blind.get_type and G.GAME.blind:get_type()) or (G.GAME and G.GAME.blind_on_deck) or 'Small'
                local tag_to_spawn = nil
                if G.GAME and G.GAME.round_resets and G.GAME.round_resets.blind_tags and G.GAME.round_resets.blind_tags[current_blind] then
                    tag_to_spawn = G.GAME.round_resets.blind_tags[current_blind]
                elseif G.GAME and G.GAME.round_resets and G.GAME.round_resets.blind_tags and (G.GAME.round_resets.blind_tags.Big or G.GAME.round_resets.blind_tags.Small) then
                    tag_to_spawn = G.GAME.round_resets.blind_tags.Big or G.GAME.round_resets.blind_tags.Small
                end
                if not (tag_to_spawn and G.P_TAGS and G.P_TAGS[tag_to_spawn]) then
                    tag_to_spawn = 'tag_handy'
                end

                self:yep('+', G.C.PURPLE, function()
                    if tag_to_spawn and G.P_TAGS and G.P_TAGS[tag_to_spawn] then
                        add_tag(Tag(tag_to_spawn))
                    end
                    return true
                end)
            end
        end
    end
    return tab, sprite
end
