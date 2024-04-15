--Ether Counter
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
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--Registra Flags para os Jogadores
	if not Duel.GetFlagEffect(tp, 107)==0 then return true end
	Duel.RegisterFlagEffect(tp,107,0,0,0)
	Duel.RegisterFlagEffect(1-tp,107,0,0,0)
	--Vira a Skill
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	-- Cria os efeitos restantes
	local c=e:GetHandler()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_RECOVER)
	e2:SetCondition(s.countercon)
	e2:SetOperation(s.addcounter)
	Duel.RegisterEffect(e2,tp)
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
	--Reduzir flag quando recebe dano por efeito
	-- local e5=Effect.CreateEffect(c)
 --    	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
 --    	e5:SetCode(EVENT_DAMAGE)
 --   	e5:SetCondition(s.damagecon)
 --    	e5:SetOperation(s.damageop)
 --    	Duel.RegisterEffect(e5,tp)
	-- Retorna o Registro inicial (Deve retornar 0)
	Debug.Message("Registro de LP: "..Duel.GetFlagEffectLabel(tp,107).." | jogador "..(tp))
end

function s.countercon(e,tp,eg,ep,ev,re,r,rp)
	return ep==0|1
end

function s.addcounter(e,tp,eg,ep,ev,re,r,rp)
	if ep==0 then
		local flag=Duel.GetFlagEffectLabel(0,107)
		if not flag then
			Duel.RegisterFlagEffect(0,107,RESET_PHASE+PHASE_END,0,1,0)
			Duel.SetFlagEffectLabel(0,107,ev)
		else
			Duel.SetFlagEffectLabel(0,107,flag+ev)
		end
		Debug.Message("Registro de LP após o ganho: "..Duel.GetFlagEffectLabel(0,107).." | jogador "..(0))
	else
		local flag=Duel.GetFlagEffectLabel(1,107)
		if not flag then
			Duel.RegisterFlagEffect(1,107,RESET_PHASE+PHASE_END,0,1,0)
			Duel.SetFlagEffectLabel(1,107,ev)
		else
			Duel.SetFlagEffectLabel(1,107,flag+ev)
		end
		Debug.Message("Registro de LP após o ganho: "..Duel.GetFlagEffectLabel(1,107).." | jogador "..(1))
	end
end

function s.wincon(e,tp,eg,ep,ev,re,r,rp)
	local flag=Duel.GetFlagEffectLabel(tp,107)
	return flag and flag>=10000 and not (Duel.GetLP(tp)>=5000)
end

function s.winop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(tp,0x46)
end

function s.losecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)>=15000
end

function s.loseop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(1-tp,0x47)
end

-- condition to check for effect damage to the player
-- function s.damagecon(e,tp,eg,ep,ev,re,r,rp)
--     return ep==tp and bit.band(r,REASON_EFFECT)~=0
-- end

-- operation to reduce the flag value by the amount of effect damage taken
-- function s.damageop(e,tp,eg,ep,ev,re,r,rp)
--     local flag=Duel.GetFlagEffectLabel(tp,107)
--     if flag then
--         local new_val = flag - ev
--         if new_val < 0 then new_val = 0 end -- prevent the flag from going negative
--         Duel.SetFlagEffectLabel(tp,107,new_val)
--     end
--     Debug.Message("Registro de LP após dano: "..Duel.GetFlagEffectLabel(tp,107).." | jogador "..(tp))
-- end
