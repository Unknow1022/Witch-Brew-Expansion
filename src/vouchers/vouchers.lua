-- Vouchers Atlas
SMODS.Atlas {
    key = "witch_brew_vouchers",
    path = "vouchers.png",
    px = 71,
    py = 95
}
-- Vouchers
-- 1. Taster (Catador)
SMODS.Voucher {
    key = 'catador',
    atlas = 'witch_brew_vouchers',
    pos = { x = 0, y = 0 },
    cost = 10,
    loc_txt = {
        name = 'Taster',
        text = {
            "{C:common}Common Jokers{} appear",
            "{C:attention}less frequently{} in shop"
        }
    },
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_Witch_brew_catador = true
        G.GAME.used_vouchers['v_Witch brew_catador'] = true
        G.GAME.used_vouchers.v_catador = true
        G.GAME.used_vouchers.catador = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_Witch_brew_catador = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_catador'] = false
        end
    end
}

-- 2. Critic (Crítico)
SMODS.Voucher {
    key = 'critico',
    atlas = 'witch_brew_vouchers',
    requires = { 'v_Witch_brew_catador' },
    pos = { x = 1, y = 0 },
    cost = 10,
    loc_txt = {
        name = 'Critic',
        text = {
            "{C:common}Common Jokers{} no longer",
            "appear in shop"
        }
    },
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_Witch_brew_critico = true
        G.GAME.used_vouchers['v_Witch brew_critico'] = true
        G.GAME.used_vouchers.v_critico = true
        G.GAME.used_vouchers.critico = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_Witch_brew_critico = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_critico'] = false
        end
    end
}

-- 3. Embrujo (Hex)
SMODS.Voucher {
    key = 'embrujo',
    atlas = 'witch_brew_vouchers',
    pos = { x = 0, y = 1 },
    cost = 10,
    loc_txt = {
        name = 'Embrujo',
        text = {
            "{C:attention}Potions{} appear {C:attention}2X{}",
            "more frequently in shop"
        }
    },
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_Witch_brew_embrujo = true
        G.GAME.used_vouchers['v_Witch brew_embrujo'] = true
        G.GAME.used_vouchers.v_embrujo = true
        G.GAME.used_vouchers.embrujo = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_Witch_brew_embrujo = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_embrujo'] = false
        end
    end
}

-- 4. Caldero (Cauldron)
SMODS.Voucher {
    key = 'caldero',
    atlas = 'witch_brew_vouchers',
    requires = { 'v_Witch_brew_embrujo' },
    pos = { x = 1, y = 1 },
    cost = 10,
    loc_txt = {
        name = 'Caldero',
        text = {
            "{C:attention}Potions{} appear {C:attention}4X{}",
            "more frequently in shop"
        }
    },
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_Witch_brew_caldero = true
        G.GAME.used_vouchers['v_Witch brew_caldero'] = true
        G.GAME.used_vouchers.v_caldero = true
        G.GAME.used_vouchers.caldero = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_Witch_brew_caldero = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_caldero'] = false
        end
    end
}

-- 5. Destilación Recurrente (Recurring Distillation)
SMODS.Voucher {
    key = 'destilacion_recurrente',
    atlas = 'witch_brew_vouchers',
    pos = { x = 0, y = 2 },
    cost = 10,
    loc_txt = {
        name = 'Recurring Distillation',
        text = {
            "{C:attention}15% chance{} for any used",
            "{C:attention}consumable{} to be recreated"
        }
    },
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_Witch_brew_destilacion_recurrente = true
        G.GAME.used_vouchers['v_Witch brew_destilacion_recurrente'] = true
        G.GAME.used_vouchers.v_destilacion_recurrente = true
        G.GAME.used_vouchers.destilacion_recurrente = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_Witch_brew_destilacion_recurrente = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_destilacion_recurrente'] = false
        end
    end
}

-- 6. Destilación Infinita (Infinite Distillation)
SMODS.Voucher {
    key = 'destilacion_infinita',
    atlas = 'witch_brew_vouchers',
    requires = { 'v_Witch_brew_destilacion_recurrente' },
    pos = { x = 1, y = 2 },
    cost = 10,
    loc_txt = {
        name = 'Infinite Distillation',
        text = {
            "{C:attention}45% chance{} for any used",
            "{C:attention}consumable{} to be recreated"
        }
    },
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_Witch_brew_destilacion_infinita = true
        G.GAME.used_vouchers['v_Witch brew_destilacion_infinita'] = true
        G.GAME.used_vouchers.v_destilacion_infinita = true
        G.GAME.used_vouchers.destilacion_infinita = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_Witch_brew_destilacion_infinita = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_destilacion_infinita'] = false
        end
    end
}

-- Hook Card.use_consumeable for Destilacion vouchers
if Card and Card.use_consumeable then
    local orig_use_consumeable_vouchers = Card.use_consumeable
    function Card:use_consumeable(area, copier)
        local voucher_chance = 0
        if G.GAME and G.GAME.used_vouchers then
            if G.GAME.used_vouchers.v_Witch_brew_destilacion_infinita or G.GAME.used_vouchers['v_Witch brew_destilacion_infinita'] or G.GAME.used_vouchers.v_destilacion_infinita or G.GAME.used_vouchers.destilacion_infinita then
                voucher_chance = 45
            elseif G.GAME.used_vouchers.v_Witch_brew_destilacion_recurrente or G.GAME.used_vouchers['v_Witch brew_destilacion_recurrente'] or G.GAME.used_vouchers.v_destilacion_recurrente or G.GAME.used_vouchers.destilacion_recurrente then
                voucher_chance = 15
            end
        end

        local will_recreate = false
        local saved_set = (self.ability and self.ability.set) or 'Tarot'
        local saved_key = (self.config and self.config.center and self.config.center.key) or (self.ability and self.ability.name)

        if voucher_chance > 0 and not copier and saved_key and saved_key ~= '' then
            if pseudorandom('destilacion_voucher') < (voucher_chance / 100) then
                will_recreate = true
            end
        end

        local ret = orig_use_consumeable_vouchers(self, area, copier)

        if will_recreate then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.5,
                func = function()
                    if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                        play_sound('tarot2', 1.4, 0.85)
                        play_sound('gold_seal', 1.3, 0.9)
                        local new_card = create_card(saved_set, G.consumeables, nil, nil, nil, nil, saved_key, 'destilacion')
                        new_card:add_to_deck()
                        G.consumeables:emplace(new_card)
                        new_card:juice_up(0.6, 0.6)
                        card_eval_status_text(new_card, 'extra', nil, nil, nil, {
                            message = 'Destilado!',
                            colour = G.C.SECONDARY_SET.Tarot
                        })
                    end
                    return true
                end
            }))
        end

        return ret
    end
end

-- 7. Ambrosia (Pantheon Voucher T1)
SMODS.Voucher {
    key = 'ambrosia',
    atlas = 'witch_brew_vouchers',
    pos = { x = 0, y = 3 },
    cost = 10,
    config = { extra = 1 },
    loc_txt = {
        name = 'Ambrosia',
        text = {
            "{C:attention}+#1#{} Consumable slot"
        }
    },
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or (self.config and self.config.extra) or 1
        return { vars = { extra } }
    end,
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_Witch_brew_ambrosia = true
        G.GAME.used_vouchers['v_Witch brew_ambrosia'] = true
        G.GAME.used_vouchers.v_ambrosia = true
        G.GAME.used_vouchers.ambrosia = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_Witch_brew_ambrosia = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_ambrosia'] = false
        end
        if G.consumeables then
            local extra = (card and card.ability and card.ability.extra) or (self.config and self.config.extra) or 1
            G.consumeables.config.card_limit = G.consumeables.config.card_limit + extra
        end
    end
}

-- 8. Nectar (Pantheon Voucher T2)
SMODS.Voucher {
    key = 'nectar',
    atlas = 'witch_brew_vouchers',
    requires = { 'v_Witch_brew_ambrosia' },
    pos = { x = 1, y = 3 },
    cost = 10,
    config = { extra = 30 },
    loc_txt = {
        name = 'Nectar',
        text = {
            "Rerolling the shop reduces",
            "{C:attention}Boss Blind{} requirement",
            "by {C:attention}#1#%{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or (self.config and self.config.extra) or 30
        return { vars = { extra } }
    end,
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_Witch_brew_nectar = true
        G.GAME.used_vouchers['v_Witch brew_nectar'] = true
        G.GAME.used_vouchers.v_nectar = true
        G.GAME.used_vouchers.nectar = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_Witch_brew_nectar = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_nectar'] = false
        end
    end
}

-- Hook shop rerolls for Nectar Voucher
if G.FUNCS and G.FUNCS.reroll_shop then
    local orig_reroll_shop_nectar = G.FUNCS.reroll_shop
    G.FUNCS.reroll_shop = function(e)
        orig_reroll_shop_nectar(e)
        if G.GAME and G.GAME.used_vouchers and (G.GAME.used_vouchers.v_Witch_brew_nectar or G.GAME.used_vouchers.v_nectar or G.GAME.used_vouchers.nectar) then
            if G.GAME.blind and G.GAME.blind.boss and G.GAME.blind.chips then
                G.GAME.blind.chips = math.max(1, math.floor(G.GAME.blind.chips * 0.70))
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            end
        end
    end
end




