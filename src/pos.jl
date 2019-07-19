tag_to_idx = Dict(
    "ADJ" => 1,
    "ADP" => 2,
    "ADV" => 3,
    "AUX" => 4,
    "CONJ" => 5,
    "CCONJ" => 6, # U20
    "DET" => 7,
    "INTJ" => 8,
    "NOUN" => 9,
    "NUM" => 10,
    "PART" => 11,
    "PRON" => 12,
    "PROPN" => 13,
    "PUNCT" => 14,
    "SCONJ" => 15,
    "SYM" => 16,
    "VERB" => 17,
    "X" => 18,
    "EOL" => 19,
    "SPACE" => 20,
)

taglist = [
    "ADJ",
    "ADP",
    "ADV",
    "AUX",
    "CONJ",
    "CCONJ",
    "DET",
    "INTJ",
    "NOUN",
    "NUM",
    "PART",
    "PRON",
    "PROPN",
    "PUNCT",
    "SCONJ",
    "SYM",
    "VERB",
    "X",
    "EOL",
    "SPACE",
]

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
