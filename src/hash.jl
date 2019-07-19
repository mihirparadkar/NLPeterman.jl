function hash(s::AbstractString)
    MurmurHash3.mmhash128_8_c(s, 0x00000000)[1]
end
