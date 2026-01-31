-- 암흑계의 마물 그레이
local s,id=GetID()
function s.initial_effect(c)
   --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DARK_WORLD}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.copyfilter(c,e,tp,eg,ep,ev,re,r,rp)
	return c:IsAbleToRemoveAsCost() and c:IsSetCard(SET_DARK_WORLD) and c:IsMonster()
	and not c:IsCode(99458769,34968834,15667446,32619583,78004197,33731070,7623640,id)
	and s.activable(c,e,tp,eg,ep,ev,re,r,rp)
end
function s.activable(c,e,tp,eg,ep,ev,re,r,rp) 
	local effs = {c:GetOwnEffects()}
	for k, eff in ipairs(effs) do
		if bit.band(eff:GetType(), EFFECT_TYPE_SINGLE)~=0 and eff:GetCode()==EVENT_TO_GRAVE then 
			local tg = eff:GetTarget()
			local op = eff:GetOperation()
			if tg then 
				if tg(e, tp, eg, ep, ev, re, r, 1-tp, 0) then 
					return true
				else 
					return false
				end
			end
		end
	end
	return false
end
function s.filter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		return tg and tg(e,tp,eg,ep,ev,re,r,1-tp,0,chkc)
	end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 제외할 암흑계가 있어야 함
		return e:GetHandler():IsDiscardable() and Duel.IsExistingMatchingCard(s.copyfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) 
	end
	e:SetLabel(0)
	Duel.SendtoGrave(e:GetHandler(),REASON_DISCARD|REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.copyfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp):GetFirst()
	if not Duel.Remove(g,POS_FACEUP,REASON_COST) then return end

	local effs = {g:GetOwnEffects()}
	local copy = false
	for k, eff in ipairs(effs) do
		if bit.band(eff:GetType(), EFFECT_TYPE_SINGLE)~=0 and eff:GetCode()==EVENT_TO_GRAVE then 
			local tg = eff:GetTarget()
			local op = eff:GetOperation()
			e:SetLabel(tp)
			-- 스노우의 경우 대상 지정 후 특수 소환까지
			-- if g:IsCode(60228941) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			-- and Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_GRAVE,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(g:GetCode(),1))then 
			-- 	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
			-- 	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			-- 	local g=Duel.SelectTarget(tp,s.filter2,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
			-- end
			-- 마신왕 레인, 파알, 군신왕 실바
			if g:IsCode(41406613, 3289027, 12312) then 
				e:SetLabel(1)
			end


			if tg then 
				tg(e, tp, eg, ep, ev, re, r, 1-tp, 1)
			end
			eff:SetLabel(1-tp)
			--e:SetLabel(tp)
			e:SetLabelObject(eff)
			e:SetProperty(eff:GetProperty())
			
			
			
			
			Duel.ClearOperationInfo(0)
			copy = true
			
		end
	end
	if not copy then return false end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		--e:SetLabel(te:GetLabel())
		--e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,1-tp) end
		--te:SetLabel(e:GetLabel())
		--te:SetLabelObject(e:GetLabelObject())
	end
end

function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_HAND) and (r&REASON_EFFECT+REASON_DISCARD)==REASON_EFFECT+REASON_DISCARD
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local tc2=Duel.SelectMatchingCard(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,1,nil):GetFirst()
	if not tc2 then return end
	Duel.HintSelection(tc2)
	if tc2:IsCanBeDisabledByEffect(e) then
		--Negate its effects
		if tc2 then
			Duel.NegateRelatedChain(tc2,RESET_TURN_SET)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc2:RegisterEffect(e2)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc2:RegisterEffect(e3)
		end
	end
end