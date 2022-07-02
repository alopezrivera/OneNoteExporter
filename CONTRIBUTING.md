# Contributing to OneWayOut

OneWayOut has two ways of allowing you complete freedom to process your files:

* By giving you complete control over the Pandoc call
* By allowing you to post-process Pandoc's output using a Markup Pack of your choice

Contributions of any kind are than welcome. Below you can find urgently needed features, and the pointers you need to create your own Markup Packs and add support for more markup languages.

---

### Table of Contents

[**New Features**](#new-features)

[**Adding Markup Packs**](#adding-markup-packs)

[**Adding support for new markup formats**](#adding-support-for-new-markup-formats)

-----

## New features

### Better picture export

Currently, pictures in your notes are exported at fairly low resolution. Retrieving the pictures at their original resolution (that which they have inside OneNote) would be ideal.

### Better `InkDrawing` export

As mentioned in the README,

* You should start by 'flattening' all `InkDrawing` (i.e. pen/hand written elements) in your onennote pages. Because OneNote does not have this function you will have to take screenshots of your pages with pen/hand written notes and paste the resulting image and then remove the scriblings. If you are a heavy 'pen' user this is a very cumbersome.
  * Alternatively, if you are converting a notebook only for reading sake, and want to preserve all of your notes' layout, instead of flattening all `InkDrawing` manually you may prefer to export a  `.pdf` which preserves the full apperance and layout of the original note (including `InkDrawing`). Simply use the config option `$exportPdf = 2` to export a `.pdf` alongisde the markup file.

A way to automate this process would be good to have.

---

## Adding Markup Packs

Markup Packs are *markup-format-specific* **functions** containing search and replace queries executed at runtime against a string containing the entire markup content. If search and replace doesn't cut it, you can add a `postprocessing` scriptblock to increase your freedom (check the scriptblock to "Remove over-indentation of list items" in [Markdown MarkdownPack1](https://github.com/alopezrivera/owo/blob/master/src/Conversion/Markup-Packs/Markdown.psm1)).

A Markup Pack template is available in the [`templates` directory](https://github.com/alopezrivera/owo/tree/master/templates). It's an annotated version of the [Emacs Org Mode **OrgPack1**](https://github.com/alopezrivera/owo/blob/master/src/Conversion/Markup-Packs/Org.psm1) Markup Pack. If you're interested in exporting to a Markdown format, check the [Markdown MarkdownPack1](https://github.com/alopezrivera/owo/blob/master/src/Conversion/Markup-Packs/Markdown.psm1) Markup Pack for inspiration.

To add a Markup Pack, follow these steps:

1. Write your Markup Pack in the file containing the Markup Packs of your markup format of choice (`Org.psm1` or `Markdown.psm1` in `src/Conversion/Markup-Packs`). 
2. Set `markupPack` in your [config.ps1](https://github.com/alopezrivera/owo/blob/6ec09267553cec5848c02fa2f20531185b2b2289/config_example.ps1) to the name of your markup pack. That is, the name of the **function** you have written.


---

[Back to top](#contributing-to-onewayout)
