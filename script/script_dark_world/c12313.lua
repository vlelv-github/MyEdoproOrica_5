-- 암흑계의 마왕 레돈
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,nil,s.lcheck)

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

    -- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.chcon)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)

	-- 자신 패에서 몬스터가 묘지로 보내졌을 경우
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e3:SetTarget(s.sptg1)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 상대 패에서 몬스터가 묘지로 보내졌을 경우
	local e4 = e3:Clone()
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetTarget(s.sptg2)
	c:RegisterEffect(e4)
end
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(s.mzfilter,1,nil,lc,sumtype,tp)
end
function s.mzfilter(c,lc,sumtype,tp)
	return c:IsLevelAbove(8) and c:IsAttribute(ATTRIBUTE_DARK,lc,sumtype,tp) and c:IsRace(RACE_FIEND,lc,sumtype,tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLinkSummoned()
end
function s.thfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
        if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            Duel.BreakEffect()
		    Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT|REASON_DISCARD)
        end
	end
end

function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end

function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local h1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    local h2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if chk==0 then return (h1+h2>0) and (Duel.IsPlayerCanDraw(tp,1) or h1==0) and (Duel.IsPlayerCanDraw(1-tp,1) or h2==0) end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 or Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
        local turn_pl=Duel.GetTurnPlayer()
		Duel.BreakEffect()
		Duel.DiscardHand(turn_pl,nil,1,1,REASON_EFFECT|REASON_DISCARD)
		Duel.DiscardHand(1-turn_pl,nil,1,1,REASON_EFFECT|REASON_DISCARD)
    end
end

function s.spfilter(c,e,tp,eg)
    return c:IsPreviousLocation(LOCATION_HAND)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and eg:IsContains(c)
		and c:IsControler(tp)
end
function s.spfilter2(c,e,tp,eg)
    return c:IsPreviousLocation(LOCATION_HAND)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and eg:IsContains(c)
		and c:IsControler(1-tp)
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp,eg)
    end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter2(chkc,e,tp,eg)
    end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter2,tp,0,LOCATION_GRAVE,1,nil,e,tp,eg)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter2,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,eg)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end