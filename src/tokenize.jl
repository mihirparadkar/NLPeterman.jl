function tokenize(
    lang::Language,
    text::String,
)
    strtoks = nltk_word_tokenize(text)
    lexemes = Lexeme.(strtoks)

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
    Doc(tokens)
end
