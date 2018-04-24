# Define the mechanism by which code snippet is evaluated
#
export initialize_boxing_module


#+Evaluate, Obsolete
# -> evaluate_new
# Parse and execute a Julia code snippet
#
function evaluate(code::Union{SubString{String},String},m::Module)::String
        result=eval(m,parse(code,raise=true))
        io=IOBuffer()
        show(io,"text/plain",result)
        return String(take!(io))
end

#+Evaluate, API
#
# Initialize a boxing module. This module is used to run Julia comment
# code snippet (tagged by #!)
#
function initialize_boxing_module(;boxingModule::String="BoxingModule",usedModules::Vector{String}=String[],force::Bool=false)::Void
    # Common errors
    @assert boxingModule!=""
    @assert usedModules!=String[""]
    
    # initialize a module (for boxing)
    const module_exists = isdefined(J4Org,Symbol(boxingModule))

    if force||(!module_exists)
        if length(usedModules)>0
            usedModules_asString = "using $(foldr((x,y)->x*", "*y,"",usedModules)[1:end-2]) "
        else
            usedModules_asString = ""
        end
        eval(parse("module $(boxingModule) $(usedModules_asString) end"))
    else
        # force=false && module_exists = true
        # -> nothing is done... interpreted as an error if usedModules if different
        # --> however for the moment we do not know how to get module "used" module_name
        #     thus we trigger an error if usedModules is not empty 
        @assert isempty(usedModules) "Tried to define an already existing module, maybe use the force=true kwarg"
    end
    nothing
end 


#+Evaluate, TODO
#
# Parse and execute a Julia code snippet
#
# The format is raw comment
# #+BEGIN_EXAMPLE
# # some text
# #!5+6
# #!rand(5)
# # some text 
# #+END_EXAMPLE
#
# Example:
#!5+6
#!rand(5)
#
# - [ ] TODO skip output for code ending with ";"
function with_hash_evaluate(comment::String,
                            boxingModule::String)::String
    # Common error
    @assert boxingModule!=""
    @assert isdefined(J4Org,Symbol(boxingModule)) "Module $(boxingModule) does not exist, create a new one with initialize_boxing_module()"
    
    boxingModule_asType=eval(parse("J4Org.$(boxingModule)"))
    
    # process comment, line by line 
    output=Array{String,1}(0)
    comment_line_by_line=split(comment,"\n")
    const n_comment_line_by_line=length(comment_line_by_line)
    i=1
    while i<=n_comment_line_by_line
        
        # only process line beginning with "#!"
        # (other lines are forwarded without modification)
        if (length(comment_line_by_line[i])<2)||(comment_line_by_line[i][1:2]!="#!")
            push!(output,comment_line_by_line[i])
            i=i+1
            continue
        end 

        # Here process code
        @assert comment_line_by_line[i][1:2]=="#!"

        output_code=Array{String,1}(0)
        output_result=Array{String,1}(0)

        push!(output_code,"# #+BEGIN_SRC julia")
        push!(output_result,"# #+BEGIN_SRC julia")

        while (length(comment_line_by_line[i])>=2)&&(comment_line_by_line[i][1:2]=="#!")
            push!(output_code,"# "*comment_line_by_line[i][3:end])
            const code_local = comment_line_by_line[i][3:end]
            show_code_local_result = !ismatch(r";\s*$",code_local) # Caveat: do not take into account final comment
            
            try 
                result_line_by_line=evaluate(code_local,boxingModule_asType)
            catch e
                io=IOBuffer()
                show(io,"text/plain",e)
                result_line_by_line="***ERROR***  $(String(take!(io)))"
                show_code_local_result = true; # if an error occurred, show it!
                warning_message("An error occurred evaluating $(code_local)")
            end 
            result_line_by_line=split(result_line_by_line,"\n")

            if show_code_local_result
                result_line_by_line=map(x->"# "*x,result_line_by_line)
                output_result=vcat(output_result,result_line_by_line)
            end 
            i=i+1
        end

        push!(output_code,"# #+END_SRC")
        push!(output_result,"# #+END_SRC")

        output=vcat(output,output_code,output_result)
    end

    return foldr((x,y)->x*"\n"*y,"",output)
end 
