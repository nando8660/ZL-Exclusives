local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SPELL)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(LOCATION_ALL)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
Ether=0
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id,0,0,0)
    	local c=e:GetHandler()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_RECOVER)
	e2:SetCondition(s.countercon)
	e2:SetOperation(s.addcounter)
	Duel.RegisterEffect(e2,tp)
	Debug.Message("Registro de LP: "..Ether)
	--lose
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.losecon)
	e3:SetOperation(s.loseop)
	Duel.RegisterEffect(e3,tp)
	--win
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCountLimit(1)
	e4:SetCondition(s.wincon)
	e4:SetOperation(s.winop)
    	Duel.RegisterEffect(e4,tp)
end
function s.countercon(e, tp, eg, ep, ev, re, r, rp)
    return ep==tp
end
function s.addcounter(e,tp,eg,ep,ev,re,r,rp)
    --Duel.Draw(tp, 1, REASON_COST)
	Ether=ev+Ether
	Debug.Message("Registro de LP: "..Ether)
end
function s.wincon(e,tp,eg,ep,ev,re,r,rp)
	return Ether>=10000
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(tp,WIN_REASON_DECK_MASTER)
end
function s.losecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)>=10499
end
function s.loseop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(1-tp,WIN_REASON_DECK_MASTER)
end

