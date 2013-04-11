package WWW::CSP::Schema::Result::Report;
use strict;
use warnings;

# ABSTRACT: Report class for WWW::CSP::Report
# VERSION

use base qw( DBIx::Class::Core );
use DateTime;

__PACKAGE__->table('report');
__PACKAGE__->load_components( qw/InflateColumn::DateTime/ );
__PACKAGE__->add_columns(
    report_id => {
        accessor => 'id',
        data_type => 'integer',
        is_numeric => 1,
        is_nullable => 0,
        is_auto_increment => 1,
    },
    report_uri => {
        accessor => 'uri',
        data_type => 'varchar',
        size => 2048,
    },
    report_referrer => {
        accessor => 'referrer',
        data_type => 'varchar',
        size => 2048,
        is_nullable => 1,
    },
    report_blocked_uri => {
        accessor => 'blocked_uri',
        data_type => 'varchar',
        size => 2048,
    },
    report_violated_directive => {
        accessor => 'violated_directive',
        data_type => 'varchar',
        size => 2048,
    },
    report_original_policy => {
        accessor => 'original_policy',
        data_type => 'varchar',
        size => 2048,
    },
    report_timestamp => {
        accessor => 'timestamp',
        data_type => 'datetime',
        timezone => 'UTC',
    },
    report_reporter_ip => {
        accessor => 'reporter_ip',
        data_type => 'varchar',
        size => '39',
        is_nullable => 1,
    },
);

__PACKAGE__->set_primary_key(qw/ report_id /);

=head2 TO_JSON

A method for serializing Reports into JSON. See L<JSON/convert_blessed>.

=cut

sub TO_JSON {
    my $self = shift;
    return { 'csp-report' => {
        'document-uri'          => $self->uri,
        'referrer'              => $self->referrer,
        'blocked-uri'           => $self->blocked_uri,
        'violated-directive'    => $self->violated_directive,
        'original-policy'       => $self->original_policy,
    }};
}

=head2 FROM_JSON

A class method which returns a hashref of parameters required to generate a
Report, given the deserialized JSON document of a report from a client.

You probably want to use L<WWW::CSP::Schema::ResultSet::Report/create_FROM_JSON>
instead.

=cut

sub FROM_JSON {
    my $class = shift;
    my $json  = shift;
    $json     = $json->{'csp-report'} if exists $json->{'csp-report'};
    return {
        report_uri                  => $json->{'document-uri'},
        report_referrer             => $json->{'referrer'},
        report_blocked_uri          => $json->{'blocked-uri'},
        report_violated_directive   => $json->{'violated-directive'},
        report_original_policy      => $json->{'original-policy'},
        report_timestamp            => DateTime->now,
    }
};

1;
