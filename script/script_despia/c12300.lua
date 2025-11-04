-- 데스피아의 드래그마트루그
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.rlcon)
    e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)

    local e3=e2:Clone()
	e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.fucon)
    c:RegisterEffect(e3)

end

function s.disfilter(c)
	return c:GetSummonLocation()==LOCATION_EXTRA
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and Duel.GetCurrentChain()==0 and eg:IsExists(s.disfilter,1,nil)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(Card.IsPreviousLocation,nil,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsPreviousLocation,nil,LOCATION_EXTRA)
	Duel.NegateSummon(g)
	Duel.Destroy(g,REASON_EFFECT)
end

function s.rlcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	return c:IsReason(REASON_RITUAL) and c:IsPreviousLocation(LOCATION_ONFIELD|LOCATION_HAND)
end
function s.fucon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (r&REASON_FUSION)==REASON_FUSION and c:IsPreviousLocation(LOCATION_ONFIELD|LOCATION_HAND)
		and c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and c:IsFaceup()
end
function s.tgfilter(c)
	return c:IsMonster() and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil)
	and Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_EXTRA,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_EXTRA)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local g2=Duel.SelectMatchingCard(1-tp,s.tgfilter,1-tp,LOCATION_EXTRA,0,1,1,nil)
	if #g1>0 then
		Duel.SendtoGrave(g1,REASON_EFFECT)
	end
	if #g2>0 then
		Duel.SendtoGrave(g2,REASON_EFFECT)
	end
end

