using Test
using J4Org

function readcode(filename::AbstractString)
    if VERSION < v"0.7"
        code = readstring(filename)
    else
        code = read(filename,String)
    end
    code
end 
 
# write your own tests here
@testset "J4Org" begin

    # initialize a default boxing module
    #
    initialize_boxing_module()
    
    # include test files 
    #
    include("tokenizer.jl")
    include("extract.jl")
    include("find_tag.jl")
    include("links.jl")
    include("evaluate.jl")
    include("documented_item.jl")
    include("real_code.jl")

    
    import J4Org:
    tokenized,
    find_tag,
    org_string_comment,
    org_string_code,
    identifier,
    create_documented_item,
    org_string_documented_item
    
    code_1 = String("
    # This is a test file

    #+MyTag
    #
    # My documentedItem
    #
    # line 2
    #
    function myFunction (;x::Float64=sin(1))
        return 0
    end
        ")
    
    @testset "code_1" begin
        @test !isempty(code_1)
        t=tokenized(code_1)
        r=find_tag(t,1,"MyTag")
        di=create_documented_item(t,tag_idx(r))
        @test org_string_comment(di,[di],[di],"","BoxingModule") == "#+BEGIN_QUOTE\nMy documentedItem\n\nline 2\n#+END_QUOTE\n"
        @test org_string_code(di) == "#+BEGIN_SRC julia :eval never :exports code\nfunction myFunction (;x::Float64=sin(1))\n#+END_SRC\n"
        @test identifier(di) == "myFunction"
        @test org_string_documented_item(di,[di],[di]) ==  "- @@latex:\\phantomsection@@ *=myFunction=* \n#+BEGIN_SRC julia :eval never :exports code\nfunction myFunction (;x::Float64=sin(1))\n#+END_SRC\n#+BEGIN_QUOTE\nMy documentedItem\n\nline 2\n#+END_QUOTE\n\n"
    end
    
end;
nothing
