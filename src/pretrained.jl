const deps = joinpath(@__DIR__, "..", "deps")
const url = "https://storage.googleapis.com/mihirparadkar/NLPeterman/"

function getmodel(name)
    fname = "$(name).jld"
    mkpath(deps)
    cd(deps) do
        isfile(fname) || Base.download(joinpath("$url",fname), fname)
    end
end

function loadmodel(name, componentname)
    getmodel(name)
    FileIO.load(joinpath(deps, "$(name).jld"), componentname)
end

function Language(tagger; sentencer=WordTokenizers.split_sentences, tokenizer=WordTokenizers.nltk_word_tokenize)
    Language(sentencer, tokenizer, tagger)
end
