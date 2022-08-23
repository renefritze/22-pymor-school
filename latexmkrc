@default_files = ('integration_with_pde_solvers.tex');

$latex = 'latex -interaction=nonstopmode -recorder -file-line-error -synctex=1 --src-specials -shell-escape %O %S';

$lualatex= 'lualatex -interaction=nonstopmode -recorder -file-line-error -synctex=1 -shell-escape %O %S';

# this is for old (<=4.45) latexmk versions
$pdf_mode = 1;
$pdflatex = $lualatex;
# newer version would just set
# $pdf_mode = 4

$postscript_mode = $dvi_mode = 0;

# Use bibtex if a .bib file exists
$bibtex_use = 1;

$pdf_previewer = 'xdg-open';

# Also remove pdfsync files on clean
$clean_ext = 'pdfsync synctex.gz';

ensure_path( 'TEXINPUTS', './pymor-beamer//' );

$max_repeat = 5;

# workaround that prevents endless build loops with enabeld math font setting
# https://github.com/latex3/luaotfload/issues/40
# https://tex.stackexchange.com/q/475444
$hash_calc_ignore_pattern{'luc'} = '^';
