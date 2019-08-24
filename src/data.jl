mutable struct Lexeme
    length::Int64
    orth::UInt64
    lower::UInt64
    shape::UInt64
    prefix::UInt64
    suffix::UInt64
end

for nm in fieldnames(Lexeme)
    if nm in names(Base)
        eval(:(import Base.$nm))
        eval(:($Base.$nm(l::Lexeme) = l.$nm))
    else
        eval(:($nm(l::Lexeme) = l.$nm))    
    end
end

function Lexeme(s::AbstractString)
    orth = hash(s)
    len = length(s)
    lower = hash(lowercase(s))
    shape = hash(wordshape(s))
    prefx = hash(prefix(s, 1))
    suffx = hash(suffix(s, 3))
    Lexeme(
        len,
        orth,
        lower,
        shape,
        prefx,
        suffx,
    )
end

function suffix(s::AbstractString, n::Int64)
    lastind, slen = lastindex(s), length(codeunits(s))
    SubString(s, prevind(s, slen + 1, min(n, length(s))), lastind)
end

function prefix(s::AbstractString, n::Int64)
    SubString(s, 1, min(nextind(s, 0, n), length(s)))
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
    pos::Int64
end

for nm in fieldnames(Lexeme)
    if nm in names(Base)
        eval(:($Base.$nm(t::Token) = t.lex.$nm))
    else
        eval(:($nm(t::Token) = t.lex.$nm))    
    end
end

upos(t::Token) = t.pos
uposname(t::Token) = uposlist[t.pos]

mutable struct ProcessedDoc
    tokens::Vector{Vector{Token}}
end

struct Pipeline
    sentencer
    tokenizer
    tagger
end

function (Lang::Pipeline)(text::String)
    sents = Lang.sentencer(text)
    tokens = Lang.tokenizer.(sents)
    lexemes = [Lexeme.(sent) for sent in tokens]
    tags = Lang.tagger.(lexemes)
    ProcessedDoc([Token.(lexeme_sent, tag_sent) for (lexeme_sent, tag_sent) in zip(lexemes, tags)])
end

Base.getindex(p::ProcessedDoc, sent) = p.tokens[sent]
