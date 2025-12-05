-- 인조인간-사이코 에스퍼
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_JINZO,s.ffilter)
    --change name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(CARD_JINZO)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.negcon)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetTarget(s.pltg)
	e3:SetOperation(s.plop)
	c:RegisterEffect(e3)
end
s.listed_names = {CARD_JINZO}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_MACHINE,fc,sumtype,tp) or c:GetLevel()==5
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainDisablable(ev) and e:GetHandler():GetFlagEffect(id)==0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,re:GetHandler():GetCode()),tp,0,LOCATION_STZONE,1,nil)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if Duel.GetFlagEffectLabel(tp,id)==cid or not Duel.SelectEffectYesNo(tp,c) then return end
	c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1,cid)
	Duel.Hint(HINT_CARD,0,id)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
function s.spfilter(c)
	return ((c:IsFaceup() and c:IsLocation(LOCATION_MZONE)) or c:IsLocation(LOCATION_GRAVE)) and c:IsMonster()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and s.spfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetFirstTarget()
	if d:IsRelateToEffect(e) and not d:IsImmuneToEffect(e) then
		if Duel.GetLocationCount(1-tp,LOCATION_SZONE)==0 then
			Duel.SendtoGrave(d,REASON_RULE,nil,PLAYER_NONE)
		elseif Duel.MoveToField(d,tp,1-tp,LOCATION_SZONE,POS_FACEUP,d:IsMonsterCard()) then
			--Treated as a Continuous Trap
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_TRAP|TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
			d:RegisterEffect(e1)
		end
	end
end