import J4Org: org_string_documented_item_array

@testset "real_code_with_link" begin
    filename="$(dirname(@__FILE__))/code_examples/real_code_with_link.jl"
    documented_items=create_documented_item_array([filename])
    s = org_string_documented_item_array(documented_items,header_level=-1,link_prefix="")
    @test s==" @@latex:\\phantomsection@@  <<foo>>\n#+BEGIN_SRC julia :eval never :exports code\nfoo()\n#+END_SRC\n#+BEGIN_QUOTE\nfoo\n[[foo][foo(...)]]\n[[foo2][foo2(...)]]\n_faa_\n[[faa][org]]\n\"[[foo][foo(...)]]\"\n#+END_QUOTE\n[[file:$(filename)::1][real_code_with_link.jl:1]]\n @@latex:\\phantomsection@@  <<foo2>>\n#+BEGIN_SRC julia :eval never :exports code\nfoo2()\n#+END_SRC\n[[file:$(filename)::10][real_code_with_link.jl:10]]\n"
end; 
