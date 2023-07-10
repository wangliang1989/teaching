#!/usr/bin/env perl
use strict;
use warnings;

my @data;
open( IN, "< physics.txt" ) or die;
foreach (<IN>) {
    chomp;
    push @data, $_ unless $_ =~ '#';
}
close(IN);

print "学期 学生人数 卷面及格率 总分及格率\n";
foreach my $term0 ( '22春', '22秋', '23春', '合计' ) {
    my ( $num, $exam, $total ) = check( $term0, @data );
    printf "$term0 %4d %4.1f%% %4.1f%%\n", $num, $exam, $total;
}

sub check {
    my $term  = shift;
    my $num   = 0;
    my $exam  = 0;
    my $total = 0;
    foreach (@_) {
        my ( $id, $pingshi, $kaoshi, $zongfen, $class, $term0 ) = split m/\s+/;

        # 2130621080 97 69 77 21制造2 22春
        next unless $term eq $term0 or $term eq '合计';
        $num++;
        $exam++  if $kaoshi >= 60;
        $total++ if $zongfen >= 60;
    }
    return ( $num, $exam / $num * 100, $total / $num * 100 );
}
