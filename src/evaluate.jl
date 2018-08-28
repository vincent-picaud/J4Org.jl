# Define the mechanism by which code snippet is evaluated
#
export initialize_boxing_module


#+Evaluate, Obsolete
# -> evaluate_new
# Parse and execute a Julia code snippet
#
function evaluate(code::Union{SubString{String},String},
                  m::Module)::String
    result=m.eval(Meta.parse(code,raise=true))
    io=IOBuffer()
    show(io,"text/plain",result)
    return String(take!(io))
end

# +Evaluate, API   L:initialize_boxing_module
#
# Initialize a boxing module. This module is used to run Julia comment
# code snippet (tagged by "#!" or by "# !")
#
# *Example:*
# #+BEGIN_SRC julia :eval never :exports code
# initialize_boxing_module(boxingModule="MyBoxing",
#                          usedModules=["RequiredPackage_1",
#                                       "RequiredPackage_2",...])
# #+END_SRC
#
# creates
#
# #+BEGIN_SRC julia :eval never :exports code
# module MyBoxing
# using RequiredPackage_1,RequiredPackage_2,...
# end 
# #+END_SRC
#
# and future "# !" statements are executed after using MyBoxing:
# #+BEGIN_SRC julia :eval never :exports code
# using MyBoxing
# # !statements
# #+END_SRC
function initialize_boxing_module(;
                                  boxingModule::String="BoxingModule",
                                  usedModules::Vector{String}=String[],
                                  force::Bool=false)::Nothing
    # Common errors
    @assert boxingModule!=""
    @assert usedModules!=String[""]
    
    # initialize a module (for boxing)
    module_exists = isdefined(J4Org,Symbol(boxingModule))

    if force||(!module_exists)
        if length(usedModules)>0
            usedModules_asString = "using $(join(usedModules,", ")) "
        else
            usedModules_asString = ""
        end
        eval(Meta.parse("module $(boxingModule) $(usedModules_asString) end"))
    else
        # force=false && module_exists = true
        # -> nothing is done... interpreted as an error if usedModules if different
        # --> however for the moment we do not know how to get module "used" module_name
        #     thus we trigger an error if usedModules is not empty 
        @assert isempty(usedModules) "Tried to define an already existing module, maybe use the force=true kwarg"
    end
    nothing
end 


# +Evaluate
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
# !5+6
# !rand(5)
#
function with_hash_evaluate(comment::String,
                            boxingModule::String)::String
    # Common error
    @assert boxingModule!=""
    @assert isdefined(J4Org,Symbol(boxingModule)) "Module $(boxingModule) does not exist, create a new one with initialize_boxing_module()"
    
    boxingModule_asType=eval(Meta.parse("J4Org.$(boxingModule)"))
    
    # process comment, line by line 
    output=Array{String,1}()
    comment_line_by_line=split(comment,"\n")
    n_comment_line_by_line=length(comment_line_by_line)
    code_to_execute=r"^#[ ]?!(.*)$"
    i=1
    while i<=n_comment_line_by_line
        
        # only process line beginning with "#!" or by "# !"
        # (other lines are forwarded without modification)
        if !occursin(code_to_execute,comment_line_by_line[i])
            push!(output,comment_line_by_line[i])
            i=i+1
            continue
        end 

        # Here process code
        @assert occursin(code_to_execute,comment_line_by_line[i])

        output_code=Array{String,1}()
        output_result=Array{String,1}()

        push!(output_code,"# #+BEGIN_SRC julia")
        push!(output_result,"# #+BEGIN_SRC julia")

        while occursin(code_to_execute,comment_line_by_line[i])
            code_local = match(code_to_execute,comment_line_by_line[i])[1]
            push!(output_code,"# "*code_local)
            show_code_local_result = !occursin(r";\s*$",code_local) # Caveat: do not take into account final comment
            
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

#    return foldr((x,y)->x*"\n"*y,output,"")
    return join(output,"\n")
end 

