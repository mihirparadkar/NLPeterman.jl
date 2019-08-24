using Test
import NLPeterman; const NLP = NLPeterman

@testset "Suffix" begin
    @test NLP.suffix("", 1) == ""
    @test NLP.suffix("a", 1) == "a"
    @test NLP.suffix("a", 3) == "a"
    @test NLP.suffix("the", 2) == "he"
    @test NLP.suffix("pequeño", 2) == "ño"
    @test NLP.suffix(SubString("pequeño", 2, 8), 2) == "ño"
end

@testset "Prefix" begin
    @test NLP.prefix("", 1) == ""
    @test NLP.prefix("a", 1) == "a"
    @test NLP.prefix("a", 3) == "a"
    @test NLP.prefix("the", 2) == "th"
    @test NLP.prefix("pequeño", 6) == "pequeñ"
    @test NLP.prefix(SubString("pequeño", 1, 8), 6) == "pequeñ"
end

@testset "Word Shape" begin
    @test NLP.wordshape("") == ""
    @test NLP.wordshape("a") == "x"
    @test NLP.wordshape("The") == "Xxx"
    @test NLP.wordshape("12") == "dd"
end

@testset "Lexeme" begin
    lex = NLP.Lexeme("pequeño")
    for nm in fieldnames(NLP.Lexeme)
        @test eval(:($NLP.$nm($lex) == $lex.$nm))
    end
end

@testset "Token" begin
    lex = NLP.Lexeme("pequeño")
    tok = NLP.Token(lex, 1)
    for nm in fieldnames(NLP.Lexeme)
        @test eval(:($NLP.$nm($tok) == $tok.lex.$nm))
    end
    @test NLP.upos(tok) == 1
    @test NLP.uposname(tok) == "ADJ"
end

@testset "ProcessedDoc" begin
    lexs = NLP.Lexeme.(["Go", "!"])
    toks = NLP.Token.(lexs, [17, 14])
    pd = NLP.ProcessedDoc([toks])
    @test pd[1] == pd.tokens[1]
    @test NLP.uposname.(pd[1]) == ["VERB", "PUNCT"]
end
