function tokenize(
    lang::Language{Val{:en}},
    text::String,
)
    vocab = lang.vocab
    strtoks = nltk_word_tokenize(text)
    tokens = Vector{Token}(undef, length(strtoks))

    for (i, substr) in enumerate(strtoks)
        orth = hash(substr)
        #=
        row = vocab.hash2row[orth]
        len = length(substr)
        lower = hash(lowercase(substr))
        shape = hash(strshape(substr))
        prefix = hash(SubString(tok,1:1))
        suffix = hash(length(tok) >= 3 ? SubString(tok, 1:3) : tok)
        =#
        tokens[i] = Token(
            #=
            Lexeme(
                row,
                len,
                orth,
                lower,
                shape,
                prefix,
                suffix,
            ),
            =#
            vocab.lexemes[orth]
            i,
        )
    end
    Doc(tokens, vocab)
end

function strshape(tok::T) where {T}
    tmp1 = replace(tok, r"([a-z])"=>s"x")
    tmp2 = replace(tmp1, r"([A-Z])"=>s"X")
    tmp3 = replace(tmp2, r"(\d)"=>s"d")
    tmp3
end
