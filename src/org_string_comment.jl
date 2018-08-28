#+Extracted_Item_Base
# Removes hash
function remove_hashtag(s::String)::String
    input=split(s,"\n",keepempty=false)
    output=Vector{String}()

    for s in input
        if s=="#"
            push!(output,"\n")
        else
            @assert(s[1:2]=="# ")
            push!(output,s[3:end]*"\n")
        end
    end
    return join(output)
end 

# +Extracted_Item_Base,OrgString  L:org_string_comment
#
# *Note:* this function does a lot, it uses links.jl and
# *evaluate.jl. That is the reason why it is defined in its own file
#
function org_string_comment(di::Documented_Item,
                            di_array::Array{Documented_Item,1},
                            di_array_universe::Array{Documented_Item,1},
                            link_prefix::String,
                            boxingModule::String)::String

    s=raw_string_doc(di)
    
    # Process links 
    s=doc_link_substitution(s,di_array,di_array_universe, link_prefix)
    # Execute code snippet
    s=with_hash_evaluate(s,boxingModule)
    # remove #
    s=remove_hashtag(s)

    # Quote string 
    if !isempty(s)
        s="#+BEGIN_QUOTE\n$(s)#+END_QUOTE\n"
    end 

    return s
end
