const deps = joinpath(@__DIR__, "..", "deps")
const url = "https://storage.googleapis.com/mihirparadkar/NLPeterman/"

function getmodel(name)
    fname = "$(name).jld"
    mkpath(deps)
    cd(deps) do
        isfile(fname) || Base.download(joinpath("$url",fname), fname)
    end
end

"""
Given a model name and component, downloads the corresponding
model file and loads the model from it

Example:
```julia
tagger = loadmodel("tagger-en-v0.1.0", "tagger")
```
"""
function loadmodel(name, componentname)
    getmodel(name)
    FileIO.load(joinpath(deps, "$(name).jld"), componentname)
end

"""
A convenience constructor for the Pipeline type that assumes a sentence splitter and word tokenizer
"""
function Pipeline(tagger; sentencer=WordTokenizers.split_sentences, tokenizer=WordTokenizers.nltk_word_tokenize)
    Pipeline(sentencer, tokenizer, tagger)
end

