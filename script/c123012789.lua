-- Ether Counter v2.0
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetTurnCount()==1 end)
	e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_DUEL)
	e1:SetRange(LOCATION_ALL)
	e1:SetOperation(s.init)
	c:RegisterEffect(e1)
end
Ether_Counters_In_Game = 0
function s.filter(c)
    return c:IsCode(id)
end
function s.init(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    -- Registra no Client quem é p0
    aux.RegisterClientHint(c, nil, 0, 1, 0, aux.Stringid(id, 0), nil, 99999)
    -- Registra no Client quem é p1
    aux.RegisterClientHint(c, nil, 1, 1, 0, aux.Stringid(id, 1), nil, 99999)

    -- Conta quantos Ether Counter há no jogo
    if Duel.GetFlagEffectLabel(0, id)==nil and Duel.GetFlagEffectLabel(1, id)==nil then
        local this_local_count = 0
        if Duel.IsExistingMatchingCard(s.filter, 0, 0, LOCATION_ALL, 1, nil, nil) then
            this_local_count = this_local_count+1
        end
        if Duel.IsExistingMatchingCard(s.filter, 1, 0, LOCATION_ALL, 1, nil, nil) then
            this_local_count = this_local_count+1
        end
        Ether_Counters_In_Game = this_local_count
        Debug.Message("Há exatamente "..Ether_Counters_In_Game.." Ether Counter no jogo.")
    end
    Duel.BreakEffect()
    -- Remove estes contadores do Duelo
    if Duel.IsExistingMatchingCard(s.filter, 0, LOCATION_ALL, LOCATION_ALL, 1, nil, nil) then  
        local d0=Duel.GetMatchingGroupCount(s.filter, 0, LOCATION_HAND, 0, nil, nil)
        local d1=Duel.GetMatchingGroupCount(s.filter, 1, LOCATION_HAND, 0, nil, nil)
        local g=Duel.GetMatchingGroup(s.filter, 0, LOCATION_ALL, LOCATION_ALL, nil, nil)
        if Duel.SendtoDeck(g, nil, -2, REASON_RULE) then 
            Duel.Draw(0, d0, REASON_RULE) 
            Duel.Draw(1, d1, REASON_RULE) 
        end
    end
    -- Registra Flag Effects
    if Ether_Counters_In_Game==1 then 
        Duel.RegisterFlagEffect(0, id, 0, 0, 0)
        Duel.RegisterFlagEffect(1, id, 0, 0, 0)
    else
        Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    end
    -- Inicia o Registro de LP em 0 (O Ether e a Label)
    local Ether=0
    if Ether_Counters_In_Game==1 then 
        Duel.SetFlagEffectLabel(0, id, Ether)
        Duel.SetFlagEffectLabel(1, id, Ether)
    else
        Duel.SetFlagEffectLabel(tp, id, Ether)
    end
    -- Retorna valor de Ether do(s) jogador(es)
    if Ether_Counters_In_Game==1 then 
        -- Define "Get_Owner"
        local Get_p0_Ether = Duel.GetFlagEffectLabel(0, id)
        local Get_p1_Ether = Duel.GetFlagEffectLabel(1, id)
        Debug.Message("Registro de LP do Jogador 0: "..Get_p0_Ether)
        Debug.Message("Registro de LP do Jogador 1: "..Get_p1_Ether)
    else
        -- Define "Get_Owner"
        local Get_tp_Ether = Duel.GetFlagEffectLabel(tp, id)
        Debug.Message("Registro de LP do Jogador "..tp..": "..Get_tp_Ether)
    end
    -- Inicia o efeito que faz contagem
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_RECOVER)
    e1:SetCondition(s.LP_Aumenta)
	e1:SetOperation(s.Ether_Aumenta)
    if Ether_Counters_In_Game==1 then
        Duel.RegisterEffect(e1, 0)
    else
        Duel.RegisterEffect(e1, tp)
    end
    -- Registra derrota por Overflow
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(s.OverflowCon)
	e2:SetOperation(s.Derrota)
    Duel.RegisterEffect(e2, 0)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(s.VitoriaCon)
	e3:SetOperation(s.Vitoria)
    Duel.RegisterEffect(e3, 0)
end
function s.LP_Aumenta(e, tp, eg, ep, ev, re, r, rp)
    if Ether_Counters_In_Game==1 then
        return ep==1 or ep==0
    else
        return ep==tp
    end
end
function s.Ether_Aumenta(e,tp,eg,ep,ev,re,r,rp)
    local Ganho_de_LP = ev
    if Ether_Counters_In_Game==1 then
        if ep==0 then
            local player = 0
            local Get_Ether_Prev = Duel.GetFlagEffectLabel(player, id)
            Duel.SetFlagEffectLabel(player, id, Get_Ether_Prev+Ganho_de_LP)
            local Get_Ether = Duel.GetFlagEffectLabel(player, id)
            Debug.Message("Registro de LP do Jogador "..player..": "..Get_Ether)
        elseif ep==1 then
            local player = 1
            local Get_Ether_Prev = Duel.GetFlagEffectLabel(player, id)
            Duel.SetFlagEffectLabel(player, id, Get_Ether_Prev+Ganho_de_LP)
            local Get_Ether = Duel.GetFlagEffectLabel(player, id)
            Debug.Message("Registro de LP do Jogador "..player..": "..Get_Ether)
        end
    else
        local player = tp
        local Get_Ether_Prev = Duel.GetFlagEffectLabel(player, id)
        Duel.SetFlagEffectLabel(player, id, Get_Ether_Prev+Ganho_de_LP)
        local Get_Ether = Duel.GetFlagEffectLabel(player, id)
        Debug.Message("Registro de LP do Jogador "..player..": "..Get_Ether)
    end
end
function s.OverflowCon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetLP(0)>15000 or Duel.GetLP(1)>15000
end
function s.Derrota(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLP(0)>15000 then Duel.Win(1,0x47) return end
	if Duel.GetLP(1)>15000 then Duel.Win(0,0x47) return end
	Duel.Win(PLAYER_NONE, 0x47)
end
function s.VitoriaCon(e,tp,eg,ep,ev,re,r,rp)
    return (Duel.GetLP(0)<=5000 and Duel.GetFlagEffectLabel(0, id)>=10000) 
        or (Duel.GetLP(1)<=5000 and Duel.GetFlagEffectLabel(1, id)>=10000) 
end
function s.Vitoria(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLP(0)<=5000 and Duel.GetFlagEffectLabel(0, id)>=10000 then Duel.Win(1,0x46) return end
	if Duel.GetLP(1)<=5000 and Duel.GetFlagEffectLabel(1, id)>=10000 then Duel.Win(0,0x46) return end
	Duel.Win(PLAYER_NONE, 0x46)
end
