using Test
import NLPeterman; const NLP = NLPeterman

@testset "Extract at Relative Positions" begin
    sent = NLP.Lexeme.(split("All work and no play makes Jack a dull boy !"))
    @test size(NLP.extract_positions(sent, :lower, 0:0)) == (1, 11)
end
