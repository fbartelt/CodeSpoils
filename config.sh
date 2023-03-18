################################## COMPARISON ##################################
winner_color="91"
loser_color="92"

################################# PROGRESS BAR #################################
bar_size=40
bar_char_done="#"
bar_resolution=1

################################## FILE NAME ##################################
word_separator="_"
rank_separator="-"
declare -A extension_map=(
  ["agda"]="agda"
  ["bf"]="b"
  ["c"]="c"
  ["cfml"]="cfml"
  ["clojure"]="clj"
  ["cobol"]="cbl"
  ["coffeescript"]="coffee"
  ["commonlisp"]="lisp"
  ["coq"]="v"
  ["cpp"]="cpp"
  ["crystal"]="cr"
  ["csharp"]="cs"
  ["d"]="d"
  ["dart"]="dart"
  ["elixir"]="ex"
  ["elm"]="elm"
  ["erlang"]="erl"
  ["factor"]="factor"
  ["forth"]="4th"
  ["fortran"]="f95"
  ["fsharp"]="fs"
  ["go"]="go"
  ["groovy"]="groovy"
  ["haskell"]="hs"
  ["haxe"]="hx"
  ["idris"]="idr"
  ["java"]="java"
  ["javascript"]="js"
  ["julia"]="jl"
  ["kotlin"]="kt"
  ["lambdacalc"]="lambdacalc"
  ["lean"]="lean"
  ["lua"]="lua"
  ["nasm"]="asm"
  ["nim"]="nim"
  ["objc"]="m"
  ["ocaml"]="ml"
  ["pascal"]="pas"
  ["perl"]="pl"
  ["php"]="php"
  ["powershell"]="ps1"
  ["prolog"]="pl"
  ["purescript"]="purs"
  ["python"]="py"
  ["r"]="r"
  ["racket"]="rkt"
  ["raku"]="raku"
  ["reason"]="re"
  ["riscv"]="riscv"
  ["ruby"]="rb"
  ["rust"]="rs"
  ["scala"]="scala"
  ["shell"]="sh"
  ["solidity"]="sol"
  ["sql"]="sql"
  ["swift"]="swift"
  ["typescript"]="ts"
  ["vb"]="vb"
)
#################################### ICONS ####################################
bgcolor="\%23181717"
logocolor="white"
height="35"
logoWidth=""

# The icon is mapped to Codewars icon for languages without simple icons
declare -A iconMap=(
    ["cpp"]="c%2B%2B"
    ["groovy"]="apache-groovy"
    ["shell"]="gnu-bash" 
    ["agda"]="codewars"
    ["bf"]="codewars"
    ["cfml"]="codewars"
    ["cobol"]="codewars"
    ["commonlisp"]="codewars"
    ["coq"]="codewars"
    ["factor"]="codewars"
    ["forth"]="codewars"
    ["fsharp"]="codewars"
    ["idris"]="codewars"
    ["java"]="codewars"
    ["lambdacalc"]="codewars"
    ["lean"]="codewars"
    ["nasm"]="codewars"
    ["objc"]="codewars"
    ["pascal"]="codewars"
    ["prolog"]="codewars"
    ["raku"]="codewars"
    ["riscv"]="codewars"
    ["sql"]="codewars"
    ["vb"]="codewars"
    )