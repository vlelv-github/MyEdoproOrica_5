-- 암흑계의 군신왕 실바
local s,id=GetID()
function s.initial_effect(c)
   --Special Summon itself from GY 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

    --Search 1 Level 5 or higher "Dark World" monster/Special Summon 1 Level 4 or lower "Dark World" monster if discarded by opponent
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)

    --Cannot be destroyed by effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
s.listed_series={SET_DARK_WORLD}
function s.spcfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_DARK_WORLD) and c:IsLevelBelow(5) and c:IsAbleToHandAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_MZONE,0,nil)
	local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
	for _,te in ipairs(eff) do
		local op=te:GetOperation()
		if not op or op(e,c) then return false end
	end
	local tp=c:GetControler()
	return aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RTOHAND,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoHand(g,nil,REASON_COST)
	g:DeleteGroup()
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==1-tp and c:IsPreviousControler(tp) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	return c:IsPreviousLocation(LOCATION_HAND) and (r&REASON_EFFECT+REASON_DISCARD)==REASON_EFFECT+REASON_DISCARD
end
function s.thfilter(c)
	return c:IsSetCard(SET_DARK_WORLD) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	local opp_chk=e:GetLabel()
	if opp_chk==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
        Duel.SetTargetPlayer(tp)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_HAND)
        
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_DARK_WORLD) and c:IsLevelBelow(4) and 
		((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,g)
	local opp_chk=e:GetLabel()
    --Debug.Message(opp_chk)
	if opp_chk==0 then return end
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    local sg=Duel.GetFieldGroup(p,0,LOCATION_HAND)
    if #sg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
    Duel.ConfirmCards(p,sg)
    Duel.Hint(HINT_SELECTMSG,p,HINTMSG_REMOVE)
    local sg=sg:FilterSelect(p,Card.IsAbleToRemove,1,1,nil)
    Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
    Duel.ShuffleHand(1-p)
end