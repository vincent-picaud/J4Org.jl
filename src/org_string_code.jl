# +Internal
#
# Print first line of code
#
# For instance:
# #+BEGIN_SRC julia :eval never
# function foo()
# #+END_SRC
#
function org_string_code(di::Documented_Item)::String
    s=raw_string_code(di)
    if !isempty(s)
        s="#+BEGIN_SRC julia :eval never :exports code\n$(s)\n#+END_SRC\n"
    end
    return s
end

# +Internal
#
# Print first line of code AND body
#
# For instance:
# #+BEGIN_SRC julia :eval never
# function foo()
#   # foo body
# end
# #+END_SRC
#
function org_string_code_with_body(di::Documented_Item)::String
    s=raw_string_code_with_body(di)
    if !isempty(s)
        s="#+BEGIN_SRC julia :eval never :exports code\n$(s)\n#+END_SRC\n"
    end
    return s
end 
