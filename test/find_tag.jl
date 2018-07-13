import J4Org: extract_tag, find_tag, tags, link, line, tokenized

@testset "extract_tag" begin

    r=extract_tag(tokenized("one_word"),1)
    @test r==nothing

    r=extract_tag(tokenized("#one_word"),1)
    @test r==nothing

    r=extract_tag(tokenized("#+one_word"),1)
    @test r!=nothing
    @test length(tags(r))==1
    @test line(r) == 1
    
    r=extract_tag(tokenized("#+one_word, two_Words L:my_link   "),1)
    @test r!=nothing
    @test length(tags(r))==2
    @test tags(r)[1] == "one_word"
    @test tags(r)[2] == "two_Words"
    @test link(r) == "my_link"
    @test line(r) == 1

    # also support "# +"
    r=extract_tag(tokenized("# +one_word, two_Words L:my_link   "),1)
    @test r!=nothing
    @test length(tags(r))==2
    @test tags(r)[1] == "one_word"
    @test tags(r)[2] == "two_Words"
    @test link(r) == "my_link"
    @test line(r) == 1

end;

@testset "extract_tag" begin

    filename = "$(dirname(@__FILE__))/code_examples/basic.jl"
    code=readcode(filename)
    t=tokenized(code)
    
    @test extract_tag(t,1)==nothing
    @test extract_tag(t,2)==nothing
    @test extract_tag(t,3)!=nothing
end;

@testset "find_tag" begin

    filename = "$(dirname(@__FILE__))/code_examples/basic.jl"

    code=readcode(filename)
    t=tokenized(code)

    r = find_tag(t,1)
    @test line(r) == 3
    @test tags(r) == ["MyTag1";"MyTag2"]

    r = find_tag(t,skip(r))
    @test r==nothing
end;
