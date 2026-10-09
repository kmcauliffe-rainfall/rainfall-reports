/* Typst preamble — requires format.typst.root = repo root (see v5-final.qmd) */

#let font-regular = "DM Sans"
#let font-bold = "DM Sans"

#set text(font: font-regular, size: 10.5pt, fill: rgb("#203050"))

#show heading.where(level: 1): set text(font: font-bold, weight: "bold", size: 15pt, fill: rgb("#203050"))
#show heading.where(level: 2): set text(font: font-bold, weight: "bold", size: 12.5pt, fill: rgb("#203050"))
#show heading.where(level: 3): set text(font: font-bold, weight: "medium", size: 11pt, fill: rgb("#203050"))

#set page(
  paper: "us-letter",
  margin: (left: 0.7in, right: 0.7in, top: 0.7in, bottom: 0.78in),
  footer: context {
    if counter(page).get().first() > 1 {
      set text(size: 8pt, fill: rgb("#64748b"), font: font-regular)
      grid(
        columns: (1fr, auto, 1fr),
        align: (left, center, right),
        [CMS TEAM Impact Report · v5 final],
        counter(page).display("1"),
        box(height: 13pt, image("../assets/rainfall-logo.png")),
      )
    }
  },
)

#set par(justify: true, leading: 0.62em)
