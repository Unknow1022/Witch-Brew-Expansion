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
            "{C:spectral}La Muchachada{}",
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
                        local tag_muchachada_key = (G.P_CENTERS and G.P_CENTERS['c_Witch_brew_la_muchachada'] and 'c_Witch_brew_la_muchachada') or 'c_la_muchachada'
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
            "Creates {C:attention}2{} {C:purple}Witcher Brew{}",
            "consumables",
            "{C:inactive}(Must have room){}"
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
            "Next shop grants {C:attention}2 combination Jokers{}",
            "and an {C:purple}Amalgam Potion{}",
            "{C:red}Lose all current money{}"
        }
    },
    apply = function(self, tag, context)
        if context.type == 'store_joker_create' then
            if not tag.ability.amalgam_pair then
                local recipes = G.AMALGAM_RECIPES or {
                    { pair = { 'blueprint', 'brainstorm' } },
                    { pair = { 'midas_mask', 'vampire' } },
                    { pair = { 'hologram', 'certificate' } },
                    { pair = { 'constellation', 'astronomer' } },
                    { pair = { 'four_fingers', 'shortcut' } }
                }
                local recipe = pseudorandom_element(recipes, pseudoseed('amalgam_tag'))
                tag.ability.amalgam_pair = (recipe and recipe.pair) or { 'blueprint', 'brainstorm' }
                tag.ability.amalgam_idx = 1
                if G.GAME and G.GAME.dollars and G.GAME.dollars > 0 then
                    ease_dollars(-G.GAME.dollars, true)
                end
            end

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
                    local pot_key = (G.P_CENTERS and G.P_CENTERS['c_Witch_brew_potion_amalgama'] and 'c_Witch_brew_potion_amalgama') or 'c_potion_amalgama'
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
                local pot_key = (G.P_CENTERS and G.P_CENTERS['c_Witch_brew_potion_amalgama'] and 'c_Witch_brew_potion_amalgama') or 'c_potion_amalgama'
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
            "{C:red}+$1{} to reroll cost"
        }
    },
    apply = function(self, tag, context)
        if (context.type == 'shop_final_pass' or context.type == 'shop_start') and not (G.GAME and G.GAME.dark_alchemy_tag_active) then
            G.GAME.dark_alchemy_tag_active = true
            tag:yep('+', G.C.DARK_EDITION, function()
                if G.GAME.round_resets then
                    local base_reroll = G.GAME.round_resets.temp_reroll_cost or G.GAME.round_resets.reroll_cost or 5
                    G.GAME.round_resets.temp_reroll_cost = base_reroll + 1
                end
                if calculate_reroll_cost then
                    calculate_reroll_cost(true)
                end
                return true
            end)
            tag.triggered = true
            return true
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



