function _tide_multiline_prompt
    set -g add_prefix
    _tide_side=left for item in $_tide_left_items
        set -g add_suffix
        _tide_item_$item
    end
    if not set -e add_prefix && set -e add_suffix
        set_color $prev_bg_color -b normal
        echo $tide_left_prompt_suffix
    else
        echo
    end

    set -g add_prefix
    _tide_side=right for item in $_tide_right_items
        set -g add_suffix
        _tide_item_$item
    end
    if not set -e add_prefix && set -e add_suffix
        set_color $prev_bg_color -b normal
        echo $tide_right_prompt_suffix
    end
end

function _tide_item_pwd
    _tide_print_item pwd @PWD@
    set -e add_suffix
end

function _tide_item_newline
    set_color $prev_bg_color -b normal
    v=tide_"$_tide_side"_prompt_suffix echo $$v
    set -g add_prefix
    set -g add_suffix
end
