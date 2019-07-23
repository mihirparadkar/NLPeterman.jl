#####################################################################
# Averaged Perceptron implementation
#####################################################################
mutable struct AveragedPerceptron
    weights::Dict{Tuple{Int64, UInt64}, Vector{Float32}}
    totals::Dict{Tuple{Int64, UInt64, Int64}, Float32}
    tstamps::Dict{Tuple{Int64, UInt64, Int64}, Int64}
    tagweights::Matrix{Float32}
    tagtotals::Matrix{Float32}
    tagtstamps::Matrix{Int64}
    bias::Vector{Float32}
    biastotals::Vector{Float32}
    biaststamps::Vector{Int64}
    nupdates::Int64
end

function AveragedPerceptron(n_classes::Int64)
    weights = Dict{Tuple{Int64, UInt64}, Vector{Float32}}()
    totals = Dict{Tuple{Int64, UInt64, Int64}, Float32}()
    tstamps = Dict{Tuple{Int64, UInt64, Int64}, Int64}()
    bias = zeros(Float32, n_classes)
    biastotals = copy(bias)
    biaststamps = zeros(Int64, n_classes)
    tagweights = zeros(Float32, n_classes + 1, n_classes) # accomodate padding
    tagtotals = copy(tagweights)
    tagtstamps = zeros(Int64, n_classes + 1, n_classes)
    nupdates = 0
    AveragedPerceptron(
        weights, totals, tstamps,
        tagweights, tagtotals, tagtstamps,
        bias, biastotals, biaststamps, nupdates
    )
end

function predict_single!(ap::AveragedPerceptron, features::Vector{UInt64}, prevtag::Int64, scores::Vector{Float32})
    # featidx is in 1:num_features, featvalue is sparse
    for (featidx, featvalue) in enumerate(features)
        if (featidx, featvalue) in keys(ap.weights)
            weights = ap.weights[(featidx, featvalue)]
            scores .+= weights
        end
    end
    scores .+= ap.tagweights[prevtag,:]
    scores .+= ap.bias
    argmax(scores)
end

predict_single(ap, features, prevtag) = predict_single!(ap, features, prevtag, zeros(Float32, ap.bias))

function complete_prediction!(
    ap::AveragedPerceptron,
    features::Matrix{UInt64},
    labels::Array{Int64},
    seedtag::Int64 = (length(ap.bias) + 1)
)
    scores = zeros(Float32, length(ap.bias))
    firstlabel = (
        labels[1] != 0 ?
        labels[1] :
        predict_single!(ap, features[:,1], seedtag, scores)
    )
    labels[1] = firstlabel
    for i in 2:length(labels)
        if labels[i] == 0
            scores .= 0
            labels[i] = predict_single!(ap, features[:,i], labels[i-1], scores)
        end
    end
    labels
end

function predict_sequence(ap::AveragedPerceptron, features::Matrix{UInt64},
                                        seedtag::Int64 = (length(ap.bias) + 1))
    labels = zeros(Int64, size(features, 2))
    complete_prediction!(ap, features, labels, seedtag)
    labels
end

function update!(ap::AveragedPerceptron, truth::Int64, guess::Int64, features::Vector{UInt64}, prevtag::Int64)
    ap.nupdates += 1
    if truth == guess
        return ap
    end
    # If weights[(i,f)] doesn't exist, it needs to be created
    for (i, f) in enumerate(features)
        truthidx = (i, f, truth)
        guessidx = (i, f, guess)
        if !((i, f) in keys(ap.weights))
            ap.weights[(i, f)] = zeros(Float32, length(ap.bias))
        end
        ap.totals[truthidx] = (
            get(ap.totals, truthidx, 0.0f0)
            + (ap.nupdates - get(ap.tstamps, truthidx, 0)) * ap.weights[(i, f)][truth]
        )
        ap.tstamps[truthidx] = ap.nupdates
        ap.weights[(i, f)][truth] += 1.0f0

        ap.totals[guessidx] = (
            get(ap.totals, guessidx, 0.0f0)
            + (ap.nupdates - get(ap.tstamps, guessidx, 0)) * ap.weights[(i, f)][guess]
        )
        ap.tstamps[guessidx] = ap.nupdates
        ap.weights[(i, f)][guess] -= 1.0f0
    end
    ap.tagtotals[prevtag, truth] += (ap.nupdates - ap.tagtstamps[prevtag, truth]) * ap.tagweights[prevtag, truth]
    ap.tagtstamps[prevtag, truth] = ap.nupdates
    ap.tagweights[prevtag, truth] += 1.0f0

    ap.tagtotals[prevtag, guess] += (ap.nupdates - ap.tagtstamps[prevtag, guess]) * ap.tagweights[prevtag, guess]
    ap.tagtstamps[prevtag, guess] = ap.nupdates
    ap.tagweights[prevtag, guess] -= 1.0f0

    ap.biastotals[truth] += (ap.nupdates - ap.biaststamps[truth]) * ap.bias[truth]
    ap.biaststamps[truth] = ap.nupdates
    ap.bias[truth] += 1.0f0

    ap.biastotals[guess] += (ap.nupdates - ap.biaststamps[guess]) * ap.bias[guess]
    ap.biaststamps[guess] = ap.nupdates
    ap.bias[guess] -= 1.0f0
    return ap
end

function average_weights!(ap::AveragedPerceptron)
    new_feat_weights = zeros(Float32, length(ap.bias))
    for ((feattype, feat), weights) in ap.weights
        for (clas, weight) in enumerate(weights)
            param = (feattype, feat, clas)
            total = get(ap.totals, param, 0.0f0)
            total += (ap.nupdates - get(ap.tstamps, param, 0)) * weight
            averaged = total / ap.nupdates
            new_feat_weights[clas] = averaged
        end
        ap.weights[(feattype, feat)] .= new_feat_weights
    end
    ap.tagtotals .+= (ap.nupdates .- ap.tagtstamps) .* ap.tagweights
    ap.tagweights .= ap.tagtotals ./ ap.nupdates
    ap.biastotals .+= (ap.nupdates .- ap.biaststamps) .* ap.bias
    ap.bias .= ap.biastotals ./ ap.nupdates
end

struct GreedyApTagger
    features::Vector{Symbol}
    positions::Vector
    lookup::Dict{UInt64,Int64}
    model::AveragedPerceptron
end

function (g::GreedyApTagger)(sent::Vector{Lexeme})
    labels = zeros(Int64, length(sent))
    for (i, l) in enumerate(sent)
        if l.lower in keys(g.lookup)
            labels[i] = g.lookup[l.lower]
        end
    end
    featmat = sent2feats(sent, g.features, g.positions)
    complete_prediction!(g.model, featmat, labels, length(taglist) + 1)
    labels
end
