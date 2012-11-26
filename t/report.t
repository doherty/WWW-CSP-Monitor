use Test::More tests => 4;
use strict;
use warnings;

# the order is important
use WWW::CSP::Receive;
use Dancer::Plugin::DBIC;
use JSON qw( decode_json );
use Dancer::Test;

schema->deploy;

route_exists [POST => '/csp'], 'a route handler is defined for POST /csp';

my $json = do { local $/; <DATA> };
my $payload = decode_json($json);
my $response = dancer_response( POST => '/csp', { params => $payload } );
is $response->{status}, 200, 'POSTed a report';
is_deeply decode_json($response->{content}), { success => 1, report_id => 1 }, 'POST claims success'
    or diag explain $response;

my $get = dancer_response( GET => '/1' );
is_deeply decode_json($get->{content}), $payload, 'report can be retrieved'
    or diag explain { response => $get, logs => read_logs };

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
