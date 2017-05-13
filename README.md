[![Build Status](https://travis-ci.org/zoffixznet/perl6-IO-Dir.svg)](https://travis-ci.org/zoffixznet/perl6-IO-Dir)

# NAME

IO::Dir - IO::Path.dir you can close

# SYNOPSIS

```perl6
    # Won't always suit, since non-exhausted iterator holds on to an open
    # file descriptor until GC:
    'foo'.IO.dir[^3].say;

    # all good; we explicitly close the file descriptor when done
    .dir[^3].say and .close with IO::Dir.open: 'foo';
```

# DESCRIPTION

[`IO::Path.dir`](https://docs.perl6.org/routine/dir) does the job well for
most cases, however, there's an edge case where it's no good:

- You don't exhaust or [eagerly](https://docs.perl6.org/routine/eager)
    evaluate the `Seq` `dir` returns
- You do that enough times in some tight loop that
[GC](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science))
doesn't get a chance to clean up unreachable `dir` `Seq`s; or
- You run this on some system with tight open file limits

If you're in that category, then good news! `IO::Dir` gives you a `dir` whose
file descriptor you can close without relying on GC or having to [fully
reify](https://docs.perl6.org/language/glossary#index-entry-Reify)
the dir's `Seq`.

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-IO-Dir

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-IO-Dir/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
