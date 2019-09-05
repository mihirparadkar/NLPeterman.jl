# NLPeterman

NLPeterman aims to be a package for performant natural language processing.

# Usage

Using NLPeterman functionality out of the box requires downloading pre-trained models
```julia
import NLPeterman; const NLP = NLPeterman
# Loads the tagger component
tagger = NLP.loadmodel("tagger-en-v0.1.0", "tagger")
```

After loading the model, create a pipeline for processing text.
```julia
pipe = NLP.Pipeline(tagger)
pd = pipe("All work and no play makes Jack a dull boy!")
NLP.uposname.(pd[1])
#=
11-element Array{String,1}:
 "DET"  
 "NOUN" 
 "CCONJ"
 "DET"  
 "NOUN" 
 "VERB" 
 "PROPN"
 "DET"  
 "ADJ"  
 "NOUN" 
 "PUNCT"
=#
```

# Available Models

```julia
tagger-en-v0.1.0 : tagger
```
