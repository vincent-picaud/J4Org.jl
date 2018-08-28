export generate_doc,org_string, create_documented_item_array, create_documented_item

#+OrgString
#
# Generates header for Org export
#
# *Parameters:*
# - *uuid_link:* add a link target <<uuid_link>> (used by index for instance)
# - *extra_link:* add an extra link target <<extra_link>> (used by index for instance)
# - *header_level:* [[(test)]]
#   - *-1*: no header (this function returns "") 
#   - *0*: header -
#   - *n*: header *...* with n stars
#
function org_string_documented_item_header(di::Documented_Item;
                                           extra_link::String="", # (ref:test)
                                           uuid_link::String="",
                                           header_level::Int=0)::String 
    s=""
    if header_level<0
        return s
    end
    
    if header_level==0
        header_str="- @@latex:\\phantomsection@@"
    else
        header_str=String(fill('*',header_level))
    end 
    identifier_=identifier(di)
    s=s*"$(header_str) *=$(identifier(di))=* "

    if !isempty(uuid_link) 
        s=s*" <<$(uuid_link)>>"
    end

    return s
end

#+OrgString
#
# Generates footer for Org export
#
function org_string_documented_item_footer(di::Documented_Item;
                                           index_link::String="")::String
    s=""
    generate_index_link = (index_link!="")
    
    if !isempty(filename(di))
        s=s*create_file_org_link(di)
        if generate_index_link
            s=s*", "
        end  
    end
    
    if  generate_index_link
        s=s*"[[$(index_link)][back to index]]"
    end
    s=s*"\n"

    return s
end 


#+OrgString
# Prints a =Documented_Item= structure
#
# This function is reserved for internal uses
#
# *Note:* we need all the =di_array::Array{Documented_Item,1}= and not simply =di::Documented_Item=
#         this global array is use to generate and check extra link (L:link)
#
# *Optional arguments:*
# - souce_link: uses item filename to create a link to source
# - uuid_link: if != "" add a link target <uuid_link> (for used to create index for instance)
function org_string_documented_item(di::Documented_Item,
                                    di_array::Array{Documented_Item,1},
                                    di_array_universe::Array{Documented_Item,1};
                                    link_prefix::String=randstring(),
                                    source_link::Bool=true,
                                    uuid_link::String="",
                                    index_link::String="",
                                    header_level::Int=0,
                                    boxingModule::String="BoxingModule",
                                    with_body::Bool=false)::String
    # check links for error
    check_for_link_error(di_array,di_array_universe)
    
    # Header
    s=""
    s=s*org_string_documented_item_header(di,
                                          uuid_link=uuid_link,
                                          header_level=header_level)
    # Header, need completion in case of extra link (L:something)
    if !isempty(link(di))
        if header_level<0
            s=s*" @@latex:\\phantomsection@@ "
        end
        s=s*" <<$(link_prefix*link(di))>>\n"
    else
        s=s*"\n"
    end
    
    # Code
    s=s*org_string_code(di)
        
    # Doc
    s=s*org_string_comment(di,
                           di_array,
                           di_array_universe,
                           link_prefix,
                           boxingModule)

     if with_body
        s=s*org_string_code_with_body(di)
     end
         
    # Footer
    s=s*org_string_documented_item_footer(di,
                                          index_link=index_link)
    
    return s
end 

#+Internal
#
# Given a transformation t(x) creates groups (a vector of UnitRange) where
# t(x_i), i in group_k is constant
#
# *Caveat:* to make sense, the input array must be sorted.
function create_group(array::Array{T,1},t::Function)::Array{UnitRange{Int},1} where {T}
    groups=Array{UnitRange{Int},1}()
    n = length(array)
    if length(array)==0
        return groups
    end 
    i,j=1,2
    current_identifier = t(array[1])
    while(j<=n)
        if current_identifier!=t(array[j])
            push!(groups,i:j-1)
            i=j
            current_identifier=t(array[j])
        end
        j=j+1
    end
    push!(groups,i:n)
    return groups
end 

#+Internal
# Creates groups sharing the same identifier with correct lexical order 
#
# This version is *case nonsensitive*
#
function group_by_identifier_case_nonsensitive(di_array::Array{Documented_Item,1})::Array{UnitRange{Int},1}

    # Group without taking into account uppercase/lowercase
    #
    t(x)=uppercase(identifier(x))
    sort!(di_array, by = t)
    groups = create_group(di_array,t)
    
    # Sort taking account uppercase/lowercase for each group
    #
    for group_i in groups
        sort!(view(di_array,group_i), by = x -> identifier(x))
    end
    # Rebuild group taking account uppercase/lowercase
    #
    groups = create_group(di_array,x->identifier(x))
    
    return groups
end

#+Internal
# Creates groups sharing the same identifier with correct lexical order 
#
# This version is *case sensitive* (capitals are in front)
#
function group_by_identifier_case_sensitive(di_array::Array{Documented_Item,1})::Array{UnitRange{Int},1}

    # Group without taking into account uppercase/lowercase
    #
    t(x)=identifier(x)
    sort!(di_array, by = t)
    groups = create_group(di_array,t)
    
    return groups
end

#+OrgString
#
# *Arguments:* see [[print_org_doc_API][]]
# 
function org_string_documented_item_array(di_array::Array{Documented_Item,1},
                                          predicate::Function;
                                          header_level::Int=0,
                                          link_prefix::String=randstring(),
                                          complete_link::Bool=false,
                                          case_sensitive::Bool=true,
                                          boxingModule::String="BoxingModule",
                       with_body::Bool=false)::String

    # extract what we need 
    di_array_copy=filter(predicate,di_array)

    # try to complete links
    if complete_link
        links = extract_links(di_array_copy)
        di_array_copy_complement=filter(x->!predicate(x),di_array)
        @assert length(di_array_copy_complement) + length(di_array_copy) == length(di_array)
        while length(links)>0
            link_i=pop!(links)
            idx=get_item_idx_from_link_target(link_i,di_array_copy)
            if isempty(idx)
                # We have not found the link target,
                # try with complementary
                #
                idx=get_item_idx_from_link_target(link_i,di_array_copy_complement)

                if !isempty(idx)
                    # The target exists in complementary, we must:
                    # 1/ add all the new links
                    # 2/ move these new items from complement to our current item list
                    #    note:we can delete them as there is only _one_ link target per item

                    # 1/
                    links=vcat(links,extract_links(di_array_copy_complement[idx]))
                    links=remove_link_duplicate(links)
                    # 2/
                    di_array_copy=vcat(di_array_copy,di_array_copy_complement[idx])
                    di_array_copy_complement=deleteat!(di_array_copy_complement,idx)
                end 
            end 
        end 
    end
    
    # lexical grouping
    n_di = length(di_array_copy)
    s=""
    if n_di==0
        return s
    end
    #    groups = group_by_identifier_case_nonsensitive(di_array_copy)
    # sort!(di_array_copy,by=x->identifier(x))
    # groups = create_group(di_array_copy,x->identifier(x))

    if case_sensitive 
        groups = group_by_identifier_case_sensitive(di_array_copy)
    else
        groups = group_by_identifier_case_nonsensitive(di_array_copy)
    end
    
    n_groups = length(groups)

    # generates (hidden) uuid
    uuid = Array{String,1}()
    for i in 1:n_di 
        push!(uuid,randstring())
    end

    # Creates index string
    if header_level>=0

        function get_identifier_first_letter(idx)
            first_letter = identifier(di_array_copy[idx])[1]

            if !case_sensitive
                first_letter = uppercase(first_letter)
            end
            return first_letter
        end
        
        # if case_sensitive
        #     get_identifier_first_letter(idx) = identifier(di_array_copy[idx])[1]
        # else
        #     get_identifier_first_letter(idx) = uppercase(identifier(di_array_copy[idx])[1])
        # end 

        alpha_group = create_group(groups,r->get_identifier_first_letter(first(r)))
        
        index_label = randstring()
        s="<<$(index_label)>> *Index:* "

        for alpha in alpha_group
            s=s*"*[$(get_identifier_first_letter(first(groups[first(alpha)])))]* "
            for group_j in groups[alpha]
                first_item_idx = first(group_j)
                s=s*"[[$(uuid[first_item_idx])][$(identifier(di_array_copy[first_item_idx]))]]"
                if  group_j!=last(groups[alpha])
                    s=s*","
                end
                s=s*" "
            end
        end
        s=s*"\n"
    else
        index_label = ""
    end
    
    # Generate documented items
    for group_j in groups
        for j in group_j
            is_first = j==first(group_j)
            s=s*org_string_documented_item(di_array_copy[j],
                                           di_array_copy,
                                           di_array, # universe (mainly use to find external links)
                                           header_level = (is_first ? header_level : -1),
                                           index_link   = index_label,
                                           uuid_link    = uuid[j],
                                           link_prefix  = link_prefix,
                                           boxingModule=boxingModule,
                                           with_body=with_body)
        end
    end
    
    return s 
end


#+OrgString
#
# Generates org doc string
#
# This function filters output according to these options:
#
# *tag:* filter according to this tag, "" <-> take all tags
#
function org_string_documented_item_array(di_array::Array{Documented_Item,1};
                                          tag::Union{String,Array{String,1}}="",
                                          tag_to_ignore::Union{String,Array{String,1}}="",
                                          identifier::String="",
                                          header_level::Int=0,
                                          link_prefix::String=randstring(),
                                          complete_link::Bool=false,
                                          case_sensitive::Bool=true,
                                          boxingModule::String="BoxingModule",
                                          with_body::Bool=false)::String

    function predicate(di::Documented_Item)
        ok = true
        ok = ok && ( (isempty(tag))||contains_tag(di,tag) )
        ok = ok && ( (isempty(tag_to_ignore))||(!contains_tag(di,tag_to_ignore)) )
        ok = ok && ( (identifier=="")||(identifier==J4Org.identifier(di)) )

        return ok
    end

    return org_string_documented_item_array(di_array,
                                            predicate,
                                            header_level=header_level,
                                            link_prefix=link_prefix,
                                            complete_link=complete_link,
                                            case_sensitive=case_sensitive,
                                            boxingModule=boxingModule,
                                           with_body=with_body)
end

#+API                                                                L:print_org_doc_API
#
# Prints generated documentation to be exported by OrgMode, this is the main function of the =J4Org= package.
#
# *Org-Mode Usage example:*
# #+BEGIN_SRC julia :eval never :exports code
# ,#+BEGIN_SRC julia :results output drawer :eval no-export :exports results
# documented_items = create_documented_item_array_dir("~/GitLab/MyPackage.jl/src/");
# print_org_doc(documented_items,tag="API",header_level=0)
# ,#+END_SRC
# #+END_SRC
#
# *Arguments:*
# - =tag=: tags to collect when generating the documentation
# - =tag_to_ignore=: tags to ignore when generating the documentation
# - =identifier=: generates documentation for this "identifier". Can be a function name, a structure name, etc…
# - =link_prefix=: allows to add a prefix to extra link (#+tag L=extra_link). this is can be useful to avoid link name conflict when performing local doc extraction.
# - =complete_link=: if true, try to fix link without target by adding extra items
# - =case_sensitive=: case sensitive index.
# - =boxingModule=: specifies the context in which "#!" code will be executed. See [[initialize_boxing_module][]] for details.
# - =with_body::Bool=: if true include code body
#
function print_org_doc(di_array::Array{Documented_Item,1};
                       tag::Union{String,Array{String,1}}="",
                       tag_to_ignore::Union{String,Array{String,1}}="",
                       identifier::String="",
                       header_level::Int=0,
                       link_prefix::String=randstring(),
                       complete_link::Bool=false,
                       case_sensitive::Bool=true,
                       boxingModule::String="BoxingModule",
                       with_body::Bool=false)
    print(org_string_documented_item_array(di_array,
                                           tag=tag,
                                           tag_to_ignore=tag_to_ignore,
                                           identifier=identifier,
                                           header_level=header_level,
                                           link_prefix=link_prefix,
                                           complete_link=complete_link,
                                           case_sensitive=case_sensitive,
                                           boxingModule=boxingModule,
                                           with_body=with_body))
end 

