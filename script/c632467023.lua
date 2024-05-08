-- Makina-vice Monstro #1
-- Hev-Device In-Solardien
local s,id=GetID()
function s.initial_effect(c)
	-- Destroy monster that battles this card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e0:SetCategory(CATEGORY_DESTROY)
	e0:SetCode(EVENT_BATTLE_START)
	e0:SetRange(LOCATION_SZONE)
	e0:SetCountLimit(1,{id,2})
	e0:SetCondition(s.descon)
	e0:SetTarget(s.destg)
	e0:SetOperation(s.desop)
	c:RegisterEffect(e0)
	-- Destroy card in opponent's hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(function(e) return e:GetHandler():GetEquipTarget() end)
	e1:SetTarget(s.destg2)
	e1:SetOperation(s.desop2)
	c:RegisterEffect(e1)
    --Place this card in the Spell/Trap Zone as Continuous Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
end
s.toss_coin=true
-- EQUIP EFFECT
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetHandler():GetEquipTarget()
	return tg and (Duel.GetAttacker()==tg or Duel.GetAttackTarget()==tg)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget():GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) end
	local g=Group.FromCards(tc,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=c:GetEquipTarget():GetBattleTarget()
	if tc:IsRelateToBattle() and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.CountHeads(Duel.TossCoin(tp,2))==2 then
		Duel.BreakEffect()
		Duel.Destroy(c,REASON_EFFECT)
	end
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil, tp, 0, LOCATION_HAND|LOCATION_ONFIELD, 1, nil, e, tp) end
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CountHeads(Duel.TossCoin(tp,2))==2 then
		local g=Duel.GetMatchingGroup(nil, tp, 0, LOCATION_HAND, nil, e, tp)
		local tc=g:RandomSelect(tp, 1)
		Duel.Destroy(tc,REASON_EFFECT)
	else
		local tc=Duel.SelectMatchingCard(tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, nil, e, tp)
		Duel.Destroy(tc,REASON_EFFECT)
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- REST
function s.filter1(c,e,tp)
	return c:IsSetCard(0x21E0)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>=1 and Duel.IsExistingMatchingCard(s.filter1, tp, LOCATION_DECK, 0, 1, nil, e) end
end
function s.move_to_stzone(c,hc,tp)
	if not Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then return end
	--Treat as Continuous Spell
	local e1=Effect.CreateEffect(hc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
	c:RegisterEffect(e1)
	return true
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<2 then return end
	if s.move_to_stzone(c,c,tp) then
		local tc = Duel.SelectMatchingCard(tp, s.filter1, tp, LOCATION_DECK, 0, 1, 1, nil):GetFirst()
		s.move_to_stzone(tc,tc,tp)
	end
end