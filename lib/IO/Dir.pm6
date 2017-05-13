unit class IO::Dir;
use MONKEY-GUTS;

has Mu $!dirh;
has IO::Spec $!SPEC;
has int $!relative;
has str $!path;
has str $!abspath;

method open(IO() $dir = '.', :$absolute) {
    $!path := $dir;
    $!SPEC = $!path.SPEC;
    my str $dir-sep  = $!SPEC.dir-sep;
    $!relative = !$absolute && !$!path.is-absolute;

    $!abspath = $!path.absolute.ends-with: $dir-sep
      ?? $!path.absolute
      !! $!path.absolute ~ $dir-sep;

    $!path = $!path eq '.' || $!path eq $dir-sep
      ?? ''
      !! $!path.ends-with($dir-sep)
        ?? $!path
        !! $!path ~ $dir-sep;

    $!dirh := nqp::opendir(nqp::unbox_s($dir.absolute));
    self
}

method close { $!dirh and nqp::closedir($!dirh) }

method dir(IO::Path:D:
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
                (take IO::Path!new-from-absolute-path(
                  nqp::concat($!abspath,$str-elem),:$!SPEC,:$CWD))
              )
            )
          )
        );
        self.close
      }
    }
}
