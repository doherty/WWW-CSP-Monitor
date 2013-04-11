package WWW::CSP::Schema::ResultSet::Report;
use strict;
use warnings;

# ABSTRACT: Report result set
# VERSION

use base qw( DBIx::Class::ResultSet );
use WWW::CSP::Schema::Result::Report ();
use Net::IP::XS ();

=head2 create_FROM_JSON

Constructs a Report from JSON input.

    my $new_report = schema->resultset('Report')->create_FROM_JSON(
        ip   => request->address,
        json => param('csp-report'),
    );

=cut

sub create_FROM_JSON {
    my $rs = shift;
    my %args = @_;
    $args{ip} = Net::IP->new( $args{ip} ) if defined $args{ip};

    return $rs->create({
        %{ WWW::CSP::Schema::Result::Report->FROM_JSON( $args{json} ) },
        report_reporter_ip => defined $args{ip} ? $args{ip}->ip : $args{ip},
    });
}

1;
