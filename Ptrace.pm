package Sys::Ptrace;

# $Id: Ptrace.pm,v 1.2 2001/11/28 00:38:07 rob Exp $

use strict;
use vars qw( @ISA @EXPORT @EXPORT_OK $VERSION $AUTOLOAD );
use Exporter;
use DynaLoader;
use Carp qw( croak );

$VERSION = '0.03';
@ISA = qw(Exporter DynaLoader);

@EXPORT_OK = qw
  (PT_ATTACH
   PT_CONTINUE
   PT_DETACH
   PT_GETFPREGS
   PT_GETFPXREGS
   PT_GETREGS
   PT_KILL
   PT_READ_D
   PT_READ_I
   PT_READ_U
   PT_SETFPREGS
   PT_SETFPXREGS
   PT_SETREGS
   PT_STEP
   PT_SYSCALL
   PT_TRACE_ME
   PT_WRITE_D
   PT_WRITE_I
   PT_WRITE_U
   );

@EXPORT = qw( ptrace );

# Load PTRACE_* constants
eval { require "linux/ptrace.ph"; };  # Perl 5.6 style?
eval { require "sys/ptrace.ph"; };  # Perl 5.005 style?

# Allow export for all of them
foreach (keys %Sys::Ptrace::) {
  push (@EXPORT_OK, $_) if /^PTRACE_/;
}

foreach ( @EXPORT_OK ) {
  # Prototype constants to prepare
  # for correct entry into the AUTOLOAD
  eval "sub $_ ();" if /^PT_/;
}

sub AUTOLOAD {
  # This AUTOLOAD is used to 'autoload' constants from the constant()
  # XS function.  If a constant is not found then control is passed
  # to the AUTOLOAD in AutoLoader.

  my $constname;
  ($constname = $AUTOLOAD) =~ s/.*:://;
  croak "& not defined" if $constname eq 'constant';
  my $val = constant($constname, @_ ? $_[0] : 0);
  if ($! != 0) {
    croak "Your vendor has not defined Sys::Ptrace macro $constname";
  }
  eval "sub $constname () { $val; }";
  goto &$AUTOLOAD;
}

bootstrap Sys::Ptrace $VERSION;

# Preloaded methods go here.

# Dumb wrapper function to call the internal ptrace C function.
# Returns true on success and sets $! on failure.
sub ptrace {
  my ($request, $pid, $addr, $data) = @_;
  $pid  ||= 0;
  $addr ||= 0;
  $data ||= 0;
  my $result = _ptrace($request, $pid, $addr, $data);
  if ($request == PT_READ_I() ||
      $request == PT_READ_D() ||
      $request == PT_READ_U()) {
    if (ref $data eq "SCALAR") {
      $$data = $result;
    } elsif (@_ > 3) {
      $_[3] = $result;
    } else {
      croak 'PTRACE_PEEK* requires $data to store into';
    }
    $result = 0;
  }
  return !$result;
}


1;
__END__

=head1 NAME

Sys::Ptrace - Perl interface to the ptrace(2) command

=head1 SYNOPSIS

  use Sys::Ptrace qw(ptrace PTRACE_TRACEME);

  ptrace( PTRACE_TRACEME, $pid, $addr, $data );


=head1 EXAMPLES

  use Sys::Ptrace qw(ptrace PTRACE_SYSCALL PTRACE_CONT PTRACE_TRACEME);

  ptrace(PTRACE_SYSCALL, $pid, undef, undef);

  ptrace(PTRACE_CONT, $pid, undef, undef);

  ptrace(PTRACE_TRACEME, $$, 0, 0);

=head1 DESCRIPTION

Perl interface to the ptrace(2) command.  This module is
meant to be used mostly for debugging purposes and for
black box testing where the source code is generally
not available or unknown.  This may also prove useful
when the program or script in question has already been
compiled to a binary or it is third party code.

=head2 EXPORT

ptrace( $request, $pid, $addr, $data)

  Returns true on success and sets $! on failure.


=head2 EXPORT_OK

  PT_ATTACH
  PT_CONTINUE
  PT_DETACH
  PT_GETFPREGS
  PT_GETFPXREGS
  PT_GETREGS
  PT_KILL
  PT_READ_D
  PT_READ_I
  PT_READ_U
  PT_SETFPREGS
  PT_SETFPXREGS
  PT_SETREGS
  PT_STEP
  PT_SYSCALL
  PT_TRACE_ME
  PT_WRITE_D
  PT_WRITE_I
  PT_WRITE_U
  ptrace

and all PTRACE_* constants defined in linux/ptrace.h and asm/ptrace.h

=head1 BUGS

It is designed specifically for linux OS on x86 platform.
It is not meant to be tested or used on any other system
at this time.  Any portability changes and/or bug fixes
should be sent to the author.

=head1 AUTHOR

Rob Brown, rob@roobik.com

=head1 COPYRIGHT

Copyright (c) 2001 Rob Brown. All rights reserved.

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

ptrace(2)

=cut
