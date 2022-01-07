# Contributing to OneWayOut

OneWayOut has two ways of allowing you complete freedom to process your files:

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

### Better picture export

Currently, pictures in your notes are exported at fairly low resolution. Retrieving the pictures at their original resolution would be ideal.

### Better `InkDrawing` export

As mentioned in the README,

* You should start by 'flattening' all `InkDrawing` (i.e. pen/hand written elements) in your onennote pages. Because OneNote does not have this function you will have to take screenshots of your pages with pen/hand written notes and paste the resulting image and then remove the scriblings. If you are a heavy 'pen' user this is a very cumbersome.
  * Alternatively, if you are converting a notebook only for reading sake, and want to preserve all of your notes' layout, instead of flattening all `InkDrawing` manually you may prefer to export a  `.pdf` which preserves the full apperance and layout of the original note (including `InkDrawing`). Simply use the config option `$exportPdf = 2` to export a `.pdf` alongisde the markup file.

A way to automate this process would be good to have.

### Encoding issue

It would seem that at some point in the process, either the conversion from OneNote to Word, or from Word to whatever markup, content is being read with the wrong enconding. This generates unwanted characters in the final result such as

* Â
* Ã

which are then removed in post-processing. Finding the source of this and removing the issue would be convenient to ensure OneWayOut works properly with any character set.

### Running out of memory

In the case of rather large collections, the system may run out of memory before finishing the process. Currently the best workaround for this is to save the generated Word files and start back up hoping for the best, or export the collection notebook by notebook.

Flushing memory after, say, a notebook export is completed, or any other way to solve this problem would be very welcome.

---

## Adding Markup Packs

Markup Packs are *markup-format-specific* **functions** containing search and replace queries executed at runtime against a string containing the entire markup content. If search and replace doesn't cut it, you can add a `postprocessing` scriptblock to increase your freedom (check the scriptblock to "Remove over-indentation of list items" in [Markdown MarkdownPack1](https://github.com/alopezrivera/owo/blob/master/src/Conversion/Markup-Packs/Markdown.psm1)).

A Markup Pack template is available in the [`templates` directory](https://github.com/alopezrivera/owo/tree/master/templates). It's an annotated version of the [Emacs Org Mode **OrgPack1**](https://github.com/alopezrivera/owo/blob/master/src/Conversion/Markup-Packs/Org.psm1) Markup Pack. If you're interested in exporting to a Markdown format, check the [Markdown MarkdownPack1](https://github.com/alopezrivera/owo/blob/master/src/Conversion/Markup-Packs/Markdown.psm1) Markup Pack for inspiration.

To add a Markup Pack, follow these steps:

1. Write your Markup Pack in the file containing the Markup Packs of your markup format of choice (`Org.psm1` or `Markdown.psm1` in `src/Conversion/Markup-Packs`). 
   * **If you intend to export to a markup format that is neither Emacs Org Mode nor a variety of Markdown, [read the section below and come back.](#adding-support-for-new-markup-formats)**
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

Currently, any Pandoc-supported markup with `markdown` or `org` in its Pandoc name is supported by OneWayOut, or in other words, Org Mode and any Markdown variety. To clarify, Pandoc will correctly convert to any file format it supports. OneWayOut "support" means that the files will be exported with their correct extension, and that the output by Pandoc will be processed by a default Markup Pack. The following formats fall in this category:

* org (Emacs Org Mode)
* markdown (Pandoc’s Markdown)
* commonmark (CommonMark Markdown)
* gfm (GitHub-Flavored Markdown), or the deprecated and less accurate markdown_github; use markdown_github only if you need extensions not supported in gfm.
* markdown_mmd (MultiMarkdown)
* markdown_phpextra (PHP Markdown Extra)
* markdown_strict (original unextended Markdown)

If your export format of choice does not fall in this category, you may easily add support for it. To do so, follow these steps:

1. Edit `src/Conversion/Conversion-Markup.psm1`
   * Add the new Markup format to the Markup extension hashtable in `Get-MarkupExtension`
      * KEY: Pandoc name of the new Markup format (eg: `markdown` in the case of `markdown` or `markdown_phpextra`)
      * VAL: File extension of the new Markup format
1. Optionally, write a Markup Pack for the new format
   1. Create a new PowerShell module for the new markup format 
      * `src/Conversion/Markup-Packs/<Name of the new Markup format>.psm1`
   1. Write a custom Markup Pack. Check the [previous section for reference.](#adding-markup-packs)
   1. Import your Markup Pack PowerShell module in `src/Conversion/Conversion-Config.psm1`
      * Under the Markup Pack imports (line 8) add `Import-Module .\src\Conversion\Markup-Packs\<Name of the new Markup format>.psm1`
   1. [Set your Markup Pack as the default for the new format](#adding-markup-packs)

---

[Back to top](#contributing-to-onewayout)
