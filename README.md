# PathFinder
Various implementations of the "shortest path between two dictionary words" problem.

## Generating the dictionary file
To keep this repository small, I have not included any dictionary files.

### OSX
If you're running OSX, then you're in luck because OSX comes with a built-in dictionary file. Here's an example of generating a dictionary of words that are 2 to 5 characters in length.

The following example requires `ack` because (for some unkown reason) recent versions of OSX (i.e., 10.9) removed support for `grep -P 'perl_regex' ...`. You can use Brew to quickly install: `brew install ack`.

```bash
$ cp /usr/share/dict/words ./full-dictionary.txt
$ ack '^[a-z]{2,5}$' full-dictionary.txt > 2-5-dictionary.txt 
```

## Ruby
Here's an example of running the Ruby PathFinder on the dictionary file we created above.

```bash
$ ruby path-finder.rb 2-5-dictionary.txt
```
