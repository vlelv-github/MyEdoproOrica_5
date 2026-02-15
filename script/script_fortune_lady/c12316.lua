-- 점쟁이 마녀 카
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtgtg)
	e1:SetOperation(s.thtgop)
	c:RegisterEffect(e1)
end
s.listed_names = {id}
s.listed_series = {SET_FORTUNE_LADY,SET_FORTUNE_FAIRY}
function s.thfilter(c)
    return not c:IsCode(id) and (c:IsSetCard(SET_FORTUNE_LADY) or c:IsSetCard(SET_FORTUNE_FAIRY)) and c:IsMonster()
end
function s.thtgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemove() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.thtgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsLocation(LOCATION_HAND|LOCATION_MZONE) then return end
    if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then 
	    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        Duel.ShuffleDeck(tp)
		Duel.MoveToDeckTop(g)
		if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            Duel.Draw(tp,1,REASON_EFFECT)
            --Cannot Special Summon from the Extra Deck, except Synchro monsters
            local e0=Effect.CreateEffect(e:GetHandler())
            e0:SetDescription(aux.Stringid(id,2))
            e0:SetType(EFFECT_TYPE_FIELD)
            e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
            e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e0:SetTargetRange(1,0)
            e0:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO) end)
            e0:SetReset(RESET_PHASE|PHASE_END)
            Duel.RegisterEffect(e0,tp)
            --Clock Lizard check
            aux.addTempLizardCheck(e:GetHandler(),tp,function(_,c) return not c:IsOriginalType(TYPE_SYNCHRO) end)

            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_SUMMON_SUCCESS)
            e1:SetOperation(s.sumop)
            e1:SetReset(RESET_PHASE|PHASE_END)
            Duel.RegisterEffect(e1,tp)
            local e2=e1:Clone()
            e2:SetCode(EVENT_SPSUMMON_SUCCESS)
            Duel.RegisterEffect(e2,tp)
            aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
        end
         
    end

end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),1,nil) then
		Duel.SetChainLimitTillChainEnd(function(e,rp,tp) return tp==rp end)
	end
end