# Contributing to OneWayOut

OneWayOut has two ways of allowing you complete freedom to process your files:

* By giving you complete control over the Pandoc call
* By allowing you to post-process Pandoc's output using a Markup Pack of your choice

Contributions of any kind are than welcome. Below you can find urgently needed features, and the pointers you need to create your own Markup Packs and add support for more markup languages.

---

### Table of Contents

[**New Features**](#new-features)

[**Adding Markup Packs**](#adding-markup-packs)

-----

## New features

### Higher resolution picture export

Currently, pictures in your notes are exported at fairly low resolution. Retrieving the pictures at their original resolution (that which they have inside OneNote) would be ideal.

### `InkDrawing` support

`InkDrawing`s, that is, the format used by OneNote to store your hand-drawn notes, do not survive the OneNote to Word export process as of July 2022.

This is a major inconvenience for digitial pen users, but there is little `owo` can do about this. Two "solutions" are currently available:

* Manually replace all your drawings by screenshots of them before export. If you are a heavy pen user this is impracticable. Furthermore, your drawings will lose much of their resolution, making this a bad solution.
* Export PDFs of your notes alongside with their markup files. You can achieve this by setting `$exportPdf = 2` in your `config.ps1`. This way your drawings will keep their full resolution, albeit locked in PDF format. The export process will be slower and its output multiplied by two without clue as to which notes contained `InkDrawings`, making this too a bad solution.

In an ideal world, all `InkDrawing`s would be identified by `owo` before export, turned into SVGs and saved alongside other note media, and references to such SVGs would then be added in their place in your exported notes. Alas, I stopped being a heavy pen user long ago and do not have the time to look into it.

---

## Adding Markup Packs

Markup Packs are *markup-format-specific* **functions** containing search and replace queries executed at runtime against a string containing the entire markup content. If search and replace doesn't cut it, you can add a `postprocessing` scriptblock to increase your freedom (check the scriptblock to "Remove over-indentation of list items" in [Markdown MarkdownPack1](https://github.com/alopezrivera/owo/blob/master/src/Conversion/Markup-Packs/Markdown.psm1)).

A Markup Pack template is available in the [`templates` directory](https://github.com/alopezrivera/owo/tree/master/templates). It's an annotated version of the [Emacs Org Mode **OrgPack1**](https://github.com/alopezrivera/owo/blob/master/src/Conversion/Markup-Packs/Org.psm1) Markup Pack. If you're interested in exporting to a Markdown format, check the [Markdown MarkdownPack1](https://github.com/alopezrivera/owo/blob/master/src/Conversion/Markup-Packs/Markdown.psm1) Markup Pack for inspiration.

To add a Markup Pack, follow these steps:

1. Write your Markup Pack in the file containing the Markup Packs of your markup format of choice (`Org.psm1` or `Markdown.psm1` in `src/Conversion/Markup-Packs`). 
2. Set `markupPack` in your [config.ps1](https://github.com/alopezrivera/owo/blob/6ec09267553cec5848c02fa2f20531185b2b2289/config_example.ps1) to the name of your markup pack. That is, the name of the **function** you have written.


---

[Back to top](#contributing-to-onewayout)
