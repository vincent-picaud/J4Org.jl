

const Link_Collection_Type = Vector{String}

# +Links
#
# This function cleans extracted links by removing duplicates
#
# See: [[extract_links_string][]]
function remove_link_duplicate(toClean::Link_Collection_Type)::Link_Collection_Type
    # a priori sort is not necessary
    return unique(toClean)
end

# +Links L:extract_links_string
#
# This function returns the list of links found in the string. It
# returns nothing if no link is found
#
# !s="# some text [[some_target][]], [[link_target][link_name]]";
# !J4Org.extract_links(s)
#
# *Caveat:* only use links of the forme ​"[​[something][]]", which are not
#           valid Org mode links, see [[doc_link_substitution][]]
#
# *Test link:* [[doc_link_substitution][]]
#
# *Note*: duplicates are removed
#
function extract_links(input::String)::Link_Collection_Type
    # remove blalba "toremove" kmsdqkm (do not consider quoted links)
    input = replace(input,r"(\".*\")" => "")
    v=Link_Collection_Type()
    
    match_link = r"\[\[(\w+)\]\[\]\]"

    if !occursin(match_link,input)
        return v
    end

    offset=1
    while (m=match(match_link,input,offset))!=nothing
        push!(v,m[1])
        offset=m.offsets[end]+length(m[1])      
    end 
    
    return remove_link_duplicate(v)
end

# +Links
#
# This function is like [[extract_links_string][]], except that it
# processes a [[Documented_Item][]]
#
# *Note*: duplicates are removed
#
function extract_links(di::Documented_Item)::Link_Collection_Type
    v=extract_links(raw_string_doc(di))
    return remove_link_duplicate(v)
end

# +Links
#
# This function is like [[extract_links_string][]], except that it
# processes an array of [[Documented_Item][]]
#
# *Note*: duplicates are removed
#
function extract_links(di_array::Array{Documented_Item,1})::Link_Collection_Type
    v=Link_Collection_Type()

    for di in di_array
        v=vcat(v,extract_links(di))
    end 
    
    return remove_link_duplicate(v)
end



# +Links
#
# Returns the indices of [[Documented_Item][]] containing the
# link_target (have a tag line with L:link_target)
#
# *Note:* a normal situation is to have zero or one indices. Several
# indices means that we do not have a unique target.
#
function get_item_idx_from_link_target(link_target::String,di_array::Array{Documented_Item,1})::Vector{Int}
    v=Vector{Int}()
    n = length(di_array)
    for i in 1:n
        if link_target==link(di_array[i])
            push!(v,i)
        end
    end 
    return v
end 



# +Links
# Check for if links are well formed
#
# Two kinds of errors:
# - links without target
# - duplicate link targets
#
# *Returns*: true if ok, false if some errors are detected
# 
function check_for_link_error(di_array::Array{Documented_Item,1},
                              di_array_universe::Array{Documented_Item,1})::Bool

    visited_links = Link_Collection_Type() # store visited links -> do not print error several times

    ok=true
    
    for di in di_array
        links_to_check = extract_links(di)
        
        for link_target in links_to_check

            if link_target ∉ visited_links

                push!(visited_links,link_target)

                item_idx = get_item_idx_from_link_target(link_target,di_array_universe)
                
                if isempty(item_idx)
                    ok=false
                    warning_message("link target $(link_target) in $(create_file_org_link(di)) not found")
                elseif length(item_idx)>1
                    ok=false
                    for idx in item_idx
                        warning_message("duplicate link target $(duplicated_link) presents in $(create_file_org_link(di_array_universe[idx]))")
                    end
                end
            end 
        end
    end

    return ok
end



# +Links
#
# Creates readable part of the link.
#
# By default use item identifier.
#
# Improve it if we can, for instance
#
# - for functions: identifier -> identifier(...)
# - for enums: identifier -> @enum identifier
# - ...
#
# *Parameters*:
# - di: the item containing the link target (L:link_target)
#
# *Post-condition*:
# - returns a non-empty string
# 
function create_magnified_link_name(di::Documented_Item)::String

    # start with the identifier
    identifier_as_string = identifier(di)

    # try to magnify 
    # - function add identifier()
    # - strucure add struct identifier
    # - ...
    if is_documented_function(di)
        magnified_link_name=identifier_as_string*"(...)"
    elseif is_documented_structure(di)
        magnified_link_name="struct "*identifier_as_string
    elseif is_documented_abstract_type(di)
        magnified_link_name="abstract "*identifier_as_string
    elseif is_documented_enum_type(di)
        magnified_link_name="@enum "*identifier_as_string
    elseif is_documented_macro_type(di)
        magnified_link_name="@"*identifier_as_string
    elseif is_documented_variable_type(di)
        magnified_link_name="variable "*identifier_as_string
    end 

    @assert !isempty(magnified_link_name)

    return magnified_link_name
end


# +Links
#
# - new_target=="": transforms [​[link_target][]] -> _link_magnified_
# - otherwise: transforms [​[link_target][]] -> [​[link_new_target][link_magnified]] 
#
function doc_link_substitution_helper(doc::String,
                                     link_target,
                                     link_new_target,
                                     link_magnified)::String 
    src="[[$(link_target)][]]"
    if isempty(link_new_target)
        dest="_$(link_magnified)_"
    else
        dest="[[$(link_new_target)][$(link_magnified)]]"
    end
    return replace(doc,src => dest)
end

# +Links, TODO                                       L:doc_link_substitution
# From doc string performs links substitution
#
# *Note:* in order to do not interfere with org mode link we only process "links" of the form "[[something][]]"
#         see https://orgmode.org/manual/Link-format.html
#
# *Note:* to be able to write a "unactive" link, use C-x 8 RET 200b
#         (see: https://emacs.stackexchange.com/a/16702)
#
# - [ ] TODO Finally duplicate links are not checked... do it before
#
function doc_link_substitution(doc::String,
                               di_array::Array{Documented_Item,1},
                               di_array_universe::Array{Documented_Item,1},
                               link_prefix::String)::String
    # Extract links 
    links = extract_links(doc)

    # Something to?
    if isempty(links)
        return doc
    end

    # Process each link, sequentially modify doc 
    for link_target in links
        # default values (to be modified)
        # link_new_target = "" if target not found 
        link_new_target = link_prefix*link_target
        # use create_magnified_link_name()
        link_magnified = link_target
        
        # Find item indices having link_target as target (L:link_target)
        link_target_idx = get_item_idx_from_link_target(link_target,di_array)

        # No target found 
        if isempty(link_target_idx)
            link_new_target = "" # inactive link
            
            # Try to magnify name from di_array_universe
            if !(di_array===di_array_universe)
                # Try to find one in di_array_universe
                link_target_idx = get_item_idx_from_link_target(link_target,di_array_universe)

                if !isempty(link_target_idx)
                    link_magnified = create_magnified_link_name(di_array_universe[link_target_idx[1]])
                end
            end
        else 
            link_magnified= create_magnified_link_name(di_array[link_target_idx[1]])
        end

        doc = doc_link_substitution_helper(doc,
                                           link_target,
                                           link_new_target,
                                           link_magnified)
    end
    
    return doc
end 


