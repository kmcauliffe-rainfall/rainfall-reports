// Quarto's default typst-show.typ forwards title/subtitle/author/date into the
// article template, which draws a metadata title block. These reports draw
// their own designed cover page in a ```{=typst}``` block, so this partial
// forwards typography only and omits the title metadata -- otherwise the cover
// content renders twice.
//
// Page geometry (paper, margins, footer) is set in styles/preamble.typ, and the
// article() signature does not accept it, so it is deliberately absent here.
#show: doc => article(
$if(mainfont)$
  font: ("$mainfont$",),
  heading-family: ("$mainfont$",),
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(section-numbering)$
  sectionnumbering: "$section-numbering$",
$endif$
$if(toc)$
  toc: $toc$,
$endif$
$if(toc-title)$
  toc_title: [$toc-title$],
$endif$
  toc_depth: $toc-depth$,
  cols: $if(columns)$$columns$$else$1$endif$,
  doc,
)
