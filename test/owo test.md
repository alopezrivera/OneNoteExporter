# owo test

Tuesday, June 5, 2022 `19:45`

---

**Bold,** *italic* and <span class="underline">underscored text.</span>

Formatted text.

_LISTS_

**Unordered:**

- Bulleted list item  
  Paragraph below list item  
  Second paragraph below list item

- Second bullet
  - Child bullet  
    Paragraph at deeper indent level
  - Child bullet separated by line break
    - Third
    - Fourth
  - Deindented bullet

**Ordered:**

1. Numbered list item
1. Second numbered item  
   Indented paragraph under numbered list item
   1. Child numbered item
   1. Second child numbered item
      1. …
         1. …
            1. …

Empty list items are deleted, such as the ones (not) seen below.

- 1.  

_TABLES_
| a   | b   | c   |
|-----|-----|-----|
| 1   | 4   | 7   |
| 2   | 5   | 8   |
| 3   | 6   | 9   |

_FIGURES_

<img src="media/owo test-image1.jpeg" style="width:2.27361in;height:1.70764in" />

_UNSUPPORTED_

**Indented paragraph separated by line break**

Issues:

**+** Blank lines afterwards not conserved

- _  
    
  **&lt;HERE&gt;**
&lt; --- &gt;

**Deindented bullet after blank line**

Issues:

**+** Indentation not conserved

- _
  - _
    - _



- **&lt;HERE&gt;**

&lt; --- &gt;

**Deindented bullet after indented paragraph**

Issues:

**+** Paragraph content wrapped in #+QUOTE

**+** Indentation not conserved

- _
  - _
    - _

_

-   **&lt;HERE&gt;**