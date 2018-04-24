

#+Documented_Item,Type
# A *central* structure containing documented item
#
struct Documented_Item
    _filename::String
    _tokenized::Tokenized
    _extracted_tag::Extract_Tag_Result
    _doc::Extracted_Comment
    _code::Union{Extracted_Function,
                 Extracted_Struct}
end 

#+Documented_Item,Methods
#
filename(di::Documented_Item)::String = di._filename
