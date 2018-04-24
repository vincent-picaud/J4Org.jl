function org_string_code(di::Documented_Item)::String
    s=raw_string_code(di)
    if !isempty(s)
        s="#+BEGIN_SRC julia :eval never :exports code\n$(s)\n#+END_SRC\n"
    end
    return s
end 
