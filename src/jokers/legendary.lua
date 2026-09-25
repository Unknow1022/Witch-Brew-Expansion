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

local function get_next_paradox_joker()
    local pool = {}
    if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker then
        for _, j in ipairs(G.P_CENTER_POOLS.Joker) do
            if j.key and j.key ~= 'j_Witch_brew_living_paradox' then
                table.insert(pool, j.key)
            end
        end
    end
    if #pool > 0 then
        return pseudorandom_element(pool, pseudoseed('paradox_joker_next'))
    end
    return nil
end

-- Living Paradox, Legendary Joker
SMODS.Joker {
    key = 'living_paradox',
    atlas = 'witch_brew_legendary',
    unlocked = false,
    unlock = { "Defeat a {C:attention}Boss Blind{}", "to discover this Joker" },
    loc_txt = {
        name = 'Living Paradox',
        text = {
            "Creates a {C:dark_edition}Negative{} {C:attention}#1#{}",
            "when {C:attention}Boss Blind{} is defeated",
            "{C:inactive}(Changes after each Boss Blind){}"
        }
    },
    config = { extra = { next_joker = nil } },
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
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        if not ex.next_joker then
            ex.next_joker = get_next_paradox_joker()
        end
        local next_name = "Random"
        if ex.next_joker and G.P_CENTERS and G.P_CENTERS[ex.next_joker] then
            local center = G.P_CENTERS[ex.next_joker]
            next_name = (localize and localize{type = 'name_text', key = center.key, set = 'Joker'}) or center.name or ex.next_joker
        end
        return { vars = { next_name } }
    end,
    calculate = function(self, card, context)
        if not card.ability.extra.next_joker then
            card.ability.extra.next_joker = get_next_paradox_joker()
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                G.GAME.witch_brew_boss_defeated = true
                local chosen_key = card.ability.extra.next_joker or get_next_paradox_joker()
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local new_j = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_key, 'living_paradox')
                        new_j:set_edition({ negative = true }, true)
                        new_j:add_to_deck()
                        G.jokers:emplace(new_j)
                        card:juice_up(0.5, 0.5)
                        return true
                    end
                }))
                card.ability.extra.next_joker = get_next_paradox_joker()
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
            "{C:blue}Planet{} card discovered.",
            "{C:spectral}Black Holes{} double its current Mult",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = {
        xmult_per_planet = 0.5,
        black_hole_mult = 1
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
        local base_xm = 1 + planet_count * (ex.xmult_per_planet or 0.5)
        local total_xm = base_xm * (ex.black_hole_mult or 1)
        return { vars = { ex.xmult_per_planet or 0.5, string.format('%.1f', total_xm) } }
    end,
    check_for_unlock = function(self, args)
        if G.GAME and G.GAME.witch_brew_run_won then
            return true
        end
    end,
    calculate = function(self, card, context)
        -- Double current mult when a Black Hole is used
        if context.using_consumeable and not context.blueprint then
            local c = context.consumeable
            if c and (c.key == 'c_black_hole' or (c.ability and c.ability.name == 'Black Hole')) then
                card.ability.extra.black_hole_mult = (card.ability.extra.black_hole_mult or 1) * 2
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'X2 Mult!', colour = G.C.MULT })
            end
        end

        if context.joker_main then
            local ex = card.ability.extra
            local planet_count = 0
            if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Planet then
                for _, p in ipairs(G.P_CENTER_POOLS.Planet) do
                    if p.discovered then
                        planet_count = planet_count + 1
                    end
                end
            end
            local base_xm = 1 + planet_count * (ex.xmult_per_planet or 0.5)
            local total_xm = base_xm * (ex.black_hole_mult or 1)
            if total_xm > 1 then
                return {
                    Xmult = total_xm,
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
