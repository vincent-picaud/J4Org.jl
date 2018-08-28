import Base: range,skip 

#+Extracted_Item_Base L:Extracted_Item_Base
abstract type Extracted_Item_Base end

#+Extracted_Item_Base
skip(ex::Extracted_Item_Base)::Int = ex._skip_idx

#+Extracted_Item_Base
identifier(ex::Extracted_Item_Base)::String = ex._identifier

#+Extracted_Item_Base
raw_string(ex::Extracted_Item_Base)::String = untokenize(ex._tok[ex._idx_array])
#+Extracted_Item_Base
# By default do nothing (returns an empty string)
raw_string_with_body(ex::Extracted_Item_Base)::String = ""
#untokenize(ex._tok[ex._idx_array_with_body])


#+Extracted_Item_Base 
struct Extracted_Comment <: Extracted_Item_Base
    _tok::Tokenized
    _idx_array::Array{Int,1}
    _skip_idx::Int 
end

#+Extracted_Item_Base
# Specialization that returns an empty string ""
identifier(ex::Extracted_Comment)::String = ""

#+Extracted_Item_Base
# For comment we remove empty # at begin&end
function raw_string(ex::Extracted_Comment)::String
    a=Array{String,1}()
    # remove first and trailing empty "#"
    not_empty_comment_p(idx) = untokenize(ex._tok[idx])!="#"
    idx_first = findfirst(not_empty_comment_p,ex._idx_array)
    if idx_first == 0
        # the array is empty or only contains empty comments
        return ""
    end 
    idx_last  = findlast(not_empty_comment_p,ex._idx_array)
    @assert idx_first <= idx_last

    for k in idx_first:idx_last
        push!(a,untokenize(ex._tok[ex._idx_array[k]])*"\n")
    end
    
    return join(a)
end 

raw_string_with_body(ex::Extracted_Comment) = throw("Does not make sense")

#+Extracted_Item_Base L:extract_comment
# Extracts *contiguous* comments
#
# Returns nothing if no comment found
function extract_comment(tok::Tokenized,idx::Int)::Union{Nothing,Extracted_Item_Base}

    idx=skip_whitespace(tok,idx)
    
    # fill idx array with contiguous comment
    idx_array=Array{Int,1}()
    n = length(tok)
    while (idx<=n)&&(is_comment(tok,idx))
        push!(idx_array,idx)
        idx=idx+1
        # contiguous comment only
        if is_whitespace(tok,idx)&&(count(x->x=='\n',untokenize(tok[idx]))==1)
            idx=idx+1
            continue
        end
    end

    return isempty(idx_array) ? nothing : Extracted_Comment(tok,idx_array,idx)
end



#+Tokenizer
# A structure to store extracted function.
#
# See: [[Extracted_Item_Base][]], [[extract_function][]]
#
struct Extracted_Function <: Extracted_Item_Base
    _tok::Tokenized
    _idx_array::Array{Int,1}
    _idx_array_with_body::Array{Int,1}
    _skip_idx::Int
    _identifier::String
end
#+Internal 
raw_string_with_body(ex::Extracted_Function)::String = untokenize(ex._tok[ex._idx_array_with_body])

#+Tokenizer L:extract_function
# Extract function
function extract_function(tok::Tokenized,idx::Int)::Union{Nothing,Extracted_Function}
    
    idx=skip_uninformative(tok,idx)

    if is_function(tok,idx)||is_identifier(tok,idx)
        # long  function: function foo() .... end <-> is_function(tok,idx)   = TRUE
        # short function: foo() = something       <-> is_identifier(tok,idx) = TRUE
        #
        Function_Type_Long  = Val{:Long}
        Function_Type_Short = Val{:Short}
        function_type =  is_function(tok,idx) ? Function_Type_Long : Function_Type_Short
        
        # retrieve an eventual whitespace without \n <-> important: coherent preserve tabulation
        if (idx>1)&&(is_whitespace(tok,idx-1))&&(count(x->(x=='\n'),untokenize(tok[idx-1]))==0)
            idx_save = idx-1
        else
            idx_save = idx
        end 
        
        if is_function(tok,idx)
            idx=idx+1
        end 

        identifier=Ref{String}("")
        idx_check_success = idx
        idx = skip_function_call_block(tok,idx,identifier=identifier)

        if idx_check_success<idx # successful extraction 

            idx=skip_declaration_block(tok,idx)
            idx=skip_where_block(tok,idx)

            if function_type==Function_Type_Short
                idx_body_end = skip_line(tok,idx_save )-1
            else
                idx_body_end = find_closing_block(tok,idx,1)
                # if is_end(tok,idx_body_end)
                #     idx_body_end += 1
                # end 
            end 
            
            return Extracted_Function(tok,collect(idx_save:idx-1),collect(idx_save:idx_body_end),idx,identifier[])
        end 
    end

    return nothing
end




struct Extracted_Struct <: Extracted_Item_Base
    _tok::Tokenized
    _idx_array::Array{Int,1}
    _idx_array_with_body::Array{Int,1}
    _skip_idx::Int
    _identifier::String
end
#+Internal 
raw_string_with_body(ex::Extracted_Struct)::String = untokenize(ex._tok[ex._idx_array_with_body])

#+Tokenizer
# Extract struct
#
function extract_struct(tok::Tokenized,idx::Int)::Union{Nothing,Extracted_Struct}

    idx_save = skip_uninformative(tok,idx)
    identifier=Ref{String}("")
    idx = skip_struct_block(tok,idx_save,identifier=identifier)

    if idx != idx_save
        idx_with_body = find_closing_block(tok,idx_save)
        return Extracted_Struct(tok,collect(idx_save:idx-1),collect(idx_save:idx_with_body),idx,identifier[])
    end
    
    return nothing
end




struct Extracted_Export <: Extracted_Item_Base
    _tok::Tokenized
    _idx_array::Array{Int,1}
    _skip_idx::Int
    _identifier::String
end

#+Tokenizer
# Extract export
#
function extract_export(tok::Tokenized,idx::Int)::Union{Nothing,Extracted_Export}

    idx_save = skip_uninformative(tok,idx)

    if is_export(tok,idx_save)
        idx_to_check = idx_save+1
        idx = skip_comma_separated_identifiers(tok,idx_to_check)

        if idx != idx_to_check
            return Extracted_Export(tok,collect(idx_save:idx-1),idx,"export")
        end
    end 
    
    return nothing
end



struct Extracted_Abstract <: Extracted_Item_Base
    _tok::Tokenized
    _idx_array::Array{Int,1}
    _skip_idx::Int
    _identifier::String
end

#+Tokenizer
# Extract abstract type
#
function extract_abstract(tok::Tokenized,idx::Int)::Union{Nothing,Extracted_Abstract}

    idx_save = skip_uninformative(tok,idx)
    identifier=Ref{String}("")
    idx = skip_abstract_block(tok,idx_save,identifier=identifier)

    if idx != idx_save
        return Extracted_Abstract(tok,collect(idx_save:idx-1),idx,identifier[])
    end
    
    return nothing
end



struct Extracted_Enum <: Extracted_Item_Base
    _tok::Tokenized
    _idx_array::Array{Int,1}
    _skip_idx::Int
    _identifier::String
end

# +Tokenizer
#
# Extract enum type
#
function extract_enum(tok::Tokenized,idx::Int)::Union{Nothing,Extracted_Enum}

    idx_save = skip_uninformative(tok,idx)
    identifier=Ref{String}("")
    idx = skip_enum_block(tok,idx_save,identifier=identifier)

    if idx != idx_save
        return Extracted_Enum(tok,collect(idx_save:idx-1),idx,identifier[])
    end
    
    return nothing
end



struct Extracted_Macro <: Extracted_Item_Base
    _tok::Tokenized
    _idx_array::Array{Int,1}
    _skip_idx::Int
    _identifier::String
end

# +Tokenizer
#
# Extract macro type
#
function extract_macro(tok::Tokenized,idx::Int)::Union{Nothing,Extracted_Macro}

    idx_save = skip_uninformative(tok,idx)
    identifier=Ref{String}("")
    idx = skip_macro_block(tok,idx_save,identifier=identifier)

    if idx != idx_save
        return Extracted_Macro(tok,collect(idx_save:idx-1),idx,identifier[])
    end
    
    return nothing
end



struct Extracted_Variable <: Extracted_Item_Base
    _tok::Tokenized
    _idx_array::Array{Int,1}
    _skip_idx::Int
    _identifier::String
end

# +Tokenizer
#
# Extract variable type
#
function extract_variable(tok::Tokenized,idx::Int)::Union{Nothing,Extracted_Variable}

    idx_save = skip_uninformative(tok,idx)
    identifier=Ref{String}("")
    idx = skip_variable_block(tok,idx_save,identifier=identifier)

    if idx != idx_save
        return Extracted_Variable(tok,collect(idx_save:idx-1),idx,identifier[])
    end
    
    return nothing
end



#+Extracted_Item_Base
#
# Extract the "code" part, sequentially trying
# - function
# - struct
# - ...
# declarations
#
# *Return:* nothing if we do not understandable the code 
#
function extract_code(tok::Tokenized,idx::Int)::Union{Nothing,Extracted_Item_Base}

    # Try function
    #
    toReturn = extract_function(tok,idx)
    
    if toReturn!=nothing
        return toReturn
    end

    # Try struct
    #
    toReturn = extract_struct(tok,idx)

    if toReturn!=nothing
        return toReturn
    end

    # Try abstract
    #
    toReturn = extract_abstract(tok,idx)

    if toReturn!=nothing
        return toReturn
    end

    # Try export
    #
    toReturn = extract_export(tok,idx)

    if toReturn!=nothing
        return toReturn
    end

    # Try enum
    #
    toReturn = extract_enum(tok,idx)

    if toReturn!=nothing
        return toReturn
    end

    # Try macro
    #
    toReturn = extract_macro(tok,idx)

    if toReturn!=nothing
        return toReturn
    end

    # Try variable
    #
    toReturn = extract_variable(tok,idx)

    if toReturn!=nothing
        return toReturn
    end

    return nothing
end 
