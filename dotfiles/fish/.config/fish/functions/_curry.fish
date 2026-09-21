set -g _FISH_ABBR_CURRY_COUNTER 1
function _curry
    set -l CURRIED_FN "_curried_fn_$_FISH_ABBR_CURRY_COUNTER"
    set _FISH_ABBR_CURRY_COUNTER (math $_FISH_ABBR_CURRY_COUNTER + 1)

    set -l INHERITED_ARGS $argv
    # LSP override: dude
    # @fish-lsp-disable-next-line 4004
    function "$CURRIED_FN" --inherit-variable INHERITED_ARGS
        $INHERITED_ARGS $argv
    end
    echo $CURRIED_FN
end
