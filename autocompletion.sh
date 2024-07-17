#/usr/bin/env bash
_dothis_completions()
{
    if [ "${#COMP_WORDS[@]}" != "2" ]; then
        return
    fi

    f=$(grep -Elr 'documentclass' `find . -name "*.tex"` | cut -d':' -f1)
    target_list=''
    for file in ${f}
    do
        file=${file##*/}
        file=${file%.*}
        target_list+=' '${file}
    done
    COMPREPLY=($(compgen -W "${target_list}" "${COMP_WORDS[1]}"))
}
complete -F _dothis_completions edition.launch