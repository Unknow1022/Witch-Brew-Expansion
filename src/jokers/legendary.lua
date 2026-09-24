-- Legendary Jokers, Mod definitions

SMODS.Atlas {
    key = "witch_brew_legendary",
    path = "legendary_jokers.png",
    px = 71,
    py = 95
}

-- World Devourer, Legendary Joker
SMODS.Joker {
    key = 'world_devourer',
    atlas = 'witch_brew_legendary',
    unlocked = false,
    unlock = { "Defeat {C:attention}10 Boss Blinds{}", "in a single run" },
    loc_txt = {
        name = 'World Devourer',
        text = {
            "Gains {X:mult,C:white}X1{} Mult",
            "for each {C:attention}blind{} defeated",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult){}"
        }
    },
    config = { extra = {
        xmult_per_blind = 1,
        blinds_defeated = 0,
        xmult = 1
    }},
    rarity = 4,
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    no_particles = true,
    cost = 20,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        return { vars = { ex.xmult or 1 } }
    end,
    check_for_unlock = function(self, args)
        local ex = args and args.card and args.card.ability and args.card.ability.extra
        return ex and (ex.blinds_defeated or 0) >= 10
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local ex = card.ability.extra
            if (ex.xmult or 1) > 1 then
                return {
                    Xmult = ex.xmult,
                    card = card
                }
            end
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local ex = card.ability.extra
            ex.blinds_defeated = (ex.blinds_defeated or 0) + 1
            ex.xmult = 1 + ex.blinds_defeated * (ex.xmult_per_blind or 1)
            return {
                message = 'X'..string.format('%.0f', ex.xmult)..'!',
                colour = G.C.MULT,
                card = card
            }
        end
    end
}

-- Living Paradox, Legendary Joker
SMODS.Joker {
    key = 'living_paradox',
    atlas = 'witch_brew_legendary',
    unlocked = false,
    unlock = { "Defeat a {C:attention}Boss Blind{}", "to discover this Joker" },
    loc_txt = {
        name = 'Living Paradox',
        text = {
            "Creates a {C:dark_edition}Negative{} random",
            "{C:attention}Joker{} when {C:attention}Boss Blind{}",
            "is defeated {C:inactive}(includes Legendaries){}"
        }
    },
    config = { extra = {} },
    rarity = 4,
    pos = { x = 0, y = 1 },
    soul_pos = { x = 1, y = 1 },
    no_particles = true,
    cost = 20,
    blueprint_compat = false,
    check_for_unlock = function(self, args)
        if G.GAME and G.GAME.witch_brew_boss_defeated then
            return true
        end
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                G.GAME.witch_brew_boss_defeated = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Build pool: all jokers including legendaries
                        local pool = {}
                        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker then
                            for _, j in ipairs(G.P_CENTER_POOLS.Joker) do
                                if j.key then table.insert(pool, j.key) end
                            end
                        end
                        local chosen_key = #pool > 0 and pseudorandom_element(pool, pseudoseed('paradox_joker')) or nil
                        local new_j = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_key, 'living_paradox')
                        new_j:set_edition({ negative = true }, true)
                        new_j:add_to_deck()
                        G.jokers:emplace(new_j)
                        card:juice_up(0.5, 0.5)
                        return true
                    end
                }))
                return {
                    message = 'Paradox!',
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
}

-- Star Chronicler, Legendary Joker
SMODS.Joker {
    key = 'star_chronicler',
    atlas = 'witch_brew_legendary',
    unlocked = false,
    unlock = { "Win a complete run", "{C:attention}(Defeat Ante 8+){}" },
    loc_txt = {
        name = 'Star Chronicler',
        text = {
            "Gains {X:mult,C:white}X#1#{} Mult for each",
            "{C:blue}Planet{} card discovered",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = {
        xmult_per_planet = 0.5,
        xmult = 1
    }},
    rarity = 4,
    pos = { x = 0, y = 2 },
    soul_pos = { x = 1, y = 2 },
    no_particles = true,
    cost = 20,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        -- Count discovered planets in collection
        local planet_count = 0
        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Planet then
            for _, p in ipairs(G.P_CENTER_POOLS.Planet) do
                if p.discovered then
                    planet_count = planet_count + 1
                end
            end
        end
        local xm = 1 + planet_count * (ex.xmult_per_planet or 0.5)
        return { vars = { ex.xmult_per_planet or 0.5, string.format('%.1f', xm) } }
    end,
    check_for_unlock = function(self, args)
        if G.GAME and G.GAME.witch_brew_run_won then
            return true
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local ex = card.ability.extra
            -- Count discovered planets dynamically
            local planet_count = 0
            if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Planet then
                for _, p in ipairs(G.P_CENTER_POOLS.Planet) do
                    if p.discovered then
                        planet_count = planet_count + 1
                    end
                end
            end
            local xm = 1 + planet_count * (ex.xmult_per_planet or 0.5)
            if xm > 1 then
                return {
                    Xmult = xm,
                    card = card
                }
            end
        end
    end
}

-- Win tracking hook for unlocks
local _old_win = Game.win_run
if _old_win then
    Game.win_run = function(self, ...)
        if G.GAME then G.GAME.witch_brew_run_won = true end
        return _old_win(self, ...)
    end
end
