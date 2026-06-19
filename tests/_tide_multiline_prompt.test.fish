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

# Newline in left
set -lx _tide_left_items item1 newline item2
set -lx _tide_right_items item1
_tide_multiline_prompt | count
# CHECK: 3
_tide_multiline_prompt | string replace -a \e\(B\e\[m '<ANSI_RESET>' | string replace -a \e\[34m '<ANSI_BG_BLUE>'
# CHECK: <prefix>item1<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE><left_prompt_suffix>
# CHECK: <prefix>item2<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE><left_prompt_suffix>
# CHECK: <prefix>item1<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE>

# Single item per side, no newline (baseline 1-line prompt)
set -lx _tide_left_items item1
set -lx _tide_right_items item1
_tide_multiline_prompt | count
# CHECK: 2
_tide_multiline_prompt | string replace -a \e\(B\e\[m '<ANSI_RESET>' | string replace -a \e\[34m '<ANSI_BG_BLUE>'
# CHECK: <prefix>item1<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE><left_prompt_suffix>
# CHECK: <prefix>item1<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE>

# Multiple items per line, no newline (1-line prompt with two items per side)
set -lx _tide_left_items item1 item2
set -lx _tide_right_items item1
_tide_multiline_prompt | count
# CHECK: 2
_tide_multiline_prompt | string replace -a \e\(B\e\[m '<ANSI_RESET>' | string replace -a \e\[34m '<ANSI_BG_BLUE>'
# CHECK: <prefix>item1item2<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE><left_prompt_suffix>
# CHECK: <prefix>item1<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE>

# Item suppressing the suffix (mirrors the _tide_item_character / _tide_item_pwd protocol)
function _tide_item_no_suffix
    if set -e add_prefix
        echo -n '<prefix>'
    end
    echo -n NS
    set -e add_suffix
end
set -lx _tide_left_items item1 no_suffix
set -lx _tide_right_items
_tide_multiline_prompt | count
# CHECK: 1
_tide_multiline_prompt | string replace -a \e\(B\e\[m '<ANSI_RESET>' | string replace -a \e\[34m '<ANSI_BG_BLUE>'
# CHECK: <prefix>item1NS

# Three-line left, single right (asymmetric line counts — guards against bad
# array indexing in fish_prompt.fish for last-line right content)
set -lx _tide_left_items item1 newline item2 newline item1
set -lx _tide_right_items item2
_tide_multiline_prompt | count
# CHECK: 4
_tide_multiline_prompt | string replace -a \e\(B\e\[m '<ANSI_RESET>' | string replace -a \e\[34m '<ANSI_BG_BLUE>'
# CHECK: <prefix>item1<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE><left_prompt_suffix>
# CHECK: <prefix>item2<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE><left_prompt_suffix>
# CHECK: <prefix>item1<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE><left_prompt_suffix>
# CHECK: <prefix>item2<ANSI_RESET><ANSI_RESET><ANSI_BG_BLUE>
