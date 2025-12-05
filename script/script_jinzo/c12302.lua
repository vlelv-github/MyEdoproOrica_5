-- 사이코 로드
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.fustg)
	e2:SetOperation(s.fusop)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)

	aux.GlobalCheck(s,function()
        s[0]=Group.CreateGroup()
        s[0]:KeepAlive()
        local ge=Effect.CreateEffect(c)
        ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge:SetCode(EVENT_ADJUST)
        ge:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
        ge:SetOperation(s.setop)
        Duel.RegisterEffect(ge,0)
    end)
end
s.listed_names={CARD_JINZO}

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    if s[0]:GetCount()>0 then return end
    for i=1,5 do
        local tc=Duel.CreateToken(0,946)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(511002961)
        tc:RegisterEffect(e1)
        s[0]:AddCard(tc)
    end
    for i=1,5 do
        local tc=Duel.CreateToken(1,946)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(511002961)
        tc:RegisterEffect(e1)
        s[0]:AddCard(tc)
    end
end

function s.valid_fusion(c,tp,mc)
    if not (c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE)) then return false end
    if c.material and mc:IsCode(table.unpack(c.material)) then return true end
    return c:CheckFusionMaterial(s[0],mc,tp)
end

function s.spfilter(c,tp)
    return c:IsCode(CARD_JINZO) and Duel.IsExistingMatchingCard(s.valid_fusion,tp,LOCATION_EXTRA,0,1,nil,tp,c)
end

-- 상대 필드에 뒷면 카드 OR 앞면 함정 존재 여부
function s.cond(e,tp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
    return g:IsExists(aux.FaceupFilter(Card.IsTrap),1,nil)
        or g:IsExists(Card.IsFacedown,1,nil)
end

-- 융합 몬스터 필터: 레벨 6 이하 + 기계족
function s.fusfilter(c)
    return c:IsRace(RACE_MACHINE) and c:IsLevelBelow(6) and c:IsType(TYPE_FUSION)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- 조건 만족 시: 사이코 쇼커 1장만으로 융합 가능
        if s.cond(e,tp) then
            if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,tp) then
                e:SetLabel(1)
                return true
            end
        end
        -- 기본: 패/필드 몬스터를 소재로
        e:SetLabel(0)
        return Fusion.SummonEffTG(s.fusfilter)(e,tp,eg,ep,ev,re,r,rp,0)
    end
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    -- 특수 조건 만족 시: 사이코 쇼커 1장만 소재로 허용
    if not Fusion.SummonEffTG(s.fusfilter)(e,tp,eg,ep,ev,re,r,rp,0) or (e:GetLabel()==1 and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
        local mg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
        if #mg>0 then
            local mat=mg
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.valid_fusion,tp,LOCATION_EXTRA,0,1,1,nil,tp,mat:GetFirst())
            local tc=sg:GetFirst()
            if tc then
                tc:SetMaterial(mat)
                Duel.SendtoGrave(mat,REASON_MATERIAL+REASON_FUSION)
                Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
                tc:CompleteProcedure()
                return
            end
        end
    end
    -- 기본 융합
    Fusion.SummonEffOP(s.fusfilter)(e,tp,eg,ep,ev,re,r,rp)
end


function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_JINZO) and c:IsControler(tp)
end

function s.spcon3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter3,1,nil,tp)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.tgfilter(c)
	return c:IsMonster() and c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
end
function s.thspfilter(c,e,tp,sp_chk)
	return (c:IsCode(CARD_JINZO) or c:ListsCode(CARD_JINZO)) and c:IsMonster()
		and (c:IsAbleToHand() or (sp_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local sp_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,sp_chk)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local sp_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thspfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,sp_chk):GetFirst()
	if not tc then return end
    local success = false
	if aux.ToHandOrElse(tc,tp,
		function() return sp_chk and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
		function() 
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) 
            success = true
        end,
		aux.Stringid(id,3)
	) then 
        success = true
    end
    if success then
        local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
        if #g>0 then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sg=g:Select(tp,1,1,nil)
            Duel.Destroy(sg,REASON_EFFECT)
        end
    end
end