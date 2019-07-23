module NLPeterman

import WordTokenizers
import MurmurHash3
import FileIO


include("data.jl")
include("featurize.jl")
include("pos.jl")
include("models/averagedperceptron.jl")
include("models/pos_lookup.jl")
include("pretrained.jl")

end # module
