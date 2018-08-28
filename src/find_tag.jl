
#+FindTag,Extracted_Item_Base
struct Extract_Tag_Result <: Extracted_Item_Base
    _tokenized::Tokenized
    _idx::Int 
    _tags::Array{String,1}
    _link::String
end 

#+FindTag
tag_idx(o::Extract_Tag_Result)::Int = o._idx

#+FindTag
skip(o::Extract_Tag_Result)::Int = tag_idx(o)+1

#+FindTag
tags(o::Extract_Tag_Result)::Array{String,1} = o._tags

#+FindTag
link(o::Extract_Tag_Result)::String = o._link

#+FindTag
line(o::Extract_Tag_Result)::Int = first(startpos(o._tokenized[o._idx]))



#+FindTag L:extract_tag_link
function extract_tag(tok::Tokenized,idx::Int)::Union{Nothing,Extract_Tag_Result}

    if !is_comment(tok,idx)
        return nothing
    end 

    s = untokenize(tok[idx])
    
    first_tag=match(r"^#[ ]?\+(\w+)",s)

    # Math tag?  
    if first_tag==nothing
        return nothing
    end

    tag_list = Array{String,1}([first_tag[1]])

    #----------------------------------------------------------------
    
    regex_other_tags = r"\s*,\s*(\w+)"
    match_other_tags=first_tag

    @label more_tags   
    offset = match_other_tags.offsets[end]+length(match_other_tags[1])
    match_other_tags=match(regex_other_tags,s,offset)

    if match_other_tags!=nothing
        push!(tag_list,match_other_tags[1])
        @goto more_tags
    end

    #----------------------------------------------------------------

    regex_link = r"\s*L:(\w+)\s*$"

    match_link=match(regex_link,s,offset)

    if match_link!=nothing
        link=match_link[1]
    else 
        link=""
    end

    #----------------------------------------------------------------
    
    return Extract_Tag_Result(tok,idx,tag_list,link)
end

#+FindTag L:find_tag_master
#
# If some tags are found use the
# #+BEGIN_SRC julia
# predicate(r::Extract_Tag_Result)::Bool
# #+END_SRC
# to accept (or not) the tags
#
# *Returns:*
# - =(idx,Extract_Tag_Result)=: where =idx= is the position of the discovered tag
# - =(length(tok)+1,nothing)=: if no tag found
#
function find_tag(tok::Tokenized,idx::Int,predicate::Function)::Union{Nothing,Extract_Tag_Result}
    n = length(tok)

    for k in idx:n

        extracted = extract_tag(tok,k)
        
        if (extracted!=nothing)&&(predicate(extracted))
            return extracted
        end

    end 

    return nothing
end 

#+FindTag
#
# Convenience function that uses [[find_tag_master][]] with =x->true=
# predicate. It accepts all tags
function find_tag(tok::Tokenized,idx::Int)::Union{Nothing,Extract_Tag_Result}
    return find_tag(tok,idx,x->true)
end

#+FindTag,Obsolete
#
# Convenience function that uses  find_tag_master find_tag  with a
# predicate that checks for *Tag* existence.
#
function find_tag(tok::Tokenized,idx::Int,tag::String)::Union{Nothing,Extract_Tag_Result}
    return find_tag(tok,idx,x->(tag ∈ tags(x)))
end 
