# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

# Test a few random constants to make sure they match up

use Test;
use Sys::Ptrace qw(PT_TRACE_ME PTRACE_TRACEME);

plan tests => 4;

delete $INC{"linux/ptrace.ph"};
delete $INC{"sys/ptrace.ph"};
delete $INC{"asm/ptrace.ph"};

eval { require "linux/ptrace.ph"; };
eval { require "sys/ptrace.ph"; };

ok PTRACE_ATTACH(),   Sys::Ptrace::PTRACE_ATTACH;
ok PTRACE_SYSCALL(),  Sys::Ptrace::PTRACE_SYSCALL;
ok PTRACE_GETREGS(),  Sys::Ptrace::PTRACE_GETREGS;
ok PTRACE_TRACEME,    PT_TRACE_ME;
