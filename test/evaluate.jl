import J4Org: evaluate
import J4Org: with_hash_evaluate

@testset "extract_links" begin
    r=evaluate("4+5",Main)
    
end

# "#!" support
@testset "extract_links_full" begin
    s="# some text\n#\n#!x=5+6\n#!ones(5)\n#!y=5;\n# some text \n"
    r=with_hash_evaluate(s,"BoxingModule")
    @test r=="# some text\n#\n# #+BEGIN_SRC julia\n# x=5+6\n# ones(5)\n# y=5;\n# #+END_SRC\n# #+BEGIN_SRC julia\n# 11\n# 5-element Array{Float64,1}:\n#  1.0\n#  1.0\n#  1.0\n#  1.0\n#  1.0\n# #+END_SRC\n# some text \n"
end

# "# !" support 
@testset "extract_links_full" begin
    s="# some text\n#\n# !x=5+6\n# !ones(5)\n# !y=5;\n# some text \n"
    r=with_hash_evaluate(s,"BoxingModule")
    @test r=="# some text\n#\n# #+BEGIN_SRC julia\n# x=5+6\n# ones(5)\n# y=5;\n# #+END_SRC\n# #+BEGIN_SRC julia\n# 11\n# 5-element Array{Float64,1}:\n#  1.0\n#  1.0\n#  1.0\n#  1.0\n#  1.0\n# #+END_SRC\n# some text \n"
end 
