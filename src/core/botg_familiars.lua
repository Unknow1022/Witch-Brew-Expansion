-- Mini-Boss Familiars System (Idea 19) for Battle of Gods Mode
SMODS.Atlas {
    key = "witch_brew_familiars",
    path = "familiars.png",
    px = 34,
    py = 34
}

-- Register Consumable Type for Familiars
SMODS.ConsumableType {
    key = 'Familiar',
    primary_colour = HEX('8B0000'),
    secondary_colour = HEX('4A0000'),
    loc_txt = {
        name = 'Familiar',
        collection = 'Familiars',
        underscores_single = 'Familiar',
        underscores_plural = 'Familiars'
    },
    shop_rate = 0.0,
    collection_rows = { 1, 6 },
    default = 'c_Witch_brew_baby_needle',
    unlocked = true,
    discovered = true
}

if G.FUNCS then
    G.FUNCS.botg_empty_familiar_label = function(e)
        e.config.visible = (not G.botg_familiars) or (#G.botg_familiars.cards == 0)
    end
end

-- Initialize Familiar CardArea directly above G.deck
function init_botg_familiars_area()
    if not G.botg_familiars or G.botg_familiars.REMOVED then
        local w = 1.35
        local h = 1.35
        local x = (G.deck and (G.deck.T.x + (G.deck.T.w - w) * 0.5)) or 10
        local y = (G.deck and (G.deck.T.y - h - 0.2)) or 7
        G.botg_familiars = CardArea(
            x, y,
            w, h,
            { card_limit = 1, type = 'title', highlight_limit = 1, card_w = 1.15 }
        )

        G.botg_familiars.align_cards = function(self)
            for k, card in ipairs(self.cards) do
                if not card.states.drag.is and not card.disable_align then
                    card.T.r = (G.SETTINGS.reduced_motion and 0 or 1) * 0.04 * math.sin(1.8 * G.TIMERS.REAL + card.T.x)
                    card.T.x = self.T.x + (self.T.w - card.T.w) * 0.5
                    local highlight_height = card.highlighted and G.HIGHLIGHT_H or 0
                    card.T.y = self.T.y + (self.T.h - card.T.h) * 0.5 - highlight_height
                    card.T.x = card.T.x + card.shadow_parrallax.x / 30
                end
                card.rank = k
            end
        end

        G.botg_familiars.draw = function(self)
            if not self.states.visible then return end
            if G.VIEWING_DECK then return end
            if G.STAGE ~= G.STAGES.RUN then return end

            if not self.children.slot_uibox then
                self.children.slot_uibox = UIBox{
                    definition = {
                        n = G.UIT.ROOT,
                        config = { align = 'cm', colour = G.C.CLEAR },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = {
                                    minw = self.T.w,
                                    minh = self.T.h,
                                    align = "cm",
                                    r = 0.12,
                                    colour = { 0.05, 0.03, 0.08, 0.4 },
                                    outline = 1.2,
                                    outline_colour = { 0.55, 0.25, 0.7, 0.7 }
                                },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = { align = "cm", func = 'botg_empty_familiar_label' },
                                        nodes = {
                                            {
                                                n = G.UIT.T,
                                                config = {
                                                    text = "FAMILIAR",
                                                    scale = 0.22,
                                                    colour = { 0.8, 0.7, 0.9, 0.4 },
                                                    shadow = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    },
                    config = { align = 'cm', offset = { x = 0, y = 0 }, major = self, parent = self }
                }
            end
            self.children.slot_uibox:draw()

            self:draw_boundingrect()
            add_to_drawhash(self)

            local draw_layers = self.ARGS.draw_layers or self.config.draw_layers or {'shadow', 'card'}
            for _, layer in ipairs(draw_layers) do
                for i = 1, #self.cards do
                    local c = self.cards[i]
                    if c ~= G.CONTROLLER.focused.target then
                        if G.CONTROLLER.dragging.target ~= c then
                            c:draw(layer)
                        end
                    end
                end
            end
        end
    end

    -- Restore saved familiar if run is active and area is empty
    if G.GAME and G.GAME.battle_of_gods and G.GAME.botg_current_familiar and #G.botg_familiars.cards == 0 then
        local card = create_card('Familiar', G.botg_familiars, nil, nil, nil, nil, G.GAME.botg_current_familiar)
        card.params.bypass_discovery_center = true
        card.discovered = true
        card.unlocked = true
        local size = 1.15
        card.T.w = size
        card.T.h = size
        card.VT.w = size
        card.VT.h = size
        if card.children.center then
            card.children.center.T.w = size
            card.children.center.T.h = size
            card.children.center.VT.w = size
            card.children.center.VT.h = size
            card.children.center.scale = { x = 34, y = 34 }
        end
        if card.children.back then
            card.children.back.states.visible = false
        end
        card.states.drag.can = false
        card:hard_set_T(G.botg_familiars.T.x + (G.botg_familiars.T.w - size) * 0.5, G.botg_familiars.T.y + (G.botg_familiars.T.h - size) * 0.5, size, size)
        G.botg_familiars:emplace(card)
        G.botg_familiars:align_cards()
    end
end

-- Hook set_screen_positions to align G.botg_familiars right above G.deck
if set_screen_positions then
    local orig_set_screen_positions = set_screen_positions
    function set_screen_positions()
        orig_set_screen_positions()
        if G.botg_familiars and G.deck and G.STAGE == G.STAGES.RUN then
            G.botg_familiars.T.x = G.deck.T.x + (G.deck.T.w - G.botg_familiars.T.w) * 0.5
            G.botg_familiars.T.y = G.deck.T.y - G.botg_familiars.T.h - 0.2
            G.botg_familiars:hard_set_VT()
            if G.botg_familiars.children and G.botg_familiars.children.slot_uibox then
                G.botg_familiars.children.slot_uibox:set_role({ major = G.botg_familiars, parent = G.botg_familiars })
            end
            G.botg_familiars:align_cards()
            for _, card in ipairs(G.botg_familiars.cards) do
                card:hard_set_T(card.T.x, card.T.y, card.T.w, card.T.h)
            end
        end
    end
end

-- Familiar 1: Baby Needle
SMODS.Consumable {
    key = 'baby_needle',
    set = 'Familiar',
    atlas = 'witch_brew_familiars',
    pos = { x = 0, y = 0 },
    cost = 10,
    unlocked = true,
    discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Needle',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "{C:chips}+100{} Chips and {C:mult}+15{} Mult",
            "if winning round in {C:attention}1 hand{}"
        }
    },
    in_pool = function(self) return false end
}

-- Familiar 2: Baby Pillar
SMODS.Consumable {
    key = 'baby_pillar',
    set = 'Familiar',
    atlas = 'witch_brew_familiars',
    pos = { x = 1, y = 0 },
    cost = 10,
    unlocked = true,
    discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Pillar',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Protects all cards in {C:attention}hand{}",
            "from all {C:attention}Boss debuffs{}"
        }
    },
    in_pool = function(self) return false end
}

-- Familiar 3: Baby Serpent
SMODS.Consumable {
    key = 'baby_serpent',
    set = 'Familiar',
    atlas = 'witch_brew_familiars',
    pos = { x = 2, y = 0 },
    cost = 10,
    unlocked = true,
    discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Serpent',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "After every {C:red}Discard{}, draws",
            "{C:attention}+1{} extra card from deck"
        }
    },
    in_pool = function(self) return false end
}

-- Familiar 4: Baby Flint
SMODS.Consumable {
    key = 'baby_flint',
    set = 'Familiar',
    atlas = 'witch_brew_familiars',
    pos = { x = 3, y = 0 },
    cost = 10,
    unlocked = true,
    discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Flint',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Scored cards permanently gain",
            "{C:chips}+5{} Chips and {C:mult}+2{} Mult"
        }
    },
    in_pool = function(self) return false end
}

-- Familiar 5: Baby Hook
SMODS.Consumable {
    key = 'baby_hook',
    set = 'Familiar',
    atlas = 'witch_brew_familiars',
    pos = { x = 4, y = 0 },
    cost = 10,
    unlocked = true,
    discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Hook',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "{C:red}Discards{} never drop below {C:attention}1{};",
            "grants {C:green}1 free{} Shop reroll"
        }
    },
    in_pool = function(self) return false end
}

-- Familiar 6: Baby Eye
SMODS.Consumable {
    key = 'baby_eye',
    set = 'Familiar',
    atlas = 'witch_brew_familiars',
    pos = { x = 5, y = 0 },
    cost = 10,
    unlocked = true,
    discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Eye',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Playing {C:attention}repeat{} poker hands",
            "triggers {X:mult,C:white}X1.5{} Mult"
        }
    },
    in_pool = function(self) return false end
}

local FAMILIAR_KEYS = {
    'c_Witch_brew_baby_needle',
    'c_Witch_brew_baby_pillar',
    'c_Witch_brew_baby_serpent',
    'c_Witch_brew_baby_flint',
    'c_Witch_brew_baby_hook',
    'c_Witch_brew_baby_eye'
}

-- Function to handle offering or replacing a familiar
function botg_offer_familiar(fam_key)
    fam_key = fam_key or pseudorandom_element(FAMILIAR_KEYS, pseudoseed('botg_fam'))
    init_botg_familiars_area()

    if not G.botg_familiars then return end

    if #G.botg_familiars.cards == 0 then
        if G.GAME then G.GAME.botg_current_familiar = fam_key end
        local card = create_card('Familiar', G.botg_familiars, nil, nil, nil, nil, fam_key)
        card.params.bypass_discovery_center = true
        card.discovered = true
        card.unlocked = true
        local size = 1.15
        card.T.w = size
        card.T.h = size
        card.VT.w = size
        card.VT.h = size
        if card.children.center then
            card.children.center.T.w = size
            card.children.center.T.h = size
            card.children.center.VT.w = size
            card.children.center.VT.h = size
            card.children.center.scale = { x = 34, y = 34 }
        end
        if card.children.back then
            card.children.back.states.visible = false
        end
        card.states.drag.can = false
        card:hard_set_T(G.botg_familiars.T.x + (G.botg_familiars.T.w - size) * 0.5, G.botg_familiars.T.y + (G.botg_familiars.T.h - size) * 0.5, size, size)
        G.botg_familiars:emplace(card)
        G.botg_familiars:align_cards()
        card:juice_up(0.5, 0.5)
        attention_text({
            text = 'Adopted Mini-Boss: ' .. (localize{type = 'name_text', key = fam_key, set = 'Familiar'} or 'Mini-Boss'),
            scale = 0.65,
            hold = 1.8,
            backdrop_colour = G.C.PURPLE,
            align = 'cm',
            offset = { x = 0, y = -1 }
        })
        play_sound('tarot1', 1.1, 0.8)
    else
        -- Familiar replacement prompt
        local current_fam = G.botg_familiars.cards[1]
        local new_name = localize{type = 'name_text', key = fam_key, set = 'Familiar'} or 'New Familiar'
        local old_name = (current_fam and localize{type = 'name_text', key = current_fam.config.center.key, set = 'Familiar'}) or 'Current'

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.5,
            func = function()
                G.botg_pending_familiar = fam_key
                G.FUNCS.overlay_menu{
                    definition = {
                        n = G.UIT.ROOT,
                        config = { align = "cm", colour = G.C.CLEAR },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cm", padding = 0.2, r = 0.15, colour = G.C.DARK_EDITION, outline = 2, outline_colour = G.C.GOLD },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = { align = "cm", padding = 0.1 },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = "New Mini-Boss Discovered!", scale = 0.6, colour = G.C.GOLD, shadow = true } }
                                        }
                                    },
                                    {
                                        n = G.UIT.R,
                                        config = { align = "cm", padding = 0.1 },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = "Replace " .. old_name .. " with " .. new_name .. "?", scale = 0.45, colour = G.C.WHITE } }
                                        }
                                    },
                                    {
                                        n = G.UIT.R,
                                        config = { align = "cm", padding = 0.15 },
                                        nodes = {
                                            {
                                                n = G.UIT.C,
                                                config = {
                                                    align = "cm",
                                                    padding = 0.1,
                                                    r = 0.1,
                                                    colour = G.C.PURPLE,
                                                    button = "botg_replace_familiar",
                                                    hover = true,
                                                    shadow = true,
                                                    minw = 2.2
                                                },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = "Replace", scale = 0.45, colour = G.C.WHITE, shadow = true } }
                                                }
                                            },
                                            { n = G.UIT.B, config = { w = 0.3, h = 0.1 } },
                                            {
                                                n = G.UIT.C,
                                                config = {
                                                    align = "cm",
                                                    padding = 0.1,
                                                    r = 0.1,
                                                    colour = G.C.GREY,
                                                    button = "botg_keep_familiar",
                                                    hover = true,
                                                    shadow = true,
                                                    minw = 2.2
                                                },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = "Keep Current", scale = 0.45, colour = G.C.WHITE, shadow = true } }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                return true
            end
        }))
    end
end

if G.FUNCS then
    G.FUNCS.botg_replace_familiar = function(e)
        if G.botg_pending_familiar and G.botg_familiars then
            if G.botg_familiars.cards[1] then
                G.botg_familiars.cards[1]:remove()
            end
            if G.GAME then G.GAME.botg_current_familiar = G.botg_pending_familiar end
            local card = create_card('Familiar', G.botg_familiars, nil, nil, nil, nil, G.botg_pending_familiar)
            card.params.bypass_discovery_center = true
            card.discovered = true
            card.unlocked = true
            local size = 1.15
            card.T.w = size
            card.T.h = size
            card.VT.w = size
            card.VT.h = size
            if card.children.center then
                card.children.center.T.w = size
                card.children.center.T.h = size
                card.children.center.VT.w = size
                card.children.center.VT.h = size
                card.children.center.scale = { x = 34, y = 34 }
            end
            if card.children.back then
                card.children.back.states.visible = false
            end
            card.states.drag.can = false
            card:hard_set_T(G.botg_familiars.T.x + (G.botg_familiars.T.w - size) * 0.5, G.botg_familiars.T.y + (G.botg_familiars.T.h - size) * 0.5, size, size)
            G.botg_familiars:emplace(card)
            G.botg_familiars:align_cards()
            card:juice_up(0.5, 0.5)
            play_sound('tarot1', 1.2, 0.8)
        end
        G.botg_pending_familiar = nil
        G.FUNCS.exit_overlay_menu()
    end

    G.FUNCS.botg_keep_familiar = function(e)
        G.botg_pending_familiar = nil
        G.FUNCS.exit_overlay_menu()
    end
end

-- Passive familiar hooks
if Card and Card.calculate_joker then
    local orig_calculate_joker = Card.calculate_joker
    function Card:calculate_joker(context)
        local ret = orig_calculate_joker(self, context)

        if G.GAME and G.GAME.battle_of_gods and G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1] then
            if botg_trigger_mod_achievement then
                botg_trigger_mod_achievement('divine_familiar')
            end
            local fam = G.botg_familiars.cards[1]
            local f_key = fam.config and fam.config.center and fam.config.center.key

            -- Baby Needle
            if f_key == 'c_Witch_brew_baby_needle' and context.joker_main and G.GAME.current_round.hands_played == 0 then
                if ret then
                    ret.chips = (ret.chips or 0) + 100
                    ret.mult = (ret.mult or 0) + 15
                else
                    ret = { chips = 100, mult = 15, message = '+100 Chips / +15 Mult [Baby Needle]', colour = G.C.GOLD }
                end
            end

            -- Baby Eye
            if f_key == 'c_Witch_brew_baby_eye' and context.joker_main and context.scoring_name then
                if G.GAME.hands[context.scoring_name] and G.GAME.hands[context.scoring_name].played > 1 then
                    if ret then
                        ret.x_mult = (ret.x_mult or 1) * 1.5
                    else
                        ret = { x_mult = 1.5, message = 'X1.5 Mult [Baby Eye]', colour = G.C.BLUE }
                    end
                end
            end

            -- Baby Flint
            if f_key == 'c_Witch_brew_baby_flint' and context.individual and context.cardarea == G.play and context.other_card then
                context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + 5
                context.other_card.ability.perma_mult = (context.other_card.ability.perma_mult or 0) + 2
                fam:juice_up(0.2, 0.2)
            end
        end

        return ret
    end
end

-- Baby Pillar: Protect cards from debuffs
if Blind and Blind.debuff_card then
    local orig_debuff_card = Blind.debuff_card
    function Blind:debuff_card(card, from_blind)
        if G.GAME and G.GAME.battle_of_gods and G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1] then
            if G.botg_familiars.cards[1].config.center.key == 'c_Witch_brew_baby_pillar' then
                card:set_debuff(false)
                return
            end
        end
        return orig_debuff_card(self, card, from_blind)
    end
end

-- Baby Serpent: Extra draw after discard
if G.FUNCS and G.FUNCS.discard_cards_from_highlighted then
    local orig_discard = G.FUNCS.discard_cards_from_highlighted
    G.FUNCS.discard_cards_from_highlighted = function(e, hook)
        orig_discard(e, hook)
        if G.GAME and G.GAME.battle_of_gods and G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1] then
            if G.botg_familiars.cards[1].config.center.key == 'c_Witch_brew_baby_serpent' then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        if G.FUNCS.draw_from_deck_to_hand then
                            G.FUNCS.draw_from_deck_to_hand(1)
                        end
                        G.botg_familiars.cards[1]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
        end
    end
end

-- Baby Hook: Discards never drop below 1
if ease_discard then
    local orig_ease_discard = ease_discard
    function ease_discard(mod, instant, reset)
        orig_ease_discard(mod, instant, reset)
        if G.GAME and G.GAME.battle_of_gods and G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1] then
            if G.botg_familiars.cards[1].config.center.key == 'c_Witch_brew_baby_hook' then
                if G.GAME.current_round.discards_left < 1 then
                    G.GAME.current_round.discards_left = 1
                end
            end
        end
    end
end
