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

-- Spanish localization override for vouchers
local orig_init_loc_vouchers = init_localization
function init_localization()
    if orig_init_loc_vouchers then orig_init_loc_vouchers() end
    if G.localization and G.localization.descriptions and G.localization.descriptions.Voucher then
        local is_es = (G.SETTINGS and (G.SETTINGS.language == 'es' or G.SETTINGS.language == 'es_419' or G.SETTINGS.language == 'es_ES')) or (G.Witch_brew_SPANISH == true)
        if is_es then
            local v_embrujo = G.localization.descriptions.Voucher.v_Witch_brew_embrujo or G.localization.descriptions.Voucher.v_embrujo
            if v_embrujo then
                v_embrujo.name = "Embrujo"
                v_embrujo.text = {
                    "Las {C:attention}Pociones{} aparecen el",
                    "{C:attention}doble de frecuente{} en la tienda"
                }
                if reparse_localization_entry then reparse_localization_entry(v_embrujo) end
            end
            local v_caldero = G.localization.descriptions.Voucher.v_Witch_brew_caldero or G.localization.descriptions.Voucher.v_caldero
            if v_caldero then
                v_caldero.name = "Caldero"
                v_caldero.text = {
                    "Las {C:attention}Pociones{} aparecen",
                    "{C:attention}4X más frecuente{} en la tienda"
                }
                if reparse_localization_entry then reparse_localization_entry(v_caldero) end
            end
            local v_rec = G.localization.descriptions.Voucher.v_Witch_brew_destilacion_recurrente or G.localization.descriptions.Voucher.v_destilacion_recurrente
            if v_rec then
                v_rec.name = "Destilación Recurrente"
                v_rec.text = {
                    "{C:attention}15% de probabilidad{} de que cualquier",
                    "{C:attention}consumible{} usado se vuelva a generar"
                }
                if reparse_localization_entry then reparse_localization_entry(v_rec) end
            end
            local v_inf = G.localization.descriptions.Voucher.v_Witch_brew_destilacion_infinita or G.localization.descriptions.Voucher.v_destilacion_infinita
            if v_inf then
                v_inf.name = "Destilación Infinita"
                v_inf.text = {
                    "{C:attention}45% de probabilidad{} de que cualquier",
                    "{C:attention}consumible{} usado se vuelva a generar"
                }
                if reparse_localization_entry then reparse_localization_entry(v_inf) end
            end
        end
    end
end

