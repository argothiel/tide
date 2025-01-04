function fish_prompt
end # In case this file gets loaded non-interactively, e.g by conda
status is-interactive || exit

_tide_remove_unusable_items
_tide_cache_variables
_tide_parent_dirs
source (functions --details _tide_pwd)

set -l prompt_var _tide_prompt_$fish_pid
set -U $prompt_var # Set var here so if we erase $prompt_var, bg job won't set a uvar

set_color normal | read -l color_normal
status fish-path | read -l fish_path

# _tide_repaint prevents us from creating a second background job
function _tide_refresh_prompt --on-variable $prompt_var --on-variable COLUMNS
    set -g _tide_repaint
    commandline -f repaint
end

contains newline $_tide_left_items && set_color $tide_prompt_color_frame_and_connection -b normal | read -l prompt_and_frame_color

contains newline $_tide_left_items &&
  set -l left_frame_begin '╭─' &&
  set -l left_frame_middle '│ ' &&
  set -l left_frame_end '╰─' &&
  set -l right_frame_begin '─╮' &&
  set -l right_frame_middle ' │' &&
  set -l right_frame_end '─╯'

set -l left_items_by_line (string split newline (echo $_tide_left_items))
count $left_items_by_line | read -l _tide_lines_count_left
set -l right_items_by_line (string split newline (echo $_tide_right_items))
count $right_items_by_line | read -l _tide_lines_count_right
math max $_tide_lines_count_left, $_tide_lines_count_right | read -l _tide_lines_count

set -l fish_prompt_code "function fish_prompt"\n"   "

if test "$tide_prompt_transient_enabled" = true
    set -a fish_prompt_code "set -lx _tide_status \$status"\n\n"   "
else
    set -a fish_prompt_code "_tide_status=\$status"
end

set -a fish_prompt_code "_tide_pipestatus=\$pipestatus if not set -e _tide_repaint
        jobs -q && jobs -p | count | read -lx _tide_jobs
        $fish_path -c \"set _tide_pipestatus \$_tide_pipestatus
            set _tide_parent_dirs \$_tide_parent_dirs
            PATH=\$(string escape \"\$PATH\") CMD_DURATION=\$CMD_DURATION fish_bind_mode=\$fish_bind_mode set $prompt_var (_tide_multiline_prompt)\" &
        builtin disown

        command kill \$_tide_last_pid 2>/dev/null
        set -g _tide_last_pid \$last_pid
    end"\n\n

test "$tide_prompt_transient_enabled" = true &&
    set -a fish_prompt_code "   if set -q _tide_transient
        echo -n \e\[0J
        add_prefix= _tide_item_character
        echo -n '$color_normal '
        return
    end"\n\n
    
test "$tide_prompt_add_newline_before" = true && set -a fish_prompt_code "   echo"\n\n
for line_no in (seq 1 $_tide_lines_count)
    set -l line_left $left_items_by_line[$line_no]
    set -l line_right $right_items_by_line[$line_no]
    string split ' ' $line_left | string match pwd | count | read -l pwd_placeholder_count_left
    string split ' ' $line_right | string match pwd | count | read -l pwd_placeholder_count_right
    math $pwd_placeholder_count_left \+ $pwd_placeholder_count_right | read -l pwd_placeholder_count
    math 5 \* $pwd_placeholder_count | read -l column_offset

    for side in left right
        v=tide_"$side"_prompt_frame_enabled if test "$v"
            if test $line_no -eq 1
                frame_var="$side"_frame box_line_var="$side"_frame_begin set $frame_var "$prompt_and_frame_color$$box_line_var"
            else if test $line_no -eq $_tide_lines_count
                frame_var="$side"_frame box_line_var="$side"_frame_end set $frame_var "$prompt_and_frame_color$$box_line_var"
            else
                frame_var="$side"_frame box_line_var="$side"_frame_middle set $frame_var "$prompt_and_frame_color$$box_line_var"
            end
            math $column_offset - 2 | read column_offset
        end
    end

    if test $line_no -eq 1
        set -f filler $tide_prompt_icon_connection
        set -f filler_color $prompt_and_frame_color
    else
        set -f filler ' '
        set -f filler_color $color_normal
    end

    test $line_no -eq 1 || test $pwd_placeholder_count -gt 0 &&
        set -a fish_prompt_code "   math \$COLUMNS - (string length -V \"\$"$prompt_var"[$line_no]\$"$prompt_var"["(math $line_no + $_tide_lines_count_left)"]\") + $column_offset | read -l dist_btwn_sides"\n

    if test $pwd_placeholder_count_left -eq 0
        set -a fish_prompt_code "   echo -n \e\[0J'$left_frame'\$"$prompt_var"[$line_no]'$filler_color'"
    else
        if test $line_no -eq $_tide_lines_count
            if test $pwd_placeholder_count -eq 1
                set -a fish_prompt_code "   math \$dist_btwn_sides - $tide_prompt_min_cols | read -lx _tide_max_pwd_width"\n
            else
                set -a fish_prompt_code "   math \( \$dist_btwn_sides - $tide_prompt_min_cols \) / $pwd_placeholder_count | read -lx _tide_max_pwd_width"\n
            end
        else
            if test $pwd_placeholder_count -eq 1
                set -a fish_prompt_code "   set -lx _tide_max_pwd_width \$dist_btwn_sides"\n
            else
                set -a fish_prompt_code "   math \$dist_btwn_sides / $pwd_placeholder_count | read -lx _tide_max_pwd_width"\n
            end
        end
        set -a fish_prompt_code "   echo -n \e\[0J'$left_frame'(string replace -a @PWD@ (_tide_pwd) \"\$"$prompt_var"[$line_no]\")'$filler_color'"
    end

    if test $line_no -ne $_tide_lines_count
        set -a fish_prompt_code \n"    string repeat -Nm(math max 0,"
        if test $pwd_placeholder_count = 0
            set -a fish_prompt_code "\$dist_btwn_sides) '$filler'"
        else if test $pwd_placeholder_count -eq 1
            set -a fish_prompt_code "\$dist_btwn_sides - \$_tide_pwd_len) '$filler'"
        else if test $pwd_placeholder_count -gt 1
            set -a fish_prompt_code "\$dist_btwn_sides - \$_tide_pwd_len \* $pwd_placeholder_count) '$filler'"
        end
        if test $pwd_placeholder_count_right -gt 0
            set -a fish_prompt_code \n"    echo (string replace -a @PWD@ (_tide_pwd) \"\$"$prompt_var"["(math $line_no + $_tide_lines_count_left)"]\")\"$right_frame\""\n\n
        else
            set -a fish_prompt_code \n"    echo \"\$"$prompt_var"["(math $line_no + $_tide_lines_count_left)"]$right_frame\""\n
        end
    else
        set -a fish_prompt_code "''
end

function fish_right_prompt"\n"   "
        if test $pwd_placeholder_count_right -gt 0
            set -a fish_prompt_code "math \$COLUMNS - (string length -V \"\$"$prompt_var"[$line_no]\$"$prompt_var"["(math $line_no + $_tide_lines_count_left)"]\") + $column_offset | read -l dist_btwn_sides"\n
            if test $pwd_placeholder_count -eq 1
                set -a fish_prompt_code "   math \$dist_btwn_sides - $tide_prompt_min_cols | read -lx _tide_max_pwd_width"\n"   "
            else
                set -a fish_prompt_code "   math \( \$dist_btwn_sides - $tide_prompt_min_cols \) / $pwd_placeholder_count | read -lx _tide_max_pwd_width"\n"   "
            end
        end
        test "$tide_prompt_transient_enabled" = true && set -a fish_prompt_code "set -e _tide_transient ||"

        if test $pwd_placeholder_count_right -gt 0
            set -a fish_prompt_code "string replace -a @PWD@ (_tide_pwd) \"\$"$prompt_var"["(math 2 \* $_tide_lines_count)"]$right_frame$color_normal\""
        else
            set -a fish_prompt_code "string unescape \"\$"$prompt_var"["(math 2 \* $_tide_lines_count)"]$right_frame$color_normal\""
        end
        set -a fish_prompt_code \n"end"
    end
end

eval $fish_prompt_code

# Inheriting instead of evaling because here load time is more important than runtime
function _tide_on_fish_exit --on-event fish_exit --inherit-variable prompt_var
    set -e $prompt_var
end

if test "$tide_prompt_transient_enabled" = true
    function _tide_enter_transient
        # If the commandline will be executed or is empty, and the pager is not open
        # Pager open usually means selecting, not running
        # Can be untrue, but it's better than the alternative
        if commandline --is-valid || test -z "$(commandline)" && not commandline --paging-mode
            set -g _tide_transient
            set -g _tide_repaint
            commandline -f repaint
        end
        commandline -f execute
    end

    bind \r _tide_enter_transient
    bind \n _tide_enter_transient
    bind -M insert \r _tide_enter_transient
    bind -M insert \n _tide_enter_transient
end
