/*
    Addon id: 6caa0056-2e1c-4a99-9ba2-8bb2fe3a0232
    Version: v1.5.7 (stable)
*/

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c24aa0f51c3521dc86ce13039a612ad6a262a16b758cd0bdb3462448d89950ac
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 15478a1827bdd0ab07064f24626a05e7e8fa2b4b1e33baa627f3f8cb0b843238

--[[ Make sure sentence exist and also langage exist]]
function CharacterCreator.GetSentence(string)
    local result = "Lang Problem"
    local sentence = istable(CharacterCreator.Language[CharacterCreator.Lang]) and CharacterCreator.Language[CharacterCreator.Lang][string] or "Lang Problem"
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c24aa0f51c3521dc86ce13039a612ad6a262a16b758cd0bdb3462448d89950ac

    if istable(CharacterCreator.Language[CharacterCreator.Lang]) and isstring(sentence) then
        result = sentence
    elseif istable(CharacterCreator.Language["en"]) and isstring(CharacterCreator.Language["en"][sentence]) then
        result = CharacterCreator.Language["en"][sentence]
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103836
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a45b4a0371527980aa45a614f82b3b1b5c437fbaab42e40b73e1d1d0309ff781

    return result
end
