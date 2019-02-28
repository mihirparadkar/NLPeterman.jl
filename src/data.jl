mutable struct Lexeme
    row::Int64
    length::Int64
    orth::UInt64
    lower::UInt64
    shape::UInt64
    prefix::UInt64
    suffix::UInt64
end

mutable struct Vocab
    strings::Dict{UInt64, SubString{String}}
    lexemes::Dict{UInt64, Lexeme}
    hash2row::Dict{UInt64, Int64}
    vectors::Matrix{Float32}
end

function addlexeme!(v::Vocab, s::AbstractString)
    orth = hash(s)
    row = haskey(vocab.hash2row, orth) ? vocab.hash2row[orth] : 1
    len = length(s)
    lower = hash(lowercase(s))
    shape = hash(wordshape(s))
    prefix = hash(SubString(tok,1:1))
    suffix = hash(length(tok) >= 3 ? SubString(tok, 1:3) : tok)
    newlex = Lexeme(
        row,
        len,
        orth,
        lower,
        shape,
        prefix,
        suffix,
    )
    v.strings[orth] = s
    v.lexemes[orth] = newlex
    v.hash2row[orth] = row
    v
end

"""
Taken from spaCy shape function
"""
function wordshape(text::T) where {T}
    if length(text) >= 100
        return "LONG"
    end
    len = length(text)
    shape_builder = IOBuffer()
    last = '\0'
    shape_char = '\0'
    seq = 0
    for char in text
        if isletter(char)
            shape_char = isuppercase(char) ? 'X' : 'x'
        elseif isnumeric(char)
            shape_char = 'd'
        else
            shape_char = char
        end
        if shape_char == last
            seq += 1
        else
            seq = 0
            last = shape_char
        end
        if seq < 4
            print(shape_builder, shape_char)
        end
    end
    String(take!(shape_builder))
end

mutable struct Token
    lex::Lexeme

    # More fields to be added later
    # pos::Int64

    idx::Int64
end

mutable struct Doc
    tokens::Vector{Token}
    vocab::Vocab
end

struct Language{T}
    vocab::Vocab
    pipeline::Array
end
