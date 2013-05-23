#!/usr/bin/perl

use common::sense;

my $host = $ARGV[0];
my $stage = $ARGV[1];

unless ($stage) {
    my @packages = qx/ssh $host "rpm -qa --queryformat '%{name}\\n' 'perl-*'"/;
    chomp foreach @packages;
    system 'sudo', 'zypper', 'install', @packages;

    system $0, $host, $_ foreach (1 .. 3);
}
else {
    my @modules = qx{ssh $host "perl -MExtUtils::Installed -w -e 'print join(qq(\n), ExtUtils::Installed->new()->modules())'"};
    chomp foreach @modules;
    @modules = grep { not /-/xm and not $_ eq 'Perl' } @modules;
    my @uninstalled = grep { eval "require $_"; $@ } @modules;

    say "uninstalled: @uninstalled";

    if ($stage == 1) {
        system 'sudo', 'zypper', 'install', map "perl($_)", @uninstalled;
    }
    elsif ($stage == 2) {
        system 'cpanp', 'install', @uninstalled;
    }
    elsif ($stage == 3) {
        say "Couldn't install: @uninstalled";
    }
}
