function abbr_anysubcommand_arg
    if test (count $argv) -gt 3
        echo "ERROR: abbr_anysubcommand_arg does not take denylist arguments"
        return 1
    end
    _curry_abbr _abbr_expand_exceptsubcommand_arg $argv[1..3]
end
