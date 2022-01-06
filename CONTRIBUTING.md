# Contributing to OneWayOut

**owo** has two ways of allowing you complete freedom to process your files:

* By giving you complete control over the Pandoc call
* By allowing you to post-process Pandoc's output using a Markup Pack of your choice

Contributions of any kind are than welcome. Below you can find urgently needed features, and the pointers you need to create your own Markup Packs and add support for more markup languages.

---

### Table of Contents

[**Features**](#improvements)

[**Adding Markup Packs**](#adding-markup-packs)

[**Adding support for new markup formats**](#adding-support-for-new-markup-formats)

---

## Features

### Better `InkDrawing` export

As mentioned in the README,

* You should start by 'flattening' all `InkDrawing` (i.e. pen/hand written elements) in your onennote pages. Because OneNote does not have this function you will have to take screenshots of your pages with pen/hand written notes and paste the resulting image and then remove the scriblings. If you are a heavy 'pen' user this is a very cumbersome.
  * Alternatively, if you are converting a notebook only for reading sake, and want to preserve all of your notes' layout, instead of flattening all `InkDrawing` manually you may prefer to export a  `.pdf` which preserves the full apperance and layout of the original note (including `InkDrawing`). Simply use the config option `$exportPdf = 2` to export a `.pdf` alongisde the markup file.

A way to automate this process would be awesome.

---

## Adding Markup Packs

A Markup Pack template is available in the [`Markup-Packs` directory](). Inside there is a function containing all text post-processing. Check the [Markdown](https://github.com/alopezrivera/owo/blob/master/src/Conversion/Markup-Packs/Markdown.psm1) and [Org Mode](https://github.com/alopezrivera/owo/blob/master/src/Conversion/Markup-Packs/Org.psm1) Markup Packs, with functions `Format-Markdown` and `Format-Org` respectively, for further reference.

To add a Markup Pack, follow these steps:

1. Place your Markup Pack in `src/Conversion/Markup-Packs`
1. Edit `src/Conversion/Conversion-Config.psm1`
   * Under the Markup Pack imports (line 8) add `Import-Module .\src\Conversion\Markup-Packs\<Your Markup Pack>.psm1`
1. Edit `src/Conversion/Conversion-Markup.psm1` to set your Markup Pack as the default for the markup format of your choice.
   * Edit the Markup Pack hashtable in `Get-MarkupPack`, replacing the **string** `"Format-Org"` or `"Format-Markdown"` for a **string** with the name of your method.
      ```
      $markupPacks = @{
         org = "Format-Org";      -> "<Your Markup Pack function>"
         md  = "Format-Markdown"; -> "<Your Markup Pack function>"
      }
      ```

---

## Adding support for new markup formats

Currently, any Pandoc-supported markup with `markdown` or `org` in its Pandoc name is supported by **owo**. To clarify, Pandoc will correctly convert to any file format it supports. **owo** "support" means that the files will be exported with their correct extension, and the result will be processed by a default Markup Pack. The following formats fall in this category:

* org (Emacs Org Mode)
* markdown (Pandoc’s Markdown)
* commonmark (CommonMark Markdown)
* gfm (GitHub-Flavored Markdown), or the deprecated and less accurate markdown_github; use markdown_github only if you need extensions not supported in gfm.
* markdown_mmd (MultiMarkdown)
* markdown_phpextra (PHP Markdown Extra)
* markdown_strict (original unextended Markdown)

If your export format of choice does not contain `markdown` or `org` in its Pandoc name, you can add support for it easily! To do so, follow these steps:

1. Edit `src/Conversion/Conversion-Markup.psm1`
   1. Add the new Markup format to the Markup extension hashtable in `Get-MarkupExtension`
      * KEY: Pandoc name of the new Markup format (eg: `markdown` in the case of `markdown` or `markdown_phpextra`)
      * VAL: File extension of the new Markup format
   2. Optionally, write a Markup Pack for the new format [and set it as default for it](#adding-markup-packs)

---

[Back to top](#contributing-to-oneup)
