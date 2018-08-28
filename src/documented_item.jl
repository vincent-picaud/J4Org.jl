#+Documented_Item,Internal L:Documented_Item
# A *central* structure containing documented item
#
struct Documented_Item
    _filename::String
    _extracted_tag::Extract_Tag_Result
    _doc::Union{Nothing,
                Extracted_Comment}
    _code::Extracted_Item_Base
end 

#+Documented_Item
filename(di::Documented_Item)::String = di._filename
#+Documented_Item
tokenized(di::Documented_Item)::Tokenized = di._extracted_tag._tokenized
#+Documented_Item
tags(di::Documented_Item)::Vector{String} = tags(di._extracted_tag)
#+Documented_Item
identifier(di::Documented_Item)::String = identifier(di._code)
#+Documented_Item
raw_string_doc(di::Documented_Item)::String = (di._doc==nothing) ? "" : raw_string(di._doc)
#+Documented_Item
raw_string_code(di::Documented_Item)::String = (di._code==nothing) ? "" : raw_string(di._code)
#+Documented_Item
raw_string_code_with_body(di::Documented_Item)::String = (di._code==nothing) ? "" : raw_string_with_body(di._code)
#+Documented_Item
contains_tag(di::Documented_Item,tag::String)::Bool = tag ∈ tags(di)
#contains_tag(di::Documented_Item,tag::String)::Bool = contains(==,tags(di),tag)
#+Documented_Item
# Checks if at least one tag of =tag_list= is contained in =di=
contains_tag(di::Documented_Item,tag_list::Array{String,1})::Bool = mapreduce(x->contains_tag(di,x),(x,y)->x||y,tag_list)
#+Documented_Item
line(di::Documented_Item)::Int = line(di._extracted_tag)
#+Documented_Item
skip(di::Documented_Item)::Int = skip(di._code)

#+Documented_Item
# Returns links as string if exists, "" otherwise
link(di::Documented_Item)::String = link(di._extracted_tag)



#+Documented_Item
is_documented_function(di::Documented_Item)::Bool = typeof(di._code) == Extracted_Function
#+Documented_Item
is_documented_structure(di::Documented_Item)::Bool = typeof(di._code) == Extracted_Struct
#+Documented_Item
is_documented_abstract_type(di::Documented_Item)::Bool = typeof(di._code) == Extracted_Abstract
#+Documented_Item
is_documented_enum_type(di::Documented_Item)::Bool = typeof(di._code) == Extracted_Enum
#+Documented_Item
is_documented_variable_type(di::Documented_Item)::Bool = typeof(di._code) == Extracted_Variable
#+Documented_Item
is_documented_macro_type(di::Documented_Item)::Bool = typeof(di._code) == Extracted_Macro



#+Links,Documented_Item
function create_file_org_link(di::Documented_Item)::String
    return create_file_org_link(filename(di),line(di))
end 

#+Error,Documented_Item
# Use data from [[Documented_Item][]] to add a link after the message 
function warning_message(di::Documented_Item,message::String)::Nothing
    warning_message("$(message) $(create_file_org_link(di))")
end




function create_documented_item(extracted_tag::Extract_Tag_Result;
                                filename::String="")::Documented_Item
    idx=skip(extracted_tag)
    tok=extracted_tag._tokenized
    doc=extract_comment(tok,idx)
    if doc!=nothing
        idx=skip(doc)
    else
        # for the moment do not overload logs
        # println("--- WARNING: undocumented stuff file: $(filename):$(first(startpos(tok[idx]))) $(untokenize(tok[idx]))")
    end 
    code=extract_code(tok,idx)
    @assert code!=nothing

    return Documented_Item(filename,extracted_tag,doc,code)
end


function create_documented_item(tok::Tokenized,idx::Int;
                                filename::String="")::Documented_Item
    extracted_tag = extract_tag(tok,idx)
    @assert extracted_tag != nothing
    return create_documented_item(extracted_tag,filename=filename)
end


#+API L:create_documented_item_array_filename
#
# Reads a Julia code file and returns an array of documented items.
#
function create_documented_item_array(filename::String)::Array{Documented_Item,1}

    if VERSION < v"0.7"
        code = readstring(filename)
    else
        code = read(filename,String)
    end
    
    tok=tokenized(code)

    n=length(tok)
    idx=1
    toReturn=Array{Documented_Item,1}()
    
    while idx<=n
        extracted_tag = find_tag(tok,idx)

        # no more tag?
        # 
        if extracted_tag==nothing
            break
        end 

        try
            di=create_documented_item(extracted_tag,filename=filename)
            push!(toReturn,di)
        catch msg
            warning_message("cannot interpret $(filename):$(line(extracted_tag)) $(msg)")
        end

        # important to rescan after tag (and not after code):
        # tag1
        # struct foo
        #   tag2 <- catch me!
        #   constructor
        # end 
        idx=skip(extracted_tag)
    end
    return toReturn
end 

#+API
#
# Reads an array of Julia code files and returns an array of
# documented items.
#
# *Usage example:* 
# #+BEGIN_SRC julia
# create_documented_item_array(["file1","file2",...])
# #+END_SRC
#
# *Note:* instead of a list of files you can also specify a directory,
# see [[create_documented_item_array_dir][]]
function create_documented_item_array(filename_list::Array{String,1})::Array{Documented_Item,1}
    docItem_array = Array{Documented_Item,1}()
    
    for file in filename_list
        docItem_array = vcat(docItem_array,create_documented_item_array(file))
    end 

    return docItem_array
end 



function scan_directory_return_file_names(directory_name::AbstractString)
    expanded_dirname=expanduser(directory_name)
    @assert isdir(expanded_dirname)
 
    file_names = Vector{String}()

    for (root, dirs, files) in walkdir(expanded_dirname)

        for file in files
            push!(file_names,joinpath(root, file))
        end
        
    end

    return file_names
end 

function filter_julia_source_code_file_names(file_names::Array{<:AbstractString,1})
    file_name_pattern = r".jl$"
    return filter(x->occursin(file_name_pattern,x),file_names)
end 

    
#+API L:create_documented_item_array_dir
#
# Reads all *.jl files in a directory and returns an array of
# documented items.
#
function create_documented_item_array_dir(dirname::AbstractString)
    # expanded_dirname=expanduser(dirname)
    # @assert isdir(expanded_dirname)
    # # tips from https://stackoverflow.com/questions/20484581/search-for-files-in-a-folder
    # files=filter(x->contains(x,r".jl$"), readdir(expanded_dirname))
    # map!(x->expanded_dirname*x,files,files)

    file_names=scan_directory_return_file_names(dirname)
    files=filter_julia_source_code_file_names(file_names)
    return create_documented_item_array(files)
end 
