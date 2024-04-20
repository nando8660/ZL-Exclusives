--Zero Trap Localized Tornado
local s,id=GetID()
function s.initial_effect(c)
	--Can be activated from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e1)
    --Set "Localized Tornado"
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_DECK+LOCATION_HAND)
	e1:SetCondition(condition)
	e1:SetTarget(target)
	e1:SetOperation(operation)
	c:RegisterEffect(e1)
end
function condition(e, tp, eg, ep, ev, re, r, rp)
    return not (Duel.GetTurnPlayer()==tp) and (Duel.GetTurnCount()==1 or (not Duel.GetFlagEffect(tp, 109)==0))
end
function filter(c, e, tp)
    return c:IsCode(64681263)
end
function target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(filter, tp, LOCATION_HAND|LOCATION_DECK, 0, 1, nil, e, tp) end
end
function operation(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    if c:IsPreviousLocation(LOCATION_DECK) then
        Duel.ShuffleDeck(tp)
    else
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
    local lt = Duel.SelectMatchingCard(tp, filter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, 1, e, tp)
    if Duel.SSet(1-tp, lt) then
		lt:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		local c=lt:GetFirst()
		--Cannot activate cards or effects
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_ACTIVATE)
		e3:SetTargetRange(0,1)
		e3:SetCondition(limcon)
		e3:SetValue(limtg)
		Duel.RegisterEffect(e3,tp)
		Debug.Message(c:GetFlagEffect(id))
	end
end
function limcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsTurnPlayer(e:GetHandlerPlayer()) and Duel.IsExistingMatchingCard(filter2, e:GetHandlerPlayer(), 0, LOCATION_SZONE, 1, nil)
end
function limtg(e,re,tp)
	return not (re:GetHandler():IsCode(64681263) and re:GetHandler():GetFlagEffect(id)~=0)
end
function filter2(c)
	return c:IsCode(64681263) and c:GetFlagEffect(id)~=0 and c:IsFacedown()
end