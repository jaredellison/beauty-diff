# beauty-diff

*Preview and accept the changes of a beautified file.*

I've been using and enjoying the proofreading utility of [js-beautify](https://beautifier.io/) to clean my code and make everything spiffy. I don't run js-beautify that often, but when I do, I want to be sure that I agree with all the changes it made. I want to pay attention to the feedback so I can write better code and be aware if anything goes awry. Note that although js-beautify is available in a web application, it is much quicker to use the command-line version. Also note that although js-beautify works on JavaScript files, it also processes HTML and CSS.

This is a simple bash script (for Unix or Mac machines) which sends the output of `js-beautify`  to a temporary file and compares it with the original file. If you approve the changes, it replace the original file.

The comparison is done using [colordiff](http://www.colordiff.org/), a simple utility like gnu's classic `diff` only `colordiff` shows its output in color, in a similar way to `git`.

## How to use it:

I have copied the script to my local binaries folder as:

```bash
/usr/local/bin/beauty-diff
```

To make the script executable type:

```
chmod +x /usr/local/bin/beauty-diff
```

To run the script type:

```bash
beauty-diff fileName
```

### A quick demo:

If you just want a quick test, clone this repository, install [js-beautify](https://github.com/beautify-web/js-beautify) and [colordiff](https://github.com/daveewart/colordiff), navigate to the cloned directory and run beauty-diff on the example file: `ugly.js`:

```
./beauty-diff ugly.js
```

You should see this output:

![Example Image](https://github.com/jaredellison/beauty-diff/blob/master/example/Example%20Image.png?raw=true)

## To Do:

- [ ] Allow the script to accept options and call js-beautify with them
- [ ] Allow the script to handle an array of input files
- [ ] Suggest this functionality as an addition to the js-beautify project
  - [ ] Look into implementing colordiff using node.js
  - [ ] Look into implementing colordiff using Python
- [x] Allow the script to handle filenames where a full file path is passed
- [x] Test on other unix machines
