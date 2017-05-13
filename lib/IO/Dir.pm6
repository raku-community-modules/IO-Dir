unit class IO::Dir;
use MONKEY-GUTS;

has Mu $!dirh;
has IO::Spec $!SPEC;
has int $!relative;
has str $!path;
has str $!abspath;

method open(IO() $dir = '.', :$absolute) {
    $!SPEC = $dir.SPEC;
    my str $dir-sep  = $!SPEC.dir-sep;
    $!relative = !$absolute && !$dir.is-absolute;

    $!abspath = $dir.absolute.ends-with($dir-sep)
      ?? $dir.absolute
      !! $dir.absolute ~ $dir-sep;

    $!path = $dir.path eq '.' || $dir.path eq $dir-sep
      ?? ''
      !! $dir.path.ends-with($dir-sep)
        ?? $dir.path
        !! $dir.path ~ $dir-sep;

    $!dirh := nqp::opendir(nqp::unbox_s($!abspath));
    self
}

method close {
    $!dirh and nqp::closedir($!dirh);
    self
}

method dir(::?CLASS:D:
    Mu :$test = $*SPEC.curupdir,
    :$absolute,
    :$Str,
    :$CWD = $*CWD,
) {
    CATCH { default {
        fail X::IO::Dir.new(
          :path($.absolute), :os-error(.Str) );
    } }
    gather {
       my $cwd = $CWD.IO; # faster than `temp`
      { my $*CWD = $cwd;
        nqp::until(
          nqp::isnull_s(my str $str-elem = nqp::nextfiledir($!dirh))
            || nqp::iseq_i(nqp::chars($str-elem),0),
          nqp::if(
            $test.ACCEPTS($str-elem),
            nqp::if(
              $Str,
              (take
                nqp::concat(nqp::if($!relative,$!path,$!abspath),$str-elem)),
              nqp::if(
                $!relative,
                (take IO::Path.new(
                  nqp::concat($!path,$str-elem),:$!SPEC,:$CWD)),
                (take IO::Path.new(
                  nqp::concat($!abspath,$str-elem),:$!SPEC,:$CWD))))));
        self.close
      }
    }
}
