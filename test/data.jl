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
