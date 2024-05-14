-- Tempor-Ax Monstro A
-- EonTech Engineer Timezleigh
local s,id=GetID()
function s.initial_effect(c)
	--Place this card in the Spell/Trap Zone as Continuous Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetCountLimit(3,id)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	-- Fusion Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e2:SetCondition(function(e) return e:GetHandler():IsContinuousTrap() end)
	e2:SetCountLimit(3,id)
    e2:SetTarget(s.mfustg)
    e2:SetOperation(s.mfusop)
	c:RegisterEffect(e2)
    -- Equip "Makina-vice" from GY
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(function(e, tp) return e:GetHandler():IsContinuousTrap() and Duel.GetAttacker():IsControler(1-tp) end)
	e3:SetCountLimit(3,id)
    e3:SetOperation(s.equipop)
	c:RegisterEffect(e3)
end
-- VIRA ARMADILHA
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>=1 end
end
function s.move_to_stzone(c,hc,tp)
	if not Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then return end
	--Treat as Continuous Trap
	local e1=Effect.CreateEffect(hc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_TRAP|TYPE_CONTINUOUS)
	e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
	c:RegisterEffect(e1)
	return true
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	s.move_to_stzone(c,c,tp)
end
-- FUSAO PRO LADO DO OPONENTE
function s.filter1(c,e)
    return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end

function s.filter2(c,e,tp,m,f,chkf)
    return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and (not f or f(c))
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and c:CheckFusionMaterial(m,nil,chkf)
end

function s.mfustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local chkf=tp
        -- Obter materiais de fusão da HAND, SZONE e MZONE
        local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
        local mg2=Duel.GetMatchingGroup(Card.IsCanBeFusionMaterial,tp,LOCATION_SZONE+LOCATION_MZONE,0,nil)
        mg1:Merge(mg2)
        -- Verificar se existe algum monstro de fusão que possa ser invocado com todos os materiais necessários
        local res=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf):GetCount()>0
        -- {Linhas de debug para imprimir os grupos no chat}
        -- Debug.Message("Grupo de materiais de fusão da HAND, SZONE e MZONE:")
        -- Debug.Message(mg1)
        -- Debug.Message("Resultado da verificação de monstros de fusão disponíveis:")
        -- Debug.Message(res)
        return res
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.rescon(c,e,tp,mg,chkf)
    return c:CheckFusionMaterial(mg,nil,chkf)
end

function s.mfusop(e,tp,eg,ep,ev,re,r,rp)
    local chkf=tp
    local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
    -- Inclua cartas na zona de magia/armadilha como material de fusão
    local mg2=Duel.GetMatchingGroup(Card.IsCanBeFusionMaterial,tp,LOCATION_SZONE,0,nil)
    mg1:Merge(mg2)
    local sg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
    if sg:GetCount()>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tg=sg:Select(tp,1,1,nil)
        local tc=tg:GetFirst()
        if tc then
            local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
            tc:SetMaterial(mat1)
            Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            Duel.BreakEffect()
            Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
            tc:CompleteProcedure()
        end
    end
end
-- EQUIPAR
function s.equipfilter(c,e)
    return c:IsSetCard(0x21e0) and c:IsMonster() and not c:IsForbidden()
end
function s.equipop(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetMatchingGroupCount(s.equipfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, nil, e, tp)>0 then
        local ec = Duel.SelectMatchingCard(tp, s.equipfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, 1, nil, e, tp):GetFirst()
        Duel.Equip(tp, ec, c)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(s.eqlimit)
        e1:SetLabelObject(c)
        ec:RegisterEffect(e1)
    end
end
function s.eqlimit(e,ec,c)
	return e:GetLabelObject()==ec
end
