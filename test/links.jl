import J4Org: extract_links

@testset "extract_links" begin
    s="# some text without link [c]  [[a][b] "
    a=extract_links(s)
    @test isempty(a)

    s="# some text [[some_target][]]"
    a=extract_links(s)
    @test length(a)==1
    @test a[1]=="some_target"
    
    s="# some text [[some_target][]] another one [[link_target][link_name]] and a last one [[a4][]]"
    a=extract_links(s)
    @test length(a)==2
    @test a[1]=="some_target"
    @test a[2]=="a4"

    s="# some text [[some_target][]] another one \"[[link_target][]]\" and a last one [[a4][]]"
    a=extract_links(s)
    @test length(a)==2
    @test a[1]=="some_target"
    @test a[2]=="a4"
end; 
