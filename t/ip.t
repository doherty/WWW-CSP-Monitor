use Test::More tests => 2;
use strict;
use warnings;

# the order is important
use WWW::CSP::Receive;
use Dancer::Plugin::DBIC;
use JSON qw( decode_json );
use Dancer::Test;

schema->deploy;

subtest 'IP gets saved' => sub {
    plan tests => 2;

    my $json = do { local $/; <DATA> };
    my $response = dancer_response( POST => '/', { params => decode_json($json) } );
    is $response->{status}, 200;

    my $db_row = schema->resultset('Report')->find({ report_id => 1 });
    can_ok $db_row, qw(reporter_ip);
};

subtest 'IP is private' => sub {
    plan tests => 2;

    my $get = dancer_response( GET => '/1' );
    my $from_json = decode_json( $get->{content} );

    is $from_json->{'reporter_ip'} => undef or diag explain $from_json;
    is $from_json->{'reporter-ip'} => undef or diag explain $from_json;
};

__DATA__
{
  "csp-report": {
    "document-uri": "http://hashbang.ca",
    "referrer": "http://evil.attacker.com",
    "blocked-uri": "http://evil.attacker.com/exfiltrate_browser_data.js",
    "violated-directive": "script-src 'self' https://ajax.googleapis.com",
    "original-policy": "script-src 'self' https://ajax.googleapis.com; report-uri http://hashbang.ca/csp"
  }
}
