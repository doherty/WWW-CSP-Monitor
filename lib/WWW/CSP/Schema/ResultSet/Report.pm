package WWW::CSP::Schema::ResultSet::Report;
use strict;
use warnings;

# ABSTRACT: Report result set
# VERSION

use base qw( DBIx::Class::ResultSet );
use WWW::CSP::Schema::Result::Report ();

sub create_FROM_JSON {
    my $rs = shift;
    my %args = @_;

    return $rs->create({
        %{ WWW::CSP::Schema::Result::Report->FROM_JSON( $args{json} ) },
        report_reporter_ip => $args{ip},
    });
}

1;
