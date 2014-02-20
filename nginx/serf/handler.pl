#!/usr/bin/perl
use strict;
use warnings;

my $active_members = `serf members | grep my_app | grep alive`;

# Response of 'serf members'
# my_app01     172.17.0.6:7946    alive    role=my_app
# my_app02     172.17.0.7:7946    failed   role=my_app

my @backends;
for my $line (split /\n/, $active_members) {
    $line =~ /(\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}):\d{1,5}/;
    push @backends, $1;
}

open my $fh, '>', '/etc/nginx/conf.d/my_app_backends.conf' or die $!;
print $fh "upstream my_app_backends {\n";
if (@backends) {
    print $fh "    server $_:5000;\n" for @backends;
} else {
    print $fh "    server localhost;\n";
}
print $fh "}\n";
close $fh;

system('/usr/sbin/nginx -s reload');

exit;

__END__
