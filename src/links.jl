

# Link array is a vector of Tuple{String,String}
const Link_Collection_Type = Vector{Tuple{String,String}}

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
#           valid Org mode links, see [[doc_link_substituion][]]
#
# *Test link:* [[doc_link_substituion][]]
#
# *Note*: duplicates are removed
#
function extract_links(input::String)::Link_Collection_Type
    # remove blalba "toremove" kmsdqkm (do not consider quoted links)
    input = replace(input,r"(\".*\")","")
    v=Link_Collection_Type(0)
    
    match_link = r"\[\[(\w+)\]\[\]\]"
    m=match(match_link,input)

    if m==nothing
        return v
    end

    push!(v,(m[1],""))
    offset=m.offsets[end]+length(m[1])
    
    while (m=match(match_link,input,offset))!=nothing
        push!(v,(m[1],""))
        offset=m.offsets[end]+length(m[1])      
    end 
    
    return remove_link_duplicate(v)
end

# +Links
#
# This function is like [[extract_links_string][]], except that is
# process an array of [[Documented_Item][]]
#
# *Note*: duplicates are removed
#
function extract_links(di_array::Array{Documented_Item,1})::Link_Collection_Type
    v=Link_Collection_Type(0)

    for di in di_array
        v=vcat(v,extract_links(raw_string_doc(di)))
    end 

    return remove_link_duplicate(v)
end

#+Links
#
# Returns the indices of [[Documented_Item][]] containing the
# link_target (have a tag line with L:link_target)
#
# *Note:* a normal situation is to have zero or one indices. Several
# indices means that we do not have a unique target.
#
function get_items_with_link_target(link_target::String,di_array::Array{Documented_Item,1})::Vector{Int}
    v=Vector{Int}(0)
    const n = length(di_array)
    for i in 1:n
        if link_target==link(di_array[i])
            push!(v,i)
        end
    end 
    return v
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
function create_link_readable_part(di::Documented_Item)::String

    # start with the identifier
    readable_link = identifier(di)

    # try to magnify 
    # - function add identifier()
    # - strucure add struct identifier
    # - ...
    if is_documented_function(di)
        readable_link=readable_link*"(...)"
    elseif is_documented_structure(di)
        readable_link="struct "*readable_link
    elseif is_documented_abstract_type(di)
        readable_link="abstract "*readable_link
    elseif is_documented_enum_type(di)
        readable_link="@enum "*readable_link
    end 

    @assert !isempty(readable_link)

    return readable_link
end

# +Links                                       L:doc_link_substituion
# From doc string performs links substitution
#
# - check if there are links in the doc:
#   - no: return unmodified doc string, exit
#   - yes: return a list of links 
# - for each link check if it exists in di_array
#   - yes:
#       - creates a magnified readable_link 
#       - replaces ​[​[link_target][]] by ​[​[link_prefix_link_target][readable_link]] to create a valid OrgMode link.
#   - no: try to find in di_array_universe, found?
#       - yes: 
#            - creates a magnified readable_link 
# 	   - replaces an inactive [readable_link] OrgMode link.
#       - no: 
#            - replaces ​[​[link_target][]] by _link_target_ to create an inactive link 
#
# *Note:* in order to do not interfere with org mode link we only process "links" of the form "[[something][]]"
#         see https://orgmode.org/manual/Link-format.html
#
# *Note:* to be able to write a "unactive" link, use C-x 8 RET 200b
#         (see: https://emacs.stackexchange.com/a/16702)
#
function doc_link_substituion(doc::String,
                              di_array::Array{Documented_Item,1},
#                              di_array_universe::Array{Documented_Item,1},
                              link_prefix::String)::String
    # Extract links 
    links = extract_links(doc)
#    links = remove_link_duplicate(links)

    if isempty(links)
        return doc
    end


    # Process each link
    const not_found = Int(-1)
    n_links = length(links)
    n_di_array = length(di_array)
    for k in 1:n_links
        first_occurence = not_found
        link_in_doc="[[$(first(links[k]))][]]"
        for i in 1:n_di_array
            if first(links[k])==link(di_array[i])
                first_occurence = i
                break;
            end
        end

        if first_occurence==not_found
            warning_message("Link target $(links[k]) not found")
            doc = replace(doc,link_in_doc,"_$(first(links[k]))_") # inactive link 
        else
            readable_link = create_link_readable_part(di_array[first_occurence])
            links[k]=(links[k][1],readable_link)
            
            # check for multi-occurrence
            for i in first_occurence+1:n_di_array
                if first(links[k])==link(di_array[i])
                    warning_message("multi-occurrences of target $(links[k]), $(create_file_org_link(di_array[first_occurence])) <-> $(create_file_org_link(di_array[i]))")
                end
            end  

            # perform substitution
            doc = replace(doc,link_in_doc,"[[$(link_prefix*first(links[k]))][$(last(links[k]))]]")
        end 
    end

    return doc
end 


