using Tokenize
import Tokenize.Tokens: kind, exactkind, startpos

# +Tokenizer,Internal
# Defines a convenient type alias 
const Tokenized = Array{Tokenize.Tokens.Token,1}
#+Tokenizer,Internal
# Defines a convenient method to tokenize a =String=
tokenized(s::String) = collect(tokenize(s))

#<Tokenizer,Internal
is_structure(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.STRUCT)
is_function(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.FUNCTION)
is_comment(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.COMMENT)
is_whitespace(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.WHITESPACE)
is_identifier(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.IDENTIFIER)
is_declaration(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.DECLARATION)
is_dot(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.DOT)
is_comma(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.COMMA)
is_where(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.WHERE)
is_struct(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.STRUCT)
is_mutable(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.MUTABLE)
is_immutable(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.IMMUTABLE)
is_issubtype(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.ISSUBTYPE)
is_export(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.EXPORT)
is_abstract(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.ABSTRACT)
is_type(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.TYPE)
#>

#<Tokenizer,Internal
is_opening_parenthesis(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.LPAREN)
is_closing_parenthesis(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.RPAREN)
is_opening_brace(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.LBRACE)
is_closing_brace(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.RBRACE)
is_opening_square(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.LSQUARE)
is_closing_square(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.RSQUARE)
#>



#+Tokenizer,Internal,Obsolete
# Skip comment
# -> replaced by skip uninformative
function skip_comment(tok::Tokenized,idx::Int)
    while (idx<=length(tok))&&(is_comment(tok,idx)||is_whitespace(tok,idx))
        idx=idx+1
    end
    return idx
end

#+Tokenizer,Internal
# Skip whitespace 
function skip_uninformative(tok::Tokenized,idx::Int)
    while (idx<=length(tok))&&(is_comment(tok,idx)||is_whitespace(tok,idx))
        idx=idx+1
    end
    return idx
end

#+Tokenizer,Internal
# Skip comment + whitespace 
function skip_whitespace(tok::Tokenized,idx::Int)
    while (idx<=length(tok))&&is_whitespace(tok,idx)
        idx=idx+1
    end
    return idx
end

# #+Tokenizer,Internal,Obsolet
# # Moves to the next position 
# function next_idx(tok::Tokenized,idx::Int)::Int
#     return idx+1
# end

# #+Tokenizer,Internal,Obsolet
# # Moves to the next position (skipping comment)
# function next_idx_skip_comment(tok::Tokenized,idx::Int)::Int
#     idx=idx+1
#     return skip_comment(tok,idx)
# end
# #>

# #<Tokenizer,Internal
# # Check "strict" newline: "\n    " (but not "\n\n" for instance)
# #
# function is_newline_strict(s::String)::Bool
#     n=length(s)
#     if (n==0)||(s[1]!='\n')
#         return false
#     end

#     for i = 2:n
#         if (s[i]!=' ')&&(s[i]!='\t')
#             return false
#         end
#     end         
#     return true
# end
# function is_newline_strict(tok::Tokenized,idx::Int)::Bool
#     return is_whitespace(tok,idx)&&is_newline_strict(untokenize(tok[idx]))
# end
# #>

#<Tokenizer,Internal
# Check "strict" whitespace: "  \t    " 
#
function is_whitespace_strict(s::String)::Bool
    n=length(s)
    for i = 1:n
        if (s[i]!=' ')&&(s[i]!='\t')
            return false
        end
    end         
    return true
end
function is_whitespace_strict(tok::Tokenized,idx::Int)::Bool
    return is_whitespace(tok,idx)&&is_whitespace_strict(untokenize(tok[idx]))
end
#>

#+Tokenizer,Internal
# Skip whitespace
function skip_whitespace_strict(tok::Tokenized,idx::Int)
    while (idx<=length(tok))&&(is_whitespace_strict(tok,idx))
        idx=idx+1
    end
    return idx
end


#+Internal 
#
function find_closing_X_helper(tok::Tokenized,idx::Int,
                               is_opening_X::Function,
                               is_closing_X::Function)::Int

    @assert is_opening_X(tok,idx)
    
    count_opening = 0
    while idx<=length(tok)
        if is_opening_X(tok,idx)
            count_opening =  count_opening+1
	    idx=idx+1
            continue
        end

        if is_closing_X(tok,idx)
            count_opening = count_opening-1
            if count_opening == 0
                return idx
            end
        end
        idx=idx+1
    end

    @assert false "no closing X"
end

#+
# assume an open parenthesis, find the closed one
function find_closing_parenthesis(tok::Tokenized,idx::Int)::Int
    return find_closing_X_helper(tok,idx,
                                 is_opening_parenthesis,
                                 is_closing_parenthesis)
end

#+
function find_closing_brace(tok::Tokenized,idx::Int)::Int
    return find_closing_X_helper(tok,idx,
                                 is_opening_brace,
                                 is_closing_brace)
end

#+
function find_closing_square(tok::Tokenized,idx::Int)::Int
    return find_closing_X_helper(tok,idx,
                                 is_opening_square,
                                 is_closing_square)
end



#+Tokenizer,Internal
# Skips uniformative & identifier A or A.B.C or A.B{...}
# Returns (name,idx) if prod
# Does not move is identifier not found
# 
function skip_identifier(tok::Tokenized,idx::Int;
                         identifier::Ref{String}=Ref{String}(""))::Int
    identifier[]=""
    idx_save = idx
    idx = skip_uninformative(tok,idx)
    if !is_identifier(tok,idx)
        return idx_save
    end

    n=length(tok)
    identifier[] = untokenize(tok[idx])
    while idx<=n
        idx=idx+1
        idx_save = idx
        idx=skip_whitespace_strict(tok,idx)
        if is_dot(tok,idx)
            idx=idx+1
            idx=skip_whitespace_strict(tok,idx)
            if is_identifier(tok,idx)
                identifier[]=identifier[]*"."*untokenize(tok[idx])
                continue
            else
                identifier[]=""
                return idx_save # failure
            end
        end 
        
        if is_opening_brace(tok,idx)
            idx=find_closing_brace(tok,idx)
            return idx+1
        end

        return idx_save
    end

    identifier[]=""
    return idx_save
end

# function skip_identifier(tok::Tokenized,idx::Int)::Int
#     return last(get_and_skip_identifier(tok,idx))
# end

#+Tokenizer,Internal
# Skips uninformative & a comma separated sequence of identifiers A,A.B.C,A.B{...}
# Does not move is comma separeted identifier not found
function skip_comma_separated_identifiers(tok::Tokenized,idx::Int)::Int
    idx_save = idx
    idx = skip_uninformative(tok,idx)
    if !is_identifier(tok,idx)
        return idx_save
    end

    n=length(tok)
    while idx<=n
        idx=skip_identifier(tok,idx)
        idx_save=idx
        idx=skip_uninformative(tok,idx)
        if !is_comma(tok,idx)
            return idx_save
        end
        idx=idx+1
        idx=skip_uninformative(tok,idx)
        if !is_identifier(tok,idx)
            return idx_save
        end
    end 
    @assert false 
end 

#+Tokenizer,Internal
# Skips uninformative & a where block (where {...} or where A,B
# Does not move is comma separeted identifier not found
function skip_where_block(tok::Tokenized,idx::Int)::Int
    idx_save = idx
    idx = skip_uninformative(tok,idx)
    if !is_where(tok,idx)
        return idx_save
    end

    idx=idx+1
    idx = skip_uninformative(tok,idx)

    if is_opening_brace(tok,idx)
        return find_closing_brace(tok,idx)+1
    end

    if is_identifier(tok,idx)
        return skip_comma_separated_identifiers(tok,idx)
    end

    return idx_save
end 

#+Tokenizer,Internal
# Skips uninformative & a declaration block ::identifier{...}
# Does not move in case of identification failure
function skip_declaration_block(tok::Tokenized,idx::Int)::Int
    idx_save = idx
    idx = skip_uninformative(tok,idx)
    if !is_declaration(tok,idx)
        return idx_save
    end

    idx=idx+1
    idx=skip_uninformative(tok,idx)

    if is_identifier(tok,idx)
        return skip_identifier(tok,idx)
    end

    return idx_save
end
#+Tokenizer,Internal
# Skips uninformative & a function call block identifier{...}(....)
# Does not move in case of identification failure
function skip_function_call_block(tok::Tokenized,idx::Int;
                         identifier::Ref{String}=Ref{String}(""))::Int
    identifier[]=""
    idx_save = idx
    idx = skip_uninformative(tok,idx)
    if !is_identifier(tok,idx)
        return idx_save
    end

    idx=skip_identifier(tok,idx,identifier=identifier)
    idx=skip_uninformative(tok,idx)

    if is_opening_parenthesis(tok,idx)
        idx=find_closing_parenthesis(tok,idx)
        idx=idx+1
        return idx
    end

    return idx_save
end



#+Tokenizer,Internal
# Skips uniformative & issubtype indentifier
# Does not move is identifier not found
# 
function skip_issubtype_block(tok::Tokenized,idx::Int)::Int
    idx_save = idx
    idx = skip_uninformative(tok,idx)

    if !is_issubtype(tok,idx)
        return idx_save
    end
    idx=idx+1
    idx_check_success = idx
    idx = skip_identifier(tok,idx)

    if idx != idx_check_success
        return idx
    end

    return idx_save
end

#+Tokenizer,Internal
# Skips uniformative & structure block
# Does not move is identifier not found
# 
function skip_struct_block(tok::Tokenized,idx::Int;
                          identifier::Ref{String}=Ref{String}(""))::Int
    identifier[]=""
    idx_save = idx
    idx = skip_uninformative(tok,idx)

    check_is_structure = is_structure(tok,idx)
    check_is_mutable = is_mutable(tok,idx)
    check_is_immutable = is_immutable(tok,idx)
    
    if !(check_is_structure||check_is_mutable||check_is_immutable)
        return idx_save
    end

    if check_is_mutable||check_is_immutable
        idx=idx+1
        idx = skip_uninformative(tok,idx)

        if !is_structure(tok,idx)
            return idx_save
        end
    end

    @assert is_structure(tok,idx)
    
    idx=idx+1
    idx = skip_identifier(tok,idx,identifier=identifier)
    idx = skip_issubtype_block(tok,idx)
    
    return idx
end

#+Tokenizer,Internal
# Skips uniformative & abstract type block
# Does not move is identifier not found
# 
function skip_abstract_block(tok::Tokenized,idx::Int;
                             identifier::Ref{String}=Ref{String}(""))::Int
    identifier[]=""
    idx_save = idx
    idx = skip_uninformative(tok,idx)

    if is_abstract(tok,idx)

        idx = idx+1
        idx = skip_uninformative(tok,idx)

        if is_type(tok,idx)
            idx = idx + 1
            idx_check_success = idx
            idx = skip_identifier(tok,idx,identifier=identifier)

            if idx_check_success != idx
                # no need to check success as subtype is not mandatory
                idx = idx + 1
                idx = skip_issubtype_block(tok,idx)

                # success
                return idx
            end
        end
    end
    
    return idx_save
end
