module NLPeterman

import WordTokenizers

include("data.jl")
include("tokenize.jl")
include("featurize.jl")
include("models/averagedperceptron.jl")
include("models/pos_lookup.jl")
include("pos.jl")

end # module
