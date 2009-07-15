package Log::LSB::InitMsg;

use strict;
use warnings;

use Sub::Name;

# Call a function from /lib/lsb/init-functions in a shell
sub run_with_lsb {
  my ($class, $funcname, @args) = @_;
  my $ret = system('/bin/sh', '-c', 
    '. /lib/lsb/init-functions ; cmd=$1 ; shift ; $cmd "$@"', 
    $funcname, # sh process name
    $funcname, @args);

  if (!defined $ret) {
    return;
  }

  return !$ret;
}

BEGIN {
  my @cmds = qw(
  log_success_msg
  log_failure_msg
  log_warning_msg
  log_begin_msg
  log_end_msg
  log_daemon_msg
  log_progress_msg
  );

  for my $cmdname (@cmds) {
    no strict;
    *{$cmdname} = subname $cmdname => sub {
      my $class = shift;
      return $class->run_with_lsb($cmdname, @_);
    };
  }
}

1;
