# owo test

Tuesday, June 5, 2022 `19:45`

---

**Bold,** *italic* and [underscored text.]{.underline}

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
      1. ...
         1. ...
            1. ...

Empty list items are deleted, such as the ones (not) seen below.

- 1.  

_TABLES_
| a   | b   | c   |
|-----|-----|-----|
| 1   | 4   | 7   |
| 2   | 5   | 8   |
| 3   | 6   | 9   |

_FIGURES_
![](../media/General-owo-test-image1.jpeg){width="2.2736111111111112in" height="1.707638888888889in"}

_UNSUPPORTED_

**Indented paragraph separated by line break**

Issues:

**+** Blank lines afterwards not conserved

- _
  
  **<HERE>**
< --- >

**Deindented bullet after blank line**

Issues:

**+** Indentation not conserved

- _
  - _
    - _



- **<HERE>**

< --- >

**Deindented bullet after indented paragraph**

Issues:

**+** Paragraph content wrapped in #+QUOTE

**+** Indentation not conserved

- _
  - _
    - _

_

-   **<HERE>**