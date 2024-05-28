-- Enlightenment, the Singularity of Symbols
local s,id=GetID()
function s.initial_effect(c)
    --Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Special Summon procedure
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA|LOCATION_GRAVE)
	e2:SetCondition(s.sprcon)
	e2:SetTarget(s.sprtg)
	e2:SetOperation(s.sprop)
	e2:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e2)
	-- Effect indestructable	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- Other Synchro cant be target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetTarget(function(e,c) return c~=e:GetHandler() and c:IsType(TYPE_SYNCHRO) end)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ATK Decrease
	local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_RECOVER+CATEGORY_TODECK+CATEGORY_ATKCHANGE)
    e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e5:SetCountLimit(1)
    e5:SetCost(s.atkcost)
    e5:SetTarget(s.atktg)
    e5:SetOperation(s.atkop)
    c:RegisterEffect(e5)
end
-- SUMMON PROC (START)
function s.sprfilter(c)
	return c:IsFaceup() and c:HasLevel() --and c:IsAbleToGraveAsCost()
end
function s.sprfilter1(c,tp,g,sc,e)
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	return c:IsType(TYPE_TUNER) and g:IsExists(s.sprfilter2,1,c,tp,c,sc,e)
end
function s.sprfilter2(c,tp,mc,sc,e)
	local sg=Group.FromCards(c,mc)
	local THIS_CARD_LEVEL=e:GetHandler():GetLevel()
	return (math.abs((c:GetLevel()-mc:GetLevel()))==THIS_CARD_LEVEL) and not c:IsType(TYPE_TUNER) and Duel.GetLocationCountFromEx(tp,tp,sg,sc)>0
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	return g:IsExists(s.sprfilter1,1,nil,tp,g,c,e)
end
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	local g1=g:Filter(s.sprfilter1,nil,tp,g,c,e)
	local mg1=aux.SelectUnselectGroup(g1,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #mg1>0 then
		local mc=mg1:GetFirst(	)
		local g2=g:Filter(s.sprfilter2,mc,tp,mc,c,e,mc:GetLevel())
		local mg2=aux.SelectUnselectGroup(g2,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
		mg1:Merge(mg2)
	end
	if #mg1==2 then
		mg1:KeepAlive()
		e:SetLabelObject(mg1)
		return true
	end
	return false
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
    Duel.Release(g, REASON_COST)
end
-- SUMMON PROC (END)
function s.dmgcond(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
function s.rev(e,re,r,rp,rc)
	return r&REASON_BATTLE~=0 and (Duel.GetAttacker()==e:GetHandler() or (Duel.GetAttackTarget() and Duel.GetAttackTarget()==e:GetHandler()))
end
-- ATK DECREASE >>
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
    Duel.PayLPCost(tp,500)
end
function s.tdfilter(c)
    return c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeckAsCost()
end
function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, nil) 
        and Duel.IsExistingMatchingCard(s.tdfilter, tp, LOCATION_REMOVED, 0, 1, nil) end
    local g=Duel.SelectMatchingCard(tp, s.tdfilter, tp, LOCATION_REMOVED, 0, 1, 3, true, nil)
    if #g>0 then 
        Duel.SendtoDeck(g, tp, 2, REASON_COST)
	end
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local tg = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
	if #tg==0 then return end
    local atk_decrease = Duel.GetOperatedGroup():GetSum(Card.GetAttack)
    local tc=Duel.SelectMatchingCard(tp, Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, 1, nil):GetFirst()
    local tdg=Group.CreateGroup()
    if tc then 
        -- registes the ATK of the target before this effect
        local preatk=tc:GetAttack()
        -- reduce attack
        local e1=Effect.CreateEffect(e:GetHandler()) 
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk_decrease)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
        if preatk~=0 and tc:GetAttack()==0 then tdg:AddCard(tc) end
    end
	if #tdg==0 then return end
    Duel.BreakEffect()
    if Duel.SendtoDeck(tdg, nil, 2, REASON_EFFECT) then Duel.Recover(tp, 1000, REASON_EFFECT) end
end