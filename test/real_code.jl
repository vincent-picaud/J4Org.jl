import J4Org: org_string_documented_item_array

@testset "real_code_with_link" begin
    filename="$(dirname(@__FILE__))/code_examples/real_code_with_link.jl"
    documented_items=create_documented_item_array([filename])
    s = org_string_documented_item_array(documented_items,header_level=-1,link_prefix="")
    @test s==" @@latex:\\phantomsection@@  <<foo>>\n#+BEGIN_SRC julia :eval never :exports code\nfoo()\n#+END_SRC\n#+BEGIN_QUOTE\nfoo\n[[foo][foo(...)]]\n[[foo2][foo2(...)]]\n[[faa][org]]\n\"[[foo][foo(...)]]\"\n#+END_QUOTE\n[[file:$(filename)::1][real_code_with_link.jl:1]]\n @@latex:\\phantomsection@@  <<foo2>>\n#+BEGIN_SRC julia :eval never :exports code\nfoo2()\n#+END_SRC\n[[file:$(filename)::9][real_code_with_link.jl:9]]\n"
end;



# Test new named arg: with_body 
@testset "real_code_with_body" begin
    filename="$(dirname(@__FILE__))/code_examples/real_code_with_link.jl"
    documented_items=create_documented_item_array([filename])
    s = org_string_documented_item_array(documented_items,header_level=-1,link_prefix="",with_body=true)
    @test s==" @@latex:\\phantomsection@@  <<foo>>\n#+BEGIN_SRC julia :eval never :exports code\nfoo()=0\n\n\n#+END_SRC\n#+BEGIN_QUOTE\nfoo\n[[foo][foo(...)]]\n[[foo2][foo2(...)]]\n[[faa][org]]\n\"[[foo][foo(...)]]\"\n#+END_QUOTE\n[[file:/home/picaud/GitHub/J4Org.jl/test/code_examples/real_code_with_link.jl::1][real_code_with_link.jl:1]]\n @@latex:\\phantomsection@@  <<foo2>>\n#+BEGIN_SRC julia :eval never :exports code\nfoo2()=0\n#+END_SRC\n[[file:/home/picaud/GitHub/J4Org.jl/test/code_examples/real_code_with_link.jl::9][real_code_with_link.jl:9]]\n"
end;

@testset "real_code_with_body_2" begin
    filename="$(dirname(@__FILE__))/code_examples/real_code_with_body.jl"
    documented_items=create_documented_item_array([filename])
    s = org_string_documented_item_array(documented_items,header_level=-1,link_prefix="",with_body=true)
    @test s==" @@latex:\\phantomsection@@  <<foo>>\n#+BEGIN_SRC julia :eval never :exports code\nfoo()=0\n\n\n#+END_SRC\n#+BEGIN_QUOTE\nfoo\n[[foo][foo(...)]]\n[[foo2][foo2(...)]]\n[[faa][org]]\n\"[[foo][foo(...)]]\"\n#+END_QUOTE\n[[file:/home/picaud/GitHub/J4Org.jl/test/code_examples/real_code_with_link.jl::1][real_code_with_link.jl:1]]\n @@latex:\\phantomsection@@  <<foo2>>\n#+BEGIN_SRC julia :eval never :exports code\nfoo2()=0\n#+END_SRC\n[[file:/home/picaud/GitHub/J4Org.jl/test/code_examples/real_code_with_link.jl::9][real_code_with_link.jl:9]]\n"
end; 
