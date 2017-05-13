use lib <lib>;
use Testo;

plan 11;

use IO::Dir;

with IO::Dir.new.open: '.' {
    is $_, IO::Dir;
    is .dir, Seq;
    is .dir.grep({.basename eq 't'}), True;
    is .close, IO::Dir;
}

with IO::Dir.new.open: 'test-dir' {
    is $_, IO::Dir;
    is .dir, Seq;
    is .dir[0].resolve, 't/one'.IO.resolve;
    is .dir[1].resolve, 't/three'.IO.resolve;
    is .dir[2].resolve, 't/two'.IO.resolve;
    is .dir[3].defined, False;
    is .close, IO::Dir;
}
