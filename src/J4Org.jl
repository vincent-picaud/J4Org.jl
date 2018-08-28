module J4Org

using Random # for random string

export create_documented_item_array_dir, print_org_doc



if VERSION < v"0.7"
    const Nothing = Void
end



#+Error 
# You must use this function to print error message,
# It generates a message of the form
# #+BEGIN_EXAMPLE 
# # =WARNING:= message
# #+END_EXAMPLE
# which is an Org mode *comment*, hence it does not affect function output.
#
function warning_message(message::String)::Nothing
    println(stderr,"# =WARNING:= $(message)")
end 

#+Error,Links
# Generate a org compatible link to file
# *Examples:*
#!J4Org.create_file_org_link("/path/file.txt")
#!J4Org.create_file_org_link("/path/file.txt",10)
function create_file_org_link(filename::String,line::Int=0)::String
    if line<=0
        link = "[[file:$(filename)][$(basename(filename))]]"
    else 
        link = "[[file:$(filename)::$(line)][$(basename(filename)):$(line)]]"
    end
    return link
end



include("tokenizer.jl")
include("extract.jl")
include("find_tag.jl")
include("documented_item.jl")
include("links.jl")
include("evaluate.jl")
include("org_string_comment.jl")
include("org_string_code.jl")
include("main.jl")
    
end # module
