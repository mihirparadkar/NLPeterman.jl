using Test
import NLPeterman; const NLP = NLPeterman

@testset "Averaged Perceptron Construction" begin
    ap = NLP.AveragedPerceptron(3)
    @test length(ap.bias) == 3
    @test size(ap.tagweights) == (4, 3)
end

@testset "Averaged Perceptron Update" begin
    ap = NLP.AveragedPerceptron(3)
    features = NLP.hash.(["very", "nice", "!"])
    prevtag = 1
    truth = 3
    guess = 1
    NLP.update!(ap, truth, guess, features, prevtag)
    @test ap.nupdates == 1
    @test ap.totals[(1, features[1], 3)] == 0
    @test ap.tstamps[(1, features[1], 3)] == 1
    @test ap.weights[(1, features[1])][3] == 1
end
