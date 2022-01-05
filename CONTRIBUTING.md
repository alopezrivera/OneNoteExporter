# Contributing to OneUp

OneUp has two ways of allowing you complete freedom to process your files:

* By giving you direct control over the Pandoc call
* By allowing you to post-process Pandoc's output using a Markup Pack of your choice

More Markup Packs, fixing bugs and improving the code are all more than welcome :)

---

### Table of Contents

[**Adding Markup Packs**](#adding-markup-packs)

[**Improvements**](#improvements)

---

## Adding Markup Packs

A Markup Pack template is available in the [`Markup-Packs` directory](). Check the [Markdown]() and [Org Mode]() Markup Packs for further reference.

## Improvements

---

### Exporting `InkDrawing`s

As mentioned in the README,

* You should start by 'flattening' all `InkDrawing` (i.e. pen/hand written elements) in your onennote pages. Because OneNote does not have this function you will have to take screenshots of your pages with pen/hand written notes and paste the resulting image and then remove the scriblings. If you are a heavy 'pen' user this is a very cumbersome.
  * Alternatively, if you are converting a notebook only for reading sake, and want to preserve all of your notes' layout, instead of flattening all `InkDrawing` manually you may prefer to export a  `.pdf` which preserves the full apperance and layout of the original note (including `InkDrawing`). Simply use the config option `$exportPdf = 2` to export a `.pdf` alongisde the markup file.

A way to automate this process would be awesome.

---

[Back to top](#contributing-to-oneup)
