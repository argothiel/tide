# RUN: %fish %s
_tide_parent_dirs

set -lx tide_left_prompt_suffix '<left_prompt_suffix>'
set -lx prev_bg_color blue

function _tide_item_item1
    if set -e add_prefix
        echo -n '<prefix>'
    end
    echo -n item1
end

function _tide_item_item2
    if set -e add_prefix
        echo -n '<prefix>'
    end
    echo -n item2
end

function _tide_item_item3_add_prefix_and_remove_marker
    echo -n '<prefix>item3'
    set -e add_prefix
end

# Empty items
set -lx _tide_left_items
set -lx _tide_right_items
_tide_multiline_prompt | count
# CHECK: 1
_tide_multiline_prompt
# CHECK: {{^$}}

# Item on the left
set -lx _tide_left_items item1
set -lx _tide_right_items
_tide_multiline_prompt | count
# CHECK: 1
_tide_multiline_prompt | string replace -a \e\(B\e\[m '<ANSI_RESET>' | string replace -a \e\[34m '<ANSI_BG_BLUE>'
# CHECK: <prefix>item1<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE><left_prompt_suffix>

# Item on the right
set -lx _tide_left_items
set -lx _tide_right_items item1
_tide_multiline_prompt | count
# CHECK: 2
_tide_multiline_prompt | string replace -a \e\(B\e\[m '<ANSI_RESET>' | string replace -a \e\[34m '<ANSI_BG_BLUE>'
# CHECK: {{^$}}
# CHECK: <prefix>item1<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE>

# Items on both # FIXME
set -lx _tide_left_items item1
set -lx _tide_right_items item2
_tide_multiline_prompt | count
# CHECK: 2
echo "$(_tide_multiline_prompt)" | string replace -a \e\(B\e\[m '<ANSI_RESET>' | string replace -a \e\[34m '<ANSI_BG_BLUE>'
# CHECK: <prefix>item1<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE><left_prompt_suffix>
# CHECK: <prefix>item2<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE>

# Add prefix and remove # FIXME
set -lx _tide_left_items item3_add_prefix_and_remove_marker
set -lx _tide_right_items
_tide_multiline_prompt | count
# CHECK: 1
_tide_multiline_prompt | string replace -a \e\(B\e\[m '<ANSI_RESET>' | string replace -a \e\[34m '<ANSI_BG_BLUE>'
# CHECK: <prefix>item3<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE><left_prompt_suffix>

# Newline in left
set -lx _tide_left_items item1 newline item2
set -lx _tide_right_items item1
_tide_multiline_prompt | count
# CHECK: 3
_tide_multiline_prompt | string replace -a \e\(B\e\[m '<ANSI_RESET>' | string replace -a \e\[34m '<ANSI_BG_BLUE>'
# CHECK: <prefix>item1<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE><left_prompt_suffix>
# CHECK: <prefix>item2<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE><left_prompt_suffix>
# CHECK: <prefix>item1<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE>
