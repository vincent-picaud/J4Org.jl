import J4Org: tokenized, untokenize
import J4Org: identifier
import J4Org: skip
import J4Org: raw_string
import J4Org: extract_comment
import J4Org: extract_variable
import J4Org: extract_function
import J4Org: extract_struct
import J4Org: extract_export
import J4Org: extract_abstract
import J4Org: extract_enum
import J4Org: extract_macro

@testset "extract_comment" begin
    filename="$(dirname(@__FILE__))/code_examples/basic.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_comment(t,1)
    @test r!=nothing
    @test raw_string(r) == "# This is a test file\n"
    r = extract_comment(t,skip(r))
    @test r!=nothing
    @test raw_string(r) == "#+MyTag1,MyTag2\n#     \n# My documentedItem\n"
end; 

@testset "extract_comment_tab" begin
    filename="$(dirname(@__FILE__))/code_examples/basic_tab.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_comment(t,1)
    @test r!=nothing
    @test raw_string(r)  == "# This is a test file\n"

    r = extract_comment(t,3)
    @test r!=nothing
    @test raw_string(r) == "#+MyTag1,MyTag2\n#     \n# My documentedItem\n"
end;

@testset "function_1" begin
    filename="$(dirname(@__FILE__))/code_examples/function_1.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_function(t,1)
    @test r!=nothing
    @test raw_string(r) == "   function    myFunction (a;\n                           x::Float64=sin(1))"
end; 


@testset "function_2" begin
    filename="$(dirname(@__FILE__))/code_examples/function_2.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_function(t,1)
    @test r!=nothing
    @test raw_string(r) == "function myFunction (a{T};\n                     x::Float64=sin(1))::Bool"
end; 

@testset "function_3" begin
    filename="$(dirname(@__FILE__))/code_examples/function_3.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_function(t,1)
    @test r!=nothing
    @test raw_string(r) == "function myFunction (a{T};\n                     x::Float64=sin(1))::Bool where {T}"
end; 


@testset "function_1_short" begin
    filename="$(dirname(@__FILE__))/code_examples/function_1_short.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_function(t,1)
    @test r!=nothing
    @test raw_string(r) == "       myFunction (a;\n                   x::Float64=sin(1))"
end; 


@testset "function_2_short" begin
    filename="$(dirname(@__FILE__))/code_examples/function_2_short.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_function(t,1)
    @test r!=nothing
    @test raw_string(r) == "myFunction (a{T};\n            x::Float64=sin(1))::Bool"
end; 

@testset "function_3_short" begin
    filename="$(dirname(@__FILE__))/code_examples/function_3_short.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_function(t,1)
    @test r!=nothing
    @test raw_string(r) == "myFunction (a{T};\n            x::Float64=sin(1))::Bool where {T}"
end; 



@testset "struct_1" begin
    filename="$(dirname(@__FILE__))/code_examples/struct_1.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_struct(t,1)
    @test r!=nothing
    @test raw_string(r) == "mutable struct Bar"
end; 

@testset "struct_2" begin
    filename="$(dirname(@__FILE__))/code_examples/struct_2.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_struct(t,1)
    @test r!=nothing
    @test raw_string(r) == "struct Bar" 
end; 

@testset "struct_3" begin
    filename="$(dirname(@__FILE__))/code_examples/struct_3.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_struct(t,1)
    @test r!=nothing
    @test raw_string(r) == "struct Point{T<:Real} <: Pointy{T}" 
end;

@testset "export" begin
    filename="$(dirname(@__FILE__))/code_examples/export.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_export(t,1)
    @test r!=nothing
    @test raw_string(r) == "export A,B,   C"
end;



@testset "abstract" begin
    filename="$(dirname(@__FILE__))/code_examples/abstract.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_abstract(t,1)
    @test r!=nothing
    @test raw_string(r) == "abstract type UDWT_Filter_Biorthogonal{T<:Number} "
end;



@testset "enum" begin
    filename="$(dirname(@__FILE__))/code_examples/enum.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_enum(t,1)
    @test r!=nothing
    @test raw_string(r) == "@enum Alpha A  B=1 C"
    @test identifier(r) == "Alpha"
end;



@testset "variable" begin
    filename="$(dirname(@__FILE__))/code_examples/variable.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_variable(t,1)
    @test r!=nothing
    @test raw_string(r) == "A"
    @test identifier(r) == "A"
end;

@testset "variable_const" begin
    filename="$(dirname(@__FILE__))/code_examples/variable_const.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_variable(t,1)
    @test r!=nothing
    @test raw_string(r) == "const A"
    @test identifier(r) == "A"
end;

@testset "variable_const_global" begin
    filename="$(dirname(@__FILE__))/code_examples/variable_const_global.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_variable(t,1)
    @test r!=nothing
    @test raw_string(r) == "const global A"
    @test identifier(r) == "A"
end;

@testset "variable_global_const" begin
    filename="$(dirname(@__FILE__))/code_examples/variable_global_const.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_variable(t,1)
    @test r===nothing
end;



@testset "macro" begin
    filename="$(dirname(@__FILE__))/code_examples/macro.jl"
    code=readcode(filename)
    t=tokenized(code)

    r = extract_macro(t,1)
    @test r!=nothing
    @test raw_string(r) == "macro swap(x,y)"
    @test identifier(r) == "swap"
end;
