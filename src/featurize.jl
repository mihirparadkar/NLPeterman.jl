function hash(s::AbstractString)
    MurmurHash3.mmhash128_8_c(s, 0x00000000)[1]
end

"""
Utility function to add empty strings to pad a vector of words.
Positions should be an array of relative positions to a sequence index.

For example, if positions is -1:1, that means the array is padded at the beginning and end
"""
function padsentence(sentence::Vector{String}, positions::T) where T
    start = min(minimum(positions), 0)
    stop = max(maximum(positions), 0)
    String[
        ["" for i in 1:-start];
        sentence;
        ["" for i in 1:stop];
    ]
end

function hash_vectorize(f::Function, sentence::Vector{String}, positions::T) where {T}
    hashed_padded = hash.(f.(padsentence(sentence, positions)))
    start_offset = min(minimum(positions), 0)
    feats = Matrix{UInt64}(undef, length(positions), length(sentence))
    for j in 1:lastindex(sentence)
        for (i, ind) in enumerate(j .- start_offset .+ positions)
            feats[i,j] = hashed_padded[ind]
        end
    end
    feats
end

function extract_positions(sentence::Vector{Lexeme}, feature::Symbol, positions::T) where T
    start = min(minimum(positions), 0)
    stop = max(maximum(positions), 0)
    padded = Lexeme[
        [Lexeme("") for i in 1:-start];
        sentence;
        [Lexeme("") for i in 1:stop];
    ]
    feats = Matrix{UInt64}(undef, length(positions), length(sentence))
    for j in 1:lastindex(sentence)
        for (i, ind) in enumerate(j .- start .+ positions)
            feats[i,j] = getproperty(padded[ind], feature)
        end
    end
    feats
end

function sent2feats(sentence::Vector{Lexeme}, features::Vector{Symbol}, positions)
    vcat((extract_positions(sentence, feature, position) for (feature,position) in zip(features, positions))...)
end
