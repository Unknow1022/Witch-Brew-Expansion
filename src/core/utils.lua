-- Core Utilities & Engine Hooks for Witch_Brew

if not to_number then
    function to_number(x)
        if type(x) == 'table' then
            if x.to_number then return x:to_number() end
            return tonumber(x[1]) or 0
        end
        return tonumber(x) or 0
    end
end


-- Parche defensivo para el bug de Malverk al borrar datos de perfil
local function patch_malverk(target)
    if target and target.set_defaults and not target._patched_set_defaults then
        local orig = target.set_defaults
        target.set_defaults = function(pack, ...)
            if not pack then return end
            return orig(pack, ...)
        end
        target._patched_set_defaults = true
    end
end

if malverk then patch_malverk(malverk) end
if Malverk then patch_malverk(Malverk) end
if SMODS and SMODS.Mods and SMODS.Mods['malverk'] then patch_malverk(SMODS.Mods['malverk']) end


-- Safeguard against CardSleeves/SMODS empty tooltip string crash
if SMODS then
    local orig_localize_box = SMODS.localize_box
    SMODS.localize_box = function(lines, args)
        if not lines or type(lines) ~= 'table' then
            lines = (type(lines) == 'string' and lines ~= '') and { lines } or {}
        end
        if orig_localize_box then
            return orig_localize_box(lines, args)
        end
        return {}
    end
end

if create_popup_UIBox_tooltip then
    local orig_create_popup_UIBox_tooltip = create_popup_UIBox_tooltip
    create_popup_UIBox_tooltip = function(tooltip)
        if tooltip and type(tooltip.text) == 'table' then
            local clean_text = {}
            for _, line in ipairs(tooltip.text) do
                if line and line ~= '' then
                    table.insert(clean_text, line)
                end
            end
            tooltip.text = clean_text
        end
        return orig_create_popup_UIBox_tooltip(tooltip)
    end
end

function get_card_key(card)
    if not card then return nil end
    return (card.config and card.config.center and card.config.center.key)
        or (card.config and card.config.center_key)
        or (card.ability and card.ability.name)
        or nil
end

function card_has_key(card, key)
    if not card or not key then return false end
    local k = get_card_key(card)
    if not k then return false end
    if k == key then return true end
    if string.find(k, key, 1, true) ~= nil then return true end
    return false
end

function has_charles_and_mochi()
    if not (G and G.jokers and G.jokers.cards) then return false end
    local has_charles, has_mochi = false, false
    for _, j in ipairs(G.jokers.cards) do
        if not j.debuff then
            if card_has_key(j, 'charles') then has_charles = true end
            if card_has_key(j, 'mochi') then has_mochi = true end
        end
    end
    return has_charles and has_mochi
end

function is_secret_card(card)
    if not card then return false end
    if card.is_secret or (card.config and card.config.center and card.config.center.is_secret) then return true end
    local key = get_card_key(card) or ''
    key = string.lower(tostring(key))
    local secret_names = {
        'esteban', 'thiago', 'black_hole', 'squele', 'bluxdir', 'charles', 'mochi', 'helin', 'raytracing', 'paco', 'yairo', 'kyra'
    }
    for _, name in ipairs(secret_names) do
        if string.find(key, name, 1, true) then return true end
    end
    return false
end

function is_amalgam_card(card)
    if not card then return false end
    if card.is_amalgam or (card.config and card.config.center and (card.config.center.is_amalgam or card.config.center.rarity == 'Amalgam' or card.config.center.rarity == 4)) then return true end
    local key = get_card_key(card) or ''
    key = string.lower(tostring(key))
    local amalgam_names = {
        'brainprint', 'midas_vampirico', 'programacion_certificacion', 'viajero_galactico', 'amalgam', 'amalgama'
    }
    for _, name in ipairs(amalgam_names) do
        if string.find(key, name, 1, true) then return true end
    end
    return false
end

function emit_secret_screen_sparkles(colours)
    if not (G and G.ROOM_ATTACH and G.ROOM_ATTACH.children and Particles) then return end
    if G.GAME and G.TIMERS and G.TIMERS.REAL then
        if G.GAME.last_secret_sparkle_time and (G.TIMERS.REAL - G.GAME.last_secret_sparkle_time < 0.25) then
            return
        end
        G.GAME.last_secret_sparkle_time = G.TIMERS.REAL
    end

    colours = colours or { G.C.WHITE, HEX('8a2be2'), HEX('d4af37'), HEX('ff00ff'), HEX('00ffff') }
    local p = Particles(0, 0, 0, 0, {
        timer = 0.015,
        pulse_max = 24,
        max = 0,
        scale = 0.32,
        speed = 1.3,
        lifespan = 1.1,
        attach = G.ROOM_ATTACH,
        colours = colours,
        fill = true
    })

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.75,
        blockable = false,
        blocking = false,
        func = function()
            if p and p.fade then p:fade(0.35, 1) end
            return true
        end
    }))
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 1.25,
        blockable = false,
        blocking = false,
        func = function()
            if p and p.remove then p:remove() end
            return true
        end
    }))
end

function is_invalid_eternal_joker(card)
    if not card then return true end
    if is_secret_card(card) then return true end
    local key = get_card_key(card) or ''
    key = string.lower(tostring(key))
    local invalid_keys = {
        'gros_michel', 'cavendish', 'ice_cream', 'popcorn', 'turtle_bean',
        'ramen', 'seltzer', 'diet_cola', 'egg', 'invisible', 'luchador',
        'mr_bones', 'blueberry', 'parca', 'ceremonial'
    }
    for _, ik in ipairs(invalid_keys) do
        if string.find(key, ik, 1, true) then return true end
    end
    return false
end

function is_sleeve_matching(target_key)
    if not target_key then return false end
    if G and G.GAME then
        if G.GAME[target_key .. "_sleeve_combo"] then return true end
        if G.GAME[target_key .. "_sleeve_active"] then return true end
        if G.GAME[target_key .. "_sleeve_selected"] then return true end
        if G.GAME.selected_sleeve then
            local s = tostring(G.GAME.selected_sleeve.key or G.GAME.selected_sleeve.name or G.GAME.selected_sleeve)
            if string.find(s, target_key, 1, true) ~= nil then return true end
        end
        if G.GAME.sleeve then
            local s = tostring(G.GAME.sleeve.key or G.GAME.sleeve.name or G.GAME.sleeve)
            if string.find(s, target_key, 1, true) ~= nil then return true end
        end
    end
    if CardSleeves then
        if CardSleeves.get_current_sleeve then
            local s = tostring(CardSleeves.get_current_sleeve() or "")
            if string.find(s, target_key, 1, true) ~= nil then return true end
        end
        if CardSleeves.Sleeve and CardSleeves.Sleeve.get_current_sleeve_key then
            local s = tostring(CardSleeves.Sleeve.get_current_sleeve_key() or "")
            if string.find(s, target_key, 1, true) ~= nil then return true end
        end
        if CardSleeves.current_sleeve then
            local s = tostring(CardSleeves.current_sleeve)
            if string.find(s, target_key, 1, true) ~= nil then return true end
        end
    end
    return false
end

function is_wild_card(pcard)
    if not pcard then return false end
    if SMODS and SMODS.has_enhancement and SMODS.has_enhancement(pcard, 'm_wild') then
        return true
    end
    if pcard.ability then
        if pcard.ability.name == 'Wild Card' or pcard.ability.effect == 'Wild Card' or pcard.ability.label == 'Wild Card' then
            return true
        end
    end
    if pcard.config then
        if pcard.config.center_key == 'm_wild' then return true end
        if type(pcard.config.center) == 'table' and pcard.config.center.key == 'm_wild' then return true end
        if type(pcard.config.center) == 'string' and pcard.config.center == 'm_wild' then return true end
        if pcard.config.center == G.P_CENTERS.m_wild then return true end
    end
    return false
end


function is_joker_copiable(card)
    if not card then return false end
    if card.debuff then return false end

    local key = get_card_key(card) or ''
    key = tostring(key)
    local name = (card.ability and card.ability.name) or (card.config and card.config.center and card.config.center.name) or ''
    name = tostring(name)

    if name == 'Blueprint' or name == 'Brainstorm' or name == 'Chameleon' or name == 'Brainprint' or 
       string.find(key, 'brainprint', 1, true) or string.find(key, 'chameleon_joker', 1, true) or string.find(key, 'blueprint', 1, true) or string.find(key, 'brainstorm', 1, true) then
        return false
    end

    if card.config and card.config.center and card.config.center.blueprint_compat == false then
        return false
    end
    if card.ability and card.ability.blueprint_compat == false then
        return false
    end

    return true
end

-- UIBox ability table hook
local card_generate_UIBox_ref = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table(...)
    ensure_custom_seals_discovered()
    local is_secret = is_secret_card(self)
    if is_secret then
        G.GAME_IS_RENDERING_SECRET_CARD = true
    end
    local res = card_generate_UIBox_ref(self, ...)
    G.GAME_IS_RENDERING_SECRET_CARD = false

    -- Chameleon compatibility display (just like Blueprint / Plano)
    local is_chameleon = card_has_key(self, 'chameleon_joker') or (self.ability and self.ability.name == 'Chameleon')
    if is_chameleon and res and res.main then
        local left_joker = nil
        if G.jokers and G.jokers.cards then
            for idx, j in ipairs(G.jokers.cards) do
                if j == self and idx > 1 then
                    left_joker = G.jokers.cards[idx - 1]
                    break
                end
            end
        end
        local is_compat = left_joker and is_joker_copiable(left_joker)
        local target_name = left_joker and ((left_joker.ability and left_joker.ability.name) or (left_joker.config and left_joker.config.center and left_joker.config.center.name)) or "None"
        local badge_text = is_compat and ((localize and localize('k_compatible')) or "Compatible") or ((localize and localize('k_incompatible')) or "Incompatible")

        local chameleon_ui_box = {
            n = G.UIT.R,
            config = { align = "cm", colour = G.C.CLEAR, padding = 0.04 },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm", colour = is_compat and G.C.GREEN or G.C.RED, r = 0.08, padding = 0.05, minw = 2.4, emboss = 0.04 },
                    nodes = {
                        { n = G.UIT.T, config = { text = " " .. badge_text .. " (" .. target_name .. ") ", colour = G.C.WHITE, scale = 0.3 } }
                    }
                }
            }
        }
        table.insert(res.main, { chameleon_ui_box })
    end

    -- Brainprint dual compatibility display (Left & Right)
    local is_brainprint = card_has_key(self, 'brainprint') or (self.ability and self.ability.name == 'Brainprint')
    if is_brainprint and res and res.main and G.jokers and G.jokers.cards then
        local my_idx = nil
        for idx, j in ipairs(G.jokers.cards) do
            if j == self then my_idx = idx; break end
        end
        local left_joker = (my_idx and my_idx > 1) and G.jokers.cards[my_idx - 1] or nil
        local right_joker = (my_idx and my_idx < #G.jokers.cards) and G.jokers.cards[my_idx + 1] or nil

        local l_compat = left_joker and is_joker_copiable(left_joker)
        local r_compat = right_joker and is_joker_copiable(right_joker)

        local l_name = left_joker and ((left_joker.ability and left_joker.ability.name) or (left_joker.config and left_joker.config.center and left_joker.config.center.name)) or "None"
        local r_name = right_joker and ((right_joker.ability and right_joker.ability.name) or (right_joker.config and right_joker.config.center and right_joker.config.center.name)) or "None"

        local brainprint_ui_box = {
            n = G.UIT.R,
            config = { align = "cm", colour = G.C.CLEAR, padding = 0.04 },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm", colour = l_compat and G.C.GREEN or G.C.RED, r = 0.08, padding = 0.03, minw = 2.4, emboss = 0.04 },
                    nodes = {
                        { n = G.UIT.T, config = { text = " [L] " .. (l_compat and "Compatible" or "Incompatible") .. " (" .. l_name .. ") ", colour = G.C.WHITE, scale = 0.28 } }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", colour = r_compat and G.C.GREEN or G.C.RED, r = 0.08, padding = 0.03, minw = 2.4, emboss = 0.04 },
                    nodes = {
                        { n = G.UIT.T, config = { text = " [R] " .. (r_compat and "Compatible" or "Incompatible") .. " (" .. r_name .. ") ", colour = G.C.WHITE, scale = 0.28 } }
                    }
                }
            }
        }
        table.insert(res.main, { brainprint_ui_box })
    end

    -- Doppelgänger reflected target indicator & random misprint description
    if self.doppelganger_reflected and res and res.main then
        local rand_mult = math.random(-50, -1)
        local rand_chips = math.random(-100, -5)
        local rand_div = string.format('%.1f', math.random(15, 50) / 10)
        local glitch_glyphs = { "?", "!", "#", "$", "@", "%", "&", "Ø", "§", "¿" }
        local g1 = glitch_glyphs[math.random(1, #glitch_glyphs)] .. glitch_glyphs[math.random(1, #glitch_glyphs)]
        local g2 = glitch_glyphs[math.random(1, #glitch_glyphs)] .. glitch_glyphs[math.random(1, #glitch_glyphs)]

        res.main = {
            {
                {
                    n = G.UIT.R,
                    config = { align = "cm", colour = HEX('1c2833'), r = 0.08, padding = 0.06, minw = 2.6, emboss = 0.04 },
                    nodes = {
                        { n = G.UIT.T, config = { text = " [ POSEÍDO POR DOPPELGÄNGER ] ", colour = HEX('e74c3c'), scale = 0.32 } }
                    }
                }
            },
            {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.03 },
                    nodes = {
                        { n = G.UIT.T, config = { text = g1 .. " EFECTO INVERTIDO " .. g2, colour = HEX('aeb6bf'), scale = 0.3 } }
                    }
                }
            },
            {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.T, config = { text = tostring(rand_mult) .. " Mult  /  " .. tostring(rand_chips) .. " Fichas", colour = G.C.RED, scale = 0.3 } }
                    }
                }
            },
            {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "Divide Mult entre /" .. tostring(rand_div), colour = HEX('ff7675'), scale = 0.28 } }
                    }
                }
            },
            {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "(Ignora cartas al reactivar)", colour = HEX('7f8c8d'), scale = 0.25 } }
                    }
                }
            }
        }
    end

    return res
end

if Card.generate_card_ui then
    local gen_card_ui_ref = Card.generate_card_ui
    function Card:generate_card_ui(...)
        local is_secret = is_secret_card(self)
        if is_secret then
            G.GAME_IS_RENDERING_SECRET_CARD = true
        end
        local res = gen_card_ui_ref(self, ...)
        G.GAME_IS_RENDERING_SECRET_CARD = false
        return res
    end
end

-- Secret rarity badge hook
local create_badge_ref = create_badge
function create_badge(text, badge_colour, text_colour, scale)
    if type(text) == 'table' then
        return text
    end
    if G.GAME_IS_RENDERING_SECRET_CARD and (text == 'Legendary' or text == 'Legendario' or text == 'Secret' or text == 'Secreto' or (localize and text == localize('k_legendary'))) then
        text = 'Secreto'
        badge_colour = HEX('000000')
        text_colour = G.C.WHITE
    end
    if type(text) ~= 'string' then
        text = tostring(text or '')
    end
    return create_badge_ref(text, badge_colour, text_colour, scale)
end

function ease_job_pack_background()
    ease_colour(G.C.DYN_UI.MAIN, HEX('4a1a14'))
    ease_colour(G.C.DYN_UI.DARK, HEX('240b07'))
    ease_background_colour{new_colour = HEX('4a1a14'), special_colour = HEX('6b251b'), contrast = 2}
end

local card_open_ref = Card.open
function Card:open()
    local is_job_pack = self.ability and self.ability.set == 'Booster' and (
        (self.ability.name and string.find(self.ability.name, 'job_pack')) or
        (self.config and self.config.center and (self.config.center.kind == 'Job' or (self.config.center.key and string.find(self.config.center.key, 'job_pack'))))
    )
    local ret = card_open_ref(self)
    if is_job_pack then
        ease_job_pack_background()
    end
    return ret
end

if localize then
    local orig_localize = localize
    function localize(args, misc_cat)
        if type(args) == 'string' then
            if args == 'k_job_pack' or args == 'k_job_pack_1' or args == 'k_job_pack_2' or args == 'k_job_pack_3' then
                return 'Job Application'
            end
        elseif type(args) == 'table' then
            if args.key == 'k_job_pack' then
                return 'Job Application'
            end
        end
        local res = orig_localize(args, misc_cat)
        if res == 'ERROR' and type(args) == 'string' then
            if args == 'k_job_pack' or string.find(args, 'job_pack') then
                return 'Job Application'
            end
        end
        return res
    end
end

function check_all_suits_flushed_unlock(self, args)
    if (args.type == 'hand' or args.type == 'play_hand') and args.scoring_hand and #args.scoring_hand >= 4 then
        G.GAME.flushed_suits = G.GAME.flushed_suits or {}
        local suits = {'Hearts', 'Spades', 'Clubs', 'Diamonds'}
        for _, s in ipairs(suits) do
            local matches = true
            for _, c in ipairs(args.scoring_hand) do
                if not c:is_suit(s) then matches = false; break end
            end
            if matches then
                G.GAME.flushed_suits[s] = true
            end
        end
        if G.GAME.flushed_suits.Hearts and G.GAME.flushed_suits.Spades and G.GAME.flushed_suits.Clubs and G.GAME.flushed_suits.Diamonds then
            return true
        end
    end
    if G.GAME and G.GAME.flushed_suits and G.GAME.flushed_suits.Hearts and G.GAME.flushed_suits.Spades and G.GAME.flushed_suits.Clubs and G.GAME.flushed_suits.Diamonds then
        return true
    end
end

local card_redeem_ref = Card.redeem
function Card:redeem(...)
    local key = (self.config and self.config.center and self.config.center.key) or self.config.center_key or (self.ability and self.ability.name)
    if key == 'v_blank' or key == 'v_Witch_brew_blank' or key == 'blank' then
        if G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile] then
            G.PROFILES[G.SETTINGS.profile].blank_vouchers_bought = (G.PROFILES[G.SETTINGS.profile].blank_vouchers_bought or 0) + 1
        end
        check_for_unlock({ type = 'blank_voucher_bought' })
    end

    local ret = card_redeem_ref(self, ...)

    if self.ability and self.ability.set == 'Voucher' then
        local raw_key = (self.config and self.config.center and self.config.center.key) or self.config.center_key or ""
        local c_key = self.config.center_key or raw_key
        local keys_to_mark = {
            raw_key,
            c_key,
            string.gsub(raw_key, 'Witch_brew_', 'Witch brew_'),
            string.gsub(raw_key, 'Witch brew_', 'Witch_brew_'),
            string.gsub(raw_key, 'v_Witch_brew_', 'v_'),
            string.gsub(raw_key, 'v_Witch brew_', 'v_'),
            string.gsub(raw_key, 'v_Witch_brew_', ''),
            string.gsub(raw_key, 'v_Witch brew_', '')
        }
        if G.GAME then
            G.GAME.used_vouchers = G.GAME.used_vouchers or {}
            for _, k in ipairs(keys_to_mark) do
                if k and k ~= "" then
                    G.GAME.used_vouchers[k] = true
                end
            end
            if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
                for _, target_k in ipairs(keys_to_mark) do
                    if target_k and target_k ~= "" then
                        G.GAME.current_round.voucher.spawn[target_k] = false
                    end
                end
            end
        end
    end

    return ret
end

-- Hook eval_card for debuffed hand suppression & Lucky Both unlock check
if eval_card then
    local eval_card_ref = eval_card
    function eval_card(card, context)
        if G.GAME and G.GAME.witch_brew_hand_debuffed and context and (context.after or context.joker_main or context.before) then
            return {}, {}
        end
        local ret, post_trig = eval_card_ref(card, context)
        if ret and ret.dollars and (ret.mult or ret.h_mult or ret.x_mult or ret.Xmult) then
            if G.GAME then G.GAME.lucky_hit_both = true end
            check_for_unlock({ type = 'lucky_both' })
        end
        return ret or {}, post_trig or {}
    end
end

-- Blind hook for Stick Penalty & Custom Boss Backgrounds
-- Helper to reset UI and background colors back to Balatro originals after Boss Blind
function reset_witch_brew_boss_ui(state)
    -- If currently in an active, non-disabled blind during round gameplay, NEVER reset!
    if G.GAME and G.GAME.blind and not G.GAME.blind.disabled then
        local cur_state = state or (G and G.STATE)
        if cur_state == G.STATES.SELECTING_HAND 
           or cur_state == G.STATES.HAND_PLAYED 
           or cur_state == G.STATES.DRAW_TO_HAND 
           or cur_state == G.STATES.PLAY_TAROT 
           or (G.TAROT_INTERRUPT and G.TAROT_INTERRUPT ~= G.STATES.SHOP and G.TAROT_INTERRUPT ~= G.STATES.ROUND_EVAL and G.TAROT_INTERRUPT ~= G.STATES.BLIND_SELECT) then
            return
        end
    end

    state = state or (G and G.STATE)
    if G.C and G.C.DYN_UI then
        local fixed_ui = HEX('374244')
        local def_boss_main = darken(G.C.BLACK, 0.05)
        local def_boss_dark = lighten(G.C.BLACK, 0.07)

        if G.C.DYN_UI.MAIN then
            ease_colour(G.C.DYN_UI.MAIN, fixed_ui)
        end
        if G.C.DYN_UI.DARK then
            ease_colour(G.C.DYN_UI.DARK, fixed_ui)
        end
        if G.C.DYN_UI.BOSS_MAIN then
            ease_colour(G.C.DYN_UI.BOSS_MAIN, def_boss_main)
        end
        if G.C.DYN_UI.BOSS_DARK then
            ease_colour(G.C.DYN_UI.BOSS_DARK, def_boss_dark)
        end
        if G.C.DYN_UI.BOSS_PALE then
            ease_colour(G.C.DYN_UI.BOSS_PALE, fixed_ui)
        end
    end

    if G.GAME then
        G.GAME.blind_color = nil
        G.GAME.doppelganger_target = nil
        G.GAME.doppelganger_hand_mult = 0
        G.GAME.doppelganger_hand_chips = 0
        G.GAME.doppelganger_hand_xmult = 1
        G.GAME.doppelganger_hand_xchips = 1
        G.GAME.doppelganger_target_name = nil
    end
    if G.ARGS then
        G.ARGS.blind_colour = nil
    end

    -- Reset background colour safely without calling ease_background_colour_blind (which would re-trigger blind:change_colour)
    if ease_background_colour then
        local bg_col = (G.C and G.C.BLIND and G.C.BLIND['Small']) or (G.C and G.C.BACKGROUND and G.C.BACKGROUND.D) or HEX('374244')
        ease_background_colour{
            new_colour = bg_col,
            special_colour = bg_col,
            contrast = 1
        }
    end
end

-- Guard ease_background_colour from resetting to default background when active in a custom/boss blind during round
if ease_background_colour then
    local orig_ease_bg = ease_background_colour
    function ease_background_colour(args)
        if args and G.GAME and G.GAME.blind and not G.GAME.blind.disabled then
            local in_round = (G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND or G.STATE == G.STATES.PLAY_TAROT or (G.TAROT_INTERRUPT and G.TAROT_INTERRUPT ~= G.STATES.SHOP and G.TAROT_INTERRUPT ~= G.STATES.ROUND_EVAL and G.TAROT_INTERRUPT ~= G.STATES.BLIND_SELECT))
            if in_round then
                local theme = get_witch_brew_blind_theme and get_witch_brew_blind_theme(G.GAME.blind)
                local def_small = (G.C and G.C.BLIND and G.C.BLIND['Small'])
                local is_default_bg = (args.new_colour == def_small) or (type(args.new_colour) == 'table' and def_small and args.new_colour[1] == def_small[1] and args.new_colour[2] == def_small[2] and args.new_colour[3] == def_small[3])
                if theme and is_default_bg then
                    args.new_colour = theme.new_colour
                    args.special_colour = theme.special_colour
                    args.tertiary_colour = theme.tertiary_colour
                    args.contrast = theme.contrast or 2
                elseif is_default_bg and G.GAME.blind.boss then
                    return
                end
            end
        end
        return orig_ease_bg(args)
    end
end

-- Hook Blind:change_colour to apply Witch_brew theme or fallback cleanly
if Blind and Blind.change_colour then
    local orig_blind_change_colour = Blind.change_colour
    function Blind:change_colour(blind_col)
        if self.boss and not self.disabled then
            local theme = get_witch_brew_blind_theme and get_witch_brew_blind_theme(self)
            if theme then
                if G.C and G.C.DYN_UI then
                    if theme.boss_colour then ease_colour(G.C.DYN_UI.BOSS_MAIN, theme.boss_colour) end
                    if theme.tertiary_colour or theme.boss_colour then ease_colour(G.C.DYN_UI.BOSS_DARK, theme.tertiary_colour or theme.boss_colour) end
                    if theme.special_colour then ease_colour(G.C.DYN_UI.MAIN, theme.special_colour) end
                    if theme.tertiary_colour then ease_colour(G.C.DYN_UI.DARK, theme.tertiary_colour) end
                end
                return
            end
        end
        orig_blind_change_colour(self, blind_col)
    end
end

-- Hook ease_background_colour_blind to ensure custom boss blind theme is preserved during round and reset on exit
if ease_background_colour_blind then
    local orig_ease_bg_blind = ease_background_colour_blind
    function ease_background_colour_blind(state, blind_override)
        local blind = G.GAME and G.GAME.blind
        local blindname = blind_override or (blind and blind.name ~= '' and blind.name) or ''

        local is_pack = (state == G.STATES.TAROT_PACK or state == G.STATES.SPECTRAL_PACK or
                         state == G.STATES.STANDARD_PACK or state == G.STATES.BUFFOON_PACK or
                         state == G.STATES.PLANET_PACK)

        -- Check if current active blind is a Witch_brew Boss Blind
        local theme = nil
        if not is_pack and blind and blind.boss and not blind.disabled then
            theme = get_witch_brew_blind_theme and get_witch_brew_blind_theme(blind)
        elseif not is_pack and blindname ~= '' and blindname ~= 'Small Blind' and blindname ~= 'Big Blind' then
            theme = get_witch_brew_blind_theme and get_witch_brew_blind_theme(blindname)
        end

        if theme and state ~= G.STATES.SHOP and state ~= G.STATES.ROUND_EVAL and blind_override ~= '' then
            ease_custom_blind_background(blind or blindname)
            return
        end

        orig_ease_bg_blind(state, blind_override)

        if state == G.STATES.ROUND_EVAL or state == G.STATES.BLIND_SELECT or state == G.STATES.SHOP or blind_override == '' then
            reset_witch_brew_boss_ui(state)
        end
    end
end

-- Hook toggle_shop to restore default UI when returning to blind select & reset sale tag effects
if G.FUNCS and G.FUNCS.toggle_shop then
    local orig_toggle_shop = G.FUNCS.toggle_shop
    G.FUNCS.toggle_shop = function(e)
        if reset_sale_tag_effects then reset_sale_tag_effects() end
        local ret = orig_toggle_shop(e)
        reset_witch_brew_boss_ui(G.STATES.BLIND_SELECT)
        return ret
    end
end

-- Blind hook for Detective Job, Stick Penalty & Custom Boss Backgrounds
local set_blind_ref = Blind.set_blind
function Blind:set_blind(blind, reset, silent)
    local ret = set_blind_ref(self, blind, reset, silent)
    if G.GAME and G.GAME.stick_penalty then
        self.chips = math.floor(self.chips * G.GAME.stick_penalty)
        G.GAME.stick_penalty = nil
    end

    if blind and self.boss and not self.disabled then
        local theme = get_witch_brew_blind_theme and get_witch_brew_blind_theme(self)
        if theme and ease_custom_blind_background then
            ease_custom_blind_background(self)
        end
    elseif not blind or not self.boss or self.disabled then
        reset_witch_brew_boss_ui()
    end

    return ret
end

-- Blind disable hook to reset background
if Blind.disable then
    local blind_disable_ref = Blind.disable
    function Blind:disable()
        local ret = blind_disable_ref(self)
        reset_witch_brew_boss_ui()
        return ret
    end
end

-- Blind defeat hook to reset background
if Blind.defeat then
    local blind_defeat_ref = Blind.defeat
    function Blind:defeat(silent)
        local ret = blind_defeat_ref(self, silent)
        reset_witch_brew_boss_ui()
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.5,
            func = function()
                reset_witch_brew_boss_ui()
                return true
            end
        }))
        return ret
    end
end


-- Shop dollar tracking hook for Merchant
local game_update_ref = Game.update
function Game:update(dt)
    game_update_ref(self, dt)
    if G.STATE == G.STATES.SHOP and G.GAME then
        if not G.GAME.entered_shop_dollars then
            G.GAME.entered_shop_dollars = G.GAME.dollars or 0
        end
    elseif G.STATE ~= G.STATES.SHOP and G.GAME and G.GAME.entered_shop_dollars then
        local entered = (to_number and to_number(G.GAME.entered_shop_dollars)) or tonumber(G.GAME.entered_shop_dollars) or 0
        local current = (to_number and to_number(G.GAME.dollars)) or tonumber(G.GAME.dollars) or 0
        if entered >= 50 and current <= 10 then
            check_for_unlock({ type = 'leave_shop' })
        end
        G.GAME.entered_shop_dollars = nil
    end
end

-- Mountain Blind consumable check & Layered SFX for Consumables
local use_card_ref = Card.use_consumeable
function Card:use_consumeable(area, copier)
    if G.GAME and G.GAME.blind and (G.GAME.blind.name == 'b_Witch_brew_mountain' or G.GAME.blind.name == 'mountain' or G.GAME.blind.key == 'b_Witch_brew_mountain' or G.GAME.blind.name == 'The Mountain') and not G.GAME.blind.disabled then
        G.GAME.mountain_disabled_hand = true
        if G.GAME.blind.wiggle then G.GAME.blind:wiggle() end
        if G.hand and G.hand.parse_highlighted then
            G.hand:parse_highlighted()
        end
    end

    -- Composite layered sound effects with pitch modulation
    local set = (self.ability and self.ability.set) or (self.config and self.config.center and self.config.center.set)
    local ckey = (self.config and self.config.center and self.config.center.key) or (self.config and self.config.center_key) or ''

    if set == 'Potion' and (ckey == 'c_Witch_brew_potion_amalgama' or ckey == 'potion_amalgama' or string.find(ckey, 'amalgama', 1, true)) then
        -- Amalgam Potion: Resonant deep thud + magical prism chord
        play_sound('timpani', 0.6, 1.0)
        play_sound('foil1', 0.75, 0.7)
        play_sound('polychrome1', 1.25, 0.85)
        play_sound('tarot2', 0.85, 0.6)
    elseif set == 'Potion' then
        -- Regular Potions: Cork pop + effervescence
        play_sound('cancel', 1.35, 0.9)
        play_sound('tarot2', 1.25, 0.7)
    elseif set == 'Job' or string.find(ckey, '_job', 1, true) then
        -- Job Cards: Wax seal + paper crunch + coin ding
        play_sound('crumple1', 0.9, 0.9)
        play_sound('tarot1', 0.7, 0.85)
        play_sound('coin6', 1.45, 0.75)
    elseif set == 'Spectral' and (string.find(ckey, 'Witch_brew') or (self.config and self.config.center and self.config.center.atlas == 'c_spectrals')) then
        -- Mod Spectrals: Deep ethereal gong + spectral chime
        play_sound('timpani', 0.5, 0.95)
        play_sound('tarot2', 0.65, 0.8)
        play_sound('foil1', 0.75, 0.7)
    end

    local ret = use_card_ref(self, area, copier)

    -- Ensure custom/boss blind background is preserved when using any consumable during round gameplay
    if G.GAME and G.GAME.blind and not G.GAME.blind.disabled then
        local blind = G.GAME.blind
        local theme = get_witch_brew_blind_theme and get_witch_brew_blind_theme(blind)
        if G.E_MANAGER then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    if G.GAME and G.GAME.blind and not G.GAME.blind.disabled and (G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.PLAY_TAROT or G.STATE == G.STATES.DRAW_TO_HAND) then
                        if theme and ease_custom_blind_background then
                            ease_custom_blind_background(blind)
                        elseif ease_background_colour_blind then
                            ease_background_colour_blind(G.STATE or G.STATES.SELECTING_HAND)
                        end
                    end
                    return true
                end
            }))
        end
    end

    return ret
end

-- Safety guard for Card:update_alert when ability is nil or card is uninitialized
local card_update_alert_ref = Card.update_alert
function Card:update_alert()
    if not self or not self.ability then return end
    return card_update_alert_ref(self)
end

-- Safety guard for Card:set_ability & Runway Joker enhancement tracker
local card_set_ability_ref = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
    if not center then
        center = (G.P_CENTERS and G.P_CENTERS.c_base) or { name = 'Default', set = 'Default', config = {} }
    end
    card_set_ability_ref(self, center, initial, delay_sprites)
    if not self.ability then
        self.ability = { name = 'Default', set = 'Default', mult = 0, chips = 0, x_mult = 1 }
    end
    if center and type(center) == 'table' then
        if center.key then
            self.config.center_key = center.key
        end
        local ckey = tostring(center.key or '')
        if string.find(ckey, 'Witch_brew') or string.find(ckey, 'Witch brew') then
            local clean_name = (center.loc_txt and center.loc_txt.name) or (center.name and not string.find(center.name, '^[jvc]_') and center.name)
            if clean_name then
                self.label = clean_name
                self.ability.name = clean_name
            end
        end
    end
    if not initial and center and center.set == 'Enhanced' then
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if not j.debuff and card_has_key(j, 'runway') and j.ability and j.ability.extra then
                    local gain = j.ability.extra.xmult_gain or 0.1
                    j.ability.extra.xmult = (j.ability.extra.xmult or 1.0) + gain
                    card_eval_status_text(j, 'extra', nil, nil, nil, {
                        message = 'X' .. string.format('%.1f', j.ability.extra.xmult) .. ' Mult!',
                        colour = G.C.XMULT
                    })
                    j:juice_up(0.4, 0.4)
                end
            end
        end
    end
end

-- Tremble animation for First-Hand, Single-Use, and Unique active Jokers
local card_update_ref = Card.update
function Card:update(dt)
    card_update_ref(self, dt)
    if self.area and self.area == G.jokers and not self.debuff and G.STATE and (G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.HAND_PLAYED) then
        local key = (self.config and self.config.center and (self.config.center.key or self.config.center_key)) or ""
        local hands_played = (G.GAME and G.GAME.current_round and G.GAME.current_round.hands_played) or 0
        local discards_used = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_used) or 0

        local should_tremble = false
        if key == 'j_Witch_brew_bluxdir' and hands_played == 0 then
            should_tremble = true
        elseif key == 'j_Witch_brew_mano_extendida' and discards_used == 0 then
            should_tremble = true
        elseif (key == 'j_dna' or key == 'j_trading_card' or key == 'j_sixth_sense' or key == 'j_seance' or key == 'j_superposition') and hands_played == 0 then
            should_tremble = true
        elseif key == 'j_luchador' or key == 'j_diet_cola' or key == 'j_invisible' then
            should_tremble = true
        elseif key == 'j_mr_bones' and G.GAME and G.GAME.blind and G.GAME.blind.boss then
            should_tremble = true
        elseif self.ability and (self.ability.first_hand or self.ability.single_use or self.ability.tremble_active) then
            should_tremble = true
        end

        if should_tremble and G.TIMERS and G.TIMERS.REAL then
            if not self.last_tremble_time or (G.TIMERS.REAL - self.last_tremble_time > 0.42) then
                self.last_tremble_time = G.TIMERS.REAL
                self:juice_up(0.06, 0.03)
            end
        end
    end
end

-- Overseer Deck & CardSleeves Hooks
local add_tag_ref = add_tag
function add_tag(tag)
    local ret = add_tag_ref(tag)
    if G.GAME and not G.GAME.overseer_duplicating_tag and tag then
        local is_combo = G.GAME.overseer_sleeve_combo or (G.GAME.overseer_deck and is_sleeve_matching("overseer"))
        if is_combo then
            -- Tripled tags (add 2 additional copies)
            G.GAME.overseer_duplicating_tag = true
            G.E_MANAGER:add_event(Event({
                func = function()
                    local new_tag1 = Tag(tag.key)
                    add_tag_ref(new_tag1)
                    local new_tag2 = Tag(tag.key)
                    add_tag_ref(new_tag2)
                    G.GAME.overseer_duplicating_tag = nil
                    return true
                end
            }))
        elseif G.GAME.overseer_deck or G.GAME.overseer_sleeve_active or is_sleeve_matching("overseer") then
            -- Doubled tags (add 1 additional copy)
            G.GAME.overseer_duplicating_tag = true
            G.E_MANAGER:add_event(Event({
                func = function()
                    local new_tag = Tag(tag.key)
                    add_tag_ref(new_tag)
                    G.GAME.overseer_duplicating_tag = nil
                    return true
                end
            }))
        end
    end
    return ret
end

local set_cost_ref = Card.set_cost
function Card:set_cost()
    set_cost_ref(self)
    local no_markup = G.GAME and (G.GAME.overseer_no_markup or G.GAME.overseer_sleeve_combo)
    if G.GAME and G.GAME.overseer_deck and not no_markup and self.ability and self.ability.set == 'Joker' then
        self.cost = math.max(1, math.floor(self.cost * 1.5))
    end
    if G.GAME and G.GAME.sale_tag_active then
        local is_shop_item = self.area and (self.area == G.shop_jokers or self.area == G.shop_booster or self.area == G.shop_vouchers)
        if is_shop_item then
            self.cost = math.max(1, math.floor(self.cost * 0.5))
        end
    end
end

-- Refresh cost for newly rerolled / emplaced shop cards
local cardarea_emplace_ref = CardArea.emplace
function CardArea:emplace(card, location, stay_flipped)
    cardarea_emplace_ref(self, card, location, stay_flipped)
    if G.GAME and G.GAME.sale_tag_active and (self == G.shop_jokers or self == G.shop_booster or self == G.shop_vouchers) then
        if card and card.set_cost then
            card:set_cost()
        end
    end
end

-- Revert Sale Tag effects when leaving the shop or resetting round
local function reset_sale_tag_effects()
    if G.GAME then
        G.GAME.sale_tag_active = nil
        if G.GAME.round_resets and G.GAME.round_resets.temp_reroll_cost then
            G.GAME.round_resets.temp_reroll_cost = nil
            if calculate_reroll_cost then
                calculate_reroll_cost(true)
            end
        end
        -- Heal any lingering corrupted discount_percent from earlier versions
        if G.GAME.discount_percent and G.GAME.discount_percent > 0 then
            local legitimate_discount = 0
            if G.GAME.used_vouchers then
                if G.GAME.used_vouchers.v_liquidation then
                    legitimate_discount = 50
                elseif G.GAME.used_vouchers.v_clearance_sale then
                    legitimate_discount = 25
                end
            end
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    if j.config and j.config.center and (j.config.center.key == 'j_Witch_brew_merchant_joker' or j.config.center.key == 'j_crack_businessman' or j.config.center.name == 'Merchant' or j.config.center.name == 'Businessman') then
                        legitimate_discount = legitimate_discount + 25
                    end
                end
            end
            if G.GAME.discount_percent > legitimate_discount then
                G.GAME.discount_percent = legitimate_discount
            end
        end
    end
end


local reset_idol_card_ref = reset_idol_card
function reset_idol_card()
    reset_sale_tag_effects()
    if reset_idol_card_ref then
        return reset_idol_card_ref()
    end
end

-- Silver Seal Hand XMult Hook (Steel card with Silver Seal gives X2.5 in hand)
local card_get_chip_h_x_mult_ref = Card.get_chip_h_x_mult
function Card:get_chip_h_x_mult()
    local is_silver = (self.seal == 'silver' or self.seal == 'Witch_brew_silver')
    local is_steel = (self.ability and self.ability.name == 'Steel Card') or (self.config and self.config.center == G.P_CENTERS.m_steel)
    if is_silver and is_steel then
        return 2.5
    end
    if card_get_chip_h_x_mult_ref then
        return card_get_chip_h_x_mult_ref(self)
    end
    return 1
end

-- Lover Joker Soulmates Helpers (No special characters)
function format_soulmate_card_name(c)
    if not c or not c.base then return "None" end
    local val = tostring(c.base.value or '?')
    local suit = tostring(c.base.suit or '')
    return val .. " of " .. suit
end

function get_or_pick_soulmates()
    if not G.playing_cards or #G.playing_cards < 2 then return nil, nil end
    local sm1, sm2 = nil, nil
    for _, c in ipairs(G.playing_cards) do
        if c.ability and c.ability.is_soulmate then
            if not sm1 then sm1 = c
            elseif not sm2 and c ~= sm1 then sm2 = c end
        end
    end
    if not sm1 or not sm2 then
        local unbonded = {}
        for _, c in ipairs(G.playing_cards) do
            if not (c.ability and c.ability.is_soulmate) then
                table.insert(unbonded, c)
            end
        end
        if not sm1 and #unbonded > 0 then
            sm1 = pseudorandom_element(unbonded, pseudoseed('soulmate_1'))
            if sm1 then
                sm1.ability = sm1.ability or {}
                sm1.ability.is_soulmate = true
                for i = #unbonded, 1, -1 do if unbonded[i] == sm1 then table.remove(unbonded, i) end end
            end
        end
        if not sm2 and #unbonded > 0 then
            sm2 = pseudorandom_element(unbonded, pseudoseed('soulmate_2'))
            if sm2 then
                sm2.ability = sm2.ability or {}
                sm2.ability.is_soulmate = true
            end
        end
    end
    return sm1, sm2
end

-- Voucher & Rarity calculation helpers
local function has_taster_voucher()
    if not G.GAME or not G.GAME.used_vouchers then return false end
    return G.GAME.used_vouchers.v_Witch_brew_catador or G.GAME.used_vouchers.v_catador or G.GAME.used_vouchers.catador
end

local function has_critic_voucher()
    if not G.GAME or not G.GAME.used_vouchers then return false end
    return G.GAME.used_vouchers.v_Witch_brew_critico or G.GAME.used_vouchers.v_critico or G.GAME.used_vouchers.critico
end

local function is_common_rarity(r)
    if not r then return false end
    if r == 1 or r == 'Common' or r == 'common' or tostring(r) == '1' then return true end
    if type(r) == 'number' and r > 0 and r <= 0.85 then return true end
    return false
end

local function upgrade_common_rarity(r, seed)
    local is_str = (type(r) == 'string' and not tonumber(r))
    local roll = pseudorandom(seed or 'voucher_upgrade_rarity')
    if is_str then
        return (roll < 0.75) and 'Uncommon' or 'Rare'
    else
        return (roll < 0.75) and 2 or 3
    end
end

local get_current_joker_rarity_ref = get_current_joker_rarity
function get_current_joker_rarity(area, rarity_share)
    local rarity = get_current_joker_rarity_ref(area, rarity_share)
    if G.GAME then
        if has_critic_voucher() and is_common_rarity(rarity) then
            rarity = upgrade_common_rarity(rarity, 'critico_voucher')
        elseif has_taster_voucher() and is_common_rarity(rarity) then
            if pseudorandom('catador_voucher') < 0.75 then
                rarity = upgrade_common_rarity(rarity, 'catador_voucher_rarity')
            end
        end

        if G.GAME.merchant_rare_boost and G.GAME.merchant_rare_boost > 0 then
            if rarity ~= 3 and rarity ~= 'Rare' and pseudorandom('merchant_rare') < 0.35 then
                rarity = (type(rarity) == 'string' and not tonumber(rarity)) and 'Rare' or 3
            end
        end
    end
    return rarity
end

if SMODS and SMODS.poll_rarity then
    local orig_poll_rarity = SMODS.poll_rarity
    function SMODS.poll_rarity(key, rarity_share)
        local rarity = orig_poll_rarity(key, rarity_share)
        if key == 'Joker' and G.GAME then
            if has_critic_voucher() and is_common_rarity(rarity) then
                rarity = upgrade_common_rarity(rarity, 'critico_smods_poll')
            elseif has_taster_voucher() and is_common_rarity(rarity) then
                if pseudorandom('catador_smods_poll') < 0.75 then
                    rarity = upgrade_common_rarity(rarity, 'catador_smods_poll_rarity')
                end
            end
        end
        return rarity
    end
end

-- Helper to check if player currently owns Showman (non-debuffed)
local function player_has_showman()
    if SMODS and SMODS.find_card then
        local smods_showman = SMODS.find_card('j_ring_master')
        if smods_showman and #smods_showman > 0 then return true end
    end
    if find_joker then
        local vanilla_showman = find_joker('Showman')
        if vanilla_showman and #vanilla_showman > 0 then return true end
        local rm = find_joker('Ring Master')
        if rm and #rm > 0 then return true end
    end
    if G and G.jokers and G.jokers.cards then
        for _, j in ipairs(G.jokers.cards) do
            if not j.debuff and j.config and j.config.center then
                local k = j.config.center.key or ''
                local n = (j.ability and j.ability.name) or (j.config.center.name) or ''
                if k == 'j_ring_master' or n == 'Showman' then
                    return true
                end
            end
        end
    end
    return false
end

-- Helper to check if a Joker is already owned in G.jokers
local function is_joker_owned_by_player(j_card)
    if not (G and G.jokers and G.jokers.cards and j_card and j_card.config and j_card.config.center) then
        return false
    end
    local j_key = j_card.config.center.key
    local j_name = (j_card.ability and j_card.ability.name) or j_card.config.center.name
    for _, owned in ipairs(G.jokers.cards) do
        if owned ~= j_card then
            if j_key and owned.config and owned.config.center and owned.config.center.key == j_key then
                return true
            end
            if j_name and ((owned.ability and owned.ability.name == j_name) or (owned.config and owned.config.center and owned.config.center.name == j_name)) then
                return true
            end
        end
    end
    return false
end

-- Sync all owned Jokers in G.jokers to G.GAME.used_jokers
local function sync_owned_jokers_to_used()
    if not (G and G.GAME and G.GAME.used_jokers and G.jokers and G.jokers.cards) then return end
    if player_has_showman() then return end
    for _, j in ipairs(G.jokers.cards) do
        if j.config and j.config.center and j.config.center.key then
            G.GAME.used_jokers[j.config.center.key] = true
        end
        if j.ability and j.ability.name and G.P_CENTERS then
            for k, v in pairs(G.P_CENTERS) do
                if v.name == j.ability.name then
                    G.GAME.used_jokers[k] = true
                end
            end
        end
    end
end

-- Clean any leaked duplicate flags from SMODS if player doesn't have Showman
local function clean_leaked_duplicate_flags()
    if not player_has_showman() then
        if SMODS then
            if SMODS.create_card_allow_duplicates then SMODS.create_card_allow_duplicates = nil end
            if SMODS.poll_object_allow_duplicates then SMODS.poll_object_allow_duplicates = nil end
        end
    end
end

-- Hook get_current_pool to enforce used_jokers sync
local orig_get_current_pool = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
    clean_leaked_duplicate_flags()
    if _type == 'Joker' then
        sync_owned_jokers_to_used()
    end
    return orig_get_current_pool(_type, _rarity, _legendary, _append)
end

-- Hook SMODS.showman to ensure it never allows duplicates without Showman owned
if SMODS and SMODS.showman then
    local orig_smods_showman = SMODS.showman
    function SMODS.showman(card_key)
        if not player_has_showman() then
            return false
        end
        return orig_smods_showman(card_key)
    end
end

-- Card generation hook for La Muchachada, Vouchers, and Duplicate Prevention
local create_card_ref = create_card
function create_card(type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    clean_leaked_duplicate_flags()
    if type == 'Joker' then
        sync_owned_jokers_to_used()
    end

    if not forced_key and type == 'Spectral' and (area == G.pack_cards or key_append == 'spe' or (G.pack_cards and area == G.pack_cards)) then
        local muchachada_center_key = (G.P_CENTERS and G.P_CENTERS['c_Witch_brew_la_muchachada'] and 'c_Witch_brew_la_muchachada') or 'c_la_muchachada'
        local allow_spawn = not (G.GAME and G.GAME.used_jokers and G.GAME.used_jokers[muchachada_center_key]) or player_has_showman()
        if allow_spawn then
            local ante = (G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 1
            if pseudorandom('la_muchachada_spectral_' .. (key_append or 'spe') .. ante) > 0.9985 then
                forced_key = muchachada_center_key
            end
        end
    end

    local card = create_card_ref(type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if type == 'Joker' and card and not forced_key and card.ability and card.ability.set == 'Joker' then
        local c_rarity = (card.config and card.config.center and card.config.center.rarity) or card.ability.rarity
        if is_common_rarity(c_rarity) then
            local should_replace = false
            if has_critic_voucher() then
                should_replace = true
            elseif has_taster_voucher() and pseudorandom('catador_create_check') < 0.75 then
                should_replace = true
            end
            if should_replace then
                local replacement_rarity = (pseudorandom('voucher_create_rarity') < 0.75) and 2 or 3
                local new_card = create_card_ref('Joker', area, legendary, replacement_rarity, skip_materialize, soulable, nil, (key_append or '') .. '_vup')
                if new_card then
                    card:remove()
                    card = new_card
                end
            end
        end

        -- Guarantee no duplicate Jokers appear in shop or packs without Showman
        if not player_has_showman() and (area == G.shop_jokers or (key_append and string.find(key_append, 'sho')) or area == G.pack_cards) then
            local attempts = 0
            while is_joker_owned_by_player(card) and attempts < 10 do
                attempts = attempts + 1
                local cur_rarity = (card.config and card.config.center and card.config.center.rarity) or card.ability.rarity
                local rep_card = create_card_ref('Joker', area, legendary, cur_rarity, skip_materialize, soulable, nil, (key_append or '') .. '_nodup' .. attempts)
                if rep_card then
                    card:remove()
                    card = rep_card
                else
                    break
                end
            end
        end
    end

    return card
end

-- Falta de Lectura activation tracker & Doppelgänger real-time per-activation counter hook
local calculate_joker_ref = Card.calculate_joker
function Card:calculate_joker(context)
    -- Block incompatible Jokers from being copied by Blueprint, Brainstorm, or Chameleon
    if context and context.blueprint and not is_joker_copiable(self) then
        return nil
    end

    if context and (context.ending_shop or context.setting_blind) then
        if G.GAME then G.GAME.dark_alchemy_tag_active = nil end
    end

    -- Doppelgänger: prevent retrigger from activating if this Joker is possessed
    local is_doppel_active = G.GAME and G.GAME.blind and not G.GAME.blind.disabled and 
        (G.GAME.blind.name == 'doppelganger' or G.GAME.blind.name == 'The Doppelgänger' or G.GAME.blind.key == 'b_Witch_brew_doppelganger' or G.GAME.blind.key == 'doppelganger' or (G.GAME.blind.config and G.GAME.blind.config.blind and (G.GAME.blind.config.blind.key == 'doppelganger' or G.GAME.blind.config.blind.key == 'b_Witch_brew_doppelganger')))

    if is_doppel_active and G.GAME.doppelganger_target and self == G.GAME.doppelganger_target then
        if context and context.repetition and not context.doppel_sim then
            return nil
        end
    end

    local ret = calculate_joker_ref(self, context)

    -- Secret Jokers & Amalgams Screen Sparkles
    if not self.debuff and (is_secret_card(self) or is_amalgam_card(self)) then
        if (ret and type(ret) == 'table' and next(ret)) or (context and context.first_hand_drawn) then
            local is_amal = is_amalgam_card(self)
            local colours = is_amal and { HEX('8a2be2'), HEX('4b0082'), HEX('ba55d3'), G.C.WHITE, HEX('9370db') }
                                    or { HEX('ffd700'), HEX('ff69b4'), HEX('00ffff'), HEX('ff00ff'), G.C.WHITE }
            emit_secret_screen_sparkles(colours)
        end
    end

    if ret and type(ret) == 'table' and next(ret) and not self.debuff and context and not context.falta_de_lectura_check then
        local key = (self.config and self.config.center and self.config.center.key) or self.config.center_key or (self.ability and self.ability.name)
        local is_self = (key == 'j_Witch_brew_falta_de_lectura_joker' or key == 'falta_de_lectura_joker' or key == 'j_falta_de_lectura_joker' or key == 'falta_de_lectura')
        if not is_self then
            if context.joker_main or context.individual or context.before or context.repetition then
                if ret.mult or ret.chips or ret.Xmult or ret.x_mult or ret.dollars or ret.x_chips or ret.p_dollars or ret.message or ret.swap then
                    G.GAME.falta_de_lectura_other_activated = true
                end
            end
        end
    end

    -- Doppelgänger real-time per-activation counter hook (inverts mult, chips, and divides xmult)
    if is_doppel_active and G.GAME.doppelganger_target and self == G.GAME.doppelganger_target and ret and type(ret) == 'table' and not self.debuff and context then
        if not context.end_of_round and not context.ending_shop and not context.starting_shop and not context.setting_blind and not context.doppel_sim then
            local modified = false

            -- Invert Mult (adds mult -> subtracts mult)
            if ret.mult and type(ret.mult) == 'number' and ret.mult > 0 then
                local orig_m = ret.mult
                ret.mult = -orig_m
                ret.message = '-' .. tostring(orig_m) .. ' Mult'
                ret.colour = G.C.RED
                modified = true
            end
            if ret.mult_mod and type(ret.mult_mod) == 'number' and ret.mult_mod > 0 then
                local orig_m = ret.mult_mod
                ret.mult_mod = -orig_m
                ret.message = '-' .. tostring(orig_m) .. ' Mult'
                ret.colour = G.C.RED
                modified = true
            end
            if ret.h_mult and type(ret.h_mult) == 'number' and ret.h_mult > 0 then
                local orig_m = ret.h_mult
                ret.h_mult = -orig_m
                ret.message = '-' .. tostring(orig_m) .. ' Mult'
                ret.colour = G.C.RED
                modified = true
            end

            -- Invert Chips (adds chips -> subtracts chips)
            if ret.chips and type(ret.chips) == 'number' and ret.chips > 0 then
                local orig_c = ret.chips
                ret.chips = -orig_c
                ret.message = '-' .. tostring(orig_c) .. ' Chips'
                ret.colour = G.C.CHIPS
                modified = true
            end
            if ret.chip_mod and type(ret.chip_mod) == 'number' and ret.chip_mod > 0 then
                local orig_c = ret.chip_mod
                ret.chip_mod = -orig_c
                ret.message = '-' .. tostring(orig_c) .. ' Chips'
                ret.colour = G.C.CHIPS
                modified = true
            end
            if ret.h_chips and type(ret.h_chips) == 'number' and ret.h_chips > 0 then
                local orig_c = ret.h_chips
                ret.h_chips = -orig_c
                ret.message = '-' .. tostring(orig_c) .. ' Chips'
                ret.colour = G.C.CHIPS
                modified = true
            end

            -- Invert XMult (multiplies -> divides)
            if ret.Xmult and type(ret.Xmult) == 'number' and ret.Xmult > 1 then
                local orig_xm = ret.Xmult
                ret.Xmult = 1 / orig_xm
                ret.message = '/' .. string.format('%.2g', orig_xm) .. ' Mult'
                ret.colour = G.C.RED
                modified = true
            end
            if ret.x_mult and type(ret.x_mult) == 'number' and ret.x_mult > 1 then
                local orig_xm = ret.x_mult
                ret.x_mult = 1 / orig_xm
                ret.message = '/' .. string.format('%.2g', orig_xm) .. ' Mult'
                ret.colour = G.C.RED
                modified = true
            end
            if ret.Xmult_mod and type(ret.Xmult_mod) == 'number' and ret.Xmult_mod > 1 then
                local orig_xm = ret.Xmult_mod
                ret.Xmult_mod = 1 / orig_xm
                ret.message = '/' .. string.format('%.2g', orig_xm) .. ' Mult'
                ret.colour = G.C.RED
                modified = true
            end
            if ret.h_x_mult and type(ret.h_x_mult) == 'number' and ret.h_x_mult > 1 then
                local orig_xm = ret.h_x_mult
                ret.h_x_mult = 1 / orig_xm
                ret.message = '/' .. string.format('%.2g', orig_xm) .. ' Mult'
                ret.colour = G.C.RED
                modified = true
            end

            -- Invert XChips
            if ret.x_chips and type(ret.x_chips) == 'number' and ret.x_chips > 1 then
                local orig_xc = ret.x_chips
                ret.x_chips = 1 / orig_xc
                ret.message = '/' .. string.format('%.2g', orig_xc) .. ' Chips'
                ret.colour = G.C.CHIPS
                modified = true
            end

            -- Invert repetition (block any returned repetition)
            if ret.repetitions then
                ret.repetitions = nil
                modified = true
            end

            if modified then
                ret.card = self
                if G.GAME and G.GAME.blind then
                    G.GAME.blind:juice_up(0.4, 0.4)
                end
                self:juice_up(0.4, 0.4)
                play_sound('blind_chips', 0.8, 0.7)
            end
        end
    end

    return ret
end

-- Hook card_eval_status_text to display negative mult/chips and divisions cleanly
if card_eval_status_text then
    local card_eval_status_text_ref = card_eval_status_text
    function card_eval_status_text(card, eval_type, amt, percent, dir, extra)
        if (eval_type == 'mult' or eval_type == 'h_mult') and type(amt) == 'number' and amt < 0 then
            extra = extra or {}
            extra.message = tostring(amt) .. ' Mult'
            eval_type = 'extra'
        elseif (eval_type == 'chips' or eval_type == 'h_chips') and type(amt) == 'number' and amt < 0 then
            extra = extra or {}
            extra.message = tostring(amt) .. ' Chips'
            eval_type = 'extra'
        elseif (eval_type == 'x_mult' or eval_type == 'h_x_mult') and type(amt) == 'number' and amt < 0.9999 and amt > 0 then
            local div_val = 1 / amt
            extra = extra or {}
            extra.message = '/' .. string.format('%.2g', div_val) .. ' Mult'
            eval_type = 'extra'
        end
        return card_eval_status_text_ref(card, eval_type, amt, percent, dir, extra)
    end
end

-- Dark Alchemy Tag: 10x chance to generate Negative edition in shop and packs
if poll_edition then
    local poll_edition_ref = poll_edition
    function poll_edition(_key, _mod, _no_neg, _guaranteed)
        if G.GAME and G.GAME.dark_alchemy_tag_active then
            local neg_poll = pseudorandom(pseudoseed((_key or 'edition_generic') .. '_dark_alchemy'))
            local neg_rate = 0.03 * (_mod or 1)
            if neg_poll > 1 - neg_rate and not _no_neg then
                return { negative = true }
            end
        end
        return poll_edition_ref(_key, _mod, _no_neg, _guaranteed)
    end
end

-- Doctor Jo rescue hook on Card.start_dissolve
local card_start_dissolve_ref = Card.start_dissolve
function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_sound)
    if self.ability and self.ability.set == 'Joker' and G.jokers and G.jokers.cards then
        local doctor_card = nil
        for _, j in ipairs(G.jokers.cards) do
            local key_j = (j.config and j.config.center and j.config.center.key) or j.config.center_key or j.ability.name
            local is_doctor = (key_j == 'j_Witch_brew_doctor_jo_joker' or key_j == 'doctor_jo_joker' or key_j == 'j_doctor_jo_joker')
            if is_doctor and j ~= self and not j.getting_sliced and not j.debuff then
                doctor_card = j
                break
            end
        end

        if doctor_card then
            local key_self = (self.config and self.config.center and self.config.center.key) or self.config.center_key or self.ability.name
            local incompatible = {
                ['j_Witch_brew_doctor_jo_joker'] = true,
                ['doctor_jo_joker'] = true,
                ['j_doctor_jo_joker'] = true,
                ['j_mr_bones'] = true,
                ['j_luchador'] = true,
                ['j_gros_michel'] = true,
                ['j_cavendish'] = true,
                ['j_ice_cream'] = true,
                ['j_popcorn'] = true,
                ['j_turtle_bean'] = true,
                ['j_ramen'] = true,
                ['j_diet_cola'] = true,
                ['j_invisible'] = true
            }

            if key_self and not incompatible[key_self] then
                doctor_card.getting_sliced = true
                local card_to_copy = self
                G.E_MANAGER:add_event(Event({
                    func = function()
                        doctor_card:start_dissolve()
                        local new_card = copy_card(card_to_copy, nil)
                        
                        new_card.pinned = nil
                        new_card.eternal = nil
                        new_card.perishable = nil
                        new_card.rental = nil
                        new_card.debuff = false
                        new_card.debuffed_by_blind = nil
                        
                        if new_card.ability then
                            new_card.ability.perishable = nil
                            new_card.ability.perishable_tally = nil
                            new_card.ability.rental = nil
                            new_card.ability.eternal = nil
                            new_card.ability.debuff = false
                        end

                        if new_card.set_debuff then
                            new_card:set_debuff(false)
                        end

                        new_card:set_edition({ polychrome = true }, true)
                        new_card:add_to_deck()
                        G.jokers:emplace(new_card)
                        new_card:juice_up(0.8, 0.8)
                        
                        return true
                    end
                }))
            end
        end
    end

    -- Pinza Showdown card destruction check
    if (self.playing_card or (self.ability and (self.ability.set == 'Enhanced' or self.ability.set == 'Default')) or self.base) then
        if G.GAME and G.GAME.blind and (G.GAME.blind.name == 'pinza' or G.GAME.blind.key == 'b_Witch_brew_pinza' or G.GAME.blind.name == 'b_Witch_brew_pinza' or G.GAME.blind.name == 'The Pincer') then
            if not G.GAME.pinza_card_destroyed then
                G.GAME.pinza_card_destroyed = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        if G.jokers and G.jokers.cards then
                            for _, j in ipairs(G.jokers.cards) do
                                j:set_debuff(false)
                                j.debuff = false
                            end
                        end
                        play_sound('tarot2')
                        return true
                    end
                }))
            end
        end
    end

    return card_start_dissolve_ref(self, dissolve_colours, silent, dissolve_time_fac, no_sound)
end


-- Ensure Custom Seals Discovery in UI and Collection and alias keys
function ensure_custom_seals_discovered()
    local seal_groups = {
        { 'silver', 'Witch_brew_silver', 'Witch brew_silver' },
        { 'dark_green', 'Witch_brew_dark_green', 'Witch brew_dark_green' },
        { 'white', 'Witch_brew_white', 'Witch brew_white' }
    }
    if G and G.P_SEALS then
        for _, grp in ipairs(seal_groups) do
            local found = nil
            for _, k in ipairs(grp) do
                if G.P_SEALS[k] then found = G.P_SEALS[k]; break end
            end
            if found then
                for _, k in ipairs(grp) do
                    G.P_SEALS[k] = G.P_SEALS[k] or found
                    G.P_SEALS[k].discovered = true
                    G.P_SEALS[k].unlocked = true
                end
            end
        end
    end
    if SMODS and SMODS.Seals then
        for _, grp in ipairs(seal_groups) do
            local found = nil
            for _, k in ipairs(grp) do
                if SMODS.Seals[k] then found = SMODS.Seals[k]; break end
            end
            if found then
                for _, k in ipairs(grp) do
                    SMODS.Seals[k] = SMODS.Seals[k] or found
                end
            end
        end
    end
    if G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Seal then
        for _, s in ipairs(G.P_CENTER_POOLS.Seal) do
            if s.key and (string.find(s.key, 'dark_green') or string.find(s.key, 'white') or string.find(s.key, 'silver')) then
                s.discovered = true
                s.unlocked = true
            end
        end
    end
end

ensure_custom_seals_discovered()

local card_set_seal_ref = Card.set_seal
function Card:set_seal(_seal, silent, immediate)
    if _seal then
        if _seal == 'silver' or _seal == 'Witch_brew_silver' or _seal == 'Witch brew_silver' then
            _seal = (G.P_SEALS and (G.P_SEALS['Witch_brew_silver'] and 'Witch_brew_silver' or G.P_SEALS['Witch brew_silver'] and 'Witch brew_silver' or G.P_SEALS['silver'] and 'silver')) or 'Witch_brew_silver'
        elseif _seal == 'dark_green' or _seal == 'Witch_brew_dark_green' or _seal == 'Witch brew_dark_green' then
            _seal = (G.P_SEALS and (G.P_SEALS['Witch_brew_dark_green'] and 'Witch_brew_dark_green' or G.P_SEALS['Witch brew_dark_green'] and 'Witch brew_dark_green' or G.P_SEALS['dark_green'] and 'dark_green')) or 'Witch_brew_dark_green'
        elseif _seal == 'white' or _seal == 'Witch_brew_white' or _seal == 'Witch brew_white' then
            _seal = (G.P_SEALS and (G.P_SEALS['Witch_brew_white'] and 'Witch_brew_white' or G.P_SEALS['Witch brew_white'] and 'Witch brew_white' or G.P_SEALS['white'] and 'white')) or 'Witch_brew_white'
        end
    end
    return card_set_seal_ref(self, _seal, silent, immediate)
end

-- Automatically set clean display names on SMODS.Center creation
if SMODS and SMODS.Center and SMODS.Center.register then
    local orig_center_register = SMODS.Center.register
    function SMODS.Center:register()
        if not self.name and self.loc_txt and self.loc_txt.name then
            self.name = self.loc_txt.name
            self.label = self.loc_txt.name
        end
        orig_center_register(self)
        if self.loc_txt and self.loc_txt.name then
            self.name = self.loc_txt.name
            self.label = self.loc_txt.name
            self.mod_name = "Witch Brew"
        end
    end
end

-- Universal center aliasing and clean display name normalization for Witcher Brew centers
function alias_all_witch_brew_centers()
    if G and G.P_CENTERS then
        -- Provide transparent metatable index fallback so 'Witch brew' accesses resolve without creating duplicate keys
        local mt = getmetatable(G.P_CENTERS)
        if not mt then
            mt = {}
            setmetatable(G.P_CENTERS, mt)
        end
        if not mt._witch_brew_fallback then
            local orig_index = mt.__index
            mt.__index = function(t, k)
                if orig_index then
                    local res = type(orig_index) == 'function' and orig_index(t, k) or orig_index[k]
                    if res ~= nil then return res end
                end
                if type(k) == 'string' and string.find(k, 'Witch brew') then
                    local clean_k = string.gsub(k, 'Witch brew', 'Witch_brew')
                    return rawget(t, clean_k)
                end
                return nil
            end
            mt._witch_brew_fallback = true
        end

        -- Purge duplicate alias keys that cause cards to appear twice in game data and collection
        for k, v in pairs(G.P_CENTERS) do
            if type(k) == 'string' then
                if string.find(k, 'Witch brew_') then
                    G.P_CENTERS[k] = nil
                elseif type(v) == 'table' and string.find(k, 'Witch_brew_') then
                    local clean_name = (v.loc_txt and v.loc_txt.name)
                    if not clean_name and G.localization and G.localization.descriptions then
                        local set_desc = G.localization.descriptions[v.set or 'Joker']
                        if set_desc and set_desc[k] and set_desc[k].name then
                            clean_name = set_desc[k].name
                        elseif set_desc and v.key and set_desc[v.key] and set_desc[v.key].name then
                            clean_name = set_desc[v.key].name
                        end
                    end
                    if clean_name then
                        v.name = clean_name
                        v.label = clean_name
                        v.mod_name = "Witch Brew"
                    end
                end
            end
        end
    end

    if SMODS and SMODS.Centers then
        for k, v in pairs(SMODS.Centers) do
            if type(k) == 'string' then
                if string.find(k, 'Witch brew_') then
                    SMODS.Centers[k] = nil
                elseif type(v) == 'table' and string.find(k, 'Witch_brew_') then
                    local clean_name = (v.loc_txt and v.loc_txt.name) or (v.name and not string.find(v.name, '^[jvc]_') and v.name)
                    if clean_name then
                        v.name = clean_name
                        v.label = clean_name
                        v.mod_name = "Witch Brew"
                    end
                end
            end
        end
    end

    if SMODS and SMODS.Jokers then
        for k, v in pairs(SMODS.Jokers) do
            if type(k) == 'string' then
                if string.find(k, 'Witch brew_') then
                    SMODS.Jokers[k] = nil
                elseif type(v) == 'table' and string.find(k, 'Witch_brew_') then
                    local clean_name = (v.loc_txt and v.loc_txt.name) or (v.name and not string.find(v.name, '^[jvc]_') and v.name)
                    if clean_name then
                        v.name = clean_name
                        v.label = clean_name
                        v.mod_name = "Witch Brew"
                    end
                end
            end
        end
    end

    -- Deduplicate G.P_CENTER_POOLS to ensure no card appears twice in any pool or collection
    if G and G.P_CENTER_POOLS then
        for _, pool in pairs(G.P_CENTER_POOLS) do
            if type(pool) == 'table' then
                local seen = {}
                for i = #pool, 1, -1 do
                    local c = pool[i]
                    local k = c and (c.key or c.name)
                    if k then
                        local norm_k = string.gsub(k, 'Witch brew', 'Witch_brew')
                        if string.find(k, 'Witch brew_') or seen[norm_k] then
                            table.remove(pool, i)
                        else
                            seen[norm_k] = true
                        end
                    end
                end
            end
        end
    end
end

-- Hook localize to guarantee clean names when any menu queries by key or object
if localize then
    local orig_localize = localize
    function localize(args, misc_cat)
        if args and type(args) == 'table' and args.type == 'name_text' and args.key then
            local key = tostring(args.key)
            if string.find(key, 'Witch_brew') or string.find(key, 'Witch brew') or string.find(key, 'witch_brew') then
                local c = G.P_CENTERS and (G.P_CENTERS[key] or G.P_CENTERS['j_' .. key] or G.P_CENTERS[string.gsub(key, 'Witch brew', 'Witch_brew')])
                if c and c.loc_txt and c.loc_txt.name then
                    return c.loc_txt.name
                end
                if c and c.name and not string.find(c.name, '^[jvc]_') and not string.find(c.name, 'Witch_brew') and not string.find(c.name, 'Witch brew') then
                    return c.name
                end
                if G.localization and G.localization.descriptions then
                    local set = args.set or (c and c.set) or 'Joker'
                    local set_desc = G.localization.descriptions[set]
                    if set_desc then
                        local entry = set_desc[key] or set_desc['j_' .. key] or set_desc[string.gsub(key, 'Witch brew', 'Witch_brew')]
                        if entry and entry.name then
                            return entry.name
                        end
                    end
                end
            end
        end
        return orig_localize(args, misc_cat)
    end
end

local card_load_ref = Card.load
function Card:load(cardTable, other_card)
    alias_all_witch_brew_centers()
    if cardTable then
        if cardTable.save_fields then
            for k, v in pairs(cardTable.save_fields) do
                if type(v) == 'string' and string.find(v, 'Witch brew') then
                    cardTable.save_fields[k] = string.gsub(v, 'Witch brew', 'Witch_brew')
                end
            end
        end
        if type(cardTable.label) == 'string' and string.find(cardTable.label, 'Witch brew') then
            cardTable.label = string.gsub(cardTable.label, 'Witch brew', 'Witch_brew')
        end
    end
    return card_load_ref(self, cardTable, other_card)
end

-- Masterful Joker: Mastered ranks count as any suit
local card_is_suit_ref = Card.is_suit
function Card:is_suit(suit, bypass_debuff, flush_calc)
    if G and G.jokers and G.jokers.cards then
        for _, j in ipairs(G.jokers.cards) do
            if card_has_key(j, 'masterful_joker') and not j.debuff then
                if j.ability and j.ability.extra and j.ability.extra.mastered_ranks then
                    local rank = self.base and self.base.value
                    if rank and j.ability.extra.mastered_ranks[rank] then
                        return true
                    end
                end
            end
        end
    end
    return card_is_suit_ref(self, suit, bypass_debuff, flush_calc)
end

local function is_probability_seed(seed)
    if type(seed) ~= 'string' then return false end
    local s = string.lower(seed)
    local prob_seeds = {
        wheel_of_fortune = true, lucky_mult = true, lucky_money = true,
        space_joker = true, bloodstone = true, business = true,
        hallucination = true, gros_michel = true, cavendish = true,
        glass = true, ['8_ball'] = true, eight_ball = true,
        contratado = true, injured_joker = true, squele_project = true,
        perfectionism_neg = true, discord_tag = true, blacksmith_reward = true,
    }
    if prob_seeds[s] then return true end
    if string.find(s, 'prob') or string.find(s, 'chance') or string.find(s, 'luck')
       or string.find(s, 'wheel') or string.find(s, 'odds') or string.find(s, 'roll') then
        return true
    end
    return false
end

-- Lucky One: Guaranteed success on next probability roll using stored charges or guaranteed flag
local pseudorandom_ref = pseudorandom
function pseudorandom(seed, min, max)
    if not min and not max then
        if G.GAME and G.GAME.lucky_one_guaranteed then
            G.GAME.lucky_one_guaranteed = false
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    if not j.debuff and (card_has_key(j, 'lucky_one') or card_has_key(j, 'lucky_one_joker')) then
                        card_eval_status_text(j, 'extra', nil, nil, nil, { message = 'Guaranteed!', colour = G.C.GREEN })
                        j:juice_up(0.5, 0.5)
                    end
                end
            end
            return 0
        end
        if is_probability_seed(seed) and G and G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if (card_has_key(j, 'lucky_one_joker') or card_has_key(j, 'lucky_one')) and not j.debuff then
                    if j.ability and j.ability.extra and (j.ability.extra.charges or 0) > 0 then
                        j.ability.extra.charges = j.ability.extra.charges - 1
                        j.ability.extra.xmult = (j.ability.extra.xmult or 1.5) + (j.ability.extra.xmult_gain or 0.1)
                        card_eval_status_text(j, 'extra', nil, nil, nil, {
                            message = 'Guaranteed! (' .. j.ability.extra.charges .. '/5)',
                            colour = G.C.GREEN
                        })
                        play_sound('tarot1')
                        return 0.0000000001
                    end
                end
            end
        end
    end
    return pseudorandom_ref(seed, min, max)
end

-- ==========================================
-- SPECTRAL SHATTER & CLEANUP SYSTEM
-- ==========================================

function Card:spectral_shatter()
    local dissolve_time = 0.8
    self.shattered = true
    self.destroyed = true
    self.dissolve = 0
    self.dissolve_colours = {
        HEX('1b4d2e'),              -- Dark green
        HEX('2dd4bf'),              -- Spectral teal
        G.C.SECONDARY_SET.Spectral, -- Spectral blue
        {1, 1, 1, 0.95}             -- Ethereal white glimmer
    }
    self:juice_up(0.8, 0.5)

    -- Pinza Showdown card destruction check
    if G.GAME and G.GAME.blind and (G.GAME.blind.name == 'pinza' or G.GAME.blind.key == 'b_Witch_brew_pinza' or G.GAME.blind.name == 'b_Witch_brew_pinza' or G.GAME.blind.name == 'The Pincer') then
        if not G.GAME.pinza_card_destroyed then
            G.GAME.pinza_card_destroyed = true
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    if G.jokers and G.jokers.cards then
                        for _, j in ipairs(G.jokers.cards) do
                            j:set_debuff(false)
                            j.debuff = false
                        end
                    end
                    play_sound('tarot2')
                    return true
                end
            }))
        end
    end

    local childParts = Particles(0, 0, 0, 0, {
        timer_type = 'TOTAL',
        timer = 0.005 * dissolve_time,
        scale = 0.35,
        speed = 3.5,
        lifespan = 0.6 * dissolve_time,
        attach = self,
        colours = self.dissolve_colours,
        fill = true
    })

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        blockable = false,
        delay = 0.5 * dissolve_time,
        func = function()
            childParts:fade(0.2 * dissolve_time)
            return true
        end
    }))

    G.E_MANAGER:add_event(Event({
        blockable = false,
        func = function()
            -- Spectral shattered sound effect
            play_sound('magic_crumple' .. math.random(2, 3), 1.15 + math.random() * 0.1, 0.85)
            play_sound('whoosh2', 0.85, 0.7)
            play_sound('tarot2', 1.25, 0.6)
            play_sound('glass' .. math.random(1, 6), 1.4 + math.random() * 0.2, 0.45)
            play_sound('slice1', 1.1, 0.5)
            return true
        end
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'ease',
        blockable = false,
        ref_table = self,
        ref_value = 'dissolve',
        ease_to = 1,
        delay = 0.6 * dissolve_time,
        func = function(t) return t end
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        blockable = false,
        delay = 0.65 * dissolve_time,
        func = function()
            self:remove()
            -- Comprehensive purge to prevent any ghost card in any area
            if G.play and G.play.cards then
                for i = #G.play.cards, 1, -1 do
                    if G.play.cards[i] == self then
                        table.remove(G.play.cards, i)
                    end
                end
            end
            if G.hand and G.hand.cards then
                for i = #G.hand.cards, 1, -1 do
                    if G.hand.cards[i] == self then
                        table.remove(G.hand.cards, i)
                    end
                end
                G.hand:set_ranks()
                G.hand:align_cards()
            end
            if G.deck and G.deck.cards then
                for i = #G.deck.cards, 1, -1 do
                    if G.deck.cards[i] == self then
                        table.remove(G.deck.cards, i)
                    end
                end
            end
            if G.discard and G.discard.cards then
                for i = #G.discard.cards, 1, -1 do
                    if G.discard.cards[i] == self then
                        table.remove(G.discard.cards, i)
                    end
                end
            end
            if G.playing_cards then
                for i = #G.playing_cards, 1, -1 do
                    if G.playing_cards[i] == self then
                        table.remove(G.playing_cards, i)
                    end
                end
                for k, v in ipairs(G.playing_cards) do
                    v.playing_card = k
                end
            end
            return true
        end
    }))
end

-- Helper to purge any corrupted/ghost cards from hand or deck
function purge_witch_brew_ghost_cards()
    if G.hand and G.hand.cards then
        local removed_any = false
        for i = #G.hand.cards, 1, -1 do
            local c = G.hand.cards[i]
            if c.shattered or c.destroyed or c.removed or (c.dissolve and c.dissolve >= 1) then
                table.remove(G.hand.cards, i)
                removed_any = true
            end
        end
        if removed_any then
            G.hand:set_ranks()
            G.hand:align_cards()
        end
    end
    if G.deck and G.deck.cards then
        for i = #G.deck.cards, 1, -1 do
            local c = G.deck.cards[i]
            if c.shattered or c.destroyed or c.removed or (c.dissolve and c.dissolve >= 1) then
                table.remove(G.deck.cards, i)
            end
        end
    end
    if G.play and G.play.cards then
        for i = #G.play.cards, 1, -1 do
            local c = G.play.cards[i]
            if c.removed then
                table.remove(G.play.cards, i)
            end
        end
    end
end

-- Shatter hook for Glass and Spectral cards breaking
if Card.shatter then
    local card_shatter_ref = Card.shatter
    function Card:shatter()
        if (self.seal and (self.seal == 'dark_green' or self.seal == 'Witch_brew_dark_green')) or self.dark_green_broken then
            return self:spectral_shatter()
        end
        if G.GAME and G.GAME.blind and (G.GAME.blind.name == 'pinza' or G.GAME.blind.key == 'b_Witch_brew_pinza' or G.GAME.blind.name == 'b_Witch_brew_pinza' or G.GAME.blind.name == 'The Pincer') then
            if not G.GAME.pinza_card_destroyed then
                G.GAME.pinza_card_destroyed = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        if G.jokers and G.jokers.cards then
                            for _, j in ipairs(G.jokers.cards) do
                                j:set_debuff(false)
                                j.debuff = false
                            end
                        end
                        play_sound('tarot2')
                        return true
                    end
                }))
            end
        end
        return card_shatter_ref(self)
    end
end

-- =========================================================
-- BOSS BLINDS DEBUFF & INVALID HAND WARNING SYSTEM
-- =========================================================

function is_witch_brew_blind(blind, target_key)
    if not blind then return false end
    local k = (blind.config and blind.config.blind and (blind.config.blind.key or blind.config.blind.name))
              or (blind.config and blind.config.center and (blind.config.center.key or blind.config.center.name))
              or blind.key or blind.name or ''
    k = string.gsub(k, '^bl_Witch_brew_', '')
    k = string.gsub(k, '^b_Witch_brew_', '')
    k = string.gsub(k, '^bl_', '')
    k = string.gsub(k, '^b_', '')
    if target_key then
        return k == target_key or string.find(string.lower(k), string.lower(target_key)) ~= nil
    end
    return k
end

function clear_witch_brew_phone_debuffs()
    local areas = { G.hand, G.play, G.deck, G.discard }
    for _, area in ipairs(areas) do
        if area and area.cards then
            for _, c in ipairs(area.cards) do
                if c.debuffed_by_phone then
                    c:set_debuff(false)
                    c.debuffed_by_phone = nil
                end
            end
        end
    end
    if G.playing_cards then
        for _, c in ipairs(G.playing_cards) do
            if c.debuffed_by_phone then
                c:set_debuff(false)
                c.debuffed_by_phone = nil
            end
        end
    end
end

-- Hook Blind:debuff_hand to enable native Balatro invalid-hand warning (like The Psychic)
-- and completely prevent Jokers and card scoring from activating.
if Blind and Blind.debuff_hand then
    local debuff_hand_ref = Blind.debuff_hand
    function Blind:debuff_hand(cards, hand, handname, check)
        if self.disabled then
            return debuff_hand_ref(self, cards, hand, handname, check)
        end

        local debuffed = false

        -- 1. The Mountain: Consumables disable scoring on the next hand
        if is_witch_brew_blind(self, 'mountain') then
            if G.GAME and G.GAME.mountain_disabled_hand then
                if not check then
                    G.GAME.mountain_disabled_hand = nil
                end
                debuffed = true
            end
        -- 2. The Door: Hands with odd number of cards (1, 3, 5) do not score
        elseif is_witch_brew_blind(self, 'door') then
            if cards and #cards > 0 and (#cards % 2 ~= 0) then
                debuffed = true
            end
        -- 3. The Triangle: Hands with even number of cards (2, 4) do not score
        elseif is_witch_brew_blind(self, 'triangle') then
            if cards and #cards > 0 and (#cards % 2 == 0) then
                debuffed = true
            end
        -- 4. The Guitar: Hands containing 5 cards do not score
        elseif is_witch_brew_blind(self, 'guitar') then
            if cards and #cards == 5 then
                debuffed = true
            end
        end

        -- Check custom debuff_hand on the blind definition if not already matched
        if not debuffed and self.config and self.config.blind and type(self.config.blind.debuff_hand) == 'function' then
            if self.config.blind.debuff_hand(self, cards, hand, handname, check) then
                debuffed = true
            end
        end

        if debuffed then
            self.triggered = true
            if not check then
                G.GAME.witch_brew_hand_debuffed = true
            end
            return true
        end

        return debuff_hand_ref(self, cards, hand, handname, check)
    end
end

-- Hook Blind:get_loc_debuff_text to provide clean descriptive text in the floating warning UIBox
if Blind and Blind.get_loc_debuff_text then
    local get_loc_debuff_text_ref = Blind.get_loc_debuff_text
    function Blind:get_loc_debuff_text()
        if is_witch_brew_blind(self, 'door') then
            return (self.loc_debuff_text and self.loc_debuff_text ~= '') and self.loc_debuff_text or "Hands with odd number of cards do not score"
        end
        if is_witch_brew_blind(self, 'triangle') then
            return (self.loc_debuff_text and self.loc_debuff_text ~= '') and self.loc_debuff_text or "Hands with even number of cards do not score"
        end
        if is_witch_brew_blind(self, 'guitar') then
            return (self.loc_debuff_text and self.loc_debuff_text ~= '') and self.loc_debuff_text or "Hands containing 5 cards do not score"
        end
        if is_witch_brew_blind(self, 'mountain') then
            return (self.loc_debuff_text and self.loc_debuff_text ~= '') and self.loc_debuff_text or "Using consumables disables scoring on the next hand"
        end
        if is_witch_brew_blind(self, 'wizard') then
            return (self.loc_debuff_text and self.loc_debuff_text ~= '') and self.loc_debuff_text or "All Enhanced cards are debuffed"
        end
        return get_loc_debuff_text_ref(self)
    end
end

-- Hook Blind:debuff_card for custom blind debuffs (The Magician / wizard)
if Blind and Blind.debuff_card then
    local debuff_card_ref = Blind.debuff_card
    function Blind:debuff_card(card, from_blind)
        if not self.disabled and is_witch_brew_blind(self, 'wizard') then
            if card and card.area ~= G.jokers then
                local is_enhanced = (card.ability and card.ability.set == 'Enhanced') or
                                   (card.config and card.config.center and card.config.center.set == 'Enhanced') or
                                   (card.config and card.config.center_key and G.P_CENTERS and G.P_CENTERS[card.config.center_key] and G.P_CENTERS[card.config.center_key].set == 'Enhanced')
                if is_enhanced then
                    card:set_debuff(true)
                    return true
                end
            end
        end
        return debuff_card_ref(self, card, from_blind)
    end
end

-- Hook CardArea:parse_highlighted to dynamically show invalid cards for The Phone in real time
if CardArea and CardArea.parse_highlighted then
    local parse_highlighted_ref = CardArea.parse_highlighted
    function CardArea:parse_highlighted()
        if self == G.hand and G.GAME and G.GAME.blind and is_witch_brew_blind(G.GAME.blind, 'phone') and not G.GAME.blind.disabled then
            -- Reset previous phone debuffs in hand first
            if self.cards then
                for _, c in ipairs(self.cards) do
                    if c.debuffed_by_phone then
                        c:set_debuff(false)
                        c.debuffed_by_phone = nil
                    end
                end
            end

            -- Highlighted cards: only 1st scoring card is valid, subsequent scoring cards are visibly debuffed
            if self.highlighted and #self.highlighted > 0 and G.FUNCS and G.FUNCS.get_poker_hand_info then
                local text, disp_text, poker_hands, scoring_hand = G.FUNCS.get_poker_hand_info(self.highlighted)
                if scoring_hand and #scoring_hand > 1 then
                    for i = 2, #scoring_hand do
                        scoring_hand[i]:set_debuff(true)
                        scoring_hand[i].debuffed_by_phone = true
                    end
                end
            end
        else
            if self == G.hand and self.cards then
                for _, c in ipairs(self.cards) do
                    if c.debuffed_by_phone then
                        c:set_debuff(false)
                        c.debuffed_by_phone = nil
                    end
                end
            end
        end

        return parse_highlighted_ref(self)
    end
end


-- Helper to detect Lead Card
function is_lead_card(card)
    if not card then return false end
    if card.config and card.config.center then
        local k = card.config.center.key
        if k == 'lead' or k == 'm_Witch_brew_lead' or k == 'm_lead' then return true end
    end
    if SMODS and SMODS.has_enhancement and SMODS.has_enhancement(card, 'lead') then return true end
    if card.ability and (card.ability.name == 'Lead Card' or card.ability.effect == 'Lead Card') then return true end
    return false
end

-- Transmute Lead Card randomly to Gold, Shiny, or Metal
function transmute_lead_card(card)
    if not card or not is_lead_card(card) or card.destroyed or card.shattered then return false end

    local pool = {
        { center = G.P_CENTERS.m_gold, msg = 'Transmuted to Gold!', colour = G.C.GOLD },
        { center = get_diamond_enhancement_center() or G.P_CENTERS.m_gold, msg = 'Transmuted to Shiny!', colour = HEX('1b4d2e') },
        { center = G.P_CENTERS.m_steel, msg = 'Transmuted to Metal!', colour = G.C.GREY }
    }
    local chosen = pseudorandom_element(pool, pseudoseed('lead_transmute')) or pool[math.random(1, #pool)]

    if chosen and chosen.center then
        card:set_ability(chosen.center)
        card:juice_up()
        card_eval_status_text(card, 'extra', nil, nil, nil, { message = chosen.msg, colour = chosen.colour })
        play_sound('tarot1', 1.0, 0.6)
        return true
    end
    return false
end

-- Evaluates if score exceeds Blind requirement and transmutes eligible Lead cards
function check_and_transmute_lead_cards(cards)
    local blind_req = (G.GAME and G.GAME.blind and G.GAME.blind.chips) or 0
    local current_chips = (G.GAME and G.GAME.chips) or 0
    if blind_req > 0 and current_chips >= blind_req then
        local list = cards or (G.play and G.play.cards) or {}
        for _, c in ipairs(list) do
            if is_lead_card(c) and not c.destroyed and not c.shattered and not c.lead_transmuted_this_round then
                c.lead_transmuted_this_round = true
                transmute_lead_card(c)
            end
        end
    end
end

-- Hook draw_from_play_to_discard for Spectral Shatter, debuff cleanup & ghost card purging
if G and G.FUNCS and G.FUNCS.draw_from_play_to_discard then
    local draw_from_play_to_discard_ref = G.FUNCS.draw_from_play_to_discard
    G.FUNCS.draw_from_play_to_discard = function(e)
        local broken_cards = {}
        if G.play and G.play.cards then
            for _, c in ipairs(G.play.cards) do
                c.dark_green_scored_this_hand = nil
                if c.dark_green_broken then
                    broken_cards[#broken_cards + 1] = c
                end
            end
        end

        if #broken_cards > 0 then
            -- Notify jokers that cards are destroyed
            if G.jokers and G.jokers.cards then
                for j = 1, #G.jokers.cards do
                    eval_card(G.jokers.cards[j], { cardarea = G.jokers, remove_playing_cards = true, removed = broken_cards })
                end
            end
            check_for_unlock{ type = 'shatter', shattered = broken_cards }

            -- Trigger spectral shatter for each broken card
            for _, c in ipairs(broken_cards) do
                c.shattered = true
                c.destroyed = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        card_eval_status_text(c, 'extra', nil, nil, nil, { message = 'Shattered!', colour = HEX('1b4d2e') })
                        c:spectral_shatter()
                        return true
                    end
                }))
            end
        end

        -- Transmute Lead Cards if played in a hand that meets or exceeds Blind requirement
        check_and_transmute_lead_cards(G.play and G.play.cards)

        if G.GAME then
            G.GAME.round_lead_scored = nil
        end

        -- Clean up debuff flags and ghost cards
        if G.GAME then
            G.GAME.witch_brew_hand_debuffed = nil
        end
        clear_witch_brew_phone_debuffs()
        purge_witch_brew_ghost_cards()

        return draw_from_play_to_discard_ref(e)
    end
end

-- Hook end_round as a fallback safety for Lead Card transmutation
if end_round then
    local end_round_lead_ref = end_round
    function end_round()
        local cards_to_check = (SMODS and SMODS.last_hand and SMODS.last_hand.scoring_hand) or (G.play and G.play.cards) or {}
        check_and_transmute_lead_cards(cards_to_check)
        return end_round_lead_ref()
    end
end

-- Hook draw_from_deck_to_hand as an extra safety measure to clear any ghost cards & reset flags
if G and G.FUNCS and G.FUNCS.draw_from_deck_to_hand then
    local draw_from_deck_to_hand_ref = G.FUNCS.draw_from_deck_to_hand
    G.FUNCS.draw_from_deck_to_hand = function(e)
        purge_witch_brew_ghost_cards()
        if G.GAME then
            G.GAME.witch_brew_hand_debuffed = nil
        end
        clear_witch_brew_phone_debuffs()
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                c.dark_green_scored_this_hand = nil
            end
        end
        return draw_from_deck_to_hand_ref(e)
    end
end


-- Hook G.UIDEF.use_and_sell_buttons for Slot Machine (Apostar) and Injured Joker (Transformaciones)
if G and G.UIDEF and G.UIDEF.use_and_sell_buttons then
    local use_and_sell_buttons_ref = G.UIDEF.use_and_sell_buttons
    G.UIDEF.use_and_sell_buttons = function(card)
        local base_background = use_and_sell_buttons_ref(card)
        if not card or card.area ~= G.jokers or G.STATE == G.STATES.TUTORIAL then
            return base_background
        end
        if not base_background or not base_background.nodes or not base_background.nodes[1] or not base_background.nodes[1].nodes then
            return base_background
        end

        local is_es = G.Witch_brew_SPANISH == true
            -- Slot Machine "Bet" button
            if card_has_key(card, 'slot_machine') then
                local bet_text = is_es and "Apostar" or "Bet"
                table.insert(base_background.nodes[1].nodes, {
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
                                        button = 'slot_machine_bet',
                                        func = 'can_slot_machine_bet'
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
                                                        { n = G.UIT.T, config = { text = bet_text, colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true } }
                                                    }
                                                },
                                                {
                                                    n = G.UIT.R,
                                                    config = { align = "cm" },
                                                    nodes = {
                                                        { n = G.UIT.T, config = { text = "$5", colour = G.C.WHITE, scale = 0.55, shadow = true } }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            end

            -- Injured Joker button to view roster
            if card_has_key(card, 'lesionado') or card_has_key(card, 'injured') then
                local transforms_text = is_es and "Transformaciones" or "Transforms"
                table.insert(base_background.nodes[1].nodes, {
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
                                        colour = G.C.BLUE,
                                        one_press = true,
                                        button = 'injured_show_roster'
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
                                                        { n = G.UIT.T, config = { text = transforms_text, colour = G.C.WHITE, scale = 0.32, shadow = true } }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            end

        return base_background
    end
end

-- Button callbacks
if G and G.FUNCS then
    G.FUNCS.can_slot_machine_bet = function(e)
        local card = e.config.ref_table
        if card and card.ability and card.ability.extra then
            local cur_d = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
            if card.ability.extra.bet_placed then
                e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                e.config.button = nil
            elseif cur_d >= 5 and G.STATE == G.STATES.SELECTING_HAND then
                e.config.colour = G.C.GOLD
                e.config.button = 'slot_machine_bet'
            else
                e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                e.config.button = nil
            end
        end
    end

    G.FUNCS.slot_machine_bet = function(e)
        local card = e.config.ref_table
        local cur_d = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
        if card and card.ability and card.ability.extra and not card.ability.extra.bet_placed and cur_d >= 5 then
            ease_dollars(-5)
            card.ability.extra.bet_placed = true
            card.ability.extra.bet_amount = 5
            card.ability.extra.challenge_completed = false
            card:juice_up(0.5, 0.5)
            play_sound('coin1')
            local bet_msg = (G.Witch_brew_SPANISH == true) and "¡Apostado $5!" or "Bet $5!"
            attention_text({
                text = bet_msg,
                scale = 0.9,
                hold = 1.0,
                major = card,
                backdrop_colour = G.C.GOLD,
                align = 'cm',
                silent = true
            })
            if e.UIBox then e.UIBox:recalculate(true) end
        end
    end

    G.FUNCS.injured_show_roster = function(e)
        if create_UIBox_generic_options and G.FUNCS.overlay_menu then
            local is_es = (G.Witch_brew_SPANISH == true)
            local title = is_es and "Transformaciones de Injured Joker" or "Injured Joker Transformations"
            local subtitle = is_es and "Al final de la ronda (1 en 5 prob.) puede transformarse en:" or "At end of round (1 in 5 chance) can transform into:"
            local quote_rock = is_es and " - \"A rockear!\"" or " - \"Let's rock!\""
            local quote_curse = is_es and " - \"Maldito!\"" or " - \"Cursed!\""

            local t = create_UIBox_generic_options({
                back_func = 'exit_overlay_menu',
                contents = {
                    {n = G.UIT.R, config = {align = "cm", padding = 0.2}, nodes = {
                        {n = G.UIT.T, config = {text = title, scale = 0.6, colour = G.C.GOLD, shadow = true}}
                    }},
                    {n = G.UIT.R, config = {align = "cm", padding = 0.1}, nodes = {
                        {n = G.UIT.T, config = {text = subtitle, scale = 0.4, colour = G.C.WHITE}}
                    }},
                    {n = G.UIT.R, config = {align = "cm", padding = 0.15, colour = G.C.L_BLACK, r = 0.1}, nodes = {
                        {n = G.UIT.C, config = {align = "cl", padding = 0.1}, nodes = {
                            {n = G.UIT.R, config = {align = "cl", padding = 0.04}, nodes = {
                                {n = G.UIT.T, config = {text = "• Motorized Joker", scale = 0.42, colour = G.C.ORANGE}},
                                {n = G.UIT.T, config = {text = quote_rock, scale = 0.35, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                            {n = G.UIT.R, config = {align = "cl", padding = 0.04}, nodes = {
                                {n = G.UIT.T, config = {text = "• Stuntman", scale = 0.42, colour = G.C.ORANGE}},
                                {n = G.UIT.T, config = {text = quote_rock, scale = 0.35, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                            {n = G.UIT.R, config = {align = "cl", padding = 0.04}, nodes = {
                                {n = G.UIT.T, config = {text = "• Invisible Joker", scale = 0.42, colour = G.C.RED}},
                                {n = G.UIT.T, config = {text = quote_curse, scale = 0.35, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                            {n = G.UIT.R, config = {align = "cl", padding = 0.04}, nodes = {
                                {n = G.UIT.T, config = {text = "• Mr. Bones", scale = 0.42, colour = G.C.RED}},
                                {n = G.UIT.T, config = {text = quote_curse, scale = 0.35, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                            {n = G.UIT.R, config = {align = "cl", padding = 0.04}, nodes = {
                                {n = G.UIT.T, config = {text = "• Vampire", scale = 0.42, colour = G.C.RED}},
                                {n = G.UIT.T, config = {text = quote_curse, scale = 0.35, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                            {n = G.UIT.R, config = {align = "cl", padding = 0.04}, nodes = {
                                {n = G.UIT.T, config = {text = "• Joker Stencil", scale = 0.42, colour = G.C.PURPLE}},
                                {n = G.UIT.T, config = {text = " - \"?\"", scale = 0.35, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                        }}
                    }}
                }
            })
            G.FUNCS.overlay_menu{definition = t}
        end
    end
end

-- =========================================================================
-- CONFIG SYSTEM INTEGRATION & ENGINE HOOKS
-- =========================================================================

function is_witch_brew_spectrals_jobs_enabled()
    -- Check run-specific variable so ongoing runs are NOT affected by mid-run config changes
    if G and G.GAME and G.GAME.witch_brew_spectrals_jobs ~= nil then
        return G.GAME.witch_brew_spectrals_jobs
    end
    -- Fallback to mod config
    local cfg = (get_witch_brew_config and get_witch_brew_config())
        or (SMODS and SMODS.Mods and SMODS.Mods['Witch_brew'] and SMODS.Mods['Witch_brew'].config)
        or (SMODS and SMODS.current_mod and SMODS.current_mod.config)
        or {}
    if cfg.new_spectrals_and_jobs ~= nil then
        return cfg.new_spectrals_and_jobs
    end
    return true
end

function is_witch_brew_boss_blinds_enabled()
    if G and G.GAME and G.GAME.witch_brew_boss_blinds ~= nil then
        return G.GAME.witch_brew_boss_blinds
    end
    local cfg = (get_witch_brew_config and get_witch_brew_config())
        or (SMODS and SMODS.Mods and SMODS.Mods['Witch_brew'] and SMODS.Mods['Witch_brew'].config)
        or (SMODS and SMODS.current_mod and SMODS.current_mod.config)
        or {}
    if cfg.new_boss_blinds ~= nil then
        return cfg.new_boss_blinds
    end
    return true
end

function is_witch_brew_fast_animations_enabled()
    local cfg = (get_witch_brew_config and get_witch_brew_config())
        or (SMODS and SMODS.Mods and SMODS.Mods['Witch_brew'] and SMODS.Mods['Witch_brew'].config)
        or (SMODS and SMODS.current_mod and SMODS.current_mod.config)
        or {}
    return cfg.fast_animations == true
end

-- Hook SMODS.Blind.in_pool to disable Witch_Brew Boss Blinds when toggled off
if SMODS and SMODS.Blind then
    local orig_blind_in_pool = SMODS.Blind.in_pool
    function SMODS.Blind:in_pool(args)
        if (self.mod and self.mod.id == 'Witch_brew') or (self.key and G.Witch_brew_BLIND_THEMES and G.Witch_brew_BLIND_THEMES[self.key]) then
            if not is_witch_brew_boss_blinds_enabled() then
                return false
            end
        end
        if orig_blind_in_pool then
            return orig_blind_in_pool(self, args)
        end
        return true
    end
end

-- Hook Game:init_game_object for "New Runs" seed variation and "New Spectrals Y Job Cards" run-lock
if Game and Game.init_game_object then
    local orig_game_init_game_object = Game.init_game_object
    function Game:init_game_object(args)
        local ret = orig_game_init_game_object(self, args)
        local cfg = (get_witch_brew_config and get_witch_brew_config())
            or (SMODS and SMODS.Mods and SMODS.Mods['Witch_brew'] and SMODS.Mods['Witch_brew'].config)
            or (SMODS and SMODS.current_mod and SMODS.current_mod.config)
            or {}

        -- Lock in spectrals & jobs setting for this run (does not affect runs in progress)
        if self.GAME and self.GAME.witch_brew_spectrals_jobs == nil then
            self.GAME.witch_brew_spectrals_jobs = (cfg.new_spectrals_and_jobs ~= false)
        end

        -- Lock in custom boss blinds setting for this run
        if self.GAME and self.GAME.witch_brew_boss_blinds == nil then
            self.GAME.witch_brew_boss_blinds = (cfg.new_boss_blinds ~= false)
        end

        -- New Runs: when active, seeds generate different outcomes/variations between mod and vanilla Balatro
        if cfg.new_runs and self.GAME and self.GAME.pseudorandom and self.GAME.pseudorandom.seed then
            local mod_salt = "_WITCH"
            if not string.find(self.GAME.pseudorandom.seed, mod_salt, 1, true) then
                self.GAME.pseudorandom.seed = self.GAME.pseudorandom.seed .. mod_salt
                if pseudohash then
                    self.GAME.pseudorandom.hashed_seed = pseudohash(self.GAME.pseudorandom.seed)
                    for k, _ in pairs(self.GAME.pseudorandom) do
                        if k ~= 'seed' and k ~= 'hashed_seed' then
                            self.GAME.pseudorandom[k] = pseudohash(k .. self.GAME.pseudorandom.seed)
                        end
                    end
                end
            end
        end

        return ret
    end
end

-- =========================================================================
-- INTRO BACKGROUND: MORADO Y VERDE OSCURO
-- =========================================================================

function apply_witch_brew_intro_bg(force)
    local cfg = (get_witch_brew_config and get_witch_brew_config())
        or (SMODS and SMODS.Mods and SMODS.Mods['Witch_brew'] and SMODS.Mods['Witch_brew'].config)
        or {}
    if force or cfg.custom_menu_bg ~= false then
        G.C.WITCH_BREW_INTRO_PURPLE = G.C.WITCH_BREW_INTRO_PURPLE or HEX('4c196b')
        G.C.WITCH_BREW_INTRO_DARKGREEN = G.C.WITCH_BREW_INTRO_DARKGREEN or HEX('0a3314')
        if G.SPLASH_BACK then
            G.SPLASH_BACK:define_draw_steps({{
                shader = 'splash',
                send = {
                    {name = 'time', ref_table = G.TIMERS, ref_value = 'REAL_SHADER'},
                    {name = 'vort_speed', val = 0.4},
                    {name = 'colour_1', ref_table = G.C, ref_value = 'WITCH_BREW_INTRO_PURPLE'},
                    {name = 'colour_2', ref_table = G.C, ref_value = 'WITCH_BREW_INTRO_DARKGREEN'},
                    {name = 'mid_flash', ref_table = {mid_flash = 0}, ref_value = 'mid_flash'},
                    {name = 'vort_offset', val = 0},
                }
            }})
        end
        if ease_background_colour then
            ease_background_colour{
                new_colour = G.C.WITCH_BREW_INTRO_PURPLE,
                special_colour = G.C.WITCH_BREW_INTRO_DARKGREEN,
                contrast = 2.0
            }
        end
    end
end

-- =========================================================================
-- MAIN MENU AMBIENT BACKGROUND: NEGRO Y MORADO
-- =========================================================================

function apply_witch_brew_menu_bg(force, change_context)
    local cfg = (get_witch_brew_config and get_witch_brew_config())
        or (SMODS and SMODS.Mods and SMODS.Mods['Witch_brew'] and SMODS.Mods['Witch_brew'].config)
        or {}
    if force or cfg.custom_menu_bg ~= false then
        G.C.WITCH_BREW_MENU_BLACK = G.C.WITCH_BREW_MENU_BLACK or HEX('08080c')
        G.C.WITCH_BREW_MENU_PURPLE = G.C.WITCH_BREW_MENU_PURPLE or HEX('4c196b')
        local splash_args = {mid_flash = change_context == 'splash' and 1.6 or 0.}
        if change_context == 'splash' then
            ease_value(splash_args, 'mid_flash', -1.6, nil, nil, nil, 4)
        end
        if G.SPLASH_BACK then
            G.SPLASH_BACK:define_draw_steps({{
                shader = 'splash',
                send = {
                    {name = 'time', ref_table = G.TIMERS, ref_value = 'REAL_SHADER'},
                    {name = 'vort_speed', val = 0.4},
                    {name = 'colour_1', ref_table = G.C, ref_value = 'WITCH_BREW_MENU_BLACK'},
                    {name = 'colour_2', ref_table = G.C, ref_value = 'WITCH_BREW_MENU_PURPLE'},
                    {name = 'mid_flash', ref_table = splash_args, ref_value = 'mid_flash'},
                    {name = 'vort_offset', val = 0},
                }
            }})
        end
        if ease_background_colour then
            ease_background_colour{
                new_colour = G.C.WITCH_BREW_MENU_BLACK,
                special_colour = G.C.WITCH_BREW_MENU_PURPLE,
                contrast = 2.0
            }
        end
    else
        if G.SPLASH_BACK then
            G.SPLASH_BACK:define_draw_steps({{
                shader = 'splash',
                send = {
                    {name = 'time', ref_table = G.TIMERS, ref_value = 'REAL_SHADER'},
                    {name = 'vort_speed', val = 0.4},
                    {name = 'colour_1', ref_table = G.C, ref_value = 'RED'},
                    {name = 'colour_2', ref_table = G.C, ref_value = 'BLUE'},
                    {name = 'mid_flash', ref_table = {mid_flash = 0}, ref_value = 'mid_flash'},
                    {name = 'vort_offset', val = 0},
                }
            }})
        end
        if ease_background_colour then
            ease_background_colour{new_colour = G.C.BLACK, contrast = 1}
        end
    end
end

if Game and Game.splash_screen then
    local orig_splash_screen = Game.splash_screen
    function Game:splash_screen()
        orig_splash_screen(self)
        apply_witch_brew_intro_bg()
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                local mod_jokers = {}
                local mod_enhancements = {}
                for k, v in pairs(G.P_CENTERS) do
                    if v.set == 'Joker' and (string.find(k, 'Witch_brew') or string.find(k, 'witch_brew')) then
                        table.insert(mod_jokers, v)
                    elseif v.set == 'Enhanced' and (string.find(k, 'Witch_brew') or string.find(k, 'witch_brew')) then
                        table.insert(mod_enhancements, v)
                    end
                end
                local mod_seals = { 'Witch_brew_dark_green', 'Witch_brew_white', 'Witch_brew_silver' }

                make_splash_card = function(args)
                    args = args or {}
                    local angle = math.random() * 2 * 3.14
                    local card_size = (args.scale or 1.5) * (math.random() + 1)
                    local card_pos = args.card_pos or {
                        x = (18 + card_size) * math.sin(angle),
                        y = (18 + card_size) * math.cos(angle)
                    }

                    local card = nil
                    -- 30% de probabilidad de generar un Joker del mod
                    if #mod_jokers > 0 and math.random() < 0.3 then
                        local chosen_joker = pseudorandom_element(mod_jokers)
                        card = Card(
                            card_pos.x + G.ROOM.T.w / 2 - G.CARD_W * card_size / 2,
                            card_pos.y + G.ROOM.T.h / 2 - G.CARD_H * card_size / 2,
                            card_size * G.CARD_W, card_size * G.CARD_H,
                            G.P_CARDS.empty,
                            chosen_joker
                        )
                    else
                        -- Cartas estándar con mejoras y/o sellos del mod
                        local chosen_enh = (#mod_enhancements > 0 and math.random() < 0.75)
                            and pseudorandom_element(mod_enhancements)
                            or G.P_CENTERS.c_base

                        card = Card(
                            card_pos.x + G.ROOM.T.w / 2 - G.CARD_W * card_size / 2,
                            card_pos.y + G.ROOM.T.h / 2 - G.CARD_H * card_size / 2,
                            card_size * G.CARD_W, card_size * G.CARD_H,
                            pseudorandom_element(G.P_CARDS),
                            chosen_enh
                        )

                        -- 40% de probabilidad de tener un sello del mod
                        if #mod_seals > 0 and math.random() < 0.4 then
                            card:set_seal(pseudorandom_element(mod_seals), true, true)
                        end

                        if math.random() > 0.85 then
                            card.sprite_facing = 'back'
                            card.facing = 'back'
                        end
                    end

                    -- 20% de probabilidad de tener edición (Foil, Holo, Polychrome)
                    if math.random() < 0.2 then
                        local ed = pseudorandom_element({ 'foil', 'holo', 'polychrome' })
                        card:set_edition({ [ed] = true }, true, true)
                    end

                    card.no_shadow = true
                    card.states.hover.can = false
                    card.states.drag.can = false
                    card.vortex = true and not args.no_vortex
                    card.T.r = angle
                    return card, card_pos
                end
                return true
            end
        }))
    end
end

if Game and Game.main_menu then
    local orig_game_main_menu = Game.main_menu
    function Game:main_menu(change_context)
        orig_game_main_menu(self, change_context)
        apply_witch_brew_menu_bg(nil, change_context)
        spawn_main_menu_secret_joker()
    end
end

-- Spawn a random secret Joker taking the place of the card on the main menu, with increased size
function spawn_main_menu_secret_joker()
    if not (G and G.title_top and G.title_top.cards) then return end
    if #G.title_top.cards == 0 then
        if G.E_MANAGER then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                blockable = false,
                func = function()
                    spawn_main_menu_secret_joker()
                    return true
                end
            }))
        end
        return
    end
    -- If already replaced by our secret joker, do not replace repeatedly
    if G.title_top.cards[1] and G.title_top.cards[1].is_witch_brew_menu_joker then
        create_witch_brew_title_label()
        return
    end

    local secret_keys = {
        'j_Witch_brew_esteban',
        'j_Witch_brew_thiago',
        'j_Witch_brew_black_hole_joker',
        'j_Witch_brew_squele',
        'j_Witch_brew_bluxdir',
        'j_Witch_brew_charles',
        'j_Witch_brew_mochi',
        'j_Witch_brew_helin',
        'j_Witch_brew_raytracing',
        'j_Witch_brew_paco',
        'j_Witch_brew_yairo',
        'j_Witch_brew_kyra',
        'j_Witch_brew_brainprint'
    }
    local chosen_key = secret_keys[math.random(1, #secret_keys)]
    local center = (G.P_CENTERS and (G.P_CENTERS[chosen_key] or G.P_CENTERS[string.gsub(chosen_key, 'Witch_brew', 'Witch brew')])) or (G.P_CENTERS and G.P_CENTERS.j_joker)
    if center then
        local scale = 1.35
        local card_w = G.CARD_W * scale
        local card_h = G.CARD_H * scale
        G.title_top.config.card_limit = 1
        G.title_top.card_w = card_w
        G.title_top.card_h = card_h
        G.title_top.T.w = card_w
        G.title_top.T.h = card_h

        for i = #G.title_top.cards, 1, -1 do
            G.title_top.cards[i]:remove()
        end
        G.title_top.cards = {}

        local secret_card = Card(
            G.title_top.T.x,
            G.title_top.T.y,
            card_w,
            card_h,
            G.P_CARDS.empty,
            center
        )
        secret_card.is_witch_brew_menu_joker = true
        secret_card.facing = 'front'
        secret_card.sprite_facing = 'front'
        secret_card.ambient_tilt = 0.8
        G.title_top:emplace(secret_card)
        G.title_top:align_cards()
        if set_screen_positions then
            set_screen_positions()
        end
    end
    create_witch_brew_title_label()
end

-- Small title label next to the title showing the mod name
function create_witch_brew_title_label()
    if G.WITCH_BREW_TITLE_LABEL then
        G.WITCH_BREW_TITLE_LABEL:remove()
        G.WITCH_BREW_TITLE_LABEL = nil
    end
    if not (G and G.STAGE == G.STAGES.MAIN_MENU) then return end

    local major_target = G.SPLASH_LOGO or G.title_top
    if not major_target then return end

    G.WITCH_BREW_TITLE_LABEL = UIBox{
        definition = {
            n = G.UIT.ROOT,
            config = { align = "cm", colour = G.C.CLEAR },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.05 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                align = "cm",
                                padding = 0.08,
                                r = 0.12,
                                colour = {0.1, 0.05, 0.15, 0.65},
                                emboss = 0.05
                            },
                            nodes = {
                                {
                                    n = G.UIT.T,
                                    config = {
                                        text = "Witch Brew Expansion",
                                        scale = 0.33,
                                        colour = G.C.WITCH_BREW_RED or HEX('d32f2f'),
                                        shadow = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        },
        config = {
            align = (major_target == G.SPLASH_LOGO) and "tr" or "tr",
            offset = (major_target == G.SPLASH_LOGO) and { x = 0.25, y = -0.15 } or { x = 3.6, y = -1.2 },
            major = major_target,
            bond = 'Weak'
        }
    }
end

if Game and Game.update then
    local orig_game_update = Game.update
    function Game:update(dt)
        orig_game_update(self, dt)
        if G.WITCH_BREW_TITLE_LABEL and (not G.STAGE or G.STAGE ~= G.STAGES.MAIN_MENU) then
            G.WITCH_BREW_TITLE_LABEL:remove()
            G.WITCH_BREW_TITLE_LABEL = nil
        end
    end
end

-- Custom Title Atlas (Witcher Brew - Purple & Green Title)
SMODS.Atlas {
    key = "witch_brew_title",
    path = "title.png",
    px = 333,
    py = 216
}

function apply_witch_brew_title_asset()
    local title_atlas = (G.ASSET_ATLAS and (G.ASSET_ATLAS['witch_brew_title'] or G.ASSET_ATLAS['Witch_brew_title']))
        or (SMODS and SMODS.Atlases and (SMODS.Atlases['witch_brew_title'] or SMODS.Atlases['Witch_brew_title']))
    if not title_atlas then return end
    if G.ASSET_ATLAS then
        if G.ASSET_ATLAS["balatro"] and title_atlas.image then
            G.ASSET_ATLAS["balatro"].image = title_atlas.image
        end
        G.ASSET_ATLAS["balatro"] = title_atlas
    end
    if G.SPLASH_LOGO then
        G.SPLASH_LOGO.atlas = title_atlas
        G.SPLASH_LOGO:set_sprite_pos({x = 0, y = 0})
    end
end

if Game and Game.main_menu then
    local orig_game_main_menu = Game.main_menu
    function Game:main_menu(change_context)
        apply_witch_brew_title_asset()
        local res = orig_game_main_menu(self, change_context)
        apply_witch_brew_title_asset()
        return res
    end
end

if set_main_menu_UI then
    local orig_set_main_menu_UI = set_main_menu_UI
    function set_main_menu_UI()
        orig_set_main_menu_UI()
        apply_witch_brew_menu_bg()
        apply_witch_brew_title_asset()
        spawn_main_menu_secret_joker()
        create_witch_brew_title_label()
    end
end

if G and G.STAGE == G.STAGES.MAIN_MENU then
    apply_witch_brew_menu_bg()
    apply_witch_brew_title_asset()
    spawn_main_menu_secret_joker()
    create_witch_brew_title_label()
end

-- Custom Rarity: Song (Song Jokers)
if SMODS.Rarity then
    SMODS.Rarity {
        key = 'song',
        loc_txt = {
            name = 'Song'
        },
        badge_colour = HEX('d4af37'),
        default_weight = 0.03,
        pools = { ['Joker'] = true }
    }
    if SMODS.Rarities then
        SMODS.Rarities['Witch_brew_cancion'] = SMODS.Rarities['Witch_brew_song']
    end
end

-- Custom Music for Secret Jokers & Special Packs
local function has_secret_joker_equipped()
    if not (G and G.jokers and G.jokers.cards) then return false end
    for _, j in ipairs(G.jokers.cards) do
        if not j.debuff and j.config and j.config.center then
            local c = j.config.center
            if c.is_secret or c.is_amalgam or c.rarity == 'Secret' or c.rarity == 'Amalgam' then
                return true
            end
        end
    end
    return false
end

local function is_special_pack_open()
    local is_pack_state = G.STATE == G.STATES.PLANET_PACK or G.STATE == G.STATES.TAROT_PACK or
                          G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.STANDARD_PACK or
                          G.STATE == G.STATES.BUFFOON_PACK or (G.pack_cards and G.pack_cards.cards and #G.pack_cards.cards > 0)
    if is_pack_state and G.booster_pack then
        local k = (G.booster_pack.config and G.booster_pack.config.center and G.booster_pack.config.center.key) or ''
        local kind = (G.booster_pack.ability and G.booster_pack.ability.kind) or ''
        if string.find(k, 'job_pack') or kind == 'Job' or string.find(k, 'potion') or string.find(k, 'witch') or string.find(k, 'secret') then
            return true
        end
    end
    return false
end

-- Estados donde la música de Jokers NO debe sonar (Tarot, Planetas y Tienda)
local function is_excluded_music_state()
    if not G then return true end
    -- Fuera de partida / Menú / Game Over
    if (G.STAGE and G.STAGE ~= G.STAGES.RUN) or G.STATE == G.STATES.SPLASH or G.STATE == G.STATES.GAME_OVER then
        return true
    end
    -- 1. Tienda
    if G.STATE == G.STATES.SHOP or (G.shop and not G.shop.REMOVED) then
        return true
    end
    -- 2. Tarot (Arcanos)
    if G.STATE == G.STATES.TAROT_PACK or (G.booster_pack_sparkles and not G.booster_pack_sparkles.REMOVED) then
        return true
    end
    if G.booster_pack and not G.booster_pack.REMOVED and G.booster_pack.ability then
        local k = G.booster_pack.ability.kind or ''
        local n = G.booster_pack.ability.name or ''
        if k == 'Tarot' or string.find(n, 'Arcana') or string.find(n, 'Tarot') then
            return true
        end
    end
    -- 3. Planetas (Celestiales)
    if G.STATE == G.STATES.PLANET_PACK or (G.booster_pack_meteors and not G.booster_pack_meteors.REMOVED) then
        return true
    end
    if G.booster_pack and not G.booster_pack.REMOVED and G.booster_pack.ability then
        local k = G.booster_pack.ability.kind or ''
        local n = G.booster_pack.ability.name or ''
        if k == 'Planet' or string.find(n, 'Celestial') or string.find(n, 'Planet') then
            return true
        end
    end
    return false
end

local function is_secret_music_enabled()
    local cfg = (get_witch_brew_config and get_witch_brew_config())
    if cfg and cfg.secret_power_theme == false then
        return false
    end
    return true
end

-- Codename: Secret Power Discovered (All in One Theme mix)
-- (Original By LouisF, Mix by Unknow102)
if SMODS and SMODS.Sound then
    SMODS.Sound {
        key = "music_witch_brew_special",
        path = "secret_joker_music.ogg",
        pitch = 0.95,
        volume = 0.5,
        select_music_track = function(self)
            if not is_secret_music_enabled() then return nil end
            -- 1. Paquetes especiales del mod
            if is_special_pack_open() then
                return 15
            end
            -- 2. Con Jokers Secretos / Amalgamas: reemplaza toda la música excepto Tarot, Planetas y Tienda
            if has_secret_joker_equipped() and not is_excluded_music_state() then
                return 15
            end
        end
    }
end

-- Ensure secret joker music volume is properly scaled by "Volumen del juego" (Game Volume) and Master Volume
if modulate_sound then
    local orig_modulate_sound = modulate_sound
    function modulate_sound(dt)
        local enabled = not (is_secret_music_enabled and not is_secret_music_enabled())
        local is_secret = enabled and (
                          (is_special_pack_open and is_special_pack_open()) or
                          (has_secret_joker_equipped and not is_excluded_music_state and has_secret_joker_equipped() and not is_excluded_music_state())
        )
        local sound_set = G.SETTINGS and G.SETTINGS.SOUND
        if is_secret and sound_set and sound_set.music_volume and sound_set.game_sounds_volume then
            local real_music_vol = sound_set.music_volume
            local game_vol_factor = (sound_set.game_sounds_volume or 100) / 100
            sound_set.music_volume = real_music_vol * game_vol_factor
            orig_modulate_sound(dt)
            sound_set.music_volume = real_music_vol
        else
            orig_modulate_sound(dt)
        end
    end
end


