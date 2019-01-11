using Tokenize
import Tokenize.Tokens: kind, exactkind, startpos

# Defines a convenient type alias 
const Tokenized = Array{Tokenize.Tokens.Token,1}
#+Tokenizer,Internal
# Defines a convenient method to tokenize a =String=
tokenized(s::String) = collect(tokenize(s))


# +Tokenizer,Internal
is_structure(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.STRUCT)
is_function(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.FUNCTION)
is_comment(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.COMMENT)
is_whitespace(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.WHITESPACE)
# +Tokenizer,Internal
# Checks for "\n"
is_whitespace_n(tok::Tokenized,idx::Int)::Bool = is_whitespace(tok,idx) && (untokenize(tok[idx])=="\n")
# +Tokenizer,Internal
# Checks for ENDMARKER (end of code)
is_endmarker(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.ENDMARKER)
is_identifier(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.IDENTIFIER)
is_declaration(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.DECLARATION)
is_dot(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.DOT)
is_comma(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.COMMA)
is_where(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.WHERE)
is_struct(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.STRUCT)
is_mutable(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.MUTABLE)
is_const(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.CONST)
is_global(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.GLOBAL)
is_local(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.LOCAL)
is_macro(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.MACRO)
is_issubtype(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.ISSUBTYPE)
is_export(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.EXPORT)
is_abstract(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.ABSTRACT)
is_type(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.TYPE)
is_end(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.END)
is_if(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.IF)
is_for(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.FOR)
is_while(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.WHILE)
is_begin(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.BEGIN)
is_try(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (exactkind(tok[idx])==Tokenize.Tokens.TRY)

# +Tokenizer,Internal
#
# Check if tok[i] points on
#
# #+BEGIN_SRC julia :eval never :exports code 
# @enum ...
# #+END_SRC
# 
function is_enum(tok::Tokenized,idx::Int)::Bool
    return (idx+1<=length(tok)) &&
        (exactkind(tok[idx])==Tokenize.Tokens.AT_SIGN) &&
        (untokenize(tok[idx+1])=="enum")
end



# +Tokenizer,Internal
is_opening_parenthesis(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.LPAREN)
is_closing_parenthesis(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.RPAREN)
is_opening_brace(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.LBRACE)
is_closing_brace(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.RBRACE)
is_opening_square(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.LSQUARE)
is_closing_square(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok)) && (kind(tok[idx])==Tokenize.Tokens.RSQUARE)


function is_opening_block(tok::Tokenized,idx::Int)::Bool
    return (idx<=length(tok))&&(is_structure(tok,idx)||
                                is_function(tok,idx)||
                                is_if(tok,idx)||
                                is_for(tok,idx)||
                                is_begin(tok,idx)||
                                is_try(tok,idx))
end

is_closing_block(tok::Tokenized,idx::Int)::Bool = (idx<=length(tok))&&(is_end(tok,idx))
    

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
                               is_closing_X::Function,
                               count_opening::Int = 0)::Int

    # @assert is_opening_X(tok,idx)
    
    # count_opening = 0
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
    @assert is_opening_parenthesis(tok,idx)
    return find_closing_X_helper(tok,idx,
                                 is_opening_parenthesis,
                                 is_closing_parenthesis)
end

#+
function find_closing_brace(tok::Tokenized,idx::Int)::Int
    @assert is_opening_brace(tok,idx)
    return find_closing_X_helper(tok,idx,
                                 is_opening_brace,
                                 is_closing_brace)
end

#+
function find_closing_square(tok::Tokenized,idx::Int)::Int
    @assert is_opening_square(tok,idx)
    return find_closing_X_helper(tok,idx,
                                 is_opening_square,
                                 is_closing_square)
end

#+Internal
#
# Find closing block (-> END)
#
# This function does not impose that the idx position is an opening
# block. If this is the case use the count_opening::Int = 0 default
# value.
#
# If you want to reach end of block starting from an already opened
# one (for instance from the middle of a function body, use the
# count_opening::Int = 1 value.
#
function find_closing_block(tok::Tokenized,idx::Int,
                            count_opening::Int = 0)::Int
    return find_closing_X_helper(tok,idx,
                                 is_opening_block,
                                 is_closing_block,
                                 count_opening)
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
    
    if !(check_is_structure||check_is_mutable)
        return idx_save
    end

    if check_is_mutable
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

#+Tokenizer,Internal
# Moves idx until it reaches a comment #, end of line \n or of file ENDMARKER
# 
function skip_line(tok::Tokenized,idx::Int)::Int
    while !(is_comment(tok,idx)||is_endmarker(tok,idx)||is_whitespace_n(tok,idx))
        idx=idx+1
    end
    return idx
end 

#+Tokenizer,Internal
# Skips uniformative & @enum ... line
# Does not move is identifier not found
# 
function skip_enum_block(tok::Tokenized,idx::Int;
                         identifier::Ref{String}=Ref{String}(""))::Int
    identifier[]=""
    idx_save = idx
    idx = skip_uninformative(tok,idx)

    if is_enum(tok,idx)

        idx = idx+2 # caveat skip @ AND enum 
        idx_check_success = idx
        idx = skip_identifier(tok,idx,identifier=identifier)

        if idx_check_success != idx
            # move until end of line (ignoring comment if any)
            idx = skip_line(tok,idx)
            return idx
        end
    end
    
    return idx_save
end

#+Tokenizer,Internal
# Skips uniformative & const A
# Does not move is identifier not found
# 
function skip_variable_block(tok::Tokenized,idx::Int;
                         identifier::Ref{String}=Ref{String}(""))::Int
    identifier[]=""
    idx_save = idx
    idx = skip_uninformative(tok,idx)

    
    if is_const(tok,idx)
        idx =  skip_uninformative(tok,idx+1)
    end

    if is_global(tok,idx)||is_local(tok,idx)
        idx =  skip_uninformative(tok,idx+1)
    end
    
    idx_check_success = idx
    idx = skip_identifier(tok,idx,identifier=identifier)

    if idx_check_success != idx
        return idx
    end
    
    return idx_save
end

#+Tokenizer,Internal
# Skips uniformative & @enum ... line
# Does not move is identifier not found
# 
function skip_macro_block(tok::Tokenized,idx::Int;
                         identifier::Ref{String}=Ref{String}(""))::Int
    identifier[]=""
    idx_save = idx
    idx = skip_uninformative(tok,idx)

    
    if is_macro(tok,idx)
        idx=idx+1    
        idx_check_success = idx
        idx = skip_identifier(tok,idx,identifier=identifier)

        if idx_check_success != idx
            idx=skip_uninformative(tok,idx)

            if is_opening_parenthesis(tok,idx)
                idx=find_closing_parenthesis(tok,idx)
                idx=idx+1
                return idx
            end
        end
    end 
    return idx_save
end
