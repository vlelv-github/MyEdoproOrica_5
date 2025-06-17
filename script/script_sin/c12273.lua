-- Sin 스틸
local s,id=GetID()
function s.initial_effect(c)
   -- 긴빠이
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	c:RegisterEffect(e1)
	-- 대신 파괴
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetOperation(function(e) Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE) end)
	e2:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e2)
end

	-- "Sin 월드의 카드명이 쓰여짐
s.listed_names = {27564031}
	-- "Sin"의 테마명이 쓰여짐
s.listed_series = {SET_MALEFIC}

function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(27564031)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.filter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsControlerCanBeChanged()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,tp,0)
end
function s.filter2(c,tg,e,tp)
	return (c:IsAttribute(tg:GetAttribute()) or c:IsRace(tg:GetRace()) 
		or c:IsLevel(tg:GetLevel()) or c:IsAttack(tg:GetTextAttack()) or (tg:HasDefense() and c:IsDefense(tg:GetTextDefense())))
		and c:IsMonster() and c:IsSetCard(SET_MALEFIC) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if g then
		Duel.HintSelection(g)
		if Duel.GetControl(g,tp) and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,g,e,tp) 
		and Duel.SelectYesNo(tp, aux.Stringid(id,1))then 
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,g,e,tp)
			if #g2>0 then
				Duel.SpecialSummon(g2,0,tp,tp,true,false,POS_FACEUP)
			end
		end
	end
	
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_MALEFIC) and c:IsOnField() and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end