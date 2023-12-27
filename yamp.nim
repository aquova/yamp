# yamp
# Yet Another Markdown Parser
#
# Supports:
# Header 1-3
# Paragraphs
# Italics, bold, strikethru, underline
# Ordered and unordered lists
# Hyperlinks
# Images
# Code tags
# Line breaks, horizontal lines

import os, strscans, strutils

proc usage() =
    echo """
Nim Markdown Parser
Usage: ./yamp input.md output.html
    """

proc main() =
    if paramCount() < 2:
        usage()
        quit(0)

    var f: File
    let input_filename = paramStr(1)
    let output_filename = paramStr(2)

    if not input_filename.fileExists():
        echo("Unable to open ", input_filename)
        quit(1)

    let success = f.open(output_filename, FileMode.fmWrite)
    if not success:
        echo("Unable to open ", output_filename)
        quit(1)

    f.write("<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"utf-8\">\n</head>\n<body>\n")

    var prev_empty, ordered_list, unordered_list, code_block = false
    for line in lines(input_filename):
        var
            pre, txt, link, post: string
            unused: int
            modified_line = line

        if line.startsWith("```"):
            if not code_block:
                f.write("<pre><code>\n")
            else:
                f.write("</code></pre>\n")
            code_block = not code_block
            continue

        # Don't convert any text inside a code block
        if code_block:
            f.write(line & "\n")
            continue

        if line == "":
            if prev_empty:
                f.write("<br/>\n")
            else:
                # Only add a '<br>' if we have >1 line breaks
                prev_empty = true
            continue
        else:
            prev_empty = false

        if line == "---":
            f.write("<hr/>\n")
            continue

        # Headers
        if line.scanf("###$s$+", txt):
            f.write("<h3>", txt, "</h3>\n")
            continue
        elif line.scanf("##$s$+", txt):
            f.write("<h2>", txt, "</h2>\n")
            continue
        elif line.scanf("#$s$+", txt):
            f.write("<h1>", txt, "</h1>\n")
            continue

        # Images
        if modified_line.scanf("$*![$+]($+)$*", pre, txt, link, post):
            f.write(pre & "<img src=\"" & link & "\" />" & post)
            continue

        # Special case for bold and italics
        while modified_line.scanf("$****$+***$*", pre, txt, post):
            modified_line = pre & "<b><i>" & txt & "</i></b>" & post

        # Bold
        while modified_line.scanf("$***$+**$*", pre, txt, post):
            modified_line = pre & "<b>" & txt & "</b>" & post

        # Italics
        while modified_line.scanf("$**$+*$*", pre, txt, post):
            modified_line = pre & "<i>" & txt & "</i>" & post

        # Strikethru
        while modified_line.scanf("$*~~$+~~$*", pre, txt, post):
            modified_line = pre & "<del>" & txt & "</del>" & post

        # Underline
        while modified_line.scanf("$*__$+__$*", pre, txt, post):
            modified_line = pre & "<u>" & txt & "</u>" & post

        # In-line code block
        while modified_line.scanf("$*`$+`$*", pre, txt, post):
            modified_line = pre & "<code>" & txt & "</code>" & post

        # Lists
        if line.scanf("$s-$s$+", txt):
            if not unordered_list:
                f.write("<ul>\n")
                unordered_list = true
            f.write("<li>", txt, "</li>\n")
            continue
        elif unordered_list:
            f.write("</ul>\n")
            unordered_list = false

        if line.scanf("$s$i.$s$+", unused, txt):
            if not ordered_list:
                f.write("<ol>\n")
                ordered_list = true
            f.write("<li>", txt, "</li>\n")
            continue
        elif ordered_list:
            f.write("</ol>\n")
            ordered_list = false

        # Hyperlinks
        while modified_line.scanf("$*[$+]($+)$*", pre, txt, link, post):
            modified_line = pre & "<a href=\"" & link & "\">" & txt & "</a>" & post

        modified_line = "<p>" & modified_line & "</p>\n"
        f.write(modified_line)

    f.write("</body>\n</html>")
    f.close()

when isMainModule:
    main()
