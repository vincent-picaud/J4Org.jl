import J4Org: tokenized, untokenize
import J4Org: is_opening_parenthesis, is_closing_parenthesis
import J4Org: is_opening_brace, is_closing_brace
import J4Org: is_opening_square, is_closing_square
import J4Org: is_abstract
import J4Org: is_enum
import J4Org: is_const
import J4Org: is_macro
import J4Org: is_global
import J4Org: is_local
import J4Org: is_type
import J4Org: skip_identifier, skip_comma_separated_identifiers
import J4Org: skip_where_block, skip_declaration_block

@testset "openclose" begin
        
        @test is_opening_parenthesis(tokenized("("),1)
        @test is_closing_parenthesis(tokenized(")"),1)
        @test is_opening_brace(tokenized("{"),1)
        @test is_closing_brace(tokenized("}"),1)
        @test is_opening_square(tokenized("["),1)
        @test is_closing_square(tokenized("]"),1)
        
end;

@testset "skip_identifier" begin
    identifier=Ref{String}("")
    t=tokenized("A    qslkdjlk")
    @test untokenize(t[1:skip_identifier(t,1,identifier=identifier)-1]) == "A"
    @test identifier[] == "A"
    t=tokenized("A .  B      \n")
    @test untokenize(t[1:skip_identifier(t,1,identifier=identifier)-1]) == "A .  B"
    @test identifier[] == "A.B"
    t=tokenized("A. B {   A {  X}}  ")
    @test untokenize(t[1:skip_identifier(t,1,identifier=identifier)-1]) == "A. B {   A {  X}}"
    @test identifier[] == "A.B"
end; 

@testset "skip_comma_separated_identifiers" begin
    t=tokenized("  A       ")
    @test untokenize(t[1:skip_comma_separated_identifiers(t,1)-1]) == "  A"
    t=tokenized("A   ,    ")
    @test untokenize(t[1:skip_comma_separated_identifiers(t,1)-1]) == "A"
    t=tokenized("A, B     ")
    @test untokenize(t[1:skip_comma_separated_identifiers(t,1)-1]) == "A, B"
    t=tokenized("A .  B      \n")
    @test untokenize(t[1:skip_comma_separated_identifiers(t,1)-1]) == "A .  B"
    t=tokenized("A, B {   A {  X}} ,  C  ")
    @test untokenize(t[1:skip_comma_separated_identifiers(t,1)-1]) == "A, B {   A {  X}} ,  C"
end;

@testset "skip_where_block" begin
    t=tokenized(" kjsq sqd       ")
    @test untokenize(t[1:skip_where_block(t,1)-1]) == ""
    t=tokenized("  \nwhere A dfg     ")
    @test untokenize(t[1:skip_where_block(t,1)-1]) == "  \nwhere A"

end;

@testset "skip_declaration_block" begin
    t=tokenized(" ::kjsq sqd       ")
    @test untokenize(t[1:skip_declaration_block(t,1)-1]) == " ::kjsq"
    t=tokenized("  \nwhere A dfg     ")
    @test untokenize(t[1:skip_declaration_block(t,1)-1]) == ""
    t=tokenized("  \n::A{B}  ::Int   ")
    @test untokenize(t[1:skip_declaration_block(t,1)-1]) == "  \n::A{B}"

end;

@testset "is_abstract_and_is_type" begin
    t=tokenized("abstract type something")
    @test is_abstract(t,1)
    @test is_type(t,3)
end;

@testset "is_enum" begin
    t=tokenized("@enum Alpha A B")
    @test is_enum(t,1)
end;



@testset "is_const_global_local" begin
    t=tokenized("const global A=0")
    @test is_const(t,1)
    @test is_global(t,3)
    t=tokenized("const local A=0")
    @test is_const(t,1)
    @test is_local(t,3)
end;



@testset "is_macro" begin
    t=tokenized("macro Alpha(A, B)")
    @test is_macro(t,1)
end;
