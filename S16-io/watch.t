use v6;

use Test;

plan 1;

# GH rakudo/rakudo#3100
#?rakudo.jvm skip 'nqp::watchfile only implemented as stub for JVM backend'
#?DOES 1
{
    # Test if file change events are not lost.
    my $watch-file = $*SPEC.catfile( $*TMPDIR, "watchme" );
    my $fh = $watch-file.IO.open: :w, :0out-buffer;
    my $start-writing = Promise.new;
    my $start-vow = $start-writing.vow;
    my $done-writing = Promise.new;
    my $done-vow = $done-writing.vow;
    start {
        await $start-writing;
        for ^10 {
            $fh.say: time;
            sleep .01;
        }
        $done-vow.keep(True);
    }

    my $count = 0;
    my $timeout = Promise.in(5);
    react {
        whenever $watch-file.IO.watch -> $e {
            $count++;
        }
        whenever $done-writing {
            done
        }
        whenever $timeout {
            done;
        }
        $start-vow.keep(True);
    }

    if $timeout.status ~~ Planned {
        is $count, 10, "all watch events received";
    }
    else {
        flunk "timed out waiting for file change events";
    }

    LEAVE {
        $fh.close;
        $watch-file.IO.unlink;
    }
}
