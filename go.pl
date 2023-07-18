#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw(sum);

my @data;
my %class_hash;
open( IN, "< physics.txt" ) or die;
foreach (<IN>) {
    chomp;
    next if $_ =~ '#';
    push @data, $_;
    my ( $id, $pingshi, $kaoshi, $zongfen, $class, $term0 ) = split m/\s+/;
    $class_hash{$class} = 1;
}
close(IN);
my @class_all = sort {$a cmp $b} keys %class_hash;

# 统计各个学期的卷面及格率和总分及格率
print "# 及格率\n学期 学生人数 卷面及格率 总分及格率\n";
foreach my $term0 ( '22春', '22秋', '23春', '合计' ) {
    my ( $num, $exam, $total ) = pass_rate( $term0, @data );
    printf "$term0 %4d %4.1f%% %4.1f%%\n", $num, $exam, $total;
}

# 统计各个学期不同班级的卷面\总分分数的分布
foreach my $item ('卷面', '总分') {
    print "# $item分数分布\n学期 班级 不及格 60-69 70-79 80-89 90-100\n";
    foreach my $term0 ( '22春', '22秋', '23春', '合计' ) {
        foreach my $class0 (@class_all, '合计') {
            next if $term0 eq '合计' and $class0 ne '合计';
            my @out;
            foreach ('-1 59','60 69', '70 79', '80 89', '90 100') {
                my ($lower, $upper) = split m/\s+/;
                my $rate = percentage($term0, $lower, $upper, $item, $class0, @data);
                push @out, $rate;
            }
            if (sum(@out) > 0) {
                print "$term0 $class0";
                foreach (@out) {
                    printf " %.1f%%", $_;
                }
                print "\n";
            }
        }
    }
}

sub pass_rate {
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

sub percentage {
    my ($term, $lower, $upper, $item, $class, @data) = @_;
    my $total   = 0;
    my $num  = 0;
    foreach (@data) {
        my ( $id, $pingshi, $kaoshi, $zongfen, $class0, $term0 ) = split m/\s+/;

        # 2130621080 97 69 77 21制造2 22春
        next unless $term eq $term0 or $term eq '合计';
        next unless $class0 =~ $class or $class eq '合计';
        $total++;
        $num++ if $lower <= $kaoshi and $kaoshi <= $upper and $item eq '卷面';
        $num++ if $lower <= $zongfen and $zongfen <= $upper and $item eq '总分';
    }
    $total++ if $total == 0;
    return ( $num/$total * 100 );
}
