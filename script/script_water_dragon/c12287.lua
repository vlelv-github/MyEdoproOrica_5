-- 워터 드래곤-테르폴리머
local s,id=GetID()
function s.initial_effect(c)

	c:EnableReviveLimit()

	-- 융합 소환 불가
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e3:SetValue(ATTRIBUTE_FIRE)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(2)
	e4:SetCondition(s.ngcon)
	e4:SetCost(s.ngcost)
	e4:SetOperation(s.ngop)
	c:RegisterEffect(e4)
end

-- "워터 드래곤", "워터 드래곤-클러스터", "옥시게돈", "하이드로게돈"의 카드명이 쓰여짐
s.listed_names = {85066822, 6022371, 58071123, 22587018}

function s.splimit(e,se,sp,st)
    return not (st==SUMMON_TYPE_FUSION)
end

function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.chk,1,nil,sg,Group.CreateGroup(),85066822,6022371)
end
function s.chk(c,sg,g,code,...)
	if not c:IsCode(code) then return false end
	local res
	if ... then
		g:AddCard(c)
		res=sg:IsExists(s.chk,1,g,sg,g,...)
		g:RemoveCard(c)
	else
		res=true
	end
	return res
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp)
	local g1=rg:Filter(Card.IsCode,nil,85066822)
	local g2=rg:Filter(Card.IsCode,nil,6022371)
	local g=g1:Clone()
	g:Merge(g2)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and #g1>0 and #g2>0
		and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetReleaseGroup(tp)
	local g1=rg:Filter(Card.IsCode,nil,85066822)
	local g2=rg:Filter(Card.IsCode,nil,6022371)
	g1:Merge(g2)
	local g1=aux.SelectUnselectGroup(g1,e,tp,2,2,s.rescon,1,tp,HINTMSG_RELEASE,s.rescon,nil,true)
	if #g1>0 then
		g1:KeepAlive()
		e:SetLabelObject(g1)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g1=e:GetLabelObject()
	if not g1 then return end
	Duel.Release(g1,REASON_COST)
	g1:DeleteGroup()
end

function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsMonsterEffect() 
	and re:GetHandler():IsAttribute(ATTRIBUTE_FIRE) and Duel.IsChainNegatable(ev)
end
function s.filter_oxy(c,tp)
	return c:IsCode(58071123) and c:IsMonster() and c:IsAbleToDeckAsCost()
end
function s.filter_hy(c,tp)
	return c:IsCode(22587018) and c:IsMonster() and c:IsAbleToDeckAsCost()
end
function s.ngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=(Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) 
		and Duel.IsExistingMatchingCard(s.filter_oxy,tp,LOCATION_GRAVE,0,1,nil))
	local b2=(Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.IsExistingMatchingCard(s.filter_hy,tp,LOCATION_GRAVE,0,1,nil))
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.filter_oxy,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0) 
		
	elseif op==2 then
		e:SetCategory(CATEGORY_DISABLE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.filter_hy,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
	end
end
function s.ngop(e,tp,eg,ep,ev,re,r,rp) 
	local op=e:GetLabel()
	if op==1 then
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		Duel.Destroy(g,REASON_EFFECT)
		
	elseif op==2 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
        for oc in aux.Next(g) do
            Duel.NegateRelatedChain(oc,RESET_TURN_SET)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            oc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            oc:RegisterEffect(e2)
        end
	end
end