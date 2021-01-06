" Author: Tomokatsu Mizukusa
" Description: Adds support for Cadence Xcelium `xrun` Verilog compiler

call ale#Set('verilog_xrun_options', '')

function! ale_linters#verilog#xrun#GetCommand(buffer) abort
    return 'xrun -compile '
    \   . ale#Var(a:buffer, 'verilog_xrun_options')
    \   . ' %t'
endfunction

function! ale_linters#verilog#xrun#Handle(buffer, lines) abort
    " Look for lines like the following.
    "
    " xmvlog: *E,EXPSMC (top.sv,29|9): expecting a semicolon (';') [12.1(IEEE)].
    " xmvlog: *W,NONPRT (top.v,18|31): non-printable character (0xxx) ignored.
    let l:pattern = '^xmvlog: \*\(E\|W\),\([A-Z]\+\) ([^,]\+,\(\d\+\)|\d\+): \(.*\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:line = l:match[3] - 1
        let l:type = l:match[1]
        let l:text = '[' . l:match[1] . ']' . l:match[2] . ' : ' . l:match[4]

        call add(l:output, {
        \   'lnum': l:line,
        \   'text': l:text,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('verilog', {
\   'name': 'xrun',
\   'output_stream': 'stdout',
\   'executable': 'xrun',
\   'command': function('ale_linters#verilog#xrun#GetCommand'),
\   'callback': 'ale_linters#verilog#xrun#Handle',
\})
